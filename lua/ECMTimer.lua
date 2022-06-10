if RequiredScript == "lib/managers/hudmanagerpd2" then
	HUDECMCounter = HUDECMCounter or class()

    function HUDECMCounter:init(hud)
		self._end_time = 0
		self._nonpager_end_time = 0
		
	    self._hud_panel = hud.panel
	    self._ecm_panel = self._hud_panel:panel({
		    name = "ecm_counter_panel",
			alpha = HMH:GetOption("infoboxes") or 0,
		    visible = false,
		    w = 200,
		    h = 200
	    })

	    self._ecm_panel:set_top(50)
        self._ecm_panel:set_right(self._hud_panel:w() + 11)

	    local ecm_box = HUDBGBox_create(self._ecm_panel, { w = 38, h = 38, },  {})
		
		if HMH:GetOption("assault") or HMH:GetOption("hide_hudbox") then
		   ecm_box:child("bg"):hide()
		   ecm_box:child("left_top"):hide()
		   ecm_box:child("left_bottom"):hide()
		   ecm_box:child("right_top"):hide()
		   ecm_box:child("right_bottom"):hide()
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
        
		local pagers_texture, pagers_rect = tweak_data.hud_icons:get_icon_data("pagers_used")
		local pager_icon = self._ecm_panel:bitmap({
		    name = "pager_icon",
		    texture = pagers_texture,
		    texture_rect = pagers_rect,
		    valign = "top",
			visible = false,
			color = HMH:GetColor("ECMUpgradeIcon"),
		    layer = 2,
		    w = ecm_box:w() / 2,
		    h = ecm_box:h() / 2
	    })
		pager_icon:set_right(self._ecm_panel:w() - 20 )
		pager_icon:set_center_y(ecm_box:h())

		self._active_ecm = false
		self._pocket_ecm = false
		self._pager_block = false
    end

    function HUDECMCounter:update()
		local current_time = TimerManager:game():time()
		local t = self._end_time - current_time
		if t < 0 then
			t = self._nonpager_end_time - current_time
			if t > 0 then
				self._end_time = self._nonpager_end_time
				self._pocket_ecm = false
				managers.hud:update_ecm_icons(false)
			end
		end
		if managers.groupai:state():whisper_mode() then
			self._ecm_panel:set_visible(t > 0)
			
			if t > 0.1 then
			    local t_format = t < 10 and "%.1fs" or "%.fs"
				self._active_ecm = true
				self._text:set_text(string.format(t_format, t))
				
			    if t < 3 then
				    self._text:set_color(HMH:GetColor("ecm_low"))
				    self._text:animate(function(o)
                    over(1 , function(p)
					    t = t + coroutine.yield()
						local font = tweak_data.hud_corner.numhostages_size * 0.9
                        local n = 1 - math.sin(t * 700)
                        self._text:set_font_size( math.lerp(font , (font) * 1.05, n))
                    end)
                end)

			    elseif t < 9.9 then
				    self._text:stop()
				    self._text:set_color(HMH:GetColor("ecm_mid"))
			    else
				    self._text:stop()
				    self._text:set_color(HMH:GetColor("ECMText"))
			    end
			else
				self._active_ecm = false
			end
		else
			self._ecm_panel:set_visible(false)
		end
    end

	function HUDECMCounter:update_icons(jam_pagers)
        local pager_icon = self._ecm_panel:child("pager_icon")
        pager_icon:set_visible(jam_pagers and HMH:GetOption("pager_jam"))
		self._pager_block = jam_pagers
    end

	--Init
	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "buuECM_post_HUDManager__setup_player_info_hud_pd2", function(self)
		self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
	end)
	
	--Update ECM timer
	Hooks:PostHook(HUDManager, "update", "buuECM_post_HUDManager_update", function(self)
		self._hud_ecm_counter:update()
	end)

	function HUDManager:update_ecm_icons(jam_pagers)
        self._hud_ecm_counter:update_icons(jam_pagers)
    end

elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then
	
	Hooks:PostHook(ECMJammerBase, "setup", "buuECM_post_ECMJammerBase_setup", function(self, battery_life_upgrade_lvl, ...)
		local new_end_time = TimerManager:game():time() + self:battery_life()
		if new_end_time > managers.hud._hud_ecm_counter._end_time then
			if battery_life_upgrade_lvl ~= 3 then
				managers.hud._hud_ecm_counter._nonpager_end_time = new_end_time
				if (managers.hud._hud_ecm_counter._pager_block == false or managers.hud._hud_ecm_counter._active_ecm == false) then
					managers.hud._hud_ecm_counter._end_time = new_end_time
					managers.hud:update_ecm_icons(battery_life_upgrade_lvl == 3)
				end
			else
				managers.hud._hud_ecm_counter._end_time = new_end_time
				managers.hud:update_ecm_icons(battery_life_upgrade_lvl == 3)
			end
			managers.hud._hud_ecm_counter._pocket_ecm = false
		end
	end)
	
	Hooks:PostHook(ECMJammerBase, "sync_setup", "buuECM_post_ECMJammerBase_sync_setup", function(self, upgrade_lvl, ...)
		local new_end_time = TimerManager:game():time() + self:battery_life()
		if new_end_time > managers.hud._hud_ecm_counter._end_time then
			if upgrade_lvl ~= 3 then
				managers.hud._hud_ecm_counter._nonpager_end_time = new_end_time
				if (managers.hud._hud_ecm_counter._pager_block == false or managers.hud._hud_ecm_counter._active_ecm == false) then
					managers.hud._hud_ecm_counter._end_time = new_end_time
					managers.hud:update_ecm_icons(upgrade_lvl == 3)
				end
			else
				managers.hud._hud_ecm_counter._end_time = new_end_time
				managers.hud:update_ecm_icons(upgrade_lvl == 3)
			end
			managers.hud._hud_ecm_counter._pocket_ecm = false
		end
	end)

	Hooks:PostHook(ECMJammerBase, "update", "buuECM_ECMJammerBase_update", function(self, unit, t, ...)
		if (managers.hud._hud_ecm_counter._end_time == 0) then
			local new_end_time = TimerManager:game():time() + self:battery_life()
			managers.hud._hud_ecm_counter._end_time = new_end_time
			managers.hud:update_ecm_icons(false)
			managers.hud._hud_ecm_counter._active_ecm = true
			managers.hud._hud_ecm_counter._pocket_ecm = false
		end
	end)
	
elseif RequiredScript == "lib/units/beings/player/playerinventory" then
	Hooks:PostHook(PlayerInventory, "_start_jammer_effect", "buuECM_post_PlayerInventory__start_jammer_effect", function(self, end_time)
		local new_end_time = end_time or TimerManager:game():time() + self:get_jammer_time()
		if new_end_time > managers.hud._hud_ecm_counter._end_time or managers.hud._hud_ecm_counter._pager_block == false then
			managers.hud._hud_ecm_counter._end_time = new_end_time
			managers.hud:update_ecm_icons(true)
			managers.hud._hud_ecm_counter._pocket_ecm = true
		end
	end)
end