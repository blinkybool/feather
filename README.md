<div align="center">
	<h1>Feather</h1>
	<p>A featherweight declarative instance manager for Roblox.</p>
	<a href="https://blinkybool.github.io/feather/"><strong>Docs</strong></a>
	<a href="https://blinkybool.github.io/feather/api/Feather"><strong>API</strong></a>
</div>
<!--moonwave-hide-before-this-line-->

Roact is great for managing a hierarchy of instances as a function of some underlying state, but when handling tens of thousands of instances, the memory usage becomes a problem.

Feather lets you manage instances with the same `component + props` logic as Roact, using the absolute bare minimum amount of memory usage in the virtual tree, while still being performant.

The key is to not store any host props in the virtual tree, and allow function components more control over which of their resulting host components get updated.

For example, the following curve component draws lines (with parts) between adjacent points along the curve, and uses the `Feather.DeltaChildren` key to update only those lines whose props *would be changed*, had they been included as children. This differs from `Feather.Children`, which destroys any existing children which are missing from the children table.

```lua
local function partCurve(props, oldProps)

	local deltaChildren = table.create(#props.Points)

	local curve = props

	for i=1, #props.Points-1 do

		if
			not oldProps.Points -- this is the first render
			or
			props.Color ~= oldProps.Color
			or
			props.Points[i] ~= oldProps.Points[i]
			or
			props.Points[i+1] ~= oldProps.Points[i+1] then

			local centre = (curve.Points[i] + curve.Points[i+1])/2
			local vector = (curve.Points[i] - curve.Points[i+1])
		
			deltaChildren[i] = e("Part", {
		
				Size = Vector3.new((curve.Points[i] - curve.Points[i+1]).Magnitude, 0.001, curve.Width),
				Color = curve.Color,
				CFrame =
					CFrame.new(centre.X, 1 + 0.001 * curve.ZIndex, centre.Y)
					*
					CFrame.Angles(0, -math.atan2(vector.Y, vector.X), 0),
		
				Anchored = true,
			})
		end
	end

	return e("Folder", {

		[Feather.DeltaChildren] = deltaChildren
	})
end
```