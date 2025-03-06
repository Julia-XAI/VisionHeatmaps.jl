

# ColorMap(colorscheme, rangescale)
# ChannelwiseColorMap(colorschemes, rangescales) 

"""
    SequentialColormap(colorscheme)

Apply a sequential `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:batlow`.
"""
struct SequentialColormap <: AbstractTransformation
    colorscheme::ColorScheme
    # TODO: check if sequential
end
SequentialColormap(name::Symbol) = SequentialColormap(colorschemes[name])
SequentialColormap() = SequentialColormap(batlow)

apply(t::SequentialColormap, x) = get(t.colorscheme, x, :extrema)

"""
    DivergentColormap(colorscheme)

Apply a divergent `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:berlin`.
"""
struct DivergentColormap <: AbstractTransformation
    colorscheme::ColorScheme
    # TODO: check if divergent
end
DivergentColormap(name::Symbol) = DivergentColormap(colorschemes[name])
DivergentColormap() = DivergentColormap(berlin)

apply(t::DivergentColormap, x) = get(t.colorscheme, x, :centered)


# TODO: Implement channel-wise colormaps?