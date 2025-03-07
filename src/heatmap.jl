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
function heatmap(
    x::AbstractArray{T,N}, img::Union{AbstractImage,Nothing}, pipe::Pipeline
) where {T,N}
    N != 4 && throw(InputDimensionError)
    return [apply(pipe, s, img) for s in eachslice(x; dims=4)]
end
heatmap(x, pipeline::Pipeline) = heatmap(x, nothing, pipeline)
heatmap(x) = heatmap(x, DEFAULT_PIPELINE)

#=================#
# XAIBase support #
#=================#

"""
    heatmap(expl::Explanation)
    heatmap(expl::Explanation, pipeline)
    heatmap(expl::Explanation, image)   
    heatmap(expl::Explanation, image, pipeline)

Visualize `Explanation` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batch dimension) for `explanation.val`.
This will use the default heatmapping style for the given type of explanation.
"""
function heatmap(expl::Explanation, img::Union{AbstractImage,Nothing}, pipe::Pipeline)
    heatmap(expl.val, img, pipe)
end
heatmap(expl::Explanation, pipe::Pipeline) = heatmap(expl, nothing, pipe)
heatmap(expl::Explanation) = heatmap(expl, Pipeline(expl))
function heatmap(expl::Explanation, img::Union{AbstractImage,Nothing})
    heatmap(expl, img, Pipeline(expl))
end

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
    expl = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(expl, nothing)
end
