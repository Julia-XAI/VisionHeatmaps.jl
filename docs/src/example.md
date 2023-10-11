# Getting started
Let's assume you took the following image `img`,
reshaped it to WHCN format *(width, height, color channels, batch dimension)*
and ran it through a vision model:

```@example 1
using Images
using HTTP # hide
asset_dir = HTTP.URI("https://raw.githubusercontent.com/Julia-XAI/VisionHeatmaps.jl/gh-pages/assets/") # hide
img = load(joinpath(asset_dir, "img1.png")) # load image file
```

You might use an input space attribution method 
(for example from [ExplainableAI.jl](https://github.com/Julia-XAI/ExplainableAI.jl))
to determine which parts of the input contributed most to the "saxophone" class.

Let's load such an attribution `val` in WHCN format:
```@example 1
using JLD2 # hide
url = joinpath(asset_dir, "heatmap.jld2") # hide
data_heatmap = download(url) # hide
val = load(data_heatmap, "x") # load precomputed array from file
typeof(val)
```

```@example 1
size(val)
```

To make this attribution more interpretable,
we can visualize it as a heatmap:
```@example 1
using VisionHeatmaps
heatmap(val)
```

## Custom color schemes
We can partially or fully override presets by passing keyword arguments to [`heatmap`](@ref).
For example, we can use a custom color scheme from ColorSchemes.jl using the keyword argument `cs`:

```@example 1
using ColorSchemes
heatmap(val; colorscheme=ColorSchemes.jet)
```

```@example 1
heatmap(val; colorscheme=ColorSchemes.inferno)
```

Refer to the [ColorSchemes.jl catalogue](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/)
for a gallery of available color schemes.

## [Custom color channel reduction](@id docs-heatmap-reduce)
For arrays with multiple color channels, the channels need to be reduced to a single scalar value for each pixel, which is later mapped onto a color scheme.

The following presets are available for this purpose:
- `:sum`: sum up color channels (default setting)
- `:norm`: compute 2-norm over color channels
- `:maxabs`: compute `maximum(abs, x)` over the color channels

```@example 1
heatmap(val; reduce=:sum)
```

```@example 1
heatmap(val; reduce=:norm)
```

```@example 1
heatmap(val; reduce=:maxabs)
```

Using the default `reduce=:sum` visibly leaves more negative values in the heatmap, highlighting only the saxophone.

## [Mapping reduced values onto a color scheme](@id docs-heatmap-rangescale)
To map the now [color-channel-reduced](@ref docs-heatmap-reduce) array onto a color scheme,
we first need to normalize all values to the range $[0, 1]$.

For this purpose, two presets are available through the `rangescale` keyword argument:
- `:extrema`: normalize to the minimum and maximum value in the array.
- `:centered`: normalize to the maximum absolute value of the array.
  Values of zero will be mapped to the center of the color scheme.

Depending on the color scheme, one of these presets may be more suitable than the other.
The default color scheme, `seismic`, is centered around zero,
making `:centered` a good choice:

````@example 1
heatmap(val; rangescale=:centered)
````

With centered color schemes such as `seismic`, 
`:extrema` should be avoided, as it leads to visual artifacts:

````@example 1
heatmap(val; rangescale=:extrema)
````

However, for the `inferno` color scheme, which is not centered around zero,
`:extrema` can lead to a heatmap with higher contrast.

````@example 1
heatmap(val; colorscheme=ColorSchemes.inferno, rangescale=:centered)
````

````@example 1
heatmap(val; colorscheme=ColorSchemes.inferno, rangescale=:extrema)
````


For the full list of `heatmap` keyword arguments, refer to the [`heatmap`](@ref) documentation.

## Heatmapping batches
`heatmap` can also be used to visualize input batches.
Let's assume we computed an input space attribution `val_batch` for the following images:

```@example 1
imgs = [load(joinpath(asset_dir, f)) for f in ("img1.png", "img2.png", "img3.png", "img4.png", "img5.png")] # load image files 
```

Once again, we assume that `val_batch` is in WHCN format:

```@example 1
url = joinpath(asset_dir, "heatmaps.jld2") # hide
data_heatmaps = download(url) # hide
val_batch = load(data_heatmaps, "x") # load precomputed array from file
typeof(val_batch)
```

```@example 1
size(val_batch)
```

Calling `heatmap` will automatically return an vector of images:

```@example 1
heatmap(val_batch)
```

These heatmaps can be customized as usual:

```@example 1
heatmap(val_batch; colorscheme=ColorSchemes.inferno, rangescale=:extrema)
```

### Processing batches
The normalization when [mapping values onto a color scheme](@ref docs-heatmap-rangescale) 
can optionally be computed for a batch. 
Using the example of `rangescale=:extrema`, this means that the minimum and maximum value
will be computed over all images in the batch, instead of individually for each image.

Note that this will lead to different heatmaps for each image, based on other images in the batch.

```@example 1
heatmap(val_batch; process_batch=true)
```

```@example 1
heatmap(val_batch; colorscheme=ColorSchemes.inferno, rangescale=:extrema, process_batch=true)
```

### Consistent output types
As we have seen, calling `heatmap` on an array of size `(W, H, C, 1)` 
will return a single heatmap image, while calling it on an array of size `(W, H, C, N)`
will return a vector of heatmap. 
This is due to the fact that VisionHeatmaps.jl will automatically "unpack" singleton vectors of heatmaps.

If this behavior is not desired, the keyword argument `unpack_singleton` can be set to `false`:
```@example 1
heatmap(val; unpack_singleton=false)
```