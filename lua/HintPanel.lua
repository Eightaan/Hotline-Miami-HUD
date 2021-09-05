if not HMH:GetOption("hint") then
	return
end

Hooks:PostHook(HUDHint, "init", "hudhint_HMH", function(self, ...)
	local clip_panel = self._hint_panel:child("clip_panel")
	clip_panel:child("bg"):hide()
	clip_panel:child("hint_text"):set_color(HMH:GetColor("HintColor"))
	self._hint_panel:child("marker"):set_h(0)
end)