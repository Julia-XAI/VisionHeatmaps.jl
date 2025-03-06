module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, berlin, batlow, jet
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze
using Configurations: @option

include("transformations/interface.jl")
include("transformations/reduction.jl")
include("transformations/colormapping.jl")
include("transformations/overlay.jl")
include("transformations/flip.jl")
export AbstractTransformation
export AbstractReduction,
    SumReduction, NormReduction, MaxAbsReduction, SumAbsReduction, AbsSumReduction

include("pipeline.jl") # Combine Transforms
export Pipeline

include("config.jl")  # HeatmapOptions
include("heatmap.jl") # heatmap
include("overlay.jl") # heatmap_overlay
export heatmap, heatmap_overlay

end # module
