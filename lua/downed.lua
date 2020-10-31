Hooks:PostHook(HUDPlayerDowned, "init", "hudplayerdowned_HMH", function(self, ...)
	local downed_panel = self._hud_panel:child("downed_panel")
	local timer_msg = downed_panel:child("timer_msg")

	if HMH:GetOption("downed") then
        timer_msg:set_color(Color("ff80df"))
        self._hud.timer:set_color(Color("66ffff"))
	    self._hud.timer:set_font(Idstring("fonts/font_medium"))
	end
end)