#!/usr/bin/env julia
#
# Robustness regression tests for ScalarDualNewton.jl. Complements
# test_scalar_dual.jl (which checks the closed-form math) with checks that
# solve_dual actually converges reliably:
#
#   - Test 1: a large random battery, checking that the Armijo stall
#     safeguard prevents backtracking from freezing near lambda* until
#     `maxit`.
#   - Test 2: Step 0 boundary handling on near-degenerate instances
#     (B1≈B2, g1≈g2), which stress the degenerate case of Proposition
#     "degenerate-case" in the paper.
#
#   julia test_robustness.jl

using LinearAlgebra
using Random
using Statistics
using Printf

using NewtonBiObj
using .ScalarDualNewton
using .SyntheticProblems

function random_spd(n::Int, κ::Float64, rng)
    A = randn(rng, n, n)
    Q, _ = qr(A)
    Q = Matrix(Q)
    λs = exp.(range(0.0, log(κ), length=n))
    return Q * Diagonal(λs) * Q'
end

"""
    test_random_battery(; N, seed) -> Bool

Solves N random instances spanning n in [2,100] and condition number kappa
in [1, 1e6], and checks that none of them hit `:maxit`. This is the
regression test for the Armijo-stall bug described above.
"""
function test_random_battery(; N::Int=20_000, seed::Int=42, verbose::Bool=true)
    rng = MersenneTwister(seed)
    iters = Int[]
    ncalls = Int[]
    failures = Tuple{Int,Int,Float64}[]
    for trial in 1:N
        n = rand(rng, 2:100)
        κ = 10.0 ^ rand(rng, 0:6)
        g1 = randn(rng, n); g2 = randn(rng, n)
        B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        push!(iters, res.iterations)
        push!(ncalls, res.n_phi_calls)
        res.status == :maxit && push!(failures, (trial, n, κ))
    end
    if verbose
        @printf("  instances=%d  iterations: mean=%.3f median=%.1f max=%d\n",
                N, mean(iters), median(iters), maximum(iters))
        @printf("  phi_all calls: mean=%.3f max=%d\n", mean(ncalls), maximum(ncalls))
        println("  failures (:maxit): ", length(failures), " / ", N)
        for (trial, n, κ) in first(failures, min(5, length(failures)))
            println("    trial=$trial n=$n κ=$κ")
        end
    end
    return isempty(failures)
end

"""
    test_near_degenerate(; n, seed) -> Bool

Near-degenerate instances (B1≈B2, g1≈g2, `near_degenerate_instance` in
SyntheticProblems.jl) should always be resolved at Step 0 (status
endpoint0/endpoint1, zero Newton iterations) with a tiny KKT residual, per
Proposition "degenerate-case".
"""
function test_near_degenerate(; n::Int=20, seed::Int=2, verbose::Bool=true)
    rng = MersenneTwister(seed)
    ok = true
    for τ in (1e-3, 1e-6, 1e-9, 1e-12, 0.0)
        inst = near_degenerate_instance(n; τ=τ, rng=rng)
        P = DualProblem(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2))
        res = solve_dual(P)
        _, ϕp, _, _ = ScalarDualNewton.phi_all(P, res.λ)
        r = ScalarDualNewton.rho(res.λ, ϕp)
        good = res.iterations == 0 && r <= 1e-6
        ok &= good
        if verbose
            println("  τ=$τ  status=$(res.status)  it=$(res.iterations)  ",
                    "ρ(λ*)=$r  ", good ? "OK" : "FAILED")
        end
    end
    return ok
end

function main()
    println("Running robustness regression tests for ScalarDualNewton...")
    println()
    println("Test 1: large-scale random battery (regression for the Armijo-stall bug)")
    ok1 = test_random_battery()
    println()
    println("Test 2: near-degenerate stress test")
    ok2 = test_near_degenerate()
    println()

    if ok1 && ok2
        println("All robustness tests passed.")
    else
        println("SOME TESTS FAILED.")
        exit(1)
    end
end

# Runs automatically when executed as `julia test_robustness.jl` from the
# shell, but not when `include`/`includet` from an interactive REPL session
# -- there, call main() explicitly.
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
