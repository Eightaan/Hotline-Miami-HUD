if not HMH:GetOption("combo") then
	return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "HMH_Combo_setup_player_info_hud_pd2", function(self, ...)
		self._hud_combo_counter = HUDComboCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
		self:add_updator("HMH_CC_Updater", callback(self._hud_combo_counter, self._hud_combo_counter, "update"))
	end)

	function HUDManager:HMHCC_OnKillshot()
		self._hud_combo_counter:OnKillshot()
	end

	HUDComboCounter = HUDComboCounter or class()
	function HUDComboCounter:init(hud)
		self._t = 0
		self._kill_time = 0
		self._last_kill_time = 0
		self._kills = 0
		local font = "guis/textures/pd2_mod_hmh/hmcc_font"
		if not managers.dyn_resource:has_resource(Idstring("font"), Idstring(font), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
			managers.dyn_resource:load(Idstring("font"), Idstring(font), managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
		end
		self._hud_panel = hud.panel
		self._full_hud_panel = managers.hud._fullscreen_workspace:panel():gui(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2, {})
		self._combo_panel = self._full_hud_panel:panel({
			visible = false,
			name = "combo_panel",
			x = 0,
			y = 0,
			h = 256,
			w = 512,
			valign = "top",
			blend_mode = "normal"
		})
		self._combo_panel:set_top(40)
		local Combo_text = self._combo_panel:text({
			name = "Combo_text",
			visible = true,
			layer = 2,
			color = Color("e2087c"),
			text = "0",
			font_size = 96,
			font = font,
			x = 6,
			y = 0,
			align = "left",
			vertical = "top"
		})
		local Combo_text_bg = self._combo_panel:text({
			name = "Combo_text_bg",
			visible = true,
			layer = 1,
			color = Color.black,
			text="0",
			font_size = 96,
			font = font,
			x = 8,
			y = 1,
			align = "left",
			vertical = "top"
		})
		local Combo_bg = self._combo_panel:bitmap({
			name = "Combo_bg",
			visible = true,
			layer = 0,
			texture = "guis/textures/pd2_mod_hmh/hmcc_bg",
			x = 8,
			w = 200,
			h = 64,
			vertical = "top"
		})
		Combo_bg:set_left(self._full_hud_panel:left())
		Combo_bg:set_top(40 + 5)
		
		HMH._in_heist = true
	end
	
	local should_be_open = false
	function HUDComboCounter:set_combo(combo)
		local Combo_text = self._combo_panel:child("Combo_text")
		local Combo_text_bg = self._combo_panel:child("Combo_text_bg")
		local Combo_bg = self._combo_panel:child("Combo_bg")
		if combo > 1 and HMH._in_heist then
			should_be_open = true
			self._combo_panel:set_visible(true)  
		else
			should_be_open = false
			Combo_text:animate(callback(self, self, "close_anim"))
			Combo_text_bg:animate(callback(self, self, "close_anim"))
		end
		if combo .. "x" ~= Combo_text:text() and combo ~= 0 then
			Combo_text:set_text(combo.."x")
			Combo_text_bg:set_text(combo.."x")
			if combo == 2 then
				Combo_text:animate(callback(self, self, "open_anim"))
				Combo_text_bg:animate(callback(self, self, "open_anim"))
			end
			if combo > 9 then
				Combo_bg:set_w(240)
			end
			if combo > 99 then
				Combo_bg:set_w(310)
			end
		end
	end
	
	function HUDComboCounter:open_anim(panel)
		local speed = 50
		panel:set_x(-150)
		local distance = 50 - panel:x()
		local timespan = 10/speed
		local elapsed = 0
		local panel_y = HMH:GetOption("panel_position") or 40
		self._combo_panel:set_top(panel_y)
		while elapsed < timespan do
			if not should_be_open then return end
			local delta = coroutine.yield()
			elapsed = elapsed + delta
			panel:set_x( ( distance * ( elapsed / timespan ) ) - 150 )
		end
	end
	
	function HUDComboCounter:close_anim(panel)
		local speed = 50
		local distance = panel:x() + 150
		local timespan = 10/speed
		local elapsed = 0
		while elapsed < timespan do
			if should_be_open then break end
			local delta = coroutine.yield()
			elapsed = elapsed + delta
			panel:set_x( math.max( ( distance * ( 1 - ( elapsed / timespan ) ) ) - 150 , -150 ) )
		end
		local Combo_text = self._combo_panel:child("Combo_text")
		local Combo_text_bg = self._combo_panel:child("Combo_text_bg")
		self._combo_panel:set_visible(false) 
		self._combo_panel:set_x(0)
		Combo_text:set_x(6)
		Combo_text_bg:set_x(8)	
		Combo_text:animate(callback(self, self, "open_anim"))
		Combo_text_bg:animate(callback(self, self, "open_anim"))
	end

	function HUDComboCounter:flash_text(text)
		local TOTAL_T = 0.4
		local t = TOTAL_T
		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			local cv = math.abs((math.sin(t * 180 * 16)))
			text:set_color(Color("e2087c") * cv + Color("e2087c") * cv)
		end
		text:set_color(Color("e2087c"))
	end

	function HUDComboCounter:kill_anim(panel)
		local Combo_text = self._combo_panel:child("Combo_text")
		local Combo_text_bg = self._combo_panel:child("Combo_text_bg")
		over(0.4 , function(p)
			local n = 1 - math.sin((p / 2 ) * 180)
			Combo_text:set_font_size(math.lerp(96, 96 + 125, n))
			Combo_text_bg:set_font_size(math.lerp(96, 96 + 125, n))
		end)
	end

	function HUDComboCounter:OnKillshot()
		local Combo_text = self._combo_panel:child("Combo_text")
		local Combo_text_bg = self._combo_panel:child("Combo_text_bg")
		self._kills = self._kills + 1
		self._last_kill_time = self._kill_time
		self._kill_time = self._t
		if self._kills <= 2 then return end
		if HMH:GetOption("combo_kill_anim") then
			Combo_text:animate(callback(self, self, "kill_anim"))
			Combo_text_bg:animate(callback(self, self, "kill_anim"))
		end
		if HMH:GetOption("combo_kill_flash") then
			Combo_text:animate(callback(self, self, "flash_text"))
		end
	end

	local time_buffer = 3
	function HUDComboCounter:update(t, dt)
		self._t = t
		if (self._kill_time - self._last_kill_time) > time_buffer then
			self._kills = 1
		end
		if (t - self._kill_time) > time_buffer then
			self._kills = 0
		end
		self:set_combo(self._kills)
	end

elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PostHook(PlayerManager, "on_killshot", "HMH_PlayerManager_update", function(self, killed_unit)
		if not CopDamage.is_civilian(killed_unit:base()._tweak_table) then
			managers.hud:HMHCC_OnKillshot()
		end
	end)

elseif RequiredScript == "lib/utils/accelbyte/telemetry" then
	Hooks:PostHook(Telemetry, "on_end_heist", "HMH_Telemetry_on_end_heist", function(self)
		HMH._in_heist = false
	end)
end