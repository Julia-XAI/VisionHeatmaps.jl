"""
    FlipImage()

Permutes the width and height dimensions of an array.
Assumes width and height are the leading directions in the array.

`heatmap` already applies this flip by default,
turning WHCN values into display-oriented images,
so it does not need to be part of a pipeline.
It remains available for pipelines that operate on pre-oriented arrays.
"""
struct FlipImage <: AbstractTransform end

apply(::FlipImage, x::AbstractArray{T, 2}) where {T} = permutedims(x, (2, 1))
apply(::FlipImage, x::AbstractArray{T, 3}) where {T} = permutedims(x, (2, 1, 3))
apply(::FlipImage, x::AbstractArray{T, 4}) where {T} = permutedims(x, (2, 1, 3, 4))

"""
    PermuteDims(dims...)

Permutes arrays according to the specified dimensions.
"""
struct PermuteDims{T <: Tuple{Int}} <: AbstractTransform
    dims::T
end

apply(t::PermuteDims, x::AbstractArray) = permutedims(x, t.dims)

"""
    DropDims(dims...)

Drops specified singleton array dimensions.
"""
struct DropDims{T <: Union{Int, Tuple{Int}}} <: AbstractTransform
    dims::T
end

apply(t::DropDims, x::AbstractArray) = dropdims(x; dims = t.dims)
