"""
    render_group_summary_table(group_stats::AbstractDict{<:AbstractString, SummaryStats}; digits::Integer=3) -> String

Render a deterministic plain-text table of grouped summary statistics.

Rows are sorted lexicographically by group label.
"""
function render_group_summary_table(
    group_stats::AbstractDict{<:AbstractString, SummaryStats};
    digits::Integer=3,
)::String
    digits < 0 && throw(ArgumentError("digits must be non-negative"))
    isempty(group_stats) && throw(ArgumentError("group_stats must not be empty"))

    io = IOBuffer()
    fmt = string("%.", digits, "f")

    println(io, "group\tcount\tmean\tstd\tmin\tmedian\tmax")
    for group in sort!(collect(keys(group_stats)))
        stats = group_stats[group]
        println(
            io,
            group,
            "\t",
            stats.n,
            "\t",
            Printf.@sprintf(fmt, stats.mean),
            "\t",
            Printf.@sprintf(fmt, stats.std),
            "\t",
            Printf.@sprintf(fmt, stats.minimum),
            "\t",
            Printf.@sprintf(fmt, stats.median),
            "\t",
            Printf.@sprintf(fmt, stats.maximum),
        )
    end

    return rstrip(String(take!(io)), '\n')
end
