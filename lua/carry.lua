--Using LDDG Animations

local HUDTemp_animate_hide_bag_panel = HUDTemp._animate_hide_bag_panel
function HUDTemp:_animate_hide_bag_panel(bag_panel)
    if not HMH:GetOption("carry") then return HUDTemp_animate_hide_bag_panel(self, bag_panel) end
	
	set_alpha(bag_panel, 0)	--LDDG Animation
end

local HUDTemp_animate_show_bag_panel= HUDTemp._animate_show_bag_panel
function HUDTemp:_animate_show_bag_panel(bag_panel)
	if not HMH:GetOption("carry") then return HUDTemp_animate_show_bag_panel(self, bag_panel) end
	
	--LDDG Animations
	local bag_text = self._bg_box:child("bag_text")
	set_alpha(bag_panel, 1)	
	while bag_text:visible() do
		set_alpha(bag_panel, 0.6)
		set_alpha(bag_panel, 1)
	end
end 

local HUDTemp_show_carry_bag = HUDTemp.show_carry_bag
function HUDTemp:show_carry_bag(carry_id, value)	
	if not HMH:GetOption("carry") then return HUDTemp_show_carry_bag(self, carry_id, value) end
	
	local bag_panel = self._temp_panel:child("bag_panel")
	local carry_data = tweak_data.carry[carry_id]
	local type_text = carry_data.name_id and managers.localization:text(carry_data.name_id)
	local bag_text = self._bg_box:child("bag_text")
	
	bag_panel:set_visible(true)
	
	local carrying_text = managers.localization:text("hud_carrying")
	
	self._bg_box:child("bag_text"):set_text(utf8.to_upper(carrying_text .. " " .. type_text))
	
	local team_color = tweak_data.chat_colors[managers.network:session():local_peer():id()]
	bag_text:set_color(team_color)
	bag_text:set_font_size(20)
	
	bag_panel:stop()
	bag_panel:animate(callback(self, self, "_animate_show_bag_panel"))
	
	--LDDG Putting the carry text in place
	managers.hud:make_fine_text(self._bg_box:child("bag_text"))
	self._bg_box:child("bag_text"):set_right(bag_panel:w())
end 