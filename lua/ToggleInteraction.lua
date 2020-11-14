if VHUDPlus then return end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	function HUDManager:set_interaction_bar_locked(status, tweak_entry)
	    self._hud_interaction:set_locked(status, tweak_entry)
	end

elseif RequiredScript == "lib/units/beings/player/states/playerstandard" then
	local _update_interaction_timers_original = PlayerStandard._update_interaction_timers
	local _check_action_interact_original = PlayerStandard._check_action_interact

	function PlayerStandard:_update_interaction_timers(t, ...)
		self:_check_interaction_locked(t)
		return _update_interaction_timers_original(self, t, ...)
	end

	function PlayerStandard:_check_action_interact(t, input, ...)
		if not self:_check_interact_toggle(t, input) then
			return _check_action_interact_original(self, t, input, ...)
		end
	end

	function PlayerStandard:_check_interaction_locked(t)
		local is_locked = false
		if self._interact_params ~= nil then
			if HMH:GetOption("toggle_interact") > 0 then
				is_locked = self._interact_params and (self._interact_params.timer >= HMH:GetOption("toggle_interact"))
			end
		end

		if self._interaction_locked ~= is_locked then
			managers.hud:set_interaction_bar_locked(is_locked, self._interact_params and self._interact_params.tweak_data or "")
			self._interaction_locked = is_locked
		end
	end

	function PlayerStandard:_check_interact_toggle(t, input)
		local interrupt_key_press = input.btn_interact_press
		if HMH:GetOption("interupt_interact") then
			interrupt_key_press = input.btn_use_item_press
		end

		if interrupt_key_press and self:_interacting() then
			self:_interupt_action_interact()
			return true
		elseif input.btn_interact_release and self._interact_params then
			if self._interaction_locked then
				return true
			end
		end
	end

elseif RequiredScript == "lib/managers/hud/hudinteraction" then
	local hide_interaction_bar_original = HUDInteraction.hide_interaction_bar
	local show_interact_original		= HUDInteraction.show_interact

	function HUDInteraction:hide_interaction_bar(complete, ...)
		if self._old_text then
			self._hud_panel:child(self._child_name_text):set_text(self._old_text or "")
			self._old_text = nil
		end
		return hide_interaction_bar_original(self, complete, ...)
	end

	function HUDInteraction:set_locked(status, tweak_entry)
		if status then
			self._old_text = self._hud_panel:child(self._child_name_text):text()
			local locked_text = self._old_text
			if HMH:GetOption("interupt_interact_hint") then
				local btn_cancel = HMH:GetOption("interupt_interact") and (managers.localization:btn_macro("use_item", true) or managers.localization:get_default_macro("BTN_USE_ITEM")) or (managers.localization:btn_macro("interact", true) or managers.localization:get_default_macro("BTN_INTERACT"))
				locked_text = managers.localization:to_upper_text(tweak_entry == "corpse_alarm_pager" and "hmh_int_locked_pager" or "hmh_int_locked", {BTN_CANCEL = btn_cancel})
			end
			self._hud_panel:child(self._child_name_text):set_text(locked_text)
		end
	end

	function HUDInteraction:show_interact(data)
		if not self._old_text then
			return show_interact_original(self, data)
		end
	end
end