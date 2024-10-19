local HMH = HMH
local waypoints = HMH:GetOption("waypoints")
local alpha = HMH:GetOption("waypoint_alpha")
local bitmap = waypoints and HMH:GetColor("WaypointIcon") or Color.white
local distance = waypoints and HMH:GetColor("WaypointDistance") or Color.white
local arrow = waypoints and HMH:GetColor("WaypointArrow") or Color.white

Hooks:PostHook(HUDManager, "add_waypoint", "HMH_HUDManager_add_waypoint", function(self, id, data, ...)
	local waypoints_available = id and self._hud and self._hud.waypoints and self._hud.waypoints[id]

	if waypoints_available then
		local wp = self._hud.waypoints[id]
		local scale = alpha
		if wp and wp.bitmap and wp.distance and wp.arrow and data.distance then
			if alpha then
				wp.bitmap:set_color(bitmap)
				wp.distance:set_color(distance)
				wp.arrow:set_color(arrow)
			end
			wp.bitmap:set_alpha(1 * scale)
			wp.distance:set_alpha(1 * scale)
			wp.arrow:set_alpha(1 * scale)
		end
	end
end)