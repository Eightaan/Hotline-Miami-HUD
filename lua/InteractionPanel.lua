if RequiredScript == "lib/managers/hud/hudinteraction" then
    Hooks:PostHook(HUDInteraction, "show_interact", "HMH_HUDInteraction_show_interact", function(self, ...)
	    if HMH:GetOption("interact") then
			self._hud_panel:child(self._child_name_text):set_color(HMH:GetColor("Interaction"))
			self._hud_panel:child(self._child_name_text):set_alpha(HMH:GetOption("InteractAlpha"))
			self._hud_panel:child(self._child_ivalid_name_text):set_alpha(HMH:GetOption("InteractAlpha"))
	    end
    end)
    
	Hooks:PreHook(HUDInteraction, "_animate_interaction_complete", "HMH_HUDInteraction_animate_interaction_complete", function(self, bitmap, circle)
		if HMH:GetOption("interact_texture") > 1 then
			circle:set_visible(false)
		end
	end)

elseif RequiredScript == "lib/units/interactions/interactionext" then
	Hooks:PostHook(BaseInteractionExt, "_add_string_macros", "HMH_BaseInteractionExt_add_string_macros", function (self, macros, ...)
	    macros.INTERACT = self:_btn_interact() or managers.localization:get_default_macro("BTN_INTERACT") --Ascii ID for RB
	    if self._unit:carry_data() then
		    local carry_id = self._unit:carry_data():carry_id()
			macros.BAG = managers.localization:text(tweak_data.carry[carry_id]) and managers.localization:text(tweak_data.carry[carry_id].name_id)
	    end
    end)

	Hooks:PostHook(BaseInteractionExt, "interact_start", "HMH_BaseInteractionExt_interact_start", function (self, player, data, ...)
		local t = Application:time()
		if HMH:GetOption("stealth_c4") and managers.groupai:state():whisper_mode() and self._tweak_data.required_deployable and self._tweak_data.required_deployable == "trip_mine" and (t - (self._last_shaped_charge_t or 0) >= 0.25) then
			self._last_shaped_charge_t = t
			return false
		end
	end)
end