if RequiredScript == "lib/managers/hudmanagerpd2" then

	HUDECMCounter = HUDECMCounter or class()
    function HUDECMCounter:init(hud)
	    self._hud_panel = hud.panel
	    self._ecm_panel = self._hud_panel:panel({
		    name = "ecm_counter_panel",
		    visible = false,
		    w = 200,
		    h = 200
	    })

	    self._ecm_panel:set_top(50)
        self._ecm_panel:set_right(self._hud_panel:w() + 11)

	    local ecm_box = HUDBGBox_create(self._ecm_panel, { w = 38, h = 38, },  {})

        local ecm_text_color
		local pager_icon_color
		local ecm_icon_color
		if HMH:GetOption("assault") and BeardLib and hotlinemiamihud then
		    ecm_icon_color = hotlinemiamihud.Options:GetValue("ECMIcon")
			pager_icon_color = hotlinemiamihud.Options:GetValue("ECMUpgradeIcon")
			ecm_text_color = hotlinemiamihud.Options:GetValue("ECMText")
		else
		    ecm_icon_color = HMH:GetOption("assault") and Color("ff80df") or Color.white
			pager_icon_color = HMH:GetOption("assault") and Color("66ff99") or Color.white
			ecm_text_color = HMH:GetOption("assault") and Color("66ffff") or Color.white
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
		    color = ecm_text_color,
		    font = tweak_data.hud_corner.assault_font,
		    font_size = tweak_data.hud_corner.numhostages_size * 0.9
	    })

	    local ecm_icon = self._ecm_panel:bitmap({
		    name = "ecm_icon",
		    texture = "guis/textures/pd2/skilltree/icons_atlas",
		    texture_rect = { 1 * 64, 4 * 64, 64, 64 },
		    valign = "top",
			color = ecm_icon_color,
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
			color = pager_icon_color,
		    layer = 2,
		    w = ecm_box:w() / 2,
		    h = ecm_box:h() / 2
	    })
		pager_icon:set_right(self._ecm_panel:w() - 20 )
		pager_icon:set_center_y(ecm_box:h())
    end

    function HUDECMCounter:update(t)
	    self._ecm_panel:set_visible(HMH:GetOption("infoboxes") and managers.groupai:state():whisper_mode() and t > 0 )
		local text_color
		if HMH:GetOption("assault") and BeardLib and hotlinemiamihud then
		    text_color = hotlinemiamihud.Options:GetValue("ECMText")
		else
		    text_color = HMH:GetOption("assault") and Color("66ffff") or Color.white
		end
	    if t > 0 then
		    self._text:set_text(string.format("%.fs", t))
		    self._text:set_color(text_color)
        end	
    end

	function HUDECMCounter:update_icons(jam_pagers)
        local pager_icon = self._ecm_panel:child("pager_icon")
        pager_icon:set_visible(jam_pagers and HMH:GetOption("pager_jam"))
    end

    local _setup_player_info_hud_pd2_original = HUDManager._setup_player_info_hud_pd2
    function HUDManager:_setup_player_info_hud_pd2(...)
	    _setup_player_info_hud_pd2_original(self, ...)
	    self._hud_ecm_counter = HUDECMCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
    end

    function HUDManager:update_ecm(t)
	    self._hud_ecm_counter:update(t)
    end

	function HUDManager:update_ecm_icons(jam_pagers)
        self._hud_ecm_counter:update_icons(jam_pagers)
    end

elseif RequiredScript == "lib/units/equipment/ecm_jammer/ecmjammerbase" then

    local setup_original = ECMJammerBase.setup
    local sync_setup_original = ECMJammerBase.sync_setup
    local destroy_original = ECMJammerBase.destroy
    local load_original = ECMJammerBase.load
    local update_original = ECMJammerBase.update

    function ECMJammerBase:_check_new_ecm()
	    if not ECMJammerBase._max_ecm or ECMJammerBase._max_ecm:battery_life() < self:battery_life() then
			ECMJammerBase._max_ecm = self
	    end
    end

    function ECMJammerBase:sync_setup(upgrade_lvl, ...)
	    sync_setup_original(self, upgrade_lvl, ...)
	    self:_check_new_ecm()
		managers.hud:update_ecm_icons(upgrade_lvl == 3)
    end

    function ECMJammerBase:setup(battery_life_upgrade_lvl, ...)
	    setup_original(self, battery_life_upgrade_lvl, ...)
	    self:_check_new_ecm()
		managers.hud:update_ecm_icons(battery_life_upgrade_lvl == 3)
    end

    function ECMJammerBase:destroy(...)
	    if ECMJammerBase._max_ecm == self then
		    ECMJammerBase._max_ecm = nil
		    managers.hud:update_ecm(0)
	    end
		
	    return destroy_original(self, ...)
    end

    function ECMJammerBase:load(...)
	    load_original(self, ...)
	    self:_check_new_ecm()
    end

    function ECMJammerBase:update(unit, t, ...)
	    update_original(self, unit, t, ...)
	    if ECMJammerBase._max_ecm == self then
		    managers.hud:update_ecm(self:battery_life())
	    end 
    end
end