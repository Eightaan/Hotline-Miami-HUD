core:import("CoreMenuItem")
core:import("CoreMenuItemOption")

HMHMenuItemColor = class(CoreMenuItem.Item)
function HMHMenuItemColor:init(data_node, parameters)
    CoreMenuItem.Item.init(self, data_node, parameters)
    self._type = "HMHColor"
    self._options = {}
    if data_node then
        for _, c in ipairs(data_node) do
            local type = c._meta
            if type == "option" then
                local option = CoreMenuItemOption.ItemOption:new(c)
                table.insert(self._options, option)
            end
        end
    end
    self._enabled = true
end

function HMHMenuItemColor:setup_gui(node, row_item)
    local right_align = node:_right_align()
    row_item.gui_panel = node.item_panel:panel({
        w = node.item_panel:w()
    })
    row_item.gui_text = node:_text_item_part(row_item, row_item.gui_panel, right_align, row_item.align)
    row_item.gui_text:set_layer(tweak_data.gui.MENU_COMPONENT_LAYER + 6)

    row_item.gui_text:set_wrap(true)
    row_item.gui_text:set_word_wrap(true)

    row_item.gui_color_border = row_item.gui_panel:rect({
        w = 48,
        color = Color.white,
        layer = tweak_data.gui.MENU_COMPONENT_LAYER + 4
    })
    row_item.gui_color = row_item.gui_panel:rect({
        color = Color.red,
        layer = tweak_data.gui.MENU_COMPONENT_LAYER + 5
    })

    self:_layout(node, row_item)

    return true
end

function HMHMenuItemColor:_layout(node, row_item)
    local safe_rect = managers.gui_data:scaled_size()

    row_item.gui_panel:set_width(safe_rect.width - node:_mid_align())
    row_item.gui_panel:set_x(node:_mid_align())

    local x, y, w, h = row_item.gui_text:text_rect()

    row_item.gui_text:set_h(h)
    row_item.gui_text:set_width(w + 5)

    row_item.gui_color_border:set_x(5)
    row_item.gui_color_border:set_h(h)
    local color_x, color_y, color_w, color_h = row_item.gui_color_border:shape()
    row_item.gui_color:set_shape(color_x + 1, color_y + 1, color_w - 2, color_h - 2)

    if row_item.align == "right" then
        row_item.gui_text:set_right(row_item.gui_panel:w())
    else
        row_item.gui_text:set_left(node:_right_align() - row_item.gui_panel:x() + (self:parameters().expand_value or 0))
    end

    row_item.gui_text:set_height(h)
    row_item.gui_panel:set_height(h)

    return true
end

function HMHMenuItemColor:reload(row_item, node)
    if not row_item then
        return
    end
    row_item.gui_text:set_color(row_item.color)
    local new_color = Color()
    for _, option in ipairs(self._options) do
        local o_params = option:parameters()
        new_color[o_params.name] = o_params.value / 255
    end
    row_item.gui_color:set_color(new_color:with_alpha(self._enabled and 1 or 0.75))
    return true
end

function HMHMenuItemColor:highlight_row_item(node, row_item, mouse_over)
    row_item.gui_text:set_color(row_item.color)
    return true
end

function HMHMenuItemColor:fade_row_item(node, row_item, mouse_over)
    row_item.gui_text:set_color(row_item.color)
    return true
end

---@param value { r: integer, g: integer, b: integer }
function HMHMenuItemColor:set_value(value)
    for _, option in ipairs(self._options) do
        local o_params = option:parameters()
        o_params.value = value[o_params.name]
    end
    self:dirty()
end

function HMHMenuItemColor:value()
    local color = {}
    for _, option in ipairs(self._options) do
        local o_params = option:parameters()
        color[o_params.name] = o_params.value
    end
    return color
end

HMHMenuSetColorInitiator = class(MenuCrimeNetSpecialInitiator)
function HMHMenuSetColorInitiator:modify_node(original_node, data)
    return self:setup_node(original_node, data)
end

function HMHMenuSetColorInitiator:setup_node(node, data)
    node:clean_items()
    data = data or node:parameters().menu_component_data
    if not node:item("divider") then
        self:create_slider(node, {
            name = "red",
            text_id = "hmh_color_red"
        })
        self:create_slider(node, {
            name = "green",
            text_id = "hmh_color_green"
        })
        self:create_slider(node, {
            name = "blue",
            text_id = "hmh_color_blue"
        })
        self:create_divider(node, "divider", nil, 64)
    end
    local params = {
        callback = "hmh_set_item_color",
        name = "confirm",
        text_id = "dialog_apply",
        align = "right"
    }
    node:add_item(node:create_item({}, params))

    local params = {
        callback = "hmh_reset_color_params",
        name = "reset",
        text_id = "hmh_color_reset",
        align = "right"
    }
    node:add_item(node:create_item({}, params))

    local params = {
        last_item = "true",
        name = "back",
        text_id = "dialog_cancel",
        align = "right",
        previous_node = "true"
    }
    node:add_item(node:create_item({}, params))

    node:set_default_item_name("red")
    node:select_item("red")

    node:parameters().menu_component_data = data
    local r = node:item("red")
    local g = node:item("green")
    local b = node:item("blue")

    local color = data.item and data.item:value()
    if color and r and g and b then
        r:set_value(color.r)
        g:set_value(color.g)
        b:set_value(color.b)
    end

    return node
end

function HMHMenuSetColorInitiator:refresh_node(node, data)
    return node
end

function HMHMenuSetColorInitiator:create_slider(node, params)
    params.callback = "hmh_update_color"
    params.show_value = true
    local data_node = {
        type = "CoreMenuItemSlider.ItemSlider",
        show_value = true,
        min = 0,
        max = 255,
        step = 1,
        decimal_count = 0
    }
    local new_item = node:create_item(data_node, params)
    node:add_item(new_item)
end

function MenuCallbackHandler:hmh_update_color()
    local menu = managers.menu:active_menu()
    if not menu then
        return false
    end
    if not menu.logic then
        return false
    end
    if not menu.logic:selected_node() then
        return false
    end
    local active_node_gui = menu.renderer:active_node_gui()
    if active_node_gui and active_node_gui.update_node_colors then
        active_node_gui:update_node_colors()
    end
end

function MenuCallbackHandler:hmh_reset_color_params()
    local menu = managers.menu:active_menu()
    if not menu then
        return false
    end
    if not menu.logic then
        return false
    end
    if not menu.logic:selected_node() then
        return false
    end
    local active_node_gui = menu.renderer:active_node_gui()
    local node = active_node_gui.node
    active_node_gui:setup(node, node:parameters().menu_component_data.item:parameters().default_color)
end

HMHMenuNodeCustomizeGadgetGui = HMHMenuNodeCustomizeGadgetGui or class(MenuNodeGui)
HMHMenuNodeCustomizeGadgetGui._rec_round_object = MenuNodeCustomizeGadgetGui._rec_round_object
local padding = 10

function HMHMenuNodeCustomizeGadgetGui:init(node, layer, parameters)
    parameters.font = tweak_data.menu.pd2_small_font
    parameters.font_size = tweak_data.menu.pd2_small_font_size
    parameters.align = "left"
    parameters.row_item_blend_mode = "add"
    parameters.row_item_color = tweak_data.screen_colors.button_stage_3
    parameters.row_item_hightlight_color = tweak_data.screen_colors.button_stage_2
    parameters.marker_alpha = 1
    parameters.to_upper = true
    HMHMenuNodeCustomizeGadgetGui.super.init(self, node, layer, parameters)

    self:setup(node)
end

function HMHMenuNodeCustomizeGadgetGui:setup(node, default_color)
    local r = node:item("red")
    local g = node:item("green")
    local b = node:item("blue")
    local data = node:parameters().menu_component_data
    local color = default_color or data.item and data.item:value()
    if color and r and g and b then
        r:set_value(color.r)
        g:set_value(color.g)
        b:set_value(color.b)
    end
    self:update_node_colors()
end

function HMHMenuNodeCustomizeGadgetGui:make_fine_text(text)
    local x, y, w, h = text:text_rect()
    text:set_size(w, h)
    text:set_position(math.round(x), math.round(y))
    return x, y, w, h
end

function HMHMenuNodeCustomizeGadgetGui:_setup_item_panel(safe_rect, res)
    HMHMenuNodeCustomizeGadgetGui.super._setup_item_panel(self, safe_rect, res)
    self.item_panel:set_w(safe_rect.width * (1 - self._align_line_proportions))
    self.item_panel:set_center(self.item_panel:parent():w() / 2, self.item_panel:parent():h() / 2)

    local static_y = self.static_y and safe_rect.height * self.static_y

    if static_y and static_y < self.item_panel:y() then
        self.item_panel:set_y(static_y)
    end

    self.item_panel:set_position(math.round(self.item_panel:x()), math.round(self.item_panel:y()))
    self:_rec_round_object(self.item_panel)

    if alive(self.box_panel) then
        self.item_panel:parent():remove(self.box_panel)
        self.box_panel = nil
    end

    self.box_panel = self.item_panel:parent():panel()

    self.box_panel:set_x(self.item_panel:x())
    self.box_panel:set_w(self.item_panel:w())

    if self._align_data.panel:h() < self.item_panel:h() then
        self.box_panel:set_y(0)
        self.box_panel:set_h(self.item_panel:parent():h())
    else
        self.box_panel:set_y(self.item_panel:top())
        self.box_panel:set_h(self.item_panel:h())
    end

    self.box_panel:grow(20, 20)
    self.box_panel:move(-10, -10)
	--Added a basic fix for the layering issue
	self.box_panel:set_layer(1000)
	self.item_panel:set_layer(1001)

    local next_panel_h = padding + 2 + (tweak_data.menu.pd2_small_font_size + 1) * 3

    self._preview_panel = self.box_panel:panel({
        h = 32,
        layer = 10,
        x = padding,
        y = next_panel_h,
        w = self.box_panel:w() - padding * 2
    })

    self:_rec_round_object(self._preview_panel)

    self._preview_color = self._preview_panel:rect({
        color = Color.blue
    })
    next_panel_h = padding + 2 + (tweak_data.menu.pd2_small_font_size + 1) * 6 + 64

    self:update_node_colors()

    self.boxgui = BoxGuiObject:new(self.box_panel, {
        sides = {
            1,
            1,
            1,
            1
        }
    })

    self.boxgui:set_clipping(false)
    self.boxgui:set_layer(1000)
    self.box_panel:rect({
        rotation = 360,
        color = tweak_data.screen_colors.dark_bg
    })
    self._align_data.panel:set_left(self.box_panel:left())
    self._list_arrows.up:set_world_left(self._align_data.panel:world_left())
    self._list_arrows.up:set_world_top(self._align_data.panel:world_top() - 10)
    self._list_arrows.up:set_width(self.box_panel:width())
    self._list_arrows.up:set_rotation(360)
    self._list_arrows.up:set_layer(1050)
    self._list_arrows.down:set_world_left(self._align_data.panel:world_left())
    self._list_arrows.down:set_world_bottom(self._align_data.panel:world_bottom() + 10)
    self._list_arrows.down:set_width(self.box_panel:width())
    self._list_arrows.down:set_rotation(360)
    self._list_arrows.down:set_layer(1050)
    self:_set_topic_position()
end

function HMHMenuNodeCustomizeGadgetGui:update_node_colors()
    local node =  self.node
    local colors = {}
    if alive(self._preview_color) then
        local r = node:item("red")
        local g = node:item("green")
        local b = node:item("blue")
        if r and g and b then
            colors.r = tonumber(r:raw_value_string())
            colors.g = tonumber(g:raw_value_string())
            colors.b = tonumber(b:raw_value_string())
            local col = Color(255, colors.r, colors.g, colors.b) / 255
            self._preview_color:set_color(col)
        end
    end
    return colors
end

function HMHMenuNodeCustomizeGadgetGui:_setup_item_panel_parent(safe_rect, shape)
    shape = shape or {}
    shape.x = shape.x or safe_rect.x
    shape.y = shape.y or safe_rect.y + 0
    shape.w = shape.w or safe_rect.width
    shape.h = shape.h or safe_rect.height - 0
    HMHMenuNodeCustomizeGadgetGui.super._setup_item_panel_parent(self, safe_rect, shape)
end

function HMHMenuNodeCustomizeGadgetGui:reload_item(item)
    HMHMenuNodeCustomizeGadgetGui.super.reload_item(self, item)
    local row_item = self:row_item(item)
    if row_item and alive(row_item.gui_panel) then
        row_item.gui_panel:set_halign("right")
        row_item.gui_panel:set_right(self.item_panel:w())
    end
end

function HMHMenuNodeCustomizeGadgetGui:_align_marker(row_item)
    HMHMenuNodeCustomizeGadgetGui.super._align_marker(self, row_item)
    if row_item.item:parameters().pd2_corner then
        self._marker_data.marker:set_world_right(row_item.gui_panel:world_right())
        return
    end
    self._marker_data.marker:set_world_right(self.item_panel:world_right())
end

function MenuCallbackHandler:hmh_modify_item_color(item)
    managers.menu:open_node("hmh_color_select", {
        {
            item = item
        }
    })
    managers.menu_component:post_event("menu_enter")
end

function MenuCallbackHandler:hmh_set_item_color()
    local menu = managers.menu:active_menu()
    if not menu or not menu.logic or not menu.logic:selected_node() then
        return
    end

    local active_node_gui = menu.renderer:active_node_gui()
    if not active_node_gui or not active_node_gui.update_node_colors then
        return
    end

    local color = active_node_gui:update_node_colors()
    local node = active_node_gui.node
    local data = node and node:parameters().menu_component_data
    local item = data and data.item

    if not item or not color then
        return
    end

    item:set_value(color)

    local params = item:parameters()
    local option = params.option or params.value_key or params.name

    if option then
        HMH._data[option] = {
            r = math.round(color.r),
            g = math.round(color.g),
            b = math.round(color.b)
        }
    end

    if params.hmh_callback then
        local callback_args = params.hmh_callback_arguments
        local fn = HMHMenu and HMHMenu[params.hmh_callback]

        if fn then
            local c = Color(255, color.r, color.g, color.b) / 255
            if type(callback_args) == "table" then
                fn(HMHMenu, c, unpack(callback_args))
            elseif callback_args ~= nil then
                fn(HMHMenu, c, callback_args)
            else
                fn(HMHMenu, c)
            end
        end
    end

    if HMH.Save then
        HMH:Save()
    end

    managers.menu:back()
end