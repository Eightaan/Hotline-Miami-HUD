if _G.IS_VR then 
	return
end
local Color = Color
local math_lerp = math.lerp

if RequiredScript == "lib/managers/hudmanagerpd2" then
	-- Hud Buffs
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "hmh_bufflist_setup_player_info_hud_pd2", function(self, ...)
		self._hud_buff_list = HUDBuffList:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
	end)

	function HUDManager:update_inspire_timer(buff)
		self._hud_buff_list:update_inspire_timer(buff)
	end
	
	function HUDManager:Set_bloodthirst(buff)
	   self._hud_buff_list:Set_bloodthirst(buff)
	end
	
	HUDBuffList = HUDBuffList or class()
	function HUDBuffList:init()
		if managers.hud ~= nil then

			local Skilltree2 = "guis/textures/pd2/skilltree_2/icons_atlas_2"
			local TimeBackground = "guis/textures/pd2/crimenet_marker_glow"
			
			self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

			self._cooldown_panel = self.hud.panel:panel({
				name = "cooldown_panel",
				x = 0,
				y = 0
			})
			self.cooldown_text = self._cooldown_panel:text({
				layer = 2,
				visible = false,
				text = "",
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
				x = 13,
				y = 25,
				color = Color.white
			})
			self._inspire_cooldown_icon = self._cooldown_panel:bitmap({
				name = "inspire_cooldown_icon",
				texture = Skilltree2,
				texture_rect = { 4* 80, 9 * 80, 80, 80 },
				w = 28,
				h = 28,
				x = 0,
				y = 0,
				color = Color.white,
				visible = false,
				layer = 1
			})
			self._inspire_cooldown_timer_bg = self._cooldown_panel:bitmap({
				name = "inspire_cooldown_timer_bg",
				texture = TimeBackground,
				texture_rect = { 1, 1, 62, 62 }, 
				w = 40,
				h = 40,
				x = 0,
				y = 13,
				color = Color("66ffff"),
				alpha = 0.5,
				visible = false,
				layer = 0
			})
			self._bloodthirst_panel = self.hud.panel:panel({
				name = "bloodthirst_panel",
				x = 0,
				y = 0
			})
			self.bloodthirst_text = self._bloodthirst_panel:text({
				layer = 2,
				visible = false,
				text = "",
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
				x = 12,
				y = 25,
				color = Color.white
			})
			self._bloodthirst_icon = self._bloodthirst_panel:bitmap({
				name = "bloodthirst_icon",
				texture = Skilltree2,
				texture_rect = { 11* 80, 6 * 80, 80, 80 },
				w = 28,
				h = 28,
				x = 0,
				y = 0,
				color = Color.white,
				visible = false,
				layer = 1
			})
			self._bloodthirst_bg = self._bloodthirst_panel:bitmap({
				name = "bloodthirst_bg",
				texture = TimeBackground,
				texture_rect = { 1, 1, 62, 62 }, 
				w = 37,
				h = 37,
				x = 0,
				y = 15,
				color = Color("66ffff"),
				alpha = 0.5,
				visible = false,
				layer = 0
			})
		end
	end
	
	function HUDBuffList:update_timer_visibility_and_position()
		local inspire_visible = HMH:GetOption("inspire")
		self.cooldown_text:set_visible(inspire_visible)
		self._inspire_cooldown_timer_bg:set_visible(inspire_visible)
		self._inspire_cooldown_icon:set_visible(inspire_visible)

		local pos_x = 10 * (HMH:GetOption("timer_x") or 0)
		local pos_y = 10 * (HMH:GetOption("timer_y") or 0)
		self._cooldown_panel:set_x(pos_x)
		self._cooldown_panel:set_y(pos_y)
	end

	function HUDBuffList:update_inspire_timer(duration)
		local timer = self.cooldown_text
		local timer_bg = self._inspire_cooldown_timer_bg
		local icon = self._inspire_cooldown_icon

		timer:set_alpha(1)
		timer_bg:set_alpha(0.5)
		icon:set_alpha(1)

		if duration and duration > 1 then
			timer:stop()
			timer:animate(function(o)
				local t_left = duration
				self:update_timer_visibility_and_position()
				
				while t_left >= 0 do
					if t_left <= 0.1 then
						self:fade_out("inspire")
						return
					end
					t_left = t_left - coroutine.yield()
					o:set_text(string.format(t_left < 9.9 and "%.1f" or "%.f", t_left))
					self:update_timer_visibility_and_position()
					o:set_color(HMH:GetColor("InspireTimer") or Color.white)
					icon:set_color(HMH:GetColor("InspireIcon") or Color.white)
					timer_bg:set_color(HMH:GetColor("InspireTimer") or Color("66ffff"))
				end
			end)
		end
	end
	
	function HUDBuffList:fade_out(buff_type)
		local start_time = os.clock()
		local text, bg, icon
		local duration

		if buff_type == "inspire" then
			text = self.cooldown_text
			bg = self._inspire_cooldown_timer_bg
			icon = self._inspire_cooldown_icon
			duration = 0.1  -- Fade out duration for Inspire
		elseif buff_type == "bloodthirst" then
			text = self.bloodthirst_text
			bg = self._bloodthirst_bg
			icon = self._bloodthirst_icon
			duration = 0.3  -- Fade out duration for Bloodthirst
		end

		if text and bg and icon then
			text:animate(function()
				while true do
					local alpha = math.max(1 - (os.clock() - start_time) / duration, 0)
					text:set_alpha(alpha)
					bg:set_alpha(0.5 * alpha)
					icon:set_alpha(alpha)

					if alpha <= 0 then
						icon:set_visible(false)
						bg:set_visible(false)
						text:set_text("")
						break
					end

					coroutine.yield()
				end
			end)
		end
	end
	
	function HUDBuffList:update_bloodthirst_position()
		local panel = self._bloodthirst_panel
		local x_position = 10 * (HMH:GetOption("BloodthirstX") or 0)
		local y_position = 10 * (HMH:GetOption("BloodthirstY") or 0)
		panel:set_x(x_position)
		panel:set_y(y_position)
	end

	function HUDBuffList:Set_bloodthirst(buff)
		local bloodthirst_text = self.bloodthirst_text
		local bloodthirst_icon = self._bloodthirst_icon
		local bloodthirst_timer_bg = self._bloodthirst_bg
		
		bloodthirst_text:set_alpha(1)
		bloodthirst_icon:set_alpha(1)
		bloodthirst_timer_bg:set_alpha(0.5)
		
		if buff >= HMH:GetOption("BloodthirstMinKills") and HMH:GetOption("Bloodthirst") then
			bloodthirst_text:set_visible(true)
			bloodthirst_icon:set_visible(true)
			bloodthirst_timer_bg:set_visible(true)
			self:update_bloodthirst_position()
			bloodthirst_timer_bg:set_color(HMH:GetColor("BloodthirstText") or Color("66ffff"))
			bloodthirst_text:set_color(HMH:GetColor("BloodthirstText") or Color.white)
			bloodthirst_icon:set_color(HMH:GetColor("BloodthirstIcon") or Color.white)
			bloodthirst_text:set_text(managers.localization:to_upper_text("HMH_bloodthirst_multiplier", { NUM = buff }).."x")
			bloodthirst_text:animate(function(o)
				over(1 , function(p)
					local n = 1 - math.sin((p / 2 ) * 180)
					o:set_font_size(math_lerp(16, 16 * 1.16 , n))
				end)
			end)
		else
			self:fade_out("bloodthirst")
		end
	end
	
	-- Stamina Circle
	Hooks:PostHook(HUDManager, "set_stamina_value", "HMH_HUDManager_set_stamina_value", function (self, value, ...)
		if HMH:GetOption("stamina") and self._teammate_panels[self.PLAYER_PANEL].set_stamina_current then --VHUDPlus Compatibility
			self._teammate_panels[self.PLAYER_PANEL]:set_stamina_current(value)
		elseif self._teammate_panels[self.PLAYER_PANEL].set_stamina_visibility then --VHUDPlus Compatibility
			self._teammate_panels[self.PLAYER_PANEL]:set_stamina_visibility(false)
		end
	end)

	Hooks:PostHook(HUDManager, "set_max_stamina", "HMH_HUDManager_set_max_stamina", function (self, value, ...)
		if HMH:GetOption("stamina") and self._teammate_panels[self.PLAYER_PANEL] then --VHUDPlus Compatibility
			self._teammate_panels[self.PLAYER_PANEL]:set_stamina_max(value)
		end
	end)
	
	--Infinite Ammo Display
	function HUDManager:set_infinite_ammo(state)
		if self._teammate_panels[self.PLAYER_PANEL]._set_infinite_ammo then
			self._teammate_panels[self.PLAYER_PANEL]:_set_infinite_ammo(state)		
		end
		-- Hides the bulletstorm display used by VHUDPlus		
		if self._teammate_panels[self.PLAYER_PANEL]._set_bulletstorm then
			self._teammate_panels[self.PLAYER_PANEL]:_set_bulletstorm(false)
		end
	end
	
	--Captain Winters Buff
	function HUDManager:set_vip_text(buff)
		if self._hud_assault_corner.set_vip_text then
			self._hud_assault_corner:set_vip_text(buff)
		end
	end
	
	--Ping Display
	Hooks:PostHook(HUDManager, "update", "HMH_HUDManager_update", function (self, ...)
		for i, panel in ipairs(self._teammate_panels) do
			panel:update(...)
		end
	end)
	
	--VHUDPlus Compatibility
	if HMH:GetOption("assault") then
		Hooks:PostHook(HUDManager, "show_casing", "HMH_HUDManager_show_casing", function (self, ...)
			if self._hud_heist_timer._heist_timer_panel then
				self._hud_heist_timer._heist_timer_panel:set_visible(true)
			end
		end)
		Hooks:PostHook(HUDManager, "sync_start_assault", "HMH_HUDManager_sync_start_assault", function (self, ...)
			if self._hud_heist_timer._heist_timer_panel then
				self._hud_heist_timer._heist_timer_panel:set_visible(true)
			end
		end)
	end
	
	--Swansong and Kingpin Screen Effects
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

elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "HMH_PlayerManager_activate_temporary_upgrade_armor_timer", function (self, category, upgrade)
		if upgrade == "armor_break_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
				if HMH:GetOption("armorer_cooldown_radial") and HMH:GetOption("armorer_cooldown_timer") and teammate_panel.update_cooldown_timer then
					teammate_panel:update_cooldown_timer(upgrade_value[2])
				end
				if HMH:GetOption("armorer_cooldown_radial") and teammate_panel.animate_invulnerability then
					teammate_panel:animate_invulnerability(upgrade_value[1])
				end
			end
		end
		if upgrade == "mrwi_health_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
				if HMH:GetOption("armorer_cooldown_radial") and HMH:GetOption("armorer_cooldown_timer") and teammate_panel.health_cooldown_timer then
					teammate_panel:health_cooldown_timer(2)
				end
				if HMH:GetOption("armorer_cooldown_radial") and teammate_panel.animate_health_invulnerability then
					teammate_panel:animate_health_invulnerability(2)
				end
			end
		end
	end)

	function PlayerManager:_clbk_bulletstorm_expire()
		self._infinite_ammo_clbk = nil
		managers.hud:set_infinite_ammo(false)

		if managers.player and managers.player:player_unit() and managers.player:player_unit():inventory() then
			for id, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end
	end

	Hooks:PostHook(PlayerManager, "add_to_temporary_property", "HMH_PlayerManager_add_to_temporary_property", function (self, name, time, value, ...)
		if HMH:GetOption("bulletstorm") and name == "bullet_storm" and time then
			if not self._infinite_ammo_clbk then
				self._infinite_ammo_clbk = "infinite"
				managers.hud:set_infinite_ammo(true)
				managers.enemy:add_delayed_clbk(self._infinite_ammo_clbk, callback(self, self, "_clbk_bulletstorm_expire"), TimerManager:game():time() + time)
			end
		end
	end)
	
	Hooks:PostHook(PlayerManager, "disable_cooldown_upgrade", "HMH_PlayerManager_disable_cooldown_upgrade", function (self, category, upgrade)
		local upgrade_value = self:upgrade_value(category, upgrade)
		if upgrade_value and upgrade_value[1] ~= 0 and HMH:GetOption("inspire") then
			managers.hud:update_inspire_timer(upgrade_value[2])
		end
	end)
	
	Hooks:PostHook(PlayerManager, 'set_melee_dmg_multiplier', "HMH_update_Bloodthirst", function(self, ...)
		if not self:has_category_upgrade("player", "melee_damage_stacking") then return end
		if self._melee_dmg_mul ~= 1 then
			managers.hud:Set_bloodthirst(self._melee_dmg_mul)
		end
	end)

elseif RequiredScript == "lib/managers/hud/hudteammate" then	
	Hooks:PostHook(HUDTeammate, "init", "HMH_Stamina_init", function (self, ...)
		if self._main_player then
			self:_create_circle_stamina()
		end
	end)
	
	Hooks:PostHook(HUDTeammate, "set_custom_radial", "HMH_HUDTeammate_set_custom_radial", function (self, data, ...)
		local duration = data.current / data.total
		local aced = managers.player:upgrade_level("player", "berserker_no_ammo_cost", 0) == 1
		if self._main_player and HMH:GetOption("bulletstorm") and aced then
			if duration > 0 then
				managers.hud:set_infinite_ammo(true)
			else
				managers.hud:set_infinite_ammo(false)
			end
		end
		
		if self._main_player and self._cooldown_timer then
			if duration > 0 then
				self._cooldown_timer:set_visible(false)
				self._cooldown_health_timer:set_visible(false)
				self._cooldown_icon:set_visible(false)
				self._health_cooldown_icon:set_visible(false)
				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(0)
					self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
				end
			else
				self._cooldown_timer:set_visible(self._armor_invulnerability_timer)
				self._cooldown_health_timer:set_visible(self._health_timer)
				self._cooldown_icon:set_visible(self._armor_invulnerability_timer and not self._health_timer)
				self._health_cooldown_icon:set_visible(self._health_timer)
				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(1)
					self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
				end
			end
		end
	end)
	
	Hooks:PostHook(HUDTeammate, "_create_condition", "HMH_HUDTeammate_create_condition", function (self, ...)
		self._health_panel = self._health_panel or self._player_panel:child("radial_health_panel")
		if self._main_player then
			self._cooldown_timer = self._health_panel:text({
				name = "cooldown_timer",
				text = "",
				color = Color.white,
				visible = false,
				align = "center",
				vertical = "center",
				y = 10,
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
				alpha = 1,
				layer = 4
			})
			self._cooldown_health_timer = self._health_panel:text({
				name = "cooldown_health_timer",
				text = "",
				color = Color.white,
				visible = false,
				align = "center",
				vertical = "center",
				y = -4,
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
				alpha = 1,
				layer = 4
			})
			self._cooldown_icon = self._health_panel:bitmap({
				name = "cooldown_icon",
				texture = "guis/dlcs/opera/textures/pd2/specialization/icons_atlas",
				texture_rect = {0, 0, 64, 64},
				valign = "center",
				x = 14,
				y = 15,
				w = 40,
				h = 40,
				color = HMH:GetColor("Ability_icon_color") or Color.white,
				visible = false,
				align = "center",
				alpha = 0.4,
				layer = 3
			})
			self._health_cooldown_icon = self._health_panel:bitmap({
				name = "health_cooldown_icon",
				texture = "guis/textures/pd2_mod_hmh/health_cooldown_icon",
				valign = "center",
				x = 9.5,
				y = 19,
				w = 48,
				h = 29,
				color = HMH:GetColor("Ability_icon_color") or Color.white,
				visible = false,
				align = "center",
				alpha = 0.4,
				layer = 3
			})
		end
	end)
	
	function HUDTeammate:_create_circle_stamina()
		local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
		self._stamina_circle = radial_health_panel:bitmap({
			name = "radial_stamina",
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
			render_template = "VertexColorTexturedRadial",
			w = radial_health_panel:w() * 0.7,
			h = radial_health_panel:h() * 0.7,
			visible = true,
			layer = 3,
		})
		self._stamina_circle:set_center(radial_health_panel:child("radial_health"):center())
	end

	Hooks:PreHook(HUDTeammate, "_create_radial_health", "HMH_Ability_create_radial_health", function (self, radial_health_panel)
		self._radial_health_panel = radial_health_panel
		local radial_armor = radial_health_panel:bitmap({
			texture = "guis/textures/pd2/hud_swansong",
			name = "radial_armor",
			blend_mode = "add",
			visible = false,
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
		local animate_health_circle = radial_health_panel:bitmap({
			texture = "guis/textures/pd2_mod_hmh/animate_health_circle",
			name = "animate_health_circle",
			blend_mode = "add",
			visible = false,
			render_template = "VertexColorTexturedRadial",
			layer = 5,
			color = Color(1, 0, 0, 0),
			w = radial_health_panel:w(),
			h = radial_health_panel:h()
		})
	end)

	function HUDTeammate:update_cooldown_timer(t)
		local timer = self._cooldown_timer
		if t and t > 1 and timer then
			timer:stop()
			if self._stamina_circle then
				self._stamina_circle:set_alpha(0)
			end
			timer:animate(function(o)
				o:set_visible(true)
				local t_left = t
				local health_icon = self._health_cooldown_icon 
				local armor_icon = self._cooldown_icon 
				while t_left >= 0.1 do
					self._armor_invulnerability_timer = true
					t_left = t_left - coroutine.yield()
					t_format = t_left < 9.9 and "%.1f" or "%.f"
					o:set_text(string.format(t_format, t_left))
					o:set_color(HMH:GetColor("armorer_cooldown_timer_color2") or Color.red)
				end
				self._armor_invulnerability_timer = false
				o:set_visible(false)
				armor_icon:set_visible(false)
				health_icon:set_visible(self._health_timer)
				self._stamina_circle:set_alpha(not self._health_timer and 1 or 0)
			end)
		end
	end

	function HUDTeammate:animate_invulnerability(duration)
		if not self._radial_health_panel:child("radial_armor") then return end
		self._radial_health_panel:child("radial_armor"):animate(function (o)
			local armor_icon = self._cooldown_icon 
			o:set_color(Color(1, 1, 1, 1))
			self._stamina_circle:set_alpha(0)
			self._armor_invulnerability_timer = true
			armor_icon:set_visible(self._armor_invulnerability_timer and not self._health_timer)
			armor_icon:set_alpha(not HMH:GetOption("armorer_cooldown_timer") and 1 or 0.4)
			o:set_visible(true)
			over(duration, function (p)
				o:set_color(Color(1, 1 - p, 1, 1))
			end)
			if not HMH:GetOption("armorer_cooldown_timer") then 
				self._stamina_circle:set_alpha(1) 
				self._armor_invulnerability_timer = false
				armor_icon:set_visible(self._armor_invulnerability_timer)
			end
			o:set_visible(false)
		end)
	end
	
	function HUDTeammate:health_cooldown_timer(t)
		local timer = self._cooldown_health_timer
		if t and t > 1 and timer then
			timer:stop()
			if self._stamina_circle then
				self._stamina_circle:set_alpha(0)
			end
			timer:animate(function(o)
				o:set_visible(true)
				local t_left = t + 13
				local health_icon = self._health_cooldown_icon
				local armor_icon = self._cooldown_icon				
				while t_left >= 0.1 do
					self._health_timer = true
					t_left = t_left - coroutine.yield()
					t_format = t_left < 9.9 and "%.1f" or "%.f"
					o:set_text(string.format(t_format, t_left))
					o:set_color(HMH:GetColor("armorer_duration_timer_color") or Color.green)
				end
				self._health_timer = false
				armor_icon:set_visible(self._armor_invulnerability_timer)
				o:set_visible(false)
				health_icon:set_visible(self._health_timer)
				self._stamina_circle:set_alpha(not self._armor_invulnerability_timer and 1 or 0)
			end)
		end
	end
	
	function HUDTeammate:animate_health_invulnerability(duration)
		if not self._radial_health_panel:child("animate_health_circle") then return end
		self._radial_health_panel:child("animate_health_circle"):animate(function (o)
			local health_icon = self._health_cooldown_icon
			local armor_icon = self._cooldown_icon
			o:set_color(Color(1, 1, 1, 1))
			self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
			self._stamina_circle:set_alpha(0)
			self._health_timer = true
			armor_icon:set_visible(not self._health_timer)
			health_icon:set_visible(self._health_timer)
			health_icon:set_alpha(not HMH:GetOption("armorer_cooldown_timer") and 1 or 0.4)
			o:set_visible(true)
			over(duration, function (p)
				o:set_color(Color(1, 1 - p, 1, 1))
			end)
			o:set_visible(false)
			if not HMH:GetOption("armorer_cooldown_timer") then
				if not (self._armor_invulnerability_timer or self._injector_active or self._active_ability) then
					self._stamina_circle:set_alpha(1)
				end
				self._health_timer = false
				health_icon:set_visible(self._health_timer)
				armor_icon:set_visible(self._armor_invulnerability_timer)
			end
			o:set_visible(false)
		end)
	end

	function HUDTeammate:set_stamina_max(value)
		if not self._max_stamina or self._max_stamina ~= value then
			self._max_stamina = value
		end
		-- Hides the stamina display used by VHUDPlus
		if self._stamina_bar and self._stamina_line then
			self._stamina_bar:set_alpha(0)
			self._stamina_line:set_alpha(0)
		end
	end

	function HUDTeammate:set_stamina_current(value)
		if self._stamina_circle then
			self._stamina_circle:set_color(Color(1, value/self._max_stamina, 0, 0))
			self:set_stamina_visibility(not self._condition_icon:visible())
		end
	end

	function HUDTeammate:set_stamina_visibility(value)
		if self._stamina_circle and self._stamina_circle:visible() ~= value then
			self._stamina_circle:set_visible(value)
		end
	end

	Hooks:PostHook(HUDTeammate, "set_condition", "HMH_HUDTeammate_set_condition", function (self, icon_data, ...)
		local custody = icon_data ~= "mugshot_normal"
		self:set_stamina_visibility(not custody and HMH:GetOption("stamina"))
		local timer = self._cooldown_timer
		local health_timer = self._cooldown_health_timer
		local icon = self._cooldown_icon
		local health_icon = self._health_cooldown_icon
		if self._main_player and timer then
			timer:set_alpha(custody and 0 or 1)
			health_timer:set_alpha(custody and 0 or 1)
			icon:set_visible(not custody and self._armor_invulnerability_timer and not self._health_timer)
			health_icon:set_visible(not custody and self._health_timer)
		end
	end)
	
	Hooks:PostHook(HUDTeammate, "set_ability_radial", "HMH_HUDTeammate_set_ability_radial", function (self, data, ...)
		local progress = data.current / data.total
		if self._main_player then
			local stamina_alpha = self._health_timer and 0 or 1
			if self._stamina_circle and HMH:GetOption("ability_icon") then
				self._stamina_circle:set_alpha(progress > 0 and 0 or stamina_alpha) 
			end
			if self._radial_health_panel:child("animate_health_circle") then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(progress > 0 and 0 or 1)
			end
			if progress > 0 then
				self._injector_active = true
				self._health_cooldown_icon:set_visible(false)
				self._cooldown_health_timer:set_visible(false)
			else
				self._injector_active = false
				self._cooldown_health_timer:set_visible(HMH:GetOption("armorer_cooldown_timer") and self._health_timer)
				self._health_cooldown_icon:set_visible(self._health_timer)
			end
		end
	end)

	Hooks:PostHook(HUDTeammate, "activate_ability_radial", "HMH_HUDTeammate_activate_ability_radial", function (self, time_left, ...)
		self._radial_health_panel:child("radial_custom"):animate(function (o)
			over(time_left, function (p)
				if self._main_player then
					if HMH:GetOption("ability_icon") then
						self._stamina_circle:set_alpha(0)
					end
					self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
					self._health_cooldown_icon:set_visible(false)
					self._cooldown_health_timer:set_visible(false)
					self._active_ability = true
				end
			end)
			if not self._health_timer then
				self._stamina_circle:set_alpha(1) 
			end
			self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
			self._cooldown_health_timer:set_visible(HMH:GetOption("armorer_cooldown_timer") and self._health_timer)
			self._health_cooldown_icon:set_visible(self._health_timer)
			self._active_ability = false
		end)
	end)
end