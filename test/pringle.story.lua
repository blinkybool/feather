local Feather = require(script.Parent.Parent)
local RunService = game:GetService("RunService")

local Board3D = require(script.Parent["Board3D"])

return function ()

	local function graph(t: number)

		local p = math.fmod(t, 1)
		local n = 20
		local size = 5

		local function phi(u: number, v: number)
		
			return Vector3.new(v, math.pow(u,2) - math.pow(v,2), u)
		end
	
		local function slice(u: number)
	
			local points = {}
			
			for i=-n, n do
	
				local v = i/n
				
				table.insert(points, phi(u,v) * size)
			end
	
			return points
		end

		local curves = {}

		for i=-n+p, n do

			local u = i/n

			local c = (u+1)/2
			
			table.insert(curves, {
					Color = Color3.new(1-c, 0, c),
					Width = size/30,
					Points = slice(u),
			})
		end
		
		return Feather.createElement(Board3D, {

			Curves = curves,
			Origin = Vector3.new(0,10,0),
		})
	end
	
	local tree = Feather.mount(graph(0), workspace, "Pringle")

	local startTime = os.clock()
	
	local con = RunService.Heartbeat:Connect(function(_deltaTime)
		
		tree = Feather.update(tree, graph(os.clock() - startTime))
	end)

	return
		function ()
			
			con:Disconnect()
			Feather.unmount(tree)
		end
end