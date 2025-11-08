local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local player = Players.LocalPlayer

local gui = script:FindFirstAncestorOfClass("PlayerGui")

local function waitForGui()
    while not player:FindFirstChild("PlayerGui") do
        task.wait()
    end
    return player.PlayerGui
end

task.spawn(function()
    local pg = waitForGui()
    local mainUi = pg:FindFirstChild("MainUI")
    if not mainUi then
        mainUi = Instance.new("ScreenGui")
        mainUi.Name = "MainUI"
        mainUi.ResetOnSpawn = false
        mainUi.Parent = pg
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.fromScale(0.3, 0.2)
    frame.Position = UDim2.fromScale(0.02, 0.75)
    frame.BackgroundTransparency = 0.3
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
    frame.Parent = mainUi

    local healthBar = Instance.new("Frame")
    healthBar.Name = "HealthBar"
    healthBar.Size = UDim2.fromScale(1, 0.25)
    healthBar.Position = UDim2.fromScale(0, 0)
    healthBar.BackgroundColor3 = Color3.fromRGB(200, 40, 40)
    healthBar.Parent = frame

    local staminaBar = Instance.new("Frame")
    staminaBar.Name = "StaminaBar"
    staminaBar.Size = UDim2.fromScale(1, 0.25)
    staminaBar.Position = UDim2.fromScale(0, 0.35)
    staminaBar.BackgroundColor3 = Color3.fromRGB(40, 180, 200)
    staminaBar.Parent = frame

    local poiseBar = Instance.new("Frame")
    poiseBar.Name = "PoiseBar"
    poiseBar.Size = UDim2.fromScale(1, 0.25)
    poiseBar.Position = UDim2.fromScale(0, 0.7)
    poiseBar.BackgroundColor3 = Color3.fromRGB(180, 180, 60)
    poiseBar.Parent = frame

    local healthFill = Instance.new("Frame")
    healthFill.Name = "Fill"
    healthFill.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
    healthFill.Size = UDim2.fromScale(1, 1)
    healthFill.AnchorPoint = Vector2.new(0, 0)
    healthFill.Parent = healthBar

    local staminaFill = healthFill:Clone()
    staminaFill.BackgroundColor3 = Color3.fromRGB(60, 220, 255)
    staminaFill.Parent = staminaBar

    local poiseFill = healthFill:Clone()
    poiseFill.BackgroundColor3 = Color3.fromRGB(255, 240, 120)
    poiseFill.Parent = poiseBar

    local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
    local maxHealth = humanoid and humanoid.MaxHealth or Config.Stats.BaseHealth
    healthFill.Size = UDim2.fromScale(1, 1)

    local function updateHealth()
        local hum = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            healthFill.Size = UDim2.fromScale(hum.Health / hum.MaxHealth, 1)
        end
    end

    local function updateStamina()
        local stamina = player:GetAttribute("SR_Stamina") or Config.Stats.BaseStamina
        staminaFill.Size = UDim2.fromScale(stamina / Config.Stats.BaseStamina, 1)
    end

    local function updatePoise()
        local poise = player.Character and player.Character:GetAttribute("SR_Poise") or Config.Stats.BasePoise
        poiseFill.Size = UDim2.fromScale(poise / Config.Stats.BasePoise, 1)
    end

    player:GetAttributeChangedSignal("SR_Stamina"):Connect(updateStamina)
    player.CharacterAdded:Connect(function(char)
        char:GetAttributeChangedSignal("SR_Poise"):Connect(updatePoise)
        local hum = char:WaitForChild("Humanoid")
        hum.HealthChanged:Connect(updateHealth)
        updateHealth()
    end)

    updateHealth()
    updateStamina()
    updatePoise()
end)
