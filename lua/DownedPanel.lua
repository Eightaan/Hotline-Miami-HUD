if not HMH:GetOption("downed") then
	return
end

Hooks:PostHook(HUDPlayerDowned, "init", "hudplayerdowned_HMH", function(self, ...)
    if self._hud_panel:child("downed_panel"):child("timer_msg") then
	    self._hud_panel:child("downed_panel"):child("timer_msg"):set_color(HMH:GetColor("DownedText"))
    	self._hud_panel:child("downed_panel"):child("timer_msg"):set_alpha(HMH:GetOption("DownedAlpha"))
	end
	self._hud.timer:set_color(HMH:GetColor("DownedTimer"))
	self._hud.timer:set_alpha(HMH:GetOption("DownedAlpha"))
	self._hud.timer:set_font(Idstring("fonts/font_medium"))
end)

Hooks:PostHook(HUDPlayerDowned, "show_timer", "hudplayerdowned_show_timer_HMH", function(self, ...)
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_alpha(HMH:GetOption("DownedAlpha"))
	self._hud.timer:set_alpha(HMH:GetOption("DownedAlpha"))
end)

Hooks:PostHook(HUDPlayerDowned, "hide_timer", "hudplayerdowned_hide_timer_HMH", function(self, ...)
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	timer_msg:set_alpha(HMH:GetOption("DownedAlpha") / 2)
	self._hud.timer:set_alpha(HMH:GetOption("DownedAlpha") / 2)
end)