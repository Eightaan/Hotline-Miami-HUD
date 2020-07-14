if string.lower(RequiredScript) == "core/lib/managers/subtitle/coresubtitlepresenter" then	
	core:module("CoreSubtitlePresenter")
	function OverlayPresenter:show_text(text, duration)
        -- Using the same code as vanilla hud plus so they work together
        local text_shadow
		if _G.VHUDPlus then
		    self._text_scale = _G.VHUDPlus:getSetting({"MISCHUD", "SCALE"}, 1)
			text_shadow = _G.VHUDPlus:getSetting({"MISCHUD", "SUB"}, true)
		else
		    self._text_scale = _G.HMH:GetOption("hud_scale")
			text_shadow = _G.HMH:GetOption("custom_subs")
		end
		
		self.__font_name = "fonts/font_medium_mf"
		local label = self.__subtitle_panel:child("label") or self.__subtitle_panel:text({
			name = "label",
			font = self.__font_name,
			font_size = self.__font_size * self._text_scale,
			color = _G.HMH:GetOption("custom_subs") and Color("66ff99") or Color.white,
			align = "center",
			vertical = "bottom",
			layer = 1,
			wrap = true,
			word_wrap = true
		})
		local shadow = self.__subtitle_panel:child("shadow") or self.__subtitle_panel:text({
			name = "shadow",
			x = 1,
			y = 1,
			font = self.__font_name,
			font_size = self.__font_size * self._text_scale,
			color = Color.black:with_alpha(1),
			align = "center",
			vertical = "bottom",
			layer = 0,
			wrap = true,
			word_wrap = true
		})
		label:set_text(text)
		shadow:set_text(text)	
		label:set_font_size(self.__font_size * self._text_scale)
		shadow:set_font_size(self.__font_size * self._text_scale)
		shadow:set_visible(text_shadow)
	end
end