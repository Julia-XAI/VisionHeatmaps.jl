using VisionHeatmaps
using XAIBase
using ImageCore
using ColorSchemes

using Test
using ReferenceTests

shape = (2, 2, 3, 1)
A = reshape(collect(Float32, 1:prod(shape)), shape)
val = output = input = reshape(collect(Float32, 1:prod(shape)), shape)
output_selection = [[CartesianIndex(1, 2)]] # irrelevant
expl = Explanation(val, input, output, output_selection, :DummyAnalyzer, :attribution)

shape = (2, 2, 3, 2)
batch = reshape(collect(Float32, 1:prod(shape)), shape)

img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]
img2 = [RGB(x, y, 0) for x in 0:0.2:1, y in 0:0.2:1]

rangscale2transform = Dict(:extrema => SequentialColormap, :centered => DivergentColormap)
reducer2transform = Dict(
    :sum    => SumReduction,
    :maxabs => MaxAbsReduction,
    :norm   => NormReduction,
    :sumabs => SumAbsReduction,
    :abssum => AbsSumReduction,
)

colorschemes = [:seismic, :viridis, :jet]
reducers = [:sum, :maxabs, :norm, :sumabs, :abssum]
rangescales = [:extrema, :centered]

@testset "Single input" begin
    for colorscheme in colorschemes
        for reducer in reducers
            for rangescale in rangescales
                Reduction = reducer2transform[reducer]
                Colormap = rangscale2transform[rangescale]
                pipe = Reduction() |> Colormap(colorscheme) |> FlipWH()
                h = heatmap(A, pipe)
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" h
                h = heatmap(expl, pipe)
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" h
                hs = heatmap(A, pipe; unpack_singleton=false)
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" hs[1]

                # Overlay
                pipe =
                    Reduction() |>
                    Colormap(colorscheme) |>
                    FlipWH() |>
                    ResizeToImage() |>
                    AlphaOverlay()
                ho = heatmap_overlay(A, img, pipe)
                @test size(ho) == size(img)
                @test_reference "references/overlay/$(colorscheme)_$(reducer)_$(rangescale).txt" ho
                ho = heatmap_overlay(expl, img, pipe)
                @test size(ho) == size(img)
                @test_reference "references/overlay/$(colorscheme)_$(reducer)_$(rangescale).txt" ho
            end
        end
    end
end
@testset "Overlay rescaling" begin
    for colorscheme in colorschemes
        for reducer in reducers
            for rangescale in rangescales
                Reduction = reducer2transform[reducer]
                Colormap = rangscale2transform[rangescale]
                pipe =
                    Reduction() |>
                    Colormap(colorscheme) |>
                    FlipWH() |>
                    ResizeToImage() |>
                    AlphaOverlay()
                ho = heatmap_overlay(A, img, pipe)
                @test size(ho) == size(img2)
                @test_reference "references/overlay_rescaled/$(colorscheme)_$(reducer)_$(rangescale).txt" ho
            end
        end
    end
end

@testset "Batched input" begin
    for reducer in reducers
        for rangescale in rangescales
            Reduction = reducer2transform[reducer]
            Colormap = rangscale2transform[rangescale]
            pipe =
                Reduction() |>
                Colormap(:viridis) |>
                FlipWH() |>
                ResizeToImage() |>
                AlphaOverlay()

            h = heatmap(batch, pipe)
            @test_reference "references/heatmap/viridis_$(reducer)_$(rangescale).txt" h[1]
            @test_reference "references/heatmap/viridis_$(reducer)_$(rangescale)_2.txt" h[2]
        end
    end
end

@testset "ColorSchemes" begin
    pipe = NormReduction() |> SequentialColormap(:inferno) |> FlipWH()
    h = heatmap(A, pipe)
    @test_reference "references/heatmap/inferno_norm_extrema.txt" h

    pipe =
        SumReduction() |>
        DivergentColormap(:inferno) |>
        FlipWH() |>
        ResizeToImage() |>
        AlphaOverlay()
    ho = heatmap(A, img, pipe)
    @test_reference "references/overlay/inferno_sum_centered.txt" ho
end

@testset "Error handling" begin
    @test_throws ArgumentError AlphaOverlay(2)
    @test_throws ArgumentError AlphaOverlay(-1)

    B = reshape(A, 2, 2, 3, 1, 1)
    @test_throws ArgumentError heatmap(B)
    B = reshape(A, 2, 2, 3)
    @test_throws ArgumentError heatmap(B)
end
