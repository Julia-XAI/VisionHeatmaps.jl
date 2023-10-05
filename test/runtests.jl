using VisionHeatmaps
using Test
using Aqua

@testset "VisionHeatmaps.jl" begin
    @testset "Code quality (Aqua.jl)" begin
        Aqua.test_all(VisionHeatmaps)
    end
    # Write your tests here.
end
