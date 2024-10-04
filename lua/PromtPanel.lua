Hooks:PostHook(HUDWaitingLegend, "update_buttons", "HMH_HUDWaitingLegend_update_buttons", function(self)
	if HMH:GetOption("promt") and self._box then
		local children = {"bg", "left_top", "left_bottom", "right_top", "right_bottom"}
		for _, child in ipairs(children) do
			if self._box:child(child) then
				self._box:child(child):hide()
			end
		end
	end
end)

Hooks:PostHook(HUDWaitingLegend, "show_on", "HMH_HUDWaitingLegend_show_on", function(self, teammate_hud, peer)
    if HMH:GetOption("prompt") then
	    local color_id = peer:id()
	    local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	    if self._btn_text then
		    self._btn_text:set_color(color)
	    end
	    if self._icon then
		    self._icon:set_alpha(0)
	    end
	end
end)