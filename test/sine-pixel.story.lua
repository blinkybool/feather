local Feather = require(script.Parent.Parent)
local RunService = game:GetService("RunService")

local PixelCanvas = require(script.Parent["PixelCanvas"])

local N = 100

return function ()

	local function graph(t: number)

		local grid = {}

		local function setSinePixels(amplitude, period, phase, color)
			
			for i=1, N do
				
				local x = ((i-1)/N)
				local j = math.floor((math.sin(x * 2 * math.pi/period + math.fmod(t,1) * 2 * math.pi + phase) * amplitude/2 + 0.5) * N) + 1
		
				local key = (j-1) * N + i

				grid[key] = color
			end
		end

		setSinePixels(0.5, 1, 0, Color3.new(1,0,1))
		setSinePixels(math.sin(2 * math.pi * math.fmod(t,1)), 1, 0.1, Color3.new(0,0,1))

		
		return Feather.createElement(PixelCanvas, {

			Grid = grid,
			Res = N,
			Width = 100
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