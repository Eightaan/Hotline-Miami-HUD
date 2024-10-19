local HMH = HMH

if RequiredScript == "core/lib/managers/subtitle/coresubtitlepresenter" then
	core:module("CoreSubtitlePresenter")
	Hooks:OverrideFunction(OverlayPresenter, "show_text", function(self, text, duration)
		local text_shadow = HMH:GetOption("custom_subs")
		self._text_scale = HMH:GetOption("hud_scale")
		self.__font_name = "fonts/font_medium_mf"
		local sub_color = HMH:GetOption("custom_subs") and HMH:GetColor("Sub") or Color.white
		local sub_alpha = HMH:GetOption("SubAlpha") or 1
		local label = self.__subtitle_panel:child("label") or self.__subtitle_panel:text({
			name = "label",
			font = self.__font_name,
			font_size = self.__font_size * self._text_scale,
			alpha = sub_alpha,
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
			alpha = sub_alpha,
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
	end)
end