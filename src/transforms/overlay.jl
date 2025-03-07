const DEFAULT_OVERLAY_ALPHA = 0.6

"""
- `resize_method`: Method used to resize the heatmap in case of a size mismatch with the image.
Defaults to `Lanczos(1)` from Interpolations.jl.

Further keyword arguments are passed to `heatmap`.
Refer to the [`heatmap`](@ref) documentation for more information.
"""
function heatmap_overlay(
    val::AbstractArray{T,N},
    im::AbstractImage;
    alpha=DEFAULT_OVERLAY_ALPHA,
    resize_method=DEFAULT_RESIZE_METHOD,
    heatmap_kwargs...,
) where {T,N}
    options = HeatmapOptions(; heatmap_kwargs...)
    return heatmap_overlay(val, im, alpha, resize_method, options)
end

"""
    AlphaOverlay()
    AlphaOverlay(alpha)

Overlays a heatmap on top of an image.
The opacity `alpha` of the heatmap defaults to `$DEFAULT_OVERLAY_ALPHA`.
"""
struct AlphaOverlay{T<:AbstractFloat} <: AbstractTransform
    alpha::T

    function AlphaOverlay(alpha::T) where {T<:AbstractFloat}
        if alpha < 0 || alpha > 1
            throw(DomainError("alpha must be in the range [0, 1]"))
        end
        return new{T}(alpha)
    end
end
AlphaOverlay() = AlphaOverlay(DEFAULT_OVERLAY_ALPHA)

function apply(t::AlphaOverlay, x, img)
    hsize = size(x)
    isize = size(img)
    if hsize != isize
        throw(
            DimensionMismatch(
                "Heatmap dimensions $hsize don't match image dimensions $isize. You might want to include [`Resize`](@ref) in your heatmapping pipeline.",
            ),
        )
    end

    return @. img * (1 - t.alpha) + x * t.alpha
end
