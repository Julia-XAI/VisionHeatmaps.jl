# Heatmapping pipelines are strongly inspired by the design of DataAugmentations.jl.
# Notably, the usage of the `compose` function has been adapted directly.
# DataAugmentations.jl uses the MIT License,
# Copyright (c) 2020 lorenzoh <lorenz.ohly@gmail.com>

"""
    abstract type Transform

Abstract supertype for all heatmapping transformations. 
Custom transformations must implement an [`apply`](@ref) method.
"""
abstract type Transform end

"""
    apply(t::Transform, x)
    apply(t::Transform, x, img)

Apply a transformation to the input array `x`. 
Can optionally take an input image.
"""
apply(t::Transform, x, img) = apply(t, x) # fallback for missing 3-argument methods

#===================================#
# Composing Transforms to pipelines #
#===================================#

"""
    compose(transforms...)

Compose transformations to create a [`Pipeline`](@ref). 
Uses `|>` on transformations as an alias.
"""
compose(t::Transform) = t
compose(ts...) = compose(compose(ts[1], ts[2]), ts[3:end]...)
Base.:(|>)(t1::Transform, t2::Transform) = compose(t1, t2)

"""
   Pipeline(transforms...)

Heatmapping pipelines sequentially apply transformations.
"""
struct Pipeline{T<:Tuple} <: Transform
    transforms::T
end

Pipeline(ts...) = Pipeline(ts)
Pipeline(t::Transform) = t

compose(t1::Transform, t2::Transform) = Pipeline(t1, t2)
compose(p::Pipeline, t::Transform) = Pipeline(p.transforms..., t)
compose(t::Transform, p::Pipeline) = compose(t, p.transforms...)
compose(p1::Pipeline, p2::Pipeline) = compose(p1.transforms..., p2.transforms...)


function apply(pipeline::Pipeline, x, img)
    for transform in pipeline
        x = transform(x, img)
    end
    return x
end
