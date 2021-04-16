if _G.IS_VR then 
    return
end

Hooks:PostHook(HUDTeammate, "init", "HMH_HUDTeammateInit", function(self, ...)
    if HMH:GetOption("interact_info") or HMH:GetOption("color_name") then
	    local radial_health_panel = self._player_panel:child("radial_health_panel")
	    local name_panel = self._panel:panel({
		    name = "name_panel",
		    w = self._panel:w() - self._panel:child( "callsign_bg" ):w() - (not self._main_player and radial_health_panel:w() or 0),
		    h = self._panel:child("name_bg"):h(),
		    x = self._panel:child("name_bg"):x(),
		    y = self._panel:child("name_bg"):y()
	    })

	    if not self._main_player then
		    local interact_panel = self._player_panel:child("interact_panel")
		    local interact_info = interact_panel:text({name = "interact_info"})
		    local interact_text = name_panel:text({
		    	name = "interact_text",
		    	text = "",
			    layer = 1,
		    	visible = false,
		    	color = Color.white,
		    	w = self._panel:child("name"):w(),
		    	h = self._panel:child("name"):h(),
		    	vertical = "bottom",
		    	font_size = tweak_data.hud_players.name_size,
		    	font = tweak_data.hud_players.name_font
		    })
	    end

	    self._new_name = name_panel:text({
		    name = "name",
		    text = " Dallas",
		    layer = 1,
		    color = Color.white,
		    y = 0,
		    vertical = "bottom",
		    font_size = tweak_data.hud_players.name_size,
		    font = tweak_data.hud_players.name_font
	    })
	    self._panel:child("name"):set_visible(false)
    end

	if self._main_player and HMH:GetOption("bulletstorm") then
	    self:inject_ammo_glow()
    end

    self._next_latency_update_t = 0
    if HMH:GetOption("ping") then
	    self:_create_ping_info()
	end
end)

if HMH:GetOption("bulletstorm") then
	function HUDTeammate:inject_ammo_glow()
		self._primary_ammo = self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):bitmap({
			align = "center",
			w = 50,
			h = 45,
			name = "primary_ammo",
		    visible = false,
  		  	texture = "guis/textures/pd2/crimenet_marker_glow",
		    color = Color("00AAFF"),
  		  	layer = 2,
	 	   	blend_mode = "add"
    	})
		self._secondary_ammo = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):bitmap({
    		align = "center",
    		w = 50,
	  	  	h = 45,
    		name = "secondary_ammo",
    		visible = false,
    		texture = "guis/textures/pd2/crimenet_marker_glow",
    		color = Color("00AAFF"),
    		layer = 2,
	   	 	blend_mode = "add"
   	 	})
		self._primary_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
		self._secondary_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
    	self._primary_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):w() / 2)
		self._secondary_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):w() / 2)
	end

	function HUDTeammate:_set_bulletstorm(state)
		self._bullet_storm = state

    	if state then   
			local pweapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")
			local pammo_clip = pweapon_panel:child("ammo_clip")
	   	 	local sweapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
	   	 	local sammo_clip = sweapon_panel:child("ammo_clip")

		    self._primary_ammo:set_visible(true)
    		self._secondary_ammo:set_visible(true)
		    self._secondary_ammo:animate(callback(self, self, "_animate_glow"))
    		self._primary_ammo:animate(callback(self, self, "_animate_glow"))

    		pammo_clip:set_color(Color.white)
    		pammo_clip:set_text("8")
    		pammo_clip:set_rotation(90)
			if HMH:GetOption("ammo") then
    		    pammo_clip:set_font_size(30)
				sammo_clip:set_font_size(30)
			end

		    sammo_clip:set_color(Color.white)
		    sammo_clip:set_text("8")
	 	    sammo_clip:set_rotation(90)
    	else
        	self._primary_ammo:set_visible(false)
	    	self._secondary_ammo:set_visible(false)
		end
	end

	function HUDTeammate:_animate_glow(glow)
		local t = 0
		while true do
	  		t = t + coroutine.yield()
	    	glow:set_alpha((math.abs(math.sin((4 + t) * 360 * 4 / 4))))
		end
	end
end

function HUDTeammate:set_voice_com(status)
	local texture = status and "guis/textures/pd2/jukebox_playing" or "guis/textures/pd2/hud_tabs"
	local texture_rect = status and { 0, 0, 16, 16 } or { 84, 34, 19, 19 }
	local callsign = self._panel:child("callsign")
	if HMH:GetOption("voice") then callsign:set_image(texture, unpack(texture_rect)) end
end

if HMH:GetOption("interact_info") or HMH:GetOption("color_name") then
    Hooks:PostHook(HUDTeammate, "set_name", "HMH_HUDTeammateSetName", function(self, ...)
	    local teammate_panel = self._panel
	    local name = teammate_panel:child("name")
	    local name_bg = teammate_panel:child("name_bg")
        self._new_name:stop()
	    self._new_name:set_text(name:text())

    	local x , y , w , h = self._new_name:text_rect()
	    self._new_name:set_left(0)
	    self._new_name:set_size(w, h)
	    name_bg:set_w(self._new_name:w() + 4)

	    if self._panel:child("name_panel"):w() < name_bg:w() then
		    self._new_name:set_font_size(tweak_data.hud_players.name_size * 0.75)
			name_bg:set_w(self._new_name:w() - 45)
		    --self._new_name:animate(callback(self, self, "_animate_name"), name_bg:w() - self._panel:child("name_panel"):w() + 2)
	    end
		name_bg:set_visible(true)
    end)

    Hooks:PostHook(HUDTeammate, "set_state", "HMH_HUDTeammateSetState", function(self, state)
	    if not self._main_player then
		    self._panel:child("name_panel"):set_y(self._panel:child("name"):y())
        end
    end)

	Hooks:PostHook(HUDTeammate, "_create_radial_health", "HMH_HUDTeammateCreateRadialHealth", function(self, radial_health_panel)
	    local radial_ability_panel = radial_health_panel:child("radial_ability")
        local ability_icon = radial_ability_panel:child("ability_icon")

	    if HMH:GetOption("color_name") then
	        ability_icon:set_visible(false)
	    end
    end)

	--function HUDTeammate:_animate_name(name, width)
	--    local t = 0
	--    while true do
	--	    t = t + coroutine.yield()
	--	    name:set_left(width * ( math.sin(90 + t * 50) * 0.5 - 0.5))
	--   end
    --end
end

Hooks:PostHook(HUDTeammate, "set_callsign", "HMH_HUDTeammateSetCallsign", function(self, id)
    if HMH:GetOption("color_condition") then
        self._condition_icon = self._panel:child("condition_icon")
        self._condition_icon:set_color(tweak_data.chat_colors[id])
	end
	
	local is_cheater = not self._main_player and self:peer_id() and managers.network:session() and managers.network:session():peer(self:peer_id()):is_cheater()
    if HMH:GetOption("color_name") then
        self._panel:child("name"):set_color(is_cheater and tweak_data.screen_colors.pro_color or tweak_data.chat_colors[id])
	    self._new_name:set_color(is_cheater and tweak_data.screen_colors.pro_color or tweak_data.chat_colors[id])
	end

    if is_cheater and HMH:GetOption("color_name") then
	    self._panel:child("callsign"):set_color(tweak_data.screen_colors.pro_color)
	end
end)

if HMH:GetOption("interact_info") then
    local t = 1 -- How long an interaction should be in order for the text to display. If its shorter than 1 sec nothing will show when at default.
    local HUDTeammate_teammate_progress = HUDTeammate.teammate_progress
    function HUDTeammate:teammate_progress(enabled, tweak_data_id, timer, success)
        if not self._player_panel:child("interact_panel"):child("interact_info") then return end
        self._panel:child("name_panel"):child("interact_text"):stop()
        self._panel:child("name_panel"):child("interact_text"):set_left(0)

        if enabled and not self._main_player and self:peer_id() and timer >= t then
            self._new_name:set_alpha(0.1)
            self._panel:child("name_panel"):child("interact_text"):set_visible(true)
            self._panel:child("name_panel"):child("interact_text"):set_text(" " .. managers.hud:_name_label_by_peer_id(self:peer_id()).panel:child("action"):text())

			local x , y , w , h = self._panel:child("name_panel"):child("interact_text"):text_rect()
			self._panel:child("name_bg"):set_w( w + 4)
			--self._panel:child("name_bg"):set_visible(false)
            self._panel:child("name_panel"):child("interact_text"):set_size(w, h)

            if self._panel:child("name_panel"):child("interact_text"):w() + 4 > self._panel:child("name_bg"):w() then
                self._panel:child("name_bg"):set_w(self._panel:child("name_panel"):child("interact_text"):w() + 4)
            end

            if self._panel:child("name_panel"):w() < self._panel:child("name_panel"):child("interact_text"):w() + 4 then
			    self._panel:child("name_panel"):child("interact_text"):set_font_size(tweak_data.hud_players.name_size * 0.75)
				self._panel:child("name_bg"):set_w(self._panel:child("name_panel"):child("interact_text"):w() - 45)
               -- self._panel:child("name_panel"):child("interact_text"):animate(callback(self,self, "_animate_name"), self._panel:child("name_bg"):w() - self._panel:child("name_panel"):w() + 2)
            end

        elseif not success and not self._main_player then
            local x, y, w, h = self._new_name:text_rect()
            self._new_name:set_size(w, h)
            self._panel:child("name_panel"):child("interact_text"):stop()
            self._panel:child("name_panel"):child("interact_text"):set_left(0)

            self._new_name:set_alpha(1)
            self._panel:child("name_panel"):child("interact_text"):set_visible(false)
			self._panel:child("name_panel"):child("interact_text"):set_font_size(tweak_data.hud_players.name_size)
			--self._panel:child("name_bg"):set_w(self._panel:child("name_panel"):child("interact_text"):w() + 4)
            self._panel:child("name_bg"):set_w( w + 4)
			--self._panel:child("name_bg"):set_visible(true)
        end

        if success then
            self._new_name:set_alpha(1)
			self._panel:child("name_panel"):child("interact_text"):set_font_size(tweak_data.hud_players.name_size)
            self._panel:child("name_panel"):child("interact_text"):set_visible(false)
			local x , y , w , h = self._new_name:text_rect()
			self._panel:child("name_bg"):set_w( w + 4)
		--	self._panel:child("name_bg"):set_visible(true)
        end

        self._panel:child("name_panel"):child("interact_text"):set_color(HMH:GetOption("color_name") and tweak_data.chat_colors[self._peer_id] or Color.white)

        if not self._main_player and self:peer_id() then
            local peer = managers.network:session() and managers.network:session():peer(self:peer_id())
            if peer and peer:is_cheater() then
                self._panel:child("name_panel"):child("interact_text"):set_color(HMH:GetOption("color_name") and tweak_data.screen_colors.pro_color or Color.white)
            end
        end
        HUDTeammate_teammate_progress(self, enabled, tweak_data_id, timer, success)
    end
end

Hooks:PreHook(HUDTeammate, "set_carry_info", "HMH_HUDTeammateSetCarryInfo", function(self, ...)
    if self._peer_id then
        self._player_panel:child("carry_panel"):child("bag"):set_color(HMH:GetOption("color_bag") and tweak_data.chat_colors[self._peer_id] or Color.white)
    end
end)

if HMH:GetOption("pickups") then
    function HUDTeammate:add_special_equipment(data)
        local team_color
    	if self._peer_id then
            team_color = tweak_data.chat_colors[self._peer_id]
        elseif not self._ai then
            team_color = tweak_data.chat_colors[managers.network:session():local_peer():id()]
        end

    	local teammate_panel = self._panel
	    local special_equipment = self._special_equipment
	    local id = data.id
    	local equipment_panel = teammate_panel:panel({
    		y = 0,
    		layer = 0,
    		name = id
    	})
    	local icon, texture_rect = tweak_data.hud_icons:get_icon_data(data.icon)

    	equipment_panel:set_size(25, 25)

    	local bitmap = equipment_panel:bitmap({
    		name = "bitmap",
    		layer = 0,
    		rotation = 360,
    		texture = icon,
    		color = team_color,
    		texture_rect = texture_rect,
			w = equipment_panel:w(),
			h = equipment_panel:h()
		})

		local w = teammate_panel:w()

		equipment_panel:set_x(w - (equipment_panel:w() + 0) * #special_equipment)
		table.insert(special_equipment, equipment_panel)

		local amount, amount_bg = nil

		if data.amount then
			amount_bg = equipment_panel:child("amount_bg") or equipment_panel:bitmap({
				texture = "guis/textures/pd2/equip_count",
				name = "amount_bg",
				rotation = 360,
				layer = 2,
				color = Color.white
			})
			amount = equipment_panel:child("amount") or equipment_panel:text({
				name = "amount",
				vertical = "center",
				font_size = 12,
				align = "center",
				font = "fonts/font_small_noshadow_mf",
				rotation = 360,
				layer = 3,
				text = tostring(data.amount),
				color = Color.black,
				w = equipment_panel:w(),
				h = equipment_panel:h()
			})

			amount_bg:set_center(bitmap:center())
			amount_bg:move(7, 7)
			amount_bg:set_visible(data.amount > 1)
			amount:set_center(amount_bg:center())
			amount:set_visible(data.amount > 1)
		end
		self:layout_special_equipments()
	end
end

if HMH:GetOption("equipment") then
    Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount", "HMH_HUDTeammateSetDeployableEquipmentAmount", function(self, index, data)
        local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
        local equipment = deployable_equipment_panel:child("equipment")
        local amount = deployable_equipment_panel:child("amount")

        equipment:stop()

        if data.amount > 0 then
            equipment:set_alpha(1)
            equipment:set_color(Color("ff80df"))
            amount:set_alpha(1)
            amount:set_color(Color("66ffff"))
        end

        if data.amount > 0 then
            equipment:animate(function(o)
                over(1, function(p)
                    local n = 1 - math.sin((p / 2) * 180)
                    equipment:set_alpha(math.lerp(1, 0.2, n))
                end)
            end)
        elseif data.amount == 0 then
            equipment:animate(function(o)
                equipment:set_color(Color("ff80df"))
                over(1, function(p)
                    equipment:set_alpha(0.2)
                    amount:set_alpha(0.2)
                end)
            end)
        end
    end)

    Hooks:PostHook(HUDTeammate, "set_grenades_amount", "HMH_HUDTeammateSetGrenadesAmount", function(self, data)
        if not PlayerBase.USE_GRENADES then
            return
        end

        if not self._grenade_amount then self._grenade_amount = data.amount end

        local grenades_panel = self._player_panel:child("grenades_panel")
        local grenades = grenades_panel:child("grenades_icon")
        local amount = grenades_panel:child("amount")

        grenades:stop()

        if data.amount > 0 then
            grenades:set_alpha(1)
            grenades:set_color(Color("ff80df"))
            amount:set_color(Color("66ffff"))
            amount:set_alpha(1)
        end

        if self._grenade_amount ~= data.amount and data.amount > 0 then
            grenades:animate( function(o)
                over(1, function(p)
                    local n = 1 - math.sin((p / 2 ) * 180)
                    grenades:set_alpha( math.lerp(1, 0.2, n))
                end)
            end)
        elseif data.amount == 0 then
            grenades:animate( function(o)
                grenades:set_color(Color("ff80df"))
                over(1, function(p)
                    grenades:set_alpha(0.2)
                    amount:set_alpha(0.2)
                end)
            end)
        end

        self._grenade_amount = data.amount
    end)

    Hooks:PostHook(HUDTeammate, "set_cable_ties_amount", "HMH_HUDTeammateSetCableTiesAmount", function(self, amount)
        if not self._cable_amount then self._cable_amount = amount end

        local cable_ties_panel = self._player_panel:child("cable_ties_panel")
        local cable_ties = cable_ties_panel:child("cable_ties")
        local cable_ties_amount = cable_ties_panel:child("amount")

        cable_ties:stop()

        if amount > 0 then
            cable_ties:set_alpha(1)
            cable_ties:set_color(Color("ff80df"))
            cable_ties_amount:set_color(Color("66ffff"))
            cable_ties_amount:set_alpha(1)
        end

        if self._cable_amount ~= amount and amount > 0 then
            cable_ties:animate(function(o)
                over(1, function(p)
                    local n = 1 - math.sin((p / 2 ) * 180)
                    cable_ties:set_alpha(math.lerp(1, 0.2, n))
                end)
            end)
        elseif amount == 0 then
            cable_ties:animate(function(o)
                cable_ties:set_color(Color("ff80df"))
                over(1, function(p)
                    cable_ties:set_alpha(0.2)
                    cable_ties_amount:set_alpha(0.2)
                end)
            end)
        end
    end)

    Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount_from_string", "HMH_HUDTeammateSetDeployableEquipmentAmountFromString", function(self, index, data)
        local teammate_panel = self._panel:child("player")
        local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
        local icon = deployable_equipment_panel:child("equipment")
        local amount = deployable_equipment_panel:child("amount")
        local amounts = ""
        local zero_ranges = {}
        local color = Color(0.5, 1, 1, 1)
        local alpha = 0.2

        icon:stop()

        for i, amount in ipairs(data.amount) do
            local amount_str = string.format("%01d", amount)

            if i > 1 then
                amounts = amounts .. "|"
            end

            if amount == 0 then
                local current_length = string.len(amounts)

                table.insert(zero_ranges, {
                    current_length,
                    current_length + string.len(amount_str)
                })
            end

            amounts = amounts .. amount_str

            if amount > 0 then
			    color = Color("66ffff")
                alpha = 1
            end
        end

        icon:set_color(Color("ff80df"))
        icon:set_alpha(alpha)
        amount:set_alpha(alpha)
        amount:set_color(color)
    end)
end

if HMH:GetOption("ammo") then
    Hooks:PreHook(HUDTeammate, "set_weapon_selected", "HMH_HUDTeammateSetWeaponSelected", function(self, id, hud_icon)
        local is_secondary = id == 1
        local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
        local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")

        secondary_weapon_panel:stop()
        primary_weapon_panel:stop()

        if is_secondary then
            primary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    primary_weapon_panel:set_alpha(math.lerp(1, 0.5, p))
                end)
            end)
            secondary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    secondary_weapon_panel:set_alpha(math.lerp(0.5, 1, p))
                end)
            end)
        else
            secondary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    secondary_weapon_panel:set_alpha(math.lerp(1, 0.5, p))
                end)
            end)
            primary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    primary_weapon_panel:set_alpha(math.lerp(0.5, 1, p))
                end)
            end)
        end
    end)
	
	Hooks:PostHook(HUDTeammate, "_create_weapon_panels", "HMH_HUDTeammate_create_weapon_panels", function(self, weapons_panel)
        local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
        local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")
        local sec_weapon_selection_panel = secondary_weapon_panel:child("weapon_selection")
        local prim_weapon_selection_panel = primary_weapon_panel:child("weapon_selection")
    
        prim_weapon_selection_panel:child("weapon_selection"):set_color(Color("66ff99"))
        sec_weapon_selection_panel:child("weapon_selection"):set_color(Color("66ffff"))
    end)
end

Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "HMH_HUDTeammateSetAmmoAmountByType", function(self, type, max_clip, current_clip, current_left, max, weapon_panel)
    local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")

	if self._main_player and HMH:GetOption("trueammo") then
		if current_left - current_clip >= 0 then
			current_left = current_left - current_clip
		end
	end

    local low_ammo = current_left <= math.round(max_clip / 2)
	local low_clip = current_clip <= math.round(max_clip / 4)
	local out_of_clip = current_clip <= 0
    local out_of_ammo = current_left <= 0
    local cheated_ammo = current_left > max
    local cheated_clip = current_clip > max_clip
	local color_total = out_of_ammo and Color(1 , 0.9 , 0.3 , 0.3)
    color_total = color_total or low_ammo and (HMH:GetOption("ammo") and Color("ffcc66") or Color(1, 0.9, 0.9, 0.3))
    color_total = color_total or cheated_ammo and Color.red
    color_total = color_total or (HMH:GetOption("ammo") and Color("66ff99") or Color.white)
	local color_clip = out_of_clip and Color(1 , 0.9 , 0.3 , 0.3)
    color_clip = color_clip or low_clip and (HMH:GetOption("ammo") and Color("ffcc66") or Color(1, 0.9, 0.9, 0.3))
    color_clip = color_clip or cheated_clip and Color.red
    color_clip = color_clip or (HMH:GetOption("ammo") and Color("66ffff") or Color.white)
    local ammo_total = weapon_panel:child("ammo_total")
	local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""

    ammo_total:set_text(zero ..tostring(current_left))
    ammo_total:set_color(color_total)
    ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))

    local ammo_clip = weapon_panel:child("ammo_clip")
    local zero_clip = current_clip < 10 and "00" or current_clip < 100 and "0" or ""

    ammo_clip:set_color(color_clip)
    ammo_clip:set_range_color(0, string.len(zero_clip), color_clip:with_alpha(0.5))

    if HMH:GetOption("ammo") then
		local ammo_font = string.len(current_left) < 4 and 21 or 18

        ammo_total:stop()
        ammo_total:set_font(Idstring("fonts/font_medium"))
		ammo_total:set_font_size(ammo_font)

        ammo_clip:stop()
        ammo_clip:set_font(Idstring("fonts/font_medium"))
	    ammo_clip:set_font_size(24)
		
		if not self._last_ammo then
            self._last_ammo = {}
            self._last_ammo[type] = current_left
        end

        if not self._last_clip then
            self._last_clip = {}
            self._last_clip[type] = current_clip
        end

        if self._last_ammo and self._last_ammo[type] and self._last_ammo[type] < current_left then
            ammo_total:animate(function(o)
                local s = self._last_ammo[type]
                local e = current_left
                over(0.5, function(p)
                    local value = math.lerp(s, e, p)
                    local text = string.format("%.0f", value)
                    local zero = math.round(value) < 10 and "00" or math.round(value) < 100 and "0" or ""
                    local low_ammo = value <= math.round(max_clip / 2)
                    local out_of_ammo = value <= 0
                    local cheated_ammo = value > max
                    local color_total = out_of_ammo and Color(1, 0.9, 0.3, 0.3)
                    color_total = color_total or low_ammo and Color("ffcc66")
                    color_total = color_total or cheated_ammo and Color.red
                    color_total = color_total or (Color("66ff99"))

                    ammo_total:set_text(zero .. text)
                    ammo_total:set_color(color_total)
                    ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
                end)
                over(1 , function(p)
                    local n = 1 - math.sin((p / 2 ) * 180)

                    ammo_total:set_font_size(math.lerp(ammo_font, ammo_font + 4, n))
                end)
            end)
        end

        if self._last_clip and self._last_clip[type] and self._last_clip[type] < current_clip and not self._bullet_storm then
            ammo_clip:animate(function(o)
                local s = self._last_clip[type]
                local e = current_clip
                over(0.25, function(p)
                    local value = math.lerp(s, e, p)
                    local text = string.format( "%.0f", value)
                    local zero = math.round(value) < 10 and "00" or math.round(value) < 100 and "0" or ""
                    local low_clip = value <= math.round(max_clip / 4)
                    local out_of_clip = value <= 0
                    local color_clip = out_of_clip and Color(1, 0.9, 0.3, 0.3)

                    color_clip = color_clip or low_clip and Color("ffcc66")
                    color_clip = color_clip or (Color("66ffff"))

                    ammo_clip:set_text(zero .. text)
                    ammo_clip:set_color(color_clip)
                    ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
                end)
            end)
        end
        self._last_ammo[type] = current_left
        self._last_clip[type] = current_clip
	end

	if HMH:GetOption("bulletstorm") then
		if self._main_player and self._bullet_storm then
			ammo_clip:set_color(Color.white)
	    	ammo_clip:set_text( "8" )
    		ammo_clip:set_rotation(90)
			if HMH:GetOption("ammo") then
		        ammo_clip:set_font_size(30)
			end
		else
		    ammo_clip:set_rotation(0)
	    end
	end
end)

function HUDTeammate:update(t,dt)
	self:update_latency(t,dt)
end

function HUDTeammate:update_latency(t,dt)
	local ping_panel = self._panel:child("latency")
	if ping_panel and self:peer_id() and t > self._next_latency_update_t then
		local net_session = managers.network:session()
		local peer = net_session and net_session:peer(self:peer_id())
		local latency = peer and Network:qos(peer:rpc()).ping or "n/a"

		if type(latency) == "number" then
			ping_panel:set_text(string.format("%.0fms", latency))
			ping_panel:set_color(latency < 75 and Color('66ff99') or latency < 150 and Color('ffcc66') or Color('ff6666'))
		else
			ping_panel:set_text(latency)
			ping_panel:set_color(Color('ff6666'))
		end

		self._next_latency_update_t = t + 1
	elseif not self:peer_id() and ping_panel then
		ping_panel:set_text("")
	end
end

function HUDTeammate:_create_ping_info()
	local name_panel = self._panel:child("name")
	local ping_info = self._panel:text({
		name = "latency",
		vertical = "right",
		font_size = tweak_data.hud.small_font_size,
		align = "right",
		halign = "right",
		text = "",
		font = "fonts/font_small_mf",
		layer = 1,
		visible = HMH:GetOption("ping") or VHUDPlus and VHUDPlus:getSetting({"CustomHUD","TEAMMATE","LATENCY"}, true),
		color = Color.white,
		x = -12,
		y = name_panel:y() - tweak_data.hud.small_font_size,
		h = 50
	})
end