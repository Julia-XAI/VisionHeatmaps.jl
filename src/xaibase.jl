const HEATMAP_PRESETS = Dict{
    Symbol,@NamedTuple{colorscheme::Symbol, reduce::Symbol, rangescale::Symbol}
}(
    :attribution => (colorscheme=:seismic, reduce=:sum, rangescale=:centered),
    :sensitivity => (colorscheme=:grays, reduce=:norm, rangescale=:extrema),
    :cam         => (colorscheme=:jet, reduce=:sum, rangescale=:extrema),
)

DEFAULT_HEATMAP_PRESET = (
    colorscheme=DEFAULT_COLORSCHEME, reduce=DEFAULT_REDUCE, rangescale=DEFAULT_RANGESCALE
),

# Override HeatmapConfig preset with keyword arguments
function HeatmapOptions(expl::Explanation; kwargs...)
    c = get(HEATMAP_PRESETS, expl.heatmap, DEFAULT_HEATMAP_PRESET)
    return HeatmapOptions(;
        colorscheme=c.colorscheme, reduce=c.reduce, rangescale=c.rangescale, kwargs...
    )
end

#=========#
# Heatmap #
#=========#

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
