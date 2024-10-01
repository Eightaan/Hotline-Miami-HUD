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
	local other = not bullets and not melee and not booms
    if bullets or melee or booms or other then
        HMH.TotalKills = HMH.TotalKills + 1
    end
	if melee then
		local buff = 0
		managers.hud:Set_bloodthirst(buff)
	end
end)