module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, berlin, batlow, jet
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze
using Configurations: @option

include("transforms/interface.jl")
include("transforms/reduction.jl")
include("transforms/dimensions.jl")
include("transforms/colormaps.jl")
include("transforms/overlay.jl")
export AbstractTransform
export AbstractReduction
export SumReduction, NormReduction, MaxAbsReduction, SumAbsReduction, AbsSumReduction
export FlipWH, PermuteDims, DropDims
export SequentialColormap, DivergentColormap

include("pipeline.jl") # Combine Transforms
export Pipeline

include("heatmap.jl") # heatmap
include("overlay.jl") # heatmap_overlay
export heatmap, heatmap_overlay

end # module
