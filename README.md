# Roblox AFK Pet Hatch + Ranch (Luau ModuleScript MVP)

This repo contains a clean ModuleScript-first architecture for an AFK pet hatching + ranch simulator.

## Folder Structure

```text
game/
  ReplicatedStorage/
    Shared/
      Config/
        GameBalance.lua
        EggsConfig.lua
        PetsConfig.lua
      Modules/
        Types.lua
        WeightedRandom.lua
    Remotes/                  # auto-created at runtime in Bootstrap.server.lua
      GetState (RemoteFunction)
      StateUpdated (RemoteEvent)
      Hatch (RemoteEvent)
      EquipPet (RemoteEvent)
      UnequipPet (RemoteEvent)
      FusePet (RemoteEvent)

  ServerScriptService/
    Bootstrap.server.lua
    Modules/
      ProfileStore.lua
      RateLimiter.lua
    Services/
      EconomyService.lua
      HatchService.lua
      InventoryService.lua
      RemoteService.lua

  StarterPlayer/
    StarterPlayerScripts/
      UI/
        HatchController.client.lua
```

## MVP Feature Mapping

- **Server-authoritative AFK coins every second**: `EconomyService` loops on Heartbeat and awards coins using equipped pet multiplier.
- **2 egg types with weighted rarity**: `EggsConfig` + `WeightedRandom` + `HatchService`.
- **Hatch single + x3**: `HatchService.hatch(profile, eggId, amount)` allows amount `1` or `3`.
- **Pet inventory with unique IDs + equip up to 3**: `InventoryService` uses GUIDs and enforces `MaxEquippedPets`.
- **Equipped pets increase coin gain**: `InventoryService.getCoinMultiplier` powers AFK economy tick.
- **Fusion 3x same pet -> +1 star**: `InventoryService.fuse` consumes 3 same `PetId` + `Stars`, creates upgraded pet.
- **DataStore + offline earnings (4h cap)**: `ProfileStore` loads/saves profile and computes capped offline reward.
- **Secure remotes with validation + rate limiting**: `RemoteService` validates payloads; `RateLimiter` enforces per-action request caps.

## Key ModuleScripts

### `ServerScriptService/Modules/ProfileStore.lua`
- Loads/saves profile from DataStore.
- Applies offline earnings at login:
  - `offlineSeconds = clamp(now - LastSeen, 0, 4h)`
  - `coins += offlineSeconds * BaseCoinsPerSecond`

### `ServerScriptService/Services/EconomyService.lua`
- Every 1s AFK tick:
  - `coins += BaseCoinsPerSecond * petMultiplier`
- Runs server-side only.

### `ServerScriptService/Services/HatchService.lua`
- Validates egg existence and amount (`1` or `3`).
- Checks coins and deducts total cost.
- Rolls weighted rewards and adds generated pet instances to inventory.

### `ServerScriptService/Services/InventoryService.lua`
- Adds pets with unique GUID.
- Equips/unequips with max equip guard.
- Computes coin multiplier from equipped pet power + stars.
- Fuses 3 matching pets into a +1 star upgraded pet.

### `ServerScriptService/Services/RemoteService.lua`
- Owns all remote handlers.
- Validates data shape/type/length.
- Applies per-player per-action rate limits.
- Never trusts client inventory/coins.

## Example UI Event Wiring

`StarterPlayerScripts/UI/HatchController.client.lua` includes example handlers you can bind to buttons:

- `OnHatchOnePressed(eggId)` → `Hatch:FireServer({ EggId = eggId, Amount = 1 })`
- `OnHatchThreePressed(eggId)` → `Hatch:FireServer({ EggId = eggId, Amount = 3 })`
- `OnEquipPressed(petUid)` → `EquipPet:FireServer(petUid)`
- `OnUnequipPressed(petUid)` → `UnequipPet:FireServer(petUid)`
- `OnFusePressed(petId, starLevel)` → `FusePet:FireServer(petId, starLevel)`
- State refresh comes from `StateUpdated.OnClientEvent` + initial `GetState:InvokeServer()`.

## Notes

- Keep all economy mutations server-side.
- Save on `PlayerRemoving` and `BindToClose`.
- For production scale, migrate to ProfileService/DataStore2 and add retry/backoff + session locking.
