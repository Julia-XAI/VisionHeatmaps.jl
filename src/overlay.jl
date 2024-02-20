const AbstractImage{T<:Colorant} = AbstractMatrix{T}

const DEFAULT_OVERLAY_ALPHA = 0.6
const DEFAULT_RESIZE_METHOD = Lanczos(1)

"""
    heatmap_overlay(val, image)

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
    im::AbstractImage;
    alpha=DEFAULT_OVERLAY_ALPHA,
    resize_method=DEFAULT_RESIZE_METHOD,
    heatmap_kwargs...,
) where {T,N}
    options = HeatmapOptions(; heatmap_kwargs...)
    return heatmap_overlay(val, im, alpha, resize_method, options)
end

function heatmap_overlay(
    val::AbstractArray{T,N},
    im::AbstractImage,
    alpha::Real,
    resize_method,
    options::HeatmapOptions,
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

    hm = heatmap(val, options)
    hmsize = size(hm)
    imsize = size(im)
    if hmsize != imsize
        hm = imresize(hm, imsize; method=resize_method)
    end
    return im * (1 - alpha) + hm * alpha
end

#=================#
# XAIBase support #
#=================#

"""
    heatmap_overlay(expl::Explanation, image)

Visualize `Explanation` from XAIBase as a vision heatmap and overlay it on top of an image.
Assumes WHCN convention (width, height, channels, batch dimension) for `explanation.val`
and batch size 1.

This will use the default heatmapping style for the given type of explanation.
Refer to the [`heatmap`](@ref) and [`heatmap_overlay`](@ref) documentation
for a list of supported keyword arguments that can be used to override the defaults.
"""
function heatmap_overlay(
    expl::Explanation,
    im::AbstractImage;
    alpha=DEFAULT_OVERLAY_ALPHA,
    resize_method=DEFAULT_RESIZE_METHOD,
    heatmap_kwargs...,
)
    options = HeatmapOptions(expl; heatmap_kwargs...)
    return heatmap_overlay(expl.val, im, alpha, resize_method, options)
end
