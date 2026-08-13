#!/usr/bin/env julia
#
# Regression / validation tests for KKTResidual.jl, consolidating the ad hoc
# verification done while designing the solver-agnostic KKT residual used to
# compare Algorithm 1 against primal SOCP/QCQP competitors
# (Clarabel/Mosek/Gurobi/Ipopt) under a common accuracy standard.
#
#   julia test_kkt_residual.jl

using LinearAlgebra
using Random
using Printf
using JuMP
using Clarabel

using NewtonBiObj
using .ScalarDualNewton
using .KKTResidual
using .PrimalSOCP
using .SyntheticProblems

# Mosek and Gurobi require a license; optional, so the rest of the suite
# still runs on machines without one.
const HAS_MOSEK = try
    @eval using MosekTools
    true
catch
    false
end

const HAS_GUROBI = try
    @eval using Gurobi
    true
catch
    false
end

# Ipopt is open-source (no license), but detected the same way for
# consistency and graceful degradation if not installed.
const HAS_IPOPT = try
    @eval using Ipopt
    true
catch
    false
end

# Gurobi prints its WLS license banner on every new Environment (every
# `Model(Gurobi.Optimizer)` call, not just once per process); a shared Env
# with OutputFlag=0 suppresses it. The wrapper function is named with a
# "Gurobi" prefix so PrimalSOCP.jl's name-based tolerance-mapping
# (`occursin("Gurobi", string(optimizer))`) still matches it -- a bare
# anonymous closure would not.
if HAS_GUROBI
    const GRB_ENV = Gurobi.Env(Dict{String,Any}("OutputFlag" => 0))
    GurobiSilent() = Gurobi.Optimizer(GRB_ENV)
end

function random_spd(n::Int, κ::Float64, rng)
    A = randn(rng, n, n)
    Q, _ = qr(A)
    Q = Matrix(Q)
    λs = exp.(range(0.0, log(κ), length=n))
    return Q * Diagonal(λs) * Q'
end

"""
    test_exact_point(; verbose) -> Bool

At the exact solution (d*, t*=phi(lambda*)) from ScalarDualNewton.jl, the
KKT residual must be at (near) machine precision and lambda_fit must equal
lambda* -- this is the consistency check that the least-squares construction
in KKTResidual.jl reduces to the exact theory when the candidate is exact.
"""
function test_exact_point(; verbose::Bool=true)
    rng = MersenneTwister(1)
    ok = true
    for (n, κ) in [(5, 1.0), (20, 1e3), (50, 1e5)]
        g1 = randn(rng, n); g2 = randn(rng, n)
        B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        r = kkt_residual(g1, g2, B1, B2, res.d, res.ϕ)
        good = r.total <= 1e-6 && abs(r.λ_fit - res.λ) <= 1e-6
        ok &= good
        verbose && @printf("  n=%d κ=%.0e  total=%.2e  |λ_fit-λ*|=%.2e  %s\n",
                            n, κ, r.total, abs(r.λ_fit - res.λ), good ? "OK" : "FAILED")
    end
    return ok
end

"""
    test_near_degenerate(; verbose) -> Bool

kkt_residual must not error/NaN on near-degenerate instances (v = r2-r1 ~ 0),
and should still report a small residual.
"""
function test_near_degenerate(; verbose::Bool=true)
    rng = MersenneTwister(2)
    ok = true
    for τ in (1e-6, 1e-9, 0.0)
        inst = near_degenerate_instance(15; τ=τ, rng=rng)
        B1, B2 = Matrix(inst.B1), Matrix(inst.B2)
        P = DualProblem(inst.g1, inst.g2, B1, B2)
        res = solve_dual(P)
        r = kkt_residual(inst.g1, inst.g2, B1, B2, res.d, res.ϕ)
        good = isfinite(r.total) && r.total <= 1e-6
        ok &= good
        verbose && @printf("  τ=%.0e  total=%.2e  λ_fit=%.4f  %s\n",
                            τ, r.total, r.λ_fit, good ? "OK" : "FAILED")
    end
    return ok
end

"""
    test_clarabel_solve(; verbose) -> Bool

Runs the real Clarabel solver via solve_primal_socp and checks that the
resulting KKT residual is small and lambda_fit agrees with the exact
lambda* from ScalarDualNewton.jl.
"""
function test_clarabel_solve(; verbose::Bool=true)
    rng = MersenneTwister(3)
    ok = true
    for (n, κ) in [(10, 1.0), (30, 1e3)]
        g1 = randn(rng, n); g2 = randn(rng, n)
        B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        sol = solve_primal_socp(g1, g2, B1, B2; optimizer=Clarabel.Optimizer, silent=true)
        r = kkt_residual(g1, g2, B1, B2, sol.d, sol.t)
        good = sol.status == JuMP.MOI.OPTIMAL && r.total <= 1e-3 && abs(r.λ_fit - res.λ) <= 1e-3
        ok &= good
        verbose && @printf("  n=%d κ=%.0e  status=%s  total=%.2e  |λ_fit-λ*|=%.2e  %s\n",
                            n, κ, sol.status, r.total, abs(r.λ_fit - res.λ), good ? "OK" : "FAILED")
    end
    return ok
end

"""
    test_mosek_solve(; verbose) -> Bool

Same as `test_clarabel_solve`, but via Mosek (`optimizer=Mosek.Optimizer`).
Independent confirmation that `kkt_residual` reports small residuals for a
second, unrelated solver, not just Clarabel.
"""
function test_mosek_solve(; verbose::Bool=true)
    rng = MersenneTwister(3)
    ok = true
    for (n, κ) in [(10, 1.0), (30, 1e3)]
        g1 = randn(rng, n); g2 = randn(rng, n)
        B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        sol = solve_primal_socp(g1, g2, B1, B2; optimizer=Mosek.Optimizer, silent=true)
        r = kkt_residual(g1, g2, B1, B2, sol.d, sol.t)
        good = sol.status == JuMP.MOI.OPTIMAL && r.total <= 1e-3 && abs(r.λ_fit - res.λ) <= 1e-3
        ok &= good
        verbose && @printf("  n=%d κ=%.0e  status=%s  total=%.2e  |λ_fit-λ*|=%.2e  %s\n",
                            n, κ, sol.status, r.total, abs(r.λ_fit - res.λ), good ? "OK" : "FAILED")
    end
    return ok
end

"""
    test_gurobi_solve(; verbose) -> Bool

Same as `test_clarabel_solve`, but via Gurobi (`optimizer=Gurobi.Optimizer`).
Third independent solver confirmation, same policy as `test_mosek_solve`.
"""
function test_gurobi_solve(; verbose::Bool=true)
    rng = MersenneTwister(3)
    ok = true
    for (n, κ) in [(10, 1.0), (30, 1e3)]
        g1 = randn(rng, n); g2 = randn(rng, n)
        B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        sol = solve_primal_socp(g1, g2, B1, B2; optimizer=GurobiSilent, silent=true)
        r = kkt_residual(g1, g2, B1, B2, sol.d, sol.t)
        good = sol.status == JuMP.MOI.OPTIMAL && r.total <= 1e-3 && abs(r.λ_fit - res.λ) <= 1e-3
        ok &= good
        verbose && @printf("  n=%d κ=%.0e  status=%s  total=%.2e  |λ_fit-λ*|=%.2e  %s\n",
                            n, κ, sol.status, r.total, abs(r.λ_fit - res.λ), good ? "OK" : "FAILED")
    end
    return ok
end

"""
    test_ipopt_solve(; verbose) -> Bool

Same as `test_clarabel_solve`, but via Ipopt, a general NLP solver, not a
conic one -- it doesn't accept the RotatedSecondOrderCone constraint
`solve_primal_socp` builds, so this goes through `solve_primal_qcqp_raw`
(raw quadratic constraint) instead. Ipopt also reports success as
`MOI.LOCALLY_SOLVED`, not `MOI.OPTIMAL` (the status conic solvers use), so
the "trust this point" check differs from the other `test_*_solve`
functions above (an earlier version of `solve_primal_qcqp_raw` wrongly
excluded `LOCALLY_SOLVED`, silently discarding genuinely good points as
NaN).
"""
function test_ipopt_solve(; verbose::Bool=true)
    rng = MersenneTwister(3)
    ok = true
    for (n, κ) in [(10, 1.0), (30, 1e3)]
        g1 = randn(rng, n); g2 = randn(rng, n)
        B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
        P = DualProblem(g1, g2, B1, B2)
        res = solve_dual(P)
        sol = solve_primal_qcqp_raw(g1, g2, B1, B2; optimizer=Ipopt.Optimizer, silent=true)
        r = kkt_residual(g1, g2, B1, B2, sol.d, sol.t)
        good = sol.status == JuMP.MOI.LOCALLY_SOLVED && r.total <= 1e-3 && abs(r.λ_fit - res.λ) <= 1e-3
        ok &= good
        verbose && @printf("  n=%d κ=%.0e  status=%s  total=%.2e  |λ_fit-λ*|=%.2e  %s\n",
                            n, κ, sol.status, r.total, abs(r.λ_fit - res.λ), good ? "OK" : "FAILED")
    end
    return ok
end

"""
    test_dual_cross_check(; verbose) -> Bool

Cross-checks lambda_fit against Clarabel's own reported dual value for the
RSOC constraints (normalized: w_j := dual(con_j)[1], lambda_dual :=
w2/(w1+w2)). Confirms empirically that the two constructions agree once the
solver's raw dual is normalized.
"""
function test_dual_cross_check(; verbose::Bool=true)
    rng = MersenneTwister(4)
    n, κ = 15, 10.0
    g1 = randn(rng, n); g2 = randn(rng, n)
    B1 = random_spd(n, κ, rng); B2 = random_spd(n, κ, rng)
    P = DualProblem(g1, g2, B1, B2)
    res = solve_dual(P)

    L1 = Matrix(cholesky(Symmetric(B1)).L)
    L2 = Matrix(cholesky(Symmetric(B2)).L)
    model = Model(Clarabel.Optimizer)
    set_silent(model)
    @variable(model, t)
    @variable(model, d[1:n])
    @objective(model, Min, t)
    con1 = @constraint(model, vcat(t - dot(g1, d), 1, L1' * d) in RotatedSecondOrderCone())
    con2 = @constraint(model, vcat(t - dot(g2, d), 1, L2' * d) in RotatedSecondOrderCone())
    optimize!(model)

    w1, w2 = dual(con1)[1], dual(con2)[1]
    λ_dual = w2 / (w1 + w2)
    r = kkt_residual(g1, g2, B1, B2, value.(d), value(t))

    good = abs(λ_dual - r.λ_fit) <= 1e-4 && abs(λ_dual - res.λ) <= 1e-4
    if verbose
        @printf("  λ* (ScalarDualNewton)=%.6f  λ_fit=%.6f  λ_dual(normalized)=%.6f  %s\n",
                res.λ, r.λ_fit, λ_dual, good ? "OK" : "FAILED")
    end
    return good
end

function main()
    println("Running KKTResidual validation tests...")
    println()
    println("Test 1: exact point (consistency with ScalarDualNewton.jl)")
    ok1 = test_exact_point()
    println()
    println("Test 2: near-degenerate instances (no crash, small residual)")
    ok2 = test_near_degenerate()
    println()
    println("Test 3: real Clarabel solve via solve_primal_socp")
    ok3 = test_clarabel_solve()
    println()
    println("Test 4: cross-check against Clarabel's own (normalized) dual value")
    ok4 = test_dual_cross_check()
    println()

    ok5 = true
    if HAS_MOSEK
        println("Test 5: real Mosek solve via solve_primal_socp")
        ok5 = test_mosek_solve()
        println()
    else
        println("Test 5: skipped (Mosek not available -- no license or MosekTools not installed)")
        println()
    end

    ok6 = true
    if HAS_GUROBI
        println("Test 6: real Gurobi solve via solve_primal_socp")
        ok6 = test_gurobi_solve()
        println()
    else
        println("Test 6: skipped (Gurobi not available -- no license or Gurobi.jl not installed)")
        println()
    end

    ok7 = true
    if HAS_IPOPT
        println("Test 7: real Ipopt solve via solve_primal_qcqp_raw")
        ok7 = test_ipopt_solve()
        println()
    else
        println("Test 7: skipped (Ipopt not available -- Ipopt.jl not installed)")
        println()
    end

    if ok1 && ok2 && ok3 && ok4 && ok5 && ok6 && ok7
        println("All KKTResidual tests passed.")
    else
        println("SOME TESTS FAILED.")
        exit(1)
    end
end

# Runs automatically when executed as `julia test_kkt_residual.jl` from the
# shell, but not when `include`/`includet` from an interactive REPL session
# -- there, call main() explicitly.
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
