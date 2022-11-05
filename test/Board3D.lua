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

partInitProps.Shape = Enum.PartType.Ball

local function ball(i, curve, origin)

	return e("Part", {
		
		[Feather.BulkCFrame] = CFrame.new(curve.Points[i] + origin),
		Color = curve.Color,
		Size = Vector3.new(curve.Width, curve.Width, curve.Width),
		
		[Feather.HostInitProps] = partInitProps,
	})
end

local function partCurve(props, oldProps)

	local curve = props.Curve

	local deltaChildren = table.create(#curve.Points)

	for i=1, #curve.Points-1 do

		if
			not oldProps.Curve
			or
			curve.Color ~= oldProps.Color
			or
			curve.Points[i] ~= oldProps.Curve.Points[i]
			or
			curve.Points[i+1] ~= oldProps.Curve.Points[i+1] then
		
				table.insert(deltaChildren, ball(i, curve, props.Origin))
			end
	end

	return e("Folder", {

		[Feather.DeltaChildren] = deltaChildren
	})
end

return function(props)

	local curves = {}

	for id, curve in props.Curves do
		
		curves[id] = e(partCurve, {
			Curve = curve,
			Origin = props.Origin
		})
	end

	return e("Model", {

		[Feather.Children] = curves
	})
end