if VHUDPlus and VHUDPlus:getSetting({"CustomHUD", "HUDTYPE"}, 2) == 3 or WolfHUD or _G.IS_VR or CustomEOStandalone and CustomEOStandalone:getSetting({"WolfHUDCustomHUD", "ENABLED"}, true) then 
    return
end
-- Stamina, Infinite ammo and Invulnerable display
if RequiredScript == "lib/managers/hudmanagerpd2" then
	local set_stamina_value_original = HUDManager.set_stamina_value
	local set_max_stamina_original = HUDManager.set_max_stamina
	
	function HUDManager:set_stamina_value(value, ...)
	    if HMH:GetOption("stamina") and self._teammate_panels[self.PLAYER_PANEL] then
		    self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina_current(value)
		end
		return set_stamina_value_original(self, value, ...)
	end

	function HUDManager:set_max_stamina(value, ...)
	    if HMH:GetOption("stamina") and self._teammate_panels[self.PLAYER_PANEL] then
		    self._teammate_panels[HUDManager.PLAYER_PANEL]:set_stamina_max(value)
		end
		return set_max_stamina_original(self, value, ...)
	end
	
    function HUDManager:set_infinite_ammo(state)
		if HMH:GetOption("bulletstorm") and self._teammate_panels[self.PLAYER_PANEL] then
	        self._teammate_panels[HUDManager.PLAYER_PANEL]:_set_infinite_ammo(state)
			if VHUDPlus and VHUDPlus:getSetting({"CustomHUD", "HUDTYPE"}, 2) == 2 then
			    self._teammate_panels[ self.PLAYER_PANEL ]:_set_bulletstorm(false)
			end
        end
	end

elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PreHook(PlayerManager, "activate_temporary_upgrade", "activate_temporary_upgrade_armor_timer", function (self, category, upgrade)
		if upgrade == "armor_break_invulnerable" then
			local upgrade_value = self:upgrade_value(category, upgrade)
			if upgrade_value == 0 then return end
			local teammate_panel = managers.hud:get_teammate_panel_by_peer()
			if teammate_panel then
			    if HMH:GetOption("armorer_cooldown_timer") then
				    teammate_panel:update_cooldown_timer(upgrade_value[2])
				end
				if HMH:GetOption("armorer_cooldown_radial") then
				    teammate_panel:animate_invulnerability(upgrade_value[1])
				end
			end
		end
	end)

    local add_to_temporary_property_original = PlayerManager.add_to_temporary_property
    function PlayerManager:_clbk_bulletstorm_expire()
       	self._infinite_ammo_clbk = nil
        managers.hud:set_infinite_ammo(false)

        if managers.player and managers.player:player_unit() and managers.player:player_unit():inventory() then
    	    for id, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
	   	    	managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
	        end
     	end
    end

    function PlayerManager:add_to_temporary_property(name, time, value, ...)
        add_to_temporary_property_original(self, name, time, value, ...)
        if HMH:GetOption("bulletstorm") and name == "bullet_storm" and time then
            if not self._infinite_ammo_clbk then
	    	    self._infinite_ammo_clbk = "infinite"
	     	    managers.hud:set_infinite_ammo(true)
				managers.enemy:add_delayed_clbk(self._infinite_ammo_clbk, callback(self, self, "_clbk_bulletstorm_expire"), TimerManager:game():time() + time)
	   	    end
        end
    end

elseif RequiredScript == "lib/managers/hud/hudteammate" then	
	local init_original = HUDTeammate.init
	local original_create_condition = HUDTeammate._create_condition
	local set_custom_radial_orig = HUDTeammate.set_custom_radial
	local set_condition_original = HUDTeammate.set_condition
  	local set_ability_radial_original = HUDTeammate.set_ability_radial
	local activate_ability_radial_original = HUDTeammate.activate_ability_radial

	function HUDTeammate:init(...)
		init_original(self, ...)
		if self._main_player then
			if HMH:GetOption("stamina") then
			    self:_create_circle_stamina()
			end
		end
	end
	
	function HUDTeammate:set_custom_radial(data)
       	set_custom_radial_orig(self, data)
        local duration = data.current / data.total
        local aced = managers.player:upgrade_level("player", "berserker_no_ammo_cost", 0) == 1
		if self._main_player and HMH:GetOption("bulletstorm") and aced then
            if duration > 0 then
                managers.hud:set_infinite_ammo(true)
            else
                managers.hud:set_infinite_ammo(false)
	        end
		end
		
		if self._main_player and HMH:GetOption("armorer_cooldown_timer") and self._cooldown_timer then
		    if duration > 0 then
			    self._cooldown_timer:set_alpha(0)
				self._cooldown_icon:set_alpha(0)
				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(0)
				end
			else
			    self._cooldown_timer:set_alpha(1)
				self._cooldown_icon:set_alpha(0.4)
				if self._radial_health_panel:child("radial_armor") then
					self._radial_health_panel:child("radial_armor"):set_alpha(1)
				end
			end
		end
			
	end
		
	function HUDTeammate:_create_condition(...)
		original_create_condition(self, ...)
		self._health_panel = self._health_panel or self._player_panel:child("radial_health_panel")
		if self._main_player then
			self._cooldown_timer = self._health_panel:text({
				name = "cooldown_timer",
				text = "",
				color = Color.white,
				visible = false,
				align = "center",
				vertical = "center",
				y = HMH:GetOption("ability_icon") and 10 or 0,
				font = tweak_data.hud.medium_font_noshadow,
				font_size = 16,
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
		end
	end
	
	function HUDTeammate:_create_circle_stamina()
		local radial_health_panel = self._panel:child("player"):child("radial_health_panel")
		self._stamina_circle = radial_health_panel:bitmap({
			name = "radial_stamina",
			texture = "guis/dlcs/coco/textures/pd2/hud_absorb_stack_fg",
			render_template = "VertexColorTexturedRadial",
			w = radial_health_panel:w() * 0.7,
			h = radial_health_panel:h() * 0.7,
			layer = 3,
		})
		self._stamina_circle:set_center(radial_health_panel:child("radial_health"):center())
 
        -- Hides the stamina display used by VHUDPlus
		if VHUDPlus and VHUDPlus:getSetting({"CustomHUD", "HUDTYPE"}, 2) == 2 then
		    self._stamina_bar:set_alpha(0)
			self._stamina_line:set_alpha(0)
		end
	end

	
	Hooks:PreHook(HUDTeammate, "_create_radial_health", "_create_radial_health_armor_radial", function (self, radial_health_panel)
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
    end)

	function HUDTeammate:update_cooldown_timer(t)
    	if t and t > 1 and self._cooldown_timer then
        	self._cooldown_timer:stop()
			self._cooldown_icon:set_visible(HMH:GetOption("ability_icon"))
			if HMH:GetOption("stamina") and self._stamina_circle and (not HMH:GetOption("armorer_cooldown_radial") or HMH:GetOption("ability_icon")) then 
	  	    	self._stamina_circle:set_alpha(0) 
			end
        	self._cooldown_timer:animate(function(o)
            	o:set_visible(true)
            	local t_left = t
            	while t_left >= 0.1 do
                	t_left = t_left - coroutine.yield()
					t_format = t_left < 10 and "%.1f" or "%.f"
                	o:set_text(string.format(t_format, t_left))
					if t_left > 13.5 then
						o:set_color(HMH:GetColor("armorer_duration_timer_color") or Color.green)
					else
					    o:set_color(HMH:GetColor("armorer_cooldown_timer_color") or Color.red)
					end
            	end
            	o:set_visible(false)
				self._cooldown_icon:set_visible(false)
				if HMH:GetOption("stamina") and self._stamina_circle then 
			    	self._stamina_circle:set_alpha(1) 
				end
        	end)
    	end
	end

	function HUDTeammate:animate_invulnerability(duration)
	    if not self._radial_health_panel:child("radial_armor") then return end
  		self._radial_health_panel:child("radial_armor"):animate(function (o)
		    local icon = self._cooldown_icon 
			local timer = self._cooldown_timer 
    		o:set_color(Color(1, 1, 1, 1))
			timer:set_alpha(0)
			if HMH:GetOption("stamina") and self._stamina_circle and HMH:GetOption("ability_icon") then 
	  	    	self._stamina_circle:set_alpha(0) 
			end
			icon:set_visible(HMH:GetOption("ability_icon"))
			icon:set_alpha(1)
    		o:set_visible(true)
    		over(duration, function (p)
      			o:set_color(Color(1, 1 - p, 1, 1))
    		end)
    		o:set_visible(false)
		    timer:set_alpha(1)
			if HMH:GetOption("stamina") and self._stamina_circle and not HMH:GetOption("armorer_cooldown_timer") then 
			    self._stamina_circle:set_alpha(1) 
			end
			if not HMH:GetOption("armorer_cooldown_timer") then 
			    icon:set_visible(false)
			end
			icon:set_alpha(0.4)
  		end)
	end

    function HUDTeammate:set_stamina_max(value)
    	if not self._max_stamina or self._max_stamina ~= value then
	  	   	self._max_stamina = value
    	end
   	end

    function HUDTeammate:set_stamina_current(value)
        if self._stamina_circle then
    	    self._stamina_circle:set_color(Color(1, value/self._max_stamina, 0, 0))
    	    self:set_stamina_visibility(HMH:GetOption("stamina") and not self._condition_icon:visible())
    	end
    end

    function HUDTeammate:set_stamina_visibility(value)
    	if self._stamina_circle and self._stamina_circle:visible() ~= value then
    		self._stamina_circle:set_visible(value)
	    end
    end

    function HUDTeammate:set_condition(icon_data, ...)
	    local custody = icon_data ~= "mugshot_normal"
    	self:set_stamina_visibility(not custody and HMH:GetOption("stamina"))
		
		local icon = self._cooldown_icon
		local timer = self._cooldown_timer
		if self._main_player and icon or timer then
			icon:set_alpha(custody and 0 or 0.4)
			timer:set_alpha(custody and 0 or 1)
		end
    	set_condition_original(self, icon_data, ...)
    end
	
    function HUDTeammate:set_ability_radial(data)
        local progress = data.current / data.total
        if self._main_player and self._stamina_circle and HMH:GetOption("ability_icon") then 
    	    self._stamina_circle:set_alpha(progress > 0 and 0 or 1) 
    	end
        set_ability_radial_original(self, data)
    end

    function HUDTeammate:activate_ability_radial(time_left, ...)
      	self._radial_health_panel:child("radial_custom"):animate(function (o)
        	over(time_left, function (p)
	    	    if self._main_player and self._stamina_circle and HMH:GetOption("ability_icon") then
         		    self._stamina_circle:set_alpha(0)
	    		end
        	end)
	    	self._stamina_circle:set_alpha(1) 
     	end)
    	activate_ability_radial_original(self, time_left, ...)
    end
end