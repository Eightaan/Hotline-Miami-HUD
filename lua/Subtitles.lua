if RequiredScript == "core/lib/managers/subtitle/coresubtitlepresenter" then
	core:module("CoreSubtitlePresenter")
	function OverlayPresenter:show_text(text, duration)
        local text_shadow
		if _G.VHUDPlus then
		    self._text_scale = _G.VHUDPlus:getSetting({"MISCHUD", "SCALE"}, 1)
			text_shadow = _G.VHUDPlus:getSetting({"MISCHUD", "SUB"}, true)
		else
		    self._text_scale = _G.HMH:GetOption("hud_scale")
			text_shadow = _G.HMH:GetOption("custom_subs")
		end

		self.__font_name = "fonts/font_medium_mf"
		local sub_color
		if _G.HMH:GetOption("custom_subs") and _G.BeardLib then
		    sub_color = _G.hotlinemiamihud.Options:GetValue("Sub")
		else
		    sub_color = _G.HMH:GetOption("custom_subs") and Color("66ff99") or Color.white
		end
		local label = self.__subtitle_panel:child("label") or self.__subtitle_panel:text({
			name = "label",
			font = self.__font_name,
			font_size = self.__font_size * self._text_scale,
			color = sub_color,
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