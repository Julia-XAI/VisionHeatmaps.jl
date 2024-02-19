using XAIBase

# NOTE: Heatmapping assumes Flux's WHCN convention (width, height, color channels, batch size).
# Single input
@testset "Single input" begin
    shape = (2, 2, 3, 1)
    val = output = reshape(collect(Float32, 1:prod(shape)), shape)
    output_selection = [CartesianIndex(1, 2)] # irrelevant
    expl = Explanation(val, output, [output_selection], :LRP, :attribution)

    reducers = [:sum, :maxabs, :norm, :sumabs, :abssum]
    rangescales = [:extrema, :centered]
    for reducer in reducers
        for rangescale in rangescales
            local h = heatmap(expl; reduce=reducer, rangescale=rangescale)
            @test_reference "references/$(reducer)_$(rangescale).txt" h
            h2 = heatmap(
                expl; reduce=reducer, rangescale=rangescale, unpack_singleton=false
            )[1]
            @test h ≈ h2
        end
    end
end

@testset "Batched input" begin
    val = output = reshape(1:(2^4), 2, 2, 2, 2)
    output_selection = [CartesianIndex(1, 2), CartesianIndex(3, 4)] # irrelevant
    expl_batch = Explanation(val, output, output_selection, :LRP, :attribution)

    h1 = heatmap(expl_batch)
    h2 = heatmap(expl_batch; process_batch=true)
    @test_reference "references/process_batch_false.txt" h1
    @test_reference "references/process_batch_true.txt" h2
end
