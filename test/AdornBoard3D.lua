local Feather = require(script.Parent.Parent)
local e = Feather.createElement

local function ball(i, curve, origin, adornee)

	return e("SphereHandleAdornment", {

		
		CFrame = CFrame.new(curve.Points[i] + origin),
		
		[Feather.HostInitProps] = {
			
			Color3 = curve.Color,
			Radius = curve.Width/2,
			Adornee = adornee,
		},
	})
end

local function partCurve(props, oldProps)

	local curve = props.Curve

	local deltaChildren = table.create(#curve.Points)

	oldProps = oldProps or {}
	local oldCurve = oldProps.Curve or { Points = {}}

	for i=1, #curve.Points-1 do

		if
			curve.Color ~= oldProps.Color
			or
			curve.Points[i] ~= oldCurve.Points[i]
			or
			curve.Points[i+1] ~= oldCurve.Points[i+1] then
		
			table.insert(deltaChildren, ball(i, curve, props.Origin, props.Adornee))
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
			Origin = props.Origin,
			Adornee = props.Adornee,
		})
	end

	return e("Model", {

		[Feather.Children] = curves
	})
end