if _G.IS_VR then
	return
end

local HMH = HMH
local Color = Color

local math_round = math.round
local math_lerp = math.lerp
local math_sin = math.sin
local math_max = math.max

local hud_interact_info_text = HMH:GetOption("interact_info") and not VoidUI
local hud_special_equipment = HMH:GetOption("pickups")
local hud_equipment = HMH:GetOption("equipment")
local hud_downs = HMH:GetOption("colored_downs")
local hud_ping = HMH:GetOption("ping")
local hud_ammo = HMH:GetOption("ammo")

if RequiredScript == "lib/managers/hud/hudteammate" then
	Hooks:PostHook(HUDTeammate, "init", "HMH_HUDTeammate_init", function(self, ...)
		if hud_interact_info_text then
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
		end
		
		if self._main_player and HMH:GetOption("bulletstorm") then
			self:infinite_ammo_glow()
		end
		
		self._next_latency_update_t = 0
		if hud_ping then
			self:_create_ping_info()
		end

		if HMH:GetOption("team_bg") then
			local function hide_bg(panel, ...)
				for _, name in ipairs({...}) do
					local child = panel and panel:child(name)
					if child then child:set_visible(false) end
				end
			end

			hide_bg(self._panel, "name_bg")
			hide_bg(self._cable_ties_panel, "bg")
			hide_bg(self._deployable_equipment_panel, "bg")
			hide_bg(self._grenades_panel, "bg")

			if self._player_panel then
				local weapons_panel = self._player_panel:child("weapons_panel")
				hide_bg(weapons_panel and weapons_panel:child("primary_weapon_panel"), "bg")
				hide_bg(weapons_panel and weapons_panel:child("secondary_weapon_panel"), "bg")
			end
		end
	end)

	function HUDTeammate:infinite_ammo_glow()
		self._prim_ammo = self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):bitmap({
			align = "center",
			w = 50,
			h = 40,
			name = "primary_ammo",
			visible = false,
			texture = "guis/textures/pd2/crimenet_marker_glow",
			texture_rect = { 1, 1, 62, 62 }, 
			color = Color("00AAFF"),
			layer = 2,
			blend_mode = "add"
		})
		self._sec_ammo = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):bitmap({
			align = "center",
			w = 50,
			h = 40,
			name = "secondary_ammo",
			visible = false,
			texture = "guis/textures/pd2/crimenet_marker_glow",
			texture_rect = { 1, 1, 62, 62 }, 
			color = Color("00AAFF"),
			layer = 2,
			blend_mode = "add"
		})
		self._prim_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
		self._sec_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
		self._prim_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):w() / 2)
		self._sec_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):w() / 2)
	end

	function HUDTeammate:_set_infinite_ammo(state)
		self._infinite_ammo = state
		if self._prim_ammo then
			if self._infinite_ammo then
				local hudinfo = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2)
				local pammo_clip = 	self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip")
				local sammo_clip = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip")

				self._prim_ammo:set_visible(true)
				self._sec_ammo:set_visible(true)
				self._prim_ammo:animate(hudinfo.flash_icon, 4000000000)
				self._sec_ammo:animate(hudinfo.flash_icon, 4000000000)

				pammo_clip:set_color(Color.white)
				pammo_clip:set_text("8")
				pammo_clip:set_rotation(90)
				if hud_ammo then
					pammo_clip:set_font_size(30)
					sammo_clip:set_font_size(30)
				end

				sammo_clip:set_color(Color.white)
				sammo_clip:set_text("8")
				sammo_clip:set_rotation(90)
			else
				self._prim_ammo:set_visible(false)
				self._sec_ammo:set_visible(false)
			end
		end
	end

	if hud_interact_info_text then
		Hooks:PostHook(HUDTeammate, "set_name", "HMH_HUDTeammate_set_name", function(self, ...)
			local teammate_panel = self._panel
			local name = teammate_panel:child("name")
			local name_bg = teammate_panel:child("name_bg")

			if self._panel:child("name_panel"):w() < name_bg:w() and not self._main_player then
				name:set_font_size(tweak_data.hud_players.name_size * 0.75)
				name_bg:set_w(name:w() - 45)
			elseif self._panel:child("name_panel"):w() < name_bg:w() and self._main_player then
				name:set_font_size(tweak_data.hud_players.name_size * 0.75)
				name_bg:set_w(name:w() - 45)
			end
		end)

		Hooks:PreHook(HUDTeammate, "teammate_progress", "HMH_HUDTeammate_teammate_progress", function(self, enabled, tweak_data_id, timer, success, ...)
			local t = 1 -- How long an interaction should be in order for the text to display. If its shorter than 1 sec nothing will show when at default.
			if not self._player_panel:child("interact_panel"):child("interact_info") then return end

			if enabled and not self._main_player and self:peer_id() and timer >= t then
				self._panel:child("name"):set_alpha(0)
				self._panel:child("name_panel"):child("interact_text"):set_visible(true)
				self._panel:child("name_panel"):child("interact_text"):set_text(" " .. managers.hud:_name_label_by_peer_id(self:peer_id()).panel:child("action"):text())

				local x, y, w, h = self._panel:child("name_panel"):child("interact_text"):text_rect()
				self._panel:child("name_bg"):set_w( w + 4)
				self._panel:child("name_panel"):child("interact_text"):set_size(w, h)

				if self._panel:child("name_panel"):child("interact_text"):w() + 4 > self._panel:child("name_bg"):w() then
					self._panel:child("name_bg"):set_w(self._panel:child("name_panel"):child("interact_text"):w() + 4)
				end

				if self._panel:child("name_panel"):w() < self._panel:child("name_panel"):child("interact_text"):w() + 4 then
					self._panel:child("name_panel"):child("interact_text"):set_font_size(tweak_data.hud_players.name_size * 0.75)
					self._panel:child("name_bg"):set_w(self._panel:child("name_panel"):child("interact_text"):w() - 45)
				end

			elseif not success and not self._main_player then
				local x, y, w, h =  self._panel:child("name"):text_rect()
				self._panel:child("name"):set_size(w, h)
				self._panel:child("name_panel"):child("interact_text"):stop()
				self._panel:child("name_panel"):child("interact_text"):set_left(0)

				self._panel:child("name"):set_alpha(1)
				self._panel:child("name_panel"):child("interact_text"):set_visible(false)
				self._panel:child("name_panel"):child("interact_text"):set_font_size(tweak_data.hud_players.name_size)
				self._panel:child("name_bg"):set_w( w + 4)
			end

			if success then
				self._panel:child("name"):set_alpha(1)
				self._panel:child("name_panel"):child("interact_text"):set_font_size(tweak_data.hud_players.name_size)
				self._panel:child("name_panel"):child("interact_text"):set_visible(false)
				local x, y, w , h =  self._panel:child("name"):text_rect()
				self._panel:child("name_bg"):set_w( w + 4)
			end

			self._panel:child("name_panel"):child("interact_text"):set_color(tweak_data.chat_colors[self._peer_id] or Color.white)

			if not self._main_player and self:peer_id() then
				local peer = managers.network:session() and managers.network:session():peer(self:peer_id())
				if peer and peer:is_cheater() then
					self._panel:child("name_panel"):child("interact_text"):set_color(tweak_data.screen_colors.pro_color or Color.white)
				end
			end
		end)
	end

	if hud_downs then 
		Hooks:PostHook(HUDTeammate, "set_revives_amount", "HMH_HUDTeammate_set_revives_amount", function(self, revive_amount, ...)
			if revive_amount then
				local teammate_panel = self._panel:child("player")
				local revive_panel = teammate_panel:child("revive_panel")
				local revive_amount_text = revive_panel:child("revive_amount")
				local revive_arrow = revive_panel:child("revive_arrow")
				local revive_bg = revive_panel:child("revive_bg")
				local team_color = self._peer_id and tweak_data.chat_colors[self._peer_id] or (not self._ai and tweak_data.chat_colors[managers.network:session():local_peer():id()]) or Color.white
				local bg_alpha = HMH:GetOption("team_bg") and 0 or 0.6

				if revive_amount_text then
					revive_amount_text:set_text(tostring(math_max(revive_amount - 1, 0)))
					revive_amount_text:set_color(revive_amount > 1 and team_color or Color.red)
					revive_amount_text:set_font_size(17)
					revive_amount_text:animate(function(o)
						over(1, function(p)
							local n = 1 - math_sin((p / 2 ) * 180)
							revive_amount_text:set_font_size(math_lerp(17, 17 * 0.85, n))
						end)
					end)
				end

				if revive_arrow then 
					revive_arrow:set_color(revive_amount > 1 and team_color or Color.red) 
				end

				if revive_bg then
					revive_bg:set_color(Color.black / 3)
					revive_bg:set_alpha(bg_alpha)
				end
			end
		end)
	end

	if hud_special_equipment then
		Hooks:OverrideFunction(HUDTeammate, "add_special_equipment", function(self, data)
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
		end)
	end

	if hud_equipment then
		Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount", "HMH_HUDTeammate_set_deployable_equipment_amount", function(self, index, data, ...)
			local deployable_equipment_panel = self._player_panel:child("deployable_equipment_panel")
			local equipment = deployable_equipment_panel:child("equipment")
			local amount = deployable_equipment_panel:child("amount")

			equipment:stop()

			if data.amount > 0 then
				equipment:set_alpha(1)
				equipment:set_color(HMH:GetColor("EquipmentIcon"))
				amount:set_alpha(1)
				amount:set_color(HMH:GetColor("EquipmentText"))
			end

			if data.amount > 0 then
				equipment:animate(function(o)
					over(1, function(p)
						local n = 1 - math_sin((p / 2) * 180)
						equipment:set_alpha(math_lerp(1, 0.2, n))
					end)
				end)
			elseif data.amount == 0 then
				equipment:animate(function(o)
					equipment:set_color(HMH:GetColor("EquipmentIcon"))
					over(1, function(p)
						equipment:set_alpha(0.2)
						amount:set_alpha(0.2)
					end)
				end)
			end
		end)

		Hooks:PostHook(HUDTeammate, "set_grenades_amount", "HMH_HUDTeammate_set_grenades_amount", function(self, data, ...)
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
				grenades:set_color(HMH:GetColor("GrenadeIcon"))
				amount:set_color(HMH:GetColor("GrenadeText"))
				amount:set_alpha(1)
			end

			if self._grenade_amount ~= data.amount and data.amount > 0 then
				grenades:animate( function(o)
					over(1, function(p)
						local n = 1 - math_sin((p / 2 ) * 180)
						grenades:set_alpha(math_lerp(1, 0.2, n))
					end)
				end)
			elseif data.amount == 0 then
				grenades:animate( function(o)
					grenades:set_color(HMH:GetColor("GrenadeIcon"))
					over(1, function(p)
						grenades:set_alpha(0.2)
						amount:set_alpha(0.2)
					end)
				end)
			end

			self._grenade_amount = data.amount
		end)

		Hooks:PostHook(HUDTeammate, "set_cable_ties_amount", "HMH_HUDTeammate_set_cable_ties_amount", function(self, amount, ...)
			if not self._cable_amount then self._cable_amount = amount end

			local cable_ties_panel = self._player_panel:child("cable_ties_panel")
			local cable_ties = cable_ties_panel:child("cable_ties")
			local cable_ties_amount = cable_ties_panel:child("amount")

			cable_ties:stop()

			if amount > 0 then
				cable_ties:set_alpha(1)
				cable_ties:set_color(HMH:GetColor("CabletiesIcon"))
				cable_ties_amount:set_color(HMH:GetColor("CabletiesText"))
				cable_ties_amount:set_alpha(1)
			end

			if self._cable_amount ~= amount and amount > 0 then
				cable_ties:animate(function(o)
					over(1, function(p)
						local n = 1 - math_sin((p / 2 ) * 180)
						cable_ties:set_alpha(math_lerp(1, 0.2, n))
					end)
				end)
			elseif amount == 0 then
				cable_ties:animate(function(o)
					cable_ties:set_color(HMH:GetColor("CabletiesIcon"))
					over(1, function(p)
						cable_ties:set_alpha(0.2)
						cable_ties_amount:set_alpha(0.2)
					end)
				end)
			end
		end)

		Hooks:PostHook(HUDTeammate, "set_deployable_equipment_amount_from_string", "HMH_HUDTeammate_set_deployable_equipment_amount_from_string", function(self, index, data, ...)
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
					color = HMH:GetColor("EquipmentText")
					alpha = 1
				end
			end
			icon:set_color(HMH:GetColor("EquipmentIcon"))
			icon:set_alpha(alpha)
			amount:set_alpha(alpha)
			amount:set_color(color)
		end)

		Hooks:PostHook(HUDTeammate, "set_waiting", "HMH_HUDTeammate_set_waiting", function(self, waiting, peer)
			if self._wait_panel then
				if waiting then
					local color_id = peer:id()
					local color = tweak_data.chat_colors[color_id] or tweak_data.chat_colors[#tweak_data.chat_colors]
					local name = self._wait_panel:child("name")
					name:set_color(HMH:GetOption("promt") and color or Color.white)
					self._wait_panel:child("throw"):child("icon"):set_color(HMH:GetColor("EquipmentIcon"))
					self._wait_panel:child("perk"):child("icon"):set_color(HMH:GetColor("EquipmentIcon"))
					self._wait_panel:child("deploy"):child("icon"):set_color(HMH:GetColor("EquipmentIcon"))   
					self._wait_panel:child("deploy"):child("amount"):set_color(HMH:GetColor("EquipmentText"))
					self._wait_panel:child("throw"):child("amount"):set_color(HMH:GetColor("EquipmentText"))
					self._wait_panel:child("perk"):child("amount"):set_color(HMH:GetColor("EquipmentText"))
				end
			end
		end)
		
		Hooks:PostHook(HUDTeammate, "animate_grenade_flash", "HMH_HUDTeammate_animate_grenade_flash", function(self, ...)
			local teammate_panel = self._panel:child("player")
			local grenades_panel = self._player_panel:child("grenades_panel")
			local radial = grenades_panel:child("grenades_radial")
			local icon = grenades_panel:child("grenades_icon")
			local radial_ghost = grenades_panel:child("grenades_radial_ghost")
			local icon_ghost = grenades_panel:child("grenades_icon_ghost")

			local function animate_flash()
				local radial_w, radial_h = radial:size()
				local radial_x, radial_y = radial:center()
				local icon_w, icon_h = icon:size()
				local icon_x, icon_y = icon:center()

				radial_ghost:set_visible(true)
				icon_ghost:set_visible(true)
				over(0.6, function (p)
					local color = Color(1 - p, 1, 1, 1)
					local scale = 1 + p

					radial_ghost:set_color(color)
					radial_ghost:set_size(radial_w * scale, radial_h * scale)
					radial_ghost:set_center(radial_x, radial_y)
					icon_ghost:set_color(HMH:GetColor("GrenadeIcon"))
					icon_ghost:set_size(icon_w * scale, icon_h * scale)
					icon_ghost:set_center(icon_x, icon_y)
				end)
				radial_ghost:set_visible(false)
				radial_ghost:set_size(radial_w, radial_h)
				radial_ghost:set_center(radial_x, radial_y)
				icon_ghost:set_visible(false)
				icon_ghost:set_size(icon_w, icon_h)
				icon_ghost:set_center(icon_x, icon_y)
			end

			grenades_panel:stop()
			grenades_panel:animate(animate_flash)
		end)
	end

	if hud_ammo then
		local function selected(o)
			over(0.5, function(p)
				o:set_alpha(math_lerp(0.5, 1, p))
			end)
		end
		local function unselected(o)
			over(0.5, function(p)
				o:set_alpha(math_lerp(1, 0.5, p))
			end)
		end
		Hooks:PreHook(HUDTeammate, "set_weapon_selected", "HMH_HUDTeammate_set_weapon_selected", function(self, id, hud_icon, ...)
			if not self._player_panel:child("weapons_panel"):child("secondary_weapon_panel") then return end
			local is_secondary = id == 1
			local secondary_weapon_panel = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel")
			local primary_weapon_panel = self._player_panel:child("weapons_panel"):child("primary_weapon_panel")

			secondary_weapon_panel:stop()
			primary_weapon_panel:stop()

			if is_secondary then
				primary_weapon_panel:animate(unselected)
				secondary_weapon_panel:animate(selected)
			else
				secondary_weapon_panel:animate(unselected)
				primary_weapon_panel:animate(selected)
			end
		end)

		Hooks:PostHook(HUDTeammate, "_create_weapon_panels", "HMH_HUDTeammate_create_weapon_panels", function(self, weapons_panel, ...)
			local primary_weapon_panel = weapons_panel:child("primary_weapon_panel")
			local secondary_weapon_panel = weapons_panel:child("secondary_weapon_panel")
			local sec_weapon_selection_panel = secondary_weapon_panel:child("weapon_selection")
			local prim_weapon_selection_panel = primary_weapon_panel:child("weapon_selection")

			prim_weapon_selection_panel:child("weapon_selection"):set_color(HMH:GetColor("PrimFiremode"))
			sec_weapon_selection_panel:child("weapon_selection"):set_color(HMH:GetColor("SecFiremode"))
		end)
	end

	Hooks:PostHook(HUDTeammate, "set_ammo_amount_by_type", "HMH_HUDTeammate_set_ammo_amount_by_type", function(self, type, max_clip, current_clip, current_left, max, weapon_panel)
		local weapon_panel = self._player_panel:child("weapons_panel"):child(type .. "_weapon_panel")
		local ammo_clip = weapon_panel:child("ammo_clip")

		if self._alt_ammo and ammo_clip:visible() then
			current_left = math_max(0, current_left - max_clip - (current_clip - max_clip))
		end
		
		local low_ammo = current_left <= math_round(max_clip / 2)
		local low_ammo_color = hud_ammo and HMH:GetColor("LowAmmo") or Color(1, 0.9, 0.9, 0.3)
		local total_ammo_color = hud_ammo and HMH:GetColor("TotalAmmo") or Color.white
		
		local out_of_ammo = current_left <= 0
		local color_total = out_of_ammo and Color(1 , 0.9 , 0.3 , 0.3)
		
		color_total = color_total or low_ammo and (low_ammo_color)
		color_total = color_total or (total_ammo_color)
		
		local out_of_clip = current_clip <= 0
		local color_clip = out_of_clip and Color(1 , 0.9 , 0.3 , 0.3)
		local low_clip = current_clip <= math_round(max_clip / 4)
		local clip_ammo_color = hud_ammo and HMH:GetColor("ClipAmmo") or Color.white
		
		color_clip = color_clip or low_clip and (low_ammo_color)
		color_clip = color_clip or (clip_ammo_color)
		
		local ammo_total = weapon_panel:child("ammo_total")
		local zero = current_left < 10 and "00" or current_left < 100 and "0" or ""

		ammo_total:set_text(zero ..tostring(current_left))
		ammo_total:set_color(color_total)
		ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))

		local zero_clip = current_clip < 10 and "00" or current_clip < 100 and "0" or ""

		ammo_clip:set_color(color_clip)
		ammo_clip:set_range_color(0, string.len(zero_clip), color_clip:with_alpha(0.5))

		if hud_ammo then
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
						local value = math_lerp(s, e, p)
						local text = string.format("%.0f", value)
						local zero = math_round(value) < 10 and "00" or math_round(value) < 100 and "0" or ""
						local low_ammo = value <= math_round(max_clip / 2)
						local out_of_ammo = value <= 0
						local color_total = out_of_ammo and Color(1, 0.9, 0.3, 0.3)
						color_total = color_total or low_ammo and low_ammo_color
						color_total = color_total or (total_ammo_color)

						ammo_total:set_text(zero .. text)
						ammo_total:set_color(color_total)
						ammo_total:set_range_color(0, string.len(zero), color_total:with_alpha(0.5))
					end)
					over(1 , function(p)
						local n = 1 - math_sin((p / 2 ) * 180)

						ammo_total:set_font_size(math_lerp(ammo_font, ammo_font + 4, n))
					end)
				end)
			end

			if self._last_clip and self._last_clip[type] and self._last_clip[type] < current_clip and not self._infinite_ammo then
				ammo_clip:animate(function(o)
					local s = self._last_clip[type]
					local e = current_clip
					over(0.25, function(p)
						local value = math_lerp(s, e, p)
						local text = string.format( "%.0f", value)
						local zero = math_round(value) < 10 and "00" or math_round(value) < 100 and "0" or ""
						local low_clip = value <= math_round(max_clip / 4)
						local out_of_clip = value <= 0
						local color_clip = out_of_clip and Color(1, 0.9, 0.3, 0.3)

						color_clip = color_clip or low_clip and low_ammo_color
						color_clip = color_clip or (clip_ammo_color)

						ammo_clip:set_text(zero .. text)
						ammo_clip:set_color(color_clip)
						ammo_clip:set_range_color(0, string.len(zero), color_clip:with_alpha(0.5))
					end)
					over(1 , function(p)
						local n = 1 - math_sin((p / 2 ) * 180)
						ammo_clip:set_font_size(math_lerp(24, 24 + 4, n))
					end)
				end)
			end
			self._last_ammo[type] = current_left
			self._last_clip[type] = current_clip
		end

		if self._main_player and self._infinite_ammo then
			ammo_clip:set_color(Color.white)
			ammo_clip:set_text( "8" )
			ammo_clip:set_rotation(90)
			if hud_ammo then
				ammo_clip:set_font_size(30)
			end
		else
			ammo_clip:set_rotation(0)
		end
	end)

	Hooks:PostHook(HUDTeammate, "_create_radial_health", "HMH_HUDTeammate_create_radial_health", function(self, radial_health_panel, ...)
		local radial_ability_panel = radial_health_panel:child("radial_ability")
		local ability_icon = radial_ability_panel:child("ability_icon")
		ability_icon:set_color(HMH:GetColor("Ability_icon_color") or Color.white)
		ability_icon:set_visible(HMH:GetOption("ability_icon"))
	end)

	Hooks:PostHook(HUDTeammate, "set_callsign", "HMH_HUDTeammate_set_callsign", function(self, id, ...)
		if HMH:GetOption("color_condition") then
			self._condition_icon = self._panel:child("condition_icon")
			self._condition_icon:set_color(tweak_data.chat_colors[id])
		end
	end)

	Hooks:PreHook(HUDTeammate, "set_carry_info", "HMH_HUDTeammate_set_carry_info", function(self, ...)
		if self._peer_id then
			self._player_panel:child("carry_panel"):child("bag"):set_color(HMH:GetOption("color_bag") and tweak_data.chat_colors[self._peer_id] or Color.white)
		end
	end)

	function HUDTeammate:update(t, dt, ...)
		if hud_ping then
			self:update_latency(t, dt)
		end
	end

	function HUDTeammate:update_latency(t, dt)
		local ping_panel = self._panel:child("latency")
		if ping_panel and self:peer_id() and t > self._next_latency_update_t then
			local net_session = managers.network:session()
			local peer = net_session and net_session:peer(self:peer_id())
			local latency = peer and Network:qos(peer:rpc()).ping or "n/a"

			if type(latency) == "number" then
				ping_panel:set_text(string.format("%.0fms", latency))
				ping_panel:set_color(latency < 75 and  tweak_data.chat_colors[1] or latency < 150 and  tweak_data.chat_colors[4] or  tweak_data.chat_colors[3])
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
			visible = HMH:GetOption("ping"),
			color = Color.white,
			x = -12,
			y = name_panel:y() - tweak_data.hud.small_font_size,
			h = 50
		})
	end

elseif RequiredScript == "lib/units/beings/player/playerdamage" then
	local PlayerDamage_restore_health = PlayerDamage.restore_health
	function PlayerDamage:restore_health(health_restored, ...)
		if health_restored * self._healing_reduction == 0 then
			return
		end
		return PlayerDamage_restore_health(self, health_restored, ...)
	end
end