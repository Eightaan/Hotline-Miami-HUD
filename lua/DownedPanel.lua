if not HMH:GetOption("downed") then
	return
end

Hooks:PostHook(HUDPlayerDowned, "init", "hudplayerdowned_HMH", function(self, ...)
	local timer_msg = self._hud_panel:child("downed_panel"):child("timer_msg")
    if timer_msg then
	    timer_msg:set_color(HMH:GetColor("DownedText"))
        timer_msg:set_alpha(HMH:GetOption("DownedAlpha"))
	end
	self._hud.timer:set_color(HMH:GetColor("DownedTimer"))
	self._hud.timer:set_alpha(HMH:GetOption("DownedAlpha"))
	self._hud.timer:set_font(Idstring("fonts/font_medium"))
end)

Hooks:PostHook(HUDPlayerDowned, "show_timer", "hudplayerdowned_show_timer_HMH", function(self, ...)
	local timer_msg = self._hud_panel:child("downed_panel"):child("timer_msg")

    if timer_msg then
	    timer_msg:set_alpha(HMH:GetOption("DownedAlpha"))
	end
	self._hud.timer:set_alpha(HMH:GetOption("DownedAlpha"))
end)

Hooks:PostHook(HUDPlayerDowned, "hide_timer", "hudplayerdowned_hide_timer_HMH", function(self, ...)
	local timer_msg = self._hud_panel:child("downed_panel"):child("timer_msg")
    if timer_msg then
	    timer_msg:set_alpha(HMH:GetOption("DownedAlpha"))
	end
	self._hud.timer:set_alpha(HMH:GetOption("DownedAlpha") / 2)
end)