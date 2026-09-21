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
attr = Attribution(val, input, output, output_selection, SumPooling())

shape = (2, 2, 3, 2)
batch = reshape(collect(Float32, 1:prod(shape)), shape)

img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]
img2 = [RGB(x, y, 0) for x in 0:0.2:1, y in 0:0.2:1]
img_batch = [RGB(x, y, z) for x in 0:0.2:1, y in 0:0.2:1, z in 0:1]

rangescale2normalization = Dict(
    :extrema => ExtremaNormalization, :centered => CenteredNormalization
)
reducer2pooling = Dict(
    :sum => SumPooling,
    :maxabs => MaxAbsPooling,
    :norm => NormPooling,
    :sumabs => SumAbsPooling,
    :abssum => AbsSumPooling,
)

colorschemes = [:seismic, :viridis, :jet]
reducers = [:sum, :maxabs, :norm, :sumabs, :abssum]
rangescales = [:extrema, :centered]

@testset "Single input" begin
    for colorscheme in colorschemes
        for reducer in reducers
            for rangescale in rangescales
                Pooling = reducer2pooling[reducer]
                Normalization = rangescale2normalization[rangescale]
                pipe = Pooling() |> Normalization() |> Colormap(colorscheme)
                h = heatmap(A, pipe)
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" only(
                    h
                )
                h = heatmap(attr, pipe)
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" only(
                    h
                )

                # Overlay
                pipe =
                    Pooling() |>
                    Normalization() |>
                    Colormap(colorscheme) |>
                    ResizeToImage() |>
                    AlphaOverlay()
                ho = heatmap(A, img, pipe)
                @test size(only(ho)) == size(img)
                @test_reference "references/overlay/$(colorscheme)_$(reducer)_$(rangescale).txt" only(
                    ho
                )
                ho = heatmap(attr, img, pipe)
                @test size(only(ho)) == size(img)
                @test_reference "references/overlay/$(colorscheme)_$(reducer)_$(rangescale).txt" only(
                    ho
                )
            end
        end
    end
end
@testset "Overlay rescaling" begin
    for colorscheme in colorschemes
        for reducer in reducers
            for rangescale in rangescales
                Pooling = reducer2pooling[reducer]
                Normalization = rangescale2normalization[rangescale]
                pipe =
                    Pooling() |>
                    Normalization() |>
                    Colormap(colorscheme) |>
                    ResizeToImage() |>
                    AlphaOverlay()
                ho = heatmap(A, img2, pipe)
                @test size(only(ho)) == size(img2)
                @test_reference "references/overlay_rescaled/$(colorscheme)_$(reducer)_$(rangescale).txt" only(
                    ho
                )
            end
        end
    end
end

@testset "Batched input" begin
    for reducer in reducers
        for rangescale in rangescales
            Pooling = reducer2pooling[reducer]
            Normalization = rangescale2normalization[rangescale]
            pipe =
                Pooling() |>
                Normalization() |>
                Colormap(:viridis) |>
                ResizeToImage() |>
                AlphaOverlay()

            h = heatmap(batch, pipe)
            @test_reference "references/heatmap/viridis_$(reducer)_$(rangescale).txt" h[1]
            @test_reference "references/heatmap/viridis_$(reducer)_$(rangescale)_2.txt" h[2]
        end
    end
end
@testset "Batched overlay" begin
    for colorscheme in colorschemes
        for reducer in reducers
            for rangescale in rangescales
                Pooling = reducer2pooling[reducer]
                Normalization = rangescale2normalization[rangescale]
                pipe =
                    Pooling() |>
                    Normalization() |>
                    Colormap(colorscheme) |>
                    ResizeToImage() |>
                    AlphaOverlay()
                ho = heatmap(batch, img_batch, pipe)
                h1, h2 = ho[1], ho[2]

                @test size(h1) == size(h2) == size(img2)
                @test_reference "references/overlay_rescaled/$(colorscheme)_$(reducer)_$(rangescale).txt" h1
                @test_reference "references/overlay_rescaled/$(colorscheme)_$(reducer)_$(rangescale)_2.txt" h1
            end
        end
    end
end

@testset "Batched normalization" begin
    # The second sample is a scaled copy of the first one
    x = cat(A, 3 .* A; dims = 4)
    for Normalization in (ExtremaNormalization, CenteredNormalization)
        # By default, samples are normalized individually
        pipe = NormPooling() |> Normalization() |> Colormap()
        h1, h2 = heatmap(x, pipe)
        @test channelview(h1) ≈ channelview(h2) rtol = 1.0e-5 # Float32 rounding

        # Batched normalization uses a shared value range
        pipe = NormPooling() |> BatchedNormalization(Normalization()) |> Colormap()
        h1, h2 = heatmap(x, pipe)
        @test h1 != h2
        pooled = pool(NormPooling(), x, 3)
        bounds = normalization_bounds(Normalization(), pooled)
        for (h, p) in zip((h1, h2), eachslice(pooled; dims = 3))
            @test h == permutedims(get(ColorSchemes.batlow, Normalization()(p, bounds)))
        end

        # Overlays onto a single image or a batch of images
        overlay = pipe |> ResizeToImage() |> AlphaOverlay()
        ho1, ho2 = heatmap(x, img2, overlay)
        @test size(ho1) == size(ho2) == size(img2)
        @test ho1 != ho2
        ho2_batch = VisionHeatmaps.apply(
            ResizeToImage() |> AlphaOverlay(), h2, img_batch[:, :, 2]
        )
        @test heatmap(x, img_batch, overlay) == [ho1, ho2_batch]

        # On single samples, batched normalization has no effect
        @test heatmap(A, pipe) ==
            heatmap(A, NormPooling() |> Normalization() |> Colormap())
    end

    # Batches of heatmaps and images need to have the same size
    pipe = NormPooling() |> ExtremaNormalization() |> Colormap() |> AlphaOverlay()
    @test_throws DimensionMismatch heatmap(x, cat(img, img, img; dims = 3), pipe)
end

@testset "ColorSchemes" begin
    pipe = NormPooling() |> ExtremaNormalization() |> Colormap(:inferno)
    h = heatmap(A, pipe)
    @test_reference "references/heatmap/inferno_norm_extrema.txt" only(h)

    pipe =
        SumPooling() |>
        CenteredNormalization() |>
        Colormap(:inferno) |>
        ResizeToImage() |>
        AlphaOverlay()
    ho = heatmap(A, img, pipe)
    @test_reference "references/overlay/inferno_sum_centered.txt" only(ho)
end

@testset "Colormap and normalization pairing" begin
    default_colormap = VisionHeatmaps.default_colormap
    @test default_colormap(ExtremaNormalization()) == Colormap(:batlow)
    @test default_colormap(CenteredNormalization()) == Colormap(:berlin)
    @test default_colormap(BatchedNormalization(CenteredNormalization())) ==
        Colormap(:berlin)

    # Matching and unknown kinds of colormaps don't warn
    @test_logs ExtremaNormalization() |> Colormap(:batlow)
    @test_logs CenteredNormalization() |> Colormap(:berlin)
    @test_logs ExtremaNormalization() |> Colormap(:jet)
    @test_logs NormPooling() |> Colormap(:berlin)

    # Mismatched kinds of colormaps warn
    @test_logs (:warn, r"diverging colormap") CenteredNormalization() |> Colormap()
    @test_logs (:warn, r"sequential colormap") ExtremaNormalization() |> Colormap(:berlin)
    @test_logs (:warn, r"sequential colormap") ExtremaNormalization() |>
        (Colormap(:berlin) |> FlipImage())
    @test_logs (:warn, r"diverging colormap") SumPooling() |>
        BatchedNormalization(CenteredNormalization()) |>
        PercentileClip() |>
        Colormap(:viridis) |>
        FlipImage()
end

@testset "Error handling" begin
    @test_throws DomainError AlphaOverlay(2.0)
    @test_throws DomainError AlphaOverlay(-1.0)

    B = reshape(A, 2, 2, 3, 1, 1)
    @test_throws ArgumentError heatmap(B)
    B = reshape(A, 2, 2, 3)
    @test_throws ArgumentError heatmap(B)

    # Identity poolings can't reduce multiple color channels
    pipe = UnsignedNoPooling() |> ExtremaNormalization() |> Colormap()
    @test_throws ArgumentError heatmap(A, pipe)
end
