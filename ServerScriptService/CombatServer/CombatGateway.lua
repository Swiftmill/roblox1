local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local Net = require(ReplicatedStorage.Shared.Net)
local StateService = require(script.Parent.StateService)
local HitboxService = require(script.Parent.HitboxService)
local DamageService = require(script.Parent.DamageService)
local AbilitiesService = require(script.Parent.AbilitiesService)
local LockOnService = require(script.Parent.LockOnService)
local AntiExploit = require(script.Parent.AntiExploit)

local remotes = ReplicatedStorage:WaitForChild("Remotes")

local comboRemote = remotes.Combat["Combat: StartCombo"]
local hitRemote = remotes.Combat["Combat: Hit"]
local blockRemote = remotes.Combat["Combat: Block"]
local shockRemote = remotes.Combat["Combat: Shock"]
local kickRemote = remotes.Combat["Combat: Kick"]
local lockRemote = remotes.Combat["Combat: LockOn"]
local emoteRemote = remotes.UX["UX: Emote"]
local tauntRemote = remotes.UX["UX: Taunt"]
local shopRemote = remotes.Shop["Shop: Purchase"]

local function incrementCombo(player, step)
    local state = StateService.Get(player)
    state.ComboStep = step
    state.ComboTick = os.clock()
    task.delay(Config.Timing.ComboReset, function()
        if os.clock() - state.ComboTick >= Config.Timing.ComboReset then
            state.ComboStep = 0
        end
    end)
end

Net.BindRemote(comboRemote, function(player, step)
    if not AntiExploit.CheckRate(player, comboRemote.Name) then
        return
    end
    if not AntiExploit.ValidateStep(player, step) then
        return
    end

    local state = StateService.Get(player)
    incrementCombo(player, step)
    HitboxService.StartSwing(player, step)
end)

Net.BindRemote(hitRemote, function(player, victimId, step)
    if not AntiExploit.CheckRate(player, hitRemote.Name) then
        return
    end

    local target = Players:GetPlayerByUserId(victimId)
    if not target or not target.Character then
        return
    end

    if not player.Character or not player.Character.PrimaryPart then
        return
    end

    DamageService.Apply(player, target.Character, {
        Damage = Config.Damage.Light[step] or Config.Damage.Light[1],
        PoiseDamage = 18,
        Kind = "Light",
        Knockback = {
            Direction = (target.Character.PrimaryPart.Position - player.Character.PrimaryPart.Position).Unit,
            Force = 25,
        },
    })
end)

Net.BindRemote(blockRemote, function(player, state)
    if not AntiExploit.CheckRate(player, blockRemote.Name) then
        return
    end
    if typeof(state) ~= "boolean" then
        return
    end
    StateService.SetBlock(player, state)
end)

Net.BindRemote(shockRemote, function(player)
    if not AntiExploit.CheckRate(player, shockRemote.Name) then
        return
    end
    AbilitiesService.Shock(player)
end)

Net.BindRemote(kickRemote, function(player)
    if not AntiExploit.CheckRate(player, kickRemote.Name) then
        return
    end
    AbilitiesService.Kick(player)
end)

Net.BindRemote(lockRemote, function(player, targetId)
    if not AntiExploit.CheckRate(player, lockRemote.Name) then
        return
    end
    local target
    if typeof(targetId) == "number" then
        target = Players:GetPlayerByUserId(targetId)
    else
        target = LockOnService.FindClosest(player)
    end
    LockOnService.Assign(player, target)
end)

Net.BindRemote(emoteRemote, function(player, slot)
    if not AntiExploit.CheckRate(player, emoteRemote.Name) then
        return
    end
    if typeof(slot) ~= "number" then
        return
    end
    -- Emote broadcast placeholder
    emoteRemote:FireAllClients(player, slot)
end)

Net.BindRemote(tauntRemote, function(player)
    if not AntiExploit.CheckRate(player, tauntRemote.Name) then
        return
    end
    if StateService.UseStamina(player, math.abs(Config.Costs.Taunt)) then
        StateService.AddStamina(player, 8)
        player:SetAttribute("SR_Ult", (player:GetAttribute("SR_Ult") or 0) + 1)
    end
end)

Net.BindRemote(shopRemote, function(player, itemId)
    if not AntiExploit.CheckRate(player, shopRemote.Name) then
        return
    end
    if typeof(itemId) ~= "string" then
        return
    end

    local price = 100
    local coins = player:GetAttribute("SR_Coins") or 0
    if coins < price then
        return
    end
    player:SetAttribute("SR_Coins", coins - price)
    local ownedFolder = player:FindFirstChild("_Owned")
    if not ownedFolder then
        ownedFolder = Instance.new("Folder")
        ownedFolder.Name = "_Owned"
        ownedFolder.Parent = player
    end
    if not ownedFolder:FindFirstChild(itemId) then
        local flag = Instance.new("BoolValue")
        flag.Name = itemId
        flag.Parent = ownedFolder
    end
end)

Players.PlayerAdded:Connect(function(player)
    local attributes = {
        SR_Stamina = Config.Stats.BaseStamina,
        SR_Poise = Config.Stats.BasePoise,
        SR_Coins = 0,
        SR_XP = 0,
        SR_Streak = 0,
        SR_Ult = 0,
        SR_Lock = 0,
        SR_Sprinting = false,
    }
    for name, value in pairs(attributes) do
        if player:GetAttribute(name) == nil then
            player:SetAttribute(name, value)
        end
    end
    player.CharacterAdded:Connect(function(char)
        char:SetAttribute("SR_Poise", Config.Stats.BasePoise)
        char:SetAttribute("SR_Blocking", false)
    end)
end)

return {}
