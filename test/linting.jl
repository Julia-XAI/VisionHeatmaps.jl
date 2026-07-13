# Shared code-quality (Aqua.jl), type-stability (JET.jl) and import-hygiene
# (ExplicitImports.jl) checks.
# Kept consistent across the Julia-XAI packages — see REFACTOR.md.
using VisionHeatmaps
using Test
using Aqua
using JET
using ExplicitImports

@testset "Aqua.jl" begin
    @info "Running Aqua.jl code-quality tests. These might print warnings from dependencies."
    Aqua.test_all(VisionHeatmaps; ambiguities = false)
    Aqua.test_ambiguities(VisionHeatmaps)
end

@testset "ExplicitImports.jl" begin
    @info "Running ExplicitImports.jl import-hygiene tests."
    @test check_no_stale_explicit_imports(VisionHeatmaps) === nothing
    @test check_all_explicit_imports_via_owners(VisionHeatmaps) === nothing
    @test check_all_qualified_accesses_via_owners(VisionHeatmaps) === nothing
    @test check_no_self_qualified_accesses(VisionHeatmaps) === nothing
end

# JET's v0.11 series supports Julia v1.12 and above only.
if VERSION >= v"1.12"
    @testset "JET.jl" begin
        @info "Running JET.jl type-stability tests."
        JET.test_package(VisionHeatmaps; target_defined_modules = true)
    end
end
