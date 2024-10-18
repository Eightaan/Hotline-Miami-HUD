if RequiredScript == "lib/managers/hud/hudhitconfirm" then
	Hooks:PostHook(HUDHitConfirm, "init", "HMH_HUDHitConfirm_init", function(self, ...)
		if self._hud_panel:child("headshot_confirm") then
			self._hud_panel:remove(self._hud_panel:child("headshot_confirm"))
		end

		local headshot_icon = HMH:GetOption("headshot_texture") == 3 and "guis/textures/pd2_mod_hmh/Headshot_confirm_blessings" or HMH:GetOption("headshot_texture") == 4 and "guis/textures/pd2/hud_progress_active" or "guis/textures/pd2_mod_hmh/Headshot_confirm"
		self._headshot_confirm = self._hud_panel:bitmap({
			texture = headshot_icon,
			name = "headshot_confirm",
			halign = "center",
			visible = false,
			layer = 1,
			blend_mode = "normal",
			valign = "center",
			color = Color("ff3633")
		})
		self._headshot_confirm:set_center(self._hud_panel:w() / 2, self._hud_panel:h() / 2)
	end)
	
	Hooks:PostHook(HUDHitConfirm, "on_headshot_confirmed", "HMH_HUDHitConfirm_on_headshot_confirmed", function(self, ...)
		if HMH:GetOption("headshot_texture") > 1 then
			self._headshot_confirm:stop()
			self._headshot_confirm:animate(callback(self, self, "_animate_show"), callback(self, self, "show_done"), 0.25, 0.15)
		end
	end)
	
elseif RequiredScript == "lib/managers/playermanager" then
	Hooks:PostHook(PlayerManager, "on_headshot_dealt", "HMH_PlayerManager_on_headshot_dealt", function(self, ...)
		managers.hud:on_headshot_confirmed()
	end)
end