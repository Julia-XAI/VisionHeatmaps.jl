const DEFAULT_OVERLAY_ALPHA = 0.6

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
