"""
    ProblemInterface

Adapter between `MyProblem.jl` (a collection of MOO test problems: F1-F9,
JOSx, ZDTx, MOPx, Lovx, etc.) and the `ScalarDualNewton` / `PrimalSOCP`
modules.

Two usage notes:

1. `MyProblem.jl` references the globals `PROBLEM`, `T`, `ZERO`, `ONE`
   which, in the original code, are defined by an external driver (the
   file itself only defines the problems). If your project already
   defines these globals elsewhere, comment out the `const`/`global` block
   below and just make sure `MyProblem.jl` is included before this file.

2. The analytical Hessians `evalh!` are the raw ∇²fⱼ(x). Since most of
   these problems are nonconvex (`strconvex=false`), ∇²fⱼ(x) may be
   indefinite at a generic point -- which violates the paper's Bⱼ ≻ 0
   assumption. By default, we therefore regularize by eigenvalues
   (Levenberg-Marquardt style): eigenvalues smaller than `eps_reg` are
   replaced by `eps_reg`. This is the same practice used in
   implementations of multiobjective Newton-type methods. Turn it off
   with `regularize=false` if you want to guarantee by hand that the
   point already satisfies Bⱼ ≻ 0 (e.g. by testing points close to a
   local minimizer of fⱼ).
"""
module ProblemInterface

using Random
using LinearAlgebra

export biobjective_data, list_biobjective_problems, ALL_KNOWN_PROBLEMS

# ----------------------------------------------------------------------
# Globals required by MyProblem.jl. Remove this block if your project
# already defines them elsewhere.
# ----------------------------------------------------------------------
const T    = Float64
const ZERO = 0.0
const ONE  = 1.0
PROBLEM = "F1"

include("MyProblem.jl")   # adjust the path if needed; defines inip, evalf, evalg!, evalh!

const ALL_KNOWN_PROBLEMS = [
    "F1","F2","F3","F4","F5","F6","F7","F8","F9",
    "CEC04","CEC05","CEC06","CEC07","CEC09","CEC10",
    "AP1","AP2","AP3","AP4","DD1","DGO1","DGO2","FA1","Far1","FDS","FF1",
    "Hil1","IKK1","IM1","JOS1","JOS4","KW2","LE1","LTDZ","Lov1","Lov2",
    "Lov3","Lov4","Lov5","Lov6","MGH9","MGH16","MGH26","MGH33","MHHM2",
    "MLF1","MLF2","MMR1","MMR3","MMR4","MOP2","MOP3","MOP5","MOP6","MOP7",
    "PNR","QV1","SD","SK1","SK2","SLCDT1","SLCDT2","SP1","SSFYY2","TKLY1",
    "Toi4","Toi8","Toi9","Toi10","VU1","VU2","ZDT1","ZDT2","ZDT3","ZDT4",
    "ZDT6","ZLT1",
]

"""
    eig_regularize(H; eps_reg=1e-6) -> Symmetric SPD matrix

Replaces eigenvalues of H smaller than `eps_reg` by `eps_reg`, preserving
the eigenvectors. Cost O(n³) (same order as the Cholesky used downstream).
"""
function eig_regularize(H::AbstractMatrix{T}; eps_reg::T=T(1e-6)) where {T<:AbstractFloat}
    F = eigen(Symmetric(Matrix(H)))
    λs = F.values
    λs_reg = map(λ -> λ < eps_reg ? eps_reg : λ, λs)
    return Symmetric(F.vectors * Diagonal(λs_reg) * F.vectors')
end

"""
    biobjective_data(name; x=nothing, seed=1, regularize=true, eps_reg=1e-6)

Builds (g1, g2, B1, B2) for a bi-objective problem (m == 2) from
`MyProblem.jl`, evaluated at the point `x` (uses the problem's own random
starting point if `x === nothing`).

Returns a NamedTuple (g1, g2, B1, B2, n, x, was_regularized_1, was_regularized_2).
"""
function biobjective_data(name::String; x::Union{Nothing,Vector{Float64}}=nothing,
                           seed::Int=1, regularize::Bool=true, eps_reg::Float64=1e-6)
    global PROBLEM
    PROBLEM = name

    rng = MersenneTwister(seed)
    n, m, x0, l, u, strconvex, scaleF, checkder = inip(name; rng=rng)
    m == 2 || throw(ArgumentError("Problem $name has m=$m objectives; this pipeline requires m=2."))

    xx = x === nothing ? x0 : x
    length(xx) == n || throw(DimensionMismatch("x has length $(length(xx)), expected $n"))

    g1 = zeros(Float64, n); g2 = zeros(Float64, n)
    H1 = zeros(Float64, n, n); H2 = zeros(Float64, n, n)

    evalg!(g1, 1, xx, n)
    evalg!(g2, 2, xx, n)
    evalh!(H1, 1, xx, n)
    evalh!(H2, 2, xx, n)

    reg1 = false
    reg2 = false
    if regularize
        if minimum(eigvals(Symmetric(H1))) < eps_reg
            H1 = Matrix(eig_regularize(H1; eps_reg=eps_reg)); reg1 = true
        end
        if minimum(eigvals(Symmetric(H2))) < eps_reg
            H2 = Matrix(eig_regularize(H2; eps_reg=eps_reg)); reg2 = true
        end
    end

    return (g1=g1, g2=g2, B1=Symmetric(H1), B2=Symmetric(H2), n=n, x=xx,
            was_regularized_1=reg1, was_regularized_2=reg2)
end

"""
    list_biobjective_problems()

Scans `ALL_KNOWN_PROBLEMS` and returns the names with m == 2, by testing `inip`.
"""
function list_biobjective_problems()
    out = String[]
    for name in ALL_KNOWN_PROBLEMS
        try
            _, m, _, _, _, _, _, _ = inip(name)
            m == 2 && push!(out, name)
        catch err
            @warn "Failed to initialize $name" exception=err
        end
    end
    return out
end

end # module
