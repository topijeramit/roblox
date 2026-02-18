local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local GameBalance = require(game.ReplicatedStorage.Shared.Config.GameBalance)

local ProfileStore = {}
local store = DataStoreService:GetDataStore("AFKPetRanch_v1")
local cache = {} -- [player] = profile

local function defaultProfile()
	return {
		Coins = 0,
		LastSeen = os.time(),
		Pets = {},
	}
end

function ProfileStore.load(player: Player)
	local key = tostring(player.UserId)
	local ok, data = pcall(function()
		return store:GetAsync(key)
	end)

	local profile = if ok and type(data) == "table" then data else defaultProfile()
	profile.Coins = profile.Coins or 0
	profile.Pets = profile.Pets or {}
	profile.LastSeen = profile.LastSeen or os.time()

	local now = os.time()
	local offlineSeconds = math.max(0, math.min(now - profile.LastSeen, GameBalance.OfflineEarningCapSeconds))
	local offlineEarnings = offlineSeconds * GameBalance.BaseCoinsPerSecond
	profile.Coins += offlineEarnings
	profile.LastSeen = now

	cache[player] = profile
	return profile, offlineEarnings
end

function ProfileStore.get(player: Player)
	return cache[player]
end

function ProfileStore.save(player: Player)
	local profile = cache[player]
	if not profile then
		return
	end
	profile.LastSeen = os.time()

	local key = tostring(player.UserId)
	pcall(function()
		store:SetAsync(key, profile)
	end)
end

function ProfileStore.release(player: Player)
	ProfileStore.save(player)
	cache[player] = nil
end


function ProfileStore._debugCache()
	return cache
end

Players.PlayerRemoving:Connect(function(player)
	ProfileStore.release(player)
end)

game:BindToClose(function()
	for _, player in ipairs(Players:GetPlayers()) do
		ProfileStore.save(player)
	end
end)

return ProfileStore
