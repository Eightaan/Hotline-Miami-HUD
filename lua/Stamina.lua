if not HMH:GetOption("stamina") or VHUDPlus or WolfHUD or (restoration and restoration:all_enabled("HUD/MainHUD", "HUD/Teammate")) or (CustomEOStandalone and getSetting({"WolfHUDCustomHUD", "ENABLED"}, true)) then 
    return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	local set_stamina_value_original = HUDManager.set_stamina_value
	local set_max_stamina_original = HUDManager.set_max_stamina
	
	function HUDManager:set_stamina_value(value, ...)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_current_stamina(value)
		return set_stamina_value_original(self, value, ...)
	end

	function HUDManager:set_max_stamina(value, ...)
		self._teammate_panels[HUDManager.PLAYER_PANEL]:set_max_stamina(value)
		return set_max_stamina_original(self, value, ...)
	end

elseif RequiredScript == "lib/managers/hud/hudteammate" then	
	local init_original = HUDTeammate.init
	local set_condition_original = HUDTeammate.set_condition

	function HUDTeammate:init(i, ...)
		init_original(self, i, ...)
		
		if self._main_player then
			self:_create_stamina_circle()
		end
	end
	
	function HUDTeammate:_create_stamina_circle()
		local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
		self._stamina_bar = radial_health_panel:bitmap({
			name = "radial_stamina",
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
			render_template = "VertexColorTexturedRadial",
			w = radial_health_panel:w() * 0.7,
			h = radial_health_panel:h() * 0.7,
			layer = 3,
		})
		self._stamina_bar:set_center(radial_health_panel:child("radial_health"):center())
	end

	function HUDTeammate:set_max_stamina(value)
		if not self._max_stamina or self._max_stamina ~= value then
			self._max_stamina = value
		end
	end

	function HUDTeammate:set_current_stamina(value)
		self._stamina_bar:set_color(Color(1, value/self._max_stamina, 0, 0))
	end
	
		function HUDTeammate:set_max_stamina(value)
		if not self._max_stamina or self._max_stamina ~= value then
			self._max_stamina = value
		end
	end

	function HUDTeammate:set_current_stamina(value)
	    if self._stamina_bar then
		    self._stamina_bar:set_color(Color(1, value/self._max_stamina, 0, 0))
		    self:set_stamina_meter_visibility(HMH:GetOption("stamina") and not self._condition_icon:visible())
		end
	end

	function HUDTeammate:set_stamina_meter_visibility(value)
		if self._stamina_bar and self._stamina_bar:visible() ~= value then
			self._stamina_bar:set_visible(value)
		end
	end

	function HUDTeammate:set_condition(icon_data, ...)
		local visible = icon_data ~= "mugshot_normal"
		self:set_stamina_meter_visibility(not visible and HMH:GetOption("stamina"))
		set_condition_original(self, icon_data, ...)
	end
end