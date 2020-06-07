Hooks:PostHook( HUDInteraction , "init" , "HMM_HUDInteractionInit" , function( self, ... )
    local interact_text = self._hud_panel:child(self._child_name_text)
	if HMH:GetOption("interact") then
	    interact_text:set_color(Color("ffcc66"))
	end
end)

function HUDInteraction:_animate_interaction_complete(bitmap, circle)
	local TOTAL_T = 0.6
	local t = TOTAL_T
	local mul = 1
	local c_x, c_y = bitmap:center()
	local size = bitmap:w()

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		mul = mul + dt * 0.75

		bitmap:set_size(size * mul, size * mul)
		bitmap:set_center(c_x, c_y)
		bitmap:set_alpha(math.max(t / TOTAL_T, 0))
	end

	bitmap:parent():remove(bitmap)
end