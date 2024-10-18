function HMH:LoadTextureEntry(key, path)
	DB:create_entry(Idstring("texture"), Idstring(key), path)
end

function HMH:LoadTextures()
	local preset = HMH:GetOption("preset")
	local preset_1_2 = preset ~= 3
	local preset_2 = preset == 2
	local preset_1 = preset == 1

	local font_medium_path = (preset_1 and HMH:GetOption("font")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/font_medium.texture") or (HMH._path .. "fonts/font_medium.texture")
	self:LoadTextureEntry("fonts/font_medium", font_medium_path)

	local detection_meter_path = (preset_1_2 and HMH:GetOption("suspicion")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture") or (preset_2 and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")) or (HMH._path .. "guis/textures/pd2/inv_detection_meter.texture")
	for _, key in ipairs({"blackmarket/inv_detection_meter", "mission_briefing/inv_detection_meter"}) do
		self:LoadTextureEntry("guis/textures/pd2/" .. key, detection_meter_path)
	end

	local fireselector_path = (preset_1_2 and HMH:GetOption("ammo")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_fireselector.texture") or (preset_2 and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_fireselector.texture")) or (HMH._path .. "guis/textures/pd2/hud_fireselector.texture")
	self:LoadTextureEntry("guis/textures/pd2/hud_fireselector", fireselector_path)

	local interact_textures = {
		"c4_indicator_df", "camera_indicator_df", "crowbar_indicator_df",
		"cutter_indicator_df", "drill_indicator_df", "ecm_indicator_df",
		"file_indicator_df", "glasscutter_indicator_df", "gps_indicator_df",
		"gui_brackets_df", "gui_color_use_df", "gui_drive_driver_df",
		"gui_drive_passenger_df", "gui_drive_repair_df", "gui_drive_trunk_df",
		"gui_generic_search_df", "lockpick_ghost_indicator_df", 
		"lockpick_indicator_df", "plank_indicator_df", "sawblade_indicator_df",
		"thermite_indicator_df", "scissors_indicator_df", "turret_indicator_df",
	}

	local interact_base_path = (preset_1_2 and (HMH:GetOption("interact_icons") or preset_2)) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/") or (HMH._path .. "units/gui/")
	for _, texture in ipairs(interact_textures) do
		self:LoadTextureEntry("units/gui/" .. texture, interact_base_path .. texture .. ".texture")
	end

	local suspicion_eye = {
		"hud_stealthmeter", "hud_stealthmeter_bg", "hud_stealth_exclam",
		"hud_stealth_eye",
	}

	local suspicion_base_path = (preset_1_2 and (HMH:GetOption("suspicion") or preset_2)) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/") or (HMH._path .. "guis/textures/pd2/")
	for _, texture in ipairs(suspicion_eye) do
		self:LoadTextureEntry("guis/textures/pd2/" .. texture, suspicion_base_path .. texture .. ".texture")
	end

	local health_texture_option = HMH:GetOption("health_texture")
	local health_base_path

	if preset_1_2 and (health_texture_option == 2 or preset_2) then
		health_base_path = HMH._path .. "assets/guis/textures/pd2_mod_hmh/"
	elseif preset_1_2 and health_texture_option == 3 then
		health_base_path = HMH._path .. "assets/guis/textures/pd2_mod_hmh/"
	else
		health_base_path = HMH._path .. "guis/textures/pd2/"
	end

	local health_textures = {
		{"hud_health", "hud_health"},
		{"hud_fearless", "hud_fearless"},
		{"hud_radial_rim", "hud_radial_rim"},
		{"hud_radialbg", "hud_radialbg"},
		{"hud_shield", "hud_shield"},
		{"hud_swansong", "hud_swansong"},
		{"hud_absorb_health", "hud_absorb_health"},
		{"hud_absorb_shield", "hud_absorb_shield"},
	}

	for _, texture in ipairs(health_textures) do
		local texture_name = texture[1]
		local final_texture_name = (health_texture_option == 3) and texture_name:gsub("hud_", "heart_") or texture_name
		self:LoadTextureEntry("guis/textures/pd2/" .. texture_name, health_base_path .. final_texture_name .. ".texture")
	end

	local mouse_pointer_option = HMH:GetOption("mouse_pointer")
	local mouse_pointer_paths = {
		[2] = "fingerless_gloves.texture",
		[3] = "jacket_pointer.texture",
		[4] = "pink_pointer.texture",
	}

	local mouse_pointer_name = (preset_1_2 and mouse_pointer_paths[mouse_pointer_option]) or "mouse_pointer.texture"
	self:LoadTextureEntry("guis/textures/mouse_pointer", (preset_1_2 and HMH._path .. "assets/guis/textures/pd2_mod_hmh/" .. mouse_pointer_name) or (HMH._path .. "guis/textures/mouse_pointer.texture"))

	local custom_bg_path = (preset_1 and HMH:GetOption("custom_menu_background") == 2) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/classic_purple_bg.texture") or (HMH._path .. "units/menu/menu_scene/menu_background_pattern.texture")
	self:LoadTextureEntry("units/menu/menu_scene/menu_background_pattern", custom_bg_path)

	local pink_corner_path = (preset_1_2 and HMH:GetOption("pink_corner")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_corner.texture") or (preset_2 and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_corner.texture")) or (HMH._path .. "guis/textures/pd2/hud_corner.texture")
	self:LoadTextureEntry("guis/textures/pd2/hud_corner", pink_corner_path)

	local stop_ai_path = (preset_1_2 and HMH:GetOption("stop_ai")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/stophand_symbol.texture") or (preset_2 and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/stophand_symbol.texture")) or (HMH._path .. "guis/textures/pd2/stophand_symbol.texture")
	self:LoadTextureEntry("guis/textures/pd2/stophand_symbol", stop_ai_path)

	local silent_obj_path = (preset_1 and HMH:GetOption("silent_obj")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/objective.stream") or (HMH._path .. "soundbanks/streamed/hud/670238416.stream")
	DB:create_entry(Idstring("stream"), Idstring("soundbanks/streamed/hud/670238416"), silent_obj_path)

	local smoke_textures = {
		"menu_cylinder_smoke",
		"menu_cylinder_smoke_tile"
	}
	local base_path = (preset_1 and HMH:GetOption("no_smoke")) and (HMH._path .. "assets/guis/textures/pd2_mod_hmh/") or (HMH._path .. "units/menu/menu_scene/")
	
	for _, texture in ipairs(smoke_textures) do
		self:LoadTextureEntry("units/menu/menu_scene/" .. texture, base_path .. texture .. ".texture")
	end

	local interact_texture_option = HMH:GetOption("interact_texture")
	local progress_texture_paths = {
		[2] = {
			active = "pink_progress_active.texture",
			invalid = "pink_progress_invalid.texture",
			bg = "pink_progress_bg.texture"
		},
		[3] = {
			active = "triangle_bg.texture",
			invalid = "triangle_bg.texture",
			bg = "triangle_bg.texture"
		},
		[4] = {
			active = "hud_health.texture",
			invalid = "faded_invalid.texture",
			bg = "faded_bg.texture"
		},
		[5] = {
			active = "triangle.texture",
			invalid = "triangle_invalid.texture",
			bg = "triangle_bg.texture"
		},
		[6] = {
			active = "hm2_progress_active.texture",
			invalid = "hm2_progress_invalid.texture",
			bg = "hm2_progress_bg.texture"
		},
		[7] = {
			active = "heart_progress_active.texture",
			invalid = "heart_progress_invalid.texture",
			bg = "heart_progress_bg.texture"
		},
		[8] = {
			active = "hud_progress_active.texture",
			invalid = "hud_progress_invalid.texture",
			bg = "hud_progress_bg.texture"
		},
	}

	if preset_1_2 then
		if progress_texture_paths[interact_texture_option] then
			local selected_textures = progress_texture_paths[interact_texture_option]

			for key, texture in pairs(selected_textures) do
				DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_" .. key), HMH._path .. "assets/guis/textures/pd2_mod_hmh/" .. texture)
			end
		else
			for _, key in pairs({"active", "invalid", "bg"}) do
				DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_" .. key), HMH._path .. "guis/textures/pd2/hud_progress_" .. key .. ".texture")
			end
		end
	elseif preset_2 then
		for _, key in pairs({"active", "invalid", "bg"}) do
			DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_" .. key), HMH._path .. "guis/textures/pd2/hud_progress_" .. key .. ".texture")
		end
	end
end
HMH:LoadTextures()