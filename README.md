# VisionHeatmaps.jl

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://julia-xai.github.io/VisionHeatmaps.jl/stable/)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://julia-xai.github.io/VisionHeatmaps.jl/dev/)
[![Build Status](https://github.com/Julia-XAI/VisionHeatmaps.jl/actions/workflows/CI.yml/badge.svg?branch=main)](https://github.com/Julia-XAI/VisionHeatmaps.jl/actions/workflows/CI.yml?query=branch%3Amain)
[![Coverage](https://codecov.io/gh/Julia-XAI/VisionHeatmaps.jl/branch/main/graph/badge.svg)](https://codecov.io/gh/Julia-XAI/VisionHeatmaps.jl)
[![Code Style: Runic](https://img.shields.io/badge/code_style-%E1%9A%B1%E1%9A%A2%E1%9A%BE%E1%9B%81%E1%9A%B2-black)](https://github.com/fredrikekre/Runic.jl)
[![Aqua.jl](https://raw.githubusercontent.com/JuliaTesting/Aqua.jl/master/badge.svg)](https://github.com/JuliaTesting/Aqua.jl)
[![JET.jl](https://img.shields.io/badge/%F0%9F%9B%A9%EF%B8%8F_tested_with-JET.jl-233f9a)](https://github.com/aviatesk/JET.jl)

Julia package for visualization of input space attributions for vision models.

![image of saxophone](https://github.com/Julia-XAI/VisionHeatmaps.jl/blob/gh-pages/assets/img1.png)
![heatmap of saxophone](https://github.com/Julia-XAI/VisionHeatmaps.jl/blob/gh-pages/assets/heatmap1.png)

For more information, take a look at the [documentation](https://julia-xai.github.io/VisionHeatmaps.jl/stable/).

## Installation
To install this package and its dependencies, open the Julia REPL and run

```julia-repl
]add VisionHeatmaps
```

## Related packages
* [TextHeatmaps.jl](https://github.com/Julia-XAI/TextHeatmaps.jl):
  Sibling package for visualization of sentiment analysis and input space attributions of NLP models.
* [Julia-XAI](https://github.com/Julia-XAI): 
  VisionHeatmaps.jl was designed to visualize explanations from the Julia-XAI ecosystem
  and provides methods for the interface defined by [XAIBase.jl](https://github.com/Julia-XAI/XAIBase.jl).