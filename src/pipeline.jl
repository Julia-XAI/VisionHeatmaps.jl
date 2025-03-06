# Heatmapping pipelines are strongly inspired by the design of DataAugmentations.jl.
# Notably, the usage of the `compose` function has been adapted directly.
# DataAugmentations.jl uses the MIT License,
# Copyright (c) 2020 lorenzoh <lorenz.ohly@gmail.com>

"""
Pipeline(AbstractTransforms...)

Heatmapping pipelines sequentially apply AbstractTransformations.
"""
struct Pipeline{T<:Tuple} <: AbstractTransformation
    AbstractTransforms::T
end

Pipeline(ts...) = Pipeline(ts)
Pipeline(t::AbstractTransformation) = t

"""
    compose(AbstractTransforms...)

Compose AbstractTransformations to create a [`Pipeline`](@ref). 
Uses `|>` on AbstractTransformations as an alias.
"""
compose(t::AbstractTransformation) = t
compose(ts...) = compose(compose(ts[1], ts[2]), ts[3:end]...)
Base.:(|>)(t1::AbstractTransformation, t2::AbstractTransformation) = compose(t1, t2)

compose(t1::AbstractTransformation, t2::AbstractTransformation) = Pipeline(t1, t2)
compose(p::Pipeline, t::AbstractTransformation) = Pipeline(p.AbstractTransforms..., t)
compose(t::AbstractTransformation, p::Pipeline) = compose(t, p.AbstractTransforms...)
function compose(p1::Pipeline, p2::Pipeline)
    compose(p1.AbstractTransforms..., p2.AbstractTransforms...)
end

function apply(pipeline::Pipeline, x, img)
    for AbstractTransformation in pipeline
        x = AbstractTransformation(x, img)
    end
    return x
end
