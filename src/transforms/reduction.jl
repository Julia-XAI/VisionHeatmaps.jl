"""
   AbstractReduction <: Transform

Abstract supertype of all color channel reductions.
"""
abstract type AbstractReduction <: Transform end
function apply(t::AbstractReduction, x::AbstractArray)
    size(x, 3) == 1 && return x # nothing to reduce
    init = zero(eltype(val))
    return reduce(t, val; dims=3, init=init)
end

"""
    NormReduction()
    
Computes 2-norm over color channels
"""
struct NormReduction <: AbstractChannelReduction end
(::NormReduction)(cs...) = sqrt(sum(c .^ 2))

"""
    MaxAbsReduction()
    
Computes `maximum(abs, x)` over color channels
"""
struct MaxAbsReduction <: AbstractChannelReduction end
(::MaxAbsReduction)(cs...) = maximum(abs, cs)

"""
    SumAbsReduction()
    
Computes `sum(abs, x)` over color channels
"""
struct SumAbsReduction <: AbstractChannelReduction end
(::SumAbsReduction)(cs...) = sum(abs, cs)

"""
    AbsSumReduction()
    
Computes `abs(sum(x))` the color channels
"""
struct AbsSumReduction <: AbstractChannelReduction end
(::SumAbsReduction)(cs...) = abs(sum, cs)

"""
    SumReduction()

Sums up color channels.
"""
struct SumReduction <: AbstractChannelReduction end

function apply(::SumReduction, x::AbstractArray)
    size(x, 3) == 1 && return x # nothing to reduce
    return reduce(+, val; dims=3)
end
