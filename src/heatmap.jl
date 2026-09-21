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
        vals::AbstractArray{T, N}, img::Union{AbstractImage, Nothing}, pipe::Pipeline
    ) where {T, N}
    N != 4 && throw(InputDimensionError)
    return unwrap(apply(pipe, Batch(vals), img))
end
function heatmap(
        vals::AbstractArray{T, N}, imgs::AbstractImageBatch, pipe::Pipeline
    ) where {T, N}
    N != 4 && throw(InputDimensionError)
    return unwrap(apply(pipe, Batch(vals), Batch(imgs)))
end

# Return heatmaps as a vector of images
unwrap(hs::Batch) = [copy(h) for h in eachsample(hs)]
heatmap(x, pipeline::Pipeline) = heatmap(x, nothing, pipeline)
heatmap(x) = heatmap(x, DEFAULT_PIPELINE)

##================#
# XAIBase support #
##================#

"""
    heatmap(attr::Attribution)
    heatmap(attr::Attribution, pipeline)
    heatmap(attr::Attribution, image)
    heatmap(attr::Attribution, image, pipeline)

Visualize `Attribution` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batch dimension) for `attr.val`.
Unless a `pipeline` is passed, this will use the default heatmapping pipeline
for the attribution pooling function `attr.pooling`, see [`default_pipeline`](@ref).
"""
function heatmap(attr::Attribution, img::Union{AbstractImage, Nothing}, pipe::Pipeline)
    return heatmap(attr.val, img, pipe)
end
heatmap(attr::Attribution, pipe::Pipeline) = heatmap(attr, nothing, pipe)
heatmap(attr::Attribution) = heatmap(attr, default_pipeline(attr))
function heatmap(attr::Attribution, img::Union{AbstractImage, Nothing})
    return heatmap(attr, img, default_pipeline(attr))
end

"""
    heatmap(input::AbstractArray, analyzer::AbstractXAIMethod)
    heatmap(input::AbstractArray, analyzer::AbstractXAIMethod, image)

Compute an `Attribution` for a given `input` using the XAI method `analyzer` and visualize it
as a vision heatmap.
This will use the default heatmapping pipeline for the attribution pooling function `attr.pooling`.
"""
function heatmap(
        input,
        analyzer::AbstractXAIMethod,
        img::AbstractImage,
        analyze_args...;
        analyze_kwargs...,
    )
    attr = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(attr, img)
end
function heatmap(input, analyzer::AbstractXAIMethod, analyze_args...; analyze_kwargs...)
    attr = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(attr, nothing)
end
