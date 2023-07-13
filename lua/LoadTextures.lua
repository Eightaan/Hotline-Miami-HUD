function HMH:LoadTextures()
	local preset_1_2 = HMH:GetOption("preset") ~= 3
	local preset_2 = HMH:GetOption("preset") == 2
	local preset_1 = HMH:GetOption("preset") == 1
	if preset_1 and HMH:GetOption("font") then
		DB:create_entry(Idstring("texture"), Idstring("fonts/font_medium"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/font_medium.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("fonts/font_medium"), HMH._path .. "fonts/font_medium.texture")
	end

	if preset_1_2 and HMH:GetOption("suspicion") or preset_2 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealthmeter.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter_bg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealthmeter_bg.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/blackmarket/inv_detection_meter"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/mission_briefing/inv_detection_meter"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/inv_detection_meter.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealth_exclam"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealth_exclam.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealth_eye"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_stealth_eye.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter"), HMH._path .. "guis/textures/pd2/hud_stealthmeter.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealthmeter_bg"), HMH._path .. "guis/textures/pd2/hud_stealthmeter_bg.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/blackmarket/inv_detection_meter"), HMH._path .. "guis/textures/pd2/blackmarket/inv_detection_meter.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/mission_briefing/inv_detection_meter"), HMH._path .. "guis/textures/pd2/mission_briefing/inv_detection_meter.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealth_exclam"), HMH._path .. "guis/textures/pd2/hud_stealth_exclam.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_stealth_eye"), HMH._path .. "guis/textures/pd2/hud_stealth_eye.texture")
	end

	if preset_1_2 and HMH:GetOption("ammo") or preset_2 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_fireselector"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_fireselector.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_fireselector"), HMH._path .. "guis/textures/pd2/hud_fireselector.texture")
	end

	if preset_1_2 and HMH:GetOption("interact_texture") == 2 or preset_2 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_progress_active.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_progress_invalid.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_progress_bg.texture")
	elseif preset_1_2 and HMH:GetOption("interact_texture") == 3 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/pink_progress_active.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/pink_progress_invalid.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/pink_progress_bg.texture")
	elseif preset_1_2 and HMH:GetOption("interact_texture") == 4 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hm2_progress_active.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hm2_progress_invalid.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hm2_progress_bg.texture")
	elseif preset_1_2 and HMH:GetOption("interact_texture") == 5 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_progress_active.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_progress_invalid.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_progress_bg.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_active"), HMH._path .. "guis/textures/pd2/hud_progress_active.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_invalid"), HMH._path .. "guis/textures/pd2/hud_progress_invalid.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_progress_bg"), HMH._path .. "guis/textures/pd2/hud_progress_bg.texture")
	end

	if preset_1_2 and HMH:GetOption("health_texture") == 2 or preset_2 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_health"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_health.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_fearless"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_fearless.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radial_rim"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_radial_rim.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radialbg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_radialbg.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_shield"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_shield.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_swansong"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_swansong.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_health"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_absorb_health.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_shield"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_absorb_shield.texture")
	elseif preset_1_2 and HMH:GetOption("health_texture") == 3 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_health"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_health.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_fearless"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_fearless.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radial_rim"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_radial_rim.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radialbg"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_radialbg.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_shield"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_shield.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_swansong"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_swansong.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_health"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_absorb_health.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_shield"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/heart_absorb_shield.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_health"), HMH._path .. "guis/textures/pd2/hud_health.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_fearless"), HMH._path .. "guis/textures/pd2/hud_fearless.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radial_rim"), HMH._path .. "guis/textures/pd2/hud_radial_rim.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_radialbg"), HMH._path .. "guis/textures/pd2/hud_radialbg.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_shield"), HMH._path .. "guis/textures/pd2/hud_shield.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_swansong"), HMH._path .. "guis/textures/pd2/hud_swansong.texture")	
		DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_health"), HMH._path .. "guis/dlcs/coco/textures/pd2/hud_absorb_health.texture")
		DB:create_entry(Idstring("texture"), Idstring("guis/dlcs/coco/textures/pd2/hud_absorb_shield"), HMH._path .. "guis/dlcs/coco/textures/pd2/hud_absorb_shield.texture")
	end

	if preset_1_2 and HMH:GetOption("interact_icons") or preset_2 then
	    DB:create_entry(Idstring("texture"), Idstring("units/gui/c4_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/c4_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/camera_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/camera_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/crowbar_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/crowbar_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/cutter_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/cutter_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/drill_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/drill_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/ecm_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/ecm_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/file_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/file_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/glasscutter_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/glasscutter_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gps_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gps_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_brackets_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_brackets_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_color_use_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_color_use_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_driver_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_driver_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_passenger_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_passenger_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_repair_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_repair_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_trunk_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_drive_trunk_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_generic_search_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/gui_generic_search_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/lockpick_ghost_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/lockpick_ghost_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/lockpick_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/lockpick_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/plank_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/plank_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/sawblade_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/sawblade_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/thermite_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/thermite_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/scissors_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/scissors_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/turret_indicator_df"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/turret_indicator_df.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("units/gui/c4_indicator_df"), HMH._path .. "units/gui/c4_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/camera_indicator_df"), HMH._path .. "units/gui/camera_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/crowbar_indicator_df"), HMH._path .. "units/gui/crowbar_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/cutter_indicator_df"), HMH._path .. "units/gui/cutter_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/drill_indicator_df"), HMH._path .. "units/gui/drill_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/ecm_indicator_df"), HMH._path .. "units/gui/ecm_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/file_indicator_df"), HMH._path .. "units/gui/file_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/glasscutter_indicator_df"), HMH._path .. "units/gui/glasscutter_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gps_indicator_df"), HMH._path .. "units/gui/gps_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_brackets_df"), HMH._path .. "units/gui/gui_brackets_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_color_use_df"), HMH._path .. "units/gui/gui_color_use_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_driver_df"), HMH._path .. "units/gui/gui_drive_driver_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_passenger_df"), HMH._path .. "units/gui/gui_drive_passenger_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_repair_df"), HMH._path .. "units/gui/gui_drive_repair_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_drive_trunk_df"), HMH._path .. "units/gui/gui_drive_trunk_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/gui_generic_search_df"), HMH._path .. "units/gui/gui_generic_search_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/lockpick_ghost_indicator_df"), HMH._path .. "units/gui/lockpick_ghost_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/lockpick_indicator_df"), HMH._path .. "units/gui/lockpick_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/plank_indicator_df"), HMH._path .. "units/gui/plank_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/sawblade_indicator_df"), HMH._path .. "units/gui/sawblade_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/thermite_indicator_df"), HMH._path .. "units/gui/thermite_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/scissors_indicator_df"), HMH._path .. "units/gui/scissors_indicator_df.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/gui/turret_indicator_df"), HMH._path .. "units/gui/turret_indicator_df.texture")
	end

	if preset_1 and HMH:GetOption("custom_menu_background") == 2 then
	    DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_background_pattern"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/classic_purple_bg.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_background_pattern"), HMH._path .. "units/menu/menu_scene/menu_background_pattern.texture")
	end

	if preset_1_2 and HMH:GetOption("stop_ai") or preset_2 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/stophand_symbol"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/stophand_symbol.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/stophand_symbol"), HMH._path .. "guis/textures/pd2/stophand_symbol.texture")
	end
		
	if preset_1_2 and HMH:GetOption("pink_corner") or preset_2 then
	    DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_corner"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/hud_corner.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/pd2/hud_corner"), HMH._path .. "guis/textures/pd2/hud_corner.texture")
	end
		
	if preset_1 and HMH:GetOption("silent_obj") then
	    DB:create_entry(Idstring("stream"), Idstring("soundbanks/streamed/hud/670238416"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/objective.stream")
	else
		DB:create_entry(Idstring("stream"), Idstring("soundbanks/streamed/hud/670238416"), HMH._path .. "soundbanks/streamed/hud/670238416.stream")
	end
	
	if preset_1 and HMH:GetOption("no_smoke") then
	    DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_cylinder_smoke"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/menu_cylinder_smoke.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_cylinder_smoke_tile"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/menu_cylinder_smoke_tile.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_cylinder_smoke"), HMH._path .. "units/menu/menu_scene/menu_cylinder_smoke.texture")
		DB:create_entry(Idstring("texture"), Idstring("units/menu/menu_scene/menu_cylinder_smoke_tile"), HMH._path .. "units/menu/menu_scene/menu_cylinder_smoke_tile.texture")
	end
	
	if preset_1_2 and HMH:GetOption("mouse_pointer") == 2 or preset_2 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/mouse_pointer"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/fingerless_gloves.texture")
	elseif preset_1_2 and HMH:GetOption("mouse_pointer") == 3 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/mouse_pointer"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/jacket_pointer.texture")
	elseif preset_1_2 and HMH:GetOption("mouse_pointer") == 4 then
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/mouse_pointer"), HMH._path .. "assets/guis/textures/pd2_mod_hmh/pink_pointer.texture")
	else
		DB:create_entry(Idstring("texture"), Idstring("guis/textures/mouse_pointer"), HMH._path .. "guis/textures/mouse_pointer.texture")
	end
end

HMH:LoadTextures()