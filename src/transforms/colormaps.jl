
# ColorMap(colorscheme, rangescale)
# ChannelwiseColorMap(colorschemes, rangescales) 

"""
    ExtremaColormap(name::Symbol)
    ExtremaColormap(name::Symbol, colorscheme)

Apply a sequential `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:batlow`.
"""
struct ExtremaColormap <: AbstractTransform
    name::Symbol
    colorscheme::ColorScheme
end
ExtremaColormap(name::Symbol) = ExtremaColormap(name, colorschemes[name])
ExtremaColormap() = ExtremaColormap(:batlow)

function Base.show(io::IO, ::MIME"text/plain", t::ExtremaColormap)
    print(io, "ExtremaColormap(:$(t.name))")
end
function Base.show(io::IO, t::ExtremaColormap)
    print(io, "ExtremaColormap(:$(t.name))")
end

apply(t::ExtremaColormap, x) = get(t.colorscheme, x, :extrema)

"""
    CenteredColormap(name::Symbol)
    CenteredColormap(name::Symbol, colorscheme)

Apply a divergent `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:berlin`.
"""
struct CenteredColormap <: AbstractTransform
    name::Symbol
    colorscheme::ColorScheme
end
CenteredColormap(name::Symbol) = CenteredColormap(name, colorschemes[name])
CenteredColormap() = CenteredColormap(:berlin)

function Base.show(io::IO, ::MIME"text/plain", t::CenteredColormap)
    print(io, "CenteredColormap(:$(t.name))")
end
function Base.show(io::IO, t::CenteredColormap)
    print(io, "CenteredColormap(:$(t.name))")
end

apply(t::CenteredColormap, x) = get(t.colorscheme, x, :centered)

# TODO: Implement channel-wise colormaps?
