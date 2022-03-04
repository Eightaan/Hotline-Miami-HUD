if _G.IS_VR then 
    return 
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	local set_slot_ready_orig = HUDManager.set_slot_ready
	local update_original = HUDManager.update
	local force_ready_clicked = 0
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

    -- Force Start
	function HUDManager:set_slot_ready(peer, peer_id, ...)
		set_slot_ready_orig(self, peer, peer_id, ...)

		if not VHUDPlus and Network:is_server() and not Global.game_settings.single_player then
			local session = managers.network and managers.network:session()
			local local_peer = session and session:local_peer()
			if local_peer and local_peer:id() == peer_id then
				force_ready_clicked = force_ready_clicked + 1
				if game_state_machine and force_ready_clicked >= 3 then
					local menu_options = {
						[1] = {
							text = managers.localization:text("dialog_yes"),
							callback = function(self, item)
							    game_state_machine:current_state():start_game_intro()
						    end,
						},
						[2] = {
							text = managers.localization:text("dialog_no"),
							is_cancel_button = true,
						}
					}
					QuickMenu:new( managers.localization:text("hmh_dialog_force_start_title"), managers.localization:text("hmh_dialog_force_start_desc"), menu_options, true )
				end
			end
		end
	end
end