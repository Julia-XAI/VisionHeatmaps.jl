module VisionHeatmaps

using ColorSchemes: ColorScheme, colorschemes, get, seismic
using ImageTransformations: imresize
using Interpolations: Lanczos
using ImageCore
using Requires: @require

include("heatmap.jl")
include("overlay.jl")

if !isdefined(Base, :get_extension)
    using Requires
    function __init__()
        @require XAIBase = "9b48221d-a747-4c1b-9860-46a1d8ba24a7" include(
            "../ext/VisionHeatmapsXAIBaseExt.jl"
        )
    end
end

export heatmap, heatmap_overlay

end # module
