local GameBalance = {
	BaseCoinsPerSecond = 5,
	MaxEquippedPets = 3,
	AfkTickSeconds = 1,
	OfflineEarningCapSeconds = 4 * 60 * 60,
	FusionRequiredCount = 3,
	StarPowerMultiplier = 0.5, -- each star adds +50% of base power
	RemoteRateLimits = {
		Hatch = 4, -- calls/second
		EquipPet = 8,
		UnequipPet = 8,
		FusePet = 4,
	},
}

return GameBalance
