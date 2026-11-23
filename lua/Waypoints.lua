local HMH = HMH
local hud_waypoints = HMH:GetOption("waypoints")

Hooks:PostHook(HUDManager, "add_waypoint", "HMH_HUDManager_add_waypoint", function(self, id, ...)
	local wp = id and self._hud and self._hud.waypoints and self._hud.waypoints[id]

	if hud_waypoints and wp and wp.bitmap and wp.arrow then
		local alpha = HMH:GetOption("waypoint_alpha") or 1
		local bitmap = HMH:GetColor("WaypointIcon") or Color.white
		local arrow = HMH:GetColor("WaypointArrow") or Color.white
		wp.bitmap:set_color(bitmap)
		wp.bitmap:set_alpha(1 * alpha)
		wp.arrow:set_color(arrow)
		wp.arrow:set_alpha(1 * alpha)
		if wp.distance then
			local distance = HMH:GetColor("WaypointDistance") or Color.white
			wp.distance:set_color(distance)
			wp.distance:set_alpha(1 * alpha)
		end
	end
end)