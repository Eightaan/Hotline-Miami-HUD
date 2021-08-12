Hooks:PostHook( HUDPlayerCustody , "init", "HMH_HUDTeammate_init", function(self, ...)
    local custody_panel = self._hud_panel:child("custody_panel")
    local timer_msg = custody_panel:child("timer_msg")
	local timer = custody_panel:child("timer")
	local civilians_killed = custody_panel:child("civilians_killed")
	local trade_delay = custody_panel:child("trade_delay")

	if HMH:GetOption("custody") then
        timer_msg:set_color(BeardLib and hotlinemiamihud and hotlinemiamihud.Options:GetValue("CustodyReleased") or Color("66ff99"))
	    timer:set_color(BeardLib and hotlinemiamihud and hotlinemiamihud.Options:GetValue("CustodyTimer") or Color("66ffff"))
	    timer:set_font(Idstring("fonts/font_medium"))
	    civilians_killed:set_color(BeardLib and hotlinemiamihud and hotlinemiamihud.Options:GetValue("Civillans") or Color("ff6666"))
	    trade_delay:set_color(BeardLib and hotlinemiamihud and hotlinemiamihud.Options:GetValue("Trade") or Color("ffcc66"))
	end
end)

Hooks:PostHook( HUDPlayerCustody , "set_negotiating_visible", "HMH_HUDTeammate_set_negotiating_visible", function(self, ...)
	self._hud.trade_text2:set_visible(false)
end)

Hooks:PostHook( HUDPlayerCustody , "set_can_be_trade_visible", "HMH_HUDTeammate_set_can_be_trade_visible", function(self, ...)
	self._hud.trade_text1:set_visible(false)
end)