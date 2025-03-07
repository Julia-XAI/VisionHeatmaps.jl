"""
    abstract type AbstractTransform

Abstract supertype for all heatmapping AbstractTransforms. 
Custom AbstractTransforms must implement an [`apply`](@ref) method.
"""
abstract type AbstractTransform end

"""
    apply(t::AbstractTransform, x)
    apply(t::AbstractTransform, x, img)

Apply a AbstractTransform to the input array `x`. 
Can optionally take an input image.
"""
apply(t::AbstractTransform, x, img) = apply(t, x) # fallback for missing 3-argument methods
