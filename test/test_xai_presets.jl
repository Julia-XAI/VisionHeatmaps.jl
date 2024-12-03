using XAIBase
using Test

using XAIBase: AbstractXAIMethod
import XAIBase: call_analyzer

struct DummyAnalyzer <: AbstractXAIMethod end
function call_analyzer(
    input, ::DummyAnalyzer, output_selector::AbstractOutputSelector; kwargs...
)
    output = input
    output_selection = output_selector(output)
    batchsize = size(input)[end]
    v = reshape(output[output_selection], :, batchsize)
    val = input .* v
    return Explanation(val, input, output, output_selection, :Dummy, :attribution)
end

shape = (2, 2, 3, 1)
val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)
output_selection = [[CartesianIndex(1, 2)]] # irrelevant
img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]

@testset "Heatmapping presets" begin
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :attribution)
    h = heatmap(expl)
    @test_reference "references/seismic_sum_centered.txt" h
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :sensitivity)
    h = heatmap(expl)
    @test_reference "references/grays_norm_extrema.txt" h
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :cam)
    h = heatmap(expl)
    @test_reference "references/jet_sum_extrema.txt" h
end

@testset "Overlay presets" begin
    shape = (2, 2, 3, 1)
    val = output = reshape(collect(Float32, 1:prod(shape)), shape)
    output_selection = [[CartesianIndex(1, 2)]] # irrelevant

    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :attribution)
    ho = heatmap_overlay(expl, img)
    @test_reference "references/overlay/seismic_sum_centered.txt" ho
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :sensitivity)
    ho = heatmap_overlay(expl, img)
    @test_reference "references/overlay/grays_norm_extrema.txt" ho
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :cam)
    ho = heatmap_overlay(expl, img)
    @test_reference "references/overlay/jet_sum_extrema.txt" ho
end

@testset "Batched input" begin
    val = output = reshape(1:(2^4), 2, 2, 2, 2)
    output_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
    expl_batch = Explanation(val, input, output, output_selection, :LRP, :attribution)

    h1 = heatmap(expl_batch)
    h2 = heatmap(expl_batch; process_batch=true)
    @test_reference "references/process_batch_false.txt" h1
    @test_reference "references/process_batch_true.txt" h2
end

@testset "Direct Analyzer call" begin
    analyzer = DummyAnalyzer()
    input = reshape([1 6 2 5 3 4], 2, 3, 1, 1)
    val = reshape([3 36 6 30 9 24], 2, 3, 1, 1) # Explanation for max activation
    expl = analyzer(input)

    h1 = heatmap(expl)
    h2 = heatmap(input, analyzer)
    @test h1 ≈ h2
end
