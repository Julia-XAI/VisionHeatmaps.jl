"""
   AbstractReduction <: AbstractTransformation

Abstract supertype of all color channel reductions.
"""
abstract type AbstractReduction <: AbstractTransformation end

# This default fallback (ab)uses callable structs to reduce code duplication.
# It is more efficient to write custom `apply` methods, see `SumReduction`.
function apply(reduction::AbstractReduction, x::AbstractArray)
    size(x, 3) == 1 && return x # nothing to reduce
    init = zero(eltype(x))
    return reduce(reduction, x; dims=3, init=init)
end

"""
    NormReduction()
    
Computes 2-norm over color channels
"""
struct NormReduction <: AbstractReduction end
(::NormReduction)(cs...) = sqrt(sum(c .^ 2))

"""
    MaxAbsReduction()
    
Computes `maximum(abs, x)` over color channels
"""
struct MaxAbsReduction <: AbstractReduction end
(::MaxAbsReduction)(cs...) = maximum(abs, cs)

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
(::SumAbsReduction)(cs...) = abs(sum, cs)

"""
    SumReduction()

Sums up color channels.
"""
struct SumReduction <: AbstractReduction end

function apply(::SumReduction, x::AbstractArray)
    size(x, 3) == 1 && return x # nothing to reduce
    return reduce(+, val; dims=3)
end
