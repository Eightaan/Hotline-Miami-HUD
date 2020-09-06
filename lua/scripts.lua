if RequiredScript == "lib/managers/hudmanagerpd2" then
	local set_teammate_ammo_amount_orig = HUDManager.set_teammate_ammo_amount
	local set_slot_ready_orig = HUDManager.set_slot_ready
	local force_ready_clicked = 0

	--Screen Effects
	local custom_radial = HUDManager.set_teammate_custom_radial
	function HUDManager:set_teammate_custom_radial(i, data)
		local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		if not hud.panel:child("swan_song_left") then
			local swan_song_left = hud.panel:bitmap({
				name = "swan_song_left",
				visible = false,
				texture = "guis/textures/pd2_mod_hmh/screeneffect",
				layer = 0,
				color = Color(0, 0.7, 1),
				blend_mode = "add",
				w = hud.panel:w(),
				h = hud.panel:h(),
				x = 0,
				y = 0 
			})
		end
		local swan_song_left = hud.panel:child("swan_song_left")
		if i == 4 and data.current < data.total and data.current > 0 and swan_song_left then
			swan_song_left:set_visible(HMH:GetOption("screen_effect"))
			local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			swan_song_left:animate(hudinfo.flash_icon, 4000000000)
		elseif hud.panel:child("swan_song_left") then
			swan_song_left:stop()
			swan_song_left:set_visible(false)
		end
		if swan_song_left and data.current == 0 then
			swan_song_left:set_visible(false)
		end
		return custom_radial(self, i, data)
	end

	local ability_radial = HUDManager.set_teammate_ability_radial
	function HUDManager:set_teammate_ability_radial(i, data)
		local hud = managers.hud:script( PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)
		if not hud.panel:child("chico_injector_left") then
			local chico_injector_left = hud.panel:bitmap({
				name = "chico_injector_left",
				visible = false,
				texture = "guis/textures/pd2_mod_hmh/screeneffect",
				layer = 0,
				color = Color(1, 0.6, 0),
				blend_mode = "add",
				w = hud.panel:w(),
				h = hud.panel:h(),
				x = 0,
				y = 0 
			})
		end
		local chico_injector_left = hud.panel:child("chico_injector_left")
		if i == 4 and data.current < data.total and data.current > 0 and chico_injector_left then
			chico_injector_left:set_visible(HMH:GetOption("screen_effect"))
			local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			chico_injector_left:animate(hudinfo.flash_icon, 4000000000)
		elseif hud.panel:child("chico_injector_left") then
			chico_injector_left:stop()
			chico_injector_left:set_visible(false)
		end
		if chico_injector_left and data.current == 0 then
			chico_injector_left:set_visible(false)
		end
		return ability_radial(self, i, data)
	end

    -- Real Ammo
    function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max, ...)
	    if HMH:GetOption("trueammo") and not (VHUDPlus and VHUDPlus:getSetting({"CustomHUD", "USE_REAL_AMMO"}, true)) then
		    local total_left = current_left - current_clip
		    if total_left >= 0 then
			    current_left = total_left
			    max = max - current_clip
		    end
	    end
	    return set_teammate_ammo_amount_orig(self, id, selection_index, max_clip, current_clip, current_left, max, ...)
    end

	-- Force Start
	function HUDManager:set_slot_ready(peer, peer_id, ...)
		set_slot_ready_orig(self, peer, peer_id, ...)

		if not VHUDPlus and Network:is_server() and not Global.game_settings.single_player then
			local session = managers.network and managers.network:session()
			local local_peer = session and session:local_peer()
			if local_peer and local_peer:id() == peer_id then
				force_ready_clicked = force_ready_clicked + 1
				if game_state_machine and force_ready_clicked >= 3 then
					local menu_options = {
						[1] = {
							text = managers.localization:text("dialog_yes"),
							callback = function(self, item)
							    game_state_machine:current_state():start_game_intro()
						    end,
						},
						[2] = {
							text = managers.localization:text("dialog_no"),
							is_cancel_button = true,
						}
					}
					QuickMenu:new( "Force start game?", "Are you sure you want to force the game to start?", menu_options, true )
				end
			end
		end
	end

	-- Scale Hud
	Hooks:PreHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_hudmamanger_setup_player_info_hud_pd2", function(self)
        managers.gui_data:layout_scaled_fullscreen_workspace(managers.hud._saferect)
    end)

    function HUDManager:recreate_player_info_hud_pd2()
	    if not self:alive(PlayerBase.PLAYER_INFO_HUD_PD2) then return end

		local hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
	    self:_create_present_panel(hud)
	    self:_create_interaction(hud)
	    self:_create_progress_timer(hud)
	    self:_create_objectives(hud)
	    self:_create_hint(hud)
	    self:_create_heist_timer(hud)
	    self:_create_temp_hud(hud)
	    self:_create_suspicion(hud)
	    self:_create_hit_confirm(hud)
	    self:_create_hit_direction(hud)
	    self:_create_downed_hud()
	    self:_create_custody_hud()
	    self:_create_waiting_legend(hud)
    end

    core:module("CoreGuiDataManager")
    function GuiDataManager:layout_scaled_fullscreen_workspace(ws)
	    local scale
	    if _G.VHUDPlus then
		    scale = _G.VHUDPlus:getSetting({"CustomHUD", "HUD_SCALE"}, 1)
	    else
		    scale = _G.HMH:GetOption("hud_scale")
	    end

	    local base_res = {x = 1280, y = 720}
	    local res = RenderSettings.resolution
	    local sc = (2 - scale)
	    local aspect_width = base_res.x / self:_aspect_ratio()
	    local h = math.round(sc * math.max(base_res.y, aspect_width))
	    local w = math.round(sc * math.max(base_res.x, aspect_width / h))
	    local safe_w = math.round(0.95 * res.x)
	    local safe_h = math.round(0.95 * res.y)   
	    local sh = math.min(safe_h, safe_w / (w / h))
	    local sw = math.min(safe_w, safe_h * (w / h))
	    local x = res.x / 2 - sh * (w / h) / 2
        local y = res.y / 2 - sw / (w / h) / 2

		ws:set_screen(w, h, x, y, math.min(sw, sh * (w / h)))
    end

elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then
    -- No Red Lasers
    function UnitNetworkHandler:set_weapon_gadget_color(unit, red, green, blue, sender)
	    if not self._verify_character_and_sender(unit, sender) then
		    return
	    end

	    if red and green and blue then 
		    local threshold = 0.66
		    if red * threshold > green + blue then
			    red = 1
			    green = 51
			    blue = 1
		    end
	    end
	    unit:inventory():sync_weapon_gadget_color(Color(red / 255, green / 255, blue / 255))
    end

elseif RequiredScript == "lib/units/beings/player/states/playerstandard" then
    local PlayerStandard__check_action_interact_original = PlayerStandard._check_action_interact
    -- Toggle Interaction
	function PlayerStandard:_check_action_interact(t, input)
		local interrupt_key_press = input.btn_interact_press
		if HMH:GetOption("interupt_interact") and not VHUDPlus then
			interrupt_key_press = input.btn_use_item_press
		end

		if not VHUDPlus and interrupt_key_press and self:_interacting() then
			self:_interupt_action_interact()
			return false
		elseif input.btn_interact_release and self._interact_params and HMH:GetOption("toggle_interact") > 0 and not VHUDPlus then
			if self._interact_params.timer >= HMH:GetOption("toggle_interact") then
				return false
			end
		end
		return PlayerStandard__check_action_interact_original(self, t, input)
	end

elseif RequiredScript == "lib/managers/menu/stageendscreengui" then
    -- Skip and Autoselect
	local update_original = StageEndScreenGui.update

	function StageEndScreenGui:update(t, ...)
		update_original(self, t, ...)
		
		if not self._button_not_clickable and HMH:GetOption("skip_xp") >= 0 and HMH:GetOption("skip_xp") > 0 and not VHUDPlus then
			self._auto_continue_t = self._auto_continue_t or (t + HMH:GetOption("skip_xp"))
			if t >= self._auto_continue_t then
				managers.menu_component:post_event("menu_enter")
				game_state_machine:current_state()._continue_cb()
			end
		end
	end

elseif RequiredScript == "lib/managers/menu/lootdropscreengui" then

	local update_original = LootDropScreenGui.update

	function LootDropScreenGui:update(t, ...)
		update_original(self, t, ...)

		if not self._card_chosen and HMH:GetOption("pick_card") and not VHUDPlus then
			self:_set_selected_and_sync(math.random(3))
			self:confirm_pressed()
		end
		
		if not self._button_not_clickable and HMH:GetOption("skip_card") >= 0 and HMH:GetOption("skip_card") > 0 and not VHUDPlus then
			self._auto_continue_t = self._auto_continue_t or (t + HMH:GetOption("skip_card"))
			if t >= self._auto_continue_t then
				self:continue_to_lobby()
			end
		end
	end

elseif RequiredScript == "lib/states/ingamewaitingforplayers" then
	local update_original = IngameWaitingForPlayersState.update
	
	function IngameWaitingForPlayersState:update(...)
		update_original(self, ...)
		
		if self._skip_promt_shown and HMH:GetOption("skip_blackscreen") and not VHUDPlus then
			self:_skip()
		end
	end

elseif RequiredScript == "lib/managers/menu/blackmarketgui" then
	local function getEquipmentAmount(name_id)
		local data = tweak_data.equipments[name_id]
		if not (VHUDPlus or WolfHUD) and data and data.quantity then
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

	local populate_deployables_original = BlackMarketGui.populate_deployables
	function BlackMarketGui:populate_deployables(data, ...)
		populate_deployables_original(self, data, ...)
		if not (VHUDPlus or WolfHUD) then
		    for i, equipment in ipairs(data) do
			    equipment.name_localized = equipment.name_localized .. (equipment.unlocked and getEquipmentAmount(equipment.name) or "")
		    end
		end	
	end

	local populate_grenades_original = BlackMarketGui.populate_grenades
	function BlackMarketGui:populate_grenades(data, ...)
		populate_grenades_original(self, data, ...)
		if not (VHUDPlus or WolfHUD) then
		    local t_data = tweak_data.blackmarket.projectiles
		    for i, throwable in ipairs(data) do
			    local has_amount = throwable.unlocked and t_data[throwable.name] or false
			    throwable.name_localized = throwable.name_localized .. (has_amount and " (x" .. t_data[throwable.name].max_amount .. ")" or "")
		    end
	    end
    end
end