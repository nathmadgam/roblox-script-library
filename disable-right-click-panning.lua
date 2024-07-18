local ContextActionService = game:GetService("ContextActionService")

ContextActionService:BindActionAtPriority("RightMouseDisable", function()
	return Enum.ContextActionResult.Sink
end, false, Enum.ContextActionPriority.Medium.Value, Enum.UserInputType.MouseButton2)
