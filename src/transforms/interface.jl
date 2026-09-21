# The abstract type `AbstractTransform` is defined in XAIBase.jl.
# Custom heatmapping transforms subtype it and implement `apply`.

"""
    apply(t::AbstractTransform, x)
    apply(t::AbstractTransform, x, img)

Apply a transform `t` of type `AbstractTransform` to the input `x`.
Can optionally take an input image.

Custom heatmapping transforms subtype `AbstractTransform`
and must implement an `apply(t, x::AbstractArray)` method for single samples.
Batches of type `XAIBase.Batch` are transformed sample by sample by default.
Batch-aware transforms can implement `apply(t, xs::Batch)`.
"""
apply(t::AbstractTransform, x, img) = apply(t, x) # fallback for missing 3-argument methods
apply(t::AbstractTransform, xs::Batch) = mapsamples(x -> apply(t, x), xs)

# Pooling functions reduce the color-channel dimension, which is then dropped.
# Following the WHCN convention, color channels are the third dimension
# of both single samples and batches.
apply(p::AbstractPooling, x::AbstractArray{T, 3}) where {T} = pool_channels(p, x)
apply(p::AbstractPooling, xs::Batch) = Batch(pool_channels(p, xs.val))

function pool_channels(p::AbstractPooling, x::AbstractArray)
    y = pool(p, x, 3)
    size(y, 3) != 1 && throw(
        ArgumentError("$p can't reduce $(size(y, 3)) color channels to a single channel."),
    )
    return dropdims(y; dims = 3)
end

# Normalization functions from XAIBase handle batches,
# e.g. to normalize the whole batch at once using `BatchedNormalization`.
apply(n::AbstractNormalization, x::AbstractArray) = normalize(n, x)
apply(n::AbstractNormalization, xs::Batch) = normalize(n, xs)
