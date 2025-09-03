using VisionHeatmaps
using ColorSchemes

using Test
using ReferenceTests
using Aqua

@testset "VisionHeatmaps.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(VisionHeatmaps)
    end
    @testset "Heatmap" begin
        @info "Testing heatmaps..."
        include("test_heatmap.jl")
    end
    @testset "XAIBase Explanations" begin
        @info "Testing heatmaps on XAIBase explanations..."
        include("test_xai_presets.jl")
    end
end
