local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local StateService = {}

local states = {}

local function newState(player)
    states[player] = {
        ComboStep = 0,
        ComboTick = 0,
        Block = false,
        Stamina = Config.Stats.BaseStamina,
        MaxStamina = Config.Stats.BaseStamina,
        Poise = Config.Stats.BasePoise,
        MaxPoise = Config.Stats.BasePoise,
        LockTarget = nil,
        Cooldowns = {},
        Sprinting = false,
        RegenTick = os.clock(),
    }
    return states[player]
end

function StateService.Get(player)
    return states[player] or newState(player)
end

function StateService.SetBlock(player, state)
    local info = StateService.Get(player)
    info.Block = state
    local char = player.Character
    if char then
        local flag = char:FindFirstChild("_Blocking") or Instance.new("BoolValue")
        flag.Name = "_Blocking"
        flag.Parent = char
        flag.Value = state
        char:SetAttribute("SR_Blocking", state)
    end
end

function StateService.UseStamina(player, amount)
    local info = StateService.Get(player)
    if info.Stamina < amount then
        return false
    end
    info.Stamina -= amount
    info.RegenTick = os.clock()
    player:SetAttribute("SR_Stamina", info.Stamina)
    return true
end

function StateService.AddStamina(player, amount)
    local info = StateService.Get(player)
    info.Stamina = math.clamp(info.Stamina + amount, 0, info.MaxStamina)
    player:SetAttribute("SR_Stamina", info.Stamina)
end

function StateService.ModifyPoise(player, amount)
    local info = StateService.Get(player)
    info.Poise = math.clamp(info.Poise + amount, 0, info.MaxPoise)
    if player.Character then
        player.Character:SetAttribute("SR_Poise", info.Poise)
    end
end

function StateService.SetCooldown(player, key, duration)
    local info = StateService.Get(player)
    info.Cooldowns[key] = os.clock() + duration
end

function StateService.IsOnCooldown(player, key)
    local info = StateService.Get(player)
    local expire = info.Cooldowns[key]
    if not expire then
        return false
    end
    if os.clock() >= expire then
        info.Cooldowns[key] = nil
        return false
    end
    return true
end

function StateService.SetLockTarget(player, target)
    local info = StateService.Get(player)
    info.LockTarget = target
    player:SetAttribute("SR_Lock", target and target.UserId or 0)
end

function StateService.GetLockTarget(player)
    local info = StateService.Get(player)
    return info.LockTarget
end

task.spawn(function()
    while task.wait(0.25) do
        for player, info in pairs(states) do
            if player.Parent then
                local drain = 0
                if info.Sprinting or player:GetAttribute("SR_Sprinting") then
                    info.Sprinting = true
                    drain += Config.Costs.Sprint
                else
                    info.Sprinting = false
                end
                if info.Block then
                    drain += Config.Costs.BlockPerHit * 0.1
                end
                if drain > 0 then
                    info.Stamina = math.max(0, info.Stamina - drain)
                    player:SetAttribute("SR_Stamina", info.Stamina)
                    info.RegenTick = os.clock()
                end
                if os.clock() - info.RegenTick >= Config.Regen.StaminaDelay and info.Stamina < info.MaxStamina then
                    info.Stamina = math.clamp(info.Stamina + Config.Regen.StaminaRate * 0.25, 0, info.MaxStamina)
                    player:SetAttribute("SR_Stamina", info.Stamina)
                end
                if info.Poise < info.MaxPoise then
                    info.Poise = math.clamp(info.Poise + Config.Regen.PoiseRate * 0.25, 0, info.MaxPoise)
                    if player.Character then
                        player.Character:SetAttribute("SR_Poise", info.Poise)
                    end
                end
            else
                states[player] = nil
            end
        end
    end
end)

Players.PlayerRemoving:Connect(function(player)
    states[player] = nil
end)

return StateService
