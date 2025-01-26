if _G.IS_VR then 
	return
end

local HMH = HMH
local math_max = math.max
local math_sin = math.sin
local math_lerp = math.lerp
local Color = Color

if RequiredScript == "lib/managers/hudmanagerpd2" then
	function HUDManager:set_infinite_ammo(state)
		if self._teammate_panels[self.PLAYER_PANEL]._set_infinite_ammo then
			self._teammate_panels[self.PLAYER_PANEL]:_set_infinite_ammo(state)		
		end
		-- Hides the bulletstorm display used by VHUDPlus		
		if self._teammate_panels[self.PLAYER_PANEL]._set_bulletstorm then
			self._teammate_panels[self.PLAYER_PANEL]:_set_bulletstorm(false)
		end
	end

	Hooks:PostHook(HUDManager, "_setup_player_info_hud_pd2", "hmh_bufflist_setup_player_info_hud_pd2", function(self, ...)
		self._hud_buff_list = HUDBuffList:new(managers.hud:script(PlayerBase.PLAYER_INFO_HUD_PD2))
	end)

	function HUDManager:update_inspire_timer(buff)
		self._hud_buff_list:update_inspire_timer(buff)
	end

	function HUDManager:Set_bloodthirst(buff)
	   self._hud_buff_list:Set_bloodthirst(buff)
	end

	HUDBuffList = HUDBuffList or class()
	function HUDBuffList:init()
		if managers.hud ~= nil then

			local Skilltree2 = "guis/textures/pd2/skilltree_2/icons_atlas_2"
			local TimeBackground = "guis/textures/pd2/crimenet_marker_glow"
			
			self.hud = managers.hud:script(PlayerBase.PLAYER_INFO_HUD_FULLSCREEN_PD2)

			--Inspire Cooldown
			self._cooldown_panel = self.hud.panel:panel()

			self.cooldown_text = self._cooldown_panel:text({
				layer = 2,
				visible = false,
				font = tweak_data.hud.medium_font_noshadow
			})
			self._inspire_cooldown_icon = self._cooldown_panel:bitmap({
				name = "inspire_cooldown_icon",
				texture = Skilltree2,
				texture_rect = { 4* 80, 9 * 80, 80, 80 },
				visible = false,
				layer = 1
			})
			self._inspire_cooldown_timer_bg = self._cooldown_panel:bitmap({
				name = "inspire_cooldown_timer_bg",
				texture = TimeBackground,
				texture_rect = { 1, 1, 62, 62 }, 
				color = Color("66ffff"),
				visible = false
			})

			--Bloodthirst
			self._bloodthirst_panel = self.hud.panel:panel()
			
			self.bloodthirst_text = self._bloodthirst_panel:text({
				layer = 2,
				visible = false,
				font = tweak_data.hud.medium_font_noshadow
			})
			self._bloodthirst_icon = self._bloodthirst_panel:bitmap({
				name = "bloodthirst_icon",
				texture = Skilltree2,
				texture_rect = { 11* 80, 6 * 80, 80, 80 },
				visible = false,
				layer = 1
			})
			self._bloodthirst_bg = self._bloodthirst_panel:bitmap({
				name = "bloodthirst_bg",
				texture = TimeBackground,
				texture_rect = { 1, 1, 62, 62 }, 
				color = Color("66ffff"),
				visible = false
			})
		end
	end

	function HUDBuffList:update_timer_visibility_and_position()
		local inspire_visible = HMH:GetOption("inspire")
		local panel = self._cooldown_panel
		local timer = self.cooldown_text
		local inspire_timer_scale = HMH:GetOption("timer_scale")
		local pos_x = 10 * (HMH:GetOption("timer_x") or 0)
		local pos_y = 10 * (HMH:GetOption("timer_y") or 0)
		
		timer:set_visible(inspire_visible)
		panel:child("inspire_cooldown_icon"):set_visible(inspire_visible)
		panel:child("inspire_cooldown_timer_bg"):set_visible(inspire_visible)
		
		panel:set_x(pos_x)
		panel:set_y(pos_y)
		
		timer:set_x(13 * inspire_timer_scale)
		timer:set_y(25 * inspire_timer_scale)
		timer:set_font_size(16 * inspire_timer_scale)
		
		panel:child("inspire_cooldown_timer_bg"):set_w(40 * inspire_timer_scale)
		panel:child("inspire_cooldown_timer_bg"):set_h(40 * inspire_timer_scale)
		panel:child("inspire_cooldown_timer_bg"):set_y(13 * inspire_timer_scale)
		
		panel:child("inspire_cooldown_icon"):set_w(28 * inspire_timer_scale)
		panel:child("inspire_cooldown_icon"):set_h(28 * inspire_timer_scale)
	end

	function HUDBuffList:update_inspire_timer(duration)
		local timer = self.cooldown_text
		local timer_bg = self._inspire_cooldown_timer_bg
		local icon = self._inspire_cooldown_icon

		timer:set_alpha(1)
		timer_bg:set_alpha(0.5)
		icon:set_alpha(1)

		if duration and duration > 1 then
			timer:stop()
			timer:animate(function(o)
				local t_left = duration
				self:update_timer_visibility_and_position()
				
				while t_left >= 0 do
					if t_left <= 0.1 then
						self:fade_out("inspire")
						return
					end
					t_left = t_left - coroutine.yield()
					o:set_text(string.format(t_left < 9.9 and "%.1f" or "%.f", t_left))
					self:update_timer_visibility_and_position()
					o:set_color(HMH:GetColor("InspireTimer") or Color.white)
					icon:set_color(HMH:GetColor("InspireIcon") or Color.white)
					timer_bg:set_color(HMH:GetColor("InspireTimer") or Color("66ffff"))
				end
			end)
		end
	end

	function HUDBuffList:fade_out(buff_type)
		local start_time = os.clock()
		local text, bg, icon
		local duration

		if buff_type == "inspire" then
			text = self.cooldown_text
			bg = self._inspire_cooldown_timer_bg
			icon = self._inspire_cooldown_icon
			duration = 0.1  -- Fade out duration for Inspire
		elseif buff_type == "bloodthirst" then
			text = self.bloodthirst_text
			bg = self._bloodthirst_bg
			icon = self._bloodthirst_icon
			duration = 0.3  -- Fade out duration for Bloodthirst
		end

		if text and bg and icon then
			text:animate(function()
				while true do
					local alpha = math_max(1 - (os.clock() - start_time) / duration, 0)
					text:set_alpha(alpha)
					bg:set_alpha(0.5 * alpha)
					icon:set_alpha(alpha)

					if alpha <= 0 then
						icon:set_visible(false)
						bg:set_visible(false)
						text:set_text("")
						break
					end

					coroutine.yield()
				end
			end)
		end
	end

	function HUDBuffList:update_bloodthirst_position()
		local panel = self._bloodthirst_panel
		local text = self.bloodthirst_text

		local x_position = 10 * (HMH:GetOption("BloodthirstX") or 0)
		local y_position = 10 * (HMH:GetOption("BloodthirstY") or 0)
		local bloodthirst_scale = HMH:GetOption("BloodthirstScale")
		panel:set_x(x_position)
		panel:set_y(y_position)
		text:set_x(12 * bloodthirst_scale)
		text:set_y(25 * bloodthirst_scale)
		panel:child("bloodthirst_bg"):set_w(37 * bloodthirst_scale)
		panel:child("bloodthirst_bg"):set_h(37 * bloodthirst_scale)
		panel:child("bloodthirst_bg"):set_y(15 * bloodthirst_scale)
		panel:child("bloodthirst_icon"):set_w(28 * bloodthirst_scale)
		panel:child("bloodthirst_icon"):set_h(28 * bloodthirst_scale)
	end

	function HUDBuffList:Set_bloodthirst(buff)
		local bloodthirst_text = self.bloodthirst_text
		local bloodthirst_icon = self._bloodthirst_icon
		local bloodthirst_timer_bg = self._bloodthirst_bg
		
		bloodthirst_text:set_alpha(1)
		bloodthirst_icon:set_alpha(1)
		bloodthirst_timer_bg:set_alpha(0.5)
		
		if buff >= HMH:GetOption("BloodthirstMinKills") and HMH:GetOption("Bloodthirst") then
			bloodthirst_text:set_visible(true)
			bloodthirst_icon:set_visible(true)
			bloodthirst_timer_bg:set_visible(true)
			self:update_bloodthirst_position()
			bloodthirst_timer_bg:set_color(HMH:GetColor("BloodthirstText") or Color("66ffff"))
			bloodthirst_text:set_color(HMH:GetColor("BloodthirstText") or Color.white)
			bloodthirst_icon:set_color(HMH:GetColor("BloodthirstIcon") or Color.white)
			bloodthirst_text:set_text(managers.localization:to_upper_text("HMH_bloodthirst_multiplier", { NUM = buff }).."x")
			local font_size = 16 * HMH:GetOption("BloodthirstScale")
			bloodthirst_text:animate(function(o)
				over(1 , function(p)
					local n = 1 - math_sin((p / 2 ) * 180)
					o:set_font_size(math_lerp(font_size, font_size * 1.16 , n))
				end)
			end)
		else
			self:fade_out("bloodthirst")
		end
	end
elseif RequiredScript == "lib/managers/playermanager" then

	function PlayerManager:_clbk_bulletstorm_expire()
		self._infinite_ammo_clbk = nil
		managers.hud:set_infinite_ammo(false)

		if managers.player and managers.player:player_unit() and managers.player:player_unit():inventory() then
			for id, weapon in pairs(managers.player:player_unit():inventory():available_selections()) do
				managers.hud:set_ammo_amount(id, weapon.unit:base():ammo_info())
			end
		end
	end

	Hooks:PostHook(PlayerManager, "add_to_temporary_property", "HMH_PlayerManager_add_to_temporary_property", function (self, name, time, ...)
		if HMH:GetOption("bulletstorm") and name == "bullet_storm" and time then
			if not self._infinite_ammo_clbk then
				self._infinite_ammo_clbk = "infinite"
				managers.hud:set_infinite_ammo(true)
				managers.enemy:add_delayed_clbk(self._infinite_ammo_clbk, callback(self, self, "_clbk_bulletstorm_expire"), TimerManager:game():time() + time)
			end
		end
	end)
	
	Hooks:PostHook(PlayerManager, "disable_cooldown_upgrade", "HMH_PlayerManager_disable_cooldown_upgrade", function (self, category, upgrade)
		local upgrade_value = self:upgrade_value(category, upgrade)
		if upgrade_value and upgrade_value[1] ~= 0 and HMH:GetOption("inspire") then
			managers.hud:update_inspire_timer(upgrade_value[2])
		end
	end)
	
	Hooks:PostHook(PlayerManager, 'set_melee_dmg_multiplier', "HMH_update_Bloodthirst", function(self, ...)
		if not self:has_category_upgrade("player", "melee_damage_stacking") then 
			return 
		end

		if self._melee_dmg_mul ~= 1 then
			managers.hud:Set_bloodthirst(self._melee_dmg_mul)
		end
	end)
	
	Hooks:PostHook(PlayerManager, 'reset_melee_dmg_multiplier', "HMH_reset_Bloodthirst", function(self)
		if not self:has_category_upgrade("player", "melee_damage_stacking") then 
			return 
		end
		managers.hud:Set_bloodthirst(0)
	end)
end