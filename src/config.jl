const DEFAULT_COLORSCHEME = :seismic
const DEFAULT_REDUCE = :sum
const DEFAULT_RANGESCALE = :centered

@option struct HeatmapOptions
    colorscheme::Union{ColorScheme,Symbol} = DEFAULT_COLORSCHEME
    reduce::Symbol = DEFAULT_REDUCE
    rangescale::Symbol = DEFAULT_RANGESCALE
    permute::Bool = true
    process_batch::Bool = false
    unpack_singleton::Bool = true
end

get_colorscheme(options::HeatmapOptions) = get_colorscheme(options.colorscheme)
get_colorscheme(c::ColorScheme) = c
get_colorscheme(s::Symbol)::ColorScheme = colorschemes[s]

#=================#
# XAIBase support #
#=================#

const HEATMAP_PRESETS = Dict{
    Symbol,@NamedTuple{colorscheme::Symbol, reduce::Symbol, rangescale::Symbol}
}(
    :attribution => (colorscheme=:seismic, reduce=:sum, rangescale=:centered),
    :sensitivity => (colorscheme=:grays, reduce=:norm, rangescale=:extrema),
    :cam         => (colorscheme=:jet, reduce=:sum, rangescale=:extrema),
)
const DEFAULT_HEATMAP_PRESET = (
    colorscheme=DEFAULT_COLORSCHEME, reduce=DEFAULT_REDUCE, rangescale=DEFAULT_RANGESCALE
)

# Override HeatmapOptions preset with keyword arguments
function HeatmapOptions(expl::Explanation; kwargs...)
    c = get(HEATMAP_PRESETS, expl.heatmap, DEFAULT_HEATMAP_PRESET)
    return HeatmapOptions(;
        colorscheme=c.colorscheme, reduce=c.reduce, rangescale=c.rangescale, kwargs...
    )
end
