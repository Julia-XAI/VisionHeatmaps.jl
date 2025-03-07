"""
    AbstractTransform

Abstract supertype for all heatmapping transforms. 
Custom transforms must implement an `apply` method.
"""
abstract type AbstractTransform end

"""
    apply(t::AbstractTransform, x)
    apply(t::AbstractTransform, x, img)

Apply a AbstractTransform to the input array `x`. 
Can optionally take an input image.
"""
apply(t::AbstractTransform, x, img) = apply(t, x) # fallback for missing 3-argument methods
