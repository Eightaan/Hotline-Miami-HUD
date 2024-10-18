if RequiredScript == "lib/managers/moneymanager" then
	Hooks:PostHook(MoneyManager, 'civilian_killed', "HMH_MoneyManager_civilian_killed", function(self)
		HMH.CivKill = HMH.CivKill + 1
	end)

	function MoneyManager:ResetCivilianKills()
		HMH.CivKill = 0
	end
elseif RequiredScript == "lib/managers/trademanager" then
	Hooks:PostHook(TradeManager, 'on_player_criminal_death', "HMH_TradeManager_on_player_criminal_death", function(...)
		managers.money:ResetCivilianKills()
	end)
end