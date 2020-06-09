Hooks:PostHook( HUDInteraction , "init" , "HMM_HUDInteractionInit" , function( self, ... )
    local interact_text = self._hud_panel:child(self._child_name_text)
	if HMH:GetOption("interact") then
	    interact_text:set_color(Color("ffcc66"))
	end
end)