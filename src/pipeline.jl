# Pipelines of transforms are defined and composed in XAIBase.jl,
# VisionHeatmaps defines how they are applied.

# Batches are passed through the pipeline as a whole,
# such that each transform can act on the entire batch.
function apply(pipe::Pipeline, x, img)
    for t in pipe.transforms
        x = apply(t, x, img)
    end
    return x
end
apply(pipe::Pipeline, x::AbstractArray) = apply(pipe, x, nothing)
apply(pipe::Pipeline, xs::Batch) = apply(pipe, xs, nothing)

##============================#
# Presets for XAIBase support #
##============================#

"""
    default_pipeline(attr::Attribution)
    default_pipeline(pooling::AbstractPooling)

Return the default heatmapping pipeline for an `Attribution` from XAIBase.jl,
chosen based on its attribution pooling function `attr.pooling`:
- `UnsignedPooling` (e.g. `NormPooling`) uses `ExtremaNormalization` and the sequential `:batlow`
- `SignedPooling` (e.g. `SumPooling`) uses `CenteredNormalization` and the diverging `:berlin`
"""
default_pipeline(attr::Attribution) = default_pipeline(attr.pooling)
function default_pipeline(pooling::AbstractPooling)
    return pooling |>
        default_normalization(pooling) |>
        default_colormap(pooling) |>
        FlipImage()
end

default_colormap(::UnsignedPooling) = Colormap(:batlow)
default_colormap(::SignedPooling) = Colormap(:berlin)

const DEFAULT_PIPELINE = default_pipeline(NormPooling())
