local HMH = HMH

if RequiredScript == "lib/managers/hudmanagerpd2" then
	--VHUDPlus Compatibility
	if HMH:GetOption("assault") then
		Hooks:PostHook(HUDManager, "show_casing", "HMH_HUDManager_show_casing", function (self, ...)
			if self._hud_heist_timer._heist_timer_panel then
				self._hud_heist_timer._heist_timer_panel:set_visible(true)
			end
		end)
		Hooks:PostHook(HUDManager, "sync_start_assault", "HMH_HUDManager_sync_start_assault", function (self, ...)
			if self._hud_heist_timer._heist_timer_panel then
				self._hud_heist_timer._heist_timer_panel:set_visible(true)
			end
		end)
	end
	
elseif RequiredScript == "lib/units/beings/player/playerdamage" then
	local PlayerDamage_restore_health = PlayerDamage.restore_health
	function PlayerDamage:restore_health(health_restored, ...)
		if health_restored * self._healing_reduction == 0 then
			return
		end
		return PlayerDamage_restore_health(self, health_restored, ...)
	end
end