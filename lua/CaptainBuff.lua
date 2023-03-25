if not (HMH:GetOption("assault") and HMH:GetOption("captain_buff")) then
	return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	function HUDManager:set_vip_text(buff)
		if self._hud_assault_corner.set_vip_text then
			self._hud_assault_corner:set_vip_text(buff)
		end
	end
elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebesiege" then
	Hooks:PostHook(GroupAIStateBesiege, "set_damage_reduction_buff_hud", "HMH_set_damage_reduction_buff_hud", function(self, ...)
		local law1team = self:_get_law1_team()
		if law1team then
			managers.hud:set_vip_text(law1team.damage_reduction and math.round(law1team.damage_reduction * 10) or 0)
		end
	end)
end