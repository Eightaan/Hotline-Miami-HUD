--[[
	Original code by Void UI team

	HMH Menu specific code made by Dom
	List:
	Items in line
	Focus changed callback
	Callback arguments
	Color animation
	Input
]]

local math_clamp = math.clamp
local math_round = math.round
local math_lerp = math.lerp

local math_random = math.random
local math_floor = math.floor
local math_max = math.max

local function make_fine_text(text_obj)
	local x, y, w, h = text_obj:text_rect()

	text_obj:set_size(w, h)
	text_obj:set_position(math_round(text_obj:x()), math_round(text_obj:y()))
end

local function do_animation(TOTAL_T, clbk)
	local t = 0
	while t < TOTAL_T do
		coroutine.yield()
		t = t + TimerManager:main():delta_time()
		clbk(t / TOTAL_T, t)
	end
	clbk(1, TOTAL_T)
end

HMHMenu = HMHMenu or class()
HMHMenu.AspectRatio =
{
	_16_10 = 1,
	_4_3 = 2,
	Other = 3
}
function HMHMenu:init()
	local aspect_ratio = RenderSettings.resolution.x / RenderSettings.resolution.y
	local _1_33 = 4 / 3
	local AspectRatioEnum
	if aspect_ratio == 1.6 or aspect_ratio == _1_33 then -- 16:10 or 4:3
		AspectRatioEnum = aspect_ratio == 1.6 and self.AspectRatio._16_10 or self.AspectRatio._4_3
		self._ws = managers.gui_data:create_fullscreen_16_9_workspace()
		self._convert_mouse_pos = function(menu, x, y)
			return managers.mouse_pointer:convert_fullscreen_16_9_mouse_pos(x, y)
		end
	else
		AspectRatioEnum = self.AspectRatio.Other
		self._ws = managers.gui_data:create_fullscreen_workspace()
		self._convert_mouse_pos = function(menu, x, y)
			return x, y
		end
	end
	self._ws:connect_keyboard(Input:keyboard())
	self._mouse_id = managers.mouse_pointer:get_id()
	self._menus = {}
	self._axis_timer = { x = 0, y = 0 }
	self._panel = self._ws:panel():panel({
		name = "HMHMenu",
		layer = 500,
		alpha = 0
	})
	local background_size = managers.gui_data:full_scaled_size()
	local bg = self._panel:bitmap({
		name = "bg",
		color = Color.black,
		alpha = 0.25,
		layer = -1,
		rotation = 360,
		w = background_size.w
	})
	bg:set_center_x(self._panel:w() / 2)
	local blur_bg = self._panel:bitmap({
		name = "blur_bg",
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = background_size.w,
		h = self._panel:h(),
		rotation = 360,
		layer = -2,
	})
	blur_bg:set_center_x(self._panel:w() / 2)
	self._tooltip = self._panel:text({
		name = "tooltip",
		font_size = 18,
		font = tweak_data.menu.pd2_medium_font,
		y = 10,
		w = 500,
		align = "right",
		wrap = true,
		word_wrap = true,
	})
	self._tooltip_bottom = self._panel:text({
		name = "tooltip_bottom",
		font_size = 18,
		font = tweak_data.menu.pd2_medium_font,
		y = 10,
		w = 500,
		align = "right",
		wrap = true,
		word_wrap = true,
	})
	local options_bg = self._panel:rect({
		name = "options_bg",
		color = Color.black,
		alpha = 0.3,		
		w = self._panel:w() / 2.5,
		h = self._panel:h(),
	})
	options_bg:set_right(self._panel:w())
	self._options_panel = self._panel:panel({
		name = "options_panel",
		y = 5,
		w = options_bg:w() - 20,
		h = options_bg:h() - 45,
	})
	self._options_panel:set_right(self._panel:w() - 10)
	self._tooltip:set_right(self._options_panel:x() - 20)
	self._tooltip_bottom:set_right(self._options_panel:x() - 20)
	if managers.menu:is_pc_controller() then
		local back_button = self._panel:panel({
			name = "back_button",
			w = 100,
			h = 25,
			layer = 2
		})
		local esc = " %["..utf8.to_upper(managers.controller:get_settings("pc"):get_connection("back"):get_input_name_list()[1]).."%]"
		local title = back_button:text({
			name = "title",
			font_size = 28,
			font = tweak_data.menu.pd2_large_font,
			align = "center",
			text = managers.localization:text("menu_back"):gsub(esc, "")
		})
		make_fine_text(title)
		back_button:set_size(title:w() + 16, title:h() + 2)
		title:set_center(back_button:w() / 2, back_button:h() / 2)
		back_button:set_righttop(self._options_panel:right(), self._options_panel:bottom() + 2)
		local bg = back_button:bitmap({
			name = "bg",
			alpha = 0,
		})
		self._back_button = { type = "button", panel = back_button, callback = "Cancel", num = 0 }
	else
		self._button_legends = self._panel:text({
			name = "legends",
			layer = 2,
			w = options_bg:w() - 20,
			h = 25,
			font_size = 23,
			font = tweak_data.menu.pd2_medium_font,
			align = "right",
			text = managers.localization:text("menu_legend_select", {BTN_UPDATE = managers.localization:btn_macro("menu_update")}).."    "..managers.localization:text("menu_legend_back", {BTN_BACK = managers.localization:btn_macro("back")})
		})
		self._button_legends:set_right(self._options_panel:right() - 5)
		self._button_legends:set_top(self._options_panel:bottom())
	end
	
	if HMHMenu.Warning == 1 then
		self:CreateChangeWarning()
	end

	self:GetMenuFromJson(HMH._menu_path .. "Main.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "Presets/PresetsOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "MenuOptions/EnhancedLoadout/EnhancedLoadoutOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "MenuOptions/SkipMenus/SkipMenusOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "MenuOptions/Main.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/Main.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TeamHud/TeamHudOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TeamHud/PlayerColor/PlayerColorOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TeamHud/CustodyDowned/CustodyDownedOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TeamHud/Ammo/AmmoOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TeamHud/Ability/AbilityOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TeamHud/Equipment/EquipmentOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/ECMTimer/ECMTimerOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/BuffList/BuffListOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/InteractionAndCarry/InteractionAndCarryOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/Assault/AssaultOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TabstatsAndSubtitles/TabstatsAndSubtitlesOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/WaypointAndDetection/WaypointAndDetectionOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/Notifications/NotificationsOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/TimerAndObjectives/TimerAndObjectivesOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/ComboCounter/ComboCounterOptions.json", HMH._data)
	self:GetMenuFromJson(HMH._menu_path .. "HudOptions/JoiningPlayers/JoiningPlayersOptions.json", HMH._data)

	self:OpenMenu("hmh_menu")
end

function HMHMenu:CallCallback(item, params)
	if item.callback then
		params = params or {}
		local value = item.value
		if params.to_n then
			value = tonumber(value)
		end
		if params.color then
			local cpanels = { 5, 32, 59 }
			local colors = {}
			local i = 1
			for _, v in pairs(params.color_panels) do
				if v:y() == cpanels[i] then
					colors[#colors + 1] = v:child("value"):text()
					i = i + 1
				end
			end
			value = Color(colors[1], colors[2], colors[3])
		end
		local var = item.callback_arguments and type(item.callback_arguments) == "table" or false
		if type(item.callback) == "table" then
			for _, clbk in pairs(item.callback) do
				if var then
					self[clbk](self, value, unpack(item.callback_arguments))
				else
					self[clbk](self, value, item.callback_arguments)
				end
			end
		else
			if var then
				self[item.callback](self, value, unpack(item.callback_arguments))
			else
				self[item.callback](self, value, item.callback_arguments)
			end
		end
	end
end

function HMHMenu:update(t, dt)
	if self._axis_timer.y <= 0 then
		if 0.5 < self._controller:get_input_axis("menu_move").y or self._controller:get_input_bool("menu_up") then
			self:MenuUp()
			self:SetAxisTimer("y", 0.18, 0.3, "menu_up")
		elseif -0.5 > self._controller:get_input_axis("menu_move").y or self._controller:get_input_bool("menu_down") then
			self:MenuDown()
			self:SetAxisTimer("y", 0.18, 0.3, "menu_down")
		end
	end
	if self._controller and self._axis_timer.x <= 0 then
		if 0.5 < self._controller:get_input_axis("menu_move").x or self._controller:get_input_bool("menu_right") then
			self:MenuLeftRight(1)
			self:SetAxisTimer("x", 0.12, 0.22, "menu_right")
		elseif -0.5 > self._controller:get_input_axis("menu_move").x or self._controller:get_input_bool("menu_left") then
			self:MenuLeftRight(-1)
			self:SetAxisTimer("x", 0.12, 0.22, "menu_left")
		end

		if not managers.menu:is_pc_controller() and self._controller:get_input_bool("next_page") then
			self:MenuLeftRight(10)
			self:SetAxisTimer("x", 0.12, 0.22, "next_page")
		elseif not managers.menu:is_pc_controller() and self._controller:get_input_bool("previous_page") then
			self:MenuLeftRight(-10)
			self:SetAxisTimer("x", 0.12, 0.22, "previous_page")
		end
	end

	self._axis_timer.y = math_max(self._axis_timer.y - dt, 0)
	self._axis_timer.x = math_max(self._axis_timer.x - dt, 0)
end

function HMHMenu:SetAxisTimer(axis, delay, input_delay, input)
	self._axis_timer[axis] = delay
	if self._controller:get_input_pressed(input) then
		self._axis_timer[axis] = input_delay
	end
end

function HMHMenu:Open()
	self._enabled = true
	managers.menu._input_enabled = false
	for _, menu in ipairs(managers.menu._open_menus) do
		menu.input._controller:disable()
	end

	if not self._controller then
		self._controller = managers.controller:create_controller("HMHMenu", nil, false)
		self._controller:add_trigger("cancel", callback(self, self, "Cancel"))
		self._controller:add_trigger("confirm", callback(self, self, "Confirm"))
		self._controller:add_trigger("menu_toggle_voice_message", callback(self, self, "SetItem"))
		if managers.menu:is_pc_controller() then
			managers.mouse_pointer:use_mouse({
				mouse_move = callback(self, self, "mouse_move"),
				mouse_press = callback(self, self, "mouse_press"),
				mouse_release = callback(self, self, "mouse_release"),
				id = self._mouse_id
			})
		end
	end

	self._panel:stop()
	self._panel:animate(function(o)
		local a = self._panel:alpha()

		do_animation(0.2, function (p)
			self._panel:set_alpha(math_lerp(a, 1, p))
		end)
		self._controller:enable()
	end)
end

function HMHMenu:Close()
	self._enabled = false
	managers.mouse_pointer:remove_mouse(self._mouse_id)
	if self._controller then
		self._controller:destroy()
		self._controller = nil
	end
	HMH:Save()
	self._panel:stop()
	self._panel:animate(function(o)
		local a = self._panel:alpha()

		do_animation(0.2, function (p)
			self._panel:set_alpha(math_lerp(a, 0, p))
		end)

		self._panel:set_alpha(0)
		managers.menu._input_enabled = true
		for _, menu in ipairs(managers.menu._open_menus) do
			menu.input._controller:enable()
		end
	end)
end

-- Mouse Functions
function HMHMenu:mouse_move(o, x, y)
	x, y = self:_convert_mouse_pos(x, y)
	if self._open_menu then
		managers.mouse_pointer:set_pointer_image("arrow")
		if self._open_choice_dialog and self._open_choice_dialog.panel then
			local selected = false
			for i, item in pairs(self._open_choice_dialog.items) do
				if alive(item) and item:inside(x,y) and not selected then
					if self._open_choice_dialog.selected > 0 and self._open_choice_dialog.selected ~= i then
						self._open_choice_dialog.items[self._open_choice_dialog.selected]:set_color(Color(0.6,0.6,0.6))
					end
					item:set_color(Color.white)
					self._open_choice_dialog.selected = i
					selected = true
					managers.mouse_pointer:set_pointer_image("link")
				end
			end
		elseif self._open_color_dialog and self._open_color_dialog.panel then
			if self._slider then
				self:SetColorSlider(self._slider.slider, x, self._slider.type)
				managers.mouse_pointer:set_pointer_image("grab")
			else
				for i, item in pairs(self._open_color_dialog.items) do
					if alive(item) and item:inside(x,y) and item:child("bg"):alpha() ~= 0.1 then
						if self._open_color_dialog.selected > 0 and self._open_color_dialog.selected ~= i then
							self._open_color_dialog.items[self._open_color_dialog.selected]:child("bg"):set_alpha(0)
						end
						item:child("bg"):set_alpha(0.1)
						self._open_color_dialog.selected = i
						managers.mouse_pointer:set_pointer_image("link")
					end
				end
			end
		elseif self._slider then
			self:SetSlider(self._slider, x)
		elseif self._back_button and self._back_button.panel:inside(x,y) then
			self:HighlightItem(self._back_button)
			managers.mouse_pointer:set_pointer_image("link")
		else
			for _, item in pairs(self._open_menu.items) do
				if item.enabled and item.panel:inside(x,y) and item.panel:child("bg") then
					self:HighlightItem(item)
					if item.type == "slider" then
						managers.mouse_pointer:set_pointer_image("hand")
					else
						managers.mouse_pointer:set_pointer_image("link")
					end
				end
			end
		end
	end
end

function HMHMenu:mouse_press(o, button, x, y)
	x, y = self:_convert_mouse_pos(x, y)
	if button == Idstring("0") then
		if self._open_choice_dialog then
			if self._open_choice_dialog.panel:inside(x,y) then
				for i, item in pairs(self._open_choice_dialog.items) do
					if alive(item) and item:inside(x,y) and item:alpha() == 1 then
						local parent_item = self._open_choice_dialog.parent_item
						parent_item.panel:child("title_selected"):set_text(self._open_choice_dialog.items[i]:text())
						parent_item.value = i
						self:CloseMultipleChoicePanel()
						self:CreateChangeWarning()
					end
				end
			else
				self:CloseMultipleChoicePanel()
			end
		elseif self._open_color_dialog then
			if self._open_color_dialog.panel:inside(x,y) then
				for i, item in pairs(self._open_color_dialog.items) do
					if alive(item) and item:inside(x,y) then
						if item:child("slider") then
							self._slider = {slider = item, type = i}
							self:SetColorSlider(item, x, i)
							managers.mouse_pointer:set_pointer_image("grab")
						elseif item:name() == "reset_panel" then
							self:ResetColorMenu()
						else
							self:CloseColorMenu(true)
						end
					end
				end
			else
				self:CloseColorMenu(false)
			end
		elseif self._input then
			if self._input.panel:inside(x, y) then
				--HMH:Log(Activate input")
			else
				self:CloseInput()
			end
		elseif self._highlighted_item and self._highlighted_item.panel:inside(x,y) then
			self:ActivateItem(self._highlighted_item, x)
		end
		HMH:Save()
	end
end

function HMHMenu:mouse_release(o, button, x, y)
	if button == Idstring("0") then
		if self._slider then
			self:CallCallback(self._slider, { to_n = true })
			self._slider = nil
			managers.mouse_pointer:set_pointer_image("hand")
		end
	end
end

-- Item interaction
function HMHMenu:Confirm()
	if not self._enabled then
		return
	end
	if self._open_choice_dialog then
		for i, item in pairs(self._open_choice_dialog.items) do
			if alive(item) and self._open_choice_dialog.selected == i then
				local parent_item = self._open_choice_dialog.parent_item
				parent_item.panel:child("title_selected"):set_text(self._open_choice_dialog.items[i]:text())
				parent_item.value = i
				self:CloseMultipleChoicePanel()
				self:CreateChangeWarning()
			end
		end
	elseif self._open_color_dialog then
		if self._open_color_dialog.selected == 4 then
			self:CloseColorMenu(true)
		elseif self._open_color_dialog.selected == 5 then
			self:ResetColorMenu()
		end
	elseif self._highlighted_item then
		self:ActivateItem(self._highlighted_item)
	end
end

function HMHMenu:MenuDown()
	if not self._enabled then
		return
	end
	if self._open_choice_dialog then
		if self._open_choice_dialog.selected < #self._open_choice_dialog.items then
			if self._open_choice_dialog.selected > 0 then
				self._open_choice_dialog.items[self._open_choice_dialog.selected]:set_color(Color(0.6,0.6,0.6))
			end
			self._open_choice_dialog.items[self._open_choice_dialog.selected + 1]:set_color(Color.white)
			self._open_choice_dialog.selected = self._open_choice_dialog.selected + 1
		end
	elseif self._open_color_dialog then
		if self._open_color_dialog.selected < 4 then
			if self._open_color_dialog.selected > 0 then
				self._open_color_dialog.items[self._open_color_dialog.selected]:child("bg"):set_alpha(0)
			end
			self._open_color_dialog.items[self._open_color_dialog.selected + 1]:child("bg"):set_alpha(0.1)
			self._open_color_dialog.selected = self._open_color_dialog.selected + 1
			self:SetLegends(self._open_color_dialog.selected == 4 and true or false, false, self._open_color_dialog.selected < 4 and true or false)
		end
	elseif self._open_menu and not self._highlighted_item then
		for i, item in pairs(self._open_menu.items) do
			if item.enabled and item.panel:child("bg") then
				self:HighlightItem(item)
				return
			end
		end
	elseif self._open_menu and self._highlighted_item then
		local current_num = self._highlighted_item.num + 1 > #self._open_menu.items - 1 and 0 or self._highlighted_item.num + 1
		for i = current_num, (#self._open_menu.items - current_num) + current_num do
			local item = self._open_menu.items[i + 1]
			if item and item.enabled and item.panel:child("bg") then
				self:HighlightItem(item)
				return
			end
		end
		for i = 0, #self._open_menu.items do
			local item = self._open_menu.items[i]
			if item and item.enabled and item.panel:child("bg") then
				self:HighlightItem(item)
				return
			end
		end
	end
end

function HMHMenu:MenuUp()
	if not self._enabled then
		return
	end
	if self._open_choice_dialog then
		if self._open_choice_dialog.selected > 1 then
			self._open_choice_dialog.items[self._open_choice_dialog.selected]:set_color(Color(0.7,0.7,0.7))
			self._open_choice_dialog.items[self._open_choice_dialog.selected - 1]:set_color(Color.white)
			self._open_choice_dialog.selected = self._open_choice_dialog.selected - 1
		end
	elseif self._open_color_dialog then
		if self._open_color_dialog.selected > 1 then
			self._open_color_dialog.items[self._open_color_dialog.selected]:child("bg"):set_alpha(0)
			self._open_color_dialog.items[self._open_color_dialog.selected - 1]:child("bg"):set_alpha(0.1)
			self._open_color_dialog.selected = self._open_color_dialog.selected - 1
			self:SetLegends(false, false, true)
		end
	elseif self._open_menu and self._highlighted_item then
		local current_num = self._highlighted_item.num + 1
		for i = current_num, 1, - 1 do
			local item = self._open_menu.items[i - 1]
			if item and item.enabled and item.panel:child("bg") then
				self:HighlightItem(item)
				return
			end
		end
		for i = #self._open_menu.items + 1, 1, - 1 do
			local item = self._open_menu.items[i - 1]
			if item and item.enabled and item.panel:child("bg") then
				self:HighlightItem(item)
				return
			end
		end
	end
end

function HMHMenu:MenuLeftRight(change)
	if not self._enabled then
		return
	end
	if self._open_color_dialog and self._open_color_dialog.selected < 4 then
		self:SetColorSlider(self._open_color_dialog.items[self._open_color_dialog.selected], nil, self._open_color_dialog.selected, change)
	elseif self._open_menu and self._highlighted_item and self._highlighted_item.type == "slider" then
		self:SetSlider(self._highlighted_item, nil, change)
		self:CallCallback(self._highlighted_item, { to_n = true })
	end
end

function HMHMenu:ActivateItem(item, x)
	if not self._highlighted_item then
		return
	end

	if item.type == "button" then
		if item.next_menu and self._menus[item.next_menu] then
			self:OpenMenu(item.next_menu)
		elseif item.callback then
			self:CallCallback(item)
		end
	elseif item.type == "toggle" then
		local value = not item.value
		self:SetItem(item, value, self._open_menu)
	elseif item.type == "multiple_choice" and not self._open_choice_dialog then
		self:OpenMultipleChoicePanel(item)
	elseif item.type == "slider" and x then
		self._slider = item
		self:SetSlider(item, x)
		managers.mouse_pointer:set_pointer_image("grab")
		self:CreateChangeWarning()
	elseif item.type == "input" then
		self:SetInput(item)
	elseif item.type == "color_select" and not self._open_color_dialog then
		self:OpenColorMenu(item)
	end
end

function HMHMenu:CreateChangeWarning()
	if managers.hud and not self._panel:child("changed_warning") then
		HMHMenu.Warning = 1
		local changed_warning = self._panel:text({
			name = "changed_warning",
			layer = 2,
			w = 500,
			h = 20,
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			color = Color.red,
			align = "right",
			text = managers.localization:text("HMH_warning_desc")
		})
		changed_warning:set_right(self._options_panel:left() - 15)
		changed_warning:set_bottom(self._panel:h())
	end
end

function HMHMenu:SetMenuItemsEnabled(menu, parent_item_id, enabled)
	for _, item in pairs(menu.items) do
		local parents = item.parent
		if parents then
			local e
			if type(parents) == "string" and parents == parent_item_id then
				e = enabled
			elseif type(parents) == "table" then
				e = true
				for _, parent in pairs(parents) do
					for _, menu_item in pairs(menu.items) do
						if menu_item.id == parent and menu_item.value == false then
							e = false
							break
						end
					end
				end
			end
			self:AnimateItemEnabled(item, e)
		end
	end
end

function HMHMenu:GetMenu(menu)
	return self._menus[menu]
end

function HMHMenu:AnimateItemEnabled(item, enabled)
	if item.panel and enabled ~= nil and enabled ~= item.enabled then
		item.enabled = enabled
		item.panel:stop()
		item.panel:animate(function(o)
			local alpha = o:alpha()
			do_animation(0.2, function (p)
				o:set_alpha(math_lerp(alpha, enabled and 1 or 0.5, p))
			end)
			o:set_alpha(enabled and 1 or 0.5)
		end)
	end
end

function HMHMenu:HighlightItem(item)
	if self._highlighted_item and self._highlighted_item == item then
		return
	end
	if self._highlighted_item then
		self:UnhighlightItem(self._highlighted_item)
	end
	item.panel:child("bg"):stop()
	item.panel:child("bg"):animate(function(o)
		local alpha = o:alpha()
		do_animation(0.2, function (p)
			o:set_alpha(math_lerp(alpha, 0.3, p))
		end)
		o:set_alpha(0.3)
	end)
	self._highlighted_item = item

	self._tooltip:set_text(self._highlighted_item.desc or "")
	if item.focus_changed_callback then
		self[item.focus_changed_callback](self, true)
	end
end

function HMHMenu:UnhighlightItem(item)
	if item.focus_changed_callback then
		self[item.focus_changed_callback](self, false)
	end
	item.panel:child("bg"):stop()
	item.panel:child("bg"):animate(function(o)
		local alpha = o:alpha()
		do_animation(0.20, function (p)
			o:set_alpha(math_lerp(alpha, 0, p))
		end)
		o:set_alpha(0)
	end)
	self._highlighted_item = nil
end

function HMHMenu:SetLegends(accept, reset, step)
	if self._button_legends then
		local text = managers.localization:text("menu_legend_back", {BTN_BACK = managers.localization:btn_macro("back")})
		local separator = "    "
		if accept then text = managers.localization:text("menu_legend_select", {BTN_UPDATE  = managers.localization:btn_macro("menu_update")}).. separator ..text end
		if reset then text = managers.localization:to_upper_text("VoidUI_tooltip_reset_cnt", {BTN_RESET  = managers.localization:btn_macro("menu_toggle_voice_message")}).. separator.. text end
		if step then text = managers.localization:to_upper_text("VoidUI_tooltip_steps", {BTN_STEP  = managers.localization:btn_macro("previous_page")..managers.localization:btn_macro("next_page")}).. separator.. text end
		self._button_legends:set_text(text)
	end
end

function HMHMenu:Cancel()
	if self._open_choice_dialog then
		self:CloseMultipleChoicePanel()
	elseif self._open_color_dialog then
		self:CloseColorMenu(false)
	elseif self._input then
		self:CloseInput()
	elseif self._open_menu and self._open_menu.parent_menu then
		self:OpenMenu(self._open_menu.parent_menu, true)
	else
		self:Close()
	end
end

function HMHMenu:SetItem(item, value, menu)
	if item == nil or type(item) ~= "table" then
		item = self._highlighted_item
		value = item.default_value
		menu = self._open_menu
	end
	if item and type(item) == "table" and item.default_value ~= nil then
		if item.type == "toggle" then
			item.value = value

			item.panel:child("check"):stop()
			item.panel:child("check"):animate(function(o)
				local alpha = o:alpha()
				local w, h = o:size()
				local check = item.panel:child("check_bg")
				do_animation(0.1, function (p)
					o:set_alpha(math_lerp(alpha, value and 1 or 0, p))
					o:set_size(math_lerp(w, value and check:w() or check:w() * 2, p), math_lerp(h, value and check:h() or check:h() * 2, p))
					o:set_center(check:center())
				end)
				o:set_alpha(value and 1 or 0)
			end)
		elseif item.type == "slider" then
			value = string.format("%." .. (item.step or 0) .. "f", value)
			local percentage = (value - item.min) / (item.max - item.min)
			item.panel:child("value_bar"):set_w(math_max(1,item.panel:w() * percentage))
			item.panel:child("value_text"):set_text(item.percentage and math_floor(value * 100).."%" or value ..(item.suffix and item.suffix or ""))
			value = tonumber(value)
			item.value = value
		elseif item.type == "multiple_choice" then
			item.panel:child("title_selected"):set_text(item.items[value])
			item.value = value
		elseif item.type == "color_select" then
			value = Color(unpack(value))
			item.panel:child("color"):set_color(value)
			item.value = value
		end
		self:CreateChangeWarning()
		self:CallCallback(item, { to_n = item.type == "slider" })
		if item.is_parent then
			self:SetMenuItemsEnabled(menu, item.id, value)
		end
	end
end

--Menu Creation and activation
function HMHMenu:GetMenuFromJson(path, ...)
	local file = io.open(path, "r")
	if file then
		local file_content = file:read("*all")
		file:close()

		local content = json.decode(file_content)
		local menu_id = content.menu_id
		local parent_menu = content.parent_menu or nil
		local menu_title = managers.localization:text(content.title)
		local items = content.items

		if content.title == "hmh_title" then
			menu_title = menu_title .. " " .. HMH.ModVersion
		end

		local menu = self:CreateMenu({
			menu_id = menu_id,
			parent_menu = parent_menu,
			title = menu_title,
			focus_changed_callback = content.focus_changed_callback,
		})

		for i, item in pairs(items) do
			if item.table then
				self:CreateOneLineItems(item, items, menu_id, ...)
			else
				self:CreateItem(item, items, menu_id, ...)
			end
		end
		menu.panel:set_h(content.h or menu.items[#menu.items].panel:bottom())
		if content.created_menu_callback then
			self[content.created_menu_callback](self)
		end
	end
end

function HMHMenu:CreateItem(item, items, menu_id, ...)
	local item_type = item.type
	local id = item.id
	local title = item.title
	local desc = item.description
	local value = item.default_value
	local default_value = item.default_value
	local parents = item.parent
	local enabled = true

	if item.enabled ~= nil then
		enabled = item.enabled
	elseif parents then
		if type(parents) == "string" then
			for _, pitem in pairs(items) do
				if pitem.id == parents then
					enabled = HMH._data[pitem.value]
					break
				end
			end
		elseif type(parents) == "table" then
			local final = true
			for _, parent in ipairs(parents) do
				for _, pitem in pairs(items) do
					if pitem.id == parent then
						final = final and HMH._data[pitem.value]
						break
					end
				end
			end
			enabled = final
		end
	end

	value = HMH._data[item.value]

	local itm
	if item_type == "label" then
		itm = self:CreateLabel({
			menu_id = menu_id,
			id = id,
			enabled = enabled,
			title = managers.localization:text(title),
			parent = item.parent,
			center = item.center
		})
	elseif item_type == "divider" then
		itm = self:CreateDivider({
			menu_id = menu_id,
			size = item.size
		})
	elseif item_type == "button" then
		itm = self:CreateButton({
			menu_id = menu_id,
			id = id,
			title = managers.localization:text(title),
			description = managers.localization:text(desc),
			next_menu = item.next_menu,
			callback = item.callback,
			callback_arguments = item.callback_arguments,
			enabled = enabled,
			parent = item.parent
		})
	elseif item_type == "toggle" then
		itm = self:CreateToggle({
			menu_id = menu_id,
			id = id,
			title = managers.localization:text(title),
			description = managers.localization:text(desc),
			value = value,
			default_value = default_value,
			is_parent = item.is_parent,
			enabled = enabled,
			parent = item.parent,
			callback = item.callback,
			callback_arguments = item.callback_arguments,
			focus_changed_callback = item.focus_changed_callback
		})
	elseif item_type == "slider" then
		itm = self:CreateSlider({
			menu_id = menu_id,
			id = id,
			title = managers.localization:text(title),
			description = managers.localization:text(desc),
			percentage = item.percentage,
			callback = item.callback,
			callback_arguments = item.callback_arguments,
			max = item.max,
			min = item.min,
			step = item.step,
			value = value,
			suffix = item.suffix,
			default_value = default_value,
			enabled = enabled,
			parent = item.parent,
			focus_changed_callback = item.focus_changed_callback
		})
	elseif item_type == "multiple_choice" then
		for k = 1, #item.items do
			item.items[k] = managers.localization:text(item.items[k])
		end

		itm = self:CreateMultipleChoice({
			menu_id = menu_id,
			id = id,
			title = managers.localization:text(title),
			description = managers.localization:text(desc),
			value = value,
			items = item.items,
			default_value = default_value,
			enabled = enabled,
			parent = item.parent,
			callback = item.callback,
			callback_arguments = item.callback_arguments,
			focus_changed_callback = item.focus_changed_callback
		})
	elseif item_type == "input" then
		itm = self:CreateInput({
			menu_id = menu_id,
			id = id,
			title = managers.localization:text(title),
			description = managers.localization:text(desc),
			value = value,
			default_value = default_value,
			enabled = enabled,
			parent = item.parent,
			callback = item.callback,
			callback_arguments = item.callback_arguments
		})
	elseif item_type == "color_select" then
		value = HMH:GetColor(item.value)

		itm = self:CreateColorSelect({
			menu_id = menu_id,
			id = id,
			title = managers.localization:text(title),
			description = managers.localization:text(desc),
			value = value,
			default_value = default_value,
			enabled = enabled,
			parent = item.parent,
			callback = item.callback,
			callback_arguments = item.callback_arguments,
			texture = item.texture
		})
	end

	return itm
end

function HMHMenu:CreateOneLineItems(item, items, menu_id, ...)
	local offset = {
		["label"] = 5,
		["button"] = 10,
		["toggle"] = 34,
		["slider"] = 110,
		["multiple_choice"] = 215,
		["input"] = 34,
		["color_select"] = 64
	}
	local n = table.getn(item.table)
	local previous_item
	for _, v in pairs(item.table) do
		local itm = self:CreateItem(v, items, menu_id, ...)
		itm.panel:set_w(itm.panel:w() / n)
		if itm.panel:child("title") then
			itm.panel:child("title"):set_w(itm.panel:w() - (offset[itm.type] or 0))
			local w = select(3, itm.panel:child("title"):text_rect())
			if w > itm.panel:child("title"):w() then
				itm.panel:child("title"):set_font_size(itm.panel:child("title"):font_size() * (itm.panel:child("title"):w() / w))
			end
		end
		if previous_item then
			itm.panel:set_left(previous_item.panel:right())
			itm.panel:set_y(previous_item.panel:y())
			self:AddItemToMenu(menu_id, nil, -(itm.panel:h() + 1))
		end
		previous_item = itm
	end
end

function HMHMenu:CreateMenu(params)
	if self._options_panel:child("menu_"..tostring(params.menu_id)) or self._menus[params.menu_id] then
		return
	end

	local menu_panel = self._options_panel:panel({
		name = "menu_"..tostring(params.menu_id),
		x = self._options_panel:w(),
		w = self._options_panel:w(),
		h = self._options_panel:h(),
		layer = 1,
		visible = false
	})
	local title = menu_panel:text({
		name = "title",
		font_size = 45,
		font = tweak_data.menu.pd2_large_font,
		text = params.title,
		vertical = "center"
	})
	make_fine_text(title)
	if title:w() > menu_panel:w() - 5 then
		local menu_w = menu_panel:w() - 5
		title:set_font_size(title:font_size() * (menu_w/title:w()))
		title:set_w(title:w() * (menu_w/title:w()))
	end
	title:set_right(menu_panel:w() - 5)
	self._menus[params.menu_id] = {panel = menu_panel, parent_menu = params.parent_menu, items = {}, focus_changed_callback = params.focus_changed_callback}
	return self._menus[params.menu_id]
end

function HMHMenu:OpenMenu(menu, close)
	if not self._menus[menu] then
		return
	end
	local prev_menu = self._open_menu
	local next_menu = self._menus[menu]
	if prev_menu and prev_menu.focus_changed_callback then
		self[prev_menu.focus_changed_callback](self, false, prev_menu.id, menu) -- Ugly focus callback
	end
	if next_menu.focus_changed_callback then
		self[next_menu.focus_changed_callback](self, true, prev_menu.id, "") -- Ugly focus callback
	end
	self._tooltip:set_text("")
	if prev_menu then
		prev_menu.panel:stop()
	end
	next_menu.panel:stop()
	next_menu.panel:animate(function(o)
		local x = next_menu.panel:x()
		local prev_x
		if prev_menu then
			prev_x = prev_menu.panel:x()
		end
		next_menu.panel:set_visible(true)

		do_animation(0.1, function (p)
			next_menu.panel:set_x(math_lerp(x, 0, p))
			if prev_menu then
				prev_menu.panel:set_x(math_lerp(prev_x, close and prev_menu.panel:w() or -prev_menu.panel:w(), p))
			end
		end)

		next_menu.panel:set_x(0)
		local opened
		if prev_menu then
			prev_menu.panel:set_visible(false)
			prev_menu.panel:set_x(close and prev_menu.panel:w() or -prev_menu.panel:w())
			opened = self._open_menu.id
		end
		self._open_menu = next_menu
		self._open_menu.id = menu

		if close and opened ~= nil then
			for _, item in pairs(self._open_menu.items) do
				if item.panel and item.panel:child("bg") and item.id == opened then
					self:HighlightItem(item)
				end
			end
		else
			for _, item in pairs(self._open_menu.items) do
				if item.panel and item.enabled and item.panel:child("bg") then
					self:HighlightItem(item)
					return
				end
			end
		end
	end)
end

function HMHMenu:AddItemToMenu(menu_id, item, total_size)
	table.insert(self._menus[menu_id].items, item)
	if total_size then
		self._menus[menu_id].len = (self._menus[menu_id].len or 50) + total_size
	else
		self._menus[menu_id].len = (self._menus[menu_id].len or 50) + (item.panel and item.panel:h() or (item.size or 25)) + 1
	end
end

function HMHMenu:GetLastPosInMenu(menu_id)
	return self._menus[menu_id].len or 50
end

--Label Items
function HMHMenu:CreateLabel(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local label_name = params.id or tostring(#self._menus[params.menu_id].items)
	local label_panel = menu_panel:panel({
		name = "label_"..label_name,
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	local title = label_panel:text({
		name = "title",
		font_size = 23,
		font = tweak_data.menu.pd2_large_font,
		text = utf8.to_upper(params.title) or "",
		color = Color(0.7,0.7,0.7),
		w = label_panel:w(),
		align = params.center and "center" or "right",
		vertical = "center",
		layer = 1
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w()/w))
	end
	local label = {
		panel = label_panel,
		id = "label_"..label_name,
		enabled = params.enabled,
		parent = params.parent,
		type = "label",
		num = #self._menus[params.menu_id].items
	}
	self:AddItemToMenu(params.menu_id, label)
	return label
end

--Divider Items
function HMHMenu:CreateDivider(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end

	local div = {
		id = "divider_"..tostring(#self._menus[params.menu_id].items),
		type = "divider",
		num = #self._menus[params.menu_id].items,
		size = params.size
	}
	self:AddItemToMenu(params.menu_id, div)
	return div
end

--Button Items
function HMHMenu:CreateButton(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local button_panel = menu_panel:panel({
		name = "button_"..tostring(params.id),
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	local button_bg = button_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	local title = button_panel:text({
		name = "title",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.title or "",
		x = 5,
		w = button_panel:w() - 10,
		align = "right",
		vertical = "center",
		layer = 1
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w()/w))
	end
	local button = {
		panel = button_panel,
		id = params.id,
		type = "button",
		enabled = params.enabled,
		parent = params.parent,
		desc = params.description,
		next_menu = params.next_menu,
		callback = params.next_menu and nil or params.callback,
		callback_arguments = params.callback_arguments,
		num = #self._menus[params.menu_id].items
	}
	self:AddItemToMenu(params.menu_id, button)
	return button
end

--Toggle Items
function HMHMenu:CreateToggle(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local toggle_panel = menu_panel:panel({
		name = "toggle_"..tostring(params.id),
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	local toggle_bg = toggle_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	local title = toggle_panel:text({
		name = "title",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.title or "",
		x = 29,
		w = toggle_panel:w() - 34,
		align = "right",
		vertical = "center",
		layer = 1
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w()/w))
	end
	local check_bg = toggle_panel:bitmap({
		name = "check_bg",
		texture = "pd2_mod_hmh/check_bg",
		x = 2,
		y = 2,
		w = 22,
		h = 21,
		layer = 1
	})
	local check = toggle_panel:bitmap({
		name = "check",
		texture = "pd2_mod_hmh/check",
		x = 2,
		y = 2,
		w = params.value and 22 or 44,
		h = params.value and 21 or 42,
		alpha = params.value and 1 or 0,
		layer = 2
	})
	check:set_center(check_bg:center())
	local toggle = {
		panel = toggle_panel,
		type = "toggle",
		id = params.id,
		enabled = params.enabled,
		value = params.value,
		default_value = params.default_value,
		parent = params.parent,
		is_parent = params.is_parent,
		desc = params.description,
		num = #self._menus[params.menu_id].items,
		callback = params.callback,
		callback_arguments = params.callback_arguments,
		focus_changed_callback = params.focus_changed_callback
	}
	self:AddItemToMenu(params.menu_id, toggle)
	return toggle
end

--Slider Items
function HMHMenu:CreateSlider(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local percentage = (params.value - params.min) / (params.max - params.min)
	local slider_panel = menu_panel:panel({
		name = "slider_"..tostring(params.id),
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	slider_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	local value_bar = slider_panel:bitmap({
		name = "value_bar",
		alpha = 0.2,
		w = math_max(1, slider_panel:w() * percentage)
	})
	local t
	if params.value then
		if params.percentage then
			t = (params.value * 100) .. "%"
		else
			t = string.format("%." .. (params.step or 0) .. "f", params.value)
		end
	else
		t = ""
	end
	if params.suffix then
		t = t + params.suffix
	end
	local value_text = slider_panel:text({
		name = "value_text",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = t,
		x = 5,
		w = 100,
		align = "left",
		vertical = "center",
		layer = 2
	})
	local title = slider_panel:text({
		name = "title",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.title or "",
		x = 105,
		w = slider_panel:w() - 110,
		align = "right",
		vertical = "center",
		layer = 2
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w()/w))
	end
	local slider = {
		panel = slider_panel,
		id = params.id,
		type = "slider",
		enabled = params.enabled,
		value = params.value,
		default_value = params.default_value,
		percentage = params.percentage,
		callback = params.callback,
		callback_arguments = params.callback_arguments,
		max = params.max,
		min = params.min,
		step = params.step,
		parent = params.parent,
		desc = params.description,
		suffix = params.suffix,
		num = #self._menus[params.menu_id].items,
		focus_changed_callback = params.focus_changed_callback
	}
	self:AddItemToMenu(params.menu_id, slider)
	return slider
end

function HMHMenu:SetSlider(item, x, add)
	local panel_min, panel_max = item.panel:world_x(), item.panel:world_x() + item.panel:w()
	x = math_clamp(x, panel_min, panel_max)
	local value_bar = item.panel:child("value_bar")
	local value_text = item.panel:child("value_text")
	local percentage
	if add then
		local step = 1 / (10^item.step)
		local new_value = math_clamp(item.value + (add * step), item.min, item.max)
		percentage = (new_value - item.min) / (item.max - item.min)
	else
		percentage = (x - panel_min) / (panel_max - panel_min)
	end

	if percentage then
		local value = string.format("%." .. (item.step or 0) .. "f", item.min + (item.max - item.min) * percentage)
		value_bar:set_w(math_max(1,item.panel:w() * percentage))
		value_text:set_text(item.percentage and math_floor(value * 100).."%" or value ..(item.suffix and item.suffix or ""))
		item.value = value
	end
end

function HMHMenu:SetInput(item)
	if self._input then
		self:CloseInput()
	end
	self._input = item
	--hmh:Log("Input")
	self._input.gui_panel = self._input.panel:panel({
		alpha = 0.9,
		w = self._input.panel:w()
	})
	self._input.limit = 30
	self._input.caret = self._input.panel:child("caret")
	self._input.caret:animate(function(o)
		while true do
			o:set_visible(true)
			wait(0.5)
			o:set_visible(false)
			wait(0.5)
		end
	end)
	self._input.caret:set_x(-5 + select(3, item.panel:child("value"):text_rect()))

	self._input.gui_panel:key_press(callback(self, self, "key_press", self._input))
	self._input.gui_panel:enter_text(callback(self, self, "enter_text", self._input))
	self._input.gui_panel:key_release(callback(self, self, "key_release", self._input))

	self._input.panel:child("left_top"):set_color(Color.red)
	self._input.panel:child("left_bottom"):set_color(Color.red)
	self._input.panel:child("right_top"):set_color(Color.red)
	self._input.panel:child("right_bottom"):set_color(Color.red)

	if managers.menu:is_pc_controller() then
		managers.mouse_pointer:_deactivate()
	end

	--self._esc_released_callback = callback(self, self, "esc_key_callback", row_item)
	--self._enter_callback = callback(self, self, "enter_key_callback", row_item)

	--[[caret:animate(function(o)
		while true do
			o:set_color(Color(0.05, 1, 1, 1))
			wait(0.4)
			o:set_color(Color(0.9, 1, 1, 1))
			wait(0.4)
		end
	end)]]
end

function HMHMenu:key_press(item, o, k)
	if k == Idstring("backspace") then
		local text = item.value
		local n = utf8.len(text)
		if n > 0 then
			local s = ""
			if n ~= 1 then
				s = utf8.sub(text, 1, n - 1)
			end
			item.panel:child("value"):set_text(s)
			item.value = s
			item.caret:set_x(-5 + select(3, item.panel:child("value"):text_rect()))
		end
	end
end

function HMHMenu:enter_text(item, o, s)
	local text = item.value
	local m = item.limit
	local n = utf8.len(text)
	s = utf8.sub(s, 1, m - n)

	item.panel:child("value"):set_text(text .. s)
	item.value = text .. s
	item.caret:set_x(-5 + select(3, item.panel:child("value"):text_rect()))
end

function HMHMenu:key_release(item, o, k)
	if HMH:IsOr(k, Idstring("esc"), Idstring("enter")) then
		self:CloseInput()
	end
end

function HMHMenu:CloseInput()
	if self._input then
		self:CallCallback(self._input)

		self._input.panel:child("left_top"):set_color(Color.white)
		self._input.panel:child("left_bottom"):set_color(Color.white)
		self._input.panel:child("right_top"):set_color(Color.white)
		self._input.panel:child("right_bottom"):set_color(Color.white)

		self._input.gui_panel:key_press(nil)
		self._input.gui_panel:enter_text(nil)
		self._input.gui_panel:key_release(nil)
		self._input.gui_panel = nil
		self._input.caret:stop()
		self._input.caret:set_visible(false)
		self._input.caret = nil
		self._input = nil

		if managers.menu:is_pc_controller() then
			managers.mouse_pointer:_activate()
		end
	end
end

--Multiple Choice Items
function HMHMenu:CreateMultipleChoice(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local multiple_panel = menu_panel:panel({
		name = "multiple_choice_"..tostring(params.id),
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	local multiple_bg = multiple_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	local title = multiple_panel:text({
		name = "title",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.title or "",
		x = 210,
		w = multiple_panel:w() - 215,
		align = "right",
		vertical = "center",
		layer = 1
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w()/w))
	end
	local title_selected = multiple_panel:text({
		name = "title_selected",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.items[params.value],
		x = 5,
		w = 200,
		align = "left",
		vertical = "center",
		layer = 1
	})
	local multiple_choice = {
		panel = multiple_panel,
		id = params.id,
		type = "multiple_choice",
		enabled = params.enabled,
		items = params.items,
		value = params.value,
		default_value = params.default_value,
		parent = params.parent,
		desc = params.description,
		num = #self._menus[params.menu_id].items,
		callback = params.callback,
		callback_arguments = params.callback_arguments,
		focus_changed_callback = params.focus_changed_callback
	}
	self:AddItemToMenu(params.menu_id, multiple_choice)
	return multiple_choice
end

function HMHMenu:OpenMultipleChoicePanel(item)
	local choice_dialog = item.panel:parent():panel({
		name = "choice_panel_"..tostring(item.id),
		x = item.panel:x(),
		y = item.panel:bottom(),
		w = item.panel:w(),
		h = 4 + (#item.items * 25),
		alpha = 0,
		layer = 20,
		rotation = 360,
	})
	if choice_dialog:bottom() > self._options_panel:h() then
		choice_dialog:set_bottom(item.panel:top())
	end
	local border = choice_dialog:bitmap({
		name = "border",
		alpha = 0.3,
		layer = 1,
		h = 0,
		rotation = 360,
	})
	choice_dialog:bitmap({
		name = "blur_bg",
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		y = 3,
		w = choice_dialog:w(),
		h = choice_dialog:h(),
		layer = 0,
		rotation = 360
	})
	local bg = choice_dialog:bitmap({
		name = "bg",
		alpha = 0.7,
		color = Color.black,
		layer = 2,
		x = 2,
		y = 2,
		w = choice_dialog:w() - 4,
		h = choice_dialog:h() - 4,
		rotation = 360
	})
	self._open_choice_dialog = { parent_item = item, panel = choice_dialog, selected = item.value, items = {} }
	for i, choice in pairs(item.items) do
		local title = choice_dialog:text({
			name = "title",
			font_size = 18,
			font = tweak_data.menu.pd2_small_font,
			text = item.items[i] or "",
			x = 10,
			y = 2 + (i-1) * 25,
			w = choice_dialog:w() - 10,
			h = 25,
			color = item.value == i and Color.white or Color(0.6,0.6,0.6),
			vertical = "center",
			layer = 3,
			rotation = 360
		})
		local w = select(3, title:text_rect())
		if w > title:w() then
			title:set_font_size(title:font_size() * (title:w()/w))
		end
		table.insert(self._open_choice_dialog.items, title)
	end
	choice_dialog:animate(function(o)
		local h = o:h()
		do_animation(0.1, function (p)
			o:set_alpha(math_lerp(0, 1, p))
			border:set_h(math_lerp(0, h, p))
			bg:set_h(border:h() - 4)
		end)
		o:set_alpha(1)
		border:set_h(h)
		bg:set_h(border:h() - 4)
	end)
	self:SetLegends(true, false, false)
end

function HMHMenu:CloseMultipleChoicePanel()
	self:SetItem(self._open_choice_dialog.parent_item, self._open_choice_dialog.parent_item.value)
	self._open_choice_dialog.panel:stop()
	self._open_choice_dialog.panel:animate(function(o)
		local h = o:h()
		local alpha = o:alpha()
		local border = o:child("border")
		local bg = o:child("bg")
		do_animation(0.1, function (p)
			o:set_alpha(math_lerp(alpha, 0, p))
			border:set_h(math_lerp(h, 0, p))
			bg:set_h(border:h() - 4)
		end)
		o:set_alpha(0)
		border:set_h(h)
		bg:set_h(border:h() - 4)
		self._open_choice_dialog.parent_item.panel:parent():remove(self._open_choice_dialog.panel)
		self._open_choice_dialog = nil
	end)
	self:SetLegends(true, true, false)
end

function HMHMenu:CreateInput(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local input_panel = menu_panel:panel({
		name = "input_" .. tostring(params.id),
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	input_panel:bitmap({
		name = "bg",
		alpha = 0
	})
	local title = input_panel:text({
		name = "title",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.title or "",
		x = 29,
		w = input_panel:w() - 34,
		align = "right",
		vertical = "center",
		layer = 1
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w() / w))
	end

	local value = input_panel:text({
		name = "value",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.value or "",
		x = input_panel:left() + 5,
		w = input_panel:w(),
		align = "left",
		vertical = "center",
		layer = 1
	})
	local w = select(3, value:text_rect())
	if w > value:w() then
		value:set_font_size(value:font_size() * (value:w() / w))
	end

	input_panel:bitmap({
		texture = "pd2_mod_hmh/hud_corner",
		name = "left_top",
		visible = true,
		layer = 0,
		y = 0,
		halign = "left",
		x = 0,
		valign = "top",
		color = Color.white,
		blend_mode = "add"
	})

	local left_bottom = input_panel:bitmap({
		texture = "pd2_mod_hmh/hud_corner",
		name = "left_bottom",
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		halign = "left",
		rotation = -90,
		valign = "bottom",
		color = Color.white,
		blend_mode = "add"
	})

	left_bottom:set_bottom(input_panel:h())

	local right_top = input_panel:bitmap({
		texture = "pd2_mod_hmh/hud_corner",
		name = "right_top",
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 90,
		valign = "top",
		color = Color.white,
		blend_mode = "add"
	})

	right_top:set_right(input_panel:w())

	local right_bottom = input_panel:bitmap({
		texture = "pd2_mod_hmh/hud_corner",
		name = "right_bottom",
		visible = true,
		layer = 0,
		x = 0,
		y = 0,
		halign = "right",
		rotation = 180,
		valign = "bottom",
		color = Color.white,
		blend_mode = "add"
	})

	right_bottom:set_right(input_panel:w())
	right_bottom:set_bottom(input_panel:h())

	local caret = input_panel:bitmap({
		name = "caret",
		visible = false,
		layer = 3,
		x = 0,
		y = 12,
		w = input_panel:h() - 6,
		h = 2,
		rotation = 90,
		color = Color.white,
		blend_mode = "add",
		halign = "left"
	})

	local input = {
		panel = input_panel,
		type = "input",
		id = params.id,
		enabled = params.enabled,
		value = params.value or "",
		default_value = params.default_value,
		parent = params.parent,
		desc = params.description,
		callback = params.callback,
		callback_arguments = params.callback_arguments,
		num = #self._menus[params.menu_id].items
	}

	self:AddItemToMenu(params.menu_id, input)

	return input
end

-- Custom Color Items
function HMHMenu:CreateColorSelect(params)
	local menu_panel = self._options_panel:child("menu_"..tostring(params.menu_id))
	if not menu_panel or not self._menus[params.menu_id] then
		return
	end
	local texture = params.texture or nil
	local texture_extension = "_hmh"
	if texture and type(texture) == "table" then
		texture = texture[math_random(#texture)] -- Randomize texture
	end
	if texture and texture == "padlock" then
		texture_extension = ""
	end
	local move = texture and 16 or 0
	local color_panel = menu_panel:panel({
		name = "color_select_"..tostring(params.id),
		y = self:GetLastPosInMenu(params.menu_id),
		h = 25 + move,
		layer = 2,
		alpha = params.enabled and 1 or 0.5
	})
	color_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	local title = color_panel:text({
		name = "title",
		font_size = 20,
		font = tweak_data.menu.pd2_medium_font,
		text = params.title or "",
		x = 59,
		w = color_panel:w() - 64,
		align = "right",
		vertical = "center",
		layer = 1
	})
	local w = select(3, title:text_rect())
	if w > title:w() then
		title:set_font_size(title:font_size() * (title:w()/w))
	end
	color_panel:bitmap({
		name = "color_border",
		x = 3,
		y = 3,
		w = 51 - move,
		h = 19 + move,
		layer = 1
	})
	color_panel:bitmap({
		name = "color",
		x = 4,
		y = 4,
		w = 49 - move,
		h = 17 + move,
		texture = texture and ("guis/textures/pd2/hud_icon_" .. texture .. "box" .. texture_extension) or nil,
		color = params.value,
		layer = 2
	})
	local color = {
		panel = color_panel,
		id = params.id,
		type = "color_select",
		enabled = params.enabled,
		value = params.value,
		default_value = params.default_value,
		parent = params.parent,
		desc = params.description,
		num = #self._menus[params.menu_id].items,
		callback = params.callback,
		callback_arguments = params.callback_arguments
	}

	self:AddItemToMenu(params.menu_id, color)

	return color
end

function HMHMenu:OpenColorMenu(item)
	local dialog = item.panel:parent():panel({
		name = "color_panel_"..tostring(item.id),
		x = item.panel:x(),
		y = item.panel:bottom(),
		w = item.panel:w(),
		h = 141,
		layer = 20,
		alpha = 0
	})
	if dialog:bottom() > item.panel:parent():h() then
		dialog:set_bottom(item.panel:top())
	end
	local border = dialog:bitmap({
		name = "border",
		alpha = 0.3,
		layer = 1,
		h = 0
	})
	dialog:bitmap({
		name = "blur_bg",
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		y = 3,
		w = dialog:w(),
		h = dialog:h(),
		layer = 0,
	})
	local bg = dialog:bitmap({
		name = "bg",
		alpha = 0.7,
		color = Color.black,
		layer = 2,
		x = 2,
		y = 2,
		w = dialog:w() - 4,
		h = 0,
	})
	local color = item.value
	local red_panel = dialog:panel({
		name = "red_panel",
		x = 5,
		y = 5,
		w = dialog:w() - 10,
		h = 25,
		layer = 3
	})
	local red_slider = red_panel:bitmap({
		name = "slider",
		alpha = 0.3,
		layer = 2,
		w = math_max(1, red_panel:w() * (color.red / 1)),
		color = Color(color.red,0,0)
	})
	red_panel:bitmap({
		name = "bg",
		alpha = 0.1,
	})
	red_panel:text({
		name = "title",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = managers.localization:text("hmh_r"),
		x = 85,
		w = red_panel:w() - 90,
		h = 25,
		align = "right",
		vertical = "center",
		layer = 3
	})
	red_panel:text({
		name = "value",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = string.format("%.0f", color.red * 255),
		x = 5,
		w = 80,
		h = 25,
		vertical = "center",
		layer = 3
	})
	local green_panel = dialog:panel({
		name = "green_panel",
		x = 5,
		y = 32,
		w = dialog:w() - 10,
		h = 25,
		layer = 3
	})
	local green_slider = green_panel:bitmap({
		name = "slider",
		alpha = 0.3,
		layer = 2,
		w =  math_max(1, green_panel:w() * (color.green / 1)),
		color = Color(0,color.green,0)
	})
	green_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	green_panel:text({
		name = "title",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = managers.localization:text("hmh_g"),
		x = 85,
		w = red_panel:w() - 90,
		h = 25,
		align = "right",
		vertical = "center",
		layer = 3
	})
	green_panel:text({
		name = "value",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = string.format("%.0f", color.green * 255),
		x = 5,
		w = 80,
		h = 25,
		vertical = "center",
		layer = 3
	})
	local blue_panel = dialog:panel({
		name = "blue_panel",
		x = 5,
		y = 59,
		w = dialog:w() - 10,
		h = 25,
		layer = 3
	})
	local blue_slider = blue_panel:bitmap({
		name = "slider",
		alpha = 0.3,
		layer = 2,
		w = math_max(1, blue_panel:w() * (color.blue / 1)),
		color = Color(0,0,color.blue)
	})
	blue_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	blue_panel:text({
		name = "title",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = managers.localization:text("hmh_b"),
		x = 85,
		w = red_panel:w() - 90,
		h = 25,
		align = "right",
		vertical = "center",
		layer = 3
	})
	blue_panel:text({
		name = "value",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = string.format("%.0f", color.blue * 255),
		x = 5,
		w = 80,
		h = 25,
		vertical = "center",
		layer = 3
	})
	local accept_panel = dialog:panel({
		name = "accept_panel",
		x = 5,
		y = 85,
		w = dialog:w() - 10,
		h = 25,
		layer = 3
	})
	accept_panel:bitmap({
		name = "bg",
		alpha = 0,
	})
	accept_panel:text({
		name = "title",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = managers.localization:text("hmh_ok"),
		x = 5,
		w = red_panel:w() - 10,
		h = 25,
		align = "right",
		vertical = "center",
		layer = 3,
	})
	local reset_panel = dialog:panel({
		name = "reset_panel",
		x = 5,
		y = 112,
		w = dialog:w() - 10,
		h = 25,
		layer = 3
	})
	reset_panel:bitmap({
		name = "bg",
		alpha = 0
	})
	reset_panel:text({
		name = "title",
		font_size = 18,
		font = tweak_data.menu.pd2_small_font,
		text = managers.localization:text("hmh_color_reset"),
		x = 5,
		w = red_panel:w() - 10,
		h = 25,
		align = "right",
		vertical = "center",
		layer = 3
	})

	self._open_color_dialog = {
		parent_item = item,
		panel = dialog,
		color = item.value,
		selected = 1,
		items = {
			red_panel,
			green_panel,
			blue_panel,
			accept_panel,
			reset_panel
		}
	}

	dialog:animate(function(o)
		local h = o:h()
		do_animation(0.1, function (p)
			o:set_alpha(math_lerp(0, 1, p))
			border:set_h(math_lerp(0, h, p))
			bg:set_h(border:h() - 4)
		end)
		o:set_alpha(1)
		border:set_h(h)
		bg:set_h(border:h() - 4)
	end)
end

function HMHMenu:SetColorSlider(item, x, type, add)
	local panel_min, panel_max = item:world_x(), item:world_x() + item:w()
	x = math_clamp(x, panel_min, panel_max)
	local value_bar = item:child("slider")
	local value_text = item:child("value")
	local percentage = (math_clamp(value_text:text() + (add or 0), 0, 255) - 0) / 255
	if not add then
		percentage = (x - panel_min) / (panel_max - panel_min)
	end
	local value = string.format("%.0f", 0 + (255 - 0) * percentage)
	value_bar:set_w(math_max(1, item:w() * percentage))
	value_bar:set_color(Color(255, type == 1 and value or 0, type == 2 and value or 0, type == 3 and value or 0) / 255)
	value_text:set_text(value)
	local color = self._open_color_dialog.color
	self._open_color_dialog.color = Color(type == 1 and value / 255 or color.red, type == 2 and value / 255 or color.green, type == 3 and value / 255 or color.blue)
	self._open_color_dialog.parent_item.panel:child("color"):set_color(self._open_color_dialog.color)
end

function HMHMenu:CloseColorMenu()
	self._open_color_dialog.panel:stop()
	self._open_color_dialog.panel:animate(function(o)
		local h = o:h()
		local alpha = o:alpha()
		local border = o:child("border")
		local bg = o:child("bg")
		do_animation(0.1, function(p)
			o:set_alpha(math_lerp(alpha, 0, p))
			border:set_h(math_lerp(h, 0, p))
			bg:set_h(border:h() - 4)
		end)
		o:set_alpha(0)
		border:set_h(h)
		bg:set_h(border:h() - 4)
		self:CallCallback(self._open_color_dialog.parent_item, { color = true, color_panels = self._open_color_dialog.items })
		self._open_color_dialog.parent_item.panel:parent():remove(self._open_color_dialog.panel)
		local c = self._open_color_dialog.color
		self._open_color_dialog.parent_item.value = c
		self._open_color_dialog.parent_item.panel:child("color"):set_color(c)
		self._open_color_dialog = nil
		self:CreateChangeWarning()
	end)
end

function HMHMenu:ResetColorMenu()
	local item = self._open_color_dialog
	local c = item.parent_item.default_value
	local colors_to_table = { ["red"] = 1, ["green"] = 2, ["blue"] = 3 }
	local color_panel
	for _, v in pairs(item.items) do
		color_panel = v:name():gsub("_panel", "")
		local number = colors_to_table[color_panel]
		if number then
			local world_x = v:world_x()
			self:SetColorSlider(v, math_lerp(world_x, world_x + v:w(), c[number] / 255), number)
		end
	end
end

function HMHMenu:SetOption(value, option)
	HMH._data[option] = value
end

function HMHMenu:SetColorOption(color, option)
	local c = HMH._data[option]
	c.r = color.red
	c.g = color.green
	c.b = color.blue
end

function HMHMenu:RefreshTextures()
	managers.viewport._render_settings_change_map = {resolution = RenderSettings.resolution}
end