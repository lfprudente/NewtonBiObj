#!/usr/bin/env julia
#
# Driver for the numerical experiments reported in the paper. Run from the
# project root with:
#
#   julia --project=. scripts/run_experiments.jl
#
# Loads everything via the umbrella module `NewtonBiObj` (src/NewtonBiObj.jl).

using Pkg
# Pkg.activate(@__DIR__)  # uncomment if using a local Project.toml

using LinearAlgebra
using Random
using Statistics
using Printf
using JuMP
using Clarabel
using JLD2
using CSV

using NewtonBiObj
using .ScalarDualNewton
using .PrimalSOCP
using .ProblemInterface
using .SyntheticProblems
using .PerformanceProfiles
using .BFGSOuterLoop

# Mosek and Gurobi require a license; both are optional, so the script
# still runs with just Clarabel on machines without those licenses.
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

# Ipopt is open-source (no license), but still detected the same way for
# consistency and so the script degrades gracefully if it isn't installed.
const HAS_IPOPT = try
    @eval using Ipopt
    true
catch
    false
end

# Gurobi prints its WLS license banner on every new Environment (every
# `Model(Gurobi.Optimizer)` call, not just once per process). A shared Env
# with OutputFlag=0 suppresses it; the wrapper is named with a "Gurobi"
# prefix so PrimalSOCP.jl's name-based tolerance mapping still matches it.
if HAS_GUROBI
    const GRB_ENV = Gurobi.Env(Dict{String,Any}("OutputFlag" => 0))
    GurobiSilent() = Gurobi.Optimizer(GRB_ENV)
end

# List of SOCP competitors available on this machine. Each result row from
# the functions below is per (instance, method) -- "Algorithm1" plus one row
# per solver here -- a "long" format suited to building a performance
# profile later, not just medians.
const SOLVERS = let s = Tuple{String,Any}[("Clarabel", Clarabel.Optimizer)]
    HAS_MOSEK  && push!(s, ("Mosek", Mosek.Optimizer))
    HAS_GUROBI && push!(s, ("Gurobi", GurobiSilent))
    s
end

# Ipopt is a general NLP solver, not a conic one: it doesn't accept the
# RotatedSecondOrderCone constraint solve_primal_socp builds, so it's run
# separately via solve_primal_qcqp_raw (raw quadratic constraint). This
# matters in practice: a general NLP solver was empirically far more
# robust than the conic solvers on several real, ill-conditioned test
# problems, once B1/B2 needed regularizing to PD.
const QCQP_SOLVERS = let s = Tuple{String,Any}[]
    HAS_IPOPT && push!(s, ("IPOPT", Ipopt.Optimizer))
    s
end

# Subproblem solvers for the full outer-loop descent experiments
# (BFGSOuterLoop.jl's bfgs_mop): one entry per method, wrapping the same
# underlying solvers as SOLVERS/QCQP_SOLVERS into the
# (g1,g2,B1,B2)->(d,status) interface bfgs_mop expects, via
# subproblem_algorithm1/subproblem_primal_socp/subproblem_primal_qcqp.
const FULL_DESCENT_SOLVERS = let s = Tuple{String,Any}[("Algorithm1", subproblem_algorithm1)]
    for (name, optimizer) in SOLVERS
        push!(s, (name, subproblem_primal_socp(optimizer)))
    end
    for (name, optimizer) in QCQP_SOLVERS
        push!(s, (name, subproblem_primal_qcqp(optimizer)))
    end
    s
end

# Problems flagged `penalize=.true.` in the reference Fortran
# implementation. `run_full_descent_experiments` applies
# `make_penalized_eval`'s cubic box penalty only to these; problems only
# available in `MyProblem.jl` have no such flag and are left unpenalized.
const PENALIZED_PROBLEMS = Set([
    "DD1", "DGO2", "IM1", "JOS4", "KW2", "Lov2", "Lov6",
    "MLF1", "MMR1", "MMR3", "MMR4", "MOP6", "SD", "TKLY1", "VU2",
    "ZDT1", "ZDT2", "ZDT3", "ZDT4", "ZDT6",
])

# The 44 bi-objective (m=2) problems from the paper's appendix table, as
# opposed to the larger set returned by `list_biobjective_problems()`.
const PAPER_TEST_PROBLEMS = [
    "AP3", "DD1", "F1", "F2", "F3", "F4", "F5", "F7", "F9", "Far1", "FF1", "Hil1", "IM1", "JOS1", "KW2", "LE1",
    "Lov1", "Lov2", "Lov3", "Lov4", "Lov5", "Lov6",
    "MLF2", "MMR1", "MMR3", "MMR4", "MOP2", "MOP3", "MOP6", "PNR", "QV1", "SD", "SK2", "SLCDT1", "SP1", "TKLY1", "Toi4",
    "VU1", "VU2", "ZDT1", "ZDT2", "ZDT3", "ZDT4", "ZDT6",
]

"""
    warmup!()

Runs every method once on a throwaway tiny instance, discarding the
result, so JIT compilation doesn't bias whichever instance happens to be
timed first. Called automatically at the start of each `run_*_experiments`
function.
"""
function warmup!()
    n = 5
    g1, g2 = randn(n), randn(n)
    A1 = randn(n, n); B1 = A1 * A1' + I
    A2 = randn(n, n); B2 = A2 * A2' + I

    P = DualProblem(g1, g2, B1, B2)
    solve_dual(P)

    for (_, optimizer) in SOLVERS
        solve_primal_socp(g1, g2, B1, B2; optimizer=optimizer)
    end
    for (_, optimizer) in QCQP_SOLVERS
        solve_primal_qcqp_raw(g1, g2, B1, B2; optimizer=optimizer)
    end
    return nothing
end

# =========================================================================
# Full outer-loop (BFGS-Wolfe) total execution time, real test problems
# =========================================================================

"""
    run_full_descent_experiments(; nstarts=100, seed=1, maxoutiter=500, epsopt=1e-6,
                  verbose=true, problems=list_biobjective_problems(),
                  solvers=FULL_DESCENT_SOLVERS) -> results

Runs the BFGS-Wolfe outer loop (`BFGSOuterLoop.bfgs_mop`) to convergence on
every problem in `problems`, from `nstarts` random starting points each,
for every `(name, subsolver)` pair in `solvers`. Measures *total*
wall-clock time of the outer loop, not just a single subproblem solve.
Defaults reproduce the paper's experiment (`problems=PAPER_TEST_PROBLEMS`,
the 44 problems in its appendix table); pass
`problems=list_biobjective_problems()` for the larger set available in
`MyProblem.jl`.

Starting points are drawn via `ProblemInterface.inip(name; rng)` with a
seeded `rng` threaded across all `nstarts` draws of a given problem.
Objective evaluations go through `BFGSOuterLoop.make_penalized_eval`, with
the cubic box penalty applied only to problems in `PENALIZED_PROBLEMS`.

Records, per `(problem,start,method)`: `time`, `outiter`, `theta` (final
optimality measure), and `status`
(`:converged`/`:maxit`/`:subproblem_error`/`:linesearch_error`).
"""
function run_full_descent_experiments(; nstarts::Int=100, seed::Int=1, maxoutiter::Int=500, verbose::Bool=true,
                        epsopt::Float64=1e-6,
                        problems::Vector{String}=PAPER_TEST_PROBLEMS,
                        solvers=FULL_DESCENT_SOLVERS)
    verbose && println("Bi-objective problems: ", length(problems))
    verbose && println("Subproblem solvers: ", join(first.(solvers), ", "))

    results = NamedTuple[]

    for name in problems
        ProblemInterface.PROBLEM = name
        rng = MersenneTwister(seed)

        local n, l, u, strconvex, scaleF
        try
            n, _, _, l, u, strconvex, scaleF, _ = ProblemInterface.inip(name; rng=rng)
        catch err
            @warn "Skipping $name (failed to initialize)" exception=err
            continue
        end

        raw_evalf(ind, x) = ProblemInterface.evalf(ind, x, n)
        raw_evalg!(g, ind, x) = ProblemInterface.evalg!(g, ind, x, n)
        pf, pg! = make_penalized_eval(raw_evalf, raw_evalg!, l, u; penalize=(name in PENALIZED_PROBLEMS))

        verbose && @printf("%s\n", "-"^20)
        for start in 1:nstarts
            _, _, x0, _, _, _, _, _ = ProblemInterface.inip(name; rng=rng)

            for (solver_name, subsolver) in solvers
                # A single pathological combination shouldn't abort the
                # whole run -- record it as :crashed and move on.
                local t, res
                try
                    t = @elapsed res = bfgs_mop(n, x0, strconvex, scaleF, pf, pg!;
                                                subproblem_solver=subsolver, maxoutiter=maxoutiter,
                                                epsopt=epsopt)
                catch err
                    @warn "Crashed on $name start=$start method=$solver_name" exception=err
                    t = NaN
                    res = (outiter=0, theta=NaN, status=:crashed)
                end
                push!(results, (problem=name, start=start, method=solver_name, time=t,
                                 outiter=res.outiter, theta=res.theta, status=res.status))
                verbose && @printf("%-10s start=%2d  %-10s t=%.3e s  outiter=%4d  theta=%9.1e  [%s]\n",
                                    name, start, solver_name, t, res.outiter, res.theta, res.status)
            end
        end
    end

    return results
end

# =========================================================================
# Scalability in n, dense synthetic instances
# =========================================================================

"""
    _median_elapsed(f, n; n_threshold, ntrials) -> (time, result)

Runs `f()` once and returns its wall-clock time if `n > n_threshold`.
Otherwise runs `f()` `ntrials` times (same instance) and returns the
median: at small `n`, absolute times are sub-second and dominated by
OS/GC scheduling jitter rather than genuine variance, so a single
measurement is noisy.
"""
function _median_elapsed(f, n; n_threshold::Int, ntrials::Int)
    if n > n_threshold
        t = @elapsed result = f()
        return t, result
    end
    ts = Float64[]
    local result
    for _ in 1:ntrials
        t = @elapsed result = f()
        push!(ts, t)
    end
    return median(ts), result
end

function run_scalability_experiments(; ns=[50, 100, 250, 500, 1000, 1500, 2000, 4000],
                        κs=[1e1, 1e2, 1e4, 1e6],
                        nrep=3, seed=1, n_threshold=500, ntrials=7, verbose=true)
    verbose && println("Warming up (JIT compilation) before timing...")
    warmup!()

    results = NamedTuple[]
    rng = MersenneTwister(seed)

    for κ in κs, n in ns
        verbose && @printf("%s\n", "-"^20)
        for rep in 1:nrep
            inst = random_instance(n; κ=κ, rng=rng)

            # As in the correctness-check loop above: both timings must
            # start from the same raw data.
            t_dual, res_dual = _median_elapsed(n; n_threshold=n_threshold, ntrials=ntrials) do
                P = DualProblem(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2))
                solve_dual(P)
            end
            push!(results, (n=n, κ=κ, rep=rep, method="Algorithm1", time=t_dual, status=res_dual.status))
            verbose && @printf("n=%5d  κ=%.0e  rep=%d  %-10s t=%.3e s  [%s]\n",
                                n, κ, rep, "Algorithm1", t_dual, res_dual.status)

            for (solver_name, optimizer) in SOLVERS
                t_primal, sol_primal = _median_elapsed(n; n_threshold=n_threshold, ntrials=ntrials) do
                    solve_primal_socp(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2); optimizer=optimizer)
                end
                push!(results, (n=n, κ=κ, rep=rep, method=solver_name, time=t_primal, status=sol_primal.status))
                verbose && @printf("n=%5d  κ=%.0e  rep=%d  %-10s t=%.3e s  [%s]\n",
                                    n, κ, rep, solver_name, t_primal, sol_primal.status)
            end

            for (solver_name, optimizer) in QCQP_SOLVERS
                t_qcqp, sol_qcqp = _median_elapsed(n; n_threshold=n_threshold, ntrials=ntrials) do
                    solve_primal_qcqp_raw(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2); optimizer=optimizer)
                end
                push!(results, (n=n, κ=κ, rep=rep, method=solver_name, time=t_qcqp, status=sol_qcqp.status))
                verbose && @printf("n=%5d  κ=%.0e  rep=%d  %-10s t=%.3e s  [%s]\n",
                                    n, κ, rep, solver_name, t_qcqp, sol_qcqp.status)
            end
        end
    end

    return results
end

# =========================================================================
# Robustness near the degenerate case
# =========================================================================

"""
    run_degenerate_robustness_experiments(; ns=[1000], τs=..., κ=1e2, nrep=10,
                 n_threshold=500, ntrials=7, seed=1, verbose=true,
                 instance_generator=near_degenerate_instance) -> results

Cross-validates Algorithm 1 against the primal solvers on instances
approaching the degenerate case (Proposition 3.3), generated by
`instance_generator` (`SyntheticProblems.jl`: `near_degenerate_instance`,
where `B1 ≈ B2` and `g1 ≈ g2`, or the more general
`degenerate_limit_instance`), controlled by `τ` (`τ=0` is the exact
degenerate limit). Algorithm 1 resolves all of these at Step 0 with a tiny
KKT residual; this asks whether the *primal* solvers -- which must
factorize a cone/KKT system that becomes near-singular as `τ→0` -- degrade
in correctness or timing as the instance gets more degenerate.

Defaults (`ns=[1000]`, `nrep=10`) match the paper: a single `n`, 10
instances per `τ`, median time per `(τ,method)` cell.

Records, per `(n,τ,rep,method)`: `time`, `status`, and `err_d`/`err_obj`
(Inf-norm relative error of the primal solver's solution against
Algorithm 1's own).
"""
function run_degenerate_robustness_experiments(; ns=[1000],
                        τs=[1e-3, 1e-6, 1e-9, 1e-12, 0.0],
                        κ=1e2, nrep=10, seed=1, n_threshold=500, ntrials=7, verbose=true,
                        instance_generator=near_degenerate_instance)
    verbose && println("Warming up (JIT compilation) before timing...")
    warmup!()

    results = NamedTuple[]
    rng = MersenneTwister(seed)

    for τ in τs, n in ns
        verbose && @printf("%s\n", "-"^20)
        for rep in 1:nrep
            inst = instance_generator(n; τ=τ, κ=κ, rng=rng)

            t_dual, res_dual = _median_elapsed(n; n_threshold=n_threshold, ntrials=ntrials) do
                P = DualProblem(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2))
                solve_dual(P)
            end
            push!(results, (n=n, τ=τ, rep=rep, method="Algorithm1", time=t_dual, status=res_dual.status,
                             err_d=0.0, err_obj=0.0))
            verbose && @printf("n=%5d  τ=%.0e  rep=%d  %-10s t=%.3e s  [%s]\n",
                                n, τ, rep, "Algorithm1", t_dual, res_dual.status)

            for (solver_name, optimizer) in SOLVERS
                t_primal, sol_primal = _median_elapsed(n; n_threshold=n_threshold, ntrials=ntrials) do
                    solve_primal_socp(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2); optimizer=optimizer)
                end
                err_d   = norm(res_dual.d - sol_primal.d, Inf) / max(1.0, norm(sol_primal.d, Inf))
                err_obj = abs(res_dual.ϕ - (-sol_primal.obj)) / max(1.0, abs(sol_primal.obj))
                push!(results, (n=n, τ=τ, rep=rep, method=solver_name, time=t_primal, status=sol_primal.status,
                                 err_d=err_d, err_obj=err_obj))
                verbose && @printf("n=%5d  τ=%.0e  rep=%d  %-10s t=%.3e s  err_d=%.1e  err_obj=%.1e  [%s]\n",
                                    n, τ, rep, solver_name, t_primal, err_d, err_obj, sol_primal.status)
            end

            for (solver_name, optimizer) in QCQP_SOLVERS
                t_qcqp, sol_qcqp = _median_elapsed(n; n_threshold=n_threshold, ntrials=ntrials) do
                    solve_primal_qcqp_raw(inst.g1, inst.g2, Matrix(inst.B1), Matrix(inst.B2); optimizer=optimizer)
                end
                err_d   = norm(res_dual.d - sol_qcqp.d, Inf) / max(1.0, norm(sol_qcqp.d, Inf))
                err_obj = abs(res_dual.ϕ - (-sol_qcqp.obj)) / max(1.0, abs(sol_qcqp.obj))
                push!(results, (n=n, τ=τ, rep=rep, method=solver_name, time=t_qcqp, status=sol_qcqp.status,
                                 err_d=err_d, err_obj=err_obj))
                verbose && @printf("n=%5d  τ=%.0e  rep=%d  %-10s t=%.3e s  err_d=%.1e  err_obj=%.1e  [%s]\n",
                                    n, τ, rep, solver_name, t_qcqp, err_d, err_obj, sol_qcqp.status)
            end
        end
    end

    return results
end

# =========================================================================
# Result persistence
# =========================================================================

"""
    save_results(results, basename)

Saves `results` (the "long" vector returned by any `run_*_experiments`
function) as both `basename.jld2` (Julia-native, preserves `status`'s
exact type; reload with `JLD2.load(basename*".jld2", "results")`) and
`basename.csv` (portable; `status` becomes plain text, still recognized by
`PerformanceProfiles.is_success`; reload with
`CSV.File(basename*".csv") |> Tables.rowtable`).
"""
function save_results(results, basename::AbstractString)
    jldsave(basename * ".jld2"; results=results)
    CSV.write(basename * ".csv", results)
    return nothing
end

# =========================================================================
# Execution
# =========================================================================

function main()
    println("=== Scalability in n (dense synthetic instances) ===")
    res_scalability = run_scalability_experiments()
    save_results(res_scalability, joinpath(@__DIR__, "scalability_results"))
    println("\nResults saved to scalability_results.jld2 / scalability_results.csv")

    println("\n=== Robustness near the degenerate case ===")
    res_degenerate = run_degenerate_robustness_experiments()
    save_results(res_degenerate, joinpath(@__DIR__, "degenerate_robustness_results"))
    println("\nResults saved to degenerate_robustness_results.jld2 / degenerate_robustness_results.csv")

    return res_scalability, res_degenerate
end

# Runs automatically when executed as `julia run_experiments.jl` from the
# shell, but not when `include`/`includet` from an interactive REPL session
# -- there, call main() explicitly.
if abspath(PROGRAM_FILE) == @__FILE__
    main()
end
