#!/usr/bin/env julia
#
# Runs the full test suite by invoking each test file as a standalone
# script (each already prints its own report and exits with status 1 on
# failure). From the project root:
#
#   julia --project=. test/runtests.jl
#
# Individual files also run standalone, e.g. `julia --project=. test/test_scalar_dual.jl`.

const TEST_DIR = @__DIR__
const TEST_FILES = ["test_scalar_dual.jl", "test_robustness.jl", "test_kkt_residual.jl"]

exitcodes = Int[]
for f in TEST_FILES
    println("="^70)
    println("Running $f")
    println("="^70)
    cmd = `$(Base.julia_cmd()) --project=$(Base.active_project()) $(joinpath(TEST_DIR, f))`
    push!(exitcodes, run(ignorestatus(cmd)).exitcode)
    println()
end

if all(==(0), exitcodes)
    println("All test files passed.")
else
    println("SOME TEST FILES FAILED.")
    exit(1)
end
