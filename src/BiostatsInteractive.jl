"""
    module BiostatsInteractive

Public package entrypoint for interactive biostatistics utilities.

# Exports
- [`summarize_numeric`](@ref): compute robust summary statistics for numeric vectors.
- [`render_summary_table`](@ref): render a plain-text summary table for human-readable output.
"""
module BiostatsInteractive

using Printf

include("core/statistics.jl")
include("ui/formatting.jl")

export SummaryStats, summarize_numeric, render_summary_table

end # module BiostatsInteractive
