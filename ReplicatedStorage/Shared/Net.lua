local RunService = game:GetService("RunService")
local Net = {}

local RATE_LIMIT = 12
local WINDOW = 1

local signalCache = {}
local rateTable = {}

local function key(player, remote)
    return player.UserId .. "::" .. remote.Name
end

local function allow(player, remote)
    local k = key(player, remote)
    local now = os.clock()
    local info = rateTable[k]
    if not info then
        info = {count = 0, tick = now}
        rateTable[k] = info
    end

    if now - info.tick > WINDOW then
        info.count = 0
        info.tick = now
    end

    info.count += 1
    return info.count <= RATE_LIMIT
end

function Net.BindRemote(remote, callback)
    signalCache[remote] = callback
    remote.OnServerEvent:Connect(function(player, ...)
        if not allow(player, remote) then
            warn("Rate limit hit by", player)
            return
        end
        callback(player, ...)
    end)
end

function Net.Fire(remote, ...)
    if RunService:IsServer() then
        remote:FireAllClients(...)
    else
        remote:FireServer(...)
    end
end

function Net.FireClient(remote, player, ...)
    remote:FireClient(player, ...)
end

function Net.FireServer(remote, ...)
    remote:FireServer(...)
end

return Net
