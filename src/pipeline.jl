# Heatmapping pipelines are strongly inspired by the design of DataAugmentations.jl.
# Notably, the usage of the `compose` function has been adapted directly.
# DataAugmentations.jl uses the MIT License,
# Copyright (c) 2020 lorenzoh <lorenz.ohly@gmail.com>

"""
Pipeline(transforms...)

Heatmapping pipelines sequentially apply transforms.
"""
struct Pipeline{T<:Tuple} <: AbstractTransform
    transforms::T
end

Pipeline(ts...) = Pipeline(ts)
Pipeline(t::AbstractTransform) = t

function apply(pipeline::Pipeline, x, img)
    for AbstractTransform in pipeline
        x = AbstractTransform(x, img)
    end
    return x
end

#=====================#
# Composing pipelines #
#=====================#

"""
    compose(transforms...)

Compose transforms to create a [`Pipeline`](@ref). 
Uses `|>` on [`AbstractTransform`](@ref)s as an alias.
"""
compose(t::AbstractTransform) = t
compose(ts...) = compose(compose(ts[1], ts[2]), ts[3:end]...)
Base.:(|>)(t1::AbstractTransform, t2::AbstractTransform) = compose(t1, t2)

compose(t1::AbstractTransform, t2::AbstractTransform) = Pipeline(t1, t2)
compose(p::Pipeline, t::AbstractTransform) = Pipeline(p.transforms..., t)
compose(t::AbstractTransform, p::Pipeline) = compose(t, p.transforms...)
function compose(p1::Pipeline, p2::Pipeline)
    compose(p1.transforms..., p2.transforms...)
end

#==========#
# Printing #
#==========#

function Base.show(io::IO, pipe::Pipeline)
    println(io, "Pipeline(")
    show_transforms(io, pipe.transforms)
    print(io, ")")
end

function show_transforms(io, t::AbstractTransform)
    show_transforms(io, ts::Tuple) = join(io, ts, ", ")
end

#=============================#
# Presets for XAIBase support #
#=============================#

DEFAULT_PIPELINE_SENSITIVITY = NormReduction() |> SequentialColormap() |> FlipWH()
DEFAULT_PIPELINE_ATTRIBUTION = NormReduction() |> DivergentColormap() |> FlipWH()
# DEFAULT_PIPELINE_CAM = SumReduction() |> SequentialColormap(jet) |> FlipWH() |> Upscale() |> AlphaOverlay()

PIPELINE_PRESETS = Dict(
    :attribution => DEFAULT_PIPELINE_ATTRIBUTION,
    :sensitivity => DEFAULT_PIPELINE_SENSITIVITY,
    # :cam         => DEFAULT_PIPELINE_CAM,
)

function Pipeline(expl::Explanation)
    get(PIPELINE_PRESETS, expl.heatmap, DEFAULT_PIPELINE_SENSITIVITY)
end
