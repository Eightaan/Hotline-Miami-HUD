if not (HMH:GetOption("PLAYER_down") or HMH:GetOption("TEAM_down")) or VHUDPlus and VHUDPlus:getSetting({"CustomHUD", "ENABLED"}, true) and VHUDPlus:getSetting({"CustomHUD", "TEAMMATE", "DOWNCOUNTER"}, true) or WolfHUD and WolfHUD:getSetting({"CustomHUD", "ENABLED"}, true) or (restoration and restoration:all_enabled("HUD/MainHUD", "HUD/Teammate")) then return 
end

if RequiredScript == "lib/managers/hudmanagerpd2" then

    local set_mugshot_downed_original = HUDManager.set_mugshot_downed
    local set_mugshot_custody_original = HUDManager.set_mugshot_custody
    local set_mugshot_normal_original = HUDManager.set_mugshot_normal
    local set_player_condition_original = HUDManager.set_player_condition

    function HUDManager:teammate_panel_from_peer_id(id)
        for panel_id, panel in pairs(self._teammate_panels or {}) do
            if panel._peer_id == id then
                return panel_id
            end
        end
    end

    function HUDManager:set_mugshot_downed(id)
        local panel_id = self:_mugshot_id_to_panel_id(id)
        local unit = self:_mugshot_id_to_unit(id)
        if panel_id and unit and unit:movement().current_state_name and unit:movement():current_state_name() == "bleed_out" then
            self._teammate_panels[panel_id]:increment_revives()
        end
        return set_mugshot_downed_original(self, id)
    end

    function HUDManager:set_mugshot_custody(id)
        local panel_id = self:_mugshot_id_to_panel_id(id)
        if panel_id then
            self._teammate_panels[panel_id]:reset_revives()
            self._teammate_panels[panel_id]:set_player_in_custody(true)
        end
        return set_mugshot_custody_original(self, id)
    end

    function HUDManager:set_mugshot_normal(id)
        local panel_id = self:_mugshot_id_to_panel_id(id)
        if panel_id then
            self._teammate_panels[panel_id]:set_player_in_custody(false)
        end
        return set_mugshot_normal_original(self, id)
    end

    function HUDManager:reset_teammate_revives(panel_id)
        if self._teammate_panels[panel_id] then
            self._teammate_panels[panel_id]:reset_revives()
        end
    end

    function HUDManager:set_hud_mode(mode)
        for _, panel in pairs(self._teammate_panels or {}) do
            panel:set_hud_mode(mode)
        end
    end

    function HUDManager:_mugshot_id_to_panel_id(id)
        for _, data in pairs(managers.criminals:characters()) do
            if data.data.mugshot_id == id then
                return data.data.panel_id
            end
        end
    end

    function HUDManager:_mugshot_id_to_unit(id)
        for _, data in pairs(managers.criminals:characters()) do
            if data.data.mugshot_id == id then
                return data.unit
            end
        end
    end

    function HUDManager:set_player_condition(icon_data, text)
        set_player_condition_original(self, icon_data, text)
        if icon_data == "mugshot_in_custody" then
            self._teammate_panels[self.PLAYER_PANEL]:set_player_in_custody(true)
        elseif icon_data == "mugshot_normal" then
            self._teammate_panels[self.PLAYER_PANEL]:set_player_in_custody(false)
        end
    end

elseif RequiredScript == "lib/managers/hud/hudteammate" then

    local init_original = HUDTeammate.init
    local set_health_original = HUDTeammate.set_health
    local set_name_original = HUDTeammate.set_name

    function HUDTeammate:init(...)
        init_original(self, ...)
        self:_init_revivecount()
    end

    function HUDTeammate:_init_revivecount()
	self._setting_pref = self._main_player and "PLAYER_" or "TEAM_"
			
        self._revives_counter = self._player_panel:child("radial_health_panel"):text({
            name = "revives_counter",
            visible = not managers.groupai:state():whisper_mode(),
            text = "0",
            layer = 3,
            color = HMH:GetOption("colored_downs") and Color("66ff99") or Color.white,
            w = self._player_panel:child("radial_health_panel"):w(),
            x = 0,
            y = 0,
            h = self._player_panel:child("radial_health_panel"):h(),
            vertical = "center",
            align = "center",
            font_size = 16,
            font = tweak_data.hud_players.ammo_font
        })
        self._revives_count = 0

    end

    function HUDTeammate:increment_revives()
        if self._revives_counter then
            self._revives_count = self._revives_count + 1
            self._revives_counter:set_text(tostring(self._revives_count))
        end
    end

    function HUDTeammate:reset_revives()
        if self._revives_counter then
            self._revives_count = 0
            if not self._main_player then
                self._revives_counter:set_text(tostring(self._revives_count))
				self._revives_counter:set_color(HMH:GetOption("colored_downs") and Color("66ff99") or Color.white)
            else
                self._revives_counter:set_text(tostring(managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", (Global.game_settings.one_down and 2 or tweak_data.player.damage.LIVES_INIT) + (self._main_player and managers.player:upgrade_value("player", "additional_lives", 0) or 0))-1))
            end
        end
    end

    function HUDTeammate:set_revive_visibility(visible)
        if self._revives_counter then
            self._revives_counter:set_visible( HMH:GetOption(self._setting_pref .. "down") and not managers.groupai:state():whisper_mode() and visible and not self._is_in_custody)
        end
    end

    function HUDTeammate:set_health(data)
        if data.revives then
		    local green_color = HMH:GetOption("colored_downs") and Color("66ff99") or Color.white
            local revive_colors = { Color("ffcc66"), green_color, green_color, green_color, green_color}
            self._revives_counter:set_color(revive_colors[data.revives - 1] or Color("ff6666"))
           
            self._revives_counter:set_text(tostring(data.revives - 1))
           
            self:set_player_in_custody(data.revives - 1 < 0)
        end

		if not self._main_player then
		    if Global.game_settings.one_down and self._revives_count == 1 then
		        self._revives_counter:set_color(Color("ffcc66"))
		    elseif Global.game_settings.one_down and self._revives_count > 1 then
		        self._revives_counter:set_color(Color("ff6666"))
		    elseif self._revives_count == 2 then
		        self._revives_counter:set_color(Color("ffcc66"))
		    elseif self._revives_count > 2 then 
		        self._revives_counter:set_color(Color("ff6666"))
		    end
		end

        return set_health_original(self, data)
    end

    function HUDTeammate:set_hud_mode(mode)
        self:set_revive_visibility(mode ~= "stealth")
    end

    function HUDTeammate:set_player_in_custody(incustody)
        self._is_in_custody = incustody
        self:set_revive_visibility(not incustody)
    end

    function HUDTeammate:set_name(teammate_name, ...)
        if teammate_name ~= self._name then
            self._name = teammate_name
            self:reset_revives()
        end

        local name_panel = self._panel:child("name")
        name_panel:set_text(teammate_name)
        set_name_original(self, name_panel:text(), ...)
    end

elseif RequiredScript == "lib/network/handlers/unitnetworkhandler" then

    local sync_teammate_progress_original = UnitNetworkHandler.sync_teammate_progress

    function UnitNetworkHandler:sync_teammate_progress(type_index, enabled, tweak_data_id, timer, success, sender, ...)
        local sender_peer = self._verify_sender(sender)
        if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not sender_peer then
            return
        end
        if type_index and tweak_data_id and success and type_index == 1 and (tweak_data_id == "doctor_bag" or tweak_data_id == "firstaid_box") then
            managers.hud:reset_teammate_revives(managers.hud:teammate_panel_from_peer_id(sender_peer:id()))
        end
        return sync_teammate_progress_original(self, type_index, enabled, tweak_data_id, timer, success, sender, ...)
    end

elseif RequiredScript == "lib/managers/group_ai_states/groupaistatebase" then

    local set_whisper_mode_original = GroupAIStateBase.set_whisper_mode

    function GroupAIStateBase:set_whisper_mode(enabled, ...)
    set_whisper_mode_original(self, enabled, ...)      
        if (enabled) then
            managers.hud:set_hud_mode("stealth")
        else
            managers.hud:set_hud_mode("loud")
        end
    end
end