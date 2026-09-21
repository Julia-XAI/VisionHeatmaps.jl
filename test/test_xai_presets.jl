using VisionHeatmaps
using VisionHeatmaps: default_pipeline
using ImageCore
using Test
using ReferenceTests

using XAIBase: Attribution, AbstractXAIMethod, AbstractOutputSelector
import XAIBase: call_analyzer

struct DummyAnalyzer <: AbstractXAIMethod end
function call_analyzer(
        input, ::DummyAnalyzer, output_selector::AbstractOutputSelector; kwargs...
    )
    batchsize = last(size(input))
    output = reshape(input, :, batchsize)
    output_selection = output_selector(output)
    batchsize = size(input)[end]
    v = reshape(output[output_selection], :, batchsize)
    val = input .* v
    return Attribution(val, input, output, output_selection, NormPooling())
end

output_selection = [[CartesianIndex(1, 2)]] # irrelevant
img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]

@testset "Heatmapping presets" begin
    shape = (2, 4, 3, 1)
    val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)

    attr = Attribution(val, input, output, output_selection, SumPooling())
    @test default_pipeline(attr) ==
        SumPooling() |> CenteredNormalization() |> Colormap(:berlin) |> FlipImage()
    h = only(heatmap(attr))
    @test size(h) == (4, 2)
    @test_reference "references/attribution.txt" h

    attr = Attribution(val, input, output, output_selection, NormPooling())
    @test default_pipeline(attr) ==
        NormPooling() |> ExtremaNormalization() |> Colormap(:batlow) |> FlipImage()
    h = only(heatmap(attr))
    @test size(h) == (4, 2)
    @test_reference "references/sensitivity.txt" h

    # Grad-CAM-like attributions are already reduced to a single, non-negative channel
    shape = (2, 4, 1, 1)
    val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)
    attr = Attribution(val, input, output, output_selection, UnsignedNoPooling())
    @test default_pipeline(attr) ==
        UnsignedNoPooling() |> ExtremaNormalization() |> Colormap(:batlow) |> FlipImage()
    h = only(heatmap(attr))
    @test size(h) == (4, 2)
    @test_reference "references/cam.txt" h

    @testset "Singleton color channel" begin
        for pooling in (SumPooling(), NormPooling(), SignedNoPooling(), UnsignedNoPooling())
            attr = Attribution(val, input, output, output_selection, pooling)
            h = only(heatmap(attr))
            @test size(h) == (4, 2)
        end
    end
end

@testset "Presets with images" begin
    shape = (2, 2, 3, 1)
    val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)

    # Default pipelines don't overlay heatmaps onto images
    attr = Attribution(val, input, output, output_selection, SumPooling())
    @test heatmap(attr, img) == heatmap(attr)
    @test_reference "references/overlay/attribution.txt" only(heatmap(attr, img))
    attr = Attribution(val, input, output, output_selection, NormPooling())
    @test heatmap(attr, img) == heatmap(attr)
    @test_reference "references/overlay/sensitivity.txt" only(heatmap(attr, img))
end

@testset "Batched input" begin
    val = output = input = reshape(1.0:(2.0^4), 2, 2, 2, 2)
    output_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
    attr_batch = Attribution(val, input, output, output_selection, NormPooling())

    h1 = heatmap(attr_batch)
    @test_reference "references/process_batch_false.txt" h1
end

@testset "Direct Analyzer call" begin
    analyzer = DummyAnalyzer()
    input = reshape([1 6 2 5 3 4], 2, 3, 1, 1)
    attr = analyzer(input)

    h1 = heatmap(attr)
    h2 = heatmap(input, analyzer)
    @test h1 ≈ h2
end
