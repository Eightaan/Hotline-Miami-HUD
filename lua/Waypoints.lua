Hooks:PostHook(HUDManager, "add_waypoint", "HMH_hudmanager_add_waypoint", function(self, id, data, ...)
	local waypoints_available = id and self._hud and self._hud.waypoints and self._hud.waypoints[id]

	if waypoints_available then
		local wp = self._hud.waypoints[id]
		local scale = HMH:GetOption("waypoint_alpha")
		if wp and wp.bitmap and wp.distance and wp.arrow and data.distance then
		    if HMH:GetOption("waypoints") then
			    wp.bitmap:set_color(Color("66ff99"))
			    wp.distance:set_color(Color("66ffff"))
			    wp.arrow:set_color(Color("66ffff"))
			end
			wp.bitmap:set_alpha(1 * scale)
			wp.distance:set_alpha(1 * scale)
			wp.arrow:set_alpha(1 * scale)
		end
	end
end)