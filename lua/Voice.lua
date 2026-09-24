Hooks:PostHook(HUDManager, "set_mugshot_voice", "HMH_MenuManager_set_mugshot_voice", function (self, id, active, ...)
	local peer_id
	for i, data in pairs(self._hud.mugshots) do
		if data.id and data.id == id then
			peer_id = data.peer_id
			break
		end
	end

	if not peer_id or peer_id == managers.network:session():local_peer():id() then
		return
	end

	local unit = managers.criminals:character_unit_by_peer_id(peer_id)
	if not unit or not alive(unit) then
		return
	end

	local name_label = managers.hud:_get_name_label(unit:unit_data().name_label_id)
	if not name_label then
		return
	end

	local talk_icon = name_label.panel:child('hud_talk_icon')
	if talk_icon then
		name_label.panel:remove(talk_icon)
	end

	if active then
		local icon = "pd2_talk"
		local color = tweak_data.chat_colors[managers.criminals:character_color_id_by_unit(unit)]
		local texture, rect = tweak_data.hud_icons:get_icon_data(icon)
		local hud_icon = name_label.panel:bitmap({
			blend_mode = 'add',
			name = 'hud_talk_icon',
			texture = texture,
			texture_rect = rect,
			layer = 0,
			color = color:with_alpha(0.9),
			w = 32,
			h = 32,
			visible = true,
		})
		name_label.hud_talk_icon = hud_icon
		local label = name_label.panel:child('text')
		hud_icon:set_center_y(10)
		hud_icon:set_right(label:right() - 50)
	end
end)