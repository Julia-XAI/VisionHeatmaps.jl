module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, seismic
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore

include("heatmap.jl")
include("overlay.jl")

export heatmap, heatmap_overlay

end # module
