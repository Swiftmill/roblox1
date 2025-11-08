export type PlayerProfile = {
    Level: number,
    XP: number,
    Coins: number,
    OwnedCosmetics: {string},
    EmoteBinds: {number},
    Settings: {[string]: any},
}

export type CombatState = {
    ComboStep: number,
    ComboTick: number,
    Block: boolean,
    Stamina: number,
    MaxStamina: number,
    Poise: number,
    MaxPoise: number,
    LockTarget: Player?,
    Cooldowns: {[string]: number},
    Sprinting: boolean,
}

export type HitContext = {
    Player: Player,
    Step: number,
    Damage: number,
    Timestamp: number,
    Position: Vector3,
    Kind: string?,
}

export type AssistTag = {
    Player: Player,
    Time: number,
}

return {}
