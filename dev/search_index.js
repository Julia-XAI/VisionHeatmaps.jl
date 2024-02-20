var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = VisionHeatmaps","category":"page"},{"location":"#VisionHeatmaps.jl","page":"Home","title":"VisionHeatmaps.jl","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for VisionHeatmaps.jl.","category":"page"},{"location":"#Installation","page":"Home","title":"Installation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"To install this package and its dependencies, open the Julia REPL and run","category":"page"},{"location":"","page":"Home","title":"Home","text":"]add VisionHeatmaps","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"heatmap\nheatmap_overlay","category":"page"},{"location":"#VisionHeatmaps.heatmap","page":"Home","title":"VisionHeatmaps.heatmap","text":"heatmap(x::AbstractArray)\n\nVisualize 4D arrays as heatmaps, assuming the WHCN convention for input array dimensions (width, height, color channels, batch dimension).\n\nKeyword arguments\n\ncolorscheme::Union{ColorScheme,Symbol}: Color scheme from ColorSchemes.jl. Defaults to seismic.\nreduce::Symbol: Selects how color channels are reduced to a single number to apply a color scheme. The following methods can be selected, which are then applied over the color channels for each \"pixel\" in the array:\n:sum: sum up color channels\n:norm: compute 2-norm over the color channels\n:maxabs: compute maximum(abs, x) over the color channels\n:sumabs: compute sum(abs, x) over the color channels\n:abssum: compute abs(sum(x)) over the color channels\nDefaults to :sum.\nrangescale::Symbol: Selects how the color channel reduced heatmap is normalized before the color scheme is applied. Can be either :extrema or :centered. Defaults to :centered.\npermute::Bool: Whether to flip W&H input channels. Default is true.\nprocess_batch::Bool: When heatmapping a batch, setting process_batch=true will apply the rangescale normalization to the entire batch instead of computing it individually for each sample in the batch. Defaults to false.\nunpack_singleton::Bool: If false, heatmap will always return a vector of images. When heatmapping a batch with a single sample, setting unpack_singleton=true will unpack the singleton vector and directly return the image. Defaults to true.\n\n\n\n\n\nheatmap(expl::Explanation)\n\nVisualize Explanation from XAIBase as a vision heatmap. Assumes WHCN convention (width, height, channels, batch dimension) for explanation.val.\n\nThis will use the default heatmapping style for the given type of explanation. Defaults can be overridden via keyword arguments.\n\n\n\n\n\nheatmap(input::AbstractArray, analyzer::AbstractXAIMethod)\n\nCompute an Explanation for a given input using the XAI method analyzer and visualize it as a vision heatmap.\n\nAny additional arguments and keyword arguments are passed to the analyzer. Refer to the analyze documentation for more information on available keyword arguments.\n\nTo customize the heatmapping style, first compute an explanation using analyze and then call heatmap on the explanation.\n\n\n\n\n\n","category":"function"},{"location":"#VisionHeatmaps.heatmap_overlay","page":"Home","title":"VisionHeatmaps.heatmap_overlay","text":"heatmap_overlay(val, image)\n\nCreate a heatmap from val and overlay it on top of an image. Assumes 4D input array following the WHCN convention (width, height, color channels, batch dimension) and batch size 1.\n\nKeyword arguments\n\nalpha::Real: Opacity of the heatmap overlay. Defaults to 0.6.\nresize_method: Method used to resize the heatmap in case of a size mismatch with the image.   Defaults to Lanczos(1) from Interpolations.jl.\n\nFurther keyword arguments are passed to heatmap. Refer to the heatmap documentation for more information.\n\n\n\n\n\nheatmap_overlay(expl::Explanation, image)\n\nVisualize Explanation from XAIBase as a vision heatmap and overlay it on top of an image. Assumes WHCN convention (width, height, channels, batch dimension) for explanation.val and batch size 1.\n\nThis will use the default heatmapping style for the given type of explanation. Refer to the heatmap and heatmap_overlay documentation for a list of supported keyword arguments that can be used to override the defaults.\n\n\n\n\n\n","category":"function"},{"location":"example/#Getting-started","page":"Getting started","title":"Getting started","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Let's assume you took the following image img, reshaped it to WHCN format (width, height, color channels, batch dimension) and ran it through a vision model:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"using Images\nusing HTTP # hide\nasset_dir = HTTP.URI(\"https://raw.githubusercontent.com/Julia-XAI/VisionHeatmaps.jl/gh-pages/assets/\") # hide\nimg = load(joinpath(asset_dir, \"img1.png\")) # load image file","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"You might use an input space attribution method  (for example from ExplainableAI.jl) to determine which parts of the input contributed most to the \"saxophone\" class.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Let's load such an attribution val in WHCN format:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"using JLD2 # hide\nurl = joinpath(asset_dir, \"heatmap.jld2\") # hide\ndata_heatmap = download(url) # hide\nval = load(data_heatmap, \"x\") # load precomputed array from file\ntypeof(val)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"size(val)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"To make this attribution more interpretable, we can visualize it as a heatmap:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"using VisionHeatmaps\nheatmap(val)","category":"page"},{"location":"example/#Custom-color-schemes","page":"Getting started","title":"Custom color schemes","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"We can partially or fully override presets by passing keyword arguments to heatmap. For example, we can use a custom color scheme from ColorSchemes.jl using the keyword argument cs:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"using ColorSchemes\nheatmap(val; colorscheme=ColorSchemes.jet)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; colorscheme=ColorSchemes.inferno)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Refer to the ColorSchemes.jl catalogue for a gallery of available color schemes.","category":"page"},{"location":"example/#docs-heatmap-reduce","page":"Getting started","title":"Custom color channel reduction","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"For arrays with multiple color channels, the channels need to be reduced to a single scalar value for each pixel, which is later mapped onto a color scheme.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"The following presets are available for this purpose:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":":sum: sum up color channels (default setting)\n:norm: compute 2-norm over color channels\n:maxabs: compute maximum(abs, x) over the color channels","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; reduce=:sum)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; reduce=:norm)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; reduce=:maxabs)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Using the default reduce=:sum visibly leaves more negative values in the heatmap, highlighting only the saxophone.","category":"page"},{"location":"example/#docs-heatmap-rangescale","page":"Getting started","title":"Mapping reduced values onto a color scheme","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"To map the now color-channel-reduced array onto a color scheme, we first need to normalize all values to the range 0 1.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"For this purpose, two presets are available through the rangescale keyword argument:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":":extrema: normalize to the minimum and maximum value in the array.\n:centered: normalize to the maximum absolute value of the array. Values of zero will be mapped to the center of the color scheme.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Depending on the color scheme, one of these presets may be more suitable than the other. The default color scheme, seismic, is centered around zero, making :centered a good choice:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; rangescale=:centered)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"With centered color schemes such as seismic,  :extrema should be avoided, as it leads to visual artifacts:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; rangescale=:extrema)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"However, for the inferno color scheme, which is not centered around zero, :extrema can lead to a heatmap with higher contrast.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; colorscheme=ColorSchemes.inferno, rangescale=:centered)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; colorscheme=ColorSchemes.inferno, rangescale=:extrema)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"For the full list of heatmap keyword arguments, refer to the heatmap documentation.","category":"page"},{"location":"example/#Heatmapping-batches","page":"Getting started","title":"Heatmapping batches","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap can also be used to visualize input batches. Let's assume we computed an input space attribution val_batch for the following images:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"imgs = [load(joinpath(asset_dir, f)) for f in (\"img1.png\", \"img2.png\", \"img3.png\", \"img4.png\", \"img5.png\")] # load image files ","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Once again, we assume that val_batch is in WHCN format:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"url = joinpath(asset_dir, \"heatmaps.jld2\") # hide\ndata_heatmaps = download(url) # hide\nval_batch = load(data_heatmaps, \"x\") # load precomputed array from file\ntypeof(val_batch)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"size(val_batch)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Calling heatmap will automatically return an vector of images:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val_batch)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"These heatmaps can be customized as usual:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val_batch; colorscheme=ColorSchemes.inferno, rangescale=:extrema)","category":"page"},{"location":"example/#Processing-batches","page":"Getting started","title":"Processing batches","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"The normalization when mapping values onto a color scheme  can optionally be computed for a batch.  Using the example of rangescale=:extrema, this means that the minimum and maximum value will be computed over all images in the batch, instead of individually for each image.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"Note that this will lead to different heatmaps for each image, based on other images in the batch.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val_batch; process_batch=true)","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val_batch; colorscheme=ColorSchemes.inferno, rangescale=:extrema, process_batch=true)","category":"page"},{"location":"example/#Consistent-output-types","page":"Getting started","title":"Consistent output types","text":"","category":"section"},{"location":"example/","page":"Getting started","title":"Getting started","text":"As we have seen, calling heatmap on an array of size (W, H, C, 1)  will return a single heatmap image, while calling it on an array of size (W, H, C, N) will return a vector of heatmap.  This is due to the fact that VisionHeatmaps.jl will automatically \"unpack\" singleton vectors of heatmaps.","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"If this behavior is not desired, the keyword argument unpack_singleton can be set to false:","category":"page"},{"location":"example/","page":"Getting started","title":"Getting started","text":"heatmap(val; unpack_singleton=false)","category":"page"}]
}
