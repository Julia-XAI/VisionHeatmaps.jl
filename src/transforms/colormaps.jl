"""
    Colormap()
    Colormap(name::Symbol)
    Colormap(name::Symbol, colorscheme)

Apply a `colorscheme` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:batlow`.

Values are expected to be normalized to the unit interval `[0, 1]`, e.g. by `ExtremaNormalization()` or `CenteredNormalization()` from XAIBase.jl.
Values outside of this interval are clamped.
"""
struct Colormap <: AbstractTransform
    name::Symbol
    colorscheme::ColorScheme
end
Colormap(name::Symbol) = Colormap(name, colorschemes[name])
Colormap() = Colormap(:batlow)

Base.show(io::IO, t::Colormap) = print(io, "Colormap(:$(t.name))")

apply(t::Colormap, x::AbstractArray) = get(t.colorscheme, x, :clamp)
