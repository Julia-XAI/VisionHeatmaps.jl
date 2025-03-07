"""
    PercentileClip()
    PercentileClip(lower, upper)

Clip values  outside of the specified percentiles of values.
Bounds default to `0.001` and `0.999` (99.9% percentiles).
"""
struct PercentileClip{T<:AbstractFloat} <: AbstractTransform
    lower::T
    upper::T

    function PercentileClip(lower::T, upper::T) where {T<:AbstractFloat}
        if lower < 0 || lower >= upper
            throw(DomainError("lower must be in the range [0, upper)"))
        end
        if upper <= lower || upper > 1
            throw(DomainError("upper must be in the range (lower, 1]"))
        end
        return new{T}(lower, upper)
    end
end
PercentileClip() = PercentileClip(0.001, 0.999)

function apply(t::PercentileClip, x)
    lb = quantile(x[:], t.lower)
    ub = quantile(x[:], t.upper)
    return clamp.(x, lb, ub)
end
