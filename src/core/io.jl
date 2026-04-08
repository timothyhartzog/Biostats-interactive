"""
    summarize_delimited(path::AbstractString; value_col::Union{Int,AbstractString}, group_col::Union{Nothing,Int,AbstractString}=nothing, delim::Char=',')

Summarize numeric values from a delimited text file using either a column index or a header name.

When `group_col` is provided, returns grouped summaries via [`summarize_by_group`](@ref). Otherwise, returns a single [`SummaryStats`](@ref).

# Notes
- The first row is treated as header metadata.
- Empty cells in value/group columns are interpreted as `missing`.
"""
function summarize_delimited(
    path::AbstractString;
    value_col::Union{Int, AbstractString},
    group_col::Union{Nothing, Int, AbstractString}=nothing,
    delim::Char=',',
)
    rows = readlines(path)
    isempty(rows) && throw(ArgumentError("input file is empty"))

    header = split(rows[1], delim)
    value_ix = _resolve_column_index(value_col, header)
    group_ix = isnothing(group_col) ? nothing : _resolve_column_index(group_col, header)

    values = Union{Missing, Float64}[]
    groups = Union{Missing, String}[]

    for line in rows[2:end]
        isempty(strip(line)) && continue
        cols = split(line, delim)
        length(cols) < value_ix && throw(ArgumentError("row does not include requested value column index $(value_ix)"))

        value_raw = strip(cols[value_ix])
        value = isempty(value_raw) ? missing : _parse_numeric_or_throw(value_raw)
        push!(values, value)

        if !isnothing(group_ix)
            length(cols) < group_ix && throw(ArgumentError("row does not include requested group column index $(group_ix)"))
            group_raw = strip(cols[group_ix])
            push!(groups, isempty(group_raw) ? missing : group_raw)
        end
    end

    return isnothing(group_ix) ? summarize_numeric(values) : summarize_by_group(values, groups)
end

function _resolve_column_index(selector::Int, header::Vector{SubString{String}})::Int
    selector >= 1 || throw(ArgumentError("column index must be >= 1"))
    selector <= length(header) || throw(ArgumentError("column index $(selector) out of bounds for $(length(header)) columns"))
    return selector
end

function _resolve_column_index(selector::AbstractString, header::Vector{SubString{String}})::Int
    idx = findfirst(==(selector), header)
    isnothing(idx) && throw(ArgumentError("column name '$(selector)' not found in header"))
    return idx
end

function _parse_numeric_or_throw(text::AbstractString)::Float64
    parsed = tryparse(Float64, text)
    isnothing(parsed) && throw(ArgumentError("unable to parse numeric value: '$(text)'"))
    return parsed
end
