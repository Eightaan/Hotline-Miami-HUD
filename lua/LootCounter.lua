local HMH = HMH

if not (HMH:GetOption("tab") and HMH:GetOption("loot_count")) then
	return
end

local Loot = {}
Loot._crate_types = { "hold_open_xmas_present", "money_briefcase", "hold_open_case", "crate_loot", "crate_loot_crowbar" }
Loot._case_types = { "weapon_case", "weapon_case_axis_z", "gen_pku_warhead_box" }
function Loot:init()
	self.loot_count = { loot_amount = 0, crate_amount = 0 }
	self._total_loot = {}
	self._count_loot_bags = {}
	self._player_carry = {}
	self.loot_crates = {}
	self._loot_fixes = {
		born = {-- Biker Heist(Mission Parts, Mission Crates)
			ignore = {bike_part_heavy = true, bike_part_light = true},
			ignore_crates = true
		},
		framing_frame_3 = {-- Framing Frame (16x Gold, Mission Coke, Achievement Wine)
			gold = 16,
			ignore = {coke = true, old_wine = true}
		},
		pbr2 = {-- Birth of Sky (Mission Money, Mission Crate)
			ignore = {money = true},
			ignore_crates = true
		},
		mex_cooking = {-- Border Crystals (Roman Armor)
			ignore = {roman_armor = true}
		},
		election_day_2 = {-- Election Day (Mission Crates)
			ignore_crates = true
		},
		friend = {-- Scarface Mansion (Mission Paintings)
			ignore = {painting = true}
		},
		moon = {-- Stealing Xmas (Mission Crates)
			ignore_crates = true
		},
		wwh = {-- Alaskan Deal (4x Money Briefcase)
			loot_case = "grenade_briefcase"
		},
		chill = {-- Custom Safehouse (1x Painting)
			ignore = {mus_artifact_paint = true}
		},
		chill_combat = {-- Safehouse Raid (Mission Money)
			ignore = {money = true}
		},
		pent = {-- Mountain Master (2x Artifact)
			ignore = {mus_artifact = true}
		},
		fish = {-- Yacht (1x Painting)
			ignore = {mus_artifact_paint = true}
		},
		alex_3 = {-- Rats (16x Money Briefcase)
			briefcases = 16
		},
		mex = {-- Border Crossing
			loot = 41
		},
		des = {-- Henry's Rock (2x Painting 3x Artifact)
			ignore = {mus_artifact_paint = true},
			ignore_ids = { [101757] = true, [400515] = true, [400511] = true}
		},
		rvd2 = {-- Reservoir Dogs (1x Money)
			ignore_ids = {[100296] = true}
		},
		family = {-- Diamond Store (1x Money)
			ignore_ids = {[100899] = true}
		},
		mia_1 = {-- Hotline Miami (1x Money)
			ignore_ids = {[104526] = true}
		},
		welcome_to_the_jungle_1 = {-- Big Oil (1x Money, 1x Gold)
			ignore_ids = {[100886] = true, [100872] = true}
		},
		sah = {-- Shacklethorne Auction (2x Artifact)
			ignore_ids = {[400791] = true, [400792] = true}
		},
		arm_und = {-- Transport Underpass (8x Money)
			ignore_ids = {
				[101237] = true, [101238] = true,
				[101239] = true, [103835] = true,
				[103836] = true, [103837] = true,
				[103838] = true, [101240] = true
			}
		},
		mus = {-- The Diamond (RNG)
			ignore_ids = {
				[302577] = true, [302586] = true,
				[302597] = true, [302599] = true,
				[300047] = true, [300686] = true,
				[300457] = true, [300458] = true,
				[301343] = true, [301346] = true
			}
		},
		pbr = {-- Beneath the Mountain (Loot Crates)
			whitelist_ids = {
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
		}
	}
	self._loot_fixes.welcome_to_the_jungle_1_night = self._loot_fixes.welcome_to_the_jungle_1 -- Big Oil Night

	self._update_loot_bags = function()
		for i = #self._count_loot_bags, 1, -1 do
			local unit = self._count_loot_bags[i].unit
			local unit_id = unit:id()
			local loot_type = self:_is_valid_unit(unit)
			if loot_type == "loot_crates" and not self.loot_crates[unit_id] then
				self.loot_crates[unit_id] = true
				self:update_loot_crates(1)
			end
			if loot_type ~= "skipped" and not self._total_loot[unit_id] then
				local carry_data = unit:carry_data()
				local carry_id = carry_data and carry_data:carry_id()
				local is_loot = loot_type == "loot" or self:_is_valid_carry(carry_id)
				if is_loot then
					local level_id = managers.job:current_level_id()
					local current_amount = self._loot_fixes[level_id]
					if loot_type ~= "loot" and current_amount and current_amount[carry_id] and current_amount[carry_id] > 0 then
						current_amount[carry_id] = current_amount[carry_id] - 1
					else
						self._total_loot[unit_id] = true
						self:update_loot(1)
						self:update_loot_hud()
					end
				end
			end
			table.remove(self._count_loot_bags, i)
		end
	end
end

---@param amount integer
function Loot:update_loot(amount)
	self.loot_count.loot_amount = (self.loot_count.loot_amount or 0) + amount
end

function Loot:update_loot_hud()
	if managers.hud then
		managers.hud:loot_value_updated()
	end
end

---@param amount integer
function Loot:update_loot_crates(amount)
	self.loot_count.crate_amount = (self.loot_count.crate_amount or 0) + amount
	self:update_loot_hud()
end

function Loot:set_player_carry(peer, carry_id)
	if not peer then
		return
	end

	local peer_id = peer:id()
	local player = self._player_carry[peer_id]
	local carry = self:_is_valid_carry(carry_id) and carry_id or nil

	if not player and carry then
		self:update_loot(1)
		self:update_loot_hud()
	elseif player and not carry then
		self:update_loot(-1)
		self:update_loot_hud()
	end
	self._player_carry[peer_id] = carry
end

---@param unit Unit
function Loot:_is_valid_unit(unit)
	local interact = unit and alive(unit) and unit:interaction()
	if not interact or not interact:active() then
		return "skipped"
	end

	local unit_id = unit:editor_id()
	local level_id = managers.job:current_level_id()
	local loot_fixes = self._loot_fixes[level_id]
	local ignore_ids = loot_fixes and loot_fixes.ignore_ids
	if ignore_ids and ignore_ids[unit_id] then
		return "skipped"
	end

	local interact_type = interact.tweak_data
	if table.contains(self._crate_types, interact_type) then
		if loot_fixes and (loot_fixes.ignore_crates or loot_fixes.whitelist_ids and not loot_fixes.whitelist_ids[unit_id]) then
			return "skipped"
		end
		return "loot_crates"
	elseif loot_fixes and loot_fixes.loot_case == interact_type then
		return unit_id ~= -1 and "loot" or "skipped"
	elseif table.contains(self._case_types, interact_type) then
		return "loot"
	end
end

function Loot:_is_valid_carry(carry_id)
	if not carry_id or carry_id == "hydraulic_opener" or carry_id == "vehicle_falcogini" or carry_id == "turret_part" then
		return false
	end

	local carry = tweak_data.carry[carry_id]
	if carry and carry.skip_exit_secure == true then
		return false
	end

	local level_id = managers.job:current_level_id()
	local loot_fixes = self._loot_fixes[level_id]

	if loot_fixes and loot_fixes.ignore and loot_fixes.ignore[carry_id] then
		return false
	end

	return true
end

function Loot:add_unit(unit)
	if alive(unit) then
		local loot_type = self:_is_valid_unit(unit)
		if loot_type == "loot_crates" then
			local id = unit:id()
			if not self.loot_crates[id] then
				self.loot_crates[id] = true
				self:update_loot_crates(1)
			end
		end
	end
	table.insert(self._count_loot_bags, { unit = unit })
	call_on_next_update(self._update_loot_bags, true)
end

function Loot:remove_unit(unit)
	local unit_id = unit:id()
	if self._total_loot[unit_id] then
		self._total_loot[unit_id] = nil
		self:update_loot(-1)
		self:update_loot_hud()
	end

	if self.loot_crates[unit_id] then
		self.loot_crates[unit_id] = nil
		self:update_loot_crates(-1)
	end
	for i = #self._count_loot_bags, 1, -1 do
		local queued_unit = self._count_loot_bags[i].unit

		if not alive(queued_unit) or queued_unit:id() == unit_id then
			table.remove(self._count_loot_bags, i)
		end
	end
end

Hooks:PostHook(ObjectInteractionManager, "add_unit", "HMH_ObjectInteractionManager_add_unit", function(self, unit)
	Loot:add_unit(unit)
end)

Hooks:PostHook(ObjectInteractionManager, "remove_unit", "HMH_ObjectInteractionManager_remove_unit", function(self, unit)
	Loot:remove_unit(unit)
end)

function ObjectInteractionManager:get_current_crate_count()
	local level_id = managers.job:current_level_id()
	local amount = Loot.loot_count.crate_amount or 0
	local current_amount = Loot._loot_fixes[level_id]
	return (current_amount and current_amount.briefcases and amount - current_amount.briefcases) or amount
end

function ObjectInteractionManager:get_current_total_loot_count()
	local level_id = managers.job:current_level_id()
	local amount = Loot.loot_count.loot_amount or 0
	local current_amount = Loot._loot_fixes[level_id]
	return (current_amount and current_amount.loot and amount > current_amount.loot and 4) or amount
end

if Global.game_settings.level_id == "des" then
	local function count_artifact()
		local unit = managers.worlddefinition:get_unit(400511)

		if not Loot or not alive(unit) then
			return
		end

		local carry_data = unit:carry_data()
		local interaction = unit:interaction()

		if not carry_data or not interaction or not interaction:active() then
			return
		end

		local unit_id = unit:id()
		Loot._loot_fixes.des.ignore_ids[400511] = nil

		if Loot._total_loot[unit_id] then
			return
		end

		Loot._total_loot[unit_id] = true
		Loot:update_loot(1)
		Loot:update_loot_hud()
	end

	Hooks:PostHook(GameSetup, "init_finalize", "HMH_GameSetup_init_finalize", function(self)
		local element = managers.mission:get_element_by_id(102491)

		if element then
			Hooks:PostHook(element, Network:is_server() and "on_executed" or "client_on_executed", "HMH_HenrysRockArtifact", count_artifact)
		end
	end)

	Hooks:PostHook(GameSetup, "load", "HMH_GameSetup_load", function(self)
		local element = managers.mission:get_element_by_id(101506)

		if element and not element:enabled() then
			count_artifact()
		end
	end)
end

Hooks:PostHook(PlayerManager, "set_synced_carry", "HMH_PlayerManager_set_synced_carry", function(self, peer, carry_id, ...)
	Loot:set_player_carry(peer, carry_id)
end)

Hooks:PostHook(PlayerManager, "remove_synced_carry", "HMH_PlayerManager_remove_synced_carry", function(self, peer, ...)
	Loot:set_player_carry(peer)
end)

Loot:init()