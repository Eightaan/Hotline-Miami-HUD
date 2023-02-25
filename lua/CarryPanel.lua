if not HMH:GetOption("carry") then 
    return
end

Hooks:PostHook(HUDTemp, "init", "HMH_HUDTempInit", function(self, hud, ...)
	self._hud_panel = hud.panel
	self._temp_panel = self._hud_panel:panel({
		y = 0,
		name = "temp_panel",
		layer = 0,
		visible = true,
		valign = "scale"
	})
	
	local bag_panel = self._temp_panel:panel({
		halign = "right",
		name = "bag_panel",
		layer = 10,
		visible = false,
		valign = "bottom"
	})
	self._bg_box = HUDBGBox_create(bag_panel, {
		w = 300,
		x = 0,
		h = 56,
		y = 0
	})

	bag_panel:set_size(self._bg_box:size())
	self._bg_box:text({
		layer = 1,
		name = "bag_text",
		vertical = "left",
		font_size = 24,
		text = "CARRYING:\nCIRCUIT BOARDS",
		font = "fonts/font_medium_mf",
		y = 2,
		x = 8,
		valign = "center",
		color = Color.white
	})

	bag_panel:set_right(self._temp_panel:w())
	bag_panel:set_bottom(self:_bag_panel_bottom())
end)

function HUDTemp:_animate_hide_bag_panel(bag_panel)
	set_alpha(bag_panel, 0)
end

function HUDTemp:_animate_show_bag_panel(bag_panel)
	local bag_text = self._bg_box:child("bag_text")
	set_alpha(bag_panel, 1)
	if HMH:GetOption("animate_text") then
	    while bag_text:visible() do
		    set_alpha(bag_panel, 0.6)
		    set_alpha(bag_panel, 1)
		end
	end
end

function HUDTemp:show_carry_bag(carry_id, value)
	local bag_panel = self._temp_panel:child("bag_panel")
	local carry_data = tweak_data.carry[carry_id]
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local bag_text = self._bg_box:child("bag_text")
	local bag_value = managers.money:get_secured_bonus_bag_value(carry_id, value)
	
	if self._bg_box then
	    self._bg_box:child("bg"):hide()
    	self._bg_box:child("left_top"):hide()
     	self._bg_box:child("left_bottom"):hide()
	    self._bg_box:child("right_top"):hide()
    	self._bg_box:child("right_bottom"):hide()
	end

	bag_panel:set_visible(true)
	local carrying_text = managers.localization:text("hud_carrying") .. " " .. type_text
	local value_text = not tweak_data.carry[carry_id].skip_exit_secure and HMH:GetOption("carry_value") and managers.localization:text("st_menu_value") .. ": " .. tostring(managers.experience:cash_string(bag_value)) or ""

	self._bg_box:child("bag_text"):set_text(utf8.to_upper(carrying_text .. "\n" .. value_text))

	local team_color = HMH:GetOption("colored_carry_text") and tweak_data.chat_colors[managers.network:session():local_peer():id()] or Color.white
	bag_text:set_color(team_color)
	bag_text:set_font_size(20)
	bag_text:set_alpha(HMH:GetOption("CarryAlpha"))
	
	bag_panel:stop()
	bag_panel:animate(callback(self, self, "_animate_show_bag_panel"))

	managers.hud:make_fine_text(self._bg_box:child("bag_text"))
	self._bg_box:child("bag_text"):set_right(bag_panel:w())
end

function HUDTemp:hide_carry_bag()
	local bag_panel = self._temp_panel:child("bag_panel")
	bag_panel:stop()
	bag_panel:animate(callback(self, self, "_animate_hide_bag_panel"))
end