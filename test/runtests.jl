using VisionHeatmaps
using ColorSchemes

using Test
using ReferenceTests
using Aqua
using JuliaFormatter

@testset "VisionHeatmaps.jl" begin
    @testset "Aqua.jl" begin
        @info "Running Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
        Aqua.test_all(VisionHeatmaps)
    end
    @testset "JuliaFormatter.jl" begin
        @info "Running JuliaFormatter's code formatting tests."
        @test format(VisionHeatmaps; verbose=false, overwrite=false)
    end
    @testset "Heatmap" begin
        @info "Testing heatmaps..."
        include("test_heatmap.jl")
    end
    @testset "XAIBase extension" begin
        @info "Testing heatmaps on XAIBase explanations..."
        include("test_xaibase_ext.jl")
    end
end
