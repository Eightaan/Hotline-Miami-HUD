-- UHUD Vanilla + used for interaction text and animated team panels

Hooks:PostHook(HUDTeammate, "init" , "HMH_HUDTeammateInit", function(self, ... )
	local radial_health_panel = self._player_panel:child("radial_health_panel")
	local name_panel = self._panel:panel({
		name 	= "name_panel",
		w 		= self._panel:w() - self._panel:child( "callsign_bg" ):w() - ( not self._main_player and radial_health_panel:w() or 0 ),
		h 		= self._panel:child( "name_bg" ):h(),
		x 		= self._panel:child( "name_bg" ):x(),
		y 		= self._panel:child( "name_bg" ):y()
	})

	if not self._main_player then

		local interact_panel = self._player_panel:child("interact_panel")
		local interact_info = interact_panel:text({name = "interact_info"})
		local interact_text = name_panel:text({
			name 		= "interact_text",
			text 		= "",
			layer 		= 1,
			visible 	= false,
			color 		= Color.white,
			w 			= self._panel:child("name"):w(),
			h 			= self._panel:child("name"):h(),
			vertical 	= "bottom",
			font_size 	= tweak_data.hud_players.name_size,
			font 		= tweak_data.hud_players.name_font
		})
	end

	self._new_name = name_panel:text({
		name 		= "name",
		text 		= " Dallas",
		layer 		= 1,
		color 		= Color.white,
		y 			= 0,
		vertical 	= "bottom",
		font_size 	= tweak_data.hud_players.name_size,
		font 		= tweak_data.hud_players.name_font
	})
	self._panel:child("name"):set_visible(false)
end)

Hooks:PostHook(HUDTeammate, "set_name", "HMH_HUDTeammateSetName", function(self, ... )

	local teammate_panel = self._panel
	local name = teammate_panel:child("name")
	local name_bg = teammate_panel:child("name_bg")

    self._new_name:stop()

	self._new_name:set_text(name:text())

	local x , y , w , h = self._new_name:text_rect()
	self._new_name:set_left(0)
	self._new_name:set_size(w, h)
	name_bg:set_w(self._new_name:w() + 4)

	if HMH:GetOption("color_name") and self._panel:child("name_panel"):w() < name_bg:w() then
		self._new_name:animate( callback(self, self, "_animate_name"), name_bg:w() - self._panel:child("name_panel"):w() + 2)
	end
end)

Hooks:PostHook(HUDTeammate, "set_callsign", "HMH_HUDTeammateSetCallsign", function(self, id)
	self._condition_icon = self._panel:child("condition_icon")
	self._condition_icon:set_color(HMH:GetOption("color_name") and tweak_data.chat_colors[id] or Color.white)

	self._panel:child("name"):set_color(HMH:GetOption("color_name") and tweak_data.chat_colors[id] or Color.white)
	self._new_name:set_color(HMH:GetOption("color_name") and tweak_data.chat_colors[id] or Color.white)

    if not self._main_player and self:peer_id() and managers.network:session() and managers.network:session():peer(self:peer_id()):is_cheater() then
		self._panel:child("name"):set_color(tweak_data.screen_colors.pro_color)
		self._new_name:set_color(tweak_data.screen_colors.pro_color)
		self._panel:child("callsign"):set_color(tweak_data.screen_colors.pro_color)
	end
end)

Hooks:PostHook(HUDTeammate, "set_state", "uHUDPostHUDTeammateSetState", function(self, state)
	if not self._main_player then
		self._panel:child("name_panel"):set_y(self._panel:child("name"):y())
    end
end)

Hooks:PreHook(HUDTeammate, "teammate_progress", "HMH_HUDTeammateTeammateProgress", function(self, enabled, tweak_data_id, timer, success)
    if not self._player_panel:child("interact_panel"):child("interact_info") then return end

    self._panel:child("name_panel"):child("interact_text"):stop()
    self._panel:child("name_panel"):child("interact_text"):set_left(0)

	if enabled and not self._main_player and self:peer_id() and 2 <= timer and HMH:GetOption("interact_info") then
		self._new_name:set_alpha(0.1)
        self._panel:child("name_panel"):child("interact_text"):set_visible(true)
	    self._panel:child("name_panel"):child("interact_text"):set_text(" " .. managers.hud:_name_label_by_peer_id(self:peer_id()).panel:child("action"):text())

	    local x , y , w , h = self._panel:child("name_panel"):child("interact_text"):text_rect()
	    self._panel:child("name_panel"):child("interact_text"):set_size(w, h)

	    if self._panel:child("name_panel"):child("interact_text"):w() + 4 > self._panel:child("name_bg"):w() then
			self._panel:child("name_bg"):set_w(self._panel:child("name_panel"):child("interact_text"):w() + 4)
		end

		if self._panel:child("name_panel"):w() < self._panel:child("name_panel"):child("interact_text"):w() + 4 then
			self._panel:child("name_panel"):child("interact_text"):animate(callback(self,self, "_animate_name" ), self._panel:child("name_bg"):w() - self._panel:child("name_panel"):w() + 2)
		end

	elseif not success and not self._main_player then
		local x, y, w, h = self._new_name:text_rect()
		self._new_name:set_size(w, h)
		self._panel:child("name_panel"):child("interact_text"):stop()
		self._panel:child("name_panel"):child("interact_text"):set_left(0)

		self._new_name:set_alpha(1)
		self._panel:child("name_panel"):child("interact_text"):set_visible(false)
	    self._panel:child("name_bg"):set_w( w + 4)
	end

	if success then
		self._new_name:set_alpha(1)
		self._panel:child( "name_panel" ):child( "interact_text" ):set_visible(false)
		self._panel:child( "name_bg" ):set_w( self._new_name:w() + 4)
	end

	self._panel:child("name_panel"):child("interact_text"):set_color(tweak_data.chat_colors[self._peer_id] or Color.white )

    if not self._main_player and self:peer_id() then
		local peer = managers.network:session() and managers.network:session():peer(self:peer_id())
		if peer and peer:is_cheater() then
            self._panel:child("name_panel"):child("interact_text"):set_color(tweak_data.screen_colors.pro_color)
        end
    end
end)

function HUDTeammate:_animate_name(name, width)
	local t = 0
	while true do
		t = t + coroutine.yield()
		name:set_left(width * ( math.sin(90 + t * 50) * 0.5 - 0.5))
	end
end

Hooks:PreHook(HUDTeammate, "set_carry_info", "HMH_HUDTeammateSetCarryInfo", function(self, ...)
    if self._peer_id then
	    if managers.network:session():peer( self._peer_id ):is_cheater() then
	        self._player_panel:child("carry_panel"):child("bag"):set_color(tweak_data.screen_colors.pro_color)
	    else
            self._player_panel:child("carry_panel"):child("bag"):set_color(HMH:GetOption("color_bag") and tweak_data.chat_colors[self._peer_id] or Color.white)
	    end
    end
end)

Hooks:PostHook(HUDTeammate, "add_special_equipment", "HMH_HUDTeammateAddSpecialEquipment", function(self, data, ... )
    local team_color
	if self._peer_id then
        team_color = tweak_data.chat_colors[self._peer_id]
    elseif not self._ai then
        team_color = tweak_data.chat_colors[managers.network:session():local_peer():id()]
    end
    if not self._main_player and self:peer_id() and managers.network:session() and managers.network:session():peer(self:peer_id()):is_cheater() then
        team_color = tweak_data.screen_colors.pro_color
    end

	local id = data.id
	local teammate_panel = self._panel
	local equipment_panel = teammate_panel:child(id)
	local bitmap = equipment_panel:child("bitmap")
    bitmap:set_color(HMH:GetOption("pickups") and team_color or Color.white)
end)

if HMH:GetOption("equipment") then
    Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount", "HMH_HUDTeammateSetDeployableEquipmentAmount", function(self, index, data)
        local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
        local equipment = deployable_equipment_panel:child("equipment")
        local amount = deployable_equipment_panel:child("amount")

        equipment:stop()

        if data.amount > 0 then
            equipment:set_alpha(1)
            equipment:set_visible(true)
            equipment:set_color(Color("ff80df"))
            amount:set_alpha(1)
            amount:set_visible(true)
            amount:set_color(Color("66ffff"))
        end

        if data.amount > 0 then
            equipment:animate( function(o)
                equipment:set_alpha(1)
                equipment:set_visible(true)
                amount:set_alpha(1)
                amount:set_visible(true)
                over(1, function(p)
                    local n = 1 - math.sin(( p / 2 ) * 180)
                    equipment:set_alpha( math.lerp(1, 0.2, n))
                end)
            end)
        elseif data.amount == 0 then
            equipment:animate( function(o)
                equipment:set_visible(true)
                equipment:set_color(Color("ff80df"))
                amount:set_visible(true)
                self:_set_amount_string(amount, data.amount)
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
            grenades:set_visible(true)
            grenades:set_color(Color("ff80df"))

            amount:set_color(Color("66ffff"))
            amount:set_alpha(1)
            amount:set_visible(true)
        end

        if self._grenade_amount ~= data.amount and data.amount > 0 then
            grenades:animate( function(o)
                grenades:set_alpha(1)
                grenades:set_visible(true)
                amount:set_alpha(1)
                amount:set_visible(true)
                over(1, function(p)
                    local n = 1 - math.sin((p / 2 ) * 180)
                    grenades:set_alpha( math.lerp(1, 0.2, n))
                end)
            end)
        elseif data.amount == 0 then
            grenades:animate( function(o)
                grenades:set_visible(true)
                grenades:set_color(Color("ff80df"))
                amount:set_visible(true)
                self:_set_amount_string(amount, data.amount)
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

        if amount > 0 then
            cable_ties:set_alpha(1)
            cable_ties:set_visible(true)
            cable_ties:set_color(Color("ff80df"))
            cable_ties_amount:set_color(Color("66ffff"))
            cable_ties_amount:set_alpha(1)
            cable_ties_amount:set_visible(true)
        end

        if self._cable_amount ~= amount and amount > 0 then
            cable_ties:animate( function(o)
                cable_ties:set_alpha(1)
                cable_ties:set_visible(true)
                cable_ties_amount:set_alpha(1)
                cable_ties_amount:set_visible(true)
                over(1, function(p)
                    local n = 1 - math.sin((p / 2 ) * 180)
                    cable_ties:set_alpha( math.lerp(1, 0.2, n ))
                end)
            end)
        elseif amount == 0 then
            cable_ties:animate( function(o)
                cable_ties:set_visible(true)
                cable_ties:set_color(Color("ff80df"))
                cable_ties_amount:set_visible(true)
                self:_set_amount_string(cable_ties_amount, amount)
                over(1, function(p)
                    cable_ties:set_alpha(0.2)
                    cable_ties_amount:set_alpha(0.2)
                end)
            end)
        end
    end)

    Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount_from_string", "HMH_HUDTeammateSetDeployableEquipmentAmountFromString", function(self, index, data)
        -- fixes the shaped charges, not gonna bother with animating this
        local teammate_panel = self._panel:child("player")
        local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
        local icon = deployable_equipment_panel:child("equipment")
        local amount = deployable_equipment_panel:child("amount")
        local amounts = ""
        local zero_ranges = {}
        local color = Color(0.5, 1, 1, 1)
        local alpha = 0.2
        local icon_color = color

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
                icon_color = Color("ff80df")
                alpha = 1
            end
        end

        icon:set_color(icon_color)
        icon:set_visible(true)
        icon:set_alpha(alpha)
        amount:set_alpha(alpha)
        amount:set_text(amounts)
        amount:set_color(color)
        amount:set_visible(true)

        for _, range in ipairs(zero_ranges) do
            amount:set_range_color(range[1], range[2], Color(0.5, 1, 1, 1))
        end
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
                    primary_weapon_panel:set_alpha( math.lerp(1, 0.5, p ))
                end)
            end)

            secondary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    secondary_weapon_panel:set_alpha( math.lerp(0.5, 1, p ))
                end)
            end)
        else
            secondary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    secondary_weapon_panel:set_alpha( math.lerp(1, 0.5, p ))
                end)
            end)

            primary_weapon_panel:animate(function(o)
                over(0.5, function(p)
                    primary_weapon_panel:set_alpha( math.lerp(0.5, 1, p ))
                end)
            end)
        end
    end)

    Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "HMH_HUDTeammateSetAmmoAmountByType", function(self, type, max_clip, current_clip, current_left, max)
        local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
        local ammo_total = weapon_panel:child("ammo_total")
        local ammo_clip = weapon_panel:child("ammo_clip")

        local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""
        local zero_clip = current_clip < 10 and "00" or current_clip < 100 and "0" or ""

        local low_ammo = current_left <= math.round( max / 3 )
        local out_of_ammo = current_left <= 0
        local max_ammo = (current_left == max or ((current_left + current_clip == max)))
        local cheated_ammo = current_left > max

        local low_clip = current_clip <= math.round( max_clip / 4 )
        local out_of_clip = current_clip <= 0
        local cheated_clip = current_clip > max_clip

        local color_total = out_of_ammo and Color(1 , 0.9 , 0.3 , 0.3)
        color_total = color_total or max_ammo and (Color("66ff99"))
        color_total = color_total or low_ammo and Color("ffcc66")
        color_total = color_total or cheated_ammo and Color.red
        color_total = color_total or (Color("66ff99"))

        local color_clip = out_of_clip and Color(1 , 0.9 , 0.3 , 0.3)
        color_clip = color_clip or low_clip and Color("ffcc66")
        color_clip = color_clip or cheated_clip and Color.red
        color_clip = color_clip or (Color("66ffff"))

        ammo_total:stop()
        ammo_total:set_text( zero .. current_left )
        ammo_total:set_font(Idstring("fonts/font_medium"))
        ammo_total:set_font_size( 21 )
        ammo_total:set_color(color_total)
        ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))

        ammo_clip:stop()
        ammo_clip:set_color(color_clip)
        ammo_clip:set_range_color(0, string.len(zero_clip), color_clip:with_alpha(0.5))
        ammo_clip:set_font(Idstring("fonts/font_medium"))
        ammo_clip:set_font_size(21)

        if not self._last_ammo then
            self._last_ammo = {}
            self._last_ammo[ type ] = current_left
        end

        if not self._last_clip then
            self._last_clip = {}
            self._last_clip[type] = current_clip
        end

        if self._last_ammo and self._last_ammo[type] and self._last_ammo[type] < current_left then

            ammo_total:animate( function(o)
                local s = self._last_ammo[type]
                local e = current_left
                local font_size = 21
                over(0.5, function(p)
                    local value = math.lerp(s, e, p)
                    local text = string.format( "%.0f" , value )
                    local zero = math.round( value ) < 10 and "00" or math.round( value ) < 100 and "0" or ""

                    local low_ammo = value <= math.round(max / 3)
                    local out_of_ammo = value <= 0
                    local max_ammo = ( value == max or ((value + current_clip == max)))
                    local cheated_ammo = value > max

                    local color_total = out_of_ammo and Color(1, 0.9, 0.3, 0.3)
                    color_total = color_total or max_ammo and (Color("66ff99"))
                    color_total = color_total or low_ammo and Color("ffcc66")
                    color_total = color_total or cheated_ammo and Color.red
                    color_total = color_total or (Color("66ff99"))

                    ammo_total:set_text( zero .. text )
                    ammo_total:set_color( color_total )
                    ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
                end)
                over( 1 , function( p )
                    local n = 1 - math.sin((p / 2 ) * 180)

                    ammo_total:set_font_size( math.lerp(font_size, font_size + 4, n ))
                end)
            end)
        end

        if self._last_clip and self._last_clip[type] and self._last_clip[type] < current_clip and not self._bullet_storm then

            ammo_clip:animate( function(o)
                local s = self._last_clip[type]
                local e = current_clip
                over(0.25, function(p)
                    local value = math.lerp(s, e, p)
                    local text = string.format( "%.0f" , value )
                    local zero = math.round( value ) < 10 and "00" or math.round( value ) < 100 and "0" or ""

                    local low_clip = value <= math.round( max_clip / 4 )
                    local out_of_clip = value <= 0

                    local color_clip = out_of_clip and Color(1, 0.9, 0.3, 0.3)
                    color_clip = color_clip or low_clip and Color("ffcc66")
                    color_clip = color_clip or (Color("66ffff"))

                    ammo_clip:set_text(zero .. text)
                    ammo_clip:set_color(color_clip)
                    ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
                end )
            end )

        end

        self._last_ammo[type] = current_left
        self._last_clip[type] = current_clip
    end)
end

Hooks:PostHook(HUDTeammate, "_create_radial_health", "HMH_HUDTeammateCreateRadialHealth", function(self, radial_health_panel)
	local radial_ability_panel = radial_health_panel:child("radial_ability")
    local ability_icon = radial_ability_panel:child("ability_icon")
    
    if HMH:GetOption("health_texture") then
        self._radial_health_panel:child("radial_health"):set_image("guis/textures/pd2_mod_hmh/hud_health", 128, 0, -128, 128)
    end
    
	if HMH:GetOption("color_name") then
	    ability_icon:set_visible(false)
	end
end)