"""
    MeanComparisonStats

Summary of a group's mean relative to a reference group.

# Fields
- `group::String`: target group label.
- `reference::String`: reference group label.
- `n_group::Int`: non-missing count in target group.
- `n_reference::Int`: non-missing count in reference group.
- `mean_group::Float64`: mean for target group.
- `mean_reference::Float64`: mean for reference group.
- `mean_difference::Float64`: `mean_group - mean_reference`.
"""
Base.@kwdef struct MeanComparisonStats
    group::String
    reference::String
    n_group::Int
    n_reference::Int
    mean_group::Float64
    mean_reference::Float64
    mean_difference::Float64
end

"""
    compare_group_means(values::AbstractVector{<:Union{Missing, Real}}, groups::AbstractVector; reference::AbstractString) -> Dict{String, MeanComparisonStats}

Compute per-group mean differences versus a reference group.

Rows with missing value or missing group are excluded using the same semantics as [`summarize_by_group`](@ref).
"""
function compare_group_means(
    values::AbstractVector{<:Union{Missing, Real}},
    groups::AbstractVector;
    reference::AbstractString,
)::Dict{String, MeanComparisonStats}
    grouped = summarize_by_group(values, groups)
    haskey(grouped, reference) || throw(ArgumentError("reference group '$(reference)' not found"))
    length(grouped) > 1 || throw(ArgumentError("at least two groups are required for comparison"))

    ref = grouped[reference]
    out = Dict{String, MeanComparisonStats}()
    for (group, stats) in grouped
        group == reference && continue
        out[group] = MeanComparisonStats(
            group=group,
            reference=reference,
            n_group=stats.n,
            n_reference=ref.n,
            mean_group=stats.mean,
            mean_reference=ref.mean,
            mean_difference=stats.mean - ref.mean,
        )
    end

    return out
end
