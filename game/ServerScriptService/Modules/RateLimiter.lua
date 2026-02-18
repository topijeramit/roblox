local RateLimiter = {}

local buckets = {} -- [userId][action] = { windowStart, count }

function RateLimiter.check(userId: number, action: string, maxPerSecond: number): boolean
	buckets[userId] = buckets[userId] or {}
	local now = os.clock()
	local bucket = buckets[userId][action]
	if not bucket or now - bucket.windowStart >= 1 then
		buckets[userId][action] = {
			windowStart = now,
			count = 1,
		}
		return true
	end

	if bucket.count >= maxPerSecond then
		return false
	end

	bucket.count += 1
	return true
end

function RateLimiter.clear(userId: number)
	buckets[userId] = nil
end

return RateLimiter
