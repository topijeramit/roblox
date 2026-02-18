local ReplicatedStorage = game:GetService("ReplicatedStorage")

local function ensureRemote(className, name)
	local remotes = ReplicatedStorage:FindFirstChild("Remotes")
	if not remotes then
		remotes = Instance.new("Folder")
		remotes.Name = "Remotes"
		remotes.Parent = ReplicatedStorage
	end

	local existing = remotes:FindFirstChild(name)
	if existing and existing.ClassName == className then
		return existing
	end

	if existing then
		existing:Destroy()
	end

	local remote = Instance.new(className)
	remote.Name = name
	remote.Parent = remotes
	return remote
end

ensureRemote("RemoteFunction", "GetState")
ensureRemote("RemoteEvent", "StateUpdated")
ensureRemote("RemoteEvent", "Hatch")
ensureRemote("RemoteEvent", "EquipPet")
ensureRemote("RemoteEvent", "UnequipPet")
ensureRemote("RemoteEvent", "FusePet")

local ProfileStore = require(script.Parent.Modules.ProfileStore)
local EconomyService = require(script.Parent.Services.EconomyService)
local RemoteService = require(script.Parent.Services.RemoteService)

EconomyService.start(ProfileStore)
RemoteService.start()
