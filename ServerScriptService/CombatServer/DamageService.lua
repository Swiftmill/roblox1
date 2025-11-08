local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Config = require(ReplicatedStorage.Shared.Config)
local StateService = require(script.Parent.StateService)

local DamageService = {}

local hitDebounce = {}

local killRemote = ReplicatedStorage.Remotes.FX["KillEffect"]

local function key(player, target)
    return player.UserId .. ":" .. target.UserId
end

local function resetDebounce()
    for k, info in pairs(hitDebounce) do
        if os.clock() - info.tick > 1/60 then
            hitDebounce[k] = nil
        end
    end
end

local function getStateFolder(player)
    local folder = player:FindFirstChild("_SOULRING")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "_SOULRING"
        folder.Parent = player
    end
    return folder
end

local function getAssistList(character)
    local folder = character:FindFirstChild("_AssistTags")
    if not folder then
        folder = Instance.new("Folder")
        folder.Name = "_AssistTags"
        folder.Parent = character
    end
    return folder
end

local function tagAssist(attacker, victim)
    local folder = getAssistList(victim)
    local tag = folder:FindFirstChild(attacker.UserId)
    if not tag then
        tag = Instance.new("StringValue")
        tag.Name = attacker.UserId
        tag.Parent = folder
    end
    tag.Value = tostring(os.clock())
end

local function collectAssists(victim, killer)
    local folder = victim:FindFirstChild("_AssistTags")
    if not folder then
        return {}
    end

    local now = os.clock()
    local assists = {}
    for _, tag in ipairs(folder:GetChildren()) do
        local userId = tonumber(tag.Name)
        if userId then
            local stamp = tonumber(tag.Value)
            if stamp and now - stamp <= Config.Match.AssistWindow then
                local player = Players:GetPlayerByUserId(userId)
                if player and player ~= killer then
                    table.insert(assists, player)
                end
            end
        end
    end
    folder:ClearAllChildren()
    return assists
end

local function applyRewards(killer, assists)
    if killer then
        killer:SetAttribute("SR_Coins", (killer:GetAttribute("SR_Coins") or 0) + Config.Match.CurrencyPerKill)
        killer:SetAttribute("SR_XP", (killer:GetAttribute("SR_XP") or 0) + Config.Match.XpPerKill)
        killer:SetAttribute("SR_Streak", (killer:GetAttribute("SR_Streak") or 0) + 1)
    end
    for _, player in ipairs(assists) do
        player:SetAttribute("SR_Coins", (player:GetAttribute("SR_Coins") or 0) + Config.Match.CurrencyPerAssist)
        player:SetAttribute("SR_XP", (player:GetAttribute("SR_XP") or 0) + Config.Match.XpPerAssist)
    end
end

local function isBlocking(character)
    local blockValue = character:FindFirstChild("_Blocking")
    return blockValue and blockValue.Value
end

local function applyKnockback(victimHumanoidRootPart, direction, magnitude)
    local bv = Instance.new("BodyVelocity")
    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
    bv.Velocity = direction * magnitude
    bv.Parent = victimHumanoidRootPart
    Debris:AddItem(bv, 0.25)
end

function DamageService.Apply(attacker, victimCharacter, params)
    if not attacker or not victimCharacter or not params then
        return
    end

    local victimPlayer = Players:GetPlayerFromCharacter(victimCharacter)
    if not victimPlayer then
        return
    end

    if attacker.Team and victimPlayer.Team and attacker.Team == victimPlayer.Team then
        return
    end

    local humanoid = victimCharacter:FindFirstChildOfClass("Humanoid")
    local attackerCharacter = attacker.Character
    if not humanoid or humanoid.Health <= 0 or not attackerCharacter then
        return
    end

    local attackerRoot = attackerCharacter:FindFirstChild("HumanoidRootPart")
    local victimRoot = victimCharacter:FindFirstChild("HumanoidRootPart") or victimCharacter.PrimaryPart
    if not attackerRoot or not victimRoot then
        return
    end

    local distance = (attackerRoot.Position - victimRoot.Position).Magnitude
    if distance > Config.Ranges.Light * 1.8 then
        return
    end

    local ray = RaycastParams.new()
    ray.FilterType = Enum.RaycastFilterType.Exclude
    ray.FilterDescendantsInstances = {attackerCharacter}
    local result = workspace:Raycast(attackerRoot.Position, (victimRoot.Position - attackerRoot.Position), ray)
    if result and result.Instance and not result.Instance:IsDescendantOf(victimCharacter) then
        return
    end

    local k = key(attacker, victimPlayer)
    local now = os.clock()
    hitDebounce[k] = hitDebounce[k] or {tick = now}
    if now - hitDebounce[k].tick < 1/60 then
        return
    end
    hitDebounce[k].tick = now

    local damage = params.Damage or 0
    local guardBreak = false
    local block = isBlocking(victimCharacter)
    if block then
        damage *= 0.3
        guardBreak = params.Kind == "Kick"
        if not StateService.UseStamina(victimPlayer, Config.Costs.BlockPerHit) then
            guardBreak = true
        end
    end

    if damage <= 0 then
        return
    end

    humanoid:TakeDamage(damage)
    if params.PoiseDamage then
        victimCharacter:SetAttribute("SR_Poise", math.max(0, (victimCharacter:GetAttribute("SR_Poise") or Config.Stats.BasePoise) - params.PoiseDamage))
    end

    if params.Knockback and victimRoot then
        applyKnockback(victimRoot, params.Knockback.Direction, params.Knockback.Force)
    end

    if guardBreak then
        humanoid:ChangeState(Enum.HumanoidStateType.Physics)
        victimCharacter:SetAttribute("SR_BlockBroken", now + Config.Timing.GuardBreakStun)
    end

    tagAssist(attacker, victimCharacter)

    if humanoid.Health <= 0 and victimRoot then
        local assists = collectAssists(victimCharacter, attacker)
        applyRewards(attacker, assists)
        killRemote:FireAllClients(attacker, victimRoot.CFrame, victimCharacter)
    end
end

RunService.Heartbeat:Connect(resetDebounce)

return DamageService
