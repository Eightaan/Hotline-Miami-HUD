if not HMH then
    _G.HMH =
    {
        _path = ModPath,
        _menu_path = ModPath .. "Menu/",
        _data_path = SavePath .. "HMH.json",
        SaveDataVer = 2,
        ModVersion = ModInstance and ModInstance:GetVersion() or "N/A",
        _data = {}
    }
	HMH.TotalKills = 0

    function HMH:Save()
        local file = io.open( self._data_path, "w+" )
        if file then
            self._data.SaveDataVer = self.SaveDataVer
            file:write( json.encode( self._data ) )
            file:close()
        end
    end

    function HMH:Load()
        self:LoadDefaults()
        local file = io.open( self._data_path, "r" )
        if file then
            local data = json.decode( file:read("*all") )
            file:close()
            if data.SaveDataVer and data.SaveDataVer == self.SaveDataVer then
                for k, v in pairs(data) do
                    if self._data[k] ~= nil then
                        self._data[k] = v
                    end
                end
            end
        end

		if self:GetOption("font") then
            DB:create_entry(Idstring("texture"), Idstring("fonts/font_medium"), self._path .. "assets/guis/textures/pd2_mod_hmh/font_medium.texture")
        end

		if self:GetOption("suspicion") then
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealthmeter.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter_bg"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealthmeter_bg.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/blackmarket/inv_detection_meter"), self._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/mission_briefing/inv_detection_meter"), self._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealth_exclam"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealth_exclam.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealth_eye"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealth_eye.texture")
        end

		if HMH:GetOption("interact_texture") == 2 then
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_progress_active.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_progress_invalid.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_progress_bg.texture")
		elseif HMH:GetOption("interact_texture") == 3 then
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), self._path .. "assets/guis/textures/pd2_mod_hmh/pink_progress_active.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), self._path .. "assets/guis/textures/pd2_mod_hmh/pink_progress_invalid.texture")
		elseif HMH:GetOption("interact_texture") == 4 then
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), self._path .. "assets/guis/textures/pd2_mod_hmh/hm2_progress_active.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), self._path .. "assets/guis/textures/pd2_mod_hmh/hm2_progress_invalid.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), self._path .. "assets/guis/textures/pd2_mod_hmh/hm2_progress_bg.texture")
		elseif HMH:GetOption("interact_texture") == 5 then
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_progress_active.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_progress_invalid.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_progress_bg.texture")
		end

        if HMH:GetOption("health_texture") == 2 then
		    DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_health"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_health.texture")
		elseif HMH:GetOption("health_texture") == 3 then
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_health"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_health.texture")
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_fearless"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_fearless.texture")	
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radial_rim"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_radial_rim.texture")
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radialbg"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_radialbg.texture")	
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_shield"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_shield.texture")
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_swansong"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_swansong.texture")	
            DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_health"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_absorb_health.texture")
            DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_shield"), self._path .. "assets/guis/textures/pd2_mod_hmh/heart_absorb_shield.texture")				
        end

		if self:GetOption("interact_icons") then
		    DB:create_entry(Idstring("texture"), Idstring("units/gui/c4_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/c4_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/camera_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/camera_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/crowbar_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/crowbar_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/cutter_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/cutter_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/drill_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/drill_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/ecm_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/ecm_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/file_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/file_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/glasscutter_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/glasscutter_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gps_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gps_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_brackets_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_brackets_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_color_use_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_color_use_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_driver_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_driver_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_passenger_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_passenger_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_repair_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_repair_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_trunk_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_trunk_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_generic_search_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/gui_generic_search_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/lockpick_ghost_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/lockpick_ghost_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/lockpick_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/lockpick_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/plank_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/plank_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/sawblade_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/sawblade_indicator_df.texture")
			DB:create_entry(Idstring("texture"), Idstring("units/gui/thermite_indicator_df"), self._path .. "assets/guis/textures/pd2_mod_hmh/thermite_indicator_df.texture")
		end

		if HMH:GetOption("custom_menu_background") == 2 then
		    DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_background_pattern"), self._path .. "assets/guis/textures/pd2_mod_hmh/classic_purple_bg.texture")
		end

        if self:GetOption("stop_ai") then
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/stophand_symbol"), self._path .. "assets/guis/textures/pd2_mod_hmh/stophand_symbol.texture")
		end
    end

    function HMH:LoadDefaults()
        local default_file = io.open(HMH._path .."Menu/default_values.json")
        self._data = json.decode(default_file:read("*all"))
        default_file:close()
    end

    function HMH:GetOption(id)
        return self._data[id]
    end

    function HMH:GetColor(id)
        local color = self._data[id]
        if color and color.r and color.b and color.g then
            return Color(255, color.r, color.g, color.b) / 255
        end
        return Color.white
    end

    HMH:Load()
end