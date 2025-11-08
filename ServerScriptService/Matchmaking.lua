local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local Matchmaking = {}

local function setupPad(padName, placeId)
    local pad = workspace:FindFirstChild(padName, true)
    if not pad or not pad:IsA("BasePart") then
        return
    end

    pad.Touched:Connect(function(hit)
        local character = hit:FindFirstAncestorOfClass("Model")
        if not character then
            return
        end
        local player = Players:GetPlayerFromCharacter(character)
        if not player then
            return
        end

        local success, result = pcall(function()
            TeleportService:TeleportAsync(placeId, {player})
        end)
        if not success then
            warn("Teleport failed", result)
        end
    end)
end

for padName, placeName in pairs(Config.Match.HubTeleportPads) do
    setupPad(placeName, game.PlaceId)
end

return Matchmaking
