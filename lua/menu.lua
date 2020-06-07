function MenuCallbackHandler:get_latest_dlc_locked(...) return false end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_HMH", function( loc )
	loc:load_localization_file( HMH._path .. "loc/en.txt")
	local localized_strings = {}
    if LobbySettings then
        localized_strings["menu_cn_premium_buy_fee_short"] = ""
    end			
    loc:add_localized_strings(localized_strings)
end)

Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_HMH", function( menu_manager )

	MenuCallbackHandler.callback_infoboxes = function(self, item)
		HMH._data.infoboxes = item:value() == "on"
	end
	MenuCallbackHandler.callback_PLAYER_down = function(self, item)
		HMH._data.PLAYER_down = item:value() == "on"
	end
	MenuCallbackHandler.callback_TEAM_down = function(self, item)
		HMH._data.TEAM_down = item:value() == "on"
	end
	MenuCallbackHandler.callback_hud_scale = function(self, item)
        HMH._data.hud_scale = item:value()
    end
    MenuCallbackHandler.callback_inspire = function(self, item)
        HMH._data.inspire = item:value() == "on"
    end
    MenuCallbackHandler.callback_greenciv = function(self, item)
        HMH._data.greenciv = item:value() == "on"
    end
	MenuCallbackHandler.callback_waypoints = function(self, item)
        HMH._data.waypoints = item:value() == "on"
    end
	MenuCallbackHandler.callback_timer = function(self, item)
        HMH._data.timer = item:value() == "on"
    end
	MenuCallbackHandler.callback_presenter = function(self, item)
        HMH._data.presenter = item:value() == "on"
    end
	MenuCallbackHandler.callback_interact = function(self, item)
        HMH._data.interact = item:value() == "on"
    end
	MenuCallbackHandler.callback_hint = function(self, item)
        HMH._data.hint = item:value() == "on"
    end
	MenuCallbackHandler.callback_downed = function(self, item)
        HMH._data.downed = item:value() == "on"
    end
	MenuCallbackHandler.callback_custody = function(self, item)
        HMH._data.custody = item:value() == "on"
    end
	MenuCallbackHandler.callback_carry = function(self, item)
        HMH._data.carry = item:value() == "on"
    end
	MenuCallbackHandler.callback_ammo = function(self, item)
        HMH._data.ammo = item:value() == "on"
    end
	MenuCallbackHandler.callback_color_name = function(self, item)
        HMH._data.color_name = item:value() == "on"
    end
	MenuCallbackHandler.callback_interact_info = function(self, item)
        HMH._data.interact_info = item:value() == "on"
    end
	MenuCallbackHandler.callback_color_bag = function(self, item)
        HMH._data.color_bag = item:value() == "on"
    end
	MenuCallbackHandler.callback_pickups = function(self, item)
        HMH._data.pickups = item:value() == "on"
    end
	MenuCallbackHandler.callback_equipment = function(self, item)
        HMH._data.equipment = item:value() == "on"
    end
	MenuCallbackHandler.callback_trueammo = function(self, item)
        HMH._data.trueammo = item:value() == "on"
    end
	MenuCallbackHandler.callback_assault = function(self, item)
        HMH._data.assault = item:value() == "on"
    end
	MenuCallbackHandler.callback_objective = function(self, item)
        HMH._data.objective = item:value() == "on"
    end
	MenuCallbackHandler.callback_bulletstorm = function(self, item)
        HMH._data.bulletstorm = item:value() == "on"
    end

    MenuCallbackHandler.HMHSave = function(this, item)
        HMH:Save()
    end

	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/menu.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/hud.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/waypoints.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/timer.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/presenter.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/interact.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/hint.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/downed.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/carry.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/assault.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/objective.json", HMH, HMH._data )
end )

--LDDG Animations
function set_alpha( o, a, ct )
	local t = 0
	local target = ct or 0.5
	local ca = o:alpha()
	while t < target do
		t = t + coroutine.yield()
		local n = math.sin( t * 200 ) 
		o:set_alpha(math.lerp(ca, a, n))
	end
	o:set_alpha(a)
end