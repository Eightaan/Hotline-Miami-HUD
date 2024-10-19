local HMH = HMH

if not HMH:GetOption("objective") then
	return
end

local objective_alpha = HMH:GetOption("objective_text")

Hooks:PostHook(HUDObjectives, "init", "HMH_HUDObjectives_init", function(self, hud, ...)
	self._hud_panel = hud.panel
	if self._hud_panel:child("objectives_panel") then
		self._hud_panel:remove(self._hud_panel:child("objectives_panel"))
	end
	local objectives_panel = self._hud_panel:panel({
		y = 0,
		name = "objectives_panel",
		h = 100,
		visible = false,
		w = 700,
		x = 0,
		valign = "top"
	})
	local icon_objectivebox = objectives_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_objectivebox",
		name = "icon_objectivebox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "normal",
		halign = "left",
		x = 0,
		valign = "top"
	})
	self._bg_box = HUDBGBox_create(objectives_panel, {
		w = 200,
		x = 26,
		h = 38,
		y = 0
	})
	local objective_text = objectives_panel:text({
		y = 8,
		name = "objective_text",
		vertical = "top",
		align = "left",
		text = "",
		visible = false,
		x = 0,
		layer = 2, 
		color = Color.white,
		font_size = tweak_data.hud.active_objective_title_font_size,
		font = tweak_data.hud.medium_font_noshadow
	})
	local amount_text = objectives_panel:text({
		y = 0,
		name = "amount_text",
		vertical = "top",
		align = "left",
		text = "1/4",
		visible = true,
		x = 6,
		layer = 2,
		color = Color.white,
		font_size = tweak_data.hud.active_objective_title_font_size,
		font = tweak_data.hud.medium_font_noshadow
	})
	icon_objectivebox:set_color(HMH:GetColor("ObjectiveIcon"))
	icon_objectivebox:set_alpha(objective_alpha)
	objective_text:set_x(34)
	objective_text:set_alpha(objective_alpha)
	objective_text:set_y(0)
	objective_text:set_font_size(24)
	objective_text:set_color(HMH:GetColor("ObjectiveText"))
	objective_text:set_visible(true)
	amount_text:set_color(HMH:GetColor("ObjectiveAmount"))
	amount_text:set_alpha(objective_alpha)
end)

Hooks:OverrideFunction(HUDObjectives, "activate_objective", function(self, data)
	self._active_objective_id = data.id
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local objective_text = objectives_panel:child("objective_text")
	local amount_text = objectives_panel:child("amount_text")
	local icon_objectivebox = objectives_panel:child("icon_objectivebox")
	
	if self._bg_box then
		for _, child in ipairs({"bg", "left_top", "left_bottom", "right_top", "right_bottom"}) do
			self._bg_box:child(child):hide()
		end
	end

	objective_text:set_text(utf8.to_upper(data.text))

	local _, _, w, _ = objective_text:text_rect()

	if data.amount then
		self:update_amount_objective(data)
	end

	objectives_panel:stop()
	objectives_panel:set_alpha(0)
	objectives_panel:set_visible(true)
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 1)

	amount_text:set_visible(data.amount)
	amount_text:set_x(objective_text:x() + 5 + w)
end)


Hooks:OverrideFunction(HUDObjectives, "update_amount_objective", function(self, data)
	if data.id ~= self._active_objective_id then
		return
	end
	local current = data.current_amount or 0
	local amount = data.amount
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:child("amount_text"):set_text(current .. "/" .. amount)
end)

Hooks:OverrideFunction(HUDObjectives, "complete_objective", function(self, data)
	if data.id ~= self._active_objective_id then
		return
	end
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:stop()
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 0)
end)

Hooks:OverrideFunction(HUDObjectives, "remind_objective", function(self, id)
	if id ~= self._active_objective_id then
		return
	end
end)