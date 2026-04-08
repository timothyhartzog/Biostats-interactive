"""
    MeanComparisonCIStats

Mean-difference summary versus a reference group with an approximate Wald-style confidence interval.

# Fields
- `group::String`
- `reference::String`
- `n_group::Int`
- `n_reference::Int`
- `mean_group::Float64`
- `mean_reference::Float64`
- `mean_difference::Float64`
- `std_error::Float64`
- `ci_lower::Float64`
- `ci_upper::Float64`
"""
Base.@kwdef struct MeanComparisonCIStats
    group::String
    reference::String
    n_group::Int
    n_reference::Int
    mean_group::Float64
    mean_reference::Float64
    mean_difference::Float64
    std_error::Float64
    ci_lower::Float64
    ci_upper::Float64
end

"""
    compare_group_means_ci(values::AbstractVector{<:Union{Missing, Real}}, groups::AbstractVector; reference::AbstractString, z::Real=1.96) -> Dict{String, MeanComparisonCIStats}

Compute group-vs-reference mean differences with approximate confidence intervals.

The interval is `mean_difference ± z * std_error`, where
`std_error = sqrt((sd_group^2 / n_group) + (sd_ref^2 / n_ref))`.

# Notes
- Missing value/group rows are dropped using [`summarize_by_group`](@ref) semantics.
- This function uses a normal approximation and is intended as a lightweight descriptive estimate.
"""
function compare_group_means_ci(
    values::AbstractVector{<:Union{Missing, Real}},
    groups::AbstractVector;
    reference::AbstractString,
    z::Real=1.96,
)::Dict{String, MeanComparisonCIStats}
    z > 0 || throw(ArgumentError("z must be > 0"))

    grouped = summarize_by_group(values, groups)
    haskey(grouped, reference) || throw(ArgumentError("reference group '$(reference)' not found"))
    length(grouped) > 1 || throw(ArgumentError("at least two groups are required for comparison"))

    ref = grouped[reference]
    out = Dict{String, MeanComparisonCIStats}()

    for (group, stats) in grouped
        group == reference && continue

        se = sqrt((stats.std^2 / stats.n) + (ref.std^2 / ref.n))
        diff = stats.mean - ref.mean

        out[group] = MeanComparisonCIStats(
            group=group,
            reference=reference,
            n_group=stats.n,
            n_reference=ref.n,
            mean_group=stats.mean,
            mean_reference=ref.mean,
            mean_difference=diff,
            std_error=se,
            ci_lower=diff - Float64(z) * se,
            ci_upper=diff + Float64(z) * se,
        )
    end

    return out
end
