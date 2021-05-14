if not HMH:GetOption("presenter") then 
    return 
end

Hooks:PostHook(HUDPresenter, "init", "HMH_hudpresenter_init", function(self, ...)
	self._hud_panel:child("present_panel"):set_alpha(0)
    local title = self._bg_box:child("title")
 	local text = self._bg_box:child("text")	
 	self._hud_panel:child("present_panel"):show()
 	self._bg_box:child("bg"):hide()
	title:set_color(BeardLib and hotlinemiamihud.Options:GetValue("PresenterTitle") or Color("66ff99"))
	title:set_font_size(24)
	text:set_color(BeardLib and hotlinemiamihud.Options:GetValue("PresenterText") or Color("66ffff"))
	text:set_font_size(20)
end)

function HUDPresenter:_animate_present_information(present_panel, params)
	local title = self._bg_box:child("title")
	local text = self._bg_box:child("text")
	title:set_visible(params.has_title)
	text:set_visible(true)

	set_alpha(present_panel, 1)
	wait(3)
	set_alpha(present_panel, 0)
	self:_present_done()
end