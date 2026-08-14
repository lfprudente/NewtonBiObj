# NewtonBiObj.jl

Julia code accompanying the paper

> D. S. Gonçalves, L. F. Prudente, M. L. Schuverdt, F. N. C. Sobral,
> *Efficient solution of the bi-objective Newton-type subproblem via a
> scalar dual formulation*.

The paper studies the min-max quadratic subproblem that arises in
Newton-type methods for unconstrained bi-objective optimization, derives a
scalar dual reformulation, and proposes a safeguarded Newton method
(**Algorithm 1**) for solving it. This repository contains the
implementation of Algorithm 1, the primal competitors used in the paper's
numerical comparison, and the scripts used to reproduce the numerical
experiments.

## Installation

```bash
git clone https://github.com/lfprudente/NewtonBiObj.git
cd NewtonBiObj
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

`--project=.` activates this repository's own environment (`Project.toml`)
for the session; no separate `Pkg.activate()` call is needed as long as
every subsequent `julia` command also uses `--project=.`, as in the
examples below.

Some of the primal competitors require a commercial solver license
(Mosek, Gurobi); those Julia packages are still listed as dependencies (so
`Pkg.instantiate()` installs them), but a license is only needed to
actually call the corresponding solver. The package works with just
Clarabel and Ipopt (both open source) if no such license is available.

To use this package as a dependency of another project instead, run
`Pkg.develop(path="path/to/NewtonBiObj")` (or `Pkg.add(url="...")`) from
that project's own activated environment.

## Package structure

- `src/ScalarDualNewton.jl` -- Algorithm 1: the safeguarded Newton method
  for the bi-objective scalar dual problem. Depends only on
  `LinearAlgebra`.
- `src/PrimalSOCP.jl` -- primal competitors: solves the original epigraph
  problem via a rotated second-order cone (RSOC) reformulation using JuMP
  (works with any JuMP-compatible solver supporting
  `RotatedSecondOrderCone`, e.g. Clarabel, Mosek), plus a raw
  quadratically-constrained variant (`solve_primal_qcqp_raw`) for solvers
  that do not accept conic constraints (e.g. Ipopt) or for measuring the
  effect of the SOC reformulation itself.
- `src/KKTResidual.jl` -- solver-agnostic KKT residual, used to check the
  accuracy of a candidate solution `(t, d)` regardless of which solver
  produced it.
- `src/SyntheticProblems.jl` -- generators for dense synthetic instances,
  used for the scalability experiments and for the experiments near the
  degenerate case.
- `src/MyProblem.jl` / `src/ProblemInterface.jl` -- a collection of
  bi-objective test problems from the literature, and an adapter that
  builds `(g1, g2, B1, B2)` subproblem data from them at a given point.
- `src/BFGSOuterLoop.jl` -- a full multiobjective BFGS-Wolfe descent
  method, used to embed Algorithm 1 (and the primal competitors) inside a
  complete optimization run rather than testing the subproblem solve in
  isolation.
- `src/PerformanceProfiles.jl` -- Dolan-Moré performance profiles and
  summary tables from the experiment results.
- `scripts/run_experiments.jl` -- driver that runs all the numerical
  experiments reported in the paper.
- `test/` -- regression and validation tests.

## Quick example

```julia
using LinearAlgebra
using NewtonBiObj
using .ScalarDualNewton

n = 5
g1, g2 = randn(n), randn(n)
A1 = randn(n, n); B1 = A1 * A1' + I   # any SPD matrix
A2 = randn(n, n); B2 = A2 * A2' + I

P = DualProblem(g1, g2, B1, B2)
res = solve_dual(P)

res.d        # the Newton-type direction
res.status   # :converged, :endpoint0, :endpoint1, or :maxit
```

## Reproducing the paper's experiments

```bash
julia --project=. scripts/run_experiments.jl
```

This runs the scalability experiments and the robustness-near-the-
degenerate-case experiments, saving results as `.jld2`/`.csv` files next
to the script. See the docstrings of `run_scalability_experiments`,
`run_degenerate_robustness_experiments`, and `run_full_descent_experiments`
in `scripts/run_experiments.jl` for how to reproduce each individual
experiment and figure/table from the paper.

## Running the tests

```bash
julia --project=. test/runtests.jl
```

## License

MIT (see `LICENSE`).
