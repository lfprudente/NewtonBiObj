"""
    ScalarDualNewton

Implements Algorithm 1 ("Newton method with Armijo backtracking for the
bi-objective dual problem") from the paper

    "Efficient solution of the bi-objective Newton-type subproblem via a
    scalar dual formulation"
    Goncalves, Prudente, Schuverdt, Sobral.

The module solves

    min_{lambda in [0,1]} phi(lambda),

where

    g(lambda)  = (1 - lambda) g1 + lambda g2,
    B(lambda)  = (1 - lambda) B1 + lambda B2,     B1, B2 symmetric positive definite,
    d(lambda)  = -B(lambda)^{-1} g(lambda),
    phi(lambda) = -1/2 <g(lambda), d(lambda)>.

Equation numbers and proposition/algorithm labels in the comments below
refer to the corresponding items in the paper (as of the current draft),
so that this file can be cross-checked against the manuscript directly.
"""
module ScalarDualNewton

using LinearAlgebra
using Printf

export DualProblem, phi_all, rho, solve_dual, DualResult

# =============================================================================
# Problem data
# =============================================================================

"""
    DualProblem(g1, g2, B1, B2)

Stores the data (g1, g2, B1, B2) defining the scalar dual function phi.
B1 and B2 are assumed symmetric positive definite (not checked here; the
caller is responsible for supplying valid Newton-type or quasi-Newton
Hessian approximations, regularized if necessary).
"""
struct DualProblem{T<:AbstractFloat}
    g1::Vector{T}
    g2::Vector{T}
    B1::Symmetric{T,Matrix{T}}
    B2::Symmetric{T,Matrix{T}}
    Δg::Vector{T}   # g2 - g1
    ΔB::Matrix{T}   # B2 - B1
end

function DualProblem(g1::AbstractVector{T}, g2::AbstractVector{T},
                      B1::AbstractMatrix{T}, B2::AbstractMatrix{T}) where {T<:AbstractFloat}
    B1s = Symmetric(Matrix(B1))
    B2s = Symmetric(Matrix(B2))
    return DualProblem{T}(Vector(g1), Vector(g2), B1s, B2s,
                           Vector(g2) .- Vector(g1), Matrix(B2s) .- Matrix(B1s))
end

@inline gvec(P::DualProblem, λ) = (1 - λ) .* P.g1 .+ λ .* P.g2
@inline Bmat(P::DualProblem, λ) = Symmetric((1 - λ) .* Matrix(P.B1) .+ λ .* Matrix(P.B2))

# DualProblem's docstring documents B1, B2 as "assumed symmetric positive
# definite (not checked here; the caller is responsible for supplying valid
# ... Hessian approximations, regularized if necessary)" -- this is where
# that regularization actually happens, so every caller of `solve_dual`
# gets it automatically rather than needing its own workaround. BFGS-type
# Hessian approximations are SPD by construction along their standard-
# update branch, but the fallback formula used for non-strongly-convex
# objectives can occasionally drift to a near-singular or indefinite
# matrix (eigenvalues on the order of -1e-14, i.e. indefinite only by
# floating-point rounding); without this, `cholesky` throws
# `PosDefException` and the whole solve fails, even when `theta` is
# already close to optimal.
#
# Returns `(C, Bused)`: the `Cholesky` factorization itself (not just a
# corrected matrix, so the caller can reuse it directly instead of
# factorizing twice) and the matrix it actually factorized. `Bused === B`
# (checkable by the caller with `===`) whenever no shift was needed, so
# `solve_dual` can tell whether it must rebuild `DualProblem` with the
# corrected matrix for consistency in later iterations, without doing so
# needlessly in the common case. `cholesky` is attempted directly first
# (succeeds in the overwhelming majority of calls, at exactly the same
# cost as before this fix); only on failure does a Levenberg-Marquardt-
# style diagonal shift kick in, growing geometrically until the
# factorization succeeds, with a warning printed so silent numerical drift
# doesn't go unnoticed.
function _cholesky_or_shift(B::Symmetric{T,Matrix{T}}, label::AbstractString) where {T<:AbstractFloat}
    try
        return cholesky(B), B
    catch e
        e isa PosDefException || rethrow()
    end
    @warn "solve_dual: $label is not positive definite (within floating-point rounding); applying a diagonal shift"
    τ = T(1e-8)
    n = size(B, 1)
    for _ in 1:8
        Bshifted = Symmetric(Matrix(B) + τ * I(n))
        try
            return cholesky(Bshifted), Bshifted
        catch e
            e isa PosDefException || rethrow()
            τ *= 10
        end
    end
    Bshifted = Symmetric(Matrix(B) + τ * I(n))
    return cholesky(Bshifted), Bshifted
end

# =============================================================================
# Evaluation of phi, phi', phi'' (Proposition on phi-properties, eqs.
# phi-compact / phi-prime-general-prop / phi-second-general-prop)
# =============================================================================

"""
    phi_all(P, λ) -> (ϕ, ϕ', ϕ'', d)
    phi_all(P, λ, C) -> (ϕ, ϕ', ϕ'', d)

Evaluates phi(lambda), phi'(lambda), phi''(lambda) and d(lambda) at a given
lambda in [0,1], reusing a single Cholesky factorization of B(lambda) (the
dominant O(n^3) cost, as discussed in "Cost of evaluating the scalar dual
function and its derivatives"). The three-argument form accepts an
already-computed factorization `C` of `B(λ)` (e.g. from
`_cholesky_or_shift`, at the λ=0/λ=1 endpoints in `solve_dual`) instead of
recomputing it.
"""
function phi_all(P::DualProblem{T}, λ::T) where {T<:AbstractFloat}
    return phi_all(P, λ, cholesky(Bmat(P, λ)))
end

function phi_all(P::DualProblem{T}, λ::T, C) where {T<:AbstractFloat}
    g  = gvec(P, λ)
    d  = -(C \ g)                  # O(n^2): d(lambda)

    ϕ  = -T(0.5) * dot(g, d)       # phi(lambda), eq. (phi-compact)

    ΔBd = P.ΔB * d                                    # O(n^2), reused below
    ϕp  = -dot(P.Δg, d) - T(0.5) * dot(ΔBd, d)         # phi'(lambda)

    v   = P.Δg .+ ΔBd
    ϕpp = dot(v, C \ v)            # phi''(lambda), one extra triangular solve

    return ϕ, ϕp, ϕpp, d
end

# =============================================================================
# KKT residual / duality gap rho(lambda)
# (Proposition on phi-prime-kkt, eq. comp-residual-formula)
# =============================================================================

"""
    rho(λ, ϕp)

Closed-form KKT residual (equivalently, duality gap) of the primal problem
associated with a given lambda, computed from phi'(lambda) at no extra
cost:

    rho(lambda) = lambda * max(phi'(lambda), 0) + (1 - lambda) * max(-phi'(lambda), 0).

By the corresponding proposition in the paper, stationarity and primal/dual
feasibility of the KKT system hold exactly for every lambda in [0,1], so
rho(lambda) is precisely the full KKT residual (the only nonzero block is
complementary slackness).
"""
@inline rho(λ::T, ϕp::T) where {T<:AbstractFloat} = λ * max(ϕp, zero(T)) + (1 - λ) * max(-ϕp, zero(T))

# =============================================================================
# Result type
# =============================================================================

struct DualResult{T<:AbstractFloat}
    λ::T
    d::Vector{T}             # = d_N, the recovered Newton-type direction
    ϕ::T
    iterations::Int
    status::Symbol           # :endpoint0, :endpoint1, :degenerate, :converged, :maxit
    n_phi_calls::Int         # number of phi_all calls, i.e. of O(n^3/3) Cholesky
                              # factorizations of B(lambda); the dominant cost metric
                              # discussed in "Cost of evaluating the scalar dual
                              # function and its derivatives"
    elapsed::Float64         # wall-clock time spent inside solve_dual, in seconds
end

# =============================================================================
# Cubic interpolation minimizer on [0,1], used to pick the initial point
# lambda^0 in solve_dual from phi(0), phi(1), phi'(0), phi'(1).
# Standard closed-form cubic Hermite interpolation minimizer (see, e.g.,
# Nocedal & Wright, "Numerical Optimization", Section 3.5).
# =============================================================================
function cubic_minimizer01(f0::T, f1::T, g0::T, g1::T) where {T<:AbstractFloat}
    d1 = g0 + g1 + 3 * (f0 - f1)
    disc = max(d1^2 - g0 * g1, zero(T))
    d2 = sqrt(disc)
    denom = g1 - g0 + 2 * d2
    if abs(denom) < eps(T)
        return T(0.5)
    end
    λ = 1 - (g1 + d2 - d1) / denom
    return clamp(λ, zero(T), one(T))
end

# =============================================================================
# Algorithm 1: Newton method with Armijo backtracking for the bi-objective
# dual problem
# =============================================================================

"""
    solve_dual(P::DualProblem; δ=1e-4, ω1=0.1, ω2=0.9, maxit=100, tol=sqrt(eps(T)), scale=true, verbose=false)

Runs Algorithm 1 (safeguarded Newton method with Armijo backtracking) to
minimize phi on [0,1]. Returns a `DualResult` with lambda*, the recovered
direction d(lambda*) = d_N, phi(lambda*), the iteration count, the stopping
status, the number of `phi_all` calls, and the elapsed time.

`δ, ω1, ω2` are the Armijo and backtracking-safeguard parameters, `maxit`
the iteration cap.

If `scale=true` (default), the data is divided by
`sigma = max(1, |phi(lambda^0)|, |phi'(lambda^0)|)` before the main loop
(and `phi` multiplied back by `sigma` at the end), to avoid floating-point
cancellation in the Armijo test on badly scaled instances; `lambda*`, `d`,
and the iteration trajectory are unaffected, since `phi`, `phi'`, `phi''`
scale linearly and `d` is scale-invariant. Set `scale=false` to run the
literal unscaled formula instead.

With `scale=true` (the paper's default setting), iterations stop once
`rho(lambda^k) <= tol`, with `tol` defaulting to `sqrt(eps(T))`. With
`scale=false`, the criterion is instead
`rho(lambda^k) <= tol*max(1,|phi'(lambda^0)|)`, matching the un-rescaled
formula.

If `verbose=true`, prints one line per iteration (`λ`, `ρ`, `ϕ`, backtracking
step size and outcome) plus a short summary at the end.
"""
function solve_dual(P::DualProblem{T};
                     δ::T=T(1e-4), ω1::T=T(0.1), ω2::T=T(0.9),
                     maxit::Int=100, tol::T=sqrt(eps(T)),
                     scale::Bool=true, verbose::Bool=false) where {T<:AbstractFloat}

    # Start timing
    t0 = time()

    # Print header
    if verbose
        @printf("%s\n", "="^78)
        @printf("   Algorithm 1: Safeguarded Newton method for the bi-objective dual problem\n")
        @printf("%s\n", "="^78)
        @printf("  Number of primal variables : %d\n", length(P.g1))
        @printf("  Optimality tolerance       : %7.1E\n", tol)
    end

    # Counter
    it   = 0
    nphi = 0

    # ---- Preliminary tests ----------------------------------------
    # Practical relaxation of the exact tests phi'(0)>=0 / phi'(1)<=0:
    # tested via rho (same KKT-residual metric as the main stopping test).
    #
    # B1 (resp. B2) is factorized explicitly here -- regularized on the
    # spot if `cholesky` fails, see `_cholesky_or_shift` -- and that same
    # factorization is reused for phi(0)/rho(0) (resp. phi(1)/rho(1))
    # below, rather than factorizing B(0)=B1/B(1)=B2 a second time inside
    # `phi_all`. Whenever a shift is applied, `P` is rebuilt with the
    # corrected matrix *before* being used any further, so `Δg`/`ΔB` (and
    # hence every later `phi_all(P,λ)` call in the main loop below, for
    # λ strictly between 0 and 1) stay consistent with the same corrected
    # B1/B2 -- not just the two endpoint evaluations here.

    # Test for λ = 0
    C1, B1fixed = _cholesky_or_shift(P.B1, "B1")
    B1fixed === P.B1 || (P = DualProblem(P.g1, P.g2, B1fixed, P.B2))
    ϕ0, ϕp0, ϕpp0, d0 = phi_all(P, zero(T), C1); nphi += 1
    if rho(zero(T), ϕp0) <= tol
        verbose && @printf("\nPreliminary test: rho(0,ϕp0)= %12.4e <= tol\n\n", rho(zero(T), ϕp0))
        return DualResult(zero(T), d0, ϕ0, it, :endpoint0, nphi, time() - t0)
    end

    # Test for λ = 1
    C2, B2fixed = _cholesky_or_shift(P.B2, "B2")
    B2fixed === P.B2 || (P = DualProblem(P.g1, P.g2, P.B1, B2fixed))
    ϕ1, ϕp1, ϕpp1, d1 = phi_all(P, one(T), C2); nphi += 1
    if rho(one(T), ϕp1) <= tol
        verbose && @printf("\nPreliminary test: rho(1,ϕp1)=%12.4e <= tol\n\n", rho(one(T), ϕp1))
        return DualResult(one(T), d1, ϕ1, it, :endpoint1, nphi, time() - t0)
    end

    # No explicit check for the degenerate case (phi affine on [0,1], i.e.
    # phi''(0)==0) is needed here: whenever phi is affine, phi' is constant
    # (call it m), and rho reduces to max(-m,0) at lambda=0 and max(m,0) at
    # lambda=1 -- one of which is always exactly 0, regardless of m's sign
    # or magnitude. So one of the two preliminary tests above always
    # triggers first, with exact equality.

    # ---- Initialization: cubic interpolant of phi(0), phi(1), phi'(0), phi'(1) --
    λ0 = cubic_minimizer01(ϕ0, ϕ1, ϕp0, ϕp1)

    λ = λ0
    if λ == zero(T)
        ϕ, ϕp, ϕpp, d = ϕ0, ϕp0, ϕpp0, d0
    elseif λ == one(T)
        ϕ, ϕp, ϕpp, d = ϕ1, ϕp1, ϕpp1, d1
    else
        ϕ, ϕp, ϕpp, d = phi_all(P, λ); nphi += 1
    end

    # Internal rescaling for numerical robustness.
    if scale
        c_data = max(one(T), abs(ϕ), abs(ϕp))
        if c_data == one(T)
            Pw = P
        else
            Pw = DualProblem(P.g1 ./ c_data, P.g2 ./ c_data, Matrix(P.B1) ./ c_data, Matrix(P.B2) ./ c_data)
            ϕ, ϕp, ϕpp = ϕ / c_data, ϕp / c_data, ϕpp / c_data
        end
        verbose && @printf("  Objective scale factor     : %7.1E\n", one(T)/c_data)
    else
        c_data = one(T)
        Pw = P
    end

    # Stopping/stall tolerances for the main loop.
    if scale
        tol_use     = tol
        tol_relaxed = tol^(T(3) / T(4))
    else
        tol_use     = tol * max(one(T), abs(ϕp))
        tol_relaxed = tol^(T(3) / T(4)) * max(one(T), abs(ϕp))
        verbose && @printf("  Scaled Optimality tolerance: %7.1E\n", tol_use)
    end

    # Initialize variables
    status = Symbol()
    flagLS = Symbol()
    λ_prev = λ
    α      = zero(T)

    # ============================================================
    # Main loop
    # ============================================================

    while true

        # Print information
        if verbose
            if it % 10 == 0
                @printf("\n%4s  %14s  %12s  %14s  %5s  %10s  %s\n",
                "k", "λ", "ρ(λ,ϕ')", "ϕ (local)", "nphi", "α", "flag")
            end
            if it == 0
                @printf("%4d  %14.10f  %12.4e  %14.6e  %5d  %10s  %s\n",
                it, λ, rho(λ, ϕp), ϕ, nphi, "-", "-")
            else
                @printf("%4d  %14.10f  %12.4e  %14.6e  %5d  %10.4e  %s\n",
                    it, λ, rho(λ, ϕp), ϕ, nphi, α, flagLS)
            end
        end

        # ============================================================
        # Stopping criteria
        # ============================================================

        # Test optimality condition: rho(λ) <= tol_use
        # Practical relaxation stated in terms of the KKT residual.
        if rho(λ, ϕp) <= tol_use
            status = :converged
            break
        end

        # Stall safeguard: if abs(λ - λ_prev) <= tol and rho(λ) <= tol_relaxed,
        # we also accept the current iterate as the solution.
        if it > 0 && abs(λ - λ_prev) <= tol && rho(λ, ϕp) <= tol_relaxed
            status = :converged
            break
        end

        # Test whether the number of iterations is exhausted
        if it >= maxit
            status = :maxit
            break
        end

        # ========================================================
        # Start of a new outer iteration
        # ========================================================

        it += 1
        λ_prev = λ

        # Compute the Newton direction
        dNewton = -ϕp / ϕpp

        # ========================================================
        # Line search: Armijo backtracking with quadratic interpolation
        # ========================================================

        # Compute the maximum allowed stepsize
        if dNewton > 0
            αmax = (one(T) - λ) / dNewton
        elseif dNewton < 0
            αmax = -λ / dNewton
        else
            αmax = zero(T)
        end
        αtrial = min(one(T), αmax)

        dϕ = ϕp * dNewton   # phi'(lambda^k) d^k, the Armijo directional derivative
        local ϕtrial, ϕptrial, ϕpptrial, dtrial
        α = αtrial
        nback = 0
        
        # Backtracking
        while true
            λtrial = clamp(λ + α * dNewton, zero(T), one(T))
            ϕtrial, ϕptrial, ϕpptrial, dtrial = phi_all(Pw, λtrial); nphi += 1

            if ϕtrial <= ϕ + δ * α * dϕ
                flagLS = :armijo
                break
            end

            # Step too small to change lambda^k in floating point: stop
            # backtracking here and let the outer loop's stall safeguard
            # (above) decide whether the resulting iterate is acceptable.
            if abs(α * dNewton) <= eps(T) * max(one(T), abs(λ))
                flagLS = :step_too_small
                break
            end

            nback += 1
            if nback >= 60   # safeguard against infinite loops from roundoff
                flagLS = :maxback
                break
            end

            # Quadratic interpolation
            denom = 2 * (ϕtrial - ϕ - dϕ * α)
            αq = abs(denom) < eps(T) ? α / 2 : -dϕ * α^2 / denom
            α = (ω1 * α <= αq <= ω2 * α) ? αq : α / 2
        end

        # Update the iterate
        λ = clamp(λ + α * dNewton, zero(T), one(T))
        ϕ, ϕp, ϕpp, d = ϕtrial, ϕptrial, ϕpptrial, dtrial
    end

    # ============================================================
    # End of iteration
    # ============================================================

    # Stop timing
    time_spent = time() - t0

    # Print summary
    if verbose
        if status == :converged
            @printf("\n  Solution was found.")
        elseif status == :maxit
            @printf("\n  Maximum of iterations reached.")
        end
        @printf("\n  Number of functions evaluations: %d", nphi)
        @printf("\n  Total CPU time in seconds      : %.2f\n\n", time_spent)
    end

    # Translate the objective value back to the original problem's units
    # (lambda and d are scale-invariant and need no translation).
    return DualResult(λ, d, ϕ * c_data, it, status, nphi, time_spent)
end

end # module
