"""
    FlipImage()

Permutes the width and height dimensions of an array.
Assumes width and height are the leading directions in the array.
"""
struct FlipImage <: AbstractTransform end

apply(::FlipImage, x::AbstractArray{T,2}) where {T} = permutedims(x, (2, 1))
apply(::FlipImage, x::AbstractArray{T,3}) where {T} = permutedims(x, (2, 1, 3))
apply(::FlipImage, x::AbstractArray{T,4}) where {T} = permutedims(x, (2, 1, 3, 4))

"""
    PermuteDims(dims...)

Permutes arrays according to the specified dimensions.
"""
struct PermuteDims{T<:Tuple{Int}} <: AbstractTransform
    dims::T
end

apply(t::PermuteDims, x) = permutedims(x, t.dims)

"""
    DropDims(dims...)

Drops specified singleton array dimensions.
"""
struct DropDims{T<:Union{Int,Tuple{Int}}} <: AbstractTransform
    dims::T
end

apply(t::DropDims, x) = dropdims(x; dims=t.dims)
