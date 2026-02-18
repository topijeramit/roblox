local ReplicatedStorage = game:GetService("ReplicatedStorage")

local remotes = ReplicatedStorage:WaitForChild("Remotes")
local rfGetState = remotes:WaitForChild("GetState")
local reHatch = remotes:WaitForChild("Hatch")
local reEquipPet = remotes:WaitForChild("EquipPet")
local reUnequipPet = remotes:WaitForChild("UnequipPet")
local reFusePet = remotes:WaitForChild("FusePet")
local reStateUpdated = remotes:WaitForChild("StateUpdated")

local state = {
	Coins = 0,
	Pets = {},
}

local function countPets(pets)
	local c = 0
	for _ in pairs(pets) do
		c += 1
	end
	return c
end

local function render()
	print("Coins:", state.Coins)
	print("Pets:", countPets(state.Pets))
end

local function onStateUpdated(serverState)
	if type(serverState) ~= "table" then
		return
	end
	state.Coins = serverState.Coins or state.Coins
	state.Pets = serverState.Pets or state.Pets

	if serverState.OfflineEarnings and serverState.OfflineEarnings > 0 then
		print(("Welcome back! Offline earnings: %d"):format(serverState.OfflineEarnings))
	end
	
	render()
end

local function requestInitialState()
	local serverState = rfGetState:InvokeServer()
	onStateUpdated(serverState)
end

-- Example hooks for UI buttons:
local function onHatchOnePressed(eggId)
	reHatch:FireServer({ EggId = eggId, Amount = 1 })
end

local function onHatchThreePressed(eggId)
	reHatch:FireServer({ EggId = eggId, Amount = 3 })
end

local function onEquipPressed(petUid)
	reEquipPet:FireServer(petUid)
end

local function onUnequipPressed(petUid)
	reUnequipPet:FireServer(petUid)
end

local function onFusePressed(petId, starLevel)
	reFusePet:FireServer(petId, starLevel)
end

reStateUpdated.OnClientEvent:Connect(onStateUpdated)
requestInitialState()

return {
	OnHatchOnePressed = onHatchOnePressed,
	OnHatchThreePressed = onHatchThreePressed,
	OnEquipPressed = onEquipPressed,
	OnUnequipPressed = onUnequipPressed,
	OnFusePressed = onFusePressed,
}
