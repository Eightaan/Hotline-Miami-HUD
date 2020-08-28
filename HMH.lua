if not HMH then
    _G.HMH =
    {
        _path = ModPath,
        _data_path = SavePath .. "HMH.json",
        SaveDataVer = 1,
        data = {}
    }

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

		if self:GetOption("suspicion") then
            DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealthmeter.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter_bg"), self._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealthmeter_bg.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/blackmarket/inv_detection_meter"), self._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/mission_briefing/inv_detection_meter"), self._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")
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
