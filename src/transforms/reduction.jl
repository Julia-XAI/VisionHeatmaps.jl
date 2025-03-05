abstract type AbstractChannelReduction <: Transform end 

"""
    SumReduction()

Sums up color channels.
"""
struct SumReduction <: AbstractChannelReduction end

"""
    NormReduction()
    
Computes 2-norm over color channels
"""
struct NormReduction <: AbstractChannelReduction end

"""
    MaxAbsReduction()
    
Computes `maximum(abs, x)` over color channels
"""
struct MaxAbsReduction <: AbstractChannelReduction end

"""
    SumAbsReduction()
    
Computes `sum(abs, x)` over color channels
"""
struct SumReduction <: AbstractChannelReduction end

"""
    AbsSumReduction()
    
Computes `abs(sum(x))` the color channels
"""
struct AbsSumReduction <: AbstractChannelReduction end
