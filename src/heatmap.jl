const InputDimensionError = ArgumentError(
    "heatmapping assumes the WHCN convention for input array dimensions (width, height, color channels, batch dimension).
    Please reshape your input to match this format if your model doesn't adhere to this convention.",
)

"""
    heatmap(x::AbstractArray)
    heatmap(x::AbstractArray, pipeline)
    heatmap(x::AbstractArray, image)
    heatmap(x::AbstractArray, image, pipeline)

Visualize 4D arrays as heatmaps, assuming the WHCN convention for input array dimensions
(width, height, color channels, batch dimension).
"""
function heatmap(x::AbstractArray{T,N}, img::AbstractImage, pipe::Pipeline) where {T,N}
    N != 4 && throw(InputDimensionError)
    return [apply(pipe, s, img) for s in eachslice(x; dims=4)]
end
heatmap(x, pipeline::Pipeline) = heatmap(x, nothing, pipeline)

#=================#
# XAIBase support #
#=================#

"""
    heatmap(expl::Explanation)
    heatmap(expl::Explanation, image)

Visualize `Explanation` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batch dimension) for `explanation.val`.
This will use the default heatmapping style for the given type of explanation.
"""
heatmap(expl::Explanation) = heatmap(expl.val, nothing, Pipeline(expl))
heatmap(expl::Explanation, img::AbstractImage) = heatmap(expl.val, img, Pipeline(expl))

"""
    heatmap(input::AbstractArray, analyzer::AbstractXAIMethod)
    heatmap(input::AbstractArray, analyzer::AbstractXAIMethod, image)

Compute an `Explanation` for a given `input` using the XAI method `analyzer` and visualize it
as a vision heatmap.
This will use the default heatmapping style for the given type of explanation.
"""
function heatmap(
    input,
    analyzer::AbstractXAIMethod,
    img::AbstractImage,
    analyze_args...;
    analyze_kwargs...,
)
    expl = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(expl, img)
end
function heatmap(input, analyzer::AbstractXAIMethod, analyze_args...; analyze_kwargs...)
    return heatmap(input, analyzer, nothing, analyze_args...; analyze_kwargs...)
end
