# VisionHeatmaps.jl

## Version `v2.1.0`
* ![Feature][badge-feature] Support overlays over batches of images

## Version `v2.0.1`
* ![Bugfix][badge-bugfix] Fix reductions on single color channel ([#16])

## Version `v2.0.0`
* ![BREAKING][badge-breaking] Breaking rewrite adding customizable heatmapping pipelines. Check out the new documentation for more information. ([#15])
* ![BREAKING][badge-breaking] Update default color schemes ([#13], [#14])

## Version `v1.5.0`
* ![Feature][badge-feature] Allow alpha maps in `heatmap_overlay` ([#11][pr-11])

## Version `v1.4.0`
* ![Feature][badge-feature] Add heatmap overlays on Explanations ([#10][pr-10])
* ![Maintenance][badge-maintenance] Use Configurations.jl for keyword argument handling ([#9][pr-9])

## Version `v1.3.1`
* ![Feature][badge-feature] Add XAIBase dependency ([#7][pr-7], [#8][pr-8])

## Version `v1.2.0`
* ![Feature][badge-feature] Add heatmap overlays ([#5][pr-5])
* ![Feature][badge-feature] Add color channel reduction presets `:sumabs` and `:abssum` ([#6][pr-6]) 

## Version `v1.1.0`
* ![Feature][badge-feature] Access color schemes through their symbols ([#3][pr-3])

## Version `v1.0.0`
* Initial release

[#15]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/15
[#14]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/14
[#13]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/13
[pr-11]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/11
[pr-10]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/10
[pr-9]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/9
[pr-8]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/8
[pr-7]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/7
[pr-6]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/6
[pr-5]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/5
[pr-3]: https://github.com/Julia-XAI/VisionHeatmaps.jl/pull/3

<!--
# Badges
![BREAKING][badge-breaking]
![Deprecation][badge-deprecation]
![Feature][badge-feature]
![Enhancement][badge-enhancement]
![Bugfix][badge-bugfix]
![Experimental][badge-experimental]
![Maintenance][badge-maintenance]
![Documentation][badge-docs]
-->

[badge-breaking]: https://img.shields.io/badge/BREAKING-red.svg
[badge-deprecation]: https://img.shields.io/badge/deprecation-orange.svg
[badge-feature]: https://img.shields.io/badge/feature-green.svg
[badge-enhancement]: https://img.shields.io/badge/enhancement-blue.svg
[badge-bugfix]: https://img.shields.io/badge/bugfix-purple.svg
[badge-security]: https://img.shields.io/badge/security-black.svg
[badge-experimental]: https://img.shields.io/badge/experimental-lightgrey.svg
[badge-maintenance]: https://img.shields.io/badge/maintenance-gray.svg
[badge-docs]: https://img.shields.io/badge/docs-orange.svg