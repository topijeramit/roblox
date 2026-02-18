local PetsConfig = {}

PetsConfig.RarityMultiplier = {
	Common = 1,
	Rare = 2,
	Epic = 4,
	Legendary = 8,
}

PetsConfig.Pets = {
	Slime = {
		DisplayName = "Slime",
		Rarity = "Common",
		BasePower = 1,
	},
	Dog = {
		DisplayName = "Dog",
		Rarity = "Common",
		BasePower = 1.2,
	},
	Fox = {
		DisplayName = "Fox",
		Rarity = "Rare",
		BasePower = 2,
	},
	Dragon = {
		DisplayName = "Dragon",
		Rarity = "Epic",
		BasePower = 4,
	},
	Phoenix = {
		DisplayName = "Phoenix",
		Rarity = "Legendary",
		BasePower = 8,
	},
}

return PetsConfig
