using Test
using BiostatsInteractive

@testset "summarize_numeric" begin
    stats = summarize_numeric([1, 2, missing, 4])
    @test stats.n == 3
    @test isapprox(stats.mean, 7 / 3; atol=1e-12)
    @test isapprox(stats.std, sqrt(7 / 3); atol=1e-12)
    @test stats.minimum == 1.0
    @test stats.median == 2.0
    @test stats.maximum == 4.0

    singleton = summarize_numeric([missing, 10])
    @test singleton.n == 1
    @test singleton.std == 0.0

    @test_throws ArgumentError summarize_numeric([missing, missing])
end

@testset "render_summary_table" begin
    stats = summarize_numeric([1, 2, 3])
    table = render_summary_table(stats; digits=2)

    @test occursin("count\t3", table)
    @test occursin("mean\t2.00", table)
    @test occursin("max\t3.00", table)

    @test_throws ArgumentError render_summary_table(stats; digits=-1)
end


@testset "grouped summaries" begin
    out = summarize_by_group([1, 2, missing, 3, 5], ["A", "A", "B", "B", "B"])
    @test sort(collect(keys(out))) == ["A", "B"]
    @test out["A"].n == 2
    @test out["B"].n == 2
    @test isapprox(out["B"].mean, 4.0; atol=1e-12)

    table = render_group_summary_table(out; digits=2)
    @test startswith(table, "group\tcount\tmean\tstd\tmin\tmedian\tmax")
    @test occursin("A\t2\t1.50", table)
    @test occursin("B\t2\t4.00", table)

    @test_throws ArgumentError summarize_by_group([1, 2], ["A"])
    @test_throws ArgumentError summarize_by_group([missing], [missing])
    @test_throws ArgumentError render_group_summary_table(Dict{String,SummaryStats}())
end


@testset "summarize_delimited" begin
    tmp = tempname()
    write(tmp, "id,arm,response\n1,control,10\n2,control,20\n3,treated,40\n4,treated,\n")

    single = summarize_delimited(tmp; value_col="response")
    @test single.n == 3
    @test isapprox(single.mean, 70/3; atol=1e-12)

    grouped = summarize_delimited(tmp; value_col="response", group_col="arm")
    @test grouped["control"].n == 2
    @test grouped["treated"].n == 1

    bad = tempname()
    write(bad, "id,val\n1,abc\n")
    @test_throws ArgumentError summarize_delimited(bad; value_col="val")

    @test_throws ArgumentError summarize_delimited(tmp; value_col="missing_col")
end


@testset "group mean comparisons" begin
    cmp = compare_group_means([10, 20, 30, 40], ["control", "control", "treated", "treated"]; reference="control")
    @test haskey(cmp, "treated")
    @test cmp["treated"].n_group == 2
    @test cmp["treated"].n_reference == 2
    @test isapprox(cmp["treated"].mean_difference, 20.0; atol=1e-12)

    table = render_mean_comparison_table(cmp; digits=1)
    @test startswith(table, "group\treference\tn_group")
    @test occursin("treated\tcontrol\t2\t2\t35.0\t15.0\t20.0", table)

    @test_throws ArgumentError compare_group_means([1, 2], ["A", "A"]; reference="A")
    @test_throws ArgumentError compare_group_means([1, 2], ["A", "B"]; reference="Z")
    @test_throws ArgumentError render_mean_comparison_table(Dict{String,MeanComparisonStats}())
end
