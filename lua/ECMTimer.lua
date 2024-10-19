local HMH = HMH
local math_sin = math.sin
local math_lerp = math.lerp

if RequiredScript == "lib/managers/hudmanagerpd2" then
	HUDECMCounter = HUDECMCounter or class()
	function HUDECMCounter:init(hud)
		self._ecm_timer = 0
		self._hud_panel = hud.panel
		self._ecm_panel = self._hud_panel:panel({
			name = "ecm_counter_panel",
			alpha = 1,
			visible = false,
			w = 200,
			h = 200
		})
		self._ecm_panel:set_top(50)
		self._ecm_panel:set_right(self._hud_panel:w() + 11)

		local ecm_box = HUDBGBox_create(self._ecm_panel, { w = 38, h = 38, },  {})
		if HMH:GetOption("assault") or HMH:GetOption("hide_hudbox") then
			for _, child in ipairs({"bg", "left_top", "left_bottom", "right_top", "right_bottom"}) do
				ecm_box:child(child):hide()
			end
		end

		self._text = ecm_box:text({
			name = "text",
			text = "0",
			valign = "center",
			align = "center",
			vertical = "center",
			w = ecm_box:w(),
			h = ecm_box:h(),
			layer = 1,
			color = HMH:GetColor("ECMText"),
			font = tweak_data.hud_corner.assault_font,
			font_size = tweak_data.hud_corner.numhostages_size * 0.9
		})

		local ecm_icon = self._ecm_panel:bitmap({
			name = "ecm_icon",
			texture = "guis/textures/pd2/skilltree/icons_atlas",
			texture_rect = { 1 * 64, 4 * 64, 64, 64 },
			valign = "top",
			color = HMH:GetColor("ECMIcon"),
			layer = 1,
			w = ecm_box:w(),
			h = ecm_box:h()	
		})
		ecm_icon:set_right(ecm_box:parent():w())
		ecm_icon:set_center_y(ecm_box:h() / 2)
		ecm_box:set_right(ecm_icon:left())
	end
	
	function HUDECMCounter:update()
		local current_time = TimerManager:game():time()
		local t = self._ecm_timer - current_time
		if managers.groupai and managers.groupai:state():whisper_mode() then
			self._ecm_panel:set_visible(t > 0)
			if t > 0.1 then
				local t_format = t < 10 and "%.1fs" or "%.fs"
				self._text:set_text(string.format(t_format, t))
				if t < 3 then
					self._text:set_color(HMH:GetColor("ecm_low"))
					self._text:animate(function(o)
						over(1 , function(p)
							t = t + coroutine.yield()
							local font = tweak_data.hud_corner.numhostages_size * 0.9
							local n = 1 - math_sin(t * 700)
							self._text:set_font_size( math_lerp(font , (font) * 1.05, n))
						end)
					end)
				elseif t < 9.9 then
					self._text:stop()
					self._text:set_color(HMH:GetColor("ecm_mid"))
				else
					self._text:stop()
					self._text:set_color(HMH:GetColor("ECMText"))
				end
			end
		else
			self._ecm_panel:set_visible(false)
		end
	end

	--Init
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_ECM_setup_player_info_hud_pd2", function(self, ...)
		self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		self:add_updator("HMH_ECM_UPDATOR", callback(self._hud_ecm_counter, self._hud_ecm_counter, "update"))
	end)

elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	--PeerID
	local original_spawn = ECMJammerBase.spawn
	function ECMJammerBase.spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
		local unit = original_spawn(pos, rot, battery_life_upgrade_lvl, owner, peer_id, ...)
		unit:base():SetPeersID(peer_id)
		return unit
	end

	Hooks:PostHook(ECMJammerBase, "set_server_information", "HMH_ECMJammerBase_set_server_information", function(self, peer_id, ...)
		self:SetPeersID(peer_id)
	end)

	Hooks:PostHook(ECMJammerBase, "sync_setup", "HMH_ECMJammerBase_sync_setup", function(self, upgrade_lvl, peer_id, ...)
		self:SetPeersID(peer_id)
	end)

	Hooks:PostHook(ECMJammerBase, "set_owner", "HMH_ECMJammerBase_set_owner", function(self, ...)
		self:SetPeersID(self._owner_id or 0)
	end)

	function ECMJammerBase:SetPeersID(peer_id)
		local id = peer_id or 0
		self._hmh_peer_id = id
		self._hmh_local_peer = id == managers.network:session():local_peer():id()
	end

	--ECM Timer Host and Client
	Hooks:PostHook(ECMJammerBase, "set_active", "HMH_ECMJammerBase_set_active", function(self, active, ...)
		if active and HMH:GetOption("infoboxes") then
			local battery_life = self:battery_life()
			if battery_life == 0 then
				return
			end
			local ecm_timer = TimerManager:game():time() + battery_life
			local jam_pagers = false
			if self._hmh_local_peer then
				jam_pagers = managers.player:has_category_upgrade("ecm_jammer", "affects_pagers")
			elseif self._hmh_peer_id ~= 0 then
				local peer = managers.network:session():peer(self._hmh_peer_id)
				if peer and peer._unit and peer._unit.base then
					jam_pagers = peer._unit:base():upgrade_value("ecm_jammer", "affects_pagers")
				end
			end
			if jam_pagers or not HMH:GetOption("pager_jam") then
				managers.hud._hud_ecm_counter._ecm_timer = ecm_timer
			else
				return
			end
		end
	end)

elseif RequiredScript == "lib/units/beings/player/playerinventory" then
	-- Pocket ECM
	Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "HMH_PlayerInventory_start_jammer_effect", function(self, end_time, ...)
		local ecm_timer = end_time or TimerManager:game():time() + self:get_jammer_time()
		if HMH:GetOption("infoboxes") and HMH:GetOption("pocket_ecm") and ecm_timer > managers.hud._hud_ecm_counter._ecm_timer then
			managers.hud._hud_ecm_counter._ecm_timer = ecm_timer
		end
	end)
end