if string.lower(RequiredScript) == "lib/managers/menumanager" then
	Hooks:OverrideFunction(MenuCallbackHandler, "get_latest_dlc_locked", function(self) return false end) --Hide DLC ad in the main menu
	
	-- Offline chat
	Hooks:OverrideFunction(MenuManager, "toggle_chatinput", function(self)
	    if Application:editor() or SystemInfo:platform() ~= Idstring("WIN32") or self:active_menu() or not managers.network:session() then
		    return
	    end
	    if managers.hud then
		    managers.hud:toggle_chatinput()
		    return true
	    end
    end)

elseif string.lower(RequiredScript) == "lib/managers/menu/blackmarketgui" then
	local inventory_amount = HMH:GetOption("inventory_amount") and not VHUDPlus
	local function getEquipmentAmount(name_id)
		local data = tweak_data.equipments[name_id]
		if data and data.quantity and inventory_amount then
			if type(data.quantity) == "table" then
				local amounts = data.quantity
				local amount_str = ""
				for i = 1, #amounts do
					local equipment_name = name_id
					if data.upgrade_name then
						equipment_name = data.upgrade_name[i]
					end
					amount_str = amount_str .. (i > 1 and "/x" or "x") .. tostring((amounts[i] or 0) + managers.player:equiptment_upgrade_value(equipment_name, "quantity"))
				end
				return " (" .. amount_str .. ")"
			else
				return " (x" .. tostring(data.quantity) .. ")"
			end
		end
		return ""
	end

	Hooks:PostHook(BlackMarketGui, "populate_deployables", "HMH_BlackMarketGui_populate_deployables", function(self, data, ...)
		if inventory_amount then
			for i, equipment in ipairs(data) do
				equipment.name_localized = equipment.name_localized .. (equipment.unlocked and getEquipmentAmount(equipment.name) or "")
			end
		end
	end)

	Hooks:PostHook(BlackMarketGui, "populate_grenades", "HMH_BlackMarketGui_populate_grenades", function(self, data, ...)
		local t_data = tweak_data.blackmarket.projectiles
		if inventory_amount then
			for i, throwable in ipairs(data) do
				local has_amount = throwable.unlocked and t_data[throwable.name] or false
				throwable.name_localized = throwable.name_localized .. (has_amount and " (x" .. t_data[throwable.name].max_amount .. ")" or "")
			end
		end
	end)

elseif string.lower(RequiredScript) == "lib/managers/menu/skilltreeguinew" then
	--Fix mouse pointer for locked skills
	local orig_newskilltreeskillitem_is_active = NewSkillTreeSkillItem.is_active
	function NewSkillTreeSkillItem:is_active(...)
		local unlocked = self._skill_id and self._tree and managers.skilltree and managers.skilltree:skill_unlocked(self._tree, self._skill_id) or false
		return orig_newskilltreeskillitem_is_active(self, ...) or not unlocked
	end

	--Resize and move total points label
	Hooks:PostHook(NewSkillTreeTierItem, "init", "HMH_NewSkillTreeTierItem_init", function(self, ...)
		if self._tier_points_total and self._tier_points_total_zero and self._tier_points_total_curr then
			local font_size = tweak_data.menu.pd2_small_font_size * 0.75
			self._tier_points_total:set_font_size(font_size)
			local _, _, w, h = self._tier_points_total:text_rect()
			self._tier_points_total:set_size(w, h)
			self._tier_points_total_zero:set_font_size(font_size)
			self._tier_points_total_curr:set_font_size(font_size)
			self._tier_points_total:set_alpha(0.9)
			self._tier_points_total_curr:set_alpha(0.9)
			self._tier_points_total_zero:set_alpha(0.6)
		end
	end)
	
	Hooks:PostHook(NewSkillTreeTierItem, "refresh_points", "HMH_NewSkillTreeTierItem_refresh_points", function(self, selected, ...)
		if alive(self._tier_points_total) and alive(self._tier_points_total_zero) and alive(self._tier_points_total_curr) then
			self._tier_points_total:set_y(self._text_space or 10)
			self._tier_points_total_zero:set_y(self._text_space or 10)
			self._tier_points_total_curr:set_y(self._text_space or 10)
		end
		if alive(self._tier_points_0) and alive(self._tier_points) then
			self._tier_points:set_visible(not self._tier_points_needed:visible())
			self._tier_points_0:set_visible(not self._tier_points_needed:visible())
		end
	end)

	Hooks:PostHook(NewSkillTreeTierItem, "_refresh_tier_text", "HMH_NewSkillTreeTierItem_refresh_tier_text", function(self, selected, ...)
		if selected and alive(self._tier_points_needed) and alive(self._tier_points_needed_curr) and alive(self._tier_points_needed_zero) then
			self._tier_points_needed_zero:set_left(self._tier_points_0:left())
			self._tier_points_needed_curr:set_left(self._tier_points_needed_zero:right())
			self._tier_points_needed:set_left(self._tier_points_needed_curr:right() + self._text_space)
		end
		if alive(self._tier_points_0) and alive(self._tier_points) then
			self._tier_points:set_visible(not self._tier_points_needed:visible())
			self._tier_points_0:set_visible(not self._tier_points_needed:visible())
		end
	end)

elseif string.lower(RequiredScript) == "lib/states/ingamewaitingforplayers" then
	Hooks:PostHook(IngameWaitingForPlayersState, "update", "HMH_IngameWaitingForPlayersState_update", function(self, ...)
		if self._skip_promt_shown and HMH:GetOption("skip_blackscreen") then
			self:_skip()
		end
	end)

elseif string.lower(RequiredScript) == "lib/managers/menu/stageendscreengui" then
	Hooks:PostHook(StageEndScreenGui, "init", "HMH_StageEndScreenGui_init", function(self, ...)
		if self._enabled and managers.hud then
			managers.hud:set_speed_up_endscreen_hud(5)
		end
	end)
	Hooks:PostHook(StageEndScreenGui, "update", "HMH_StageEndScreenGui_update", function(self, t, ...)
		if not self._button_not_clickable and HMH:GetOption("skip_xp") >= 0 and HMH:GetOption("skip_xp") > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + HMH:GetOption("skip_xp"))
			local gsm = game_state_machine:current_state()
			if gsm and gsm._continue_cb and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
				managers.menu_component:post_event("menu_enter")
				gsm._continue_cb()
			end
		end
	end)

	Hooks:OverrideFunction(StageEndScreenGui, "special_btn_pressed", function(self) end)
	Hooks:OverrideFunction(StageEndScreenGui, "special_btn_released", function(self) end)

elseif string.lower(RequiredScript) == "lib/managers/menu/lootdropscreengui" then	
	Hooks:PostHook(LootDropScreenGui, "update", "HMH_LootDropScreenGui_update", function(self, t, ...)
		if not self._card_chosen and HMH:GetOption("pick_card") then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end

		if not self._button_not_clickable and HMH:GetOption("skip_card") >= 0 and HMH:GetOption("skip_card") > 0 then
			self._auto_continue_t = self._auto_continue_t or (t + HMH:GetOption("skip_card"))
			local gsm = game_state_machine:current_state()
			if gsm and not (gsm._continue_blocked and gsm:_continue_blocked()) and t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end)

elseif string.lower(RequiredScript) == "lib/managers/menu/renderers/menunodeskillswitchgui" then
	Hooks:PostHook(MenuNodeSkillSwitchGui, "_create_menu_item", "HMH_MenuNodeSkillSwitchGui_create_menu_item", function(self, row_item, ...)
		if row_item.type~="divider" and row_item.name~="back" then
			local gd=Global.skilltree_manager.skill_switches[row_item.name]
			row_item.status_gui:set_text( managers.localization:to_upper_text( ("menu_st_spec_%d"):format( managers.skilltree:digest_value(gd.specialization, false, 1) or 1 ) ) )
			if row_item.skill_points_gui:text() == managers.localization:to_upper_text("menu_st_points_all_spent_skill_switch") then
				local pts, pt, pp, st, sp=0, 1, 0, 2, 0
				for i=1, #gd.trees do
					pts=Application:digest_value(gd.trees[i].points_spent, false)
					if pts>pp then
						sp, st, pp, pt=pp, pt, pts, i
					elseif pts>sp then
						sp, st=pts, i
					end
				end
				row_item.skill_points_gui:set_text(	managers.localization:to_upper_text( tweak_data.skilltree.trees[pt].name_id	) .." / "..	managers.localization:to_upper_text( tweak_data.skilltree.trees[st].name_id	) )
			end
		elseif row_item.type == "divider" and row_item.name == "divider_title" then
			if alive(row_item.status_gui) then
				row_item.status_gui:set_text(managers.localization:to_upper_text("menu_specialization", {}) .. ":")
			end
		end
	end)

elseif string.lower(RequiredScript) == "lib/managers/menumanagerdialogs" then	
	local show_person_joining_original = MenuManager.show_person_joining
	function MenuManager:show_person_joining( id, nick, ... )
		local peer = managers.network:session():peer(id)
		if peer and HMH:GetOption("show_rank") and not VHUDPlus then
			local level_string, _ = managers.experience:gui_string(peer:level(), peer:rank())
			nick = "(" .. level_string .. ") " .. nick
		end
		return show_person_joining_original(self, id, nick, ...)
	end

elseif string.lower(RequiredScript) == "lib/managers/missionassetsmanager" then	
	if HMH:GetOption("no_confirm") then
		local function expect_yes(self, params) params.yes_func() end
		MenuManager.show_confirm_mission_asset_buy_all = expect_yes
		MenuManager.show_confirm_buy_premium_contract = expect_yes
		MenuManager.show_confirm_blackmarket_buy_mask_slot = expect_yes
		MenuManager.show_confirm_blackmarket_buy_weapon_slot = expect_yes
		MenuManager.show_confirm_mission_asset_buy = expect_yes
		MenuManager.show_confirm_pay_casino_fee = expect_yes
		MenuManager.show_confirm_mission_asset_buy_all = expect_yes
		MenuManager.show_confirm_blackmarket_sell = expect_yes
		MenuManager.show_confirm_blackmarket_mod = expect_yes
	end

elseif string.lower(RequiredScript) == "lib/managers/menu/menuscenemanager" then
    Hooks:PostHook(MenuSceneManager, "_set_up_environments", "HMH_MenuSceneManager_set_up_environments", function(self)
	    if HMH:GetOption("custom_filter") and self._environments and self._environments.standard and self._environments.standard.color_grading then
		    self._environments.standard.color_grading = "color_off"
	    end
    end)
end