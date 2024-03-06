using ImageCore
using XAIBase

shape = (2, 2, 3, 1)
A = reshape(collect(Float32, 1:prod(shape)), shape)
val = output = reshape(collect(Float32, 1:prod(shape)), shape)
output_selection = [[CartesianIndex(1, 2)]] # irrelevant
expl = Explanation(val, output, output_selection, :DummyAnalyzer, :attribution)

shape = (2, 2, 3, 2)
batch = reshape(collect(Float32, 1:prod(shape)), shape)

img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]
img2 = [RGB(x, y, 0) for x in 0:0.2:1, y in 0:0.2:1]

colorschemes = [:seismic, :grays, :jet]
reducers = [:sum, :maxabs, :norm, :sumabs, :abssum]
rangescales = [:extrema, :centered]

@testset "Single input" begin
    for colorscheme in colorschemes
        for reducer in reducers
            for rangescale in rangescales
                h = heatmap(
                    A; colorscheme=colorscheme, reduce=reducer, rangescale=rangescale
                )
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" h
                h = heatmap(
                    expl; colorscheme=colorscheme, reduce=reducer, rangescale=rangescale
                )
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" h
                hs = heatmap(
                    A;
                    colorscheme=colorscheme,
                    reduce=reducer,
                    rangescale=rangescale,
                    unpack_singleton=false,
                )
                @test_reference "references/heatmap/$(colorscheme)_$(reducer)_$(rangescale).txt" hs[1]

                ho = heatmap_overlay(
                    A, img; colorscheme=colorscheme, reduce=reducer, rangescale=rangescale
                )
                @test size(ho) == size(img)
                @test_reference "references/overlay/$(colorscheme)_$(reducer)_$(rangescale).txt" ho
                ho = heatmap_overlay(
                    expl,
                    img;
                    colorscheme=colorscheme,
                    reduce=reducer,
                    rangescale=rangescale,
                )
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
                ho = heatmap_overlay(
                    A, img2; colorscheme=colorscheme, reduce=reducer, rangescale=rangescale
                )
                @test size(ho) == size(img2)
                @test_reference "references/overlay_rescaled/$(colorscheme)_$(reducer)_$(rangescale).txt" ho
            end
        end
    end
end

@testset "Overlay alpha masks" begin
    alpha = 0.2
    ho = heatmap_overlay(A, img2; alpha=alpha)
    @test size(ho) == size(img2)
    @test_reference "references/overlay_alpha/scalar.txt" ho

    alpha = [(x + y) / 2 for x in 0:0.2:1, y in 0:0.2:1]
    ho = heatmap_overlay(A, img2; alpha=alpha)
    @test size(ho) == size(img2)
    @test_reference "references/overlay_alpha/matrix.txt" ho

    alpha = fill!(alpha, 0.2)
    ho = heatmap_overlay(A, img2; alpha=alpha)
    @test size(ho) == size(img2)
    @test_reference "references/overlay_alpha/scalar.txt" ho

    alpha[2, 2] = 1.1
    @test_throws ArgumentError heatmap_overlay(A, img2; alpha=alpha)
    @test_throws ArgumentError heatmap_overlay(A, img2; alpha=-0.1)
end

@testset "Batched input" begin
    for reducer in reducers
        for rangescale in rangescales
            h = heatmap(batch; reduce=reducer, rangescale=rangescale)
            @test_reference "references/heatmap/seismic_$(reducer)_$(rangescale).txt" h[1]
            @test_reference "references/heatmap/seismic_$(reducer)_$(rangescale)_2.txt" h[2]
        end
    end
end

@testset "ColorSchemes" begin
    h = heatmap(A; colorscheme=ColorSchemes.inferno)
    @test_reference "references/heatmap/inferno_sum_centered.txt" h

    # Test colorscheme symbols
    h = heatmap(A; colorscheme=:inferno)
    @test_reference "references/heatmap/inferno_sum_centered.txt" h

    ho = heatmap_overlay(A, img; colorscheme=:inferno)
    @test_reference "references/overlay/inferno_sum_centered.txt" ho
    ho = heatmap_overlay(A, img; colorscheme=ColorSchemes.inferno)
    @test_reference "references/overlay/inferno_sum_centered.txt" ho
end

@testset "Error handling" begin
    @test_throws ArgumentError heatmap(A, reduce=:foo)
    @test_throws ArgumentError heatmap(A, rangescale=:bar)

    @test_throws ArgumentError heatmap_overlay(batch, img)
    @test_throws ArgumentError heatmap_overlay(A, img; alpha=2)
    @test_throws ArgumentError heatmap_overlay(A, img; alpha=-1)

    B = reshape(A, 2, 2, 3, 1, 1)
    @test_throws ArgumentError heatmap(B)
    B = reshape(A, 2, 2, 3)
    @test_throws ArgumentError heatmap(B)
end

@testset "Color channel reduction" begin
    A1 = rand(3, 3, 1)
    A2 = VisionHeatmaps.reduce_color_channel(A1, :sum)
    @test A1 == A2
end

@testset "Process batch" begin
    A = reshape(1:(2^4), 2, 2, 2, 2)
    h1 = heatmap(A)
    h2 = heatmap(A; process_batch=true)
    @test_reference "references/process_batch_false.txt" h1
    @test_reference "references/process_batch_true.txt" h2
end
