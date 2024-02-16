using ImageCore

shape = (2, 2, 3, 1)
A = reshape(collect(Float32, 1:prod(shape)), shape)

shape = (2, 2, 3, 2)
batch = reshape(collect(Float32, 1:prod(shape)), shape)

img = [RGB(1, 0, 0) RGB(0, 1, 0); RGB(0, 0, 1) RGB(1, 1, 1)]
img2 = [RGB(x, y, 0) for x in 0:0.2:1, y in 0:0.2:1]

reducers = [:sum, :maxabs, :norm, :sumabs, :abssum]
rangescales = [:extrema, :centered]

@testset "Single input" begin
    for reducer in reducers
        for rangescale in rangescales
            h = heatmap(A; reduce=reducer, rangescale=rangescale)
            @test_reference "references/$(reducer)_$(rangescale).txt" h
            h2 = heatmap(A; reduce=reducer, rangescale=rangescale, unpack_singleton=false)[1]
            @test h ≈ h2

            ho = heatmap_overlay(A, img; reduce=reducer, rangescale=rangescale)
            @test size(ho) == size(img)
            @test_reference "references/overlay_$(reducer)_$(rangescale).txt" ho
        end
    end
end
@testset "Overlay rescaling" begin
    for reducer in reducers
        for rangescale in rangescales
            ho = heatmap_overlay(A, img2; reduce=reducer, rangescale=rangescale)
            @test size(ho) == size(img2)
            @test_reference "references/overlay_rescale_$(reducer)_$(rangescale).txt" ho
        end
    end
end

@testset "Batched input" begin
    for reducer in reducers
        for rangescale in rangescales
            h = heatmap(batch; reduce=reducer, rangescale=rangescale)
            @test_reference "references/$(reducer)_$(rangescale).txt" h[1]
            @test_reference "references/$(reducer)_$(rangescale)_2.txt" h[2]
        end
    end
end

@testset "ColorSchemes" begin
    h = heatmap(A; colorscheme=ColorSchemes.inferno)
    @test_reference "references/inferno.txt" h

    # Test colorscheme symbols
    h = heatmap(A; colorscheme=:inferno)
    @test_reference "references/inferno.txt" h

    ho = heatmap_overlay(A, img; colorscheme=:inferno)
    @test_reference "references/overlay_inferno.txt" ho
    ho = heatmap_overlay(A, img; colorscheme=ColorSchemes.inferno)
    @test_reference "references/overlay_inferno.txt" ho
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
