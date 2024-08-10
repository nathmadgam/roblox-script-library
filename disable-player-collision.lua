local PhysicsService = game:GetService("PhysicsService")
local Players = game:GetService("Players")

local collisionGroupName = "PlayersCollisionGroup"

if not pcall(function() PhysicsService:GetCollisionGroupId(collisionGroupName) end) then
    PhysicsService:CreateCollisionGroup(collisionGroupName)
end

PhysicsService:CollisionGroupSetCollidable(collisionGroupName, collisionGroupName, false)

local function setPlayerCollisionGroup(character)
    for _, part in pairs(character:GetChildren()) do
        if part:IsA("BasePart") then
            PhysicsService:SetPartCollisionGroup(part, collisionGroupName)
        end
    end
end

Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function(character)
        character:WaitForChild("HumanoidRootPart")
        setPlayerCollisionGroup(character)
    end)
end)

for _, player in pairs(Players:GetPlayers()) do
    if player.Character then
        setPlayerCollisionGroup(player.Character)
    end
end
