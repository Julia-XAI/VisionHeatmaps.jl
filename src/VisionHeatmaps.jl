module VisionHeatmaps

using ColorSchemes: ColorScheme, get, RdBu, viridis, jet
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze
using Configurations: @option

include("config.jl")  # HeatmapOptions
include("heatmap.jl") # heatmap
include("overlay.jl") # heatmap_overlay

export heatmap, heatmap_overlay

end # module
