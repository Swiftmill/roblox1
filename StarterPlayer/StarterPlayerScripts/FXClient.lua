local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local killRemote = remotes.FX["KillEffect"]

local pool = {}
local function getPart()
    local part = table.remove(pool)
    if part then
        part.Transparency = 0
        part.Anchored = true
        part.CanCollide = false
        part.Parent = workspace
        return part
    end
    part = Instance.new("Part")
    part.Anchored = true
    part.CanCollide = false
    part.Material = Enum.Material.Neon
    part.Color = Color3.fromRGB(80, 220, 255)
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(0.6, 0.6, 0.6)
    part.Parent = workspace
    return part
end

local function release(part)
    part.Parent = nil
    table.insert(pool, part)
end

local function spawnShockwave(position)
    local part = getPart()
    part.Position = position
    part.Shape = Enum.PartType.Ball
    part.Size = Vector3.new(1, 1, 1)

    TweenService:Create(part, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
        Size = Vector3.new(12, 12, 12),
        Transparency = 1,
    }):Play()
    task.delay(0.45, function()
        release(part)
    end)
end

local function spawnOrb(startCF, killer)
    local orb = getPart()
    orb.Size = Vector3.new(0.6, 0.6, 0.6)
    orb.CFrame = startCF

    local start = tick()
    local connection
    connection = RunService.Heartbeat:Connect(function()
        local t = tick() - start
        local height = math.sin(t * 6) * 2
        orb.CFrame = startCF * CFrame.new(math.sin(t * 4) * 1.5, height, math.cos(t * 4) * 1.5)
    end)

    task.delay(1.25, function()
        if connection then
            connection:Disconnect()
        end
        if killer and killer.Character and killer.Character.PrimaryPart then
            local targetCF = killer.Character.PrimaryPart.CFrame
            TweenService:Create(orb, TweenInfo.new(0.3, Enum.EasingStyle.Back), {
                CFrame = targetCF,
                Transparency = 1,
            }):Play()
            task.delay(0.32, function()
                release(orb)
            end)
        else
            TweenService:Create(orb, TweenInfo.new(0.4), {
                Transparency = 1,
                Size = Vector3.new(0, 0, 0),
            }):Play()
            task.delay(0.4, function()
                release(orb)
            end)
        end
    end)
end

local function dissolveBody(character)
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") then
            TweenService:Create(part, TweenInfo.new(0.6), {Transparency = 1}):Play()
        end
    end
end

killRemote.OnClientEvent:Connect(function(killer, victimCF, victimCharacter)
    spawnShockwave(victimCF.Position)
    task.delay(0.1, function()
        spawnShockwave(victimCF.Position + Vector3.new(0, 3, 0))
    end)
    spawnOrb(victimCF, killer)
    if victimCharacter then
        dissolveBody(victimCharacter)
    end
end)
