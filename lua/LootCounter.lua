if HMH:GetOption("tab") and HMH:GetOption("loot_count") then
    Hooks:PostHook(ObjectInteractionManager, "init", "HMH_ObjectInteractionManager_init", function(self)
        self.loot_count = { loot_amount = 0, crate_amount = 0 }
        self._total_loot = {}
        self._count_loot_bags = {}
        self.loot_crates = {}
        self._loot_fixes = {
            family = { money = 1 },
            watchdogs_2 = { coke = 10 },
            watchdogs_2_day = { coke = 10 },
            framing_frame_3 = { gold = 16 },
            mia_1 = { money = 1 },
            welcome_to_the_jungle_1 = { money = 1, gold = 1 },
            welcome_to_the_jungle_1_night = { money = 1, gold = 1 },
            mus = { painting = 2, mus_artifact = 1 },
            arm_und = { money = 8 },
            ukrainian_job = { money = 3 },
            jewelry_store = { money = 2 },
            chill = { painting = 1 },
            chill_combat = { painting = 1 },
            fish = { mus_artifact = 1 },
            rvd2 = { money = 1 },
            pbr2 = { money = 8 },
            mex_cooking = { roman_armor = 4 },
            sah = { mus_artifact = 2 },
            corp = { painting = 5 },
            ranc = { turret_part = 2 },
            trai = { turret_part = 2 },
            pent = { mus_artifact = 2 },
            des = { mus_artifact = 4, painting = 2 }
        }
        self.ignore_ids = {
            [300457] = true,
            [300458] = true,
        }
    end)

    local function is_valid_unit(unit)
        return unit and alive(unit) and unit:interaction() and 
            unit:interaction():active() and
            (unit:carry_data() and unit:carry_data():carry_id() ~= "vehicle_falcogini")
    end

    local function is_ignored_id(unit_id)
        local manager = managers.interaction
        return manager and manager.ignore_ids and manager.ignore_ids[unit_id]
    end

    local function _get_unit_type(unit)
        local interact_type = unit:interaction().tweak_data
        local election_day_2_fix = (Global.game_settings.level_id == "election_day_2") and "" or "money_briefcase"
        local counted_possible_by_int = {
            election_day_2_fix,
            "gen_pku_warhead_box",
            "weapon_case",
            "weapon_case_axis_z",
            "crate_loot",
            "crate_loot_crowbar"
        }
        if interact_type and table.contains(counted_possible_by_int, interact_type) then
            return "loot_crates"
        end
    end

    local function process_loot_count(manager, carry_id)
        local level_id = managers.job:current_level_id()
        if is_ignored_id(carry_id) then
            return
        end
        if manager._loot_fixes[level_id] and manager._loot_fixes[level_id][carry_id] then
            local current_amount = manager._loot_fixes[level_id][carry_id]
            if current_amount > 0 then
                manager._loot_fixes[level_id][carry_id] = current_amount - 1
            else
                manager:update_loot(1)
            end
        else
            manager:update_loot(1)
        end
    end

    Hooks:PostHook(ObjectInteractionManager, "update", "HMH_Update", function(self, t, dt)
        for i = #self._count_loot_bags, 1, -1 do
            local data = self._count_loot_bags[i]
            local unit = data.unit
            if is_valid_unit(unit) then
                local unit_id = unit:editor_id()
                if not is_ignored_id(unit_id) then
                    local carry_id = unit:carry_data() and unit:carry_data():carry_id()
                    self._total_loot[unit:id()] = true
                    process_loot_count(self, carry_id)
                end
            end
            table.remove(self._count_loot_bags, i)
        end
    end)

    Hooks:PostHook(ObjectInteractionManager, "add_unit", "HMH_ObjectInteractionManager_add_unit", function(self, unit)
        if alive(unit) then
            local unit_type = _get_unit_type(unit)
            if unit_type == "loot_crates" then
                table.insert(self.loot_crates, unit:id())
                self:update_loot_crates()
            end
        end
        table.insert(self._count_loot_bags, { unit = unit })
    end)

    Hooks:PostHook(ObjectInteractionManager, "remove_unit", "HMH_ObjectInteractionManager_remove_unit", function(self, unit)
        local unit_id = unit:editor_id()
        if not is_ignored_id(unit_id) then
            local carry_id = unit:carry_data() and unit:carry_data():carry_id()
            if carry_id and self._total_loot[unit:id()] then
                self._total_loot[unit:id()] = nil
                self:update_loot(-1)
            end
        end
        local crate_index = table.index_of(self.loot_crates, unit:id())
        if crate_index then
            table.remove(self.loot_crates, crate_index)
            self:update_loot_crates()
        end
    end)

    function ObjectInteractionManager:update_loot_crates()
        self.loot_count.crate_amount = self.loot_crates and #self.loot_crates or 0
    end

    function ObjectInteractionManager:update_loot(update)
        self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + update
    end

    function ObjectInteractionManager:get_current_crate_count()
        return math.max(self.loot_count.crate_amount or 0, 0)
    end

    function ObjectInteractionManager:get_current_total_loot_count()
        return math.max(self.loot_count.loot_amount or 0, 0)
    end
end