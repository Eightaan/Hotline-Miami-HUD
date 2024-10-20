local HMH = HMH
local hud_waypoints = HMH:GetOption("waypoints")

Hooks:PostHook(HUDManager, "add_waypoint", "HMH_HUDManager_add_waypoint", function(self, id, data, ...)
	local waypoints_available = id and self._hud and self._hud.waypoints and self._hud.waypoints[id]

	if hud_waypoints and waypoints_available then
		local alpha = HMH:GetOption("waypoint_alpha")
		local bitmap = hud_waypoints and HMH:GetColor("WaypointIcon") or Color.white
		local distance = hud_waypoints and HMH:GetColor("WaypointDistance") or Color.white
		local arrow = hud_waypoints and HMH:GetColor("WaypointArrow") or Color.white
		local wp = self._hud.waypoints[id]

		if wp and wp.bitmap and wp.distance and wp.arrow and data.distance then
			wp.bitmap:set_color(bitmap)
			wp.distance:set_color(distance)
			wp.arrow:set_color(arrow)
			wp.bitmap:set_alpha(1 * alpha)
			wp.distance:set_alpha(1 * alpha)
			wp.arrow:set_alpha(1 * alpha)
		end
	end
end)