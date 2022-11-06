---
sidebar_position: 1
---

# Basic Usage

Feather's syntax and design is inspired by [Roact](https://roblox.github.io/roact/api-reference/).

```lua

-- Host Elements

local e = Feather.createElement

local element = e("Part", {

	Size = Vector3.new(1,2,3),
	CFrame = CFrame.new()
})

-- Function Components

local function sphere(props)

	return e("Part", {

		Size = Vector3.new(props.Diameter, props.Diameter, props.Diameter),
		CFrame = CFrame.new(props.Position),
		Color = props.Color,

		Anchored = true,
	})
end

-- Function Elements

local redSphere = e(sphere, {

	Diameter = 3,
	Position = Vector3.new(0,5,0),
	Color = Color3.new(1,0,0),
})

-- Mounting

local tree = Feather.mount(redSphere, workspace, "RedSphere")

-- Updating

Feather.update(tree, e(sphere, {

	Diameter = 2,
	Position = Vector3.new(0,5,0),
	Color = Color3.new(0,0,1),
}))

-- Unmounting

Feather.unmount(tree)
```

## Examples

Examples can be found in [feather/test](https://github.com/blinkybool/feather/tree/main/test), such as [pringle.story](https://github.com/blinkybool/feather/blob/main/test/pringle.story.lua).

