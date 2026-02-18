local HttpService = game:GetService("HttpService")

local GameBalance = require(game.ReplicatedStorage.Shared.Config.GameBalance)
local PetsConfig = require(game.ReplicatedStorage.Shared.Config.PetsConfig)

local InventoryService = {}

local function getPowerForPet(pet)
	local definition = PetsConfig.Pets[pet.PetId]
	if not definition then
		return 0
	end
	return definition.BasePower * (1 + pet.Stars * GameBalance.StarPowerMultiplier)
end

function InventoryService.addPet(profile, petId: string)
	local uid = HttpService:GenerateGUID(false)
	profile.Pets[uid] = {
		Uid = uid,
		PetId = petId,
		Stars = 0,
		Equipped = false,
		CreatedAt = os.time(),
	}
	return profile.Pets[uid]
end

function InventoryService.countEquipped(profile): number
	local equipped = 0
	for _, pet in pairs(profile.Pets) do
		if pet.Equipped then
			equipped += 1
		end
	end
	return equipped
end

function InventoryService.equipPet(profile, uid: string): (boolean, string?)
	local pet = profile.Pets[uid]
	if not pet then
		return false, "PetNotFound"
	end
	if pet.Equipped then
		return true
	end
	if InventoryService.countEquipped(profile) >= GameBalance.MaxEquippedPets then
		return false, "EquipLimitReached"
	end
	pet.Equipped = true
	return true
end

function InventoryService.unequipPet(profile, uid: string): (boolean, string?)
	local pet = profile.Pets[uid]
	if not pet then
		return false, "PetNotFound"
	end
	pet.Equipped = false
	return true
end

function InventoryService.getCoinMultiplier(profile): number
	local totalPower = 0
	for _, pet in pairs(profile.Pets) do
		if pet.Equipped then
			totalPower += getPowerForPet(pet)
		end
	end
	return math.max(1, 1 + totalPower)
end

function InventoryService.fuse(profile, petId: string, starLevel: number): (boolean, string?, any?)
	local matches = {}
	for uid, pet in pairs(profile.Pets) do
		if pet.PetId == petId and pet.Stars == starLevel then
			table.insert(matches, uid)
			if #matches == GameBalance.FusionRequiredCount then
				break
			end
		end
	end

	if #matches < GameBalance.FusionRequiredCount then
		return false, "InsufficientPets"
	end

	for _, uid in ipairs(matches) do
		profile.Pets[uid] = nil
	end

	local fused = InventoryService.addPet(profile, petId)
	fused.Stars = starLevel + 1
	return true, nil, fused
end

return InventoryService
