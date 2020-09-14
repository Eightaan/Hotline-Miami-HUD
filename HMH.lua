if not HMH then
    _G.HMH =
    {
        _path = ModPath,
        _data_path = SavePath .. "HMH.json",
        SaveDataVer = 1,
        data = {}
    }
	
	HMH.Kills = 0
	HMH.LastKillTime = 0
	HMH.KillTime = 0
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
    end

    function HMH:LoadDefaults()
        local default_file = io.open(HMH._path .."Menu/default_values.json")
        self._data = json.decode(default_file:read("*all"))
        default_file:close()
    end

    function HMH:GetOption(id)
        return self._data[id]
    end

    HMH:Load()
end
