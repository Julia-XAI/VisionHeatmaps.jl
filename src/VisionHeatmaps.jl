module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, berlin, batlow, jet
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze
using Configurations: @option

include("transform_pipeline.jl")
export Transform, Pipeline

include("transforms/reduction.jl")
export AbstractReduction
export SumReduction, NormReduction, MaxAbsReduction, SumAbsReduction, AbsSumReduction

include("transforms/colormapping.jl")
include("transforms/overlay.jl")
include("transforms/flip.jl")

include("config.jl")  # HeatmapOptions
include("heatmap.jl") # heatmap
include("overlay.jl") # heatmap_overlay

export heatmap, heatmap_overlay

end # module
