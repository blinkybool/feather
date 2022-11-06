local Feather = require(script.Parent.Parent)

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