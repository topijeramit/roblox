local EggsConfig = require(game.ReplicatedStorage.Shared.Config.EggsConfig)
local WeightedRandom = require(game.ReplicatedStorage.Shared.Modules.WeightedRandom)
local InventoryService = require(script.Parent.InventoryService)

local HatchService = {}

function HatchService.hatch(profile, eggId: string, amount: number): (boolean, string?, { any }?)
	local egg = EggsConfig[eggId]
	if not egg then
		return false, "InvalidEgg"
	end
	if amount ~= 1 and amount ~= 3 then
		return false, "InvalidAmount"
	end

	local totalCost = egg.Price * amount
	if profile.Coins < totalCost then
		return false, "NotEnoughCoins"
	end

	profile.Coins -= totalCost
	local hatched = {}
	for _ = 1, amount do
		local petId = WeightedRandom.roll(egg.Pool)
		table.insert(hatched, InventoryService.addPet(profile, petId))
	end

	return true, nil, hatched
end

return HatchService
