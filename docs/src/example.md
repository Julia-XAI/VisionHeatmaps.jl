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

Let's load such an attribution `x` in WHCN format:
```@example 1
using JLD2 # hide
url = joinpath(asset_dir, "heatmap.jld2") # hide
data_heatmap = download(url) # hide
x = load(data_heatmap, "x") # load precomputed array from file
typeof(x)
```

```@example 1
size(x)
```

To make this attribution more interpretable,
we can visualize it as a heatmap:
```@example 1
using VisionHeatmaps
heatmap(x)
```

By default, to support batched explanations, a vector of heatmaps is returned.
Since our following examples don't use batches, we will use the `only` function to unpack singleton heatmaps:

```@example 1
using VisionHeatmaps
heatmap(x) |> only
```

## Custom heatmapping pipelines

VisionHeatmaps internally applies a sequence of image transformations in what we call a [`Pipeline`](@ref).
The default pipeline corresponds to:
```@example 1
pipe = NormPooling() |> ExtremaNormalization() |> Colormap() |> FlipImage()
```

We can apply this pipeline by passing it to `heatmap`:

```@example 1
heatmap(x, pipe) |> only
```

In the following subsection, we will explain and modify this pipeline step by step.

### [Attribution pooling](@id docs-heatmap-pooling)

For arrays with multiple color channels,
the channels need to be reduced to a single scalar value for each pixel,
which is later mapped onto a color scheme.

For this purpose, pipelines use the [attribution pooling functions](@ref api-pooling)
from [XAIBase.jl](https://github.com/Julia-XAI/XAIBase.jl).
Let's compare the two most commonly used ones.
`NormPooling` reduces color channels in the array by taking their norm,
whereas `SumPooling` takes the sum:

```@example 1
pipe = NormPooling() |> ExtremaNormalization() |> Colormap() |> FlipImage()
heatmap(x, pipe) |> only
```

```@example 1
pipe = SumPooling() |> ExtremaNormalization() |> Colormap() |> FlipImage()
heatmap(x, pipe) |> only
```

### Normalization and colormaps

To map the now [pooled](@ref docs-heatmap-pooling) array onto a color scheme,
we first need to normalize all values to the range $[0, 1]$.

For this purpose, two [normalization functions](@ref api-normalization) are available:
- `ExtremaNormalization`: maps the minimum and maximum value in the array onto $[0, 1]$.
- `CenteredNormalization`: maps the negative and positive maximum absolute value of the array onto $[0, 1]$.
  Values of zero will be mapped to the center of the color scheme.

A [`Colormap`](@ref) then applies a color scheme to the normalized values.

Since `NormPooling` only yields positive values, it is well suited for `ExtremaNormalization`
and a sequential color scheme like the default `:batlow`.
`SumPooling` on the other hand can yield positive and negative values.
If zero-values are meaningful,
using `CenteredNormalization` with a divergent color scheme like `:berlin` can be the right choice:

```@example 1
pipe = NormPooling() |> ExtremaNormalization() |> Colormap() |> FlipImage()
heatmap(x, pipe) |> only
```

```@example 1
pipe = SumPooling() |> CenteredNormalization() |> Colormap(:berlin) |> FlipImage()
heatmap(x, pipe) |> only
```

!!! note "Heatmapping XAIBase attributions"
    When heatmapping an `Attribution` from XAIBase.jl,
    the default pipeline follows from its pooling function.
    Unsigned pooling functions like `NormPooling` use `ExtremaNormalization` and `:batlow`,
    whereas signed pooling functions like `SumPooling` use `CenteredNormalization` and `:berlin`.
    Use [`VisionHeatmaps.default_pipeline`](@ref) to inspect or modify the default pipeline.

### Outlier removal

While this isn't part of the default heatmapping pipelines,
previous heatmaps visibly emphasized three "dots" on the neck of the saxophone.
Very high values in explanations tend to desaturate colors.
For this purpose, we provide the adaptive [`PercentileClip`](@ref).
By default, it clips the 0.1-th and 99.9-th percentiles of values.

```@example 1
pipe = SumPooling() |> PercentileClip() |> CenteredNormalization() |> Colormap(:berlin) |> FlipImage()
heatmap(x, pipe) |> only
```

### Custom color schemes
We can use a custom color scheme from [ColorSchemes.jl](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/) in our colormap:

```@example 1
using ColorSchemes
pipe = NormPooling() |> ExtremaNormalization() |> Colormap(:jet) |> FlipImage()
heatmap(x, pipe) |> only
```

```@example 1
pipe = NormPooling() |> ExtremaNormalization() |> Colormap(:viridis) |> FlipImage()
heatmap(x, pipe) |> only
```

We strongly suggest to only use sequential color schemes with `ExtremaNormalization`
and divergent color schemes with `CenteredNormalization`.

!!! tip "ColorSchemes.jl catalogue"
    Refer to the [ColorSchemes.jl catalogue](https://juliagraphics.github.io/ColorSchemes.jl/stable/basics/)
    for a gallery of available color schemes.

### Overlays

Singleton heatmaps can be overlaid on top of the original image.
This can be used to recreate CAM-like heatmaps (usually in combination with [`ResizeToImage`](@ref)):

```@example 1
pipe = NormPooling() |> PercentileClip() |> ExtremaNormalization() |> Colormap(:jet) |> FlipImage() |> AlphaOverlay()
heatmap(x, img, pipe) |> only
```

## Heatmapping batches
`heatmap` can also be used to visualize input batches.
Let's assume we computed an input space attribution `batch` for the following images.

```@example 1
imgs = [load(joinpath(asset_dir, f)) for f in ("img1.png", "img2.png", "img3.png", "img4.png", "img5.png")] # load image files
```

Once again, we assume that `batch` is in WHCN format:

```@example 1
url = joinpath(asset_dir, "heatmaps.jld2") # hide
data_heatmaps = download(url) # hide
batch = load(data_heatmaps, "x") # load precomputed array from file
typeof(batch)
```

```@example 1
size(batch)
```

Calling `heatmap` will automatically return an vector of images:

```@example 1
heatmap(batch)
```

These heatmaps can be customized as usual:

```@example 1
pipe = SumPooling() |> CenteredNormalization() |> Colormap(:berlin) |> FlipImage()
heatmap(batch, pipe)
```

By default, each heatmap in a batch is normalized individually,
so colors can't be compared across heatmaps.
Wrapping the normalization in a [`BatchedNormalization`](@ref XAIBase.BatchedNormalization)
normalizes the whole batch to a shared value range instead:

```@example 1
pipe = SumPooling() |> BatchedNormalization(CenteredNormalization()) |> Colormap(:berlin) |> FlipImage()
heatmap(batch, pipe)
```
