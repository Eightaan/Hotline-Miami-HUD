local PlayerDamage_restore_health = PlayerDamage.restore_health
function PlayerDamage:restore_health(health_restored, ...)
	if health_restored * self._healing_reduction == 0 then
		return
	end
	return PlayerDamage_restore_health(self, health_restored, ...)
end