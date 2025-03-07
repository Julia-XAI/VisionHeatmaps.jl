"""
   AbstractReduction <: AbstractTransform

Abstract supertype of all color channel reductions.
"""
abstract type AbstractReduction <: AbstractTransform end

reduce_dim3(f, x; kwargs...) = dropdims(reduce(f, x; dims=3, kwargs...); dims=3)

# This default fallback (ab)uses callable structs to reduce code duplication.
# It is more efficient to write custom `apply` methods, see `SumReduction`.
function apply(reduction::AbstractReduction, x::AbstractArray)
    size(x, 3) == 1 && return x # nothing to reduce
    init = zero(eltype(x))
    return reduce_dim3(reduction, x; init=init)
end

"""
    NormReduction()
    
Computes 2-norm over color channels
"""
struct NormReduction <: AbstractReduction end
(::NormReduction)(cs...) = sqrt(sum(cs .^ 2))

"""
    MaxAbsReduction()
    
Computes `maximum(abs, x)` over color channels
"""
struct MaxAbsReduction <: AbstractReduction end
(::MaxAbsReduction)(cs...) = maximum(abs.(cs))

"""
    SumAbsReduction()
    
Computes `sum(abs, x)` over color channels
"""
struct SumAbsReduction <: AbstractReduction end
(::SumAbsReduction)(cs...) = sum(abs, cs)

"""
    AbsSumReduction()
    
Computes `abs(sum(x))` the color channels
"""
struct AbsSumReduction <: AbstractReduction end
(::AbsSumReduction)(cs...) = abs(sum, cs)

"""
    SumReduction()

Sums up color channels.
"""
struct SumReduction <: AbstractReduction end

function apply(::SumReduction, x::AbstractArray)
    size(x, 3) == 1 && return x # nothing to reduce
    return reduce_dim3(+, x)
end
