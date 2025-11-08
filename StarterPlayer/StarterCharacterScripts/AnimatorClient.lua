local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local animator = humanoid:WaitForChild("Animator")

local animations = {}

local function createAnim(name)
    local animation = Instance.new("Animation")
    animation.Name = name
    animation.AnimationId = "rbxassetid://0" -- placeholder, replace in Studio
    animation.Parent = script
    return animation
end

animations.Light1 = animator:LoadAnimation(createAnim("Light1"))
animations.Light2 = animator:LoadAnimation(createAnim("Light2"))
animations.Light3 = animator:LoadAnimation(createAnim("Light3"))
animations.Block = animator:LoadAnimation(createAnim("Block"))
animations.Sprint = animator:LoadAnimation(createAnim("Sprint"))

local comboStep = 0

local function playCombo()
    comboStep = (comboStep % 3) + 1
    local track = animations["Light" .. comboStep]
    if track then
        track:Play(0.05, 1, 1)
    end
end

humanoid:GetPropertyChangedSignal("MoveDirection"):Connect(function()
    if humanoid.MoveDirection.Magnitude > 0.2 then
        animations.Sprint:Play(0.1, 1, humanoid.WalkSpeed / Config.Stats.SprintSpeed)
    else
        animations.Sprint:Stop(0.1)
    end
end)

character:GetAttributeChangedSignal("SR_Blocking"):Connect(function()
    if character:GetAttribute("SR_Blocking") then
        animations.Block:Play()
    else
        animations.Block:Stop()
    end
end)

script.Parent.ChildAdded:Connect(function(child)
    if child.Name == "SwingOrigin" then
        playCombo()
    end
end)
