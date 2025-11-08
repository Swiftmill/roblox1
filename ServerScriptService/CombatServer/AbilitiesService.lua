local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DamageService = require(script.Parent.DamageService)
local StateService = require(script.Parent.StateService)

local AbilitiesService = {}

local function canCast(player, cost, cooldownKey, cooldown)
    if StateService.IsOnCooldown(player, cooldownKey) then
        return false
    end
    if not StateService.UseStamina(player, cost) then
        return false
    end
    StateService.SetCooldown(player, cooldownKey, cooldown)
    return true
end

function AbilitiesService.Shock(player)
    if not canCast(player, Config.Costs.Shock, "Shock", Config.Cooldowns.Shock) then
        return
    end

    local character = player.Character
    if not character or not character.PrimaryPart then
        return
    end

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local parts = workspace:GetPartBoundsInRadius(character.PrimaryPart.Position, Config.Ranges.Shock, params)
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model ~= character and model.PrimaryPart then
            DamageService.Apply(player, model, {
                Damage = Config.Damage.Shock,
                PoiseDamage = 30,
                Kind = "Shock",
                Knockback = {
                    Direction = (model.PrimaryPart.Position - character.PrimaryPart.Position).Unit,
                    Force = 40,
                },
            })
            local humanoid = model:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid:ChangeState(Enum.HumanoidStateType.Physics)
            end
        end
    end
end

function AbilitiesService.Kick(player)
    if not canCast(player, Config.Costs.Kick, "Kick", Config.Cooldowns.Kick) then
        return
    end

    local character = player.Character
    if not character or not character.PrimaryPart then
        return
    end

    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {character}
    local range = Config.Ranges.Kick
    local parts = workspace:GetPartBoundsInBox(character.PrimaryPart.CFrame * CFrame.new(0, 0, -range / 2), Vector3.new(4, 6, range), params)
    for _, part in ipairs(parts) do
        local model = part:FindFirstAncestorOfClass("Model")
        if model and model ~= character and model.PrimaryPart then
            local blocking = model:FindFirstChild("_Blocking")
            DamageService.Apply(player, model, {
                Damage = Config.Damage.Kick,
                PoiseDamage = blocking and blocking.Value and Config.Damage.GuardBreakBonus or 18,
                Kind = "Kick",
                Knockback = {
                    Direction = (model.PrimaryPart.Position - character.PrimaryPart.Position).Unit,
                    Force = blocking and blocking.Value and 8 or 32,
                },
            })
        end
    end
end

function AbilitiesService.TryParry(defender, attacker)
    local info = StateService.Get(defender)
    if not info.Block then
        return false
    end
    local now = os.clock()
    if now - info.ComboTick > Config.Timing.ComboWindow then
        return false
    end

    StateService.SetCooldown(defender, "Parry", Config.Timing.ParryDisarm)
    return true
end

return AbilitiesService
