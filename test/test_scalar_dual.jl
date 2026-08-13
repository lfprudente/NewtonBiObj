#!/usr/bin/env julia
#
# Quick numerical sanity checks for ScalarDualNewton.jl.
#
#   julia test_scalar_dual.jl

using LinearAlgebra
using Random

using NewtonBiObj
using .ScalarDualNewton

function random_spd(n::Int, κ::Float64, rng)
    A = randn(rng, n, n)
    Q, _ = qr(A)
    Q = Matrix(Q)
    λs = exp.(range(0.0, log(κ), length=n))
    return Symmetric(Q * Diagonal(λs) * Q')
end

# c_j(lambda) as in the paper, used to cross-check the closed-form formulas.
function c_j(g, B, d)
    return dot(g, d) + 0.5 * dot(d, B * d)
end

function check_instance(n::Int, κ::Float64, rng; verbose::Bool=true)
    g1 = randn(rng, n)
    g2 = randn(rng, n)
    B1 = Matrix(random_spd(n, κ, rng))
    B2 = Matrix(random_spd(n, κ, rng))

    P = DualProblem(g1, g2, B1, B2)

    # --- Check 1: phi'(lambda) = c1(lambda) - c2(lambda) for a few lambdas
    max_err_cdiff = 0.0
    for λ in (0.0, 0.1, 0.37, 0.5, 0.83, 1.0)
        ϕ, ϕp, ϕpp, d = ScalarDualNewton.phi_all(P, λ)
        c1 = c_j(g1, B1, d)
        c2 = c_j(g2, B2, d)
        max_err_cdiff = max(max_err_cdiff, abs(ϕp - (c1 - c2)))
    end

    # --- Check 2: rho(lambda) matches the direct KKT-gap definition
    max_err_rho = 0.0
    for λ in (0.0, 0.1, 0.37, 0.5, 0.83, 1.0)
        ϕ, ϕp, ϕpp, d = ScalarDualNewton.phi_all(P, λ)
        c1 = c_j(g1, B1, d)
        c2 = c_j(g2, B2, d)
        t = max(c1, c2)
        rho_direct = (1 - λ) * (t - c1) + λ * (t - c2)
        rho_formula = ScalarDualNewton.rho(λ, ϕp)
        max_err_rho = max(max_err_rho, abs(rho_direct - rho_formula))
    end

    # --- Check 3: full run of Algorithm 1, verify optimality
    res = solve_dual(P,verbose=true)
    ϕstar, ϕpstar, ϕppstar, dstar = ScalarDualNewton.phi_all(P, res.λ)
    rho_star = ScalarDualNewton.rho(res.λ, ϕpstar)

    # if verbose
    #     println("n=$n, κ=$κ  |  status=$(res.status)  it=$(res.iterations)  ",
    #             "λ*=$(round(res.λ, digits=6))  ",
    #             "max|φ'-(c1-c2)|=$(max_err_cdiff)  ",
    #             "max|ρ_direct-ρ_formula|=$(max_err_rho)  ",
    #             "ρ(λ*)=$(rho_star)")
    # end

    return max_err_cdiff, max_err_rho, rho_star
end

function main()

    rng = MersenneTwister(1)
    println("Running sanity checks for ScalarDualNewton...")
    worst_cdiff = 0.0
    worst_rho_formula = 0.0
    worst_rho_star = 0.0
    for n in (5, 20, 100), κ in (1.0, 1e2, 1e6)
        e1, e2, e3 = check_instance(n, κ, rng)
        worst_cdiff = max(worst_cdiff, e1)
        worst_rho_formula = max(worst_rho_formula, e2)
        worst_rho_star = max(worst_rho_star, e3)
    end

    println()
    println("Worst-case |φ'(λ) - (c1(λ)-c2(λ))| over all instances/λ: ", worst_cdiff)
    println("Worst-case |ρ_direct - ρ_formula|                      : ", worst_rho_formula)
    println("Worst-case ρ(λ*) at convergence                        : ", worst_rho_star)
    println()
    println("Expected: all three quantities close to machine precision ",
            "(~1e-12 or smaller). Large values indicate a bug.")
end

# Runs automatically when executed as `julia test_scalar_dual.jl` from the
# shell, but not when `include`/`includet` from an interactive REPL session
# -- there, call main() explicitly (and again after editing ScalarDualNewton.jl,
# with Revise active, to see only the changed methods get recompiled).
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
