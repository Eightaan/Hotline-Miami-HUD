local HMH = HMH
local Menu_File = file
local math_lerp = math.lerp
local math_sin = math.sin

local function CreateDirectory(path)
	local current = ""
	path = Application:nice_path(path, true):gsub("\\", "/")

	for folder in string.gmatch(path, "([^/]*)/") do
		current = Application:nice_path(current .. folder, true)

		if not Menu_File.DirectoryExists(current) then
			if SystemFS and SystemFS.make_dir then
				SystemFS:make_dir(current)
			elseif file and file.CreateDirectory then
				file.CreateDirectory(current)
			end
		end
	end
end

local function loadLocalizationFiles(loc, localization, activelanguagekey)
	local files = _G.file.GetFiles(localization)
	for _, filename in ipairs(files) do
		local langKey = Idstring(filename:match("^(.*).json$") or ""):key()
		if langKey == activelanguagekey then
			loc:load_localization_file(localization .. filename)
			return true
		end
	end
	loc:load_localization_file(localization .. "english.json", false)
	return false
end

local function mod_overrides_check(mod)
	local id = "Hotline Miami Hud"
	for i = #mod:GetUpdates(), 1, -1 do
		local update = mod:GetUpdates()[i]
		if update:GetInstallFolder() ~= id then
			local directory = Application:nice_path(update:GetInstallDirectory() .. "/" .. update:GetInstallFolder(), true)
			if HMH:GetOption("mod_overrides") and HMH:GetOption("no_menu_textures") then
				CreateDirectory(directory)
			else
				table.remove(mod:GetUpdates(), i)
			end
		end
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_HMH", function(loc)
	local localization = HMH._path .. "loc/"
	local activelanguagekey = SystemInfo:language():key()
	
	loadLocalizationFiles(loc, localization, activelanguagekey)

	local localized_strings = {}
	if HMH:GetOption("skip_blackscreen") then
		localized_strings["hud_skip_blackscreen"] = ""
	end
	if HMH:GetOption("suspicion") then
		localized_strings["hud_suspicion_detected"] = ""
	end
	localized_strings["hud_instruct_mask_on"] = ""

	loc:add_localized_strings(localized_strings)
end)

Hooks:Add("MenuManagerBuildCustomMenus", "MenuManagerBuildCustomMenus_HMH", function(menu_manager, nodes)
	MenuCallbackHandler.OpenHMHModOptions = function(self, item)
		HMH.Menu = HMH.Menu or HMHMenu:new()
		HMH.Menu:Open()

		Hooks:PostHook(MenuManager, "update", "update_menu_HMH", function(self, t, dt)
			if HMH.Menu and HMH.Menu.update and HMH.Menu._enabled then
				HMH.Menu:update(t, dt)
			end
		end)
	end

	local node = nodes["blt_options"]

	local item_params = {
		name = "HMH_OpenMenu",
		text_id = "hmh_title",
		help_id = "hmh_desc",
		callback = "OpenHMHModOptions",
		localize = true,
	}
	local item = node:create_item({type = "CoreMenuItem.Item"}, item_params)
	node:add_item(item)
end)

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_HMH", function(menu_manager)
	if not Menu_File.DirectoryExists("./assets/mod_overrides/") then
		CreateDirectory("./assets/mod_overrides/")
	end

	local id = "Hotline Miami Hud"
	local mod = BLT and BLT.Mods:GetMod(id)
	if mod then
		mod_overrides_check(mod)
	end
end)

function set_alpha(o, a, ct)
	local t = 0
	local target = ct or 0.5
	local ca = o:alpha()
	while t < target do
		t = t + coroutine.yield()
		local n = math_sin(t * 200)
		o:set_alpha(math_lerp(ca, a, n))
	end
	o:set_alpha(a)
end
