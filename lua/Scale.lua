local Scale_option = HMH:GetOption("hud_scale") or 1

if not _G.IS_VR and Scale_option ~= 1 then
	Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_Scale_setup_player_info_hud_pd2", function(self)
		managers.gui_data:layout_scaled_fullscreen_workspace(self._saferect, Scale_option)
	end)
	
	function HUDManager:recreate_player_info_hud_pd2()
		if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then return end
		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
		local full_hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

		self:_create_present_panel(hud)
		self:_create_interaction(hud)
		self:_create_progress_timer(hud)
		self:_create_hint(hud)
		self:_create_heist_timer(hud)
		self:_create_temp_hud(hud)
		self:_create_suspicion(hud)
		self:_create_hit_confirm(hud)
		self:_create_hit_direction(hud)
		self:_create_downed_hud()
		self:_create_custody_hud()
		self:_create_hud_chat() --
		self._hud_assault_corner = HUDAssaultCorner:new(hud, full_hud, tweak_data.levels[Global.game_settings.level_id].hud or {})
		self:_create_waiting_legend(hud)
		local mask = self:script(Idstring("guis/mask_off_hud"))
		if mask then
			local mask_on_text = mask.mask_on_text
			if alive(mask_on_text) then
				mask_on_text:set_world_center_x(hud.panel:world_center_x())
			end
		end
	end

	Hooks:PostHook(HUDManager, "resolution_changed", "HMH_ResolutionChanged", function(self)
		if managers.hud and managers.hud.recreate_player_info_hud_pd2 then
			managers.gui_data:layout_scaled_fullscreen_workspace(self._saferect, Scale_option)
			managers.hud:recreate_player_info_hud_pd2()
		end
	end)

	core:module("CoreGuiDataManager")
	function GuiDataManager:layout_scaled_fullscreen_workspace(ws, scale)
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