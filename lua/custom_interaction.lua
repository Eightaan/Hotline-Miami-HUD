if not HMH:GetOption("interact_texture") then return end

if RequiredScript == "lib/managers/hudmanagerpd2" then
	
    local teammate_progress_ori = HUDManager.teammate_progress
    function HUDManager:teammate_progress(...)
        teammate_progress_ori(self, ...)
	local name_label
        if name_label then
            name_label = self:_name_label_by_peer_id(peer_id)
            local panel = name_label.panel
            local bitmap = panel:child("action")
            bitmap:configure({
                texture = "guis/textures/pd2_mod_hmh/hud_progress_active"
            })
        end
    end
elseif RequiredScript == "lib/managers/menu/circleguiobject" then
	function CircleBitmapGuiObject:init(panel, config)
		self._panel = panel
		self._radius = config.radius or 20
		self._sides = config.sides or 64
		self._total = config.total or 1
		self._size = 128
		config.texture_rect = nil
		config.texture = "guis/textures/pd2_mod_hmh/hud_progress_active"
		config.w = self._radius * 2
		config.h = self._radius * 2
		self._circle = self._panel:bitmap(config)

		self._circle:set_render_template(Idstring("VertexColorTexturedRadial"))

		self._alpha = self._circle:color().alpha

		self._circle:set_color(self._circle:color():with_red(0))

		if config.use_bg then
			local bg_config = deep_clone(config)
			bg_config.texture = "guis/textures/pd2_mod_hmh/hud_progress_bg"
			bg_config.layer = bg_config.layer - 1
			bg_config.blend_mode = "normal"
			self._bg_circle = self._panel:bitmap(bg_config)
		end
	end
elseif RequiredScript == "lib/managers/hud/hudinteraction" then
	function HUDInteraction:_animate_interaction_complete(bitmap, circle)
		local TOTAL_T = 0.6
		local t = TOTAL_T
		local mul = 1
		local c_x, c_y = bitmap:center()
		local size = bitmap:w()
		bitmap:set_image("guis/textures/pd2_mod_hmh/hud_progress_active")

		while t > 0 do
			local dt = coroutine.yield()
			t = t - dt
			mul = mul + dt * 0.75

			bitmap:set_size(size * mul, size * mul)
			bitmap:set_center(c_x, c_y)
			bitmap:set_alpha(math.max(t / TOTAL_T, 0))
		end
		bitmap:parent():remove(bitmap)
	end

    local hide_interaction_bar_ori = HUDInteraction.hide_interaction_bar
    function HUDInteraction:hide_interaction_bar(complete)
        hide_interaction_bar_ori(self, complete)
        local bitmap = self._hud_panel:child(self._child_name_text)
        bitmap:configure({
            texture = "guis/textures/pd2_mod_hmh/hud_progress_active"
        })
    end

	local HUDInteraction_set_bar_valid = HUDInteraction.set_bar_valid
	function HUDInteraction:set_bar_valid(valid, ...)
	    HUDInteraction_set_bar_valid(self, valid, ...)
		local texture = valid and "guis/textures/pd2_mod_hmh/hud_progress_active" or "guis/textures/pd2_mod_hmh/hud_progress_invalid"
		self._interact_circle:set_image(texture)
    end
end
