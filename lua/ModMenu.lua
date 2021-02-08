local function DirectoryExists(path)
    if SystemFS and SystemFS.exists then
        return SystemFS:exists(path)
    elseif file and file.DirectoryExists then
        log("")	-- For some weird reason the function below always returns true if we don't log anything previously...
        return file.DirectoryExists(path)
    end
end

local function CreateDirectory(path)
    local current = ""
    path = Application:nice_path(path, true):gsub("\\", "/")

    for folder in string.gmatch(path, "([^/]*)/") do
        current = Application:nice_path(current .. folder, true)

        if not DirectoryExists(current) then
            if SystemFS and SystemFS.make_dir then
                SystemFS:make_dir(current)
            elseif file and file.CreateDirectory then
                file.CreateDirectory(current)
            end
        end
    end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_HMH", function( loc )
	local localization = HMH._path .. "loc/"
	local GetFiles = _G.file.GetFiles
	local Idstring = _G.Idstring
	local activelanguagekey = SystemInfo:language():key()
	for __, filename in ipairs(GetFiles(localization)) do
		if Idstring(filename:match("^(.*).json$") or ""):key() == activelanguagekey then
			loc:load_localization_file(localization .. filename)
		    break
		end
	end
	loc:load_localization_file(localization .. "english.json", false)

    local localized_strings = {}

	if HMH:GetOption("skip_blackscreen") then
	    localized_strings["hud_skip_blackscreen"] = ""
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
	MenuCallbackHandler.callback_colored_downs = function(self, item)
        HMH._data.colored_downs = item:value() == "on"
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
	MenuCallbackHandler.callback_color_condition = function(self, item)
        HMH._data.color_condition = item:value() == "on"
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
    MenuCallbackHandler.callback_mod_overrides = function(self, item)
        HMH._data.mod_overrides = item:value() == "on"
    end
    MenuCallbackHandler.callback_health_texture = function(self, item)
        HMH._data.health_texture = item:value() == "on"
    end
    MenuCallbackHandler.callback_interact_texture = function(self, item)
        HMH._data.interact_texture = item:value()
    end
    MenuCallbackHandler.callback_custom_subs = function(self, item)
        HMH._data.custom_subs = item:value() == "on"
    end
    MenuCallbackHandler.callback_custom_color = function(self, item)
        HMH._data.custom_color = item:value() == "on"
    end 
    MenuCallbackHandler.callback_custom_menu_color = function(self, item)
        HMH._data.custom_menu_color = item:value() == "on"
    end
    MenuCallbackHandler.callback_custom_chat = function(self, item)
        HMH._data.custom_chat = item:value() == "on"
    end
	MenuCallbackHandler.callback_screen_effect = function(self, item)
        HMH._data.screen_effect = item:value() == "on"
    end
	MenuCallbackHandler.callback_toggle_interact = function(self, item)
        HMH._data.toggle_interact = item:value()
    end
	MenuCallbackHandler.callback_interupt_interact = function(self, item)
        HMH._data.interupt_interact = item:value() == "on"
    end
	MenuCallbackHandler.callback_interupt_interact_hint = function(self, item)
        HMH._data.interupt_interact_hint = item:value() == "on"
    end
	MenuCallbackHandler.callback_skip_blackscreen = function(self, item)
        HMH._data.skip_blackscreen = item:value() == "on"
    end
	MenuCallbackHandler.callback_skip_xp = function(self, item)
        HMH._data.skip_xp = item:value()
    end
	MenuCallbackHandler.callback_pick_card = function(self, item)
        HMH._data.pick_card = item:value() == "on"
    end
	MenuCallbackHandler.callback_skip_card = function(self, item)
        HMH._data.skip_card = item:value()
    end
	MenuCallbackHandler.callback_suspicion = function(self, item)
        HMH._data.suspicion = item:value() == "on"
    end
	MenuCallbackHandler.callback_combo = function(self, item)
        HMH._data.combo = item:value() == "on"
    end
	MenuCallbackHandler.callback_font = function(self, item)
        HMH._data.font = item:value() == "on"
    end
	MenuCallbackHandler.callback_pager_jam = function(self, item)
        HMH._data.pager_jam = item:value() == "on"
    end
	MenuCallbackHandler.callback_interact_icons = function(self, item)
        HMH._data.interact_icons = item:value() == "on"
    end
	MenuCallbackHandler.callback_stealth_c4 = function(self, item)
        HMH._data.stealth_c4 = item:value() == "on"
    end
	MenuCallbackHandler.callback_tab = function(self, item)
        HMH._data.tab = item:value() == "on"
    end
	MenuCallbackHandler.callback_enemy_count = function(self, item)
        HMH._data.enemy_count = item:value() == "on"
    end
	MenuCallbackHandler.callback_custom_filter = function(self, item)
        HMH._data.custom_filter = item:value() == "on"
    end
	MenuCallbackHandler.callback_voice = function(self, item)
        HMH._data.voice = item:value() == "on"
    end
	MenuCallbackHandler.callback_ping = function(self, item)
        HMH._data.ping = item:value() == "on"
    end
	MenuCallbackHandler.callback_stamina = function(self, item)
        HMH._data.stamina = item:value() == "on"
    end
	MenuCallbackHandler.callback_custom_menu_background = function(self, item)
        HMH._data.custom_menu_background = item:value()
    end
	MenuCallbackHandler.callback_no_confirm = function(self, item)
        HMH._data.no_confirm = item:value() == "on"
    end
	MenuCallbackHandler.callback_crew_loadout_tab = function(self, item)
        HMH._data.crew_loadout_tab = item:value() == "on"
    end
	MenuCallbackHandler.callback_crew_loadout = function(self, item)
        HMH._data.crew_loadout = item:value() == "on"
    end
	MenuCallbackHandler.callback_crew_loadout_briefing = function(self, item)
        HMH._data.crew_loadout_briefing = item:value() == "on"
    end
	MenuCallbackHandler.callback_profile_menu = function(self, item)
        HMH._data.profile_menu = item:value() == "on"
    end
	MenuCallbackHandler.callback_carry_value = function(self, item)
        HMH._data.carry_value = item:value() == "on"
    end
	MenuCallbackHandler.callback_headshot_mark = function(self, item)
        HMH._data.headshot_mark = item:value() == "on"
    end
    MenuCallbackHandler.HMHSave = function(this, item)
        HMH:Save()
    end
	

	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/MainMenu.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/MenuOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/TeamHudOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/InteractionOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/AssaultOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/TabstatsOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/HintOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/WaypointOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/ChatOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/TimerOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/PresenterOptions.json", HMH, HMH._data )
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/SuspicionOptions.json", HMH, HMH._data )	
	MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/CarryOptions.json", HMH, HMH._data )
    MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/ObjectivesOptions.json", HMH, HMH._data )
    MenuHelper:LoadFromJsonFile( HMH._path .. "Menu/SubtitleOptions.json", HMH, HMH._data )

    do	-- Romove Disabled Updates, so they don't show up in the download manager.
        if not DirectoryExists("./assets/mod_overrides/") then
            CreateDirectory("./assets/mod_overrides/")
        end

        local id = "Hotline Miami Hud"
		local mod = BLT and BLT.Mods:GetMod(id)
        if mod then
		    for i, update in pairs(mod:GetUpdates()) do
			    if update:GetInstallFolder() ~= id then
				    local directory = Application:nice_path(update:GetInstallDirectory() .. "/" .. update:GetInstallFolder(), true)
                    if HMH:GetOption("mod_overrides") then
                        CreateDirectory(directory)
				    else
					    table.remove(mod:GetUpdates(), i)
				    end
			    end
		    end
		end
	end
end)

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