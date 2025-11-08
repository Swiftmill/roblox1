local Config = {}

Config.Damage = {
    Light = {10, 12, 16},
    Shock = 8,
    Kick = 14,
    GuardBreakBonus = 6,
}

Config.Ranges = {
    Light = 7,
    Shock = 6,
    Kick = 6,
    LockCone = math.rad(30),
    LockDistance = 80,
}

Config.Timing = {
    ComboWindow = 0.75,
    ComboReset = 1.8,
    HitboxActive = {0.18, 0.22, 0.26},
    IFrames = {0.1, 0.12, 0.14},
    ShockStun = 0.4,
    KickStun = 0.8,
    GuardBreakStun = 0.8,
    ParryDisarm = 0.6,
    SprintDrainInterval = 0.25,
}

Config.Cooldowns = {
    Shock = 6,
    Kick = 4,
    Taunt = 3,
}

Config.Costs = {
    Sprint = 4,
    Shock = 25,
    Kick = 10,
    BlockPerHit = 8,
    Taunt = -5,
}

Config.Regen = {
    StaminaRate = 14,
    StaminaDelay = 1.5,
    PoiseRate = 10,
}

Config.Stats = {
    BaseHealth = 100,
    BaseStamina = 100,
    BasePoise = 100,
    WalkSpeed = 12,
    SprintSpeed = 18,
}

Config.UI = {
    ComboBuffer = 0.15,
    TouchButtonSize = UDim2.fromScale(0.12, 0.12),
}

Config.Match = {
    AssistWindow = 10,
    CurrencyPerKill = 20,
    CurrencyPerAssist = 8,
    XpPerKill = 16,
    XpPerAssist = 6,
    HubTeleportPads = {
        Arena1v1 = "Arena1v1",
        Arena2v2 = "Arena2v2",
        ArenaFFA = "ArenaFFA",
    },
}

return Config
