module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze
using Configurations: @option

const AbstractImage{T<:Union{Number,Colorant}} = AbstractArray{T,2}

include("transforms/interface.jl")
export AbstractTransform
include("transforms/reduction.jl")
export AbstractReduction
export SumReduction, NormReduction, MaxAbsReduction, SumAbsReduction, AbsSumReduction
include("transforms/dimensions.jl")
export FlipWH, PermuteDims, DropDims
include("transforms/colormaps.jl")
export SequentialColormap, DivergentColormap
include("transforms/resize.jl")
export ResizeToImage
include("transforms/overlay.jl")
export AlphaOverlay

include("pipeline.jl")
export Pipeline

include("heatmap.jl")
export heatmap

end # module
