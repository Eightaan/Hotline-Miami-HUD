local HMH = HMH

if not HMH:GetOption("hint") then
	return
end

Hooks:PostHook(HUDHint, "init", "HMH_HUDHint_init", function(self, ...)
	local clip_panel = self._hint_panel:child("clip_panel")
	clip_panel:child("bg"):hide()
	clip_panel:child("hint_text"):set_color(HMH:GetColor("HintColor"))
	clip_panel:child("hint_text"):set_alpha(HMH:GetOption("HintAlpha"))
	self._hint_panel:child("marker"):set_h(0)
end)

Hooks:PostHook(HUDHint, "show", "HMH_HUDHint_show", function(self, params, ...)
	self._hint_panel:stop()
	self._hint_panel:animate(callback(self, self, "_animate_show_hint"), callback(self, self, "show_done"), params.time or 3, utf8.to_upper(params.text))
end)

function HUDHint:_animate_show_hint(hint_panel, done_cb, seconds, text)
	local clip_panel = hint_panel:child("clip_panel")
	local hint_text = clip_panel:child("hint_text")
	hint_panel:set_visible(true)
	hint_panel:set_alpha(1)
	hint_text:set_text(text)
	local offset = 32
	local _, _, w, h = hint_text:text_rect()	
	local target_w = w + offset
	hint_text:set_w(target_w)
	clip_panel:set_w(target_w)
	clip_panel:set_center_x(self._hint_panel:center_x())
	set_alpha(clip_panel, 1)
	wait(3)
	set_alpha(clip_panel, 0)
	self._stop = false
	hint_panel:set_visible(false)
	done_cb()
end