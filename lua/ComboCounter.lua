if not HMH:GetOption("combo") then 
    return
end

if RequiredScript == "lib/managers/hudmanagerpd2" then
    Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "Combo_setup_player_info_hud_pd2", function(self, ...)
        self._hud_combo_counter = HUDComboCounter:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
        self:add_updator("HHM_CC_Updater", callback(self._hud_combo_counter, self._hud_combo_counter, "update"))
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
            font = "guis/textures/pd2_mod_hmh/hmcc_font",
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
            font = "guis/textures/pd2_mod_hmh/hmcc_font",
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
    end

    function HUDComboCounter:set_combo(combo)
        local Combo_text = self._combo_panel:child("Combo_text")
        local Combo_text_bg = self._combo_panel:child("Combo_text_bg")
        local Combo_bg = self._combo_panel:child("Combo_bg")
        self._combo_panel:set_visible(combo > 1)
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
        panel:set_visible(true)
        local TOTAL_T = 10/speed
        local t = TOTAL_T
        while t > 0 do
            local dt = coroutine.yield()
            t = t - dt
            panel:set_x((1 - t / TOTAL_T) * 60)
        end
    end

    function HUDComboCounter:OnKillshot()
        self._kills = self._kills + 1
        self._last_kill_time = self._kill_time
        self._kill_time = self._t
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
    Hooks:PostHook(PlayerManager, "on_killshot", "combo_update", function(self, killed_unit)
        if not CopDamage.is_civilian(killed_unit:base()._tweak_table) then
            managers.hud:HMHCC_OnKillshot()
        end
    end)
end