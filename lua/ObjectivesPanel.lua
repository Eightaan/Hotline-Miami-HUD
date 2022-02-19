if not HMH:GetOption("objective") then
    return
end

local init_orig = HUDObjectives.init
function HUDObjectives:init(...)
    init_orig(self, ...)
	if not self._bg_box then
	    return
	end
	self._bg_box:child("bg"):hide()
	self._bg_box:child("left_top"):hide()
	self._bg_box:child("left_bottom"):hide()
	self._bg_box:child("right_top"):hide()
	self._bg_box:child("right_bottom"):hide()
end
local activate_objective_orig = HUDObjectives.activate_objective
function HUDObjectives:activate_objective(data)
	self._active_objective_id = data.id
	if not self._hud_panel then
	   return activate_objective_orig(self, data) -- To prevent crashes with vanillahud plus
	end
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local objective_text = objectives_panel:child("objective_text")
	local amount_text = objectives_panel:child("amount_text")
	local icon_objectivebox = objectives_panel:child("icon_objectivebox")
	
	if not icon_objectivebox then return end -- To prevent crahses with voidui
	icon_objectivebox:set_color(HMH:GetColor("ObjectiveIcon"))
	icon_objectivebox:set_alpha(HMH:GetOption("objective_text"))
	objective_text:set_x(34)
	objective_text:set_alpha(HMH:GetOption("objective_text"))
	objective_text:set_y(0)
	objective_text:set_font_size(24)
	objective_text:set_color(HMH:GetColor("ObjectiveText"))
	objective_text:set_visible(true)
	amount_text:set_color(HMH:GetColor("ObjectiveAmount"))
	amount_text:set_alpha(HMH:GetOption("objective_text"))

	objective_text:set_text(utf8.to_upper(data.text))

	local _, _, w, _ = objective_text:text_rect()

	if data.amount then
		self:update_amount_objective( data )
	end

	objectives_panel:stop()
	objectives_panel:set_alpha(0)
	objectives_panel:set_visible( true )
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 1)

    amount_text:set_visible(data.amount)
	amount_text:set_x( objective_text:x() + 5 + w )
	amount_text:set_y(0)
end

function HUDObjectives:update_amount_objective(data)
	if data.id ~= self._active_objective_id then
		return
	end
	local current = data.current_amount or 0
	local amount = data.amount
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:child("amount_text"):set_text(current .. "/" .. amount)
end

function HUDObjectives:complete_objective(data)
	if data.id ~= self._active_objective_id then
		return
	end
	local objectives_panel = self._hud_panel:child("objectives_panel")
	objectives_panel:stop()
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 0)
end

function HUDObjectives:remind_objective(id)
	if id ~= self._active_objective_id then
		return
	end
end