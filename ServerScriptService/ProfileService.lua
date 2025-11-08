local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")

local PROFILE_VERSION = "v1"
local PROFILE_STORE = DataStoreService:GetDataStore("SOUL_RING_Profile", PROFILE_VERSION)

local DEFAULT_PROFILE = {
    Level = 1,
    XP = 0,
    Coins = 0,
    OwnedCosmetics = {},
    EmoteBinds = {1, 2, 3, 4},
    Settings = {},
}

local profiles = {}

local function deepCopy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        if type(v) == "table" then
            copy[k] = deepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

local function loadProfile(player)
    local success, data
    for _ = 1, 3 do
        success, data = pcall(function()
            return PROFILE_STORE:GetAsync(player.UserId)
        end)
        if success then
            break
        end
        task.wait(2)
    end

    if not success then
        warn("Profile load failed", player)
        data = deepCopy(DEFAULT_PROFILE)
    end

    if data then
        profiles[player] = data
        player:SetAttribute("SR_Coins", data.Coins)
        player:SetAttribute("SR_XP", data.XP)
    end
end

local function saveProfile(player)
    local data = profiles[player]
    if not data then
        return
    end

    data.Coins = player:GetAttribute("SR_Coins") or data.Coins
    data.XP = player:GetAttribute("SR_XP") or data.XP

    local success
    for _ = 1, 3 do
        success = pcall(function()
            PROFILE_STORE:SetAsync(player.UserId, data)
        end)
        if success then
            break
        end
        task.wait(2)
    end

    if not success then
        warn("Profile save failed", player)
    end
end

Players.PlayerAdded:Connect(function(player)
    loadProfile(player)
end)

Players.PlayerRemoving:Connect(function(player)
    saveProfile(player)
    profiles[player] = nil
end)

game:BindToClose(function()
    for player, _ in pairs(profiles) do
        saveProfile(player)
    end
end)
