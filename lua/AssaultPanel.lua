if not HMH:GetOption("assault") then
   return
end

local HMH = HMH
local math_sin = math.sin
local math_lerp = math.lerp
local set_alpha = set_alpha

Hooks:PostHook(HUDAssaultCorner, "init", "HMH_hudassaultcorner_init", function(self, hud, ...)
    self._assault_color = HMH:GetColor("AssaultText")
	self._vip_assault_color = HMH:GetColor("CaptainText")
	if managers.mutators:are_mutators_active() then
		local mutator_color = managers.mutators:get_category_color(managers.mutators:get_enabled_active_mutator_category())
		self._assault_color = mutator_color
		self._vip_assault_color = Color(mutator_color.a, mutator_color.b, mutator_color.g, mutator_color.r)
	end

	if managers.skirmish:is_skirmish() then
		self._is_skirmish = true
		self._assault_color = HMH:GetColor("HoldoutText")
	end

	self._is_crimespree = managers.crime_spree:is_active()

    -- HOSTAGES
	local hostages_panel = self._hud_panel:child("hostages_panel")
	local hostage_text = self._hostages_bg_box:child("num_hostages")
	local hostages_icon = hostages_panel:child("hostages_icon")
	hostages_panel:set_visible(HMH:GetOption("hostage_panel"))
	self._hostages_bg_box:child("bg"):hide()
	self._hostages_bg_box:child("left_top"):hide()
	self._hostages_bg_box:child("left_bottom"):hide()
	self._hostages_bg_box:child("right_top"):hide()
	self._hostages_bg_box:child("right_bottom"):hide()
	hostage_text:set_color(HMH:GetColor("HostagesText"))
	hostage_text:set_alpha(HMH:GetOption("info_box_alpha"))
	hostages_icon:set_alpha(HMH:GetOption("info_box_alpha"))
	hostages_icon:set_color(HMH:GetColor("HostagesIcon"))

	-- ASSAULT
	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	self._bg_box:child("bg"):hide()
	self._bg_box:child("left_top"):hide()
	self._bg_box:child("left_bottom"):hide()
	self._bg_box:child("right_top"):hide()
	self._bg_box:child("right_bottom"):hide()
	icon_assaultbox:set_blend_mode("normal")

	assault_panel:show()
	assault_panel:set_alpha(0)
	assault_panel:text({
		name = "text",
		color = self._assault_color,
		alpha = HMH:GetOption("assault_text"),
		font = tweak_data.hud.medium_font_noshadow
	})

	local _,_,w,h = assault_panel:child("text"):text_rect()
	assault_panel:set_size(500, 40)
	assault_panel:set_righttop(self._hud_panel:w(), 0)

	-- CASING
	local casing_panel = self._hud_panel:child("casing_panel")
	local icon_casingbox = casing_panel:child("icon_casingbox")
	self._casing_bg_box:child("bg"):hide()
	self._casing_bg_box:child("left_top"):hide()
	self._casing_bg_box:child("left_bottom"):hide()
	self._casing_bg_box:child("right_top"):hide()
	self._casing_bg_box:child("right_bottom"):hide()
	icon_casingbox:set_color(HMH:GetColor("CasingIcon"))
	icon_casingbox:set_alpha(HMH:GetOption("assault_text"))
	icon_casingbox:set_blend_mode("normal")

	casing_panel:show()
	casing_panel:set_alpha(0)
	casing_panel:text({
		name = "text",
        color = HMH:GetColor("CasingText"),
		alpha = HMH:GetOption("assault_text"),
		font = tweak_data.hud.medium_font_noshadow
	})

	local _,_,w,h = casing_panel:child("text"):text_rect()
	casing_panel:set_size(500, 40)
	casing_panel:set_righttop(self._hud_panel:w(), 0)

	-- POINT OF NO RETURN
	local point_of_no_return_panel = self._hud_panel:child("point_of_no_return_panel")
	local point_of_no_return_text = self._noreturn_bg_box:child( "point_of_no_return_text" )
	local icon_noreturnbox = point_of_no_return_panel:child("icon_noreturnbox")
	local point_of_no_return_timer = self._noreturn_bg_box:child( "point_of_no_return_timer" )
	self._noreturn_bg_box:child("bg"):hide()
	self._noreturn_bg_box:child("left_top"):hide()
	self._noreturn_bg_box:child("left_bottom"):hide()
	self._noreturn_bg_box:child("right_top"):hide()
	self._noreturn_bg_box:child("right_bottom"):hide()
	point_of_no_return_panel:show()
	point_of_no_return_panel:set_alpha(0)
	icon_noreturnbox:set_color(HMH:GetColor("NoReturnIcon"))
	icon_noreturnbox:set_alpha(HMH:GetOption("assault_text"))
	point_of_no_return_text:set_color(HMH:GetColor("NoReturnText"))
	point_of_no_return_text:set_alpha(HMH:GetOption("assault_text"))
	point_of_no_return_timer:set_color(HMH:GetColor("NoReturnTimer"))
	point_of_no_return_timer:set_alpha(HMH:GetOption("assault_text"))
	point_of_no_return_timer:set_y(0)
	point_of_no_return_text:set_blend_mode("normal")
   	point_of_no_return_timer:set_blend_mode("normal")
	icon_noreturnbox:set_blend_mode("normal")
	self._noreturn_bg_box:set_right(icon_noreturnbox:left() - 3)
	self._noreturn_bg_box:set_center_y(icon_noreturnbox:center_y())

    -- VIP ICON
	local width = 200
    local icon_offset = 140 + (10 * managers.job:current_difficulty_stars())
	local vip_icon = self._vip_bg_box:child("vip_icon")
	local vip_icon_new = self._vip_bg_box:child("vip_icon_new")
	local buffs_panel = self._hud_panel:child("buffs_panel")
	self._vip_bg_box:child("bg"):hide()
	self._vip_bg_box:child("left_top"):hide()
	self._vip_bg_box:child("left_bottom"):hide()
	self._vip_bg_box:child("right_top"):hide()
	self._vip_bg_box:child("right_bottom"):hide()
	buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - icon_offset)
	self._vip_bg_box:set_x(width - 38)
	vip_icon:set_color(HMH:GetColor("CaptainBuffIcon"))
	vip_icon:set_blend_mode("normal")
	vip_icon:set_alpha(HMH:GetOption("assault_text"))
	vip_icon:set_center(self._vip_bg_box:w() / 2, self._vip_bg_box:h() / 2 - 5)

	local vip_text = self._vip_bg_box:text({
		name = "vip_text",
		text = "",
		h = 38,
		layer = 10,
		w = 38,
		visible = HMH:GetOption("captain_buff"),
		valign = "center",
		align = "center",
		vertical = "center",
		y = - 13,
		x = - 16,
		alpha = HMH:GetOption("assault_text") or 1,
		color = HMH:GetColor("captain_buff_color") or Color("66ffff"),
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.numhostages_size * 0.6
	})
end)

Hooks:PostHook(HUDAssaultCorner, "setup_wave_display", "HMH_hudassaultcorner_setup_wave_display", function(self, top, ...)
	if self:should_display_waves() then
		local wave_panel = self._hud_panel:child("wave_panel")
	    local waves_icon = wave_panel:child("waves_icon")
	    local num_waves = self._wave_bg_box:child("num_waves")
		wave_panel:set_visible(HMH:GetOption("wave_panel"))
		self._wave_bg_box:child("bg"):hide()
        self._wave_bg_box:child("left_top"):hide()
        self._wave_bg_box:child("left_bottom"):hide()
        self._wave_bg_box:child("right_top"):hide()
        self._wave_bg_box:child("right_bottom"):hide()
	    waves_icon:set_color(HMH:GetColor("WavesIcon"))
		waves_icon:set_alpha(HMH:GetOption("info_box_alpha"))
	    num_waves:set_color(HMH:GetColor("WavesText"))
		num_waves:set_alpha(HMH:GetOption("info_box_alpha"))
	end
end)

function HUDAssaultCorner:_start_assault(text_list)
	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
	if alive(self._wave_bg_box) then
        local panel = self._hud_panel:child("wave_panel")
	    local wave_text = panel:child("num_waves")
		local num_waves = self._wave_bg_box:child("num_waves")
	    num_waves:set_text(self:get_completed_waves_string())
		self._hud_panel:child("wave_panel"):set_visible(HMH:GetOption("wave_panel"))
	end

	icon_assaultbox:set_color(self._assault_color)
	icon_assaultbox:set_alpha(HMH:GetOption("assault_text"))
	self._assault = true
	self:hide_casing()

	self:set_text("assault", text_list)
	assault_panel:animate(callback(self, self, "animate_assault_in_progress"))
end

function HUDAssaultCorner:animate_assault_in_progress(o)
	while self._assault do
		set_alpha(o, 0.6)
		set_alpha(o, 1)
	end
	set_alpha(o, 0)
end

function HUDAssaultCorner:_end_assault()
	if not self._assault then
		self._start_assault_after_hostage_offset = nil
		return
	end

	self._assault = false
	self._remove_hostage_offset = true
	self._start_assault_after_hostage_offset = nil
	self:_close_assault_box()
end

function HUDAssaultCorner:_hide_icon_assaultbox(icon_assaultbox)
	local TOTAL_T = 1
	local t = TOTAL_T

	while t > 0 do
		local dt = coroutine.yield()
		t = t - dt
		if self._remove_hostage_offset and t < 0.03 then
			self:_set_hostage_offseted(false)
		end
	end

	if self._remove_hostage_offset then
		self:_set_hostage_offseted(false)
	end

	if not self._casing then
		self:_show_hostages()
	end
end

function HUDAssaultCorner:set_control_info(data)
	self._hostages_bg_box:child("num_hostages"):set_text(data.nr_hostages)
end

function HUDAssaultCorner:set_text(typ, text_list, add)
	local panel = self._hud_panel:child(typ .. "_panel")
	local text = panel:child("text")
	text:set_text(text_list)
	local _,_,w,h = text:text_rect()
	text:set_size(w,h)
	text:set_right(panel:child("icon_" .. typ .. "box"):left() - 4)
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
	if self._assault_mode == mode then
		return
	end

	self._assault_mode = mode

	self:set_text("assault", self:_get_assault_strings())

	local assault_panel = self._hud_panel:child("assault_panel")
	local text = assault_panel:child("text")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	local image = mode == "phalanx" and "guis/textures/pd2/hud_icon_padlockbox" or "guis/textures/pd2/hud_icon_assaultbox"
	local color = mode == "phalanx" and self._vip_assault_color or self._assault_color
	icon_assaultbox:set_image(image)
	icon_assaultbox:set_color(color)
	icon_assaultbox:set_alpha(HMH:GetOption("assault_text"))
	text:set_color(color)
	text:set_alpha(HMH:GetOption("assault_text"))
end

function HUDAssaultCorner:_get_assault_strings()
	local crime_spree_rank
	if self._is_crimespree and self._assault_mode == "normal" then
		local space = string.rep(" ", 2)
	    crime_spree_rank = ":" .. space ..  managers.localization:to_upper_text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
	else
	    crime_spree_rank = ""
	end

	local assault_text = ""
	if self._is_crimespree then
	    assault_text = managers.localization:to_upper_text(self._assault_mode == "normal" and "cn_crime_spree" or "hud_assault_vip") .. crime_spree_rank
	elseif self._is_skirmish then
	    assault_text = managers.localization:to_upper_text("hmh_hud_assault_assault")
	else
		local difficulty = ""
		for i = 1, managers.job:current_difficulty_stars() do
			difficulty = difficulty .. managers.localization:get_default_macro("BTN_SKULL")
		end
	    assault_text = managers.localization:to_upper_text(self._assault_mode == "normal" and "hmh_hud_assault_assault" or "hud_assault_vip") .. " " .. difficulty
	end

	return assault_text
end

function HUDAssaultCorner:show_casing(mode)
    if HMH:GetOption("casing") then
 	    local delay_time = self._assault and 1.2 or 0
	    self:_end_assault()
	    local casing_panel = self._hud_panel:child("casing_panel")
	    self:_hide_hostages()
	    casing_panel:animate(callback(self, self, "_animate_show_casing"), delay_time)
	    self._casing = true
	    local msg = mode == "civilian" and "hud_casing_mode_ticker_clean" or "hud_casing_mode_ticker"
	    self:set_text("casing", managers.localization:to_upper_text(msg))
	end
end

function HUDAssaultCorner:hide_casing()
	local icon_casingbox = self._hud_panel:child("casing_panel"):child("icon_casingbox")
	icon_casingbox:stop()
	local function close_done()
		self._hud_panel:child("casing_panel"):animate(set_alpha, 0)
		icon_casingbox:animate(callback(self, self, "_hide_icon_assaultbox"))
	end
	self._casing_bg_box:stop()
	self._casing_bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
	self._casing = false
end

function HUDAssaultCorner:_animate_show_casing(casing_panel, delay_time)
	set_alpha(casing_panel, 1)
end

function HUDAssaultCorner:_hide_hostages()
	self._hud_panel:child("hostages_panel"):animate(set_alpha, 0)
end

function HUDAssaultCorner:_show_hostages()
	if not self._point_of_no_return then
		self._hud_panel:child("hostages_panel"):animate(set_alpha, 1)
	end
end

function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time)
	set_alpha(point_of_no_return_panel, 1)
	wait(delay_time)
	point_of_no_return_panel:set_visible(true)
end

function HUDAssaultCorner:flash_point_of_no_return_timer(beep)
	local flash_timer = function (o)
		local t = 0
		while t < 0.5 do
			t = t + coroutine.yield()
			local color = HMH:GetColor("NoReturnTimer") or Color(1, 1, 0, 0)
			local flash_color = self._noreturn_data.flash_color or Color(1, 1, 0.8, 0.2)
			local n = 1 - math.sin(t * 180)
			local r = math.lerp(color.r, flash_color.r, n)
			local g = math.lerp(color.g, flash_color.g, n)
			local b = math.lerp(color.b, flash_color.b, n)
			o:set_color(Color(r, g, b))
            o:set_font_size(math_lerp(24 , (24) * 1.25, n))
		end
  	end
  	local point_of_no_return_timer = self._noreturn_bg_box:child("point_of_no_return_timer")
	self:hide_casing()
	point_of_no_return_timer:animate(flash_timer)
end

function HUDAssaultCorner:set_vip_text(buff)
    if buff and self._vip_bg_box then
		self._vip_bg_box:child("vip_text"):set_text(managers.localization:to_upper_text("hmh_damage_resistance", { NUM = buff }))
	end
end