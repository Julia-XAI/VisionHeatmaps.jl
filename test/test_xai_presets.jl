using VisionHeatmaps
using ImageCore
using Test
using ReferenceTests

using XAIBase: Explanation, AbstractXAIMethod, AbstractOutputSelector
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
    return Explanation(val, input, output, output_selection, :Dummy, :sensitivity)
end

output_selection = [[CartesianIndex(1, 2)]] # irrelevant
img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]

@testset "Heatmapping presets" begin
    shape = (2, 4, 3, 1)
    val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)

    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :attribution)
    h = only(heatmap(expl))
    @test size(h) == (4, 2)
    @test_reference "references/attribution.txt" h

    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :sensitivity)
    h = only(heatmap(expl))
    @test size(h) == (4, 2)
    @test_reference "references/sensitivity.txt" h

    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :cam)
    h = only(heatmap(expl))
    @test size(h) == (4, 2)
    @test_reference "references/cam.txt" h

    @testset "Singleton color channel" begin
        shape = (2, 4, 1, 1)
        val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)

        expl = Explanation(
            val, input, output, output_selection, :DummyAnalyzer, :attribution
        )
        h = only(heatmap(expl))
        @test size(h) == (4, 2)

        expl = Explanation(
            val, input, output, output_selection, :DummyAnalyzer, :sensitivity
        )
        h = only(heatmap(expl))
        @test size(h) == (4, 2)

        expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :cam)
        h = only(heatmap(expl))
        @test size(h) == (4, 2)
    end
end

@testset "Overlay presets" begin
    shape = (2, 2, 3, 1)
    val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)
    output_selection = [[CartesianIndex(1, 2)]] # irrelevant

    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :attribution)
    ho = heatmap(expl, img)
    @test_reference "references/overlay/attribution.txt" only(ho)
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :sensitivity)
    ho = heatmap(expl, img)
    @test_reference "references/overlay/sensitivity.txt" only(ho)
    expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :cam)
    ho = heatmap(expl, img)
    @test_reference "references/overlay/cam.txt" only(ho)
end

@testset "Batched input" begin
    val = output = input = reshape(1.0:(2.0^4), 2, 2, 2, 2)
    output_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
    expl_batch = Explanation(
        val, input, output, output_selection, :DummyAnalyzer, :sensitivity
    )

    h1 = heatmap(expl_batch)
    @test_reference "references/process_batch_false.txt" h1
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
