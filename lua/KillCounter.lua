if not HMH:GetOption("tab") then
	return
end

local civies ={civilian = true, civilian_female = true, civilian_mariachi = true}

Hooks:PostHook(StatisticsManager, "killed", "HMH_StatisticsManager_killed", function(self, data, ...)
	if civies[data.name] then
		return
	end
	local bullets = data.variant == "bullet"
	local melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
	local booms = data.variant == "explosion"
	local other = not (bullets or melee or booms)
	local is_valid_kill = bullets or melee or booms or other
	if is_valid_kill then
		self:update_kills()
	end
end)

function StatisticsManager:update_kills()
	self._total_kills = (self._total_kills or 0) + 1
end

function StatisticsManager:TotalKills()
	return self._total_kills or 0
end