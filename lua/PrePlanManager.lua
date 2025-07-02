local requiredScript = string.lower(RequiredScript)
if requiredScript == "lib/managers/menumanager" then
	local modifiy_node_preplanning_original = MenuPrePlanningInitiator.modifiy_node_preplanning

	function MenuPrePlanningInitiator:modifiy_node_preplanning(node, ...)
		-- Create Saved Plans node
		local open_menus = managers.menu and managers.menu._open_menus
		local active_menu = open_menus and open_menus[#open_menus]
		local pp_nodes = active_menu.logic and active_menu.logic._data._nodes
		if pp_nodes and not pp_nodes[PrePlanningManager.saved_plans_node] then
			local arugements = {
				_meta = "node",
				back_callback = "", --"stop_preplanning_post_event",
				gui_class = "MenuNodePrePlanningGui",
				menu_components = "preplanning_map preplanning_chats",
				modifier = "MenuPrePlanningInitiator",
				name = PrePlanningManager.saved_plans_node,
				no_menu_wrapper = true,
				refresh = "MenuPrePlanningInitiator",
				current_category = "none"
			}

			local node_class = CoreSerialize.string_to_classtable("MenuNodeTable")
			if node_class then
				pp_nodes[PrePlanningManager.saved_plans_node]  = node_class:new(arugements)
				local callback_handler = CoreSerialize.string_to_classtable("MenuCallbackHandler")
				if callback_handler then
					pp_nodes[PrePlanningManager.saved_plans_node]:set_callback_handler(callback_handler:new())
				end
			end
		end

		local return_values = { modifiy_node_preplanning_original(self, node, ...) }
		local new_node = table.remove(return_values, 1)

		-- Insert dividers
		self:create_divider(node, "end_regular_menu", nil, 16, nil)
		self:create_divider(node, "title_preplanning_manager", managers.localization:text("extracted_preplanning_manager_title"), nil, tweak_data.screen_colors.text)

		local item_data = {
			type = "CoreMenuItem.Item",
		}

		--Create custom Buttons
		local save_params = {
			name = "save_preplanning",
			text_id = "extracted_preplanning_save",
			callback = "save_preplanning",
			tooltip = {
				name = managers.localization:text("extracted_preplanning_save_tooltip_title"),
				desc = managers.localization:text("extracted_preplanning_save_tooltip_desc"),
				texture = "guis/textures/icon_saving",
				--texture_rect = {0, 0, 32, 32},
				errors = {},
			},
		}

		local load_params = {
			name = "load_preplanning",
			text_id = "extracted_preplanning_load",
			callback = "set_load_mode",
			next_node = PrePlanningManager.saved_plans_node,
			tooltip = {
				name = managers.localization:text("extracted_preplanning_load_tooltip_title"),
				desc = managers.localization:text("extracted_preplanning_load_tooltip_desc"),
				texture = "guis/textures/icon_loading",
				--texture_rect = {0, 0, 32, 32},
				errors = {},
			},
		}

		local delete_params = {
			name = "delete_preplanning",
			text_id = "extracted_preplanning_delete",
			callback = "set_delete_mode",
			next_node = PrePlanningManager.saved_plans_node,
			tooltip = {
				name = managers.localization:text("extracted_preplanning_delete_tooltip_title"),
				desc = managers.localization:text("extracted_preplanning_delete_tooltip_desc"),
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/drawtools_atlas",
				texture_rect = {2, 0, 29, 29},
				errors = {},
			},
		}

		local reset_params = {
			name = "reset_preplanning",
			text_id = "extracted_preplanning_reset",
			callback = "reset_preplanning",
			tooltip = {
				name = managers.localization:text("extracted_preplanning_reset_tooltip_title"),
				desc = managers.localization:text("extracted_preplanning_reset_tooltip_desc"),
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/drawtools_atlas",
				texture_rect = {30, 0, 29, 29},
				errors = {},
			},
		}

		local reset_all_params = {
			name = "full_reset_preplanning",
			text_id = "extracted_preplanning_reset_all",
			callback = "full_reset_preplanning",
			tooltip = {
				name = managers.localization:text("extracted_preplanning_reset_all_tooltip_title"),
				desc = managers.localization:text("extracted_preplanning_reset_all_tooltip_desc"),
				texture = "guis/dlcs/big_bank/textures/pd2/pre_planning/drawtools_atlas",
				texture_rect = {30, 0, 29, 29},
				errors = {},
			},
		}

		local save_item = new_node:create_item(item_data, save_params)
		new_node:add_item(save_item)

		local load_item = new_node:create_item(item_data, load_params)
		new_node:add_item(load_item)
		local delete_item = new_node:create_item(item_data, delete_params)
		new_node:add_item(delete_item)

		local reset_item = new_node:create_item(item_data, reset_params)
		new_node:add_item(reset_item)

		if Network:is_server() and not Global.game_settings.single_player then
			local reset_all_item = new_node:create_item(item_data, reset_all_params)
			new_node:add_item(reset_all_item)
		end

		return new_node, unpack(return_values)
	end

	function MenuPrePlanningInitiator:modifiy_node_preplanning_saved_plans(node, item_name, selected_item)
		local saved_plans = PrePlanningManager.get_saved_plans()

		if table.size(saved_plans) <= 0 then
			self:create_divider(node, "title_category_saved_plans", managers.localization:text("extracted_preplanning_error_no_saved_plans"), nil, tweak_data.screen_colors.text)
			selected_item = "title_category_saved_plans"    -- TODO: crashing with controllers? Might have to set this 'nil' here...
		else
			if PrePlanningManager._PREPLANNING_DELETE_MODE then
				self:create_divider(node, "title_category_saved_plans", managers.localization:text("extracted_preplanning_delete"), nil, tweak_data.screen_colors.text)
				selected_item = nil
			else
				self:create_divider(node, "title_category_saved_plans", managers.localization:text("extracted_preplanning_load"), nil, tweak_data.screen_colors.text)
			end

			for name, data in pairs(saved_plans) do
				local item = node:item(name)
				if not item then
					local plan_icon --= "feature_crimenet_heat"
					local display_name = name
					if display_name:find("<GHOST>") then
						display_name = display_name:gsub("<GHOST>", "")
						plan_icon = "endscreen/stealth_bonus"
					elseif display_name:find("<SKULL>") then
						display_name = display_name:gsub("<SKULL>", "")
						plan_icon = "risklevel_blackscreen"
					end

					local item_data = {
						type = "CoreMenuItem.Item",
					}

					local params = {
						name = name,
						text_id = display_name or name,
						localize = false,
						callback = "saved_plan_clbk",
						tooltip = {
							name = display_name or name,
							desc = managers.preplanning and managers.preplanning:saved_assets_name(name),
							texture = "guis/textures/pd2/" .. (plan_icon or "feature_crimenet_heat"),
							texture_rect = not plan_icon and {0, 0, 1, 1}
						},
						enabled = true
					}

					local plan_item = node:create_item(item_data, params)
					node:add_item(plan_item)
				end
				selected_item = selected_item or name
			end

			table.sort(node:items(), function (a, b)
				if a._type == "divider" then
					return true
				elseif b._type == "divider" then
					return false
				end
				return tostring(a:parameters().name):upper() < tostring(b:parameters().name):upper()
			end)
		end

		return node, selected_item
	end

	function MenuCallbackHandler:save_preplanning(item)
		if managers.preplanning then
			managers.preplanning:save_preplanning()
		end
	end

	function MenuCallbackHandler:reset_preplanning(item)
		if managers.preplanning then
			managers.preplanning:reset_preplanning()
		end
	end

	function MenuCallbackHandler:full_reset_preplanning(item)
		if managers.preplanning then
			managers.preplanning:reset_preplanning(true)
		end
	end

	function MenuCallbackHandler:set_load_mode(item)
		PrePlanningManager._PREPLANNING_DELETE_MODE = false
	end

	function MenuCallbackHandler:set_delete_mode(item)
		PrePlanningManager._PREPLANNING_DELETE_MODE = true
	end

	function MenuCallbackHandler:saved_plan_clbk(item)
		local params = item:parameters() or {}
		local plan_name = params.name or ""
		if managers.preplanning then
			if PrePlanningManager._PREPLANNING_DELETE_MODE then
				managers.preplanning:delete_preplanning(plan_name)
			else
				managers.preplanning:load_preplanning(plan_name)
			end
		end
	end
	function MenuManager:show_confirm_preplanning_load(params)
		local dialog_data = {
			title = managers.localization:text("menu_item_preplanning_rebuy"),
			text = "",
			text_formating_color_table = {},
			use_text_formating = true,
			w = 600
		}
		local red = tweak_data.screen_colors.important_1
		local grey = tweak_data.screen_color_grey
		local total_money_cost = 0
		local total_favor_cost = 0

		for _, plan in pairs(params.votes) do
			local category_text = utf8.to_upper(managers.preplanning:get_category_name_by_type(plan.type))
			local location_text = managers.preplanning:get_element_name_by_type_index(plan.type, plan.index)
			local name_text = managers.preplanning:get_type_name(plan.type)
			local cost_text = managers.preplanning:get_type_cost_text(plan.type)
			dialog_data.text = dialog_data.text .. category_text .. "\n"
			dialog_data.text = dialog_data.text .. "  -" .. name_text

			if not string.match(location_text, "ERROR") then
				dialog_data.text = dialog_data.text .. " - " .. location_text
			end

			dialog_data.text = dialog_data.text .. " (" .. cost_text .. ") \n \n"
			total_money_cost = total_money_cost + managers.preplanning:get_type_cost(plan.type)
			total_favor_cost = total_favor_cost + managers.preplanning:get_type_budget_cost(plan.type)
		end

		local category_list = {}

		for _, asset in ipairs(params.rebuy_assets) do
			local cat_name = utf8.to_upper(managers.preplanning:get_category_name_by_type(asset.type))
			local create_new_category = true

			for _, category in ipairs(category_list) do
				if cat_name == category.category then
					table.insert(category.assets, {
						type = asset.type,
						id = asset.id,
						index = asset.index
					})

					create_new_category = false
				end
			end

			if create_new_category then
				table.insert(category_list, {
					category = cat_name,
					assets = {
						{
							type = asset.type,
							id = asset.id,
							index = asset.index
						}
					}
				})
			end
		end

		for _, category in ipairs(category_list) do
			dialog_data.text = dialog_data.text .. category.category .. " \n"

			for _, asset in ipairs(category.assets) do
				local money_cost = managers.preplanning:get_type_cost(asset.type)
				local favor_cost = managers.preplanning:get_type_budget_cost(asset.type)
				local td = managers.preplanning:get_tweak_data_by_type(asset.type)
				local name_text = managers.preplanning:get_type_name(asset.type)
				local cost_text = managers.preplanning:get_type_cost_text(asset.type)
				local location_text = managers.preplanning:get_element_name_by_type_index(asset.type, asset.index)
				local can_unlock = true

				if td.dlc_lock then
					can_unlock = can_unlock and managers.dlc:is_dlc_unlocked(td.dlc_lock)
				end

				if td.upgrade_lock then
					can_unlock = can_unlock and managers.player:has_category_upgrade(td.upgrade_lock.category, td.upgrade_lock.upgrade)
				end

				if not can_unlock then
					table.insert(dialog_data.text_formating_color_table, grey)

					dialog_data.text = dialog_data.text .. "##"
				else
					total_money_cost = total_money_cost + money_cost
					total_favor_cost = total_favor_cost + favor_cost
				end

				dialog_data.text = dialog_data.text .. "   -" .. name_text

				if not string.match("ERROR", location_text) then
					dialog_data.text = dialog_data.text .. " - " .. location_text
				end

				dialog_data.text = dialog_data.text .. " (" .. cost_text .. ")"

				if td.upgrade_lock and not can_unlock then
					dialog_data.text = dialog_data.text .. "##"

					table.insert(dialog_data.text_formating_color_table, red)

					dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_skill")
				elseif td.dlc_lock and not can_unlock then
					dialog_data.text = dialog_data.text .. "##"

					table.insert(dialog_data.text_formating_color_table, red)

					dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_dlc", {
						dlc = managers.localization:text(self:get_dlc_by_id(td.dlc_lock).name_id)
					})
				end

				dialog_data.text = dialog_data.text .. "\n"
			end
		end

		dialog_data.text = dialog_data.text .. "\n"

		if total_money_cost < managers.money:total() then
			dialog_data.text = dialog_data.text .. managers.localization:text("dialog_preplanning_rebuy_assets", {
				price = managers.experience:cash_string(total_money_cost),
				favor = total_favor_cost
			})
			local yes_button = {
				text = managers.localization:text("dialog_yes"),
				callback_func = params.yes_func
			}
			local no_button = {
				cancel_button = true,
				text = managers.localization:text("dialog_no")
			}
			dialog_data.focus_button = 2
			dialog_data.button_list = {
				yes_button,
				no_button
			}
		else
			dialog_data.text = dialog_data.text .. "##" .. managers.localization:text("bm_menu_not_enough_cash") .. "##"

			table.insert(dialog_data.text_formating_color_table, red)

			local ok_button = {
				text = managers.localization:text("dialog_ok"),
				cancel_button = true
			}
			dialog_data.focus_button = 1
			dialog_data.button_list = {
				ok_button
			}
		end

		managers.system_menu:show(dialog_data)
	end
elseif requiredScript == "lib/managers/preplanningmanager" then

	if not PrePlanningManager._PREPLANNING_SETUP then
		PrePlanningManager._SAVE_FOLDER = Application:nice_path(SavePath .. "PreplannedV2/", true):gsub("\\", "/")
		PrePlanningManager._SAVE_FILE = PrePlanningManager._SAVE_FOLDER .. "/Unknown.json"
		PrePlanningManager._SAVED_PLANS = nil
		PrePlanningManager.saved_plans_node = "preplanning_saved_plans"
		PrePlanningManager._PREPLANNING_DELETE_MODE = false
		PrePlanningManager._PREPLANNING_MAX_PLANS = 10
		PrePlanningManager._DEFAULT_PLAN_NAMES = { "Alfa", "Bravo", "Charlie", "Delta", "Echo", "Foxtrott", "Golf", "Hotel", "India", "Juliett", "Kilo", "Lima", "Mike", "November", "Oscar"}
		PrePlanningManager._LEVEL_ID_SUB = { "_night", "_day" }
		PrePlanningManager._LEVEL_ID_OVERWRITES = { gallery = "framing_frame_1", firestarter_3 = "branchbank" }

		function PrePlanningManager.set_path()
			if managers.crime_spree and managers.job then
				local level_id = managers.job:current_level_id()

				if level_id then
					level_id = PrePlanningManager._LEVEL_ID_OVERWRITES[level_id] or level_id
					for _, str in pairs(PrePlanningManager._LEVEL_ID_SUB) do
						level_id = level_id:gsub(str, "")
					end

					PrePlanningManager._SAVE_FILE = string.format("%s%s.json", PrePlanningManager._SAVE_FOLDER, level_id or "Unknown")
				end
			end
		end

		function PrePlanningManager.load_plans()
			local file = io.open(PrePlanningManager._SAVE_FILE, "r")
			if file then
				PrePlanningManager._SAVED_PLANS = json.decode(file:read("*all"))
				file:close()
			end
			if not PrePlanningManager._SAVED_PLANS then
				PrePlanningManager._SAVED_PLANS = {}
			end
		end

		function PrePlanningManager.has_saved_plans()
			return PrePlanningManager._SAVED_PLANS and (table.size(PrePlanningManager._SAVED_PLANS) > 0)
		end

		function PrePlanningManager.has_free_save_slot()
			return PrePlanningManager._SAVED_PLANS and (table.size(PrePlanningManager._SAVED_PLANS) < PrePlanningManager._PREPLANNING_MAX_PLANS)
		end

		function PrePlanningManager.has_current_plan()
			if managers.preplanning then
				local peer_id = managers.network:session() and managers.network:session():local_peer():id()
				local current_assets, current_votes = managers.preplanning._reserved_mission_elements or {}, peer_id and managers.preplanning:get_player_votes(peer_id) or {}
				return (table.size(current_assets) > 0) or (table.size(current_votes) > 0)
			end
			return false
		end
		
		function PrePlanningManager.DirectoryExists(path)
			if SystemFS and SystemFS.exists then
				return SystemFS:exists(path)
			elseif file and file.DirectoryExists then
				log("")	-- For some weird reason the function below always returns true if we don't log anything previously...
				return file.DirectoryExists(path)
			end
		end
		
		function PrePlanningManager.createDirectory(path)
			local current = ""
			path = Application:nice_path(path, true):gsub("\\", "/")

			for folder in string.gmatch(path, "([^/]*)/") do
				current = Application:nice_path(current .. folder, true)

				if not PrePlanningManager.DirectoryExists(current) then
					if SystemFS and SystemFS.make_dir then
						SystemFS:make_dir(current)
					elseif file and file.CreateDirectory then
						file.CreateDirectory(current)
					end
				end
			end

			return PrePlanningManager.DirectoryExists(path)
		end

		function PrePlanningManager.save_plans()
			if not PrePlanningManager.DirectoryExists(PrePlanningManager._SAVE_FOLDER) then
				if not PrePlanningManager.createDirectory(PrePlanningManager._SAVE_FOLDER) then
					managers.preplanning:notify_user("extracted_preplanning_msg_folder_creation_failed", { FOLDER = PrePlanningManager._SAVE_FOLDER }, true)
				end
			end
			local file = io.open(PrePlanningManager._SAVE_FILE, "w+")
			if file then
				local tbl_str = "{}"
				if PrePlanningManager._SAVED_PLANS and table.size(PrePlanningManager._SAVED_PLANS) > 0 then
					tbl_str = json.encode(PrePlanningManager._SAVED_PLANS)
				end

				file:write(tbl_str)
				file:close()

				return true
			else
				managers.preplanning:notify_user("extracted_preplanning_msg_file_creation_failed", { FILE = PrePlanningManager._SAVE_FILE }, true)
			end
		end

		function PrePlanningManager.get_saved_plans()
			if not PrePlanningManager._SAVED_PLANS then
				PrePlanningManager.set_path()
				PrePlanningManager.load_plans()
			end

			return PrePlanningManager._SAVED_PLANS
		end

		PrePlanningManager._PREPLANNING_SETUP = true
	end

	function PrePlanningManager:save_preplanning()
		if not PrePlanningManager._SAVED_PLANS then
			PrePlanningManager.set_path()
			PrePlanningManager.load_plans()
		end

		if not PrePlanningManager.has_free_save_slot() then
			managers.preplanning:notify_user("extracted_preplanning_msg_no_save_slot", {}, true)
		elseif not PrePlanningManager.has_current_plan() then
			managers.preplanning:notify_user("extracted_preplanning_msg_no_current_plan", {}, true)
		else
			local default_name = ""
			for i = 1, #PrePlanningManager._DEFAULT_PLAN_NAMES do
				local name = PrePlanningManager._DEFAULT_PLAN_NAMES[i]
				if not PrePlanningManager._SAVED_PLANS[name] then
					default_name = name
					break
				end
			end

			local menu_options = {
				[1] = {
					text = managers.localization:text("extracted_dialog_save"),
					callback = function(cb_data, button_id, button, text)
						if managers.preplanning then
							managers.preplanning:save_preplanning_clbk(text)
						end
					end,
				},
				[2] = {
					text = managers.localization:text("dialog_cancel"),
					is_cancel_button = true,
				}
			}
			local plan_str = managers.preplanning and managers.preplanning:current_assets_name() or ""
			QuickInputMenu:new(managers.localization:text("extracted_preplanning_dialog_save"), managers.localization:text("extracted_preplanning_dialog_save_desc", {PLAN = plan_str}), default_name, menu_options, true)
		end
	end

	function PrePlanningManager:save_preplanning_clbk(name)
		if name and name ~= "" then
			local peer_id = managers.network and managers.network:session():local_peer():id()

			local bought_assets = self._reserved_mission_elements
			--local votes = self:get_player_votes(peer_id) or {}
			--local default_votes = self:get_default_votes() or {}
			local saved_assets, saved_votes = {}, {}

			for element_id, mission_element in pairs(bought_assets) do
				if mission_element.peer_id == peer_id then
					local element_type, element_index = unpack(mission_element.pack)
					table.insert(saved_assets, { id = element_id, type = element_type, index = element_index })
				end
			end

			local winners = self:get_current_majority_votes()
			if winners then
				for plan, data in pairs(winners) do
					local type, index = unpack(data)
					table.insert(saved_votes, { id = self:get_mission_element_id(type, index), type = type, index = index })
				end
			end

			local preplanning_data = {
				assets = #saved_assets > 0 and saved_assets or nil,
				votes = #saved_votes > 0 and saved_votes or nil,
			}
			PrePlanningManager._SAVED_PLANS = PrePlanningManager._SAVED_PLANS or {}
			PrePlanningManager._SAVED_PLANS[name] = (preplanning_data.assets or preplanning_data.votes) and preplanning_data or nil
			if PrePlanningManager.save_plans() then
				managers.preplanning:notify_user("extracted_preplanning_msg_saved_success", {}, false)
			else
				PrePlanningManager._SAVED_PLANS[name] = nil
			end
		end
	end

	function PrePlanningManager:load_preplanning(name)
		if PrePlanningManager._SAVED_PLANS and PrePlanningManager._SAVED_PLANS[name] then
			local saved_assets = PrePlanningManager._SAVED_PLANS[name].assets or {}
			local saved_votes = PrePlanningManager._SAVED_PLANS[name].votes or {}

			local dialog_data = {
				title = managers.localization:text("menu_item_preplanning_rebuy"),
				text = "",
				text_formating_color_table = {},
				use_text_formating = true,
				w = 600
			}
			local red = tweak_data.screen_colors.important_1
			local grey = tweak_data.screen_color_grey
			local total_money_cost = 0
			local total_favor_cost = 0

			for _, plan in pairs(saved_votes) do
				local category_text = utf8.to_upper(managers.preplanning:get_category_name_by_type(plan.type))
				local location_text = managers.preplanning:get_element_name_by_type_index(plan.type, plan.index)
				local name_text = managers.preplanning:get_type_name(plan.type)
				local cost_text = managers.preplanning:get_type_cost_text(plan.type)
				dialog_data.text = dialog_data.text .. category_text .. "\n"
				dialog_data.text = dialog_data.text .. "  -" .. name_text

				if not string.match(location_text, "ERROR") then
					dialog_data.text = dialog_data.text .. " - " .. location_text
				end

				dialog_data.text = dialog_data.text .. " (" .. cost_text .. ") \n \n"
				total_money_cost = total_money_cost + managers.preplanning:get_type_cost(plan.type)
				total_favor_cost = total_favor_cost + managers.preplanning:get_type_budget_cost(plan.type)
			end

			local category_list = {}

			for _, asset in ipairs(saved_assets) do
				local cat_name = utf8.to_upper(managers.preplanning:get_category_name_by_type(asset.type))
				local create_new_category = true

				for _, category in ipairs(category_list) do
					if cat_name == category.category then
						table.insert(category.assets, {
							type = asset.type,
							id = asset.id,
							index = asset.index
						})

						create_new_category = false
					end
				end

				if create_new_category then
					table.insert(category_list, {
						category = cat_name,
						assets = {
							{
								type = asset.type,
								id = asset.id,
								index = asset.index
							}
						}
					})
				end
			end

			for _, category in ipairs(category_list) do
				dialog_data.text = dialog_data.text .. category.category .. " \n"

				for _, asset in ipairs(category.assets) do
					local money_cost = managers.preplanning:get_type_cost(asset.type)
					local favor_cost = managers.preplanning:get_type_budget_cost(asset.type)
					local td = managers.preplanning:get_tweak_data_by_type(asset.type)
					local name_text = managers.preplanning:get_type_name(asset.type)
					local cost_text = managers.preplanning:get_type_cost_text(asset.type)
					local location_text = managers.preplanning:get_element_name_by_type_index(asset.type, asset.index)
					local can_unlock = true

					if td.dlc_lock then
						can_unlock = can_unlock and managers.dlc:is_dlc_unlocked(td.dlc_lock)
					end

					if td.upgrade_lock then
						can_unlock = can_unlock and managers.player:has_category_upgrade(td.upgrade_lock.category, td.upgrade_lock.upgrade)
					end

					if not can_unlock then
						table.insert(dialog_data.text_formating_color_table, grey)

						dialog_data.text = dialog_data.text .. "##"
					else
						total_money_cost = total_money_cost + money_cost
						total_favor_cost = total_favor_cost + favor_cost
					end

					dialog_data.text = dialog_data.text .. "   -" .. name_text

					if not string.match("ERROR", location_text) then
						dialog_data.text = dialog_data.text .. " - " .. location_text
					end

					dialog_data.text = dialog_data.text .. " (" .. cost_text .. ")"

					if td.upgrade_lock and not can_unlock then
						dialog_data.text = dialog_data.text .. "##"

						table.insert(dialog_data.text_formating_color_table, red)

						dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_skill")
					elseif td.dlc_lock and not can_unlock then
						dialog_data.text = dialog_data.text .. "##"

						table.insert(dialog_data.text_formating_color_table, red)

						dialog_data.text = dialog_data.text .. " " .. managers.localization:text("menu_asset_buy_all_req_dlc", {
							dlc = managers.localization:text(managers.menu:get_dlc_by_id(td.dlc_lock).name_id)
						})
					end

					dialog_data.text = dialog_data.text .. "\n"
				end
			end

			dialog_data.text = dialog_data.text .. "\n"

			if total_money_cost < managers.money:total() then
				dialog_data.text = dialog_data.text .. managers.localization:text("dialog_preplanning_rebuy_assets", {
					price = managers.experience:cash_string(total_money_cost),
					favor = total_favor_cost
				})
				local yes_button = {
					text = managers.localization:text("dialog_yes"),
					callback_func = function(self)
						for i, data in ipairs(saved_assets) do
							local td = managers.preplanning:get_tweak_data_by_type(data.type)
							local can_unlock = managers.preplanning:can_reserve_mission_element(data.type)

							if td.dlc_lock then
								can_unlock = can_unlock and managers.dlc:is_dlc_unlocked(td.dlc_lock)
							end

							if td.upgrade_lock then
								can_unlock = can_unlock and managers.player:has_category_upgrade(td.upgrade_lock.category, td.upgrade_lock.upgrade)
							end

							if can_unlock then
								managers.preplanning:reserve_mission_element(data.type, data.id)
							end
						end

						for i, data in ipairs(saved_votes) do
							if managers.preplanning:can_vote_on_plan(data.type, managers.network:session():local_peer():id()) then
								managers.preplanning:mass_vote_on_plan(data.type, data.id)
							end
						end
					end
				}
				local no_button = {
					cancel_button = true,
					text = managers.localization:text("dialog_no")
				}
				dialog_data.focus_button = 2
				dialog_data.button_list = {
					yes_button,
					no_button
				}
			else
				dialog_data.text = dialog_data.text .. "##" .. managers.localization:text("bm_menu_not_enough_cash") .. "##"

				table.insert(dialog_data.text_formating_color_table, red)

				local ok_button = {
					text = managers.localization:text("dialog_ok"),
					cancel_button = true
				}
				dialog_data.focus_button = 1
				dialog_data.button_list = {
					ok_button
				}
			end

			managers.system_menu:show(dialog_data)
		end
	end

	function PrePlanningManager:reset_preplanning(full_reset)
		if not PrePlanningManager.has_current_plan() then
			managers.preplanning:notify_user("extracted_preplanning_msg_no_current_plan", {}, true)
		else
			local peer_id = managers.network and managers.network:session():local_peer():id()

			local bought_assets = self._reserved_mission_elements or {}
			local votes = self:get_player_votes(peer_id) or {}

			for element_id, mission_element in pairs(bought_assets) do
				if (full_reset and PrePlanningManager.server_master_planner and Network:is_server()) or mission_element.peer_id == peer_id then
					self:unreserve_mission_element(element_id)
				end
			end

			for plan, data in pairs(votes) do
				local location_data = self:_current_location_data()
				local default_plan = plan and location_data and location_data.default_plans and location_data.default_plans[plan]
				local default_element = self:get_default_plan_mission_element(default_plan)
				if default_plan and default_element then
					self:vote_on_plan(default_plan, default_element:id())
				end
			end

			managers.preplanning:notify_user("extracted_preplanning_msg_reseted_success", {}, true)
		end
	end

	function PrePlanningManager:delete_preplanning(name)
		local menu_options = {
			[1] = {
				text = managers.localization:text("dialog_yes"),
				callback = function(self, item)
					managers.preplanning:delete_preplanning_clbk(name)

					local open_menus = managers.menu and managers.menu._open_menus
					local active_menu = open_menus and open_menus[#open_menus]
					if active_menu and active_menu.logic then
						active_menu.logic:refresh_node(active_menu.logic:selected_node())
					end
				end,
			},
			[2] = {
				text = managers.localization:text("dialog_no"),
				is_cancel_button = true,
			}
		}
		QuickMenu:new( managers.localization:text("extracted_preplanning_dialog_delete"), managers.localization:text("extracted_preplanning_dialog_delete_desc", {NAME = name}), menu_options, true )
	end

	function PrePlanningManager:delete_preplanning_clbk(name)
		if PrePlanningManager._SAVED_PLANS and PrePlanningManager._SAVED_PLANS[name] then
			PrePlanningManager._SAVED_PLANS[name] = nil
			if PrePlanningManager.save_plans() then
				managers.preplanning:notify_user("extracted_preplanning_msg_deleted_success", {}, false)
				return
			end
		end
		managers.preplanning:notify_user("extracted_preplanning_msg_deleted_failed", {}, true)
	end

	function PrePlanningManager:current_assets_name()
		local text = ""

		local peer_id = managers.network and managers.network:session():local_peer():id()
		local current_assets, current_votes, default_votes = self._reserved_mission_elements or {}, self:get_player_votes(peer_id) or {}, self:get_default_votes() or {}

		if table.size(current_votes) > 0 or table.size(default_votes) > 0 then
			text = string.format("%s%s\n", text, managers.localization:text("extracted_preplanning_votes_title"))
			for plan, data in pairs(current_votes) do
				local element_type, element_index = unpack(data)
				local plan_data = tweak_data and tweak_data.preplanning.types[element_type]
				local plan_name = plan_data and plan_data.name_id and managers.localization:text(plan_data.name_id) or ""
				text = string.format("%s - %s", text, plan_name)
				local element = self._mission_elements_by_type[element_type] and self._mission_elements_by_type[element_type][element_index]
				if element then
					text = string.format("%s (%s)\n", text, self:get_element_name(element))
				else
					text = string.format("%s\n", text)
				end
				default_votes[plan] = nil
			end

			for plan, data in pairs(default_votes) do
				local element_type, element_index = unpack(data)
				local plan_data = tweak_data and tweak_data.preplanning.types[element_type]
				local plan_name = plan_data and plan_data.name_id and managers.localization:text(plan_data.name_id) or ""
				text = string.format("%s - %s", text, plan_name)
				local element = self._mission_elements_by_type[element_type] and self._mission_elements_by_type[element_type][element_index]
				local element_name = element and self:get_element_name(element)
				if element_name and not element_name:lower():find("error") and not plan_data.pos_not_important then
					text = string.format("%s (%s)\n", text, element_name)
				else
					text = string.format("%s\n", text)
				end
				default_votes[plan] = nil
			end

			text = string.format("%s\n", text)
		end

		if table.size(current_assets) > 0 then
			text = string.format("%s%s\n", text, managers.localization:text("extracted_preplanning_assets_title"))
			for id, mission_element in pairs(current_assets) do
				if mission_element.peer_id == peer_id then
					local element_type, index = unpack(mission_element.pack)
					local type_name = self:get_type_name(element_type)
					text = string.format("%s - %s", text, type_name)
					local element = self._mission_elements_by_type[element_type] and self._mission_elements_by_type[element_type][index]
					local element_name = element and self:get_element_name(element)
					if element_name and not element_name:lower():find("error") then
						text = string.format("%s (%s)\n", text, element_name)
					else
						text = string.format("%s\n", text)
					end
				end
			end
		end

		local money_str = managers.experience:cash_string(self:get_reserved_local_cost())
		local favours_amnt = self:get_current_budget()
		text = string.format("%s%s", text, managers.localization:text("menu_pp_tooltip_costs", {money = money_str, budget = favours_amnt}))

		return text
	end

	function PrePlanningManager:saved_assets_name(plan_name)
		local text = ""

		if PrePlanningManager._SAVED_PLANS and PrePlanningManager._SAVED_PLANS[plan_name] then
			local saved_assets, saved_votes = PrePlanningManager._SAVED_PLANS[plan_name].assets or {}, PrePlanningManager._SAVED_PLANS[plan_name].votes or {}

			if table.size(saved_votes) > 0 then
				text = string.format("%s%s\n", text, managers.localization:text("extracted_preplanning_votes_title"))
				for i, data in pairs(saved_votes) do
					local plan_data = tweak_data and tweak_data.preplanning.types[data.type]
					local plan_name = plan_data and plan_data.name_id and managers.localization:text(plan_data.name_id) or ""
					text = string.format("%s - %s", text, plan_name)
					local element = self._mission_elements_by_type[data.type] and self._mission_elements_by_type[data.type][data.index]
					local element_name = element and self:get_element_name(element)
					if element_name and not element_name:lower():find("error") and not plan_data.pos_not_important then
						text = string.format("%s (%s)\n", text, element_name)
					else
						text = string.format("%s\n", text)
					end
				end
				text = string.format("%s\n", text)
			end

			if table.size(saved_assets) > 0 then
				text = string.format("%s%s\n", text, managers.localization:text("extracted_preplanning_assets_title"))
				for id, mission_element in pairs(saved_assets) do
					local type_name = self:get_type_name(mission_element.type)
					text = string.format("%s - %s", text, type_name)
					local element = self._mission_elements_by_type[mission_element.type] and self._mission_elements_by_type[mission_element.type][mission_element.index]
					local element_name = element and self:get_element_name(element)
					if element_name and not element_name:lower():find("error") then
						text = string.format("%s (%s)\n", text, element_name)
					else
						text = string.format("%s\n", text)
					end
				end
			end
		end

		local money_str, favours_amnt = self:get_saved_costs(plan_name)
		money_str = managers.experience:cash_string(money_str)
		text = string.format("%s%s", text, managers.localization:text("menu_pp_tooltip_costs", {money = money_str, budget = favours_amnt}))

		return text
	end
	function PrePlanningManager:get_saved_costs(name)
		local money_costs, favours = 0, 0

		if PrePlanningManager._SAVED_PLANS and PrePlanningManager._SAVED_PLANS[name] then
			local saved_assets, saved_votes = PrePlanningManager._SAVED_PLANS[name].assets or {}, PrePlanningManager._SAVED_PLANS[name].votes or {}
			for i, data in pairs(saved_votes) do
				money_costs = money_costs + self:get_type_cost(data.type)
				favours = favours + self:get_type_budget_cost(data.type, 0)
			end

			for id, mission_element in pairs(saved_assets) do
				money_costs = money_costs + self:get_type_cost(mission_element.type)
				favours = favours + self:get_type_budget_cost(mission_element.type, 0)
			end
		end
		return money_costs, favours
	end

	function PrePlanningManager:get_default_votes()
		local default_votes = {} 	--{plan = {element_type, element_index}}

		local location_data = self:_current_location_data()
		local default_plans = location_data and location_data.default_plans and location_data.default_plans or {}

		for plan, element_type in pairs(default_plans) do
			local default_element = self:get_default_plan_mission_element(element_type)
			if element_type and default_element then
				default_votes[plan] = {element_type, 1}
			end
		end

		return default_votes
	end

	function PrePlanningManager:notify_user(text_id, macros, show_SP)
		local message = managers.localization:text(text_id, macros)
		if not Global.game_settings.single_player  then
			managers.chat:feed_system_message(ChatManager.GAME, message)
		elseif show_SP then
			QuickMenu:new(managers.localization:text("extracted_preplanning_manager_title"), message, { text = managers.localization:text("dialog_ok"), is_cancel_button = true }, true)
		end
	end
end
