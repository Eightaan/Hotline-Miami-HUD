if not HMH then
	_G.HMH =
	{
		_path = ModPath,
		_menu_path = ModPath .. "Menu/",
		_data_path = SavePath .. "HMH.json",
		SaveDataVer = 2,
		ModVersion = ModInstance and ModInstance:GetVersion() or "N/A",
		TotalKills = 0,
		CivKill = 0,
		_in_heist = false,
		_data = {}
	}

	local Menu_File = file
	function HMH:Save()
		local file = io.open( self._data_path, "w+" )
		if file then
			self._data.SaveDataVer = self.SaveDataVer
			file:write( json.encode( self._data ) )
			file:close()
		end
		
		if Menu_File.DirectoryExists("assets/mod_overrides/Hotline Miami Menu") and (self:GetOption("preset") == 3 or not self:GetOption("no_menu_textures")) then
			SystemFS:delete_file("assets/mod_overrides/Hotline Miami Menu")
		end
		self:LoadTextures()
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
		if self:GetOption("preset") ~= 1 then
			self:LoadDefaults()
		end
	end

	function HMH:LoadDefaults()
		local values = self:GetOption("preset") == 3 and "Menu/default_values_vanilla.json" or "Menu/default_values.json"
		local default_file = io.open(self._path ..values)
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