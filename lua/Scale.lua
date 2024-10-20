local Scale_option = HMH:GetOption("hud_scale") or 1

if not _G.IS_VR and Scale_option ~= 1 then
	local math_round = math.round
	local math_max = math.max
	local math_min = math.min
	
	Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_Scale_setup_player_info_hud_pd2", function(self)
		managers.gui_data:layout_scaled_fullscreen_workspace(self._saferect, Scale_option)
	end)

	Hooks:PostHook(HUDManager, "resolution_changed", "HMH_ResolutionChanged", function(self)
		managers.gui_data:layout_scaled_fullscreen_workspace(self._saferect, Scale_option)
	end)

	core:module("CoreGuiDataManager")
	function GuiDataManager:layout_scaled_fullscreen_workspace(ws, scale)
		local base_res = {x = 1280, y = 720}
		local res = RenderSettings.resolution
		local scale = scale or 1
		local sc = (2 - scale)
		local aspect_width = base_res.x / self:_aspect_ratio()
		local h = math_round(sc * math_max(base_res.y, aspect_width))
		local w = math_round(sc * math_max(base_res.x, aspect_width / h))
		local safe_w = math_round(0.95 * res.x)
		local safe_h = math_round(0.95 * res.y)   
		local sh = math_min(safe_h, safe_w / (w / h))
		local sw = math_min(safe_w, safe_h * (w / h))
		local x = res.x / 2 - sh * (w / h) / 2
		local y = res.y / 2 - sw / (w / h) / 2
		ws:set_screen(w, h, x, y, math_min(sw, sh * (w / h)))
	end
end