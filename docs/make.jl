using VisionHeatmaps
using Documenter

DocMeta.setdocmeta!(VisionHeatmaps, :DocTestSetup, :(using VisionHeatmaps); recursive=true)

makedocs(;
    modules=[VisionHeatmaps],
    authors="Adrian Hill <gh@adrianhill.de>",
    repo="https://github.com/Julia-XAI/VisionHeatmaps.jl/blob/{commit}{path}#{line}",
    sitename="VisionHeatmaps.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Julia-XAI.github.io/VisionHeatmaps.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md", "Getting started" => "example.md"],
)

deploydocs(; repo="github.com/Julia-XAI/VisionHeatmaps.jl", devbranch="main")
