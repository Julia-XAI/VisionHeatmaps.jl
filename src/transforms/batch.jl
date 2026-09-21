# Transforms that use the input image are applied to batches sample by sample,
# pairing each sample with its image.
# All other transforms fall back to 2-argument `apply` methods,
# which is why there is no generic method for `AbstractTransform`.
const ImageTransform = Union{ResizeToImage, AlphaOverlay}

function apply(t::ImageTransform, xs::Batch, img::AbstractImage)
    return mapsamples(x -> apply(t, x, img), xs)
end
function apply(t::ImageTransform, xs::Batch, imgs::Batch)
    return mapsamples((x, img) -> apply(t, x, img), xs, imgs)
end
