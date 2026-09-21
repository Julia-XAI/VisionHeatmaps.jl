module VisionHeatmaps

using Statistics: quantile
using ColorSchemes: ColorScheme, colorschemes, get
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Attribution, AbstractXAIMethod, analyze
using XAIBase: AbstractTransform, Pipeline
using XAIBase: Batch, eachsample, mapsamples
using XAIBase: AbstractPooling, UnsignedPooling, SignedPooling, pool
using XAIBase: SumPooling, MaxPooling, SignedNoPooling, UnsignedNoPooling
using XAIBase: SumAbsPooling, AbsSumPooling, MaxAbsPooling, NormPooling, SquaredNormPooling
using XAIBase: AbstractNormalization, ExtremaNormalization, CenteredNormalization
using XAIBase: BatchedNormalization
using XAIBase: normalize, default_normalization

const AbstractImage{T <: Union{Number, Colorant}} = AbstractArray{T, 2}
const AbstractImageBatch{T <: Union{Number, Colorant}} = AbstractArray{T, 3}

include("transforms/interface.jl")
include("transforms/dimensions.jl")
export FlipImage, PermuteDims, DropDims
include("transforms/clamp.jl")
export PercentileClip
include("transforms/colormaps.jl")
export Colormap
include("transforms/resize.jl")
export ResizeToImage
include("transforms/overlay.jl")
export AlphaOverlay
include("transforms/batch.jl")

# Re-export transforms, pipelines, attribution pooling and normalization functions from XAIBase
export AbstractTransform, Pipeline
export SumPooling, MaxPooling, SignedNoPooling, UnsignedNoPooling
export SumAbsPooling, AbsSumPooling, MaxAbsPooling, NormPooling, SquaredNormPooling
export ExtremaNormalization, CenteredNormalization, BatchedNormalization

include("pipeline.jl")

include("heatmap.jl")
export heatmap

end # module
