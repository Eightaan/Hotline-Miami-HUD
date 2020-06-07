if not HMH then
    _G.HMH =
    {
        _path = ModPath,
        _data_path = SavePath .. "HMHv2.json",
        data = {}
    }

    function HMH:Save()
        local file = io.open( self._data_path, "w+" )
        if file then
            file:write( json.encode( self._data ) )
            file:close()
        end
    end

    function HMH:Load()
        self:LoadDefaults()
        local file = io.open( self._data_path, "r" )
        if file then
            self._data = json.decode( file:read("*all") )
            file:close()
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