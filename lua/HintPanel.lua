Hooks:PostHook(HUDHint, "init", "hudhint_HMH", function(self, ...)
	local clip_panel = self._hint_panel:child("clip_panel")

	if HMH:GetOption("hint") then
	    clip_panel:child("bg"):hide()
	    clip_panel:child("hint_text"):set_color(BeardLib and hotlinemiamihud and hotlinemiamihud.Options:GetValue("Hint") or Color("ffcc66"))
        self._hint_panel:child("marker"):set_h(0)
	end
end)