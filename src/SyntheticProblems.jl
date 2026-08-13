"""
    SyntheticProblems

Generates dense synthetic instances (g1, g2, B1, B2) for scalability tests
in n and for robustness tests near the degenerate case (Proposition 3.3 of
the paper).
"""
module SyntheticProblems

using Random
using LinearAlgebra

export random_spd, random_instance, near_degenerate_instance, degenerate_limit_instance

"""
    random_spd(n, κ; rng) -> Symmetric n×n SPD matrix with condition number ≈ κ

Builds B = Q diag(log-spaced eigenvalues in [1, κ]) Qᵀ, with Q a random
orthogonal matrix (via QR of a Gaussian matrix). Allows explicit control of
conditioning, relevant because both the primal (SOCP's KKT system) and the
dual (Cholesky of B(λ)) depend on the numerical quality of B.
"""
function random_spd(n::Int, κ::Float64; rng::AbstractRNG=Random.default_rng())
    A = randn(rng, n, n)
    Q, _ = qr(A)
    Q = Matrix(Q)
    λs = exp.(range(0.0, log(κ), length=n))   # log-spaced in [1, κ]
    return Symmetric(Q * Diagonal(λs) * Q')
end

"""
    random_instance(n; κ=1e2, gnorm=1.0, rng) -> (g1, g2, B1, B2)

Generic dense synthetic instance: g1, g2 normalized Gaussian vectors, B1,
B2 independent SPD matrices with condition number κ.
"""
function random_instance(n::Int; κ::Float64=1e2, gnorm::Float64=1.0,
                          rng::AbstractRNG=Random.default_rng())
    g1 = randn(rng, n); g1 .*= gnorm / norm(g1)
    g2 = randn(rng, n); g2 .*= gnorm / norm(g2)
    B1 = random_spd(n, κ; rng=rng)
    B2 = random_spd(n, κ; rng=rng)
    return (g1=g1, g2=g2, B1=B1, B2=B2)
end

"""
    near_degenerate_instance(n; τ=1e-6, κ=1e2, rng) -> (g1, g2, B1, B2)

"Near-degenerate" instance: B2 = B1 + τ·ΔB and g2 = g1 + τ·Δg, with ΔB, Δg
of O(1) norm. This pushes ϕ''(λ) close to zero on all of [0,1] (see
Proposition 3.3), testing the robustness of the preliminary tests (Step 0)
and of Algorithm 1's stopping criterion near the boundary of the
degenerate case.
"""
function near_degenerate_instance(n::Int; τ::Float64=1e-6, κ::Float64=1e2,
                                   rng::AbstractRNG=Random.default_rng())
    g1 = randn(rng, n); g1 ./= norm(g1)
    B1 = random_spd(n, κ; rng=rng)

    Δg = randn(rng, n); Δg ./= norm(Δg)
    E  = randn(rng, n, n); ΔB = E + E'
    ΔB ./= norm(ΔB)
    ΔB = Symmetric(ΔB)

    g2 = g1 .+ τ .* Δg
    B2 = Symmetric(Matrix(B1) .+ τ .* Matrix(ΔB))

    return (g1=g1, g2=g2, B1=B1, B2=B2)
end

"""
    degenerate_limit_instance(n; τ=1e-6, κ=1e2, rng) -> (g1, g2, B1, B2)

Instance approaching the general degeneracy condition of Proposition 3.3
(item iii): there exists d such that g1+B1d=0 and g2+B2d=0. Unlike
`near_degenerate_instance` (which fixes B2≈B1, g2≈g1, a particular case),
here B1 and B2 are independent SPD matrices (same condition number κ, but
not close to each other), and a reference vector d is chosen along with
unit-norm perturbations r1, r2:

    g1 = -B1*d + τ*r1,   g2 = -B2*d + τ*r2.

At τ=0 the degeneracy condition holds exactly, for any B1, B2 (not only
B1=B2); τ→0 drives the instance towards that condition generically.
"""
function degenerate_limit_instance(n::Int; τ::Float64=1e-6, κ::Float64=1e2,
                                    rng::AbstractRNG=Random.default_rng())
    B1 = random_spd(n, κ; rng=rng)
    B2 = random_spd(n, κ; rng=rng)
    d  = randn(rng, n); d ./= norm(d)

    r1 = randn(rng, n); r1 ./= norm(r1)
    r2 = randn(rng, n); r2 ./= norm(r2)

    g1 = -B1 * d .+ τ .* r1
    g2 = -B2 * d .+ τ .* r2

    return (g1=g1, g2=g2, B1=B1, B2=B2)
end

end # module
