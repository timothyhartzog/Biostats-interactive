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
    @test occursin("mean\t2.0", table)
    @test occursin("max\t3.0", table)

    @test_throws ArgumentError render_summary_table(stats; digits=-1)
end
