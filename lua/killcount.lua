Hooks:PostHook( StatisticsManager, "killed", "hmh_StatisticsManager_killed", function(self, data, ...)
	local bullets = data.variant == "bullet"
	local melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
	local booms = data.variant == "explosion"
	local other = not bullets and not melee and not booms

	if bullets and data.name ~= "civilian" and data.name ~= "civilian_female" and data.name ~= "civilian_mariachi" then
		HMH.TotalKills = HMH.TotalKills + 1
	elseif melee and data.name ~= "civilian" and data.name ~= "civilian_female" and data.name ~= "civilian_mariachi" then
		HMH.TotalKills = HMH.TotalKills + 1
	elseif booms and data.name ~= "civilian" and data.name ~= "civilian_female" and data.name ~= "civilian_mariachi" then
		HMH.TotalKills = HMH.TotalKills + 1
	elseif other and data.name ~= "civilian" and data.name ~= "civilian_female" and data.name ~= "civilian_mariachi" then
		HMH.TotalKills = HMH.TotalKills + 1	
	end
end)