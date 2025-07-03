if _G.IS_VR then 
	return
end

local HMH = HMH
local Color = Color

if RequiredScript == "lib/managers/hudmanagerpd2" then
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

	function HUDManager:animate_invulnerability(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._animate_invulnerability then
			self._teammate_panels[self.PLAYER_PANEL]:_animate_invulnerability(duration)		
		end
	end

	function HUDManager:update_cooldown_timer(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._update_cooldown_timer then
			self._teammate_panels[self.PLAYER_PANEL]:_update_cooldown_timer(duration)		
		end
	end

	function HUDManager:health_cooldown_timer(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._health_cooldown_timer then
			self._teammate_panels[self.PLAYER_PANEL]:_health_cooldown_timer(duration)		
		end
	end

	function HUDManager:animate_health_invulnerability(duration)
		if self._teammate_panels[self.PLAYER_PANEL]._animate_health_invulnerability then
			self._teammate_panels[self.PLAYER_PANEL]:_animate_health_invulnerability(duration)		
		end
	end	

elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "HMH_PlayerManager_activate_temporary_upgrade_armor_timer", function (self, category, upgrade)
		if upgrade == "armor_break_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if HMH:GetOption("armorer_cooldown_radial") and HMH:GetOption("armorer_cooldown_timer") then
				managers.hud:update_cooldown_timer(upgrade_value[2])
			end
			if HMH:GetOption("armorer_cooldown_radial") then
				managers.hud:animate_invulnerability(upgrade_value[1])
			end
		end
		if upgrade == "mrwi_health_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end		
			if HMH:GetOption("armorer_cooldown_radial") and HMH:GetOption("armorer_cooldown_timer") then
				managers.hud:health_cooldown_timer(2)
			end
			if HMH:GetOption("armorer_cooldown_radial") then
				managers.hud:animate_health_invulnerability(2)
			end
		end
	end)


elseif RequiredScript == "lib/managers/hud/hudteammate" then	
	Hooks:PostHook(HUDTeammate, "init", "HMH_Stamina_init", function (self, ...)
		if self._main_player then
			self:_create_circle_stamina()
		end
		self._invulnerability = false
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
		
		if self._main_player and self._cooldown_timer and self._invulnerability then
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
				texture = "pd2_mod_hmh/health_cooldown_icon",
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

	Hooks:PreHook(HUDTeammate, "_create_radial_health", "HMH_create_radial_health", function (self, radial_health_panel)
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
				texture = "pd2_mod_hmh/animate_health_circle",
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

	function HUDTeammate:_update_cooldown_timer(t)
		local timer = self._cooldown_timer
		if t and t > 1 and timer then
			self._invulnerability = true
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

	function HUDTeammate:_animate_invulnerability(duration)
		if not self._radial_health_panel:child("radial_armor") then return end
		self._invulnerability = true
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
	
	function HUDTeammate:_health_cooldown_timer(t)
		local timer = self._cooldown_health_timer
		if t and t > 1 and timer then
			self._invulnerability = true
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
	
	function HUDTeammate:_animate_health_invulnerability(duration)
		if not self._radial_health_panel:child("animate_health_circle") then return end
		self._invulnerability = true
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
		if self._main_player and timer and self._invulnerability then
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
			if self._radial_health_panel:child("animate_health_circle") and self._invulnerability then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(progress > 0 and 0 or 1)
			end
			if self._invulnerability then
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
		end
	end)

	Hooks:PostHook(HUDTeammate, "activate_ability_radial", "HMH_HUDTeammate_activate_ability_radial", function (self, time_left, ...)
		self._radial_health_panel:child("radial_custom"):animate(function (o)
			over(time_left, function (p)
				if self._main_player then
					if HMH:GetOption("ability_icon") then
						self._stamina_circle:set_alpha(0)
					end
					if self._invulnerability then
						self._radial_health_panel:child("animate_health_circle"):set_alpha(0)
						self._health_cooldown_icon:set_visible(false)
						self._cooldown_health_timer:set_visible(false)
						self._active_ability = true
					end
				end
			end)
			if not self._health_timer then
				self._stamina_circle:set_alpha(1) 
			end
			if self._invulnerability then
				self._radial_health_panel:child("animate_health_circle"):set_alpha(1)
				self._cooldown_health_timer:set_visible(HMH:GetOption("armorer_cooldown_timer") and self._health_timer)
				self._health_cooldown_icon:set_visible(self._health_timer)
				self._active_ability = false
			end
		end)
	end)
end