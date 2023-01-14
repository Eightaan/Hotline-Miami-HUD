if _G.IS_VR then 
    return 
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	local update_original = HUDManager.update
	local show_casing_original = HUDManager.show_casing
	local sync_start_assault_original = HUDManager.sync_start_assault
    local show_heist_timer = VHUDPlus and VHUDPlus:getSetting({"AssaultBanner", "USE_CENTER_ASSAULT"}, true) and HMH:GetOption("assault")
	
	--VHUDPlus Compatibility
	if show_heist_timer then
		function HUDManager:show_casing(...)
		    show_casing_original(self, ...)
			self._hud_heist_timer._heist_timer_panel:set_visible(true)
		end

		function HUDManager:sync_start_assault(...)
		    sync_start_assault_original(self, ...)
			self._hud_heist_timer._heist_timer_panel:set_visible(true)
		end
	end

    --Ping Display
    function HUDManager:update(...)
	    for i, panel in ipairs(self._teammate_panels) do
		    panel:update(...)
	    end
	    return update_original(self, ...)
    end
end