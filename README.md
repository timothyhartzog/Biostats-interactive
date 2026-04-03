# Biostats Interactive

`BiostatsInteractive.jl` is a lightweight Julia package for common descriptive-statistics workflows with a stable, explicit API surface.

## Installation (local development)

```julia
julia> ]
pkg> activate .
pkg> test
```

## Public API

- `summarize_numeric(values) -> SummaryStats`
- `render_summary_table(stats; digits=3) -> String`

## Example

```julia
using BiostatsInteractive

stats = summarize_numeric([1.0, 2.0, missing, 4.0])
println(render_summary_table(stats; digits=2))
```

Expected output (digits=2) preserves fixed decimal precision:

```text
count	3
mean	2.33
std	1.53
min	1.00
median	2.00
max	4.00
```
