--Using LDDG Animations
if not HMH:GetOption("objective") then return end

Hooks:PostHook(HUDObjectives, "init", "HMH_hudobjectives_init", function(self, hud, ...)
	self._hud_panel = hud.panel
	if self._hud_panel:child("objectives_panel") then
		self._hud_panel:remove(self._hud_panel:child("objectives_panel"))
	end
	local objectives_panel = self._hud_panel:panel({
		y = 0,
		name = "objectives_panel",
		h = 100,
		visible = false,
		w = 500,
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

	icon_objectivebox:set_color(Color("ff80df"))	
	objective_text:set_x(34)
	objective_text:set_y(0)
	objective_text:set_font_size(24)
	objective_text:set_color(Color("66ffff"))
	objective_text:set_visible(true)
	amount_text:set_color(Color("ffcc66"))
end)

function HUDObjectives:activate_objective( data )
	self._active_objective_id = data.id
	local objectives_panel = self._hud_panel:child( "objectives_panel" )
	local objective_text = objectives_panel:child( "objective_text" )
		
	objective_text:set_text( utf8.to_upper( data.text ) )
		
	local _, _, w, _ = objective_text:text_rect()
		
	if data.amount then
		self:update_amount_objective( data )
	end
    -->LDDG
	--Animation
	objectives_panel:stop()
	objectives_panel:set_alpha(0)
	objectives_panel:set_visible( true )
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 1)
	
	--Put the amount text after the objective text
	local amount_text = objectives_panel:child( "amount_text" )
    amount_text:set_visible(data.amount)
	amount_text:set_x( objective_text:x() + 5 + w )	
    --<LDDG
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
	objectives_panel:animate(callback(nil, _G, "set_alpha"), 0) --LDDG Animation
end

function HUDObjectives:remind_objective(id)
	if id ~= self._active_objective_id then
		return
	end
end
