local HMH = HMH

if not HMH:GetOption("assault") and HMH:GetOption("captain_buff") then
	return
end

Hooks:PostHook(GroupAIStateBesiege, "set_damage_reduction_buff_hud", "HMH_GroupAIStateBesiege_set_damage_reduction_buff_hud", function(self, ...)
	local law1team = self:_get_law1_team()
	if law1team then
		managers.hud:set_vip_text(law1team.damage_reduction and math.round(law1team.damage_reduction * 10) or 0)
	end
end)
