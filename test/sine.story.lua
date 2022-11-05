local Feather = require(script.Parent.Parent)
local RunService = game:GetService("RunService")

local Board2D = require(script.Parent["Board2D"])

return function ()

	local function sinePoints(amplitude: number, phase: number, period: number, numPoints: number, interval: number)
		
		local points = {}

		for i=-numPoints/2, numPoints/2 do
			
			local x = i/numPoints * interval
			local y = amplitude * math.sin(2 * math.pi / period * x + phase)
			table.insert(points, Vector2.new(x,y))
		end

		return points
	end

	local function graph(t: number)

		local s = math.sin(3*t)

		local interval = 10
		local res = 10
		
		return Feather.createElement(Board2D, {

			Curves = {
				{
					Color = Color3.new(1, 0, s),
					Width = .05,
					Points = sinePoints(2*s, 3*t, 2* math.pi/4, interval * res, interval),
					ZIndex = 0,
				},
				{
					Color = Color3.new(0,0,1),
					Width = .1,
					Points = sinePoints(1, 3*t + 2 * math.pi/2, 2* math.pi, interval * res, interval),
					ZIndex = 1,
				},
				{
					Color = Color3.new(0,1,0),
					Width = .1,
					Points = sinePoints(1, 3*t + 4 * math.pi/2, 2* math.pi, interval * res, interval),
					ZIndex = 2,
				},
			}
		})
	end
	
	local tree = Feather.mount(graph(0), workspace, "Graph")
	
	local startTime = os.clock()

	local connection = RunService.Heartbeat:Connect(function(_deltaTime)

		tree = Feather.update(tree, graph(os.clock() - startTime))
	end)

	return function ()
		
		connection:Disconnect()
		Feather.unmount(tree)
	end
end