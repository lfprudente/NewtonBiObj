"""
    PrimalSOCP

Solves the primal epigraph problem (3) from the paper,

    min_{t,d}  t
    s.t.       gⱼᵀd + 1/2 dᵀBⱼd ≤ t,   j = 1,...,m,   Bⱼ ≻ 0,

using the exact rotated second-order cone (RSOC) reformulation:

    Bⱼ = LⱼLⱼᵀ  (Cholesky)
    gⱼᵀd + 1/2 dᵀBⱼd ≤ t  ⟺  (t - gⱼᵀd, 1, Lⱼᵀd) ∈ 𝒬_r

This is a pure SOCP (linear objective + second-order conic constraints),
the problem class that solvers such as Clarabel, Mosek, Gurobi, and ECOS
handle natively -- the strongest primal competitor to Algorithm 1.

`solve_primal_socp` and `solve_primal_qcqp_raw` are specific to the
bi-objective case (m=2), mirroring the `g1, g2, B1, B2` convention of
`DualProblem`/`solve_dual` (`ScalarDualNewton.jl`).
"""
module PrimalSOCP

using JuMP
using LinearAlgebra

export solve_primal_socp, solve_primal_qcqp_raw

# Matched by solver name, not by type, so this module has no hard
# dependency on Clarabel.jl/MosekTools.jl/Gurobi.jl -- only the calling
# script needs `using` them. MOI.LOCALLY_SOLVED (the status general
# QCP/NLP solvers report, e.g. Gurobi's raw path, Ipopt) is as good as
# MOI.OPTIMAL/ALMOST_OPTIMAL here since the problem is convex.
const _ACCEPTABLE_STATUSES = (MOI.OPTIMAL, MOI.ALMOST_OPTIMAL, MOI.LOCALLY_SOLVED)

# Same regularization as ScalarDualNewton._cholesky_or_shift, applied here
# for fairness: the RSOC reformulation needs Bⱼ = LⱼLⱼᵀ, which can fail on
# the same near-singular Hessian approximations that would make Algorithm
# 1's dual solve fail too. Returns the `Cholesky` factorization itself so
# the caller reuses it for `.L`.
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
each solver's own native parameters (Clarabel: `tol_gap_abs`,
`tol_gap_rel`, `tol_feas`; Mosek: `MSK_DPAR_INTPNT_CO_TOL_REL_GAP`,
`MSK_DPAR_INTPNT_CO_TOL_PFEAS`, `MSK_DPAR_INTPNT_CO_TOL_DFEAS`; Gurobi:
`BarQCPConvTol`, `FeasibilityTol`, `OptimalityTol`).

Returns a NamedTuple `(d, t, obj, solve_time, elapsed, status)`.
`solve_time` is the time reported by the solver itself (only inside
`optimize!`); `elapsed` is the wall-clock time of the entire function,
including the Cholesky factorization of B1, B2 and the JuMP model
construction -- `elapsed`, not `solve_time`, is the fair comparison
against Algorithm 1's total time.
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
    # A solver can terminate with zero retrievable results at all (not just
    # a suboptimal one), so guard value(t)/objective_value the same way.
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
constraints `gⱼᵀd + 1/2 dᵀBⱼd ≤ t` directly to the solver (same
`g1, g2, B1, B2` convention as `solve_primal_socp`). Useful with general
QCP/NLP solvers (Gurobi, which detects convexity via B ⪰ 0 in presolve;
Ipopt), and the only usable form with solvers that do not accept
`RotatedSecondOrderCone` (Ipopt). `tol` uses the same mapping as
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
    has_result = result_count(model) >= 1
    dsol = has_result && st in _ACCEPTABLE_STATUSES ? value.(d) : fill(T(NaN), n)
    tsol = has_result ? value(t) : T(NaN)
    objsol = has_result ? objective_value(model) : T(NaN)

    return (d=dsol, t=tsol, obj=objsol,
            solve_time=solve_time(model), elapsed=time() - t0, status=st)
end

end # module
