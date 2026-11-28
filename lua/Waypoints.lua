local HMH = HMH
local hud_waypoints = HMH:GetOption("waypoints")

local detection = {
    wp_detected = true,
    wp_suspicious = true,
    wp_calling_in = true,
    wp_calling_in_hazard = true
}

Hooks:PostHook(HUDManager, "add_waypoint", "HMH_HUDManager_add_waypoint", function(self, id, data)
	if not hud_waypoints and not waypoints_available or detection[data.icon] then
		return
	end

	local wp = id and self._hud and self._hud.waypoints and self._hud.waypoints[id]
	if wp and wp.bitmap and wp.arrow then
		local alpha = HMH:GetOption("waypoint_alpha") or 1
		local bitmap = HMH:GetColor("WaypointIcon") or Color.white
		local arrow = HMH:GetColor("WaypointArrow") or Color.white

		wp.bitmap:set_color(bitmap)
		wp.bitmap:set_alpha(alpha)
		wp.arrow:set_color(arrow)
		wp.arrow:set_alpha(alpha)

		if wp.distance then
			local distance = HMH:GetColor("WaypointDistance") or Color.white
			wp.distance:set_color(distance)
			wp.distance:set_alpha(alpha)
		end
	end
end)