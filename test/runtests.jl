using VisionHeatmaps
using ColorSchemes

using Test
using ReferenceTests

@testset "VisionHeatmaps.jl" begin
    @testset verbose = true "Linting" begin
        @info "Running linting tests..."
        include("linting.jl")
    end
    @testset "Heatmap" begin
        @info "Testing heatmaps..."
        include("test_heatmap.jl")
    end
    @testset "XAIBase Attributions" begin
        @info "Testing heatmaps on XAIBase attributions..."
        include("test_xai_presets.jl")
    end
end
