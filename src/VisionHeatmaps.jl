module VisionHeatmaps

using Statistics: quantile
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
export NormReduction, SumReduction, MaxAbsReduction, SumAbsReduction, AbsSumReduction
include("transforms/dimensions.jl")
export FlipImage, PermuteDims, DropDims
include("transforms/clamp.jl")
export PercentileClip
include("transforms/colormaps.jl")
export ExtremaColormap, CenteredColormap
include("transforms/resize.jl")
export ResizeToImage
include("transforms/overlay.jl")
export AlphaOverlay

include("pipeline.jl")
export Pipeline

include("heatmap.jl")
export heatmap

end # module
