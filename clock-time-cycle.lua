local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")

local FullCycleDuration = 360
local FramesPerSecond = 60
local IncrementPerFrame = 24 / (FullCycleDuration * FramesPerSecond)

RunService.Heartbeat:Connect(function()
	Lighting.ClockTime = Lighting.ClockTime + IncrementPerFrame
end)
