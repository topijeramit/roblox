local Players = game:GetService("Players")

local GameBalance = require(game.ReplicatedStorage.Shared.Config.GameBalance)
local ProfileStore = require(game.ServerScriptService.Modules.ProfileStore)
local RateLimiter = require(game.ServerScriptService.Modules.RateLimiter)
local HatchService = require(script.Parent.HatchService)
local InventoryService = require(script.Parent.InventoryService)

local remotesFolder = game.ReplicatedStorage:WaitForChild("Remotes")
local rfGetState = remotesFolder:WaitForChild("GetState")
local reHatch = remotesFolder:WaitForChild("Hatch")
local reEquipPet = remotesFolder:WaitForChild("EquipPet")
local reUnequipPet = remotesFolder:WaitForChild("UnequipPet")
local reFusePet = remotesFolder:WaitForChild("FusePet")
local reStateUpdated = remotesFolder:WaitForChild("StateUpdated")

local RemoteService = {}

local function sanitizeString(value, maxLen)
	if type(value) ~= "string" then
		return nil
	end
	if #value > maxLen then
		return nil
	end
	return value
end

local function getProfile(player)
	return ProfileStore.get(player)
end

local function pushState(player)
	local profile = getProfile(player)
	if not profile then
		return
	end

	reStateUpdated:FireClient(player, {
		Coins = profile.Coins,
		Pets = profile.Pets,
	})
end

function RemoteService.start()
	Players.PlayerAdded:Connect(function(player)
		local profile, offline = ProfileStore.load(player)
		reStateUpdated:FireClient(player, {
			Coins = profile.Coins,
			Pets = profile.Pets,
			OfflineEarnings = offline,
		})
	end)

	rfGetState.OnServerInvoke = function(player)
		local profile = getProfile(player)
		if not profile then
			return nil
		end
		return {
			Coins = profile.Coins,
			Pets = profile.Pets,
		}
	end

	reHatch.OnServerEvent:Connect(function(player, payload)
		if not RateLimiter.check(player.UserId, "Hatch", GameBalance.RemoteRateLimits.Hatch) then
			return
		end
		if type(payload) ~= "table" then
			return
		end

		local eggId = sanitizeString(payload.EggId, 32)
		local amount = payload.Amount
		if not eggId or type(amount) ~= "number" then
			return
		end

		local profile = getProfile(player)
		if not profile then
			return
		end

		local ok = HatchService.hatch(profile, eggId, amount)
		if ok then
			pushState(player)
		end
	end)

	reEquipPet.OnServerEvent:Connect(function(player, uid)
		if not RateLimiter.check(player.UserId, "EquipPet", GameBalance.RemoteRateLimits.EquipPet) then
			return
		end
		uid = sanitizeString(uid, 64)
		if not uid then
			return
		end
		local profile = getProfile(player)
		if not profile then
			return
		end

		local ok = InventoryService.equipPet(profile, uid)
		if ok then
			pushState(player)
		end
	end)

	reUnequipPet.OnServerEvent:Connect(function(player, uid)
		if not RateLimiter.check(player.UserId, "UnequipPet", GameBalance.RemoteRateLimits.UnequipPet) then
			return
		end
		uid = sanitizeString(uid, 64)
		if not uid then
			return
		end
		local profile = getProfile(player)
		if not profile then
			return
		end

		local ok = InventoryService.unequipPet(profile, uid)
		if ok then
			pushState(player)
		end
	end)

	reFusePet.OnServerEvent:Connect(function(player, petId, starLevel)
		if not RateLimiter.check(player.UserId, "FusePet", GameBalance.RemoteRateLimits.FusePet) then
			return
		end
		petId = sanitizeString(petId, 32)
		if not petId or type(starLevel) ~= "number" or starLevel < 0 then
			return
		end

		local profile = getProfile(player)
		if not profile then
			return
		end

		local ok = InventoryService.fuse(profile, petId, starLevel)
		if ok then
			pushState(player)
		end
	end)
end

return RemoteService
