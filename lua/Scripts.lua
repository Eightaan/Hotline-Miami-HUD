if _G.IS_VR then 
    return 
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	local set_slot_ready_orig = HUDManager.set_slot_ready
	local update_original = HUDManager.update
	local set_mugshot_voice_orig = HUDManager.set_mugshot_voice
	local set_stamina_value_original = HUDManager.set_stamina_value
	local set_max_stamina_original = HUDManager.set_max_stamina
	local force_ready_clicked = 0

	--Voice Chat
	function HUDManager:set_mugshot_voice(id, active)
	set_mugshot_voice_orig(self, id, active)
	local panel_id
		for _, data in pairs(managers.criminals:characters()) do
			if data.data.mugshot_id == id then
				panel_id = data.data.panel_id
				break
			end
		end
		if HMH:GetOption("voice") and panel_id and panel_id ~= HUDManager.PLAYER_PANEL and not WolfHUD then
			self._teammate_panels[panel_id]:set_voice_com(active)
		end
	end

    --Ping Display
    function HUDManager:update(...)
	    for i, panel in ipairs(self._teammate_panels) do
		    panel:update(...)
	    end
	    return update_original(self, ...)
    end

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
					QuickMenu:new( managers.localization:text("hmh_dialog_force_start_title"), managers.localization:text("hmh_dialog_force_start_desc"), menu_options, true )
				end
			end
		end
	end

    -- Scale Hud
    if HMH:GetOption("hud_scale") ~= 1 then
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
	        if _G.VHUDPlus and _G.VHUDPlus:getSetting({"CustomHUD", "ENABLED"}, true) then
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
	end

-- No Red Lasers
elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then
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

-- Custom Filter
elseif RequiredScript == "lib/managers/menu/menuscenemanager" then
    Hooks:PostHook(MenuSceneManager, "_set_up_environments", "hmh_set_up_environments", function(self)
	    if HMH:GetOption("custom_filter") and self._environments and self._environments.standard and self._environments.standard.color_grading then
		    self._environments.standard.color_grading = "color_off"
	    end
    end)

-- 360 Driving Veiw
elseif RequiredScript == "lib/units/beings/player/states/playerdriving" then
    Hooks:PostHook(PlayerDriving, "_set_camera_limits", "hmh_set_camera_limits", function(self, mode, ...)
		if mode == "driving" then
			self._camera_unit:base():set_limits(180, 20)
		end
    end)

-- Headshoot confirm
elseif RequiredScript == "lib/managers/hud/hudhitconfirm" then
	Hooks:PostHook(HUDHitConfirm, "init", "hmh_HUDHitConfirm_init", function(self, ...)
	    if not VHUDPlus then
		    if self._hud_panel:child("headshot_confirm") then
		    	self._hud_panel:remove(self._hud_panel:child("headshot_confirm"))
		    end
		    self._headshot_confirm = self._hud_panel:bitmap({
				texture = "guis/textures/pd2_mod_hmh/Headshot_confirm",
			    name = "headshot_confirm",
			    halign = "center",
			    visible = false,
			    layer = 1,
			    blend_mode = "normal",
			    valign = "center",
			    color = Color("ff3633")
		    })
		    self._headshot_confirm:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)
	    end
    end)
    
	Hooks:PostHook(HUDHitConfirm, "on_headshot_confirmed", "hmh_on_headshot_confirmed", function(self, ...)
		if not VHUDPlus then
		    self._headshot_confirm:stop()
		    self._headshot_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25, 0.15)
	    end
	end)
	
elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PostHook(PlayerManager, "on_headshot_dealt", "hmh_on_headshot_dealt", function(self, ...)
		if not VHUDPlus then
	        if HMH:GetOption("headshot_mark") then
		        managers.hud:on_headshot_confirmed()
		    end
		end
	end)
end