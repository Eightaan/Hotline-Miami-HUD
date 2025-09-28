local HMH = HMH

function HMH:LoadTextureEntry(key, path)
	DB:create_entry(Idstring("texture"), Idstring(key), path)
end

function HMH:LoadTextures()
	--Load Custom Font
	local custom_font = HMH:GetOption("font")
	local orig_font_path = HMH._path .. "fonts/font_medium.texture"
	local font_medium_path = custom_font and HMH._path .. "assets/pd2_mod_hmh/font_medium.texture"

	self:LoadTextureEntry(
		"fonts/font_medium", 
		font_medium_path or orig_font_path
	)

	--Load Fireselector
	local fireselector = HMH:GetOption("ammo")
	local orig_fireselector_path = HMH._path .. "guis/textures/pd2/hud_fireselector.texture"
	local fireselector_path = fireselector and HMH._path .. "assets/pd2_mod_hmh/hud_fireselector.texture"

	self:LoadTextureEntry(
		"guis/textures/pd2/hud_fireselector", 
		fireselector_path or orig_fireselector_path
	)

	--Load Custom Menu Background
	local custom_bg	= HMH:GetOption("custom_menu_background") == 2
	local orig_bg_path = HMH._path .. "units/menu/menu_scene/menu_background_pattern.texture"
	local custom_bg_path = custom_bg and HMH._path .. "assets/pd2_mod_hmh/classic_purple_bg.texture"

	self:LoadTextureEntry(
		"units/menu/menu_scene/menu_background_pattern", 
		custom_bg_path or orig_bg_path
    )

	--Load Pink Hud Corners
	local pink_corner = HMH:GetOption("pink_corner")
	local orig_corner_path = HMH._path .. "guis/textures/pd2/hud_corner.texture"
	local pink_corner_path = pink_corner and HMH._path .. "assets/pd2_mod_hmh/hud_corner.texture"

	self:LoadTextureEntry(
		"guis/textures/pd2/hud_corner", 
		pink_corner_path or orig_corner_path
    )

	--Load Pink Stop AI
	local stop_ai = HMH:GetOption("stop_ai")
	local orig_stop_ai_path = HMH._path .. "guis/textures/pd2/stophand_symbol.texture"
	local stop_ai_path = stop_ai and HMH._path .. "assets/pd2_mod_hmh/stophand_symbol.texture"

	self:LoadTextureEntry(
		"guis/textures/pd2/stophand_symbol", 
		stop_ai_path or orig_stop_ai_path
	)

	--Load Detection Meter
	local detection_meter = HMH:GetOption("suspicion")
	local orig_detection_meter_path = HMH._path .. "guis/textures/pd2/inv_detection_meter.texture"
	local detection_meter_path = detection_meter and HMH._path .. "assets/pd2_mod_hmh/inv_detection_meter.texture"
	local suspicion_meter_path = detection_meter and HMH._path .. "assets/pd2_mod_hmh/" or HMH._path .. "guis/textures/pd2/"

	for _, key in ipairs({"blackmarket/inv_detection_meter", "mission_briefing/inv_detection_meter"}) do
		self:LoadTextureEntry(
			"guis/textures/pd2/" .. key, 
			detection_meter_path or orig_detection_meter_path
		)
	end

	local suspicion_eye = {
		"hud_stealthmeter", 
		"hud_stealthmeter_bg", 
		"hud_stealth_exclam",
		"hud_stealth_eye",
	}

	for _, texture in ipairs(suspicion_eye) do
		self:LoadTextureEntry(
			"guis/textures/pd2/" .. texture, 
			suspicion_meter_path .. texture .. ".texture"
		)
	end

	-- Load Interaction Icons
	local interact_icons = HMH:GetOption("interact_icons")
	local interact_icons_path = interact_icons and HMH._path .. "assets/pd2_mod_hmh/" or HMH._path .. "units/gui/"
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

	for _, texture in ipairs(interact_textures) do
		self:LoadTextureEntry(
			"units/gui/" .. texture, 
			interact_icons_path .. texture .. ".texture"
		)
	end

	--Load Custom Health Circle
	local health_circle	= HMH:GetOption("health_texture")
	local health_circle_path = HMH._path .. "assets/pd2_mod_hmh/"
	if health_circle > 1 then
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
			local final_texture_name = health_circle == 3 and texture_name:gsub("hud_", "heart_") or texture_name
			self:LoadTextureEntry(
				"guis/textures/pd2/" .. texture_name, 
				health_circle_path .. final_texture_name .. ".texture"
			)
		end
	end

	-- Load Mouse Pointer
	local mouse_pointer = HMH:GetOption("mouse_pointer")
	local orig_mouse_pointer_path = HMH._path .. "guis/textures/mouse_pointer.texture"
	local mouse_pointer_path = HMH._path .. "assets/pd2_mod_hmh/"

	local mouse_pointer_paths = {
		[2] = "fingerless_gloves.texture",
		[3] = "jacket_pointer.texture",
		[4] = "pink_pointer.texture",
	}
	local mouse_pointer_name = mouse_pointer_paths[mouse_pointer] or "mouse_pointer.texture"
	local pointer_texture_path = mouse_pointer_path .. mouse_pointer_name

	self:LoadTextureEntry(
		"guis/textures/mouse_pointer",
		pointer_texture_path
	)

	--Load Menu Smoke
	local no_smoke = HMH:GetOption("no_smoke")
	local no_smoke_path	= no_smoke and HMH._path .. "assets/pd2_mod_hmh/" or HMH._path .. "units/menu/menu_scene/"
	local smoke_textures = {
		"menu_cylinder_smoke",
		"menu_cylinder_smoke_tile"
	}

	for _, texture in ipairs(smoke_textures) do
		self:LoadTextureEntry(
			"units/menu/menu_scene/" .. texture, 
			no_smoke_path .. texture .. ".texture"
		)
	end

	--Load Interaction Circle
	local interact_texture_option = HMH:GetOption("interact_texture")
	local interact_texture_path = HMH._path .. "assets/pd2_mod_hmh/"
	local orig_interact_texture_path = HMH._path .. "guis/textures/pd2/hud_progress_"
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

	if progress_texture_paths[interact_texture_option] then
		local selected_textures = progress_texture_paths[interact_texture_option]

		for key, texture in pairs(selected_textures) do
			DB:create_entry(
				Idstring("texture"), 
				Idstring("guis/textures/pd2/hud_progress_" .. key), 
				interact_texture_path .. texture
			)
		end
	else
		for _, key in pairs({"active", "invalid", "bg"}) do
			DB:create_entry(
				Idstring("texture"), 
				Idstring("guis/textures/pd2/hud_progress_" .. key), 
				orig_interact_texture_path .. key .. ".texture"
			)
		end
	end

	--Load Objective Sound
	local silent_obj = HMH:GetOption("silent_obj")
	local orig_silent_obj_path = HMH._path .. "soundbanks/streamed/hud/670238416.stream"
	local silent_obj_path = silent_obj and HMH._path .. "assets/pd2_mod_hmh/objective.stream"
	DB:create_entry(
		Idstring("stream"), 
		Idstring("soundbanks/streamed/hud/670238416"), 
		silent_obj_path or orig_silent_obj_path
	)
end
HMH:LoadTextures()