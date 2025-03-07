const InputDimensionError = ArgumentError(
    "heatmap assumes the WHCN convention for input array dimensions (width, height, color channels, batch dimension).
    Please reshape your input to match this format if your model doesn't adhere to this convention.",
)

"""
    heatmap(x::AbstractArray)

Visualize 4D arrays as heatmaps, assuming the WHCN convention for input array dimensions
(width, height, color channels, batch dimension).

## Keyword arguments
- `permute::Bool`: Whether to flip W&H input channels. Default is `true`.
- `process_batch::Bool`: When heatmapping a batch, setting `process_batch=true`
  will apply the `rangescale` normalization to the entire batch
  instead of computing it individually for each sample in the batch.
  Defaults to `false`.
- `unpack_singleton::Bool`: If false, `heatmap` will always return a vector of images.
  When heatmapping a batch with a single sample, setting `unpack_singleton=true`
  will unpack the singleton vector and directly return the image. Defaults to `true`.
"""
heatmap(val; kwargs...) = heatmap(val, HeatmapOptions(; kwargs...))

function heatmap(val::AbstractArray{T,N}, pipeline::Pipeline) where {T,N}
    # N != 4 && throw(InputDimensionError)
    # if options.unpack_singleton && size(val, 4) == 1
    #     return single_heatmap(val[:, :, :, 1], options)
    # end
    # if options.process_batch
    #     hs = single_heatmap(val, options)
    #     return [hs[:, :, i] for i in axes(hs, 3)]
    # end
    # return [single_heatmap(v, options) for v in eachslice(val; dims=4)]
end

#=================#
# XAIBase support #
#=================#

"""
    heatmap(expl::Explanation)

Visualize `Explanation` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batch dimension) for `explanation.val`.

This will use the default heatmapping style for the given type of explanation.
Defaults can be overridden via keyword arguments.
"""
heatmap(expl::Explanation) = heatmap(expl.val, Pipeline(expl))

"""
    heatmap(input::AbstractArray, analyzer::AbstractXAIMethod)

Compute an `Explanation` for a given `input` using the XAI method `analyzer` and visualize it
as a vision heatmap.

Any additional arguments and keyword arguments are passed to the analyzer.
Refer to the `analyze` documentation for more information on available keyword arguments.

To customize the heatmapping style, first compute an explanation using `analyze`
and then call [`heatmap`](@ref) on the explanation.
"""
function heatmap(input, analyzer::AbstractXAIMethod, analyze_args...; analyze_kwargs...)
    expl = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(expl)
end
