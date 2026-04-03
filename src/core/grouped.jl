"""
    summarize_by_group(values::AbstractVector{<:Union{Missing, Real}}, groups::AbstractVector) -> Dict{String, SummaryStats}

Compute per-group descriptive summary statistics, ignoring rows where either value or group is `missing`.

# Arguments
- `values`: numeric observations.
- `groups`: grouping labels aligned with `values` by index.

# Returns
A `Dict{String, SummaryStats}` keyed by group label.

# Errors
- Throws `ArgumentError` if `values` and `groups` lengths differ.
- Throws `ArgumentError` if no valid (non-missing value and group) rows are available.

# Examples
```jldoctest
julia> using BiostatsInteractive

julia> out = summarize_by_group([1, 2, missing, 3], ["A", "A", "B", "B"]);

julia> out["A"].n
2
```
"""
function summarize_by_group(
    values::AbstractVector{<:Union{Missing, Real}},
    groups::AbstractVector,
)::Dict{String, SummaryStats}
    length(values) == length(groups) || throw(ArgumentError("values and groups must have the same length"))

    grouped = Dict{String, Vector{Float64}}()

    for (v, g) in zip(values, groups)
        (ismissing(v) || ismissing(g)) && continue
        key = string(g)
        bucket = get!(grouped, key, Float64[])
        push!(bucket, Float64(v))
    end

    isempty(grouped) && throw(ArgumentError("no non-missing value/group rows available"))

    return Dict(k => summarize_numeric(v) for (k, v) in grouped)
end
