local Feather = require(script.Parent.Parent)

local e = Feather.createElement

local function curveLine(i, curve, adornee)

	local centre = (curve.Points[i] + curve.Points[i+1])/2
	
	return e("BoxHandleAdornment", {
		
		Size = Vector3.new((curve.Points[i] - curve.Points[i+1]).Magnitude, 0.0001, curve.Width),
		CFrame = CFrame.new(centre.X, 5 + curve.ZIndex * 0.001, centre.Y)
		* CFrame.Angles(0, -math.atan2((curve.Points[i] - curve.Points[i+1]).Y, (curve.Points[i] - curve.Points[i+1]).X), 0)
		-- * CFrame.Angles(0, math.pi/2, 0)
		,
		Color3 = curve.Color,
		ZIndex = curve.ZIndex,
		-- Thickness = curve.Width,

		[Feather.HostInitProps] = {
			
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
		
			table.insert(deltaChildren, curveLine(i, curve, props.Adornee))
		end
	end

	return e("Folder", {

		[Feather.DeltaChildren] = deltaChildren,
	})
end

return function(props)

	local curves = {}

	for id, curve in props.Curves do
		
		curves[id] = e(partCurve, {
			
			Curve = curve,
			Adornee = props.Adornee,
		})
	end

	return e("Model", {

		[Feather.Children] = curves
	})
end