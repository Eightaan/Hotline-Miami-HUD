if RequiredScript == "lib/managers/hud/hudinteraction" then
    Hooks:PostHook(HUDInteraction, "init", "HMH_HUDInteractionInit", function(self, ...)
	    if HMH:GetOption("interact") then
			self._hud_panel:child(self._child_name_text):set_color(HMH:GetColor("Interaction"))
			self._hud_panel:child(self._child_name_text):set_alpha(HMH:GetOption("InteractAlpha"))
	    end
    end)
    if HMH:GetOption("interact_texture") > 1 then
        Hooks:PreHook(HUDInteraction, "_animate_interaction_complete", "HMH_HUDInteractionAnimateInteractionComplete", function(self, bitmap, circle)
		    circle:set_visible(false)
        end)
	end
elseif RequiredScript == "lib/units/interactions/interactionext" then

    local _add_string_macros_original = BaseInteractionExt._add_string_macros
    function BaseInteractionExt:_add_string_macros(macros, ...)
	    _add_string_macros_original(self, macros, ...)
	    macros.INTERACT = self:_btn_interact() or managers.localization:get_default_macro("BTN_INTERACT") --Ascii ID for RB
	    if self._unit:carry_data() then
		    local carry_id = self._unit:carry_data():carry_id()
			macros.BAG = managers.localization:text(tweak_data.carry[carry_id]) and managers.localization:text(tweak_data.carry[carry_id].name_id)
	    end
    end

    local BaseInteraction_interact_start_original = BaseInteractionExt.interact_start
	function BaseInteractionExt:interact_start(player, data, ...)
		local t = Application:time()
		if HMH:GetOption("stealth_c4") and managers.groupai:state():whisper_mode() and self._tweak_data.required_deployable and self._tweak_data.required_deployable == "trip_mine" and (t - (self._last_shaped_charge_t or 0) >= 0.25) then
			self._last_shaped_charge_t = t
			return false
		end
		return BaseInteraction_interact_start_original(self, player, data, ...)
	end
end