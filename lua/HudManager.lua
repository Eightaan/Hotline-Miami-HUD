local HMH = HMH
local Color = Color

if RequiredScript == "lib/managers/hudmanagerpd2" then

	Hooks:PostHook(HUDManager, "update", "HMH_HUDManager_update", function (self, ...)
		for i, panel in ipairs(self._teammate_panels) do
			panel:update(...)
		end
	end)

	Hooks:PostHook(HUDManager, "set_teammate_custom_radial", "HMH_HUDManager_set_teammate_custom_radial", function (self, i, data, ...)
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
			local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			swan_song_left:set_visible(HMH:GetOption("screen_effect"))
			swan_song_left:animate(hudinfo.flash_icon, 4000000000)
		elseif hud.panel:child("swan_song_left") then
			swan_song_left:stop()
			swan_song_left:set_visible(false)
		end

		if swan_song_left and data.current == 0 then
			swan_song_left:set_visible(false)
		end
	end)

	Hooks:PostHook(HUDManager, "set_teammate_ability_radial", "HMH_HUDManager_set_teammate_ability_radial", function (self, i, data, ...)
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
			local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
			chico_injector_left:set_visible(HMH:GetOption("screen_effect"))
			chico_injector_left:animate(hudinfo.flash_icon, 4000000000)
		elseif hud.panel:child("chico_injector_left") then
			chico_injector_left:stop()
			chico_injector_left:set_visible(false)
		end

		if chico_injector_left and data.current == 0 then
			chico_injector_left:set_visible(false)
		end
	end)

elseif RequiredScript == "lib/managers/hud/hudhitconfirm" then
	Hooks:PostHook(HUDHitConfirm, "init", "HMH_HUDHitConfirm_init", function(self, ...)
		if self._hud_panel:child("headshot_confirm") then
			self._hud_panel:remove(self._hud_panel:child("headshot_confirm"))
		end

		local headshot_icon = HMH:GetOption("headshot_texture") == 3 and "guis/textures/pd2_mod_hmh/Headshot_confirm_blessings" or HMH:GetOption("headshot_texture") == 4 and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2_mod_hmh/Headshot_confirm"
		self._headshot_confirm = self._hud_panel:bitmap({
			texture = headshot_icon,
			name = "headshot_confirm",
			halign = "center",
			visible = false,
			layer = 1,
			blend_mode = "normal",
			valign = "center",
			color = Color("ff3633")
		})
		self._headshot_confirm:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)
	end)
	
	Hooks:PostHook(HUDHitConfirm, "on_headshot_confirmed", "HMH_HUDHitConfirm_on_headshot_confirmed", function(self, ...)
		if HMH:GetOption("headshot_texture") > 1 then
			self._headshot_confirm:stop()
			self._headshot_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25, 0.15)
		end
	end)
	
elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PostHook(PlayerManager, "on_headshot_dealt", "HMH_PlayerManager_on_headshot_dealt", function(self, ...)
		managers.hud:on_headshot_confirmed()
	end)
end