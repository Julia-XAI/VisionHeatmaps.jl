const DEFAULT_COLORSCHEME = seismic
const DEFAULT_REDUCE = :sum
const DEFAULT_RANGESCALE = :centered

"""
    heatmap(x)

Visualize 4D arrays as heatmaps, assuming the WHCN convention for input array dimensions
(width, height, color channels, batch dimension).

## Keyword arguments
- `colorscheme::Union{ColorScheme,Symbol}`: Color scheme from ColorSchemes.jl.
  Defaults to `seismic`.
- `reduce::Symbol`: Selects how color channels are reduced to a single number to apply a color scheme.
  The following methods can be selected, which are then applied over the color channels
  for each "pixel" in the array:
  - `:sum`: sum up color channels
  - `:norm`: compute 2-norm over the color channels
  - `:maxabs`: compute `maximum(abs, x)` over the color channels
  - `:sumabs`: compute `sum(abs, x)` over the color channels
  - `:abssum`: compute `abs(sum(x))` over the color channels
  Defaults to `:$DEFAULT_REDUCE`.
- `rangescale::Symbol`: Selects how the color channel reduced heatmap is normalized
  before the color scheme is applied. Can be either `:extrema` or `:centered`.
  Defaults to `:$DEFAULT_RANGESCALE`.
- `process_batch::Bool`: When heatmapping a batch, setting `process_batch=true`
  will apply the `rangescale` normalization to the entire batch
  instead of computing it individually for each sample in the batch.
  Defaults to `false`.
- `permute::Bool`: Whether to flip W&H input channels. Default is `true`.
- `unpack_singleton::Bool`: If false, `heatmap` will always return a vector of images.
  When heatmapping a batch with a single sample, setting `unpack_singleton=true`
  will unpack the singleton vector and directly return the image. Defaults to `true`.
"""
function heatmap(
    val::AbstractArray{T,N};
    colorscheme::Union{ColorScheme,Symbol}=DEFAULT_COLORSCHEME,
    reduce::Symbol=DEFAULT_REDUCE,
    rangescale::Symbol=DEFAULT_RANGESCALE,
    permute::Bool=true,
    unpack_singleton::Bool=true,
    process_batch::Bool=false,
) where {T,N}
    N != 4 && throw(InputDimensionError)
    colorscheme = get_colorscheme(colorscheme)
    if unpack_singleton && size(val, 4) == 1
        return single_heatmap(val[:, :, :, 1], colorscheme, reduce, rangescale, permute)
    end
    if process_batch
        hs = single_heatmap(val, colorscheme, reduce, rangescale, permute)
        return [hs[:, :, i] for i in axes(hs, 3)]
    end
    return [
        single_heatmap(v, colorscheme, reduce, rangescale, permute) for
        v in eachslice(val; dims=4)
    ]
end

const InputDimensionError = ArgumentError(
    "heatmap assumes the WHCN convention for input array dimensions (width, height, color channels, batch dimension).
    Please reshape your input to match this format if your model doesn't adhere to this convention.",
)

get_colorscheme(c::ColorScheme) = c
get_colorscheme(s::Symbol)::ColorScheme = colorschemes[s]

# Lower level function, mapped along batch dimension
function single_heatmap(
    val, colorscheme::ColorScheme, reduce::Symbol, rangescale::Symbol, permute::Bool
)
    img = dropdims(reduce_color_channel(val, reduce); dims=3)
    permute && (img = flip_wh(img))
    return get(colorscheme, img, rangescale)
end

flip_wh(img::AbstractArray{T,2}) where {T} = permutedims(img, (2, 1))
flip_wh(img::AbstractArray{T,3}) where {T} = permutedims(img, (2, 1, 3))

# Reduce array across color channels into a single scalar – assumes WHCN convention
function reduce_color_channel(val::AbstractArray, method::Symbol)
    init = zero(eltype(val))
    if size(val, 3) == 1 # nothing to reduce
        return val
    elseif method == :sum
        return reduce(+, val; dims=3)
    elseif method == :maxabs
        return reduce((c...) -> maximum(abs.(c)), val; dims=3, init=init)
    elseif method == :norm
        return reduce((c...) -> sqrt(sum(c .^ 2)), val; dims=3, init=init)
    elseif method == :sumabs
        return reduce((c...) -> sum(abs, c), val; dims=3, init=init)
    elseif method == :abssum
        return reduce((c...) -> abs(sum(c)), val; dims=3, init=init)
    end
    throw( # else
        ArgumentError(
            "`reduce` :$method not supported, should be :maxabs, :sum, :norm, :sumabs, or :abssum",
        ),
    )
end
