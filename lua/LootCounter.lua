if HMH:GetOption("tab") then
	Hooks:PostHook(ObjectInteractionManager, "init", "HMH_ObjectInteractionManager_init", function(self)
		self.loot_count = {}
		self.loot_count.loot_amount = 0
		self.loot_count.crate_amount = 0
		self._total_loot = {}
		self._count_loot_bags = {}
		self.loot_crates = {}
			
		self._loot_fixes = {
			family = 						{ money = 1, },
			watchdogs_2 = 					{ coke = 10, },
			watchdogs_2_day =				{ coke = 10, },
			framing_frame_3 = 				{ gold = 16, },
			mia_1 = 						{ money = 1, },
			welcome_to_the_jungle_1 =		{ money = 1, gold = 1 },
			welcome_to_the_jungle_1_night =	{ money = 1, gold = 1 },
			mus = 							{ painting = 2 },
			arm_und = 						{ money = 8, },
			ukrainian_job = 				{ money = 3, },
			jewelry_store = 				{ money = 2, },
			chill = 						{ painting = 1, },
			chill_combat = 					{ painting = 1, },
			fish = 							{ mus_artifact = 1 },
			--dah = 							{ money = 8 },
			rvd2 = 							{ money = 1 },
			des = 							{ mus_artifact = 2, painting = 2 }
		}
	end)
		
	local function _get_unit_type(unit)
		local interact_type = unit:interaction().tweak_data
		if interact_type == "weapon_case" or interact_type == "crate_loot" or interact_type == "crate_loot_crowbar" then
			return "loot_crates"
		end
	end
		
	Hooks:PostHook(ObjectInteractionManager, "update", "HMH_Update", function(self, t, dt)
		for i = #self._count_loot_bags, 1, -1 do
			local data = self._count_loot_bags[i]
			local unit = data.unit
			if alive(unit) and unit:interaction() and unit:interaction():active() then
				local carry_id = unit:carry_data() and unit:carry_data():carry_id()
				local interact_type = unit:interaction().tweak_data
				if carry_id and not tweak_data.carry[carry_id].skip_exit_secure or interact_type and tweak_data.carry[interact_type] and not tweak_data.carry[carry_id].skip_exit_secure == true then
					self._total_loot[unit:id()] = true

					local level_id = managers.job:current_level_id()
					if carry_id and level_id and self._loot_fixes[level_id] and self._loot_fixes[level_id][carry_id] and self._loot_fixes[level_id][carry_id] > 0 then
						self._loot_fixes[level_id][carry_id] = self._loot_fixes[level_id][carry_id] - 1
					else
						self:update_loot_count(1)
					end
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
		if self._total_loot[unit:id()] then
			self._total_loot[unit:id()] = nil
			self:update_loot_count(-1)
		end

		if table.contains(self.loot_crates, unit:id()) then
			table.remove(self.loot_crates, table.index_of(self.loot_crates, unit:id()))
			self:update_loot_crates()
		end
	end)

	function ObjectInteractionManager:update_loot_crates()
		local count = #self.loot_crates
		self.loot_count.crate_amount = count or 0
	end

	function ObjectInteractionManager:update_loot_count(update)
		self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + update
	end
		
	function ObjectInteractionManager:get_current_crate_count()
		return (self.loot_count.crate_amount and self.loot_count.crate_amount >= 0) and self.loot_count.crate_amount or 0
	end
		
	function ObjectInteractionManager:get_current_total_loot_count()
		return (self.loot_count.loot_amount and self.loot_count.loot_amount >= 0) and self.loot_count.loot_amount or 0
	end
end