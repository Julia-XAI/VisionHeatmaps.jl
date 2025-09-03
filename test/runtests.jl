using VisionHeatmaps
using ColorSchemes

using Test
using ReferenceTests
using Aqua
using JET

@testset "VisionHeatmaps.jl" begin
    @testset verbose = true "Linting" begin
        @info "Running linting tests..."
        @testset "Aqua.jl" begin
            @info "...Aqua.jl's auto quality assurance tests. These might print warnings from dependencies."
            Aqua.test_all(VisionHeatmaps)
        end
        @testset "JET.jl" begin
            @info "...running JET.jl type stability tests."
            JET.test_package(VisionHeatmaps; target_defined_modules = true)
        end
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
