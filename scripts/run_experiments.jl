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

# Gurobi prints its WLS license banner ("Set parameter WLSAccessID" etc.)
# on *every* new Environment, i.e. every `Model(Gurobi.Optimizer)` call --
# confirmed by testing, not just once per process. A shared Env with
# OutputFlag=0, wrapped in a function named with a "Gurobi" prefix (so
# `occursin("Gurobi", string(optimizer))` in PrimalSOCP.jl's
# `_set_solver_tolerance!` still matches it -- confirmed this works, a
# bare anonymous closure's `string(...)` does *not* contain "Gurobi" and
# would silently skip the tolerance mapping), suppresses it entirely.
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

# Problems for which the reference Fortran implementation's `inip` sets
# `penalize = .true.` (every other bi-objective problem there has
# `penalize = .false.`). `run_full_descent_experiments` applies
# `make_penalized_eval`'s cubic box penalty only to problems in this set,
# matching that reference exactly, instead of a "penalize everything
# uniformly" approximation. Problems that exist only in `MyProblem.jl` have
# no such reference flag to match and are treated as unpenalized.
# Restricted to m=2 problems only.
const PENALIZED_PROBLEMS = Set([
    "DD1", "DGO2", "IM1", "JOS4", "KW2", "Lov2", "Lov6",
    "MLF1", "MMR1", "MMR3", "MMR4", "MOP6", "SD", "TKLY1", "VU2",
    "ZDT1", "ZDT2", "ZDT3", "ZDT4", "ZDT6",
])

# The 44 bi-objective (m=2) problems from the paper's appendix table, as
# opposed to the larger set returned by `list_biobjective_problems()` (which
# includes additional problems only available in `MyProblem.jl`, not part
# of that table).
#
# QV1 needs the Cholesky regularization in `_cholesky_or_shift` (both
# `ScalarDualNewton.jl` and `PrimalSOCP.jl`): its BFGS Hessian
# approximation is reliably driven to the edge of positive-semidefiniteness
# (both objectives have strconvex=false), with eigenvalues indefinite only
# by floating-point rounding.
const PAPER_TEST_PROBLEMS = [
    "AP3", "DD1", "F1", "F2", "F3", "F4", "F5", "F7", "F9", "Far1", "FF1", "Hil1", "IM1", "JOS1", "KW2", "LE1",
    "Lov1", "Lov2", "Lov3", "Lov4", "Lov5", "Lov6",
    "MLF2", "MMR1", "MMR3", "MMR4", "MOP2", "MOP3", "MOP6", "PNR", "QV1", "SD", "SK2", "SLCDT1", "SP1", "TKLY1", "Toi4",
    "VU1", "VU2", "ZDT1", "ZDT2", "ZDT3", "ZDT4", "ZDT6",
]

"""
    warmup!()

Runs every method (`solve_dual`, and each of `SOLVERS`/`QCQP_SOLVERS` via
`solve_primal_socp`/`solve_primal_qcqp_raw`) once on a throwaway tiny
instance, discarding the result. Julia JIT-compiles each method/code path
the first time it's actually called, and that first call can be orders of
magnitude slower than a "warm" one (confirmed directly: `elapsed -
solve_time` for `solve_primal_socp` was ~8.9s on a literal first call vs.
~0.02s on a second, warmed-up one, in the same session). Without this,
whichever problem happens to be timed first in any of the `run_*_experiments`
functions would be unfairly penalized relative to every other -- not a
property of the method being slow, just of Julia's compilation model.
Called automatically at the start of each of them.
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
# Subproblem-only correctness check on real test problems (superseded by
# the full outer-loop `run_full_descent_experiments` below, kept as a
# standalone utility)
# =========================================================================

function run_subproblem_correctness_check(; eps_reg=1e-6, verbose=true)
    verbose && println("Warming up (JIT compilation) before timing...")
    warmup!()

    names = list_biobjective_problems()
    verbose && println("Bi-objective problems found (m=2): ", length(names))
    verbose && println("Available SOCP solvers: ", join(first.(SOLVERS), ", "))
    verbose && println("Available QCQP (raw constraint) solvers: ", join(first.(QCQP_SOLVERS), ", "))

    results = NamedTuple[]

    for name in names
        local data
        try
            data = biobjective_data(name; regularize=true, eps_reg=eps_reg)
        catch err
            @warn "Skipping $name (failed to build data)" exception=err
            continue
        end

        # Both timings start from the same raw data (g1,g2,B1,B2), so each
        # method's own required preprocessing counts as part of its own
        # cost: DualProblem's construction (computes Δg, ΔB) for Algorithm 1,
        # the Cholesky of B1,B2 for the RSOC reformulation done inside
        # solve_primal_socp.
        t_dual = @elapsed begin
            P = DualProblem(data.g1, data.g2, Matrix(data.B1), Matrix(data.B2))
            res = solve_dual(P)
        end

        push!(results, (name=name, n=data.n, method="Algorithm1",
                         time=t_dual, status=res.status,
                         err_d=0.0, err_obj=0.0,
                         reg1=data.was_regularized_1, reg2=data.was_regularized_2))
        verbose && @printf("%-10s n=%4d  %-10s t=%.2e s  [%s]\n",
                            name, data.n, "Algorithm1", t_dual, res.status)

        for (solver_name, optimizer) in SOLVERS
            t_primal_socp = @elapsed sol_primal = solve_primal_socp(
                data.g1, data.g2, Matrix(data.B1), Matrix(data.B2);
                optimizer=optimizer)

            # Inf-norm, not 2-norm: n ranges from 1 to 100+ across these real
            # problems, and the 2-norm inflates with sqrt(n) at fixed
            # per-component accuracy.
            err_d   = norm(res.d - sol_primal.d, Inf) / max(1.0, norm(sol_primal.d, Inf))
            err_obj = abs(res.ϕ - (-sol_primal.obj)) / max(1.0, abs(sol_primal.obj))
            # Note: ϕ(λ*) = -t*  at optimality (strong duality), hence the sign.

            push!(results, (name=name, n=data.n, method=solver_name,
                             time=t_primal_socp, status=sol_primal.status,
                             err_d=err_d, err_obj=err_obj,
                             reg1=data.was_regularized_1, reg2=data.was_regularized_2))

            if verbose
                @printf("%-10s n=%4d  %-10s t=%.2e s  err_d=%.1e  err_obj=%.1e  [%s]\n",
                        name, data.n, solver_name, t_primal_socp, err_d, err_obj, sol_primal.status)
            end
        end

        for (solver_name, optimizer) in QCQP_SOLVERS
            t_qcqp = @elapsed sol_qcqp = solve_primal_qcqp_raw(
                data.g1, data.g2, Matrix(data.B1), Matrix(data.B2);
                optimizer=optimizer)

            err_d   = norm(res.d - sol_qcqp.d, Inf) / max(1.0, norm(sol_qcqp.d, Inf))
            err_obj = abs(res.ϕ - (-sol_qcqp.obj)) / max(1.0, abs(sol_qcqp.obj))

            push!(results, (name=name, n=data.n, method=solver_name,
                             time=t_qcqp, status=sol_qcqp.status,
                             err_d=err_d, err_obj=err_obj,
                             reg1=data.was_regularized_1, reg2=data.was_regularized_2))

            if verbose
                @printf("%-10s n=%4d  %-10s t=%.2e s  err_d=%.1e  err_obj=%.1e  [%s]\n",
                        name, data.n, solver_name, t_qcqp, err_d, err_obj, sol_qcqp.status)
            end
        end
    end

    return results
end

# =========================================================================
# Full outer-loop (BFGS-Wolfe) total execution time, real test problems
# =========================================================================

"""
    run_full_descent_experiments(; nstarts=30, seed=1, maxoutiter=2000, verbose=true,
                  problems=list_biobjective_problems(), solvers=FULL_DESCENT_SOLVERS) -> results

Runs the ported BFGS-Wolfe outer loop (`BFGSOuterLoop.bfgs_mop`) to full
convergence on every problem in `problems` (defaults to every bi-objective
(`m=2`) problem returned by `list_biobjective_problems()`; pass
`PAPER_TEST_PROBLEMS` to restrict to the 44 problems used in the paper's
appendix table), from `nstarts` random starting points each, once per
`(name, subsolver)` pair in `solvers` (defaults to `FULL_DESCENT_SOLVERS`,
i.e. Algorithm 1 and every primal solver available; pass e.g.
`FULL_DESCENT_SOLVERS[1:1]` to run Algorithm 1 only, for faster iteration
while still validating/tuning `bfgs_mop` itself). Measures *total*
wall-clock time of the whole outer loop, not just a single subproblem
solve -- this is the "embedded in a full descent method" comparison
reported in the paper, made possible by `BFGSOuterLoop.jl`.

Starting points are drawn by calling `ProblemInterface.inip(name; rng)`
repeatedly with the same seeded `rng` threaded across all `nstarts` draws
for a given problem (so results are reproducible given `seed`); `n`, `l`,
`u`, `strconvex`, `scaleF` are taken from the first `inip` call and are the
same for every draw of a given problem. Objective evaluations go through
`BFGSOuterLoop.make_penalized_eval`, with the cubic box penalty applied
only to problems in `PENALIZED_PROBLEMS` (matching the reference Fortran
implementation's per-problem `penalize` flag).

Records, per `(problem,start,method)`: `time` (the whole `bfgs_mop` call,
wall-clock), `outiter`, `theta` (final optimality measure), and `status`
(`:converged`/`:maxit`/`:subproblem_error`/`:linesearch_error`).
"""
function run_full_descent_experiments(; nstarts::Int=30, seed::Int=1, maxoutiter::Int=2000, verbose::Bool=true,
                        epsopt::Float64=5.0*sqrt(2.0^-52),
                        problems::Vector{String}=list_biobjective_problems(),
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
                # A single pathological (problem, start, method) combination
                # must not abort a run spanning 56 problems x nstarts x 5
                # methods -- record it as :crashed and move on.
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
Otherwise runs `f()` `ntrials` times (same instance, tight loop) and returns
the median time instead of a single measurement -- at `n ≤ n_threshold`,
absolute times are sub-second and dominated by OS/GC scheduling jitter
rather than genuine instance-to-instance variance (confirmed empirically:
coefficient of variation across repeated instances was ~0.45-0.5 for
n∈{50,250,500} vs. ~0.03-0.11 for n≥1000). `n > n_threshold` cells are
already stable with a single measurement, and dominate total wall time,
so they're not repeated.
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
`instance_generator` (`SyntheticProblems.jl`; either `near_degenerate_instance`,
where `B1 ≈ B2` and `g1 ≈ g2`, or the more general `degenerate_limit_instance`),
controlled by `τ` (`τ=0` is the exact degenerate limit). This stresses
Step 0's preliminary tests, not typical-case scalability: Algorithm 1
resolves these at Step 0 (zero Newton iterations, `status ∈ {endpoint0,
endpoint1}`) with a tiny KKT residual for every `τ` down to and including
`0.0`. This function asks the complementary question: do the *primal*
solvers -- which have no equivalent O(1) shortcut, and must factorize a
cone/KKT system that becomes near-singular as `τ→0` -- degrade in either
correctness or timing as the instance gets more degenerate?

Defaults (`ns=[1000]`, `nrep=10`) match the paper's reporting methodology:
a single `n`, 10 distinct instances per `τ`, median time per `(τ,method)`
cell across those 10 instances. `ns` accepts more than one value, but the
paper's table only ever reports one `n` at a time.

Records, per `(n,τ,rep,method)`: `time` (via `_median_elapsed`, same
measurement-noise mitigation as `run_scalability_experiments` -- irrelevant
at the default `n=1000 > n_threshold`, where each instance is timed once),
`status`, and `err_d`/`err_obj` (Inf-norm relative error of the primal
solver's solution against Algorithm 1's own).
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
function above) in two formats:

- `basename.jld2`: Julia's native format, preserving the exact types
  (`status` stays `Symbol`/`MOI.TerminationStatusCode`, not text) --
  reload with `results = JLD2.load(basename*".jld2", "results")` and use
  directly in `PerformanceProfiles.build_performance_matrix`/`plot_pp`,
  no adapter needed.
- `basename.csv`: readable/portable (Excel, pandas, etc.), but `status`
  becomes plain text (`CSV.write` serializes via `string(...)`) -- still
  directly usable with `build_performance_matrix`/`plot_pp`, since
  `PerformanceProfiles.is_success` has a dedicated method for
  `AbstractString` that recognizes these strings. Reload with
  `results = CSV.File(basename*".csv") |> Tables.rowtable` (or any other
  Tables.jl sink).
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
