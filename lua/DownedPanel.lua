local HMH = HMH

if not HMH:GetOption("downed") then
	return
end

local downed_alpha = HMH:GetOption("DownedAlpha")
Hooks:PostHook(HUDPlayerDowned, "init", "HMH_HUDPlayerDowned_init", function(self, ...)
	local timer_msg = self._hud_panel:child("downed_panel"):child("timer_msg")
	if timer_msg then
		timer_msg:set_color(HMH:GetColor("DownedText"))
		timer_msg:set_alpha(downed_alpha)
	end
	self._hud.timer:set_color(HMH:GetColor("DownedTimer"))
	self._hud.timer:set_alpha(downed_alpha)
	self._hud.timer:set_font(Idstring("fonts/font_medium"))
end)

Hooks:PostHook(HUDPlayerDowned, "show_timer", "HMH_HUDPlayerDowned_show_timer", function(self, ...)
	local timer_msg = self._hud_panel:child("downed_panel"):child("timer_msg")

	if timer_msg then
		timer_msg:set_alpha(downed_alpha)
	end
	self._hud.timer:set_alpha(downed_alpha)
end)

Hooks:PostHook(HUDPlayerDowned, "hide_timer", "HMH_HUDPlayerDowned_hide_timer", function(self, ...)
	local timer_msg = self._hud_panel:child("downed_panel"):child("timer_msg")
	if timer_msg then
		timer_msg:set_alpha(downed_alpha)
	end
	self._hud.timer:set_alpha(downed_alpha / 2)
end)