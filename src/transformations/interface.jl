"""
    abstract type AbstractTransformation

Abstract supertype for all heatmapping AbstractTransformations. 
Custom AbstractTransformations must implement an [`apply`](@ref) method.
"""
abstract type AbstractTransformation end

"""
    apply(t::AbstractTransformation, x)
    apply(t::AbstractTransformation, x, img)

Apply a AbstractTransformation to the input array `x`. 
Can optionally take an input image.
"""
apply(t::AbstractTransformation, x, img) = apply(t, x) # fallback for missing 3-argument methods
