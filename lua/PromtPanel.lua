if not HMH:GetOption("promt") then
    return
end

local update_buttons_orig = HUDWaitingLegend.update_buttons
function HUDWaitingLegend:update_buttons()
    update_buttons_orig(self)
	if self._box then
		self._box:child("bg"):hide()
		self._box:child("left_top"):hide()
		self._box:child("left_bottom"):hide()
		self._box:child("right_top"):hide()
		self._box:child("right_bottom"):hide()
	end
end

local show_on_orig = HUDWaitingLegend.show_on
function HUDWaitingLegend:show_on(teammate_hud, peer)
	local color_id = peer:id()
	local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
	self._btn_text:set_color(color)
	self._icon:set_alpha(0)
	show_on_orig(self, teammate_hud, peer)
end