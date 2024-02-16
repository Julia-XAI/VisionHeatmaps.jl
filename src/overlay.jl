const DEFAULT_OVERLAY_ALPHA = 0.6

"""
    heatmap_overlay(val, img)

Create a heatmap from `val` and overlay it on top of an image.
Assumes 4D input array following the WHCN convention
(width, height, color channels, batch dimension) and batch size 1.

## Keyword arguments
- `alpha::Real`: Opacity of the heatmap overlay. Defaults to `$DEFAULT_OVERLAY_ALPHA`.
- `resize_method`: Method used to resize the heatmap in case of a size mismatch with the image.
    Defaults to `Lanczos(1)` from Interpolations.jl.

Further keyword arguments are passed to `heatmap`.
Refer to the [`heatmap`](@ref) documentation for more information.
"""
function heatmap_overlay(
    val::AbstractArray{T,N},
    im::AbstractMatrix{<:Colorant};
    alpha=DEFAULT_OVERLAY_ALPHA,
    resize_method=Lanczos(1),
    kwargs...,
) where {T,N}
    N != 4 && throw(InputDimensionError)
    if size(val, 4) != 1
        throw(
            ArgumentError(
                "heatmap_overlay assumes a single heatmap, i.e. a 4D array with batch dimension 1.",
            ),
        )
    end
    if alpha < 0 || alpha > 1
        throw(ArgumentError("alpha must be in the range [0, 1]"))
    end
    hm = heatmap(val; kwargs...)
    hmsize = size(hm)
    imsize = size(im)
    if hmsize != imsize
        hm = imresize(hm, imsize; method=resize_method)
    end
    return im * (1 - alpha) + hm * alpha
end
