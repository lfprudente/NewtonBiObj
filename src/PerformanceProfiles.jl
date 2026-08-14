"""
    PerformanceProfiles

Converts the "long format" results produced by `run_experiments.jl`'s
`run_full_descent_experiments`/`run_scalability_experiments`/
`run_degenerate_robustness_experiments` (one row per `(problem, method)`
pair, with `method`, `time`, `status` fields) into Dolan-Moré performance
profiles, via `BenchmarkProfiles.jl`.
"""
module PerformanceProfiles

using BenchmarkProfiles
using Plots
using JuMP: MOI
using JLD2
using Printf
using Statistics

export build_performance_matrix, plot_pp, load_results, methods_present, scalability_performance_profiles,
       scalability_scaling_plot, scalability_scaling_profiles, scalability_table_by_n, scalability_table_by_kappa,
       degenerate_robustness_table, full_descent_performance_profiles

# Preferred legend order; any result set is filtered down to whichever of
# these actually appear (so this module doesn't error/misbehave if, say,
# Mosek wasn't licensed on the machine that produced a given results file).
const PREFERRED_METHOD_ORDER = ["Algorithm1", "Clarabel", "Mosek", "Gurobi", "IPOPT"]

# "Success" classification, mirroring PrimalSOCP.jl's _ACCEPTABLE_STATUSES
# (MOI.LOCALLY_SOLVED included: it's the normal success status for general
# QCP/NLP solvers like Ipopt, not just OPTIMAL/ALMOST_OPTIMAL) plus
# Algorithm 1's own Symbol-valued statuses.
const GOOD_ALGORITHM1_STATUSES = (:converged, :endpoint0, :endpoint1, :degenerate)
const GOOD_SOLVER_STATUSES = (MOI.OPTIMAL, MOI.ALMOST_OPTIMAL, MOI.LOCALLY_SOLVED)

is_success(status::Symbol) = status in GOOD_ALGORITHM1_STATUSES
is_success(status::MOI.TerminationStatusCode) = status in GOOD_SOLVER_STATUSES
# `status` round-tripped through a CSV file (see run_experiments.jl's
# `save_results`) comes back as a plain String, not a Symbol or
# MOI.TerminationStatusCode -- CSV.write stringifies both via `string(...)`,
# so compare against the same stringified good-status sets to recognize it.
is_success(status::AbstractString) =
    status in string.(GOOD_ALGORITHM1_STATUSES) || status in string.(GOOD_SOLVER_STATUSES)

"""
    build_performance_matrix(results, methods; problem_key) -> (T, methods)

`results` is a long-format result vector (one row per `(problem, method)`,
with `method`, `time`, `status` fields). `methods` is the ordered list of
method names to include. `problem_key` maps a row to a hashable problem
identifier (e.g. `r->(r.problem, r.start)` for the full-descent
experiments, `r->(r.n,r.κ,r.rep)` for the scalability experiments).

Returns `(T, methods)`, where `T[p,s]` is the elapsed `time` of method `s`
on problem `p` if that run succeeded (`is_success`), and `NaN` otherwise
(failure, or that pair missing from `results`) -- the convention expected
by `BenchmarkProfiles.performance_profile`.
"""
function build_performance_matrix(results, methods::Vector{String}; problem_key)
    problems = unique(problem_key(r) for r in results)
    T = fill(NaN, length(problems), length(methods))
    for r in results
        pi = findfirst(==(problem_key(r)), problems)
        si = findfirst(==(r.method), methods)
        (pi === nothing || si === nothing) && continue
        T[pi, si] = is_success(r.status) ? r.time : NaN
    end
    return T, methods
end

# Cosmetic display name for plot legends (plain text, not LaTeX -- Plots.jl's
# GR backend doesn't render "~"). "Algorithm1" -> "Algorithm 1"; other method
# names are passed through unchanged.
_plot_method_name(m::AbstractString) = m == "Algorithm1" ? "Algorithm 1" : m

# `plot_pp`'s verbose printout: T's rows normalized by their own minimum
# (ratio-to-best per problem), sorted by ascending second-smallest ratio
# (closest runner-up first). Recomputes `problems` (row identifiers) from
# `problem_key` directly rather than changing `build_performance_matrix`'s
# public `(T, methods)` return signature.
function _print_ratio_matrix(results, problem_key, T::Matrix{Float64}, labels::Vector{String})
    problems = unique(problem_key(r) for r in results)
    nrows = size(T, 1)

    rowmin = [let vals = filter(!isnan, view(T, i, :))
                  isempty(vals) ? NaN : minimum(vals)
              end for i in 1:nrows]
    R = T ./ rowmin

    function sortkey(i)
        vals = sort(filter(!isnan, R[i, :]))
        return length(vals) >= 2 ? vals[2] : (isempty(vals) ? Inf : vals[1])
    end
    order = sort(1:nrows; by=sortkey)

    println(@sprintf("%-30s", "instance"), join([@sprintf("%-10s", m) for m in labels]))
    for i in order
        row = [isnan(R[i, j]) ? "NaN" : @sprintf("%.3f", R[i, j]) for j in 1:size(R, 2)]
        println(@sprintf("%-30s", string(problems[i])), join([@sprintf("%-10s", x) for x in row]))
    end
    return nothing
end

"""
    plot_pp(results, methods, title, filename; problem_key, xlim=nothing, verbose=false)

Builds and saves (via `savefig`) a Dolan-Moré performance profile comparing
`methods` on `results` (long format -- see `build_performance_matrix`).

If `verbose=true`, also prints the ratio-to-best matrix to the console
(each row normalized by its own minimum, sorted by ascending
second-smallest ratio, i.e. closest runner-up first).
"""
function plot_pp(results, methods::Vector{String}, title::AbstractString, filename::AbstractString;
                  problem_key, xlim=nothing, verbose::Bool=true)
    gr()
    T, labels = build_performance_matrix(results, methods; problem_key=problem_key)

    verbose && _print_ratio_matrix(results, problem_key, T, labels)

    p = performance_profile(
        PlotsBackend(),
        T,
        _plot_method_name.(labels),
        title=title,
        legend=:bottomright, legendfontsize=12,
        linewidth=1.4,
        size=(500, 400),
    )

    xlim !== nothing && xlims!(p, xlim)

    savefig(p, filename)
    return p
end

"""
    load_results(path) -> Vector{<:NamedTuple}

Loads a long-format result vector saved by `run_experiments.jl`'s
`save_results` (a `.jld2` file, key `"results"`).
"""
load_results(path::AbstractString) = JLD2.load(path, "results")

"""
    methods_present(results) -> Vector{String}

Methods that actually appear in `results`, ordered per
`PREFERRED_METHOD_ORDER` (any method not in that list is appended at the
end, in first-seen order).
"""
function methods_present(results)
    found = unique(r.method for r in results)
    ordered = [m for m in PREFERRED_METHOD_ORDER if m in found]
    extra = [m for m in found if !(m in PREFERRED_METHOD_ORDER)]
    return vcat(ordered, extra)
end

"""
    scalability_performance_profiles(path; outdir=dirname(path), methods=nothing)

Loads a scalability-experiment results file (see `load_results`) and
produces performance profiles: one over all instances
(`scalability_profile_all.pdf`), plus one per distinct `κ` value present
(`scalability_profile_kappa_<κ>.pdf`) -- separating the effect of
conditioning from the effect of scale (`n`).

`methods` controls which methods are plotted and the legend order.
Defaults to `methods_present(results)` (`PREFERRED_METHOD_ORDER`). E.g.:

```julia
using NewtonBiObj
using .PerformanceProfiles
scalability_performance_profiles("scalability_results.jld2"; methods=["Algorithm1", "Mosek", "IPOPT", "Gurobi", "Clarabel"])
```
"""
function scalability_performance_profiles(path::AbstractString; outdir::AbstractString=dirname(path),
                                       methods::Union{Nothing,Vector{String}}=nothing)
    results = load_results(path)
    println("Loaded ", length(results), " rows from ", path)

    methods = methods === nothing ? methods_present(results) : methods
    println("Methods: ", join(methods, ", "))

    problem_key = r -> (r.n, r.κ, r.rep)

    plot_pp(results, methods, "",
            joinpath(outdir, "scalability_profile_all.pdf");
            problem_key=problem_key)
    println("Saved: scalability_profile_all.pdf")

    for κ in sort(unique(r.κ for r in results))
        subset = filter(r -> r.κ == κ, results)
        fname = joinpath(outdir, @sprintf("scalability_profile_kappa_%.0e.pdf", κ))
        plot_pp(subset, methods, @sprintf("κ=%.0e", κ), fname;
                problem_key=problem_key)
        println("Saved: ", basename(fname))
    end

    return nothing
end

"""
    full_descent_performance_profiles(path; outdir=dirname(path), methods=nothing)

Loads a full-descent-experiment results file (see `load_results`) and
produces a Dolan-Moré performance profile of *total* outer-loop wall-clock
time, one curve per subproblem solver, matched 1-1 per `(problem, start)`
instance: every method ran the same BFGS-Wolfe outer loop from the same
starting point, only the subproblem solver differs.
"""
function full_descent_performance_profiles(path::AbstractString; outdir::AbstractString=dirname(path),
                                       methods::Union{Nothing,Vector{String}}=nothing)
    results = load_results(path)
    println("Loaded ", length(results), " rows from ", path)

    methods = methods === nothing ? methods_present(results) : methods
    println("Methods: ", join(methods, ", "))

    problem_key = r -> (r.problem, r.start)

    plot_pp(results, methods, "",
            joinpath(outdir, "full_descent_profile_all.pdf");
            problem_key=problem_key)
    println("Saved: full_descent_profile_all.pdf")

    return nothing
end

"""
    scalability_scaling_plot(results, methods, κ, filename; title=nothing) -> plot

Builds and saves a log-log plot of median solve time vs. `n`, one line per
method, for a fixed `κ` subset of scalability-experiment results.
Complements the performance profiles (`plot_pp`), which show relative
ranking but not the growth rate with `n`. Only successful runs
(`is_success`) contribute to each median.
"""
function scalability_scaling_plot(results, methods::Vector{String}, κ, filename::AbstractString;
                               title::Union{Nothing,AbstractString}=nothing)
    gr()
    subset = filter(r -> r.κ == κ, results)
    ns = sort(unique(r.n for r in subset))

    p = plot(xscale=:log10, yscale=:log10,
             xlabel="n", ylabel="Median time (s)",
             title=title === nothing ? @sprintf("κ=%.0e", κ) : title,
             legend=:topleft, legendfontsize=10,
             linewidth=1.6, markershape=:circle, markersize=3,
             size=(500, 400))

    for m in methods
        pts_n = Int[]
        pts_t = Float64[]
        for n in ns
            times = [r.time for r in subset if r.n == n && r.method == m && is_success(r.status)]
            isempty(times) && continue
            push!(pts_n, n)
            push!(pts_t, median(times))
        end
        isempty(pts_n) && continue
        plot!(p, pts_n, pts_t, label=m)
    end

    savefig(p, filename)
    return p
end

"""
    scalability_scaling_profiles(path; outdir=dirname(path), methods=nothing)

Loads a scalability-experiment results file and produces one log-log
time-vs-n plot per distinct `κ` (`scalability_scaling_kappa_<κ>.pdf`) via
`scalability_scaling_plot`. Callable directly from the REPL, same
conventions as `scalability_performance_profiles` (`methods` controls
which methods/what order).
"""
function scalability_scaling_profiles(path::AbstractString; outdir::AbstractString=dirname(path),
                                   methods::Union{Nothing,Vector{String}}=nothing)
    results = load_results(path)
    methods = methods === nothing ? methods_present(results) : methods

    for κ in sort(unique(r.κ for r in results))
        fname = joinpath(outdir, @sprintf("scalability_scaling_kappa_%.0e.pdf", κ))
        scalability_scaling_plot(results, methods, κ, fname)
        println("Saved: ", basename(fname))
    end

    return nothing
end

# Formats x as "m × 10^e" LaTeX scientific notation, except for e ∈ {0,1,2}
# (1 ≤ |x| < 1000), printed as a plain decimal instead since scientific
# notation adds no readability there. `force_sci=true` always uses
# scientific form, for axis-style labels (τ, κ) shown as powers of ten.
function _latex_sci(x::Real; digits::Int=1, force_sci::Bool=false)
    x == 0 && return "0"
    e = floor(Int, log10(abs(x)))
    if !force_sci && e in (0, 1, 2)
        d = max(0, digits - e)
        val = round(x; digits=d)
        return d == 0 ? string(Int(val)) : string(val)
    end
    m = round(x / 10.0^e; digits=digits)
    return string(m) * " \\times 10^{" * string(Int(e)) * "}"
end

# Cosmetic LaTeX display name (e.g. "Algorithm1" -> "Algorithm~1" with a
# non-breaking space); other method names are passed through unchanged.
_latex_method_name(m::AbstractString) = m == "Algorithm1" ? "Algorithm~1" : m

# Shared by scalability_table_by_n/scalability_table_by_kappa: builds a
# "group × method" median-time LaTeX table. `groups` is a Vector of (label,
# label_str, cell_rows) triples, already in display order.
function _median_time_table(groups, header_label::AbstractString, methods::Vector{String};
                             console_header::AbstractString=header_label)
    println(@sprintf("%-10s", console_header), join([@sprintf("%-14s", m) for m in methods]))
    for (label, label_str, cell) in groups
        print(@sprintf("%-10s", label_str))
        for m in methods
            t = median([r.time for r in cell if r.method == m && is_success(r.status)])
            print(@sprintf("%-14.3e", t))
        end
        println()
    end

    lines = String[]
    push!(lines, "\\begin{tabular}{l" * "c"^length(methods) * "}")
    push!(lines, "\\toprule")
    push!(lines, header_label * " & " * join(_latex_method_name.(methods), " & ") * " \\\\")
    push!(lines, "\\midrule")
    for (label, label_str, cell) in groups
        tcells = [@sprintf("\$%s\$", _latex_sci(median([r.time for r in cell if r.method == m && is_success(r.status)])))
                  for m in methods]
        push!(lines, label_str * " & " * join(tcells, " & ") * " \\\\")
    end
    push!(lines, "\\bottomrule")
    push!(lines, "\\end{tabular}")
    return join(lines, "\n")
end

"""
    scalability_table_by_n(path; methods=nothing, outfile=nothing) -> String

Loads a scalability-experiment results file and builds an "n × method"
table of median CPU time, one row per `n`, aggregating over every `κ` and
`rep` present -- reasonable since conditioning barely affects absolute
time, so this isolates the dimension-scaling trend.

Prints a plain-text version to the console and returns a LaTeX `tabular`
string; also writes it to `outfile` (default: `scalability_table_by_n.tex`
next to `path`) unless `outfile=false`.
"""
function scalability_table_by_n(path::AbstractString; methods::Union{Nothing,Vector{String}}=nothing,
                             outfile::Union{Nothing,AbstractString,Bool}=nothing)
    results = load_results(path)
    methods = methods === nothing ? methods_present(results) : methods
    ns = sort(unique(r.n for r in results))
    groups = [(n, @sprintf("%d", n), filter(r -> r.n == n, results)) for n in ns]

    tex = _median_time_table(groups, "\$n\$", methods; console_header="n")

    if outfile !== false
        file = outfile isa AbstractString ? outfile : joinpath(dirname(path), "scalability_table_by_n.tex")
        write(file, tex)
        println("\nSaved LaTeX table to: ", file)
    end

    return tex
end

"""
    scalability_table_by_kappa(path; n=4000, methods=nothing, outfile=nothing) -> String

Loads a scalability-experiment results file and builds a "κ × method"
table of median CPU time at a single, fixed `n` (default `4000`, the
largest in the grid), one row per condition number `κ` (median over `rep`
only -- unlike `scalability_table_by_n`, no aggregation over `n`).

Prints a plain-text version to the console and returns a LaTeX `tabular`
string; also writes it to `outfile` (default:
`scalability_table_by_kappa_n<n>.tex` next to `path`) unless
`outfile=false`.
"""
function scalability_table_by_kappa(path::AbstractString; n::Int=4000,
                                 methods::Union{Nothing,Vector{String}}=nothing,
                                 outfile::Union{Nothing,AbstractString,Bool}=nothing)
    results = load_results(path)
    methods = methods === nothing ? methods_present(results) : methods
    subset = filter(r -> r.n == n, results)
    isempty(subset) && error("No rows with n=$n in $path")

    κs = sort(unique(r.κ for r in subset))
    groups = [(κ, "\$" * _latex_sci(κ; digits=0, force_sci=true) * "\$", filter(r -> r.κ == κ, subset)) for κ in κs]

    tex = _median_time_table(groups, "\$\\kappa\$", methods; console_header="kappa")

    if outfile !== false
        file = outfile isa AbstractString ? outfile : joinpath(dirname(path), "scalability_table_by_kappa_n$(n).tex")
        write(file, tex)
        println("\nSaved LaTeX table to: ", file)
    end

    return tex
end

"""
    degenerate_robustness_table(path; n=1000, methods=nothing, outfile=nothing) -> String

Loads a degenerate-robustness-experiment results file and builds a
"methods × τ" table for a single `n`, since the interesting axis here is
degeneracy depth (`τ`), not scale. Rows are `τ` (decreasing, i.e.
increasingly degenerate); columns are each method's median time across
`rep`s, plus the maximum `err_d`/`err_obj` among the primal solvers at
that `τ` (Algorithm 1 is the reference solution, so excluded from the
error columns).

Prints a plain-text version to the console and returns a LaTeX `tabular`
string; also writes that string to `outfile` (default:
`degenerate_robustness_table_n<n>.tex` next to `path`) unless `outfile=false`.
"""
function degenerate_robustness_table(path::AbstractString; n::Int=1000,
                        methods::Union{Nothing,Vector{String}}=nothing,
                        outfile::Union{Nothing,AbstractString,Bool}=nothing)
    results = load_results(path)
    methods = methods === nothing ? methods_present(results) : methods
    subset = filter(r -> r.n == n, results)
    isempty(subset) && error("No rows with n=$n in $path")

    τs = sort(unique(r.τ for r in subset); rev=true)
    error_methods = filter(!=("Algorithm1"), methods)

    rows = NamedTuple[]
    for τ in τs
        cell = filter(r -> r.τ == τ, subset)
        times = Dict(m => median([r.time for r in cell if r.method == m]) for m in methods)
        max_err_d   = maximum(r.err_d   for r in cell if r.method in error_methods)
        max_err_obj = maximum(r.err_obj for r in cell if r.method in error_methods)
        push!(rows, (τ=τ, times=times, max_err_d=max_err_d, max_err_obj=max_err_obj))
    end

    # Plain-text console table.
    println(@sprintf("%-10s", "τ"), join([@sprintf("%-14s", m) for m in methods]),
            @sprintf("%-12s%-12s", "max err_d", "max err_t"))
    for row in rows
        print(@sprintf("%-10.0e", row.τ))
        for m in methods
            print(@sprintf("%-14.3e", row.times[m]))
        end
        println(@sprintf("%-12.1e%-12.1e", row.max_err_d, row.max_err_obj))
    end

    # LaTeX tabular.
    lines = String[]
    push!(lines, "\\begin{tabular}{l" * "c"^length(methods) * "cc}")
    push!(lines, "\\toprule")
    push!(lines, "\$\\tau\$ & " * join(_latex_method_name.(methods), " & ") *
                 " & max \$\\mathrm{err}_d\$ & max \$\\mathrm{err}_t\$ \\\\")
    push!(lines, "\\midrule")
    for row in rows
        τstr = row.τ == 0 ? "0" : _latex_sci(row.τ; digits=0, force_sci=true)
        tcells = [@sprintf("\$%s\$", _latex_sci(row.times[m])) for m in methods]
        push!(lines, "\$" * τstr * "\$ & " * join(tcells, " & ") * " & \$" *
                     _latex_sci(row.max_err_d) * "\$ & \$" * _latex_sci(row.max_err_obj) * "\$ \\\\")
    end
    push!(lines, "\\bottomrule")
    push!(lines, "\\end{tabular}")
    tex = join(lines, "\n")

    if outfile !== false
        file = outfile isa AbstractString ? outfile : joinpath(dirname(path), "degenerate_robustness_table_n$(n).tex")
        write(file, tex)
        println("\nSaved LaTeX table to: ", file)
    end

    return tex
end

end # module
