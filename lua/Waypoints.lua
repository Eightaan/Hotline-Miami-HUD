local HMH = HMH
local waypoints = HMH:GetOption("waypoints")
local alpha = HMH:GetOption("waypoint_alpha")
local bitmap = waypoints and HMH:GetColor("WaypointIcon") or Color.white
local distance = waypoints and HMH:GetColor("WaypointDistance") or Color.white
local arrow = waypoints and HMH:GetColor("WaypointArrow") or Color.white
Hooks:PostHook(HUDManager, "add_waypoint", "HMH_hudmanager_add_waypoint", function(self, id, data, ...)
	local wp = id and self._hud and self._hud.waypoints and self._hud.waypoints[id]
	if wp then
		if wp.bitmap then
			wp.bitmap:set_color(bitmap)
			wp.bitmap:set_alpha(alpha)
		end
		if wp.distance then
			wp.distance:set_color(distance)
			wp.distance:set_alpha(alpha)
		end
		if wp.arrow then
			wp.arrow:set_color(arrow)
			wp.arrow:set_alpha(alpha)
		end
	end
end)