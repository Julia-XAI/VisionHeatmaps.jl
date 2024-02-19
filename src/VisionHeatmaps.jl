module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, seismic
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using XAIBase: Explanation, AbstractXAIMethod, analyze

include("heatmap.jl")
include("overlay.jl")
include("xaibase.jl")

export heatmap, heatmap_overlay

end # module
