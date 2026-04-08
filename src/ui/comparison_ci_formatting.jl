"""
    render_mean_comparison_ci_table(comparisons::AbstractDict{<:AbstractString, MeanComparisonCIStats}; digits::Integer=3) -> String

Render a deterministic plain-text table for group-vs-reference mean comparisons with confidence intervals.
"""
function render_mean_comparison_ci_table(
    comparisons::AbstractDict{<:AbstractString, MeanComparisonCIStats};
    digits::Integer=3,
)::String
    digits < 0 && throw(ArgumentError("digits must be non-negative"))
    isempty(comparisons) && throw(ArgumentError("comparisons must not be empty"))

    io = IOBuffer()
    fmt = string("%.", digits, "f")

    println(io, "group\treference\tn_group\tn_reference\tmean_difference\tstd_error\tci_lower\tci_upper")
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
            Printf.@sprintf(fmt, c.mean_difference),
            "\t",
            Printf.@sprintf(fmt, c.std_error),
            "\t",
            Printf.@sprintf(fmt, c.ci_lower),
            "\t",
            Printf.@sprintf(fmt, c.ci_upper),
        )
    end

    return rstrip(String(take!(io)), '\n')
end
