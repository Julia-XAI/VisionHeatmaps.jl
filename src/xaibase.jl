struct HeatmapConfig
    colorscheme::Symbol
    reduce::Symbol
    rangescale::Symbol
end

const DEFAULT_HEATMAP_PRESET = HeatmapConfig(
    DEFAULT_COLORSCHEME, DEFAULT_REDUCE, DEFAULT_RANGESCALE
)

const HEATMAP_PRESETS = Dict{Symbol,HeatmapConfig}(
    :attribution => HeatmapConfig(:seismic, :sum, :centered),
    :sensitivity => HeatmapConfig(:grays, :norm, :extrema),
    :cam         => HeatmapConfig(:jet, :sum, :extrema),
)

# Select HeatmapConfig preset based on heatmapping style in Explanation
function get_heatmapping_config(heatmap::Symbol)
    return get(HEATMAP_PRESETS, heatmap, DEFAULT_HEATMAP_PRESET)
end

# Override HeatmapConfig preset with keyword arguments
function get_heatmapping_config(expl::Explanation; kwargs...)
    c = get_heatmapping_config(expl.heatmap)

    colorscheme = get(kwargs, :colorscheme, c.colorscheme)
    rangescale  = get(kwargs, :rangescale, c.rangescale)
    reduce      = get(kwargs, :reduce, c.reduce)
    return HeatmapConfig(colorscheme, reduce, rangescale)
end

"""
    heatmap(explanation)

Visualize `Explanation` from XAIBase as a vision heatmap.
Assumes WHCN convention (width, height, channels, batchsize) for `explanation.val`.
"""
function heatmap(expl::Explanation; kwargs...)
    c = get_heatmapping_config(expl; kwargs...)
    return heatmap(
        expl.val;
        colorscheme=c.colorscheme,
        reduce=c.reduce,
        rangescale=c.rangescale,
        kwargs...,
    )
end

"""
    heatmap(input, analyzer)

Compute an `Explanation` for a given `input` using the XAI method `analyzer` and visualize it
as a vision heatmap.

Any additional arguments and keyword arguments are passed to the analyzer.
Refer to the `analyze` documentation for more information on available keyword arguments.

To customize the heatmapping style, first compute an explanation using `analyze`
and then call [`heatmap`](@ref) on the explanation.
"""
function heatmap(input, analyzer::AbstractXAIMethod, args...; kwargs...)
    expl = analyze(input, analyzer, args...; kwargs...)
    return heatmap(expl)
end
