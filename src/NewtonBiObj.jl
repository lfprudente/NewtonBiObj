"""
    NewtonBiObj

Umbrella module for the package. Wraps the individual submodules
(`ScalarDualNewton`, `PrimalSOCP`, etc.) so the whole package can be loaded
with a single `using NewtonBiObj`.
"""
module NewtonBiObj

include(joinpath(@__DIR__, "ScalarDualNewton.jl"))
export ScalarDualNewton

include(joinpath(@__DIR__, "PrimalSOCP.jl"))
export PrimalSOCP

include(joinpath(@__DIR__, "SyntheticProblems.jl"))
export SyntheticProblems

# KKTResidual refers to ScalarDualNewton via `..ScalarDualNewton`, so must
# come after it.
include(joinpath(@__DIR__, "KKTResidual.jl"))
export KKTResidual

include(joinpath(@__DIR__, "ProblemInterface.jl"))
export ProblemInterface

include(joinpath(@__DIR__, "PerformanceProfiles.jl"))
export PerformanceProfiles

# BFGSOuterLoop refers to ScalarDualNewton and PrimalSOCP via relative
# imports, so must come after both.
include(joinpath(@__DIR__, "BFGSOuterLoop.jl"))
export BFGSOuterLoop

end # module
