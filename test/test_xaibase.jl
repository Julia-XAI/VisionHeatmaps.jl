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

@testset "Direct Analyzer call" begin
    struct DummyAnalyzer <: AbstractXAIMethod end
    function (method::DummyAnalyzer)(input, output_selector::AbstractOutputSelector)
        output = input
        output_selection = output_selector(output)
        batchsize = size(input)[end]
        v = reshape(output[output_selection], :, batchsize)
        val = input .* v
        return Explanation(val, output, output_selection, :Dummy, :attribution)
    end

    analyzer = DummyAnalyzer()
    input = reshape([1 6 2 5 3 4], 2, 3, 1, 1)
    val = reshape([3 36 6 30 9 24], 2, 3, 1, 1) # Explanation for max activation
    expl = analyzer(input)

    h1 = heatmap(expl)
    h2 = heatmap(input, analyzer)
    @test h1 ≈ h2
end
