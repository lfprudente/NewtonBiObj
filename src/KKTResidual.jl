"""
    KKTResidual

NOTE: must be `include`d from within the `NewtonBiObj` umbrella module,
after `ScalarDualNewton` -- it refers to that sibling submodule via
`..ScalarDualNewton` rather than including its own copy, and is not usable
via a bare top-level `include("KKTResidual.jl")`.

Solver-agnostic KKT residual for the primal epigraphic subproblem

    min_{t,d}  t
    s.t.       g_j^T d + 1/2 d^T B_j d <= t,   j=1,2,

computed from a candidate `d` alone (plus the solver's own reported `t`),
without relying on any solver-internal dual value or scaling convention.
Applicable identically to the output of Clarabel, Mosek, Gurobi, or any
other solver returning an approximate `(t, d)`.

Given `d`, the KKT stationarity condition `(1-lambda)(g1+B1 d) + lambda(g2+B2 d) = 0`
generally has no exact solution in `lambda` (it is n equations in one
unknown), so `lambda_fit` is chosen as the least-squares minimizer of the
stationarity residual -- a closed-form 1D projection. This coincides with
the exact `lambda^*` whenever `d = d(lambda^*)` (the residual is then
exactly zero), so it is a direct generalization of the machinery in
`ScalarDualNewton.jl`'s Proposition `phi-prime-kkt`.

Three residual components are reported, covering the four KKT blocks (dual
feasibility is automatic, since `lambda_fit` is clamped to [0,1]):

  - `r_feas`: primal feasibility of the solver's own `(t, d)` against the
    *original* (non-reformulated) quadratic constraints.
  - `r_stat`: stationarity residual at `lambda_fit`.
  - `r_comp`: complementary slackness / duality gap at `lambda_fit`, reusing
    `ScalarDualNewton.rho`.
"""
module KKTResidual

using LinearAlgebra
using ..ScalarDualNewton: rho   # sibling submodule, already included by the parent (NewtonBiObj)

export kkt_residual

"""
    kkt_residual(g1, g2, B1, B2, d, t_solver) -> NamedTuple

Returns `(r_feas, r_stat, r_comp, total, λ_fit)`, where `total =
max(r_feas, r_stat, r_comp)` is the overall KKT residual.
"""
function kkt_residual(g1::AbstractVector{T}, g2::AbstractVector{T},
                       B1::AbstractMatrix{T}, B2::AbstractMatrix{T},
                       d::AbstractVector{T}, t_solver::T) where {T<:AbstractFloat}
    r1 = g1 .+ B1 * d
    r2 = g2 .+ B2 * d
    v = r2 .- r1
    vv = dot(v, v)

    # Degenerate case (v ~ 0, analogous to phi''~0 in ScalarDualNewton.jl):
    # the stationarity residual is nearly independent of lambda, so any
    # lambda in [0,1] is an equally good fit; 0.5 is an arbitrary but
    # harmless choice.
    λ_fit = vv < eps(T) ? T(0.5) : clamp(-dot(r1, v) / vv, zero(T), one(T))

    # Inf-norm, not 2-norm: r_feas and r_comp are scalars (dimension-
    # independent), but this is a residual over an n-dimensional vector
    # equation. Using the 2-norm would make it grow with n (empirically,
    # roughly like sqrt(n) at fixed per-component accuracy) even for an
    # exact solution, unfairly dominating `total` for large n and making
    # comparisons across different n misleading.
    r_stat = norm((1 - λ_fit) .* r1 .+ λ_fit .* r2, Inf)

    c1 = dot(g1, d) + T(0.5) * dot(d, B1 * d)
    c2 = dot(g2, d) + T(0.5) * dot(d, B2 * d)
    t = max(c1, c2)

    r_comp = rho(λ_fit, c1 - c2)
    r_feas = max(zero(T), t - t_solver)

    return (r_feas=r_feas, r_stat=r_stat, r_comp=r_comp,
            total=max(r_feas, r_stat, r_comp), λ_fit=λ_fit)
end

end # module
