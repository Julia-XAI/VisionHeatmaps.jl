"""
    Colormap()
    Colormap(name::Symbol)
    Colormap(name::Symbol, colormap)

Apply a `colormap` from ColorSchemes.jl, turning an array of values into an image.
Defaults to `:batlow`.

Values are expected to be normalized to the unit interval `[0, 1]`, e.g. by `ExtremaNormalization()` or `CenteredNormalization()` from XAIBase.jl.
Values outside of this interval are clamped.

Normalizations are meant to be paired with a kind of colormap:
`ExtremaNormalization` with sequential colormaps (e.g. `:batlow`),
`CenteredNormalization` with diverging colormaps (e.g. `:berlin`).
Composing a normalization with a colormap that ColorSchemes.jl describes as the other kind emits a warning.
"""
struct Colormap <: AbstractTransform
    name::Symbol
    colormap::ColorScheme
end
Colormap(name::Symbol) = Colormap(name, colorschemes[name])
Colormap() = Colormap(:batlow)

Base.show(io::IO, t::Colormap) = print(io, "Colormap(:$(t.name))")

apply(t::Colormap, x::AbstractArray) = get(t.colormap, x, :clamp)

#=====================================#
# Coupling to normalization functions #
#=====================================#

# Kind of colormap a normalization is meant to be paired with.
# Normalizations of unknown kind return `nothing` and are not checked.
function colormap_kind(n::AbstractNormalization)
    signed = issigned(n)
    isnothing(signed) && return nothing
    return signed ? :diverging : :sequential
end

# ColorSchemes.jl only describes the kind of a colormap in its free-text notes.
# Colormaps of unknown kind return `nothing` and are not checked.
function colormap_kind(c::Colormap)
    notes = c.colormap.notes
    occursin(r"diverging"i, notes) && return :diverging
    occursin(r"sequential"i, notes) && return :sequential
    return nothing
end

function default_colormap(n::AbstractNormalization)
    return colormap_kind(n) == :diverging ? Colormap(:berlin) : Colormap(:batlow)
end

function check_colormap(n::AbstractNormalization, c::Colormap)
    expected, actual = colormap_kind(n), colormap_kind(c)
    if !isnothing(expected) && !isnothing(actual) && expected != actual
        @warn "$n is meant to be paired with a $expected colormap, but ColorSchemes.jl describes $c as $actual. Consider using $(default_colormap(n)) instead."
    end
    return nothing
end

# Colormaps are checked against the preceding normalization when a pipeline is composed.
function compose(n::AbstractNormalization, c::Colormap)
    check_colormap(n, c)
    return Pipeline(n, c)
end
function compose(p::Pipeline, c::Colormap)
    i = findlast(t -> t isa AbstractNormalization, p.transforms)
    isnothing(i) || check_colormap(p.transforms[i], c)
    return Pipeline(p.transforms..., c)
end
