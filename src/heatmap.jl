const InputDimensionError = ArgumentError(
    "heatmap assumes the WHCN convention for input array dimensions (width, height, color channels, batch dimension).
    Please reshape your input to match this format if your model doesn't adhere to this convention.",
)

"""
    heatmap(x::AbstractArray)

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
- `permute::Bool`: Whether to flip W&H input channels. Default is `true`.
- `process_batch::Bool`: When heatmapping a batch, setting `process_batch=true`
  will apply the `rangescale` normalization to the entire batch
  instead of computing it individually for each sample in the batch.
  Defaults to `false`.
- `unpack_singleton::Bool`: If false, `heatmap` will always return a vector of images.
  When heatmapping a batch with a single sample, setting `unpack_singleton=true`
  will unpack the singleton vector and directly return the image. Defaults to `true`.
"""
heatmap(val; kwargs...) = heatmap(val, HeatmapOptions(; kwargs...))

function heatmap(val::AbstractArray{T,N}, options::HeatmapOptions) where {T,N}
    N != 4 && throw(InputDimensionError)
    if options.unpack_singleton && size(val, 4) == 1
        return single_heatmap(val[:, :, :, 1], options)
    end
    if options.process_batch
        hs = single_heatmap(val, options)
        return [hs[:, :, i] for i in axes(hs, 3)]
    end
    return [single_heatmap(v, options) for v in eachslice(val; dims=4)]
end

# Lower level function, mapped along batch dimension
function single_heatmap(val, options::HeatmapOptions)
    img = dropdims(reduce_color_channel(val, options.reduce); dims=3)
    options.permute && (img = flip_wh(img))
    cs = get_colorscheme(options)
    return get(cs, img, options.rangescale)
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

#=================#
# XAIBase support #
#=================#

"""
    heatmap(expl::Explanation)

Visualize `Explanation` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batch dimension) for `explanation.val`.

This will use the default heatmapping style for the given type of explanation.
Defaults can be overridden via keyword arguments.
"""
heatmap(expl::Explanation; kwargs...) = heatmap(expl.val, HeatmapOptions(expl; kwargs...))

"""
    heatmap(input::AbstractArray, analyzer::AbstractXAIMethod)

Compute an `Explanation` for a given `input` using the XAI method `analyzer` and visualize it
as a vision heatmap.

Any additional arguments and keyword arguments are passed to the analyzer.
Refer to the `analyze` documentation for more information on available keyword arguments.

To customize the heatmapping style, first compute an explanation using `analyze`
and then call [`heatmap`](@ref) on the explanation.
"""
function heatmap(input, analyzer::AbstractXAIMethod, analyze_args...; analyze_kwargs...)
    expl = analyze(input, analyzer, analyze_args...; analyze_kwargs...)
    return heatmap(expl)
end
