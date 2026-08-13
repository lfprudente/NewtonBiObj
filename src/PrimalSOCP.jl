"""
    PrimalSOCP

Solves the primal epigraph problem (3) from the paper,

    min_{t,d}  t
    s.t.       gⱼᵀd + 1/2 dᵀBⱼd ≤ t,   j = 1,...,m,   Bⱼ ≻ 0,

using the exact rotated second-order cone (RSOC) reformulation:

    Bⱼ = LⱼLⱼᵀ  (Cholesky)
    gⱼᵀd + 1/2 dᵀBⱼd ≤ t  ⟺  (t - gⱼᵀd, 1, Lⱼᵀd) ∈ 𝒬_r

This is a pure SOCP (linear objective + second-order conic constraints),
exactly the problem class that solvers such as Clarabel, Mosek, Gurobi, and
ECOS handle natively and efficiently -- this is the strongest primal
competitor, both in terms of problem structure and available software.

`solve_primal_socp` and `solve_primal_qcqp_raw` are specific to the
bi-objective case (m=2), mirroring the `g1, g2, B1, B2` convention of
`DualProblem`/`solve_dual` (`ScalarDualNewton.jl`).
"""
module PrimalSOCP

using JuMP
using LinearAlgebra

export solve_primal_socp, solve_primal_qcqp_raw

# Solver-specific tolerance mapping, shared by solve_primal_socp and
# solve_primal_qcqp_raw. Matched by name, not by type, so this module has
# no hard dependency on Clarabel.jl, MosekTools.jl, or Gurobi.jl themselves
# -- only the calling script needs `using Clarabel` / `using MosekTools` /
# `using Gurobi`.
# Termination statuses treated as "trust the returned point". MOI.OPTIMAL/
# MOI.ALMOST_OPTIMAL are what conic solvers (Clarabel, Mosek, Gurobi's SOCP
# path) report; MOI.LOCALLY_SOLVED is what general QCP/NLP solvers (Gurobi's
# *raw* quadratic-constraint path, Ipopt) report for a converged point --
# since our problem is convex, "locally solved" is globally optimal here
# too, so excluding it would wrongly discard genuinely good points as NaN.
const _ACCEPTABLE_STATUSES = (MOI.OPTIMAL, MOI.ALMOST_OPTIMAL, MOI.LOCALLY_SOLVED)

# Same regularization as ScalarDualNewton._cholesky_or_shift, applied here
# for fairness: `solve_primal_socp`'s RSOC reformulation needs a Cholesky
# factor Bⱼ = LⱼLⱼᵀ, which throws `PosDefException` on the same
# near-singular BFGS Hessian approximations that would otherwise make
# Algorithm 1's dual solve fail too -- without this, only Algorithm 1 would
# get the benefit of the fix, biasing the comparison between solvers.
# Returns the `Cholesky` factorization itself, so the caller reuses it for
# `.L` instead of factorizing twice: `cholesky` is attempted directly first
# (succeeds in the overwhelming majority of calls, at exactly the same cost
# as before this fix); only on failure does a diagonal shift kick in.
function _cholesky_or_shift(B::AbstractMatrix{T}, label::AbstractString) where {T<:AbstractFloat}
    Bs = Symmetric(Matrix(B))
    try
        return cholesky(Bs)
    catch e
        e isa PosDefException || rethrow()
    end
    @warn "solve_primal_socp: $label is not positive definite (within floating-point rounding); applying a diagonal shift"
    τ = T(1e-8)
    n = size(Bs, 1)
    for _ in 1:8
        try
            return cholesky(Symmetric(Matrix(Bs) + τ * I(n)))
        catch e
            e isa PosDefException || rethrow()
            τ *= 10
        end
    end
    return cholesky(Symmetric(Matrix(Bs) + τ * I(n)))
end

function _set_solver_tolerance!(model, optimizer, tol)
    if occursin("Clarabel", string(optimizer))
        set_optimizer_attribute(model, "tol_gap_abs", tol)
        set_optimizer_attribute(model, "tol_gap_rel", tol)
        set_optimizer_attribute(model, "tol_feas", tol)
    elseif occursin("Mosek", string(optimizer))
        set_optimizer_attribute(model, "MSK_DPAR_INTPNT_CO_TOL_REL_GAP", tol)
        set_optimizer_attribute(model, "MSK_DPAR_INTPNT_CO_TOL_PFEAS", tol)
        set_optimizer_attribute(model, "MSK_DPAR_INTPNT_CO_TOL_DFEAS", tol)
    elseif occursin("Gurobi", string(optimizer))
        set_optimizer_attribute(model, "BarQCPConvTol", tol)
        set_optimizer_attribute(model, "FeasibilityTol", tol)
        set_optimizer_attribute(model, "OptimalityTol", tol)
    end
    return nothing
end

"""
    solve_primal_socp(g1, g2, B1, B2; optimizer, silent=true, tol=sqrt(eps(T)))

Solves the primal epigraph problem (bi-objective, m=2) via the SOC
reformulation. `g1, g2, B1, B2` follow the same convention as
`DualProblem`/`solve_dual` in `ScalarDualNewton.jl`. `optimizer` must be a
JuMP optimizer constructor, e.g. `Clarabel.Optimizer`, `Mosek.Optimizer`, or
`ECOS.Optimizer`.

`tol` is the nominal accuracy requested from the solver, translated into
each solver's own native parameters (we request `sqrt(eps)` in each
solver's own term, rather than assuming exact equivalence of accuracy
across solvers). Translation is implemented for Clarabel (`tol_gap_abs`,
`tol_gap_rel`, `tol_feas`), Mosek (`MSK_DPAR_INTPNT_CO_TOL_REL_GAP`,
`MSK_DPAR_INTPNT_CO_TOL_PFEAS`, `MSK_DPAR_INTPNT_CO_TOL_DFEAS`), and Gurobi
(`BarQCPConvTol`, `FeasibilityTol`, `OptimalityTol`).

Returns a NamedTuple `(d, t, obj, solve_time, elapsed, status)`.
`solve_time` is the time reported by the solver itself (only inside
`optimize!`, useful as a diagnostic); `elapsed` is the wall-clock time of
the entire function, including the Cholesky factorization of B1, B2
(needed to build the RSOC constraint) and the JuMP model construction --
`elapsed`, not `solve_time`, should be used to compare against Algorithm
1's total time (`ScalarDualNewton.jl`): `solve_time` alone underestimates
the real cost of using this reformulation, since it ignores the Cholesky
of B1, B2 done here in Julia, outside the solver.
"""
function solve_primal_socp(g1::Vector{T}, g2::Vector{T},
                            B1::AbstractMatrix{T}, B2::AbstractMatrix{T};
                            optimizer, silent::Bool=true, tol::T=sqrt(eps(T))) where {T<:AbstractFloat}
    t0 = time()
    g = (g1, g2)
    B = (B1, B2)
    n = length(g1)

    L1 = Matrix(_cholesky_or_shift(B1, "B1").L)
    L2 = Matrix(_cholesky_or_shift(B2, "B2").L)
    L = (L1, L2)

    model = Model(optimizer)
    # Explicit both ways (not `silent && set_silent(model)`), so `silent`
    # always reflects the actual result regardless of whatever verbosity
    # default the underlying optimizer factory happens to carry -- e.g. a
    # Gurobi factory built from a shared Env with OutputFlag=0 would
    # otherwise silently stay silent even when the caller asked for
    # `silent=false`.
    silent ? set_silent(model) : unset_silent(model)
    _set_solver_tolerance!(model, optimizer, tol)

    @variable(model, t)
    @variable(model, d[1:n])
    @objective(model, Min, t)

    for j in 1:2
        @constraint(model, vcat(t - dot(g[j], d), 1, L[j]' * d) in RotatedSecondOrderCone())
    end

    optimize!(model)

    st = termination_status(model)
    # result_count(model) == 0 whenever the solver returns no retrievable
    # point at all (not even a suboptimal/infeasible one) -- e.g. Gurobi on
    # a genuinely hard instance can terminate with zero solutions found,
    # unlike Clarabel/Mosek which typically still expose their last iterate
    # even when flagged e.g. :SLOW_PROGRESS. value(t)/objective_value would
    # throw in that case, so guard them the same way d already is.
    has_result = result_count(model) >= 1
    dsol = has_result && st in _ACCEPTABLE_STATUSES ? value.(d) : fill(T(NaN), n)
    tsol = has_result ? value(t) : T(NaN)
    objsol = has_result ? objective_value(model) : T(NaN)

    return (d=dsol, t=tsol, obj=objsol,
            solve_time=solve_time(model), elapsed=time() - t0, status=st)
end

"""
    solve_primal_qcqp_raw(g1, g2, B1, B2; optimizer, silent=true, tol=sqrt(eps(T)))

Variant WITHOUT the manual SOC reformulation: passes the convex quadratic
constraints `gⱼᵀd + 1/2 dᵀBⱼd ≤ t` directly to the solver (bi-objective,
m=2, same `g1, g2, B1, B2` convention as `DualProblem`/`solve_dual` and as
`solve_primal_socp`). Useful with general QCP/NLP solvers (Gurobi, which
detects convexity via B ⪰ 0 in presolve; Ipopt) -- lets us measure the
effect of doing the SOC reformulation manually versus letting the solver
detect convexity on its own, and is the only usable form with solvers that
do not accept `RotatedSecondOrderCone` (Ipopt). `tol` uses the same
mapping as `solve_primal_socp`, so the comparison uses the same nominal
tolerance on both sides. Also returns `elapsed` (wall-clock time of the
entire function) in addition to `solve_time` -- see the note in
`solve_primal_socp`.
"""
function solve_primal_qcqp_raw(g1::Vector{T}, g2::Vector{T},
                                B1::AbstractMatrix{T}, B2::AbstractMatrix{T};
                                optimizer, silent::Bool=true, tol::T=sqrt(eps(T))) where {T<:AbstractFloat}
    t0 = time()
    g = (g1, g2)
    B = (B1, B2)
    n = length(g1)

    model = Model(optimizer)
    # Explicit both ways (not `silent && set_silent(model)`), so `silent`
    # always reflects the actual result regardless of whatever verbosity
    # default the underlying optimizer factory happens to carry -- e.g. a
    # Gurobi factory built from a shared Env with OutputFlag=0 would
    # otherwise silently stay silent even when the caller asked for
    # `silent=false`.
    silent ? set_silent(model) : unset_silent(model)
    _set_solver_tolerance!(model, optimizer, tol)

    @variable(model, t)
    @variable(model, d[1:n])
    @objective(model, Min, t)

    for j in 1:2
        Bj = Symmetric(Matrix(B[j]))
        @constraint(model, dot(g[j], d) + 0.5 * dot(d, Bj * d) <= t)
    end

    optimize!(model)

    st = termination_status(model)
    # See the comment in solve_primal_socp: some solvers can return zero
    # retrievable results at all, not just a suboptimal one.
    has_result = result_count(model) >= 1
    dsol = has_result && st in _ACCEPTABLE_STATUSES ? value.(d) : fill(T(NaN), n)
    tsol = has_result ? value(t) : T(NaN)
    objsol = has_result ? objective_value(model) : T(NaN)

    return (d=dsol, t=tsol, obj=objsol,
            solve_time=solve_time(model), elapsed=time() - t0, status=st)
end

end # module
