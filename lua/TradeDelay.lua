if not HMH:GetOption("tab") then
	return
end

if RequiredScript == "lib/managers/moneymanager" then
	Hooks:PostHook(MoneyManager, 'civilian_killed', "HMH_MoneyManager_civilian_killed", function(self)
		self:update_civ_kills()
	end)
	
	function MoneyManager:update_civ_kills()
		self._total_civ_kills = (self._total_civ_kills or 0) + 1
		self:update_trade_delay()
	end
	
	function MoneyManager:update_trade_delay()
		self._trade_delay = (self._trade_delay or 5) + 30
	end
	
	function MoneyManager:get_trade_delay()
		return self._trade_delay or 5
	end
	
	function MoneyManager:TotalCivKills()
		return self._total_civ_kills or 0
	end

	function MoneyManager:ResetCivilianKills()
		self._trade_delay = 5
	end
elseif RequiredScript == "lib/managers/trademanager" then
	Hooks:PostHook(TradeManager, 'on_player_criminal_death', "HMH_TradeManager_on_player_criminal_death", function(...)
		managers.money:ResetCivilianKills()
	end)
end