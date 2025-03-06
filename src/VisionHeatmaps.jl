module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, berlin, batlow, jet
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze
using Configurations: @option

include("transformations/interface.jl")
include("transformations/reduction.jl")
include("transformations/dimensions.jl")
include("transformations/colormaps.jl")
include("transformations/overlay.jl")
export AbstractTransformation
export AbstractReduction
export SumReduction, NormReduction, MaxAbsReduction, SumAbsReduction, AbsSumReduction
export FlipWH, PermuteDims, DropDims
export SequentialColormap, DivergentColormap

include("pipeline.jl") # Combine Transforms
export Pipeline

DEFAULT_PIPELINE_SEQUENTIAL = NormReduction() |> SequentialColormap() |> FlipWH()
DEFAULT_PIPELINE_DIVERGENT = NormReduction() |> DivergentColormap() |> FlipWH()

include("config.jl")  # HeatmapOptions
include("heatmap.jl") # heatmap
include("overlay.jl") # heatmap_overlay
export heatmap, heatmap_overlay

end # module
