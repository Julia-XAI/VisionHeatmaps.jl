# Getting
Let's assume you took the following image,
reshaped it to WHCN format *(width, height, color channels, batch dimension)*
and ran it through a vision model:

```@example 1
using Images
using HTTP # hide
url = HTTP.URI("https://raw.githubusercontent.com/Julia-XAI/ExplainableAI.jl/gh-pages/assets/heatmaps/castle.jpg") #hide
img = load(url) #hide
img
```

After classifiying the image as a castle,
you might use an input space attribution method 
(for example from [ExplainableAI.jl](https://github.com/Julia-XAI/ExplainableAI.jl))
to determine which parts of the input contributed most to the classification.

Let's load such an attribution:
```@example 1
using JLD2 # hide
val = load("castle.jld2", "x") # hide
val
```

To make this attribution more interpretable,
we can visualize it as a heatmap:
```@example 1
using VisionHeatmaps
heatmap(val)
```

## Custom heatmap settings
### Color schemes
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



### [Mapping explanations onto the color scheme](@id docs-heatmap-rangescale)
To map a [color-channel-reduced](@ref docs-heatmap-reduce) explanation onto a color scheme,
we first need to normalize all values to the range $[0, 1]$.

For this purpose, two presets are available through the `rangescale` keyword argument:
- `:extrema`: normalize to the minimum and maximum value of the explanation
- `:centered`: normalize to the maximum absolute value of the explanation.
  Values of zero will be mapped to the center of the color scheme.

Depending on the color scheme, one of these presets may be more suitable than the other.
The default color scheme, `seismic`, is centered around zero,
making `:centered` a good choice:

````@example 1
heatmap(val; rangescale=:centered)
````

With the `seismic` colorscheme, the `:extrema` rangescale should be avoided:

````@example 1
heatmap(val; rangescale=:extrema)
````

However, for the `inferno` color scheme, which is not centered around zero,
`:extrema` leads to a heatmap with higher contrast.

````@example 1
heatmap(val; colorscheme=ColorSchemes.inferno, rangescale=:centered)
````

````@example 1
heatmap(val; colorscheme=ColorSchemes.inferno, rangescale=:extrema)
````

### [Color channel reduction](@id docs-heatmap-reduce)
Explanations have the same dimensionality as the inputs to the classifier.
For images with multiple color channels,
this means that the explanation also has a "color channel" dimension.

The keyword argument `reduce` can be used to reduce this dimension
to a single scalar value for each pixel.
The following presets are available:
- `:sum`: sum up color channels (default setting)
- `:norm`: compute 2-norm over the color channels
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

The differences are subtle, but there is a blue hue
in the place of the street sign when using `reduce=:sum`.

For the full list of `heatmap` keyword arguments, refer to the [`heatmap`](@ref) documentation.