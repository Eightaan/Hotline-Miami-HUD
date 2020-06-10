if not HMH:GetOption("interact_texture") then return end

if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then
	function HUDManager:teammate_progress(peer_id, type_index, enabled, tweak_data_id, timer, success)
		local name_label = self:_name_label_by_peer_id(peer_id)

		if name_label then
			name_label.interact:set_visible(enabled)
			name_label.panel:child("action"):set_visible(enabled)

			local action_text = ""

			if type_index == 1 then
				action_text = managers.localization:text(tweak_data.interaction[tweak_data_id].action_text_id or "hud_action_generic")
			elseif type_index == 2 then
				if enabled then
					local equipment_name = managers.localization:text(tweak_data.equipments[tweak_data_id].text_id)
					local deploying_text = tweak_data.equipments[tweak_data_id].deploying_text_id and managers.localization:text(tweak_data.equipments[tweak_data_id].deploying_text_id) or false
					action_text = deploying_text or managers.localization:text("hud_deploying_equipment", {
						EQUIPMENT = equipment_name
					})
				end
			elseif type_index == 3 then
				action_text = managers.localization:text("hud_starting_heist")
			end

			name_label.panel:child("action"):set_text(utf8.to_upper(action_text))
			name_label.panel:stop()

			if enabled then
				name_label.panel:animate(callback(self, self, "_animate_label_interact"), name_label.interact, timer)
			elseif success then
				local panel = name_label.panel
				local bitmap = panel:bitmap({
					blend_mode = "add",
					texture = "guis/textures/pd2_mod_hmh/hud_progress_active",
					layer = 2,
					align = "center",
					rotation = 360,
					valign = "center"
				})

				bitmap:set_size(name_label.interact:size())
				bitmap:set_position(name_label.interact:position())

				local radius = name_label.interact:radius()
				local circle = CircleBitmapGuiObject:new(panel, {
					blend_mode = "normal",
					rotation = 360,
					layer = 3,
					radius = radius,
					color = Color.white:with_alpha(1)
				})

				circle:set_position(name_label.interact:position())
				bitmap:animate(callback(HUDInteraction, HUDInteraction, "_animate_interaction_complete"), circle)
			end
		end

		local character_data = managers.criminals:character_data_by_peer_id(peer_id)

		if character_data then
			self._teammate_panels[character_data.panel_id]:teammate_progress(enabled, tweak_data_id, timer, success)
		end
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/circleguiobject" then
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
elseif string.lower(RequiredScript) == "lib/managers/hud/hudinteraction" then
	function HUDInteraction:_animate_interaction_complete(bitmap, circle)
		local TOTAL_T = 0.6
		local t = TOTAL_T
		local mul = 1
		local c_x, c_y = bitmap:center()
		local size = bitmap:w()

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

	function HUDInteraction:hide_interaction_bar(complete)
		if complete then
			local bitmap = self._hud_panel:bitmap({
				texture = "guis/textures/pd2_mod_hmh/hud_progress_active",
				blend_mode = "add",
				layer = 2,
				align = "center",
				valign = "center"
			})

			bitmap:set_position(bitmap:parent():w() / 2 - bitmap:w() / 2, bitmap:parent():h() / 2 - bitmap:h() / 2)

			local radius = 64
			local circle = CircleBitmapGuiObject:new(self._hud_panel, {
				sides = 64,
				current = 64,
				total = 64,
				blend_mode = "normal",
				layer = 3,
				radius = radius,
				color = Color.white:with_alpha(1)
			})

			circle:set_position(self._hud_panel:w() / 2 - radius, self._hud_panel:h() / 2 - radius)
			bitmap:animate(callback(self, self, "_animate_interaction_complete"), circle)
		end

		if self._interact_circle then
			self._interact_circle:remove()

			self._interact_circle = nil
		end
	end

	local HUDInteraction_set_bar_valid = HUDInteraction.set_bar_valid
	function HUDInteraction:set_bar_valid(valid, ...)
	    HUDInteraction_set_bar_valid(self, valid, ...)
		local texture = valid and "guis/textures/pd2_mod_hmh/hud_progress_active" or "guis/textures/pd2_mod_hmh/hud_progress_invalid"
		self._interact_circle:set_image(texture)
    end
end