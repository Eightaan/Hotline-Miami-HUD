local HMH = HMH

if HMH:GetOption("tab") and HMH:GetOption("loot_count") then
	Hooks:PostHook(ObjectInteractionManager, "init", "HMH_ObjectInteractionManager_init", function(self)
		self._total_loot = {}
		self._count_loot_bags = {}
		self.loot_crates = {}
		self.loot_count = { loot_amount = 0, crate_amount = 0 }
		self._loot_fixes = {
			--Framing Frame
			framing_frame_3 = {gold = 16},
			--Border Crystals
			mex_cooking	= {roman_armor = 4},
			--Birth of Sky
			pbr2 = {money = 8}
		}
		self.ignore_ids = {
			--Watchdogs (10x Coke)
			[100054] = true, [100058] = true, [100426] = true, [100427] = true, [100428] = true, 
			[100429] = true, [100491] = true, [100492] = true, [100494] = true, [100495] = true,
			--Transport: Underpass (8x Money)
			[101237] = true, [101238] = true, [101239] = true, [103835] = true, 
			[103836] = true, [103837] = true, [103838] = true, [101240] = true,
			--The Diamond (RNG)
			[300047] = true, [300686] = true, [300457] = true, 
			[300458] = true, [301343] = true, [301346] = true,
			--Ukrainian Job (3x Money)
			[101514] = true, [102052] = true, [102402] = true,
			-- Henry's Rock (2x Artifact, 2x Painting)
			[101757] = true, [400513] = true,
			[400515] = true, [400617] = true,
			-- Shacklethorne Auction (2x Artifact)
			[400791] = true, 
			[400792] = true,
			--Jewelry Store (2x Money)
			[102052] = true,
			[102402] = true,
			-- Mountain Master (2x Artifact)
			[500849] = true,
			[500608] = true,
			--Big Oil (1x Money 1x Gold)
			[100886] = true,
			[100872] = true,
			-- Hotline Miami (1x Money)
			[104526] = true,
			-- Custom Safehouse (1x Painting)
			[150416] = true,
			--Yacht (1x artifact Painting)
			[500533] = true,
			--Diamond Store (1x Money)
			[100899] = true,
			-- Resevoir Dogs (1x Money)
			[100296] = true
		}
	end)

	local function is_valid_unit(unit)
		return unit and alive(unit) and unit:interaction() and unit:interaction():active() 
		and (not unit:carry_data() or unit:carry_data():carry_id() ~= "vehicle_falcogini" 
		and unit:carry_data():carry_id() ~= "turret_part")
	end

	local function is_ignored_id(unit_id)
		return managers.interaction.ignore_ids and managers.interaction.ignore_ids[unit_id]
	end

	local function get_unit_type(unit)
		local interact_type = unit:interaction().tweak_data
		return (interact_type and table.contains({
			Global.game_settings.level_id == "election_day_2" and "" or "money_briefcase",
			"gen_pku_warhead_box",
			"weapon_case",
			"weapon_case_axis_z",
			"hold_open_xmas_present",
			"hold_open_case",
			"crate_loot",
			"crate_loot_crowbar"
		}, interact_type)) and "loot_crates" or nil
	end

	local function is_equipment_bag(carry_id)
		return carry_id and tweak_data.carry[carry_id].skip_exit_secure == true
	end

	local function process_loot_count(manager, carry_id)
		local level_id = managers.job:current_level_id()

		local current_amount = manager._loot_fixes[level_id] and manager._loot_fixes[level_id][carry_id]
		if current_amount and current_amount > 0 then
			manager._loot_fixes[level_id][carry_id] = current_amount - 1
		else
			manager:update_loot(1)
			managers.hud:loot_value_updated()
		end
	end

	Hooks:PostHook(ObjectInteractionManager, "update", "HMH_Update", function(self, t, dt)
		for i = #self._count_loot_bags, 1, -1 do
			local data = self._count_loot_bags[i]
			local unit = data.unit
			
			if is_valid_unit(unit) then
				local carry_id = unit:carry_data() and unit:carry_data():carry_id()
				local unit_id = unit:editor_id()
				if carry_id and not is_equipment_bag(carry_id) and not is_ignored_id(unit_id) then
					self._total_loot[unit:id()] = true
					process_loot_count(self, carry_id)
				end
			end
			table.remove(self._count_loot_bags, i)
		end
	end)

	Hooks:PostHook(ObjectInteractionManager, "add_unit", "HMH_ObjectInteractionManager_add_unit", function(self, unit)
		if alive(unit) then
			local carry_id = unit:carry_data() and unit:carry_data():carry_id()
			if get_unit_type(unit) == "loot_crates" then
				table.insert(self.loot_crates, unit:id())
				self:update_loot_crates()
			end
		end
		table.insert(self._count_loot_bags, { unit = unit })
	end)

	Hooks:PostHook(ObjectInteractionManager, "remove_unit", "HMH_ObjectInteractionManager_remove_unit", function(self, unit)
		if alive(unit) then
			local unit_id = unit:id()
			if not is_ignored_id(unit_id) then
				local carry_id = unit:carry_data() and unit:carry_data():carry_id()
				if self._total_loot[unit_id] then
					self._total_loot[unit_id] = nil
					self:update_loot(-1)
					managers.hud:loot_value_updated()
				end
			end
			
			local crate_index = table.index_of(self.loot_crates, unit_id)
			if crate_index then
				table.remove(self.loot_crates, crate_index)
				self:update_loot_crates()
			end
			
			for i = #self._count_loot_bags, 1, -1 do
				if self._count_loot_bags[i].unit:id() == unit_id then
					table.remove(self._count_loot_bags, i)
					break
				end
			end
		end
	end)

	function ObjectInteractionManager:update_loot_crates()
		self.loot_count.crate_amount = #self.loot_crates
	end

	function ObjectInteractionManager:update_loot(update)
		self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + update
	end

	function ObjectInteractionManager:get_current_crate_count()
		return self.loot_count.crate_amount or 0
	end

	function ObjectInteractionManager:get_current_total_loot_count()
		return self.loot_count.loot_amount or 0
	end
end