Hooks:PostHook(HUDWaitingLegend, "update_buttons", "HMH_HUDWaitingLegend_update_buttons", function(self)
	if HMH:GetOption("promt") and self._box then
		self._box:child("bg"):hide()
		self._box:child("left_top"):hide()
		self._box:child("left_bottom"):hide()
		self._box:child("right_top"):hide()
		self._box:child("right_bottom"):hide()
	end
end)

Hooks:PostHook(HUDWaitingLegend, "show_on", "HMH_HUDWaitingLegend_show_on", function(self, teammate_hud, peer)
    if HMH:GetOption("promt") then
	    local color_id = peer:id()
	    local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	    self._btn_text:set_color(color)
	    self._icon:set_alpha(0)
	end
end)