# SOUL RING Project Overview

## Explorer Layout
```
ReplicatedStorage
  Remotes
    Combat
      Combat: StartCombo (RemoteEvent)
      Combat: Hit (RemoteEvent)
      Combat: Block (RemoteEvent)
      Combat: Shock (RemoteEvent)
      Combat: Kick (RemoteEvent)
      Combat: LockOn (RemoteEvent)
    UX
      UX: Emote (RemoteEvent)
      UX: Taunt (RemoteEvent)
    Shop
      Shop: Purchase (RemoteEvent)
    FX
      KillEffect (RemoteEvent)
  Shared
    Config (ModuleScript)
    Net (ModuleScript)
    Types (ModuleScript)
ServerScriptService
  CombatServer (Folder)
    AntiExploit (ModuleScript)
    DamageService (ModuleScript)
    HitboxService (ModuleScript)
    StateService (ModuleScript)
    LockOnService (ModuleScript)
    AbilitiesService (ModuleScript)
    CombatGateway (Script)
  ProfileService (Script)
  Matchmaking (Script)
StarterPlayer
  StarterPlayerScripts
    InputClient (LocalScript)
    CameraClient (LocalScript)
    UIClient (LocalScript)
    FXClient (LocalScript)
  StarterCharacterScripts
    AnimatorClient (LocalScript)
StarterGui
  MainUI (ScreenGui placeholder; constructed at runtime)
Workspace
  Spawns (Folder with SpawnLocations)
  NPC_Dummy (Model for training)
```

## Instances to Create in Studio
- **ReplicatedStorage/Remotes**
  - Folder `Remotes`
    - Folder `Combat` with RemoteEvents named exactly per control list.
    - Folder `UX` with `UX: Emote`, `UX: Taunt` RemoteEvents.
    - Folder `Shop` with `Shop: Purchase` RemoteEvent.
    - Folder `FX` with `KillEffect` RemoteEvent.
- **ReplicatedStorage/Shared**
  - ModuleScripts `Config`, `Net`, `Types` (contents provided).
- **ServerScriptService**
  - Folder `CombatServer` containing ModuleScripts `AntiExploit`, `DamageService`, `HitboxService`, `StateService`, `LockOnService`, `AbilitiesService`, and Script `CombatGateway`.
  - Scripts `ProfileService`, `Matchmaking`.
- **StarterPlayer/StarterPlayerScripts**
  - LocalScripts `InputClient`, `CameraClient`, `UIClient`, `FXClient`.
- **StarterPlayer/StarterCharacterScripts**
  - LocalScript `AnimatorClient` (placeholder animations set to `rbxassetid://0`; replace with authored animations).
- **StarterGui**
  - ScreenGui `MainUI` (script constructs bars, wheel, etc.).
- **Workspace**
  - Folder `Spawns` with SpawnLocations for hub and arena teleports.
  - Model `NPC_Dummy` with Humanoid for practice.
  - Teleport pads named `Arena1v1`, `Arena2v2`, `ArenaFFA` matching `Config.Match.HubTeleportPads`.

## Placeholder Animations
`AnimatorClient` creates placeholder `Animation` objects with `AnimationId = rbxassetid://0`. Replace each ID with studio-authored martial animations before publishing.

## Testing Checklist
1. Execute light combo (LMB or Light button) three times; confirm hitboxes apply damage sequentially and combo resets after timeout.
2. Hold block (RMB/Block button) and receive light hit; observe 70% damage reduction and stamina drain.
3. Use Kick (F/button) on blocking opponent; opponent enters stun (0.8s) and poise resets.
4. Cast Shock (R/button) within 6 studs; enemies are stunned briefly and stamina decreases by 25; cooldown prohibits recast for 6s.
5. Toggle lock-on (CTRL/Lock button); camera orbits nearest opponent within 30° cone and updates when closer target appears.
6. Trigger Taunt (T/button); stamina regenerates small amount and ult meter attribute increments.
7. Perform kill to verify `KillEffect` VFX (double shockwave, orb spiral, dissolve).
8. Attempt to spam `Combat: StartCombo` >8 times per second; server should ignore excess and warn in output.
9. Attempt to spam `Combat: Shock` faster than cooldown; server rejects until cooldown ends.
10. Try to fire Kick beyond 6 studs by teleporting client; server distance check prevents damage.
11. Verify blocking players are not damaged by allied hits in team mode.
12. Test GuardBreak: blocking player hit by Kick enters `SR_BlockBroken` cooldown and is stunned.
13. Confirm Shock knocks back and stuns; victims `Humanoid` forced to `Physics` for brief duration.
14. Lock-on remote with invalid ID; server ignores and keeps previous target.
15. Shop purchase with insufficient coins; server declines and coins stay unchanged.
16. Shop purchase when coins ≥ price; coins deducted and ownership BoolValue created.
17. Mobile controls: ensure every button triggers matching remote.
18. Profile saves: run in Studio with API enabled, award coins, rejoin to confirm persistence (mock with test command).
19. DataStore failure simulation (enable `StudioAPI` errors) - script retries and logs warning without crash.
20. Stress test with 30 dummy players (local simulation) verifying pooled VFX and stable 60 FPS.

## Studio Testing Tips
- Enable `Studio Access to API Services` before testing DataStore flows.
- Use Play Solo to validate hub teleports and kill effects; Training dummy can be cloned for quick combos.
- Adjust `Config` constants to tune combat speed and stamina drain when iterating.
