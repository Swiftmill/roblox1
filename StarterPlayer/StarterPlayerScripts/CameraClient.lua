local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local Config = require(ReplicatedStorage.Shared.Config)

local lockTarget

local function updateLock()
    local targetId = player:GetAttribute("SR_Lock")
    if targetId and targetId ~= 0 then
        lockTarget = Players:GetPlayerByUserId(targetId)
    else
        lockTarget = nil
    end
end

player:GetAttributeChangedSignal("SR_Lock"):Connect(updateLock)
updateLock()

RunService.RenderStepped:Connect(function(dt)
    if not camera or not player.Character or not player.Character.PrimaryPart then
        return
    end
    if lockTarget and lockTarget.Character and lockTarget.Character.PrimaryPart then
        local root = player.Character.PrimaryPart
        local targetRoot = lockTarget.Character.PrimaryPart
        local midpoint = root.Position:Lerp(targetRoot.Position, 0.5)
        local offset = (root.Position - targetRoot.Position).Unit * 8 + Vector3.new(0, 5, 0)
        local desired = CFrame.new(midpoint + offset, targetRoot.Position)
        camera.CFrame = camera.CFrame:Lerp(desired, math.clamp(dt * 8, 0, 1))
    end
end)
