local RunService = game:GetService("RunService")

local GameBalance = require(game.ReplicatedStorage.Shared.Config.GameBalance)
local InventoryService = require(script.Parent.InventoryService)

local EconomyService = {}

function EconomyService.start(ProfileStore)
	local accumulator = 0
	RunService.Heartbeat:Connect(function(dt)
		accumulator += dt
		if accumulator < GameBalance.AfkTickSeconds then
			return
		end
		accumulator -= GameBalance.AfkTickSeconds

		for player, profile in pairs(ProfileStore._debugCache()) do
			if player.Parent then
				local multiplier = InventoryService.getCoinMultiplier(profile)
				profile.Coins += GameBalance.BaseCoinsPerSecond * multiplier
			end
		end
	end)
end

return EconomyService
