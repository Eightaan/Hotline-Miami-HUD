if file.DirectoryExists("assets/mod_overrides/Hotline Miami Menu") and (HMH:GetOption("preset") == 3 or not HMH:GetOption("no_menu_textures")) then
	SystemFS:delete_file("assets/mod_overrides/Hotline Miami Menu")
	Override = true
end