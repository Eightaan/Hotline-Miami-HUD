Hooks:PostHook(HUDPlayerCustody , "init", "HMH_HUDPlayerCustody_init", function(self, ...)
	if not HMH:GetOption("custody") then
		return
	end

	local custody_panel = self._hud_panel:child("custody_panel")
	local timer_msg = custody_panel:child("timer_msg")
	local timer = custody_panel:child("timer")
	local civilians_killed = custody_panel:child("civilians_killed")
	local trade_delay = custody_panel:child("trade_delay")

	custody_panel:set_alpha(HMH:GetOption("CustodyAlpha"))
	timer_msg:set_color(HMH:GetColor("CustodyReleased"))
	timer:set_color(HMH:GetColor("CustodyTimer"))
	timer:set_font(Idstring("fonts/font_medium"))
	civilians_killed:set_color(HMH:GetColor("Civilans_color"))
	trade_delay:set_color(HMH:GetColor("Trade"))
end)

Hooks:PostHook(HUDPlayerCustody , "set_negotiating_visible", "HMH_HUDPlayerCustody_set_negotiating_visible", function(self, ...)
	self._hud.trade_text2:set_visible(false)
end)

Hooks:PostHook(HUDPlayerCustody , "set_can_be_trade_visible", "HMH_HUDPlayerCustody_set_can_be_trade_visible", function(self, ...)
	self._hud.trade_text1:set_visible(false)
end)