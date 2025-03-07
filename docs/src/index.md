```@meta
CurrentModule = VisionHeatmaps
```

# VisionHeatmaps.jl
Documentation for [VisionHeatmaps.jl](https://github.com/Julia-XAI/VisionHeatmaps.jl).

## Installation
To install this package and its dependencies, open the Julia REPL and run

```julia-repl
]add VisionHeatmaps
```

## API
```@docs
heatmap
Pipeline
AbstractTransform
```

### [Color-channel reduction](@id api-reduction)
```@docs
NormReduction
SumReduction
MaxAbsReduction
SumAbsReduction
AbsSumReduction
```

### Manipulating array dimensions
```@docs
FlipImage
PermuteDims 
DropDims
```

### Outlier removal
```@docs
PercentileClip
```

### Colormaps
Turn numerical arrays to images by applying color schemes:
```@docs
ExtremaColormap
CenteredColormap
```

### Resizing
```@docs
ResizeToImage
```

### Image overlays
```@docs
AlphaOverlay
```
