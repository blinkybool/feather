local Feather = require(script.Parent.Parent)

local e = Feather.createElement

local partInitProps = {

	Material = Enum.Material.SmoothPlastic,
	TopSurface = Enum.SurfaceType.Smooth,
	BottomSurface = Enum.SurfaceType.Smooth,
	Anchored = true,
	CanCollide = false,
	CastShadow = false, 
	CanTouch = false, -- Do not trigger Touch events
	CanQuery = false, -- Does not take part in e.g. GetPartsInPart
}

local function partCurve(props, oldProps)

	local deltaChildren = table.create(#props.Points)

	local curve = props

	for i=1, #props.Points-1 do

		if
			not oldProps.Points
			or
			props.Color ~= oldProps.Color
			or
			props.Points[i] ~= oldProps.Points[i]
			or
			props.Points[i+1] ~= oldProps.Points[i+1] then

			local centre = (curve.Points[i] + curve.Points[i+1])/2
			local vector = (curve.Points[i] - curve.Points[i+1])
		
			table.insert(deltaChildren, e("Part", {
		
				Size = Vector3.new((curve.Points[i] - curve.Points[i+1]).Magnitude, 0.0001, curve.Width),
				Color = curve.Color,
				CFrame =
					CFrame.new(centre.X, 5 + 0.001 * curve.ZIndex, centre.Y)
					*
					CFrame.Angles(0, -math.atan2(vector.Y, vector.X), 0),
		
				[Feather.HostInitProps] = partInitProps
			}))
		end
	end

	return e("Folder", {

		[Feather.DeltaChildren] = deltaChildren
	})
end

return function(props)

	local curves = {}

	for id, curve in props.Curves do
		
		curves[id] = e(partCurve, curve)
	end

	return e("Model", {

		[Feather.Children] = curves
	})
end