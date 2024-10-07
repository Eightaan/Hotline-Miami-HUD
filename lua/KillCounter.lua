local civies =
{
    civilian = true,
    civilian_female = true,
    civilian_mariachi = true
}

Hooks:PostHook( StatisticsManager, "killed", "HMH_StatisticsManager_killed", function(self, data, ...)
    if civies[data.name] then
        return
    end
	local bullets = data.variant == "bullet"
	local melee = data.variant == "melee" or data.weapon_id and tweak_data.blackmarket.melee_weapons[data.weapon_id]
	local booms = data.variant == "explosion"
	local other = not (bullets or melee or booms)
	local is_valid_kill = bullets or melee or booms or other
	if is_valid_kill then
        HMH.TotalKills = HMH.TotalKills + 1
		if melee then
			managers.hud:Set_bloodthirst(0)
		end
    end
end)