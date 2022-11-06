---
sidebar_position: 3
---

# Optimising

Suppose we want to animate something on a pixel-based canvas made of parts.

With no optimisation, it could look like this.

```lua
local e = Feather.createElement

return function(props)

	local children = {}

	local pixelSize = props.Width/props.Res

	for i=1, props.Res do

		for j=1, props.Res do
			
			local key = (j-1) * props.Res + i

			children[key] = e("Part", {
		
				Color = props.Grid[key] or Color3.new(0,0,0),

				Size = Vector3.new(pixelSize, 1, pixelSize),
				CFrame = CFrame.new((i - 0.5)* pixelSize, 0.5, (j-0.5) * pixelSize),
		
				Material = Enum.Material.Neon,
				TopSurface = Enum.SurfaceType.Smooth,
				BottomSurface = Enum.SurfaceType.Smooth,
				Anchored = true,
			})
		end
	end

	return e("Model", {

		[Feather.Children] = children
	})
end
```

The problem with this component is that every time we call update (maybe every Heartbeat), Feather will update 7 properties of every single pixel part, even if none have changed.

## OldProps + DeltaChildren

Function components can take a second argument, to which Feather passes the stored props of the last update
to that component. We can use this to check if the color of a particular pixel has changed or not.

Then how do we tell Feather which children to update?

Instead of passing the table of all children to the [Feather.Children](/api/Feather#Children), we can pass the table of changed-children to [Feather.DeltaChildren](/api/Feather#DeltaChildren). Existing children that are missing from this table will not be destroyed as instances (like they would with Feather.Children).

Our improved component looks like this.

```lua
local e = Feather.createElement

return function(props, oldProps)

	local deltaChildren = {}

	local pixelSize = props.Width/props.Res

	local oldGrid = oldProps.Grid

	local updateAll =
		not oldGrid
		or props.Width ~= oldProps.Width
		or props.Res ~= oldProps.Res

	for i=1, props.Res do

		for j=1, props.Res do
			
			local key = (j-1) * props.Res + i

			if not oldGrid or props.Grid[key] ~= oldProps.Grid[key] then
				
				deltaChildren[key] = e("Part", {
			
					Color = props.Grid[key] or Color3.new(0,0,0),

					Size = Vector3.new(pixelSize, 1, pixelSize),
					CFrame = CFrame.new((i - 0.5)* pixelSize, 0.5, (j-0.5) * pixelSize),
			
					Material = Enum.Material.Neon,
					TopSurface = Enum.SurfaceType.Smooth,
					BottomSurface = Enum.SurfaceType.Smooth,
					Anchored = true,
				})
			end
		end
	end

	return e("Model", {

		[Feather.DeltaChildren] = deltaChildren
	})
end
```

It is still possible to remove children when using [Feather.DeltaChildren](/api/Feather#DeltaChildren). Just set their value to the special symbol [Feather.SubtractChild](/api/Feather#SubtractChild) in the delta children table.

## HostInitProps

There are often properties of hosts that *never* change with any update, and
only need to be set when the instance is first created. While it's possible
to deduce whether a host already exists via oldProps, it's much easier to use
the special key [Feather.HostInitProps](/api/Feather#HostInitProps) to gather any props that should only be set when the instance is first created.

```lua
local e = Feather.createElement

local partInitProps = {

	Material = Enum.Material.Neon,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Anchored = true,
}

return function(props, oldProps)

	local deltaChildren = {}

	local pixelSize = props.Width / props.Res

	local oldGrid = oldProps.Grid

	local updateAll =
		not oldGrid
		or props.Width ~= oldProps.Width
		or props.Res ~= oldProps.Res

	for i=1, props.Res do

		for j=1, props.Res do
			
			local key = (j-1) * props.Res + i

			if updateAll or props.Grid[key] ~= oldProps.Grid[key] then
				
				deltaChildren[key] = e("Part", {
			
					Color = props.Grid[key] or Color3.new(0,0,0),

					Size = Vector3.new(pixelSize, 1, pixelSize),
					CFrame = CFrame.new((i - 0.5)* pixelSize, 0.5, (j-0.5) * pixelSize),
			
					[Feather.HostInitProps] = partInitProps,
				})
			end
		end
	end

	return e("Model", {

		[Feather.DeltaChildren] = deltaChildren
	})
end
```

## BulkMoveCFrame

If you are moving lots of BaseParts, you can use the special key [Feather.BulkMoveCFrame](/api/Feather#BulkMoveCFrame), instead of `CFrame` for better performance.

```lua
local function sphere(props)

	return e("Part", {

		[Feather.BulkMoveCFrame] = CFrame.new(props.Position),

		Size = Vector3.new(props.Diameter, props.Diameter, props.Diameter),
		Color = props.Color,

		Anchored = true,
	})
end
```

When running [Feather.update](/api/Feather#update) or [Feather.mount](/api/Feather#mount), Feather will use [WorldRoot:BulkMoveTo()](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#BulkMoveTo) on all of the parts with this prop, instead of individually cframing every part during the update.

:::caution

[WorldRoot:BulkMoveTo()](https://create.roblox.com/docs/reference/engine/classes/WorldRoot#BulkMoveTo) is called with `Enum.BulkMoveTo.FireCFrameChanged`, so Position/Orientation Changed events will **not** fire.

:::