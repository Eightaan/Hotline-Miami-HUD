if not HMH:GetOption("downed") then
	return
end

Hooks:PostHook(HUDPlayerDowned, "init", "hudplayerdowned_HMH", function(self, ...)
	self._hud_panel:child("downed_panel"):child("timer_msg"):set_color(HMH:GetColor("DownedText"))
	self._hud.timer:set_color(HMH:GetColor("DownedTimer"))
	self._hud.timer:set_font(Idstring("fonts/font_medium"))
end)