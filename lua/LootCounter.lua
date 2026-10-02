local HMH = HMH

if HMH:GetOption("tab") and HMH:GetOption("loot_count") then
	if RequiredScript == "lib/managers/objectinteractionmanager" then
		Hooks:PostHook(ObjectInteractionManager, "init", "HMH_ObjectInteractionManager_init", function(self)
			self._total_loot = {}
			self._count_loot_bags = {}
			self._player_carry = {}
			self.loot_crates = {}
			self.loot_count = { loot_amount = 0, crate_amount = 0 }
			self._loot_fixes = {
				-- Framing Frame (16x Gold)
				framing_frame_3 = {carry_id = "gold", ignore = 16},
				-- Rats (16x Money Briefcase)
				alex_3 = {crates_over = 14, remove_crates = 16},
				-- Border Crossing
				mex = {loot_over = 41, loot_amount = 4},
				-- Alaskan Deal
				wwh = {loot_case = "grenade_briefcase"}
			}
			self.ignore_ids = {
				--Transport Underpass (8x Money)
				[101237] = true, [101238] = true, 
				[101239] = true, [103835] = true,
				[103836] = true, [103837] = true, 
				[103838] = true, [101240] = true,
				--The Diamond (RNG)
				[302577] = true, [302586] = true, 
				[302597] = true, [302599] = true,
				[300047] = true, [300686] = true, 
				[300457] = true, [300458] = true, 
				[301343] = true, [301346] = true,
				--Ukrainian Job (3x Money)
				-- [101514] = true, [102052] = true, [102402] = true,
				-- Henry's Rock (2x Artifact, 2x Painting)
				[101757] = true, 
				[400513] = true,
				[400515] = true, 
				[400617] = true,
				[400511] = true,
				-- Shacklethorne Auction (2x Artifact)
				[400791] = true, 
				[400792] = true,
				--Jewelry Store (2x Money)
				-- [102052] = true,
				-- [102402] = true,
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
			-- Beneath the Mountain
			self.pbr_loot_crates = {
				[156100] = true, 
				[156175] = true,
				[156250] = true, 
				[156325] = true,
				[156400] = true, 
				[156475] = true,
				[156550] = true, 
				[156625] = true,
				[156700] = true, 
				[156775] = true,
				[156850] = true, 
				[156925] = true,
				[157000] = true, 
				[157075] = true,
				[157150] = true, 
				[157225] = true,
				[157300] = true, 
				[157375] = true,
				[157450] = true, 
				[157525] = true,
				[157600] = true, 
				[157675] = true,
				[157750] = true, 
				[157825] = true,
				[157900] = true
			}
			self.ignore_crate_levels = {
				-- Birth of Sky
				["pbr2"] = true,
				-- Biker Heist
				["born"] = true,
				-- Election Day
				["election_day_2"] = true,
				-- Stealing Xmas
				["moon"] = true
			}
			self.ignore_loot = {
				-- Framing Frame
				framing_frame_3 = {coke = true, old_wine = true},
				-- Scarface Mansion
				friend = {painting = true},
				-- Birth of Sky
				pbr2 = {money = true},
				-- Border Crystals
				mex_cooking = {roman_armor = true},
				-- Biker Heist
				born = {bike_part_heavy = true, bike_part_light = true}
			}
		end)

		local function is_valid_unit(unit)
			return unit and alive(unit) and unit:interaction() and unit:interaction():active()
		end

		local function is_ignored_id(unit_id)
			return managers.interaction.ignore_ids and managers.interaction.ignore_ids[unit_id]
		end

		local function get_unit_type(unit)
			local interact_type = unit:interaction().tweak_data
			return (interact_type and table.contains({
				"money_briefcase",
				"hold_open_xmas_present",
				"hold_open_case", --BCI Helmet case
				"crate_loot",
				"crate_loot_crowbar"
			}, interact_type)) and "loot_crates" or nil
		end

		local function is_loot_case(unit)
			local interact_type = unit:interaction() and unit:interaction().tweak_data
			local level_id = managers.job:current_level_id()
			local current_amount = managers.interaction._loot_fixes[level_id]

			if current_amount and current_amount.loot_case == interact_type then
				return unit:editor_id() ~= -1
			end

			return interact_type and table.contains({
				"weapon_case",
				"weapon_case_axis_z",
				"gen_pku_warhead_box"
			}, interact_type)
		end

		local function process_loot_count(manager, carry_id)
			local level_id = managers.job:current_level_id()
			local current_amount = manager._loot_fixes[level_id]

			if current_amount and current_amount.carry_id == carry_id and current_amount.ignore and current_amount.ignore > 0 then
				current_amount.ignore = current_amount.ignore - 1
			else
				manager:update_loot(1)
				managers.hud:loot_value_updated()
			end
		end

		local function is_loot_crate(unit)
			local level_id = managers.job:current_level_id()
			local manager = managers.interaction

			if manager.ignore_crate_levels[level_id] then
				return false
			end

			if level_id == "pbr" then
				return manager.pbr_loot_crates[unit:editor_id()] == true
			end

			return true
		end

		local function is_valid_carry(carry_id)
			if not carry_id then
				return false
			end

			if carry_id == "hydraulic_opener" or carry_id == "vehicle_falcogini" or carry_id == "turret_part" then
				return false
			end

			local carry = tweak_data.carry[carry_id]
			if carry and carry.skip_exit_secure == true then
				return false
			end

			local level_id = managers.job:current_level_id()
			local ignore_loot = managers.interaction.ignore_loot

			if ignore_loot and ignore_loot[level_id] and ignore_loot[level_id][carry_id] then
				return false
			end

			return true
		end

		Hooks:PostHook(ObjectInteractionManager, "update", "HMH_ObjectInteractionManager_Update", function(self, ...)
			for i = #self._count_loot_bags, 1, -1 do
				local data = self._count_loot_bags[i]
				local unit = data.unit
				if is_valid_unit(unit) then
					local carry_id = unit:carry_data() and unit:carry_data():carry_id()
					local unit_id = unit:editor_id()

					if is_loot_case(unit) then
						self._total_loot[unit:id()] = true
						self:update_loot(1)
						managers.hud:loot_value_updated()
					elseif is_valid_carry(carry_id) and not is_ignored_id(unit_id) then
						self._total_loot[unit:id()] = true
						process_loot_count(self, carry_id)
					end
				end
				table.remove(self._count_loot_bags, i)
			end
		end)

		Hooks:PostHook(ObjectInteractionManager, "add_unit", "HMH_ObjectInteractionManager_add_unit", function(self, unit)
			if alive(unit) then
				if get_unit_type(unit) == "loot_crates" and is_loot_crate(unit) then
					if not table.contains(self.loot_crates, unit:id()) then
						table.insert(self.loot_crates, unit:id())
						self:update_loot_crates()
					end
				end
			end
			table.insert(self._count_loot_bags, { unit = unit })
		end)

		Hooks:PostHook(ObjectInteractionManager, "remove_unit", "HMH_ObjectInteractionManager_remove_unit", function(self, unit)
			if alive(unit) then
				local unit_id = unit:id()
				if not is_ignored_id(unit:editor_id()) then
					if self._total_loot[unit_id] then
						self._total_loot[unit_id] = nil
						self:update_loot(-1)
						managers.hud:loot_value_updated()
					end
				end
				
				local crate_index = table.index_of(self.loot_crates, unit_id)
				if crate_index ~= -1 then
					table.remove(self.loot_crates, crate_index)
					self:update_loot_crates()
				end
				for i = #self._count_loot_bags, 1, -1 do
					local queued_unit = self._count_loot_bags[i].unit

					if not alive(queued_unit) then
						table.remove(self._count_loot_bags, i)
					elseif queued_unit:id() == unit_id then
						table.remove(self._count_loot_bags, i)
						break
					end
				end
			end
		end)
		
		function ObjectInteractionManager:set_player_carry(peer, carry_id)
			if not peer then
				return
			end

			self._player_carry[peer:id()] = is_valid_carry(carry_id) and carry_id or nil
		end

		function ObjectInteractionManager:get_current_carry_count()
			return table.size(self._player_carry)
		end

		function ObjectInteractionManager:update_loot_crates()
			self.loot_count.crate_amount = #self.loot_crates
		end

		function ObjectInteractionManager:update_loot(update)
			self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + update
		end

		function ObjectInteractionManager:get_current_crate_count()
			local level_id = managers.job:current_level_id()
			local amount = self.loot_count.crate_amount or 0
			local current_amount = self._loot_fixes[level_id]

			if current_amount and current_amount.crates_over and amount > current_amount.crates_over then
				amount = amount - (current_amount.remove_crates or 0)
			end

			return amount
		end

		function ObjectInteractionManager:get_current_total_loot_count()
			local level_id = managers.job:current_level_id()
			local amount = self.loot_count.loot_amount or 0
			local current_amount = self._loot_fixes[level_id]

			if current_amount and current_amount.loot_over and amount > current_amount.loot_over then
				amount = current_amount.loot_amount
			end

			return amount
		end
	elseif RequiredScript == "lib/managers/mission/missionscriptelement" then
		Hooks:PostHook(MissionScriptElement, "on_executed", "HMH_MissionScriptElement_on_executed", function(self, ...)
			if Global.game_settings.level_id ~= "des" or self._id ~= 102491 then
				return
			end

			local manager = managers.interaction
			if not manager then
				return
			end

			local unit = managers.worlddefinition:get_unit(400511)
			if not alive(unit) then
				return
			end

			local carry_data = unit:carry_data()
			local interaction = unit:interaction()

			if not carry_data or not interaction or not interaction:active() then
				return
			end

			local unit_id = unit:id()

			manager.ignore_ids[400511] = nil

			if manager._total_loot[unit_id] then
				return
			end

			manager._total_loot[unit_id] = true
			manager:update_loot(1)
			managers.hud:loot_value_updated()
		end)

	elseif RequiredScript == "lib/managers/playermanager" then
		Hooks:PostHook(PlayerManager, "set_synced_carry", "HMH_PlayerManager_set_synced_carry", function(self, peer, carry_id, ...)
			if managers.interaction then
				managers.interaction:set_player_carry(peer, carry_id)
			end
		end)

		Hooks:PreHook(PlayerManager, "remove_synced_carry", "HMH_PlayerManager_remove_synced_carry", function(self, peer, ...)
			if managers.interaction then
				managers.interaction:set_player_carry(peer)
			end
		end)
	end
end