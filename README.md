<div align="center">
	<h1>Feather <img src="feather.svg"/></h1>
	<p>A featherweight declarative instance manager for Roblox.</p>
	<a href="https://blinkybool.github.io/feather/"><strong>Docs</strong></a>
	<br/>
	<a href="https://blinkybool.github.io/feather/api/"><strong>API</strong></a>
	<div></div>
	<br/>
</div>
<!--moonwave-hide-before-this-line-->

Roact is great for managing a hierarchy of instances as a function of some underlying state, but when handling tens of thousands of instances, the memory usage becomes a problem.

Feather lets you manage instances with the same `component + props` logic as Roact, using the absolute bare minimum amount of memory usage in the virtual tree, while still being performant.
The key is to not store any host props in the virtual tree, and rely just on the props in function components, which typically have a smaller memory footprint.

The tradeoff is that we can no longer detect which props need to be updated in host components, so they must all be updated. Performance is restored by giving function components their old props table, so they can determine which children/props must be updated.

## Installation

Download the [Latest Release](https://github.com/blinkybool/feather/releases/latest) and drag it into Roblox Studio.

or use [wally](https://github.com/UpliftGames/wally)

```toml
# In wally.toml

[dependencies]
Feather = "blinkybool/feather@0.1.0"
```

## Examples

* [sine-pixel](https://github.com/blinkybool/feather/blob/main/test/pringle.story.lua) ![sine-pixel.story](docs/sine-pixel.gif)

* [pringle](https://github.com/blinkybool/feather/blob/main/test/pringle.story.lua) ![pringle.story](docs/pringle.gif)