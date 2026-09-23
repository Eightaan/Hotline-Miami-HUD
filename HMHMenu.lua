--[[
	Original code by Dom

	Copy of BLT's MenuHelper with BTP specific changes witch HMH changes
	Loads a json-formatted text file and automatically parses and converts into a usable menu
	@param content table Path of the file to load and convert into a menu
	@param data_table table? Table containing the data keys which various menu items can load their value from
]]

local function check_value(compare, value, type)
    if type == "toggle" then
        value = value == "on"
    end
    local result = true
    local comparator = compare.comparator or "=="
    local value_to_compare = compare.value
    if comparator == "==" then
        result = value == value_to_compare
    elseif comparator == "<" then
        result = value < value_to_compare
    elseif comparator == "<=" then
        result = value <= value_to_compare
    elseif comparator == ">" then
        result = value > value_to_compare
    elseif comparator == ">=" then
        result = value >= value_to_compare
    elseif comparator == "<>" then
        result = value ~= value_to_compare
    end
    return result
end

local function CreateMenuFromJson(content, data_table)
    local menu_id = content.menu_id
    local parent_menu = content.parent_menu_id
    local items = content.items
    local menu_priority = content.priority or nil

    -- 1.
    Hooks:Add("MenuManagerSetupCustomMenus", "HMH_Base_SetupCustomMenus_Json_" .. menu_id, function(menu_manager, nodes)
        MenuHelper:NewMenu(menu_id)
    end)
	
    -- 3.
    Hooks:Add("MenuManagerBuildCustomMenus","HMH_Base_BuildCustomMenus_Json_" .. menu_id, function(menu_manager, nodes)
        local data = {
            focus_changed_callback = content.focus_changed_callback,
            back_callback = content.back_callback,
            area_bg = content.area_bg
        }
        nodes[menu_id] = MenuHelper:BuildMenu(menu_id, data)

        if menu_priority ~= nil then
            for k, v in pairs(nodes[parent_menu]._items) do
                if menu_priority > (v._priority or 0) then
                    menu_priority = k
                    break
                end
            end
        end

        if menu_id == "hmh_menu" then
            MenuHelper:AddMenuItem(nodes[parent_menu], menu_id, content.title, content.description, menu_priority)
        end
    end)

    -- 2.
    Hooks:Add("MenuManagerPopulateCustomMenus","HMH_Base_PopulateCustomMenus_Json_" .. menu_id, function(menu_manager, nodes)
        local all_items = #items
        local previous_items = {} ---@type table<string, CoreMenuItemToggle.ItemToggle, CoreMenuItemSlider.ItemSlider, MenuItemMultiChoice>
        for k, item in ipairs(items) do
            local menu_item
            local i_type = item.type
            local id = item.id
            local title = item.title
            local desc = item.description
            local callback = item.callback
            local priority = item.priority or all_items - k
            local value = item.default_value
            local localized = item.localized
            local disabled = item.disabled
            if data_table and data_table[item.value] ~= nil then
                value = data_table[item.value]
            end
            if item.disabled_from_start and MenuCallbackHandler then
                disabled = not _G.callback(MenuCallbackHandler, MenuCallbackHandler, item.disabled_from_start)()
            end
            if i_type == "button" then
                menu_item = MenuHelper:AddButton({
                    id = id,
                    title = title,
                    desc = desc,
                    callback = callback,
                    next_node = item.next_menu or nil,
                    menu_id = menu_id,
                    priority = priority,
                    localized = localized,
                    disabled = disabled
                })
            elseif i_type == "toggle" then
                menu_item = MenuHelper:AddToggle({
                    id = id,
                    title = title,
                    desc = desc,
                    callback = callback,
                    value = value,
                    menu_id = menu_id,
                    priority = priority,
                    localized = localized,
                    disabled = disabled
                })
            elseif i_type == "slider" then
                menu_item = MenuHelper:AddSlider({
                    id = id,
                    title = title,
                    desc = desc,
                    callback = callback,
                    value = value,
                    min = item.min or 0,
                    max = item.max or 1,
                    step = item.step or 0.1,
                    show_value = true,
                    display_precision = item.display_precision,
                    display_scale = item.display_scale,
                    is_percentage = item.is_percentage,
                    menu_id = menu_id,
                    priority = priority,
                    localized = localized,
                    disabled = disabled
                })
            elseif i_type == "divider" then
                menu_item = MenuHelper:AddDivider({
                    id = "",
                    size = item.size,
                    title = title,
                    menu_id = menu_id,
                    priority = priority,
                    no_text = item.no_text
                })
                menu_item:set_parameter("color", Color.white)
            elseif i_type == "multiple_choice" then
                menu_item = MenuHelper:AddMultipleChoice({
                    id = id,
                    title = title,
                    desc = desc,
                    callback = callback,
                    items = item.items,
                    item_values = item.item_values,
                    value = value,
                    menu_id = menu_id,
                    priority = priority,
                    localized = localized,
                    localized_items = item.localized_items,
                    disabled = disabled
                })
            elseif i_type == "color" then
                local default_value = item.default_value
                value = value or default_value
                local data =
                {
                    type = "HMHMenuItemColor",
                    {
                        _meta = "option",
                        text_id = "hmh_r",
                        name = "r",
                        value = value.r,
                        localize = true
                    },
                    {
                        _meta = "option",
                        text_id = "hmh_g",
                        name = "g",
                        value = value.g,
                        localize = true
                    },
                    {
                        _meta = "option",
                        text_id = "hmh_b",
                        name = "b",
                        value = value.b,
                        localize = true
                    }
                }
                local params =
                {
                    name = id,
                    text_id = title,
                    help_id = desc,
                    callback = "hmh_modify_item_color",
                    localize = localized,
                    localize_help = localized,
                    default_color = default_value
                }
                local menu = MenuHelper:GetMenu(menu_id)
                menu_item = menu:create_item(data, params)
                menu_item:set_value(value)
                menu_item._priority = priority
                if disabled then
                    menu_item:set_enabled(false)
                end
                menu._items_list = menu._items_list or {}
                table.insert(menu._items_list, menu_item)
            end
            if menu_item and id then -- Dividers do not have ID assigned
                previous_items[id] = menu_item ---@diagnostic disable-line
                if item.value then
                    menu_item:set_parameter("option", item.value)
                end
                if item.params or content.global_params then
                    for key, param_value in pairs(item.params or content.global_params) do
                        menu_item:set_parameter(key, param_value)
                    end
                end
                if content.global_params then
                    for key, param_value in pairs(content.global_params) do
                        if not menu_item:parameter(key) then
                            menu_item:set_parameter(key, param_value)
                        end
                    end
                end
                if item.child then
                    menu_item:set_parameter("child", item.child)
                elseif item.children then
                    menu_item:set_parameter("children", item.children)
                end
                if item.children_f then
                    menu_item:set_parameter("children_f", item.children_f)
                end
                if item.children_f_or then
                    menu_item:set_parameter("children_f_or", item.children_f_or)
                end
                if item.child_compare then
                    menu_item:set_parameter("child_compare", item.child_compare)
                end
				if item.parent and previous_items[item.parent] then
                    menu_item:set_enabled(previous_items[item.parent]:value() == "on")
                end
                if item.parent_compare and item.parent_compare.id and previous_items[item.parent_compare.id] then
                    local data = item.parent_compare
                    local parent = previous_items[data.id]
                    local result = check_value(data, parent:value(), parent:type())
                    if data.enabled then
                        result = result and parent:enabled()
                    end
                    menu_item:set_enabled(result)
                elseif item.parents_compare then
                    local final_result = true
                    if item.parents_compare.comparator == "and" then
                        for key, data in pairs(item.parents_compare.items) do
                            local parent = previous_items[key]
                            if parent and not check_value(data, parent:value(), parent:type()) then
                                final_result = false
                                break
                            end
                        end
                    else -- or
                        final_result = false
                        for key, data in pairs(item.parents_compare.items) do
                            local parent = previous_items[key]
                            if parent and check_value(data, parent:value(), parent:type()) then
                                final_result = true
                                break
                            end
                        end
                    end
                    menu_item:set_enabled(final_result)
                end
                if item.other_item_compare and item.other_item_compare.id and previous_items[item.other_item_compare.id] then
                    local data = item.other_item_compare
                    previous_items[data.id]:set_enabled(check_value(data, value))
                end
                if item.other_items_compare then
                    for o_id, data in pairs(item.other_items_compare) do
                        previous_items[o_id]:set_enabled(check_value(data, value))
                    end
                end
            end
        end
    end)
end

---@param file_path string Path of the file to load and convert into a menu
---@param data_table table? Table containing the data keys which various menu items can load their value from
local function LoadFromJsonFile(file_path, data_table)
    local file = io.open(file_path, "r")
    if file then
        local file_content = file:read("*all")
        file:close()
        CreateMenuFromJson(json.decode(file_content), data_table)
    end
end

---@param item MenuItemMultiChoice|CoreMenuItemSlider.ItemSlider|CoreMenuItemToggle.ItemToggle
function MenuCallbackHandler:hmh_set_item_value(item)
    local params, type = item:parameters(), item:type()
    local value
    if type == "slider" then ---@cast item CoreMenuItemSlider.ItemSlider
        value = tonumber(item:raw_value_string())
    elseif type == "toggle" then ---@cast item CoreMenuItemToggle.ItemToggle
        value = item:value() == "on"
    else ---@cast item MenuItemMultiChoice
        value = item:value()
    end
    local settings_table = HMH._data
    if params.setting then
        settings_table = settings_table[params.setting]
    elseif params._data then
        for _, setting in ipairs(params._data) do
            settings_table = settings_table[setting]
        end
    end
    settings_table[params.option] = value
    if params.child then
        for _, row_item in ipairs(params.gui_node.row_items) do
            if row_item.name == params.child then
                row_item.item:set_enabled(value)
                break
            end
        end
    elseif params.children then
        local children = table.list_to_set(params.children)
        for _, row_item in ipairs(params.gui_node.row_items) do
            if children[row_item.name] then
                row_item.item:set_enabled(value)
            end
        end
    end
	if params.child_compare then
        local compare = params.child_compare
        for _, row_item in ipairs(params.gui_node.row_items) do
            local data = compare[row_item.name]
            if data and data.value then
                row_item.item:set_enabled(check_value(data, value --[[@as integer]]))
            end
        end
    end
    if params.children_f then
        for name, f in pairs(params.children_f) do
            for _, row_item in ipairs(params.gui_node.row_items) do
                if row_item.name == name and MenuCallbackHandler[f] then
                    row_item.item:set_enabled(value and MenuCallbackHandler[f]())
                    break
                end
            end
        end
    end
    if params.children_f_or then
        for name, f in pairs(params.children_f_or) do
            for _, row_item in ipairs(params.gui_node.row_items) do
                if row_item.name == name and MenuCallbackHandler[f] then
                    row_item.item:set_enabled(value or MenuCallbackHandler[f]())
                    break
                end
            end
        end
    end
end

function MenuCallbackHandler:hmh_save(item)
    HMH:Save()
end

function MenuCallbackHandler:hmh_assault_enabled()
    return HMH:GetOption("assault")
end

function MenuCallbackHandler:hmh_hostage_panel_enabled()
    return HMH:GetOption("hostage_panel")
end

function MenuCallbackHandler:hmh_wave_panel_enabled()
    return HMH:GetOption("wave_panel")
end

function MenuCallbackHandler:hmh_casing_enabled()
    return HMH:GetOption("casing")
end

function MenuCallbackHandler:hmh_captain_buff_enabled()
    return HMH:GetOption("captain_buff")
end

function MenuCallbackHandler:hmh_armorer_timer_enabled()
    return HMH:GetOption("armorer_cooldown_timer")
end

function MenuCallbackHandler:hmh_armorer_radial_enabled()
    return HMH:GetOption("armorer_cooldown_radial")
end

function MenuCallbackHandler:hmh_ability_icon_enabled()
    return HMH:GetOption("ability_icon")
end

function MenuCallbackHandler:hmh_duration_icon_enabled()
    return HMH:GetOption("duration_icon")
end

Hooks:Add("MenuManagerInitialize", "MenuManagerInitialize_HMH", function(menu_manager, nodes)
    LoadFromJsonFile(HMH._menu_path .. "Main.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "Presets/PresetsOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/Main.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/ComboCounter/ComboCounterOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/ECMTimer/ECMTimerOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "MenuOptions/EnhancedLoadout/EnhancedLoadoutOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "MenuOptions/SkipMenus/SkipMenusOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "MenuOptions/Main.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TeamHud/TeamHudOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TeamHud/PlayerColor/PlayerColorOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TeamHud/CustodyDowned/CustodyDownedOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TeamHud/Ammo/AmmoOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TeamHud/Ability/AbilityOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TeamHud/Equipment/EquipmentOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/BuffList/BuffListOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/InteractionAndCarry/InteractionAndCarryOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/Assault/AssaultOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TabstatsAndSubtitles/TabstatsAndSubtitlesOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/WaypointAndDetection/WaypointAndDetectionOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/Notifications/NotificationsOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/TimerAndObjectives/TimerAndObjectivesOptions.json", HMH._data)
	LoadFromJsonFile(HMH._menu_path .. "HudOptions/JoiningPlayers/JoiningPlayersOptions.json", HMH._data)
	
	local main_menu = menu_manager:get_menu(menu_manager._is_start_menu and "menu_main" or "menu_pause")
    if main_menu then
        local node = CoreMenuNode.MenuNode:new({
            gui_class = "HMHMenuNodeCustomizeGadgetGui",
            modifier = "HMHMenuSetColorInitiator",
            refresh = "HMHMenuSetColorInitiator"
        })

        node:set_callback_handler(MenuCallbackHandler:new())
        main_menu.data._nodes.hmh_color_select = node
    end
end)