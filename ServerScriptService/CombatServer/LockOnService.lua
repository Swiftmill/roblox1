local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local StateService = require(script.Parent.StateService)

local LockOnService = {}

local function isValidTarget(player, target)
    if not target or target == player then
        return false
    end
    if not target.Character then
        return false
    end
    local humanoid = target.Character:FindFirstChildOfClass("Humanoid")
    if not humanoid or humanoid.Health <= 0 then
        return false
    end
    if player.Team and target.Team and player.Team == target.Team then
        return false
    end
    return true
end

function LockOnService.Assign(player, target)
    if target and not isValidTarget(player, target) then
        return
    end

    StateService.SetLockTarget(player, target)
end

function LockOnService.FindClosest(player)
    local character = player.Character
    if not character then
        return nil
    end
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local bestTarget
    local bestScore = math.huge
    for _, candidate in ipairs(Players:GetPlayers()) do
        if isValidTarget(player, candidate) then
            local cChar = candidate.Character
            if cChar and cChar.PrimaryPart then
                local offset = cChar.PrimaryPart.Position - root.Position
                local distance = offset.Magnitude
                if distance <= Config.Ranges.LockDistance then
                    local forward = root.CFrame.LookVector
                    local angle = math.acos(math.clamp(forward:Dot(offset.Unit), -1, 1))
                    if angle <= Config.Ranges.LockCone then
                        local score = distance + angle * 10
                        if score < bestScore then
                            bestScore = score
                            bestTarget = candidate
                        end
                    end
                end
            end
        end
    end

    return bestTarget
end

return LockOnService
