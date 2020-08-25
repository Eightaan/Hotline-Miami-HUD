if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	local set_teammate_ammo_amount_orig = HUDManager.set_teammate_ammo_amount
	local set_slot_ready_orig = HUDManager.set_slot_ready
	local force_ready_clicked = 0

    -- Real Ammo
    function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max, ...)
	    if HMH:GetOption("trueammo") and not (VHUDPlus and VHUDPlus:getSetting({"CustomHUD", "USE_REAL_AMMO"}, true)) then
		    local total_left = current_left - current_clip
		    if total_left >= 0 then
			    current_left = total_left
			    max = max - current_clip
		    end
	    end
	    return set_teammate_ammo_amount_orig(self, id, selection_index, max_clip, current_clip, current_left, max, ...)
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
					game_state_machine:current_state():start_game_intro()
				end
			end
		end
	end
	
	-- Scale Hud
	Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_hudmamanger_setup_player_info_hud_pd2", function(self)
        managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect)
    end)

    function HUDManager:recreate_player_info_hud_pd2()
	    if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then return end
	        
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	    self:_create_present_panel(hud)
	    self:_create_interaction(hud)
	    self:_create_progress_timer(hud)
	    self:_create_objectives(hud)
	    self:_create_hint(hud)
	    self:_create_heist_timer(hud)
	    self:_create_temp_hud(hud)
	    self:_create_suspicion(hud)
	    self:_create_hit_confirm(hud)
	    self:_create_hit_direction(hud)
	    self:_create_downed_hud()
	    self:_create_custody_hud()
	    self:_create_waiting_legend(hud)
    end

    core:module("CoreGuiDataManager")
    function GuiDataManager:layout_scaled_fullscreen_workspace(ws)
	    local scale
	    if _G.VHUDPlus then
		    scale = _G.VHUDPlus:getSetting({"CustomHUD", "HUD_SCALE"}, 1)
	    else
		    scale = _G.HMH:GetOption("hud_scale")
	    end

	    local base_res = {x = 1280, y = 720}
	    local res = RenderSettings.resolution
	    local sc = (2 - scale)
	    local aspect_width = base_res.x / self:_aspect_ratio()
	    local h = math.round(sc * math.max(base_res.y, aspect_width))
	    local w = math.round(sc * math.max(base_res.x, aspect_width / h))
	    local safe_w = math.round(0.95 * res.x)
	    local safe_h = math.round(0.95 * res.y)   
	    local sh = math.min(safe_h, safe_w / (w / h))
	    local sw = math.min(safe_w, safe_h * (w / h))
	    local x = res.x / 2 - sh * (w / h) / 2
        local y = res.y / 2 - sw / (w / h) / 2
	    
		ws:set_screen(w, h, x, y, math.min(sw, sh * (w / h)))
    end	
end