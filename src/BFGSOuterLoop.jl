"""
    BFGSOuterLoop

Julia port of the BFGS-Wolfe algorithm for unconstrained multiobjective
optimization (Prudente & Souza, "A quasi-Newton method with Wolfe line
searches for multiobjective optimization", JOTA 194, 2022), from the
reference Fortran implementation in `bfgsMOP/MOPsolverBFGS.f90` (see also
`bfgsMOP/bfgs.f90`, `bfgsMOP/lsvecopt.f90`, `bfgsMOP/scalefactor.f90`).

Ported here: only the BFGS-Wolfe variant (not the Standard-BFGS-Armijo/Wolfe
variants in `MOPsolverStBFGS*.f90`). The vector Wolfe line search
(`lsvecopt.f90`) is ported without its quadratic-function shortcut (dead
code for this driver anyway: `MOPsolverBFGS.f90` hardcodes
`quadratic(:) = .false.`, and `MyProblem.jl` has no `quadstep`), and always
assuming the standard Wolfe line-search type (`LStype=1`, the only value
`MOPsolverBFGS.f90` ever uses -- so `tolLS` is always `Inf`, which drops
several branches of the original algorithm). The scalar Moré-Thuente
sub-searches use `LineSearches.jl`'s `MoreThuente` instead of translating
`morethuente.f`.

The subproblem solve (`innersolver.f90`'s call to Algencan) is *not*
ported -- it is the pluggable point of this whole exercise. `bfgs_mop`
takes a `subproblem_solver` callback with signature
`(g1,g2,B1,B2) -> (d, status)`, matching the existing `solve_dual`
(`ScalarDualNewton.jl`) and `solve_primal_socp`/`solve_primal_qcqp_raw`
(`PrimalSOCP.jl`) already built for Families 2/3. Restricted to `m=2`
(bi-objective) throughout, matching every subproblem solver available.
"""
module BFGSOuterLoop

using LinearAlgebra
using LineSearches
using JuMP: MOI

using ..ScalarDualNewton: DualProblem, solve_dual
using ..PrimalSOCP: solve_primal_socp, solve_primal_qcqp_raw

export bfgs_mop, bfgs_update!, wolfe_linesearch, compute_scale_factors,
       subproblem_algorithm1, subproblem_primal_socp, subproblem_primal_qcqp,
       make_penalized_eval

# =========================================================================
# Box-constraint penalization (myproblem.f90's `penalizef`/`penalizeg`)
# =========================================================================

const PENALTY_PARAM = 1.0e10

"""
    make_penalized_eval(evalf_fn, evalg_fn!, l, u; penparam=1e10, penalize=true) -> (pf, pg!)

Wraps `evalf_fn(ind,x)`/`evalg_fn!(g,ind,x)` with the cubic box-constraint
penalty from `myproblem.f90`'s `penalizef`/`penalizeg` (μ = `penparam`):

    f(x) += μ/3 * Σᵢ (max(0, xᵢ-uᵢ)³ + max(0, lᵢ-xᵢ)³)
    g(x) += μ   * Σᵢ (max(0, xᵢ-uᵢ)² - max(0, lᵢ-xᵢ)²)   (componentwise)

The term is exactly zero while `x` is inside the box `[l,u]` and grows
steeply outside it. `penalize` mirrors `myproblem.f90`'s per-problem
`penalize` flag: when `false`, the cubic term is skipped entirely (matching
the Fortran reference, which only applies this penalty to the subset of
problems it flags `penalize=.true.`) -- see `PENALIZED_PROBLEMS` in
`run_experiments.jl`. The `DomainError`/`ArgumentError` -> `sentinel`
safety net (Julia's `sqrt`/`log`/etc. throw on invalid real input, unlike
Fortran's silent NaN) is applied unconditionally either way, since a trial
point can transiently leave the box during a line search regardless of
whether that problem is penalized.
"""
function make_penalized_eval(evalf_fn, evalg_fn!, l::Vector{Float64}, u::Vector{Float64};
                              penparam::Float64=PENALTY_PARAM, sentinel::Float64=1.0e100,
                              penalize::Bool=true)
    pf = (ind, x) -> begin
        pen = 0.0
        if penalize
            @inbounds for i in eachindex(x)
                pen += max(0.0, x[i] - u[i])^3 + max(0.0, l[i] - x[i])^3
            end
            pen *= penparam / 3
        end
        f = try
            evalf_fn(ind, x)
        catch e
            (e isa DomainError || e isa ArgumentError) || rethrow()
            sentinel
        end
        return f + pen
    end
    pg! = (g, ind, x) -> begin
        ok = try
            evalg_fn!(g, ind, x)
            true
        catch e
            (e isa DomainError || e isa ArgumentError) || rethrow()
            false
        end
        ok || fill!(g, 0.0)
        if penalize
            @inbounds for i in eachindex(x)
                g[i] += penparam * (max(0.0, x[i] - u[i])^2 - max(0.0, l[i] - x[i])^2)
            end
        end
        return g
    end
    return pf, pg!
end

# =========================================================================
# scalefactor.f90
# =========================================================================

"""
    compute_scale_factors(n, m, x0, scaleF, evalg_fn!) -> sF

Port of `scalefactor.f90`. If `scaleF`, returns `sF[ind] = max(eps,
1/max(1,‖∇f_ind(x0)‖_∞))`; otherwise all ones.
"""
function compute_scale_factors(n::Int, m::Int, x0::Vector{Float64}, scaleF::Bool, evalg_fn!)
    scaleF || return ones(Float64, m)
    eps0 = 1.0e-8
    sF = ones(Float64, m)
    g = zeros(Float64, n)
    for ind in 1:m
        evalg_fn!(g, ind, x0)
        sF[ind] = max(1.0, maximum(abs, g))
        sF[ind] = max(eps0, 1.0 / sF[ind])
    end
    return sF
end

# =========================================================================
# bfgs.f90 -- modified BFGS update (JOTA 2022)
# =========================================================================

"""
    bfgs_update!(B, x, xprev, JF, JFprev, strconvex, theta)

Port of `BFGSupdate` (`bfgs.f90`). Updates each `B[:,:,ind]` in place.
`theta` is the *previous* iteration's optimality measure (used only to scale
the curvature-condition tolerance `eps`), matching the Fortran call site.
"""
function bfgs_update!(B::Array{Float64,3}, x::Vector{Float64}, xprev::Vector{Float64},
                       JF::Matrix{Float64}, JFprev::Matrix{Float64},
                       strconvex::AbstractVector{Bool}, theta::Float64)
    n, _, m = size(B)
    # eps0 matches bfgs.f90's `eps` exactly (theta-scaled), and is used only
    # for the curvature test below, same as the Fortran reference.
    eps0 = 1.0e-6 * min(abs(theta), 1.0)
    # Fixed, NOT theta-scaled: guards against sTBs/sTy/denom collapsing to
    # (near) zero, which would silently poison B with NaN/Inf and propagate
    # into every later iteration. Not part of the original Fortran (which
    # has no such guard), added defensively. Using eps0 here instead would
    # be wrong: eps0 -> 0 as theta -> 0, i.e. the guard would vanish exactly
    # when iterates are closest to convergence and B is most senstive.
    guard_eps = 1.0e-12
    s = x .- xprev
    Dxs = maximum(JF * s)

    for ind in 1:m
        y = JF[ind, :] .- JFprev[ind, :]
        sTy = dot(s, y)
        Bind = view(B, :, :, ind)
        Bs = Bind * s
        sTBs = dot(s, Bs)

        if strconvex[ind] || sTy > eps0
            (abs(sTBs) > guard_eps && abs(sTy) > guard_eps) || continue
            Bind .= Bind .- (Bs * Bs') ./ sTBs .+ (y * y') ./ sTy
        else
            rho = Dxs - dot(JFprev[ind, :], s)
            denom = (rho - sTy)^2 + rho * sTBs
            abs(denom) > guard_eps || continue
            Bind .= Bind .- rho .* (Bs * Bs') ./ denom .+ sTBs .* (y * y') ./ denom .+
                    (rho - sTy) .* (y * Bs' .+ Bs * y') ./ denom
        end
    end
    return nothing
end

# =========================================================================
# lsvecopt.f90 -- vector Wolfe line search (simplified: no quadratic
# shortcut, LStype=1 fixed, so tolLS=Inf throughout)
# =========================================================================

"""
    wolfe_linesearch(evalphi, evalgphi, stp0, stpmin, stpmax, f0, g0, ftol, gtol;
                      maxoutiter=100) -> (stp, fend, nfev, ngev, info)

Port of `lsvecopt.f90` (simplified as described in the module docstring).
`evalphi(stp, ind) -> f`, `evalgphi(stp, ind) -> g` evaluate
`φ_ind(stp) = f_ind(x+stp*d)` and its directional derivative. `f0[ind]`,
`g0[ind]` are `φ_ind(0)`, `φ'_ind(0)`.

`info`: `0` success (sufficient decrease + curvature satisfied), `1` step
pinned at `stpmin`, `2` step pinned at `stpmax`, `3` rounding errors
prevented progress, `5` maximum number of (outer) iterations reached, `-1`
`d` is not a descent direction. (The Fortran reference `lsvecopt.f90`, via
MINPACK-2's `dcsrch`, also has an `info=4` "bracket width below xtol" case,
distinct from `info=3`'s "rounding errors" -- but `LineSearches.jl`'s
`MoreThuente` doesn't expose that distinction in its `LineSearchException`,
so this port can't reproduce it; every such case is reported as `info=3`
here instead.)
"""
function wolfe_linesearch(evalphi, evalgphi, stp0::Float64, stpmin::Float64, stpmax::Float64,
                           f0::Vector{Float64}, g0::Vector{Float64},
                           ftol::Float64, gtol::Float64; maxoutiter::Int=100)
    m = length(f0)
    ftolinner = min(1.1 * ftol, 0.75 * ftol + 0.25 * gtol)
    gtolinner = max(0.9 * gtol, 0.25 * ftol + 0.75 * gtol)

    nfev = 0
    ngev = 0
    fend = zeros(Float64, m)

    maxg0 = maximum(g0)
    maxg0 >= 0 && return (stp=stp0, fend=fend, nfev=0, ngev=0, info=-1)

    ftest = ftol * maxg0
    gtest = -gtol * maxg0

    stp = stp0
    stpmax_work = stpmax
    brackt = false
    ind = argmin(g0)

    # Initial sufficient-decrease / curvature check at stp0.
    sdc = true
    for i in 1:m
        f = evalphi(stp, i); nfev += 1
        fend[i] = f
        if f > f0[i] + ftest * stp
            sdc = false; brackt = true; ind = i; stpmax_work = stp
            break
        end
    end
    cc = false
    if sdc
        maxg = -Inf
        for i in 1:m
            g = evalgphi(stp, i); ngev += 1
            maxg = max(maxg, g)
        end
        cc = maxg >= -gtest
    end

    MTinfo = -99
    outiter = 0
    indwork = ind

    while true
        sdc && cc && return (stp=stp, fend=fend, nfev=nfev, ngev=ngev, info=0)
        outiter > 0 && MTinfo == 1 && return (stp=stp, fend=fend, nfev=nfev, ngev=ngev, info=1)
        !brackt && stp == stpmax && return (stp=stp, fend=fend, nfev=nfev, ngev=ngev, info=2)
        outiter > 0 && MTinfo == 3 && return (stp=stp, fend=fend, nfev=nfev, ngev=ngev, info=3)
        outiter >= maxoutiter && return (stp=stp, fend=fend, nfev=nfev, ngev=ngev, info=5)

        outiter += 1

        ϕdϕ = α -> begin
            f = evalphi(α, ind); nfev += 1
            g = evalgphi(α, ind); ngev += 1
            (f, g)
        end
        ls = LineSearches.MoreThuente(; f_tol=ftolinner, gtol=gtolinner,
                                        alphamin=stpmin, alphamax=stpmax_work)

        local newstp, newf
        try
            newstp, newf = ls(ϕdϕ, stp, f0[ind], maxg0)
            MTinfo = newstp == stpmax_work ? 2 : 0
        catch e
            # LineSearches.MoreThuente can also throw a plain ArgumentError
            # ("Minimizer not bracketed") from its internal `cstep` when the
            # bracket degenerates numerically -- treated the same as the
            # documented LineSearchException failure modes (rounding errors
            # prevented further progress) rather than crashing the whole
            # outer loop.
            (e isa LineSearches.LineSearchException || e isa ArgumentError) || rethrow()
            if e isa LineSearches.LineSearchException
                newstp = e.alpha
                if newstp <= stpmin
                    MTinfo = 1
                elseif newstp >= stpmax_work
                    MTinfo = 2
                else
                    MTinfo = 3
                end
            else
                newstp = stp
                MTinfo = 3
            end
            newf = evalphi(newstp, ind); nfev += 1
        end

        newg = evalgphi(newstp, ind); ngev += 1
        stp = newstp
        indwork = ind
        fend[ind] = newf

        if MTinfo != 1 && MTinfo != 3
            sdc = true
            for i in 1:m
                (MTinfo == 0 && i == indwork) && continue
                f = evalphi(stp, i); nfev += 1
                fend[i] = f
                if f > f0[i] + ftest * stp
                    sdc = false; ind = i; brackt = true; stpmax_work = stp
                    break
                end
            end
            cc = false
            if sdc
                maxg = MTinfo == 0 ? newg : -Inf
                for i in 1:m
                    (MTinfo == 0 && i == indwork) && continue
                    g = evalgphi(stp, i); ngev += 1
                    maxg = max(maxg, g)
                end
                cc = maxg >= -gtest
            end
        end
    end
end

# =========================================================================
# innersolver.f90 replacement: pluggable subproblem solvers (m=2 only)
# =========================================================================

const _ACCEPTABLE_SOLVER_STATUSES = (MOI.OPTIMAL, MOI.ALMOST_OPTIMAL, MOI.LOCALLY_SOLVED)
const _ACCEPTABLE_ALG1_STATUSES = (:converged, :endpoint0, :endpoint1, :degenerate)

"""
    subproblem_algorithm1(g1, g2, B1, B2) -> (d, status)

Solves the bi-objective Newton-type subproblem via Algorithm 1
(`solve_dual`, `ScalarDualNewton.jl`). `status` is `:success` or
`:failure`. `solve_dual` itself regularizes `B1`, `B2` on demand if they
fail to be positive definite (`ScalarDualNewton._ensure_spd`), so no
special handling is needed here.

Still guarded against exceptions (e.g. in the rare case that
regularization itself fails): any exception is caught and reported as
`:failure` rather than crashing the whole outer loop, matching how a
genuine solver-reported failure status is handled.
"""
function subproblem_algorithm1(g1, g2, B1, B2)
    try
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        return res.d, (res.status in _ACCEPTABLE_ALG1_STATUSES ? :success : :failure)
    catch
        return zeros(length(g1)), :failure
    end
end

"""
    subproblem_primal_socp(optimizer) -> (g1,g2,B1,B2) -> (d, status)

Returns a subproblem solver calling `solve_primal_socp` (RSOC reformulation)
with the given JuMP `optimizer` (e.g. `Clarabel.Optimizer`, `Mosek.Optimizer`,
`Gurobi.Optimizer`/`GurobiSilent`). Guarded against exceptions, see
`subproblem_algorithm1`.
"""
function subproblem_primal_socp(optimizer)
    return (g1, g2, B1, B2) -> begin
        try
            sol = solve_primal_socp(g1, g2, B1, B2; optimizer=optimizer)
            return sol.d, (sol.status in _ACCEPTABLE_SOLVER_STATUSES ? :success : :failure)
        catch
            return zeros(length(g1)), :failure
        end
    end
end

"""
    subproblem_primal_qcqp(optimizer) -> (g1,g2,B1,B2) -> (d, status)

Returns a subproblem solver calling `solve_primal_qcqp_raw` (raw quadratic
constraints, for solvers that don't accept conic constraints, e.g. Ipopt).
Guarded against exceptions, see `subproblem_algorithm1`.
"""
function subproblem_primal_qcqp(optimizer)
    return (g1, g2, B1, B2) -> begin
        try
            sol = solve_primal_qcqp_raw(g1, g2, B1, B2; optimizer=optimizer)
            return sol.d, (sol.status in _ACCEPTABLE_SOLVER_STATUSES ? :success : :failure)
        catch
            return zeros(length(g1)), :failure
        end
    end
end

# =========================================================================
# MOPsolverBFGS.f90 -- outer loop
# =========================================================================

"""
    bfgs_mop(n, x0, strconvex, scaleF, evalf_fn, evalg_fn!; subproblem_solver,
             maxoutiter=2000, epsopt=5√(2^-52), ftol=1e-4, gtol=1e-1,
             stpmin=1e-15, stpmax=1e10) -> (x, outiter, elapsed, nfev, ngev, theta, status)

Port of `MOPsolverBFGS.f90`'s main loop, restricted to `m=2` (bi-objective).
`evalf_fn(ind,x) -> f`, `evalg_fn!(g,ind,x)` evaluate the raw (unscaled)
objective/gradient (e.g. `MyProblem.jl`'s `evalf`/`evalg!`, with `n` and the
active `PROBLEM` already bound by the caller). `subproblem_solver(g1,g2,B1,B2)
-> (d,status)` is the pluggable subproblem solve -- see
`subproblem_algorithm1`/`subproblem_primal_socp`/`subproblem_primal_qcqp`.

`status` is `:converged`, `:maxit`, `:subproblem_error`, or
`:linesearch_error` (mirrors Fortran's `inform` 0/1/-1/2).
"""
function bfgs_mop(n::Int, x0::Vector{Float64}, strconvex::AbstractVector{Bool}, scaleF::Bool,
                   evalf_fn, evalg_fn!;
                   subproblem_solver,
                   maxoutiter::Int=2000,
                   epsopt::Float64=5.0 * sqrt(2.0^(-52)),
                   ftol::Float64=1.0e-4, gtol::Float64=1.0e-1,
                   stpmin::Float64=1.0e-15, stpmax::Float64=1.0e10,
                   verbose::Bool=false)
    m = 2
    length(strconvex) == m || throw(ArgumentError(
        "bfgs_mop is restricted to m=2 (bi-objective); got length(strconvex)=$(length(strconvex))"))
    t0 = time()

    x = copy(x0)
    xprev = zeros(Float64, n)
    JF = zeros(Float64, m, n)
    JFprev = zeros(Float64, m, n)
    JFin = zeros(Float64, m, n)
    B = zeros(Float64, n, n, m)

    sF = compute_scale_factors(n, m, x0, scaleF, evalg_fn!)

    outiter = 0
    nfev = 0
    ngev = 0
    theta = 0.0
    infoLS = -99
    fend = zeros(Float64, m)
    status = :maxit

    while true
        # ---- Jacobian --------------------------------------------------
        if outiter > 0
            JFprev .= JF
        end
        if outiter > 0 && (infoLS == 0 || infoLS == 2)
            JF .= JFin
        else
            g = zeros(Float64, n)
            for ind in 1:m
                evalg_fn!(g, ind, x)
                ngev += 1
                JF[ind, :] .= sF[ind] .* g
            end
        end

        # ---- BFGS matrices ----------------------------------------------
        if outiter == 0
            for ind in 1:m
                B[:, :, ind] .= Matrix{Float64}(I, n, n)
            end
        else
            bfgs_update!(B, x, xprev, JF, JFprev, strconvex, theta)
        end

        # ---- Subproblem ---------------------------------------------------
        d, substatus = subproblem_solver(JF[1, :], JF[2, :], Symmetric(B[:, :, 1]), Symmetric(B[:, :, 2]))

        if substatus != :success
            status = :subproblem_error
            break
        end

        theta = maximum(dot(JF[ind, :], d) + 0.5 * dot(B[:, :, ind] * d, d) for ind in 1:m)

        verbose && println("out=$outiter  theta=$theta  infoLS=$infoLS  nfev=$nfev  ngev=$ngev")

        # ---- Stopping tests -----------------------------------------------
        if abs(theta) <= epsopt
            status = :converged
            break
        end
        if outiter >= maxoutiter
            status = :maxit
            break
        end

        # ---- Iteration ------------------------------------------------
        outiter += 1
        stp = 1.0

        phi0 = if outiter > 1 && (infoLS == 0 || infoLS == 2)
            fend
        else
            p = [sF[ind] * evalf_fn(ind, x) for ind in 1:m]
            nfev += m
            p
        end
        gphi0 = JF * d

        evalphi = (s, ind) -> sF[ind] * evalf_fn(ind, x .+ s .* d)
        evalgphi = (s, ind) -> begin
            g = zeros(Float64, n)
            evalg_fn!(g, ind, x .+ s .* d)
            JFin[ind, :] .= sF[ind] .* g
            dot(sF[ind] .* g, d)
        end

        stp, fend, nfevLS, ngevLS, infoLS = wolfe_linesearch(evalphi, evalgphi, stp, stpmin, stpmax,
                                                              phi0, gphi0, ftol, gtol)

        verbose && println("   stp=$stp  info=$infoLS")

        if infoLS == -1
            status = abs(theta) <= 10.0 * epsopt ? :converged : :linesearch_error
            break
        end
        nfev += nfevLS
        ngev += ngevLS

        xprev .= x
        x .= x .+ stp .* d
    end

    elapsed = time() - t0
    return (x=x, outiter=outiter, elapsed=elapsed, nfev=nfev, ngev=ngev, theta=theta, status=status)
end

end # module
