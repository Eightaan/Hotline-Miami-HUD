local HMH = HMH

if not HMH:GetOption("carry") then 
	return
end

Hooks:OverrideFunction(HUDTemp, "_animate_hide_bag_panel", function(self, bag_panel) set_alpha(bag_panel, 0) end)

Hooks:OverrideFunction(HUDTemp, "show_carry_bag", function(self, carry_id, value)
	local bag_panel = self._temp_panel:child("bag_panel")
	local carry_data = tweak_data.carry[carry_id]
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local bag_text = self._bg_box:child("bag_text")
	local bag_value = managers.money:get_secured_bonus_bag_value(carry_id, value)

	if self._bg_box then
		for _, child in ipairs({"bg", "left_top", "left_bottom", "right_top", "right_bottom"}) do
			self._bg_box:child(child):hide()
		end
	end

	bag_panel:set_visible(true)
	local carrying_text = managers.localization:text("hud_carrying") .. " " .. type_text
	local value_text = (not carry_data.skip_exit_secure and HMH:GetOption("carry_value")) and managers.localization:text("st_menu_value") .. ": " .. tostring(managers.experience:cash_string(bag_value)) or ""

	bag_text:set_text(utf8.to_upper(carrying_text .. "\n" .. value_text))

	local team_color = HMH:GetOption("colored_carry_text") and tweak_data.chat_colors[managers.network:session():local_peer():id()] or Color.white
	bag_text:set_color(team_color)
	bag_text:set_font_size(19)
	bag_text:set_alpha(HMH:GetOption("CarryAlpha"))

	bag_panel:stop()
	bag_panel:animate(callback(self, self, "_animate_show_bag_panel_hmh"))

	managers.hud:make_fine_text(bag_text)
	bag_text:set_right(bag_panel:w())
end)

function HUDTemp:_animate_show_bag_panel_hmh(bag_panel)
	local bag_text = self._bg_box:child("bag_text")
	set_alpha(bag_panel, 1)
	if HMH:GetOption("animate_text") then
		while bag_text:visible() do
			set_alpha(bag_panel, 0.6)
			set_alpha(bag_panel, 1)
		end
	end
end