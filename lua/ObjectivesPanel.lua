if not HMH:GetOption("objective") then
    return
end



function HUDObjectives:activate_objective( data )
	self._active_objective_id = data.id
	local objectives_panel = self._hud_panel:child("objectives_panel")
	local objective_text = objectives_panel:child("objective_text")

	objective_text:set_text(utf8.to_upper(data.text))

	local _, _, w, _ = objective_text:text_rect()

	if data.amount then
		self:update_amount_objective( data )
	end

	objectives_panel:stop()
	objectives_panel:set_alpha(0)
	objectives_panel:set_visible( true )
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 1)
	local amount_text = objectives_panel:child("amount_text")

    amount_text:set_visible(data.amount)
	amount_text:set_x( objective_text:x() + 5 + w )
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

local orig = HUDBGBox_create
function HUDBGBox_create(panel, params, config)
	config = config or {}
	config.color = Color.white:with_alpha(0)
	config.bg_color = Color.white:with_alpha(0)
	local box_panel = orig(panel, params, config)
	box_panel:child("left_top"):hide()
	box_panel:child("left_bottom"):hide()
	box_panel:child("right_top"):hide()
	box_panel:child("right_bottom"):hide()
	return box_panel
end