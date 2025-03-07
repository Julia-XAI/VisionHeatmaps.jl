const DEFAULT_RESIZE_METHOD = Lanczos(1)

"""
    ResizeToImage()
    ResizeToImage(method)

Resize the heatmap to match the image dimensions. In some cases, this is needed for overlays.
Defaults to `Lanczos(1)` from Interpolations.jl.
"""

struct ResizeToImage{M} <: AbstractTransform
    method::M
end
ResizeToImage() = ResizeToImage(DEFAULT_RESIZE_METHOD)

function apply(t::ResizeToImage, x, img)
    hsize = size(x)
    isize = size(img)
    hsize == isize && return x
    return imresize(x, isize; method=t.method)
end
