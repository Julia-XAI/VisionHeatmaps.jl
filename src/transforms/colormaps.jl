
# ColorMap(colorscheme, rangescale)
# ChannelwiseColorMap(colorschemes, rangescales) 

"""
    SequentialColormap(name::Symbol)
    SequentialColormap(name::Symbol, colorscheme)

Apply a sequential `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:batlow`.
"""
struct SequentialColormap <: AbstractTransform
    name::Symbol
    colorscheme::ColorScheme
end
SequentialColormap(name::Symbol) = SequentialColormap(name, colorschemes[name])
SequentialColormap() = SequentialColormap(:batlow)

function Base.show(io::IO, ::MIME"text/plain", t::SequentialColormap)
    print(io, "SequentialColormap(:$(t.name))")
end
function Base.show(io::IO, t::SequentialColormap)
    print(io, "SequentialColormap(:$(t.name))")
end

apply(t::SequentialColormap, x) = get(t.colorscheme, x, :extrema)

"""
    DivergentColormap(name::Symbol)
    DivergentColormap(name::Symbol, colorscheme)

Apply a divergent `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:berlin`.
"""
struct DivergentColormap <: AbstractTransform
    name::Symbol
    colorscheme::ColorScheme
end
DivergentColormap(name::Symbol) = DivergentColormap(name, colorschemes[name])
DivergentColormap() = DivergentColormap(:berlin)

function Base.show(io::IO, ::MIME"text/plain", t::DivergentColormap)
    print(io, "DivergentColormap(:$(t.name))")
end
function Base.show(io::IO, t::DivergentColormap)
    print(io, "DivergentColormap(:$(t.name))")
end

apply(t::DivergentColormap, x) = get(t.colorscheme, x, :centered)

# TODO: Implement channel-wise colormaps?
