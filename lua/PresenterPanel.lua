if not HMH:GetOption("presenter") then
    return
end

Hooks:PostHook(HUDPresenter, "init", "HMH_hudpresenter_init", function(self, ...)
    if not self._hud_panel:child("present_panel") then
	    return
	end
	self._hud_panel:child("present_panel"):set_alpha(0)
    local title = self._bg_box:child("title")
 	local text = self._bg_box:child("text")	
 	self._hud_panel:child("present_panel"):show()
 	self._bg_box:child("bg"):hide()
	self._bg_box:child("left_top"):hide()
	self._bg_box:child("left_bottom"):hide()
	self._bg_box:child("right_top"):hide()
	self._bg_box:child("right_bottom"):hide()
	title:set_color(HMH:GetColor("PresenterTitle"))
	title:set_font_size(24)
	title:set_alpha(HMH:GetOption("presentAlpha"))
	text:set_color(HMH:GetColor("PresenterText"))
	text:set_alpha(HMH:GetOption("presentAlpha"))
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

-- For VanillaHUD Plus users
function HUDPresenter:_present_done()
	self._presenting = false
	local queued = table.remove(self._present_queue, 1)

	if queued and queued.present_mid_text then
		setup:add_end_frame_clbk(callback(self, self, "_do_it", queued))
	end
end