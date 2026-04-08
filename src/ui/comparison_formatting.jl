"""
    render_mean_comparison_table(comparisons::AbstractDict{<:AbstractString, MeanComparisonStats}; digits::Integer=3) -> String

Render a deterministic plain-text table for group-vs-reference mean comparisons.
"""
function render_mean_comparison_table(
    comparisons::AbstractDict{<:AbstractString, MeanComparisonStats};
    digits::Integer=3,
)::String
    digits < 0 && throw(ArgumentError("digits must be non-negative"))
    isempty(comparisons) && throw(ArgumentError("comparisons must not be empty"))

    io = IOBuffer()
    fmt = string("%.", digits, "f")

    println(io, "group\treference\tn_group\tn_reference\tmean_group\tmean_reference\tmean_difference")
    for group in sort!(collect(keys(comparisons)))
        c = comparisons[group]
        println(
            io,
            c.group,
            "\t",
            c.reference,
            "\t",
            c.n_group,
            "\t",
            c.n_reference,
            "\t",
            Printf.@sprintf(fmt, c.mean_group),
            "\t",
            Printf.@sprintf(fmt, c.mean_reference),
            "\t",
            Printf.@sprintf(fmt, c.mean_difference),
        )
    end

    return rstrip(String(take!(io)), '\n')
end
