local WeightedRandom = {}

function WeightedRandom.roll(pool)
	local totalWeight = 0
	for _, entry in ipairs(pool) do
		totalWeight += entry.Weight
	end

	local cursor = Random.new():NextNumber(0, totalWeight)
	local running = 0
	for _, entry in ipairs(pool) do
		running += entry.Weight
		if cursor <= running then
			return entry.PetId
		end
	end

	return pool[#pool].PetId
end

return WeightedRandom
