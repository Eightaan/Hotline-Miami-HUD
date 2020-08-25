local mvec3_dist_sq = mvector3.distance_sq
local ignored_states = { arrested = 1, bleed_out = 1, fatal = 1, incapacitated = 1 }

local PS_get_intimidation_action_orig = PlayerStandard._get_intimidation_action
function PlayerStandard:_get_intimidation_action(prime_target, primary_only, detect_only, secondary, ...)
	local voice_type, new_action, plural = PS_get_intimidation_action_orig(self, prime_target, primary_only, detect_only, secondary, ...)
	if voice_type == "revive" or secondary or detect_only then
		return voice_type, plural, prime_target
	end

	local unit_type_enemy = 0
	local unit_type_teammate = 2

	if prime_target then
		if prime_target.unit_type == unit_type_teammate then
			local record = managers.groupai:state():all_criminals()[prime_target.unit:key()]
			local current_state_name = self._unit:movement():current_state_name()
			if not ignored_states[current_state_name] then
				local rally_skill_data = self._ext_movement:rally_skill_data()
				if rally_skill_data and mvec3_dist_sq(self._pos, record.m_pos) < rally_skill_data.range_sq then
					if prime_target.unit:base().is_husk_player then
						local is_arrested = prime_target.unit:movement():current_state_name() == "arrested"
						needs_revive = prime_target.unit:interaction():active() and prime_target.unit:movement():need_revive() and not is_arrested
					else
						needs_revive = prime_target.unit:character_damage():need_revive()
					end

					if needs_revive and managers.player:has_disabled_cooldown_upgrade("cooldown", "long_dis_revive") then

						local remaining_cooldown = managers.player:get_disabled_cooldown_time("cooldown", "long_dis_revive") + 1 -- Adding 1 because the cooldown seem to count 0 as an extra second?
						if remaining_cooldown > 0 and HMH:GetOption("inspire") then
							remaining_cooldown = remaining_cooldown - Application:time()
							managers.hud:show_hint({ text = string.format("Inspire still has a cooldown of %i seconds", remaining_cooldown) })		
						end
					end
				end
			end
		else
			if prime_target.unit_type == unit_type_enemy then
				plural = false
			end
		end
	end

	return voice_type, plural, prime_target
end
