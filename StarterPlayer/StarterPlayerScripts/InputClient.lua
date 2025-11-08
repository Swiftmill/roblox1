local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local Net = require(ReplicatedStorage.Shared.Net)
local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer
local remotes = ReplicatedStorage:WaitForChild("Remotes")

local comboRemote = remotes.Combat["Combat: StartCombo"]
local blockRemote = remotes.Combat["Combat: Block"]
local shockRemote = remotes.Combat["Combat: Shock"]
local kickRemote = remotes.Combat["Combat: Kick"]
local lockRemote = remotes.Combat["Combat: LockOn"]
local tauntRemote = remotes.UX["UX: Taunt"]
local emoteRemote = remotes.UX["UX: Emote"]
local shopRemote = remotes.Shop["Shop: Purchase"]

local comboStep = 0
local comboDeadline = 0

local touchGui
local function ensureTouch()
    if not UserInputService.TouchEnabled then
        return
    end
    if touchGui then
        return
    end
    touchGui = Instance.new("ScreenGui")
    touchGui.Name = "SOULRINGTouch"
    touchGui.ResetOnSpawn = false
    touchGui.Parent = player:WaitForChild("PlayerGui")

    local function addButton(name, position, callback)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Text = name
        button.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
        button.TextColor3 = Color3.new(1, 1, 1)
        button.Size = Config.UI.TouchButtonSize
        button.Position = position
        button.AutoButtonColor = false
        button.Parent = touchGui
        button.MouseButton1Down:Connect(callback)
        return button
    end

    addButton("Light", UDim2.fromScale(0.8, 0.7), function()
        comboStep = (comboStep % 3) + 1
        comboDeadline = os.clock() + Config.UI.ComboBuffer
        Net.FireServer(comboRemote, comboStep)
    end)

    addButton("Block", UDim2.fromScale(0.65, 0.7), function()
        Net.FireServer(blockRemote, true)
    end).MouseButton1Up:Connect(function()
        Net.FireServer(blockRemote, false)
    end)

    addButton("Shock", UDim2.fromScale(0.8, 0.5), function()
        Net.FireServer(shockRemote)
    end)

    addButton("Kick", UDim2.fromScale(0.65, 0.5), function()
        Net.FireServer(kickRemote)
    end)

    addButton("Lock", UDim2.fromScale(0.1, 0.6), function()
        Net.FireServer(lockRemote)
    end)

    addButton("Sprint", UDim2.fromScale(0.1, 0.8), function()
        player:SetAttribute("SR_Sprinting", true)
    end).MouseButton1Up:Connect(function()
        player:SetAttribute("SR_Sprinting", false)
    end)

    addButton("Taunt", UDim2.fromScale(0.5, 0.8), function()
        Net.FireServer(tauntRemote)
    end)

    addButton("Emote", UDim2.fromScale(0.5, 0.6), function()
        Net.FireServer(emoteRemote, 1)
    end)

    addButton("Shop", UDim2.fromScale(0.1, 0.4), function()
        Net.FireServer(shopRemote, "RandomTrail")
    end)
end

local function resetCombo()
    comboStep = 0
end

local function startCombo()
    comboStep = (comboStep % 3) + 1
    comboDeadline = os.clock() + Config.UI.ComboBuffer
    Net.FireServer(comboRemote, comboStep)
end

local function bindInputs()
    ContextActionService:BindAction("SOULRING_Light", function(_, state)
        if state == Enum.UserInputState.Begin then
            startCombo()
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.ButtonR2, Enum.KeyCode.MouseButton1)

    ContextActionService:BindAction("SOULRING_Block", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(blockRemote, true)
        elseif state == Enum.UserInputState.End then
            Net.FireServer(blockRemote, false)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.ButtonL2, Enum.KeyCode.MouseButton2)

    ContextActionService:BindAction("SOULRING_Shock", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(shockRemote)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.R)

    ContextActionService:BindAction("SOULRING_Kick", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(kickRemote)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.F)

    ContextActionService:BindAction("SOULRING_Lock", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(lockRemote)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.LeftControl)

    ContextActionService:BindAction("SOULRING_Sprint", function(_, state)
        if state == Enum.UserInputState.Begin then
            player:SetAttribute("SR_Sprinting", true)
        elseif state == Enum.UserInputState.End then
            player:SetAttribute("SR_Sprinting", false)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.LeftShift)

    ContextActionService:BindAction("SOULRING_Taunt", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(tauntRemote)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.T)

    ContextActionService:BindAction("SOULRING_EmoteWheel", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(emoteRemote, 1)
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.Q)

    ContextActionService:BindAction("SOULRING_Shop", function(_, state)
        if state == Enum.UserInputState.Begin then
            Net.FireServer(shopRemote, "RandomTrail")
        end
        return Enum.ContextActionResult.Sink
    end, false, Enum.KeyCode.B)
end

UserInputService.InputBegan:Connect(function(input, processed)
    if processed then
        return
    end
    if input.KeyCode == Enum.KeyCode.Q then
        Net.FireServer(emoteRemote, 1)
    end
end)

RunService.RenderStepped:Connect(function()
    if comboStep > 0 and os.clock() > comboDeadline then
        resetCombo()
    end
end)

ensureTouch()
bindInputs()
