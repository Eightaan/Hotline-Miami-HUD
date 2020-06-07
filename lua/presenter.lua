--Using LDDG Animations
Hooks:PostHook(HUDPresenter, "init", "HMH_hudpresenter_init", function(self, ...)
	if HMH:GetOption("presenter") then
	    self._hud_panel:child("present_panel"):set_alpha(0)
 	    local title = self._bg_box:child("title")	
 	    local text = self._bg_box:child("text")	
 	    self._hud_panel:child("present_panel"):show()
 	    self._bg_box:child("bg"):hide()
	    title:set_color(Color("66ff99"))
	    title:set_font_size(24)
	    text:set_color(Color("66ffff"))
	    text:set_font_size(20)
	end
end)

local HUDPresenter_animate_present_information = HUDPresenter._animate_present_information
function HUDPresenter:_animate_present_information(present_panel, params)
	if not HMH:GetOption("presenter") then return HUDPresenter_animate_present_information(self, present_panel, params) end
	    local title = self._bg_box:child("title")
	    local text = self._bg_box:child("text")
	    title:set_visible(params.has_title)
	    text:set_visible(true)
	
	--LDDG Animations
	    set_alpha(present_panel, 1)
	    wait(3)
	    set_alpha(present_panel, 0)
	    self:_present_done()
end