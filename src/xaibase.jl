const HEATMAP_PRESETS = Dict{Symbol,Function}(
    :attribution => (kwargs...) -> HeatmapOptions(; colorscheme=:seismic, reduce=:sum, rangescale=:centered, kwargs...),
    :sensitivity => (kwargs...) -> HeatmapOptions(; colorscheme=:grays, reduce=:norm, rangescale=:extrema, kwargs...),
    :cam         => (kwargs...) -> HeatmapOptions(; colorscheme=:jet, reduce=:sum, rangescale=:extrema, kwargs...),
)

DEFAULT_HEATMAP_PRESET = (kwargs...) -> HeatmapOptions(; kwargs...)

# Override HeatmapConfig preset with keyword arguments
function get_heatmapping_options(expl::Explanation; kwargs...)
    constructor = get(HEATMAP_PRESETS, expl.heatmap, DEFAULT_HEATMAP_PRESET)
    options = constructor(kwargs...)
    return options
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
function heatmap(expl::Explanation; kwargs...)
    options = get_heatmapping_options(expl; kwargs...)
    return heatmap(expl.val, options)
end

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
