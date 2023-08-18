if not _G.IS_VR and HMH:GetOption("hud_scale") ~= 1 then
    Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_Scale_setup_player_info_hud_pd2", function(self, ...)
        managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect, HMH:GetOption("hud_scale"))
    end)

    core:module("CoreGuiDataManager")
	Hooks:OverrideFunction(GuiDataManager, "layout_scaled_fullscreen_workspace", function(self, ws, scale)
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
    end)
end