local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Config = require(ReplicatedStorage.Shared.Config)
local DamageService = require(script.Parent.DamageService)

local HitboxService = {}

local function newAttachment(character)
    local root = character:FindFirstChild("HumanoidRootPart")
    if not root then
        return nil
    end

    local attachment = Instance.new("Attachment")
    attachment.Name = "SwingOrigin"
    attachment.Parent = root
    game:GetService("Debris"):AddItem(attachment, 1)
    return attachment
end

local function createHitbox(player, step, attachment)
    local params = OverlapParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {player.Character}
    local range = Config.Ranges.Light

    local active = true
    local connection
    connection = RunService.Heartbeat:Connect(function()
        if not active or not player.Character then
            if connection then
                connection:Disconnect()
            end
            return
        end

        local origin = attachment.WorldPosition
        local size = Vector3.new(range * 2, 6, range * 2)
        local parts = workspace:GetPartBoundsInBox(CFrame.new(origin), size, params)
        for _, part in ipairs(parts) do
            local model = part:FindFirstAncestorOfClass("Model")
            if model and model ~= player.Character and model.PrimaryPart then
                DamageService.Apply(player, model, {
                    Damage = Config.Damage.Light[step],
                    PoiseDamage = 22,
                    Kind = "Light",
                    Knockback = {
                        Direction = (model.PrimaryPart.Position - origin).Unit,
                        Force = 28,
                    },
                })
            end
        end
    end)

    task.delay(Config.Timing.HitboxActive[step], function()
        active = false
        if connection then
            connection:Disconnect()
        end
    end)
end

function HitboxService.StartSwing(player, step)
    local character = player.Character
    if not character then
        return
    end
    local attachment = newAttachment(character)
    if not attachment then
        return
    end

    createHitbox(player, step, attachment)
end

return HitboxService
