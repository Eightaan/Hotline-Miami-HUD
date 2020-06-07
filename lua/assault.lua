Hooks:PostHook(HUDAssaultCorner, "init", "HMH_hudassaultcorner_init", function(self, hud, ...)	
	if not HMH:GetOption("assault") then return end

    self._hud_panel = hud.panel
	-- HOSTAGES
	if VHUDPlus and VHUDPlus:getSetting({"HUDList", "ENABLED"}, true) and not VHUDPlus:getSetting({"HUDList", "ORIGNIAL_HOSTAGE_BOX"}, false) then
	    Hostage_visible = false
	else
	    Hostage_visible = true	
	end
	
	local hostages_panel = self._hud_panel:child("hostages_panel")	
	local hostage_text = self._hostages_bg_box:child("num_hostages")
	local hostages_icon = hostages_panel:child("hostages_icon")
	hostages_panel:set_visible(Hostage_visible)
	hostage_text:set_color(Color("66ffff"))
	hostages_icon:set_color(Color("ff80df"))

	-- ASSAULT
	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	icon_assaultbox:set_blend_mode("normal")
	
	-- LDDG Assault text
	assault_panel:show()
	assault_panel:set_alpha(0)
	assault_panel:text({
		name = "text",
		color = Color("ffcc66"),
		font = tweak_data.hud.medium_font_noshadow
	})
	
	local _,_,w,h = assault_panel:child("text"):text_rect()	
	assault_panel:set_size(500, 40)
	assault_panel:set_righttop(self._hud_panel:w(), 0)

	-- CASING
	local casing_panel = self._hud_panel:child("casing_panel")
	local icon_casingbox = casing_panel:child("icon_casingbox")
	icon_casingbox:set_color(Color("ff80df"))
	icon_casingbox:set_blend_mode("normal")
	
	--LDDG Casing text
	casing_panel:show()
	casing_panel:set_alpha(0)	
	casing_panel:text({
		name = "text",
        color = Color("66ff99"),		
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
	
	point_of_no_return_panel:show()
	point_of_no_return_panel:set_alpha(0)
	icon_noreturnbox:set_color(Color("ff80df"))
	point_of_no_return_text:set_color(Color("66ffff"))
	point_of_no_return_timer:set_color(Color("ff3300"))
	point_of_no_return_timer:set_y(0)
	point_of_no_return_text:set_blend_mode("normal")
   	point_of_no_return_timer:set_blend_mode("normal")
	icon_noreturnbox:set_blend_mode("normal")
	self._noreturn_bg_box:set_right(icon_noreturnbox:left() - 3)
	self._noreturn_bg_box:set_center_y(icon_noreturnbox:center_y())

	-- VIP ICON
	if Global.game_settings.difficulty == "sm_wish" then -- Because I have no clue how to allign things properly
	    icon_offset = 200
	elseif Global.game_settings.difficulty == "overkill_290" then
	    icon_offset = 190
	elseif Global.game_settings.difficulty == "easy_wish" then
	    icon_offset = 180
	elseif Global.game_settings.difficulty == "overkill_145" and managers.crime_spree:is_active() then
	    icon_offset = 230
	elseif Global.game_settings.difficulty == "overkill_145" then
	    icon_offset = 170	
	elseif Global.game_settings.difficulty == "overkill" then
	    icon_offset = 160
	elseif Global.game_settings.difficulty == "hard" then
	    icon_offset = 150
	elseif Global.game_settings.difficulty == "normal" then
	    icon_offset = 140
	end
	local vip_icon = self._vip_bg_box:child("vip_icon")
	local buffs_panel = self._hud_panel:child("buffs_panel")
	buffs_panel:set_x(assault_panel:left() + self._bg_box:left() - icon_offset)
	vip_icon:set_center(self._vip_bg_box:w() / 2, self._vip_bg_box:h() / 2 - 5)
	vip_icon:set_color(Color("ffcc66"))
	vip_icon:set_blend_mode("normal")
	self._vip_bg_box:child("bg"):hide()
end)

Hooks:PostHook(HUDAssaultCorner, "setup_wave_display", "HMH_hudassaultcorner_setup_wave_display", function(self, top, ...)
	if not HMH:GetOption("assault") then return end
	
	if self:should_display_waves() then
		local wave_panel = self._hud_panel:child("wave_panel")
	    local waves_icon = wave_panel:child("waves_icon")
	    local num_waves = self._wave_bg_box:child("num_waves")
	    waves_icon:set_color(Color("ff80df"))
	    num_waves:set_color(Color("66ffff"))
	end
end)

local HUDAssaultCorner_start_assault = HUDAssaultCorner._start_assault
function HUDAssaultCorner:_start_assault(text_list)
    if not HMH:GetOption("assault") then return HUDAssaultCorner_start_assault(self, text_list) end

	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")
	if alive(self._wave_bg_box) then
        local panel = self._hud_panel:child("wave_panel")
	    local wave_text = panel:child("num_waves")
		local num_waves = self._wave_bg_box:child("num_waves")
	    num_waves:set_text(self:get_completed_waves_string())
		self._hud_panel:child("wave_panel"):set_visible(true)
	end

	icon_assaultbox:set_color(Color("ffcc66"))
	self._assault = true
	self:hide_casing()
	
	--LDDG Animation and text
	self:set_text("assault", text_list)
	assault_panel:animate(callback(self, self, "animate_assault_in_progress"))
end

function HUDAssaultCorner:animate_assault_in_progress(o)
    if not HMH:GetOption("assault") then return end

    --LDDG Assault animation
	while self._assault do
		set_alpha(o, 0.6)
		set_alpha(o, 1)
	end
	set_alpha(o, 0)
end

local HUDAssaultCorner_end_assault = HUDAssaultCorner._end_assault
function HUDAssaultCorner:_end_assault()
   if not HMH:GetOption("assault") then return HUDAssaultCorner_end_assault(self) end
   
	if not self._assault then
		self._start_assault_after_hostage_offset = nil
		return
	end

	self._assault = false
	self._remove_hostage_offset = true
	self._start_assault_after_hostage_offset = nil

	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")

	icon_assaultbox:stop()

	local function close_done()
		self._bg_box:set_visible(false)
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_hide_icon_assaultbox"))
		self:sync_set_assault_mode("normal")
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
end

local HUDAssaultCorner_set_control_info = HUDAssaultCorner.set_control_info
function HUDAssaultCorner:set_control_info(data)
    if not HMH:GetOption("assault") then return HUDAssaultCorner_set_control_info(self, data) end
	
	self._hostages_bg_box:child("num_hostages"):set_text(data.nr_hostages)
end

function HUDAssaultCorner:set_text(typ, text_list, add)
    if not HMH:GetOption("assault") then return end

    --LDDG Set text
	local panel = self._hud_panel:child(typ .. "_panel")
	local text = panel:child("text")
	text:set_text(text_list)
	local _,_,w,h = text:text_rect()
	text:set_size(w,h)
	text:set_right(panel:child("icon_" .. typ .. "box"):left() - 4)
end

local HUDAssaultCorner_sync_set_assault_mode = HUDAssaultCorner.sync_set_assault_mode
function HUDAssaultCorner:sync_set_assault_mode(mode)
    if not HMH:GetOption("assault") then return HUDAssaultCorner_sync_set_assault_mode(self, mode) end

	if self._assault_mode == mode then
		return
	end
	
	self._assault_mode = mode

	self:set_text("assault", self:_get_assault_strings())	

	local assault_panel = self._hud_panel:child("assault_panel")
	local text = assault_panel:child("text")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	local image = mode == "phalanx" and "guis/textures/pd2/hud_icon_padlockbox" or "guis/textures/pd2/hud_icon_assaultbox"
	local color = mode == "phalanx" and Color("ff6666") or Color("ffcc66")
	icon_assaultbox:set_image(image)
	icon_assaultbox:set_color(color)
	text:set_color(color)
end

local HUDAssaultCorner_get_assault_strings = HUDAssaultCorner._get_assault_strings
function HUDAssaultCorner:_get_assault_strings()
  if not HMH:GetOption("assault") then return HUDAssaultCorner_get_assault_strings(self) end
    --LDDG Assault strings	
	local difficulty = ""
	for i = 1, managers.job:current_difficulty_stars() do
		difficulty = difficulty .. managers.localization:get_default_macro("BTN_SKULL")
	end		
	
	local space = string.rep(" ", 2)
	if managers.crime_spree:is_active() then
	assault_text = managers.localization:to_upper_text(self._assault_mode == "normal" and "cn_crime_spree" or "hud_assault_vip") .. space ..  managers.localization:to_upper_text("menu_cs_level", {level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")})
	else
	assault_text = managers.localization:to_upper_text(self._assault_mode == "normal" and "hud_assault_assault" or "hud_assault_vip") .. " " .. difficulty
	end
	
	return (assault_text)
end

local HUDAssaultCorner_show_casing = HUDAssaultCorner.show_casing
function HUDAssaultCorner:show_casing(mode)
    if not HMH:GetOption("assault") then return HUDAssaultCorner_show_casing(self, mode) end
	
	local delay_time = self._assault and 1.2 or 0
	self:_end_assault()
	local casing_panel = self._hud_panel:child("casing_panel")
	self:_hide_hostages()
	casing_panel:animate(callback(self, self, "_animate_show_casing"), delay_time)
	self._casing = true
	
	--LDDG Casing text
	local msg = mode == "civilian" and "hud_casing_mode_ticker_clean" or "hud_casing_mode_ticker"
	self:set_text("casing", managers.localization:to_upper_text(msg))
	
end

local HUDAssaultCorner_hide_casing = HUDAssaultCorner.hide_casing
function HUDAssaultCorner:hide_casing()
    if not HMH:GetOption("assault") then return HUDAssaultCorner_hide_casing(self) end

	local icon_casingbox = self._hud_panel:child("casing_panel"):child("icon_casingbox")
	icon_casingbox:stop()
	local function close_done()
		self._hud_panel:child("casing_panel"):animate(callback(nil, _G, "set_alpha"), 0) --LDDG Animation
		local icon_casingbox = self._hud_panel:child("casing_panel"):child("icon_casingbox")
		icon_casingbox:stop()
		icon_casingbox:animate(callback(self, self, "_hide_icon_assaultbox"))		
	end
	self._casing_bg_box:stop()
	self._casing_bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
	self._casing = false
end

local HUDAssaultCorner_animate_show_casing = HUDAssaultCorner._animate_show_casing
function HUDAssaultCorner:_animate_show_casing( casing_panel, delay_time )
    if not HMH:GetOption("assault") then return HUDAssaultCorner_animate_show_casing(self, casing_panel, delay_time) end
	
	set_alpha(casing_panel, 1)--LDDG Animation
end

local HUDAssaultCorner_hide_hostages = HUDAssaultCorner._hide_hostages
function HUDAssaultCorner:_hide_hostages()
    if not HMH:GetOption("assault") then return HUDAssaultCorner_hide_hostages(self) end

	self._hud_panel:child( "hostages_panel" ):animate(callback(nil, _G, "set_alpha"), 0)--LDDG Animation
end

local HUDAssaultCorner_show_hostages = HUDAssaultCorner._show_hostages
function HUDAssaultCorner:_show_hostages()
    if not HMH:GetOption("assault") then return HUDAssaultCorner_show_hostages(self) end

	if not self._point_of_no_return then
		self._hud_panel:child( "hostages_panel" ):animate(callback(nil, _G, "set_alpha"), 1)--LDDG Animation
	end
end

local HUDAssaultCorner_animate_show_noreturn = HUDAssaultCorner._animate_show_noreturn
function HUDAssaultCorner:_animate_show_noreturn(point_of_no_return_panel, delay_time)
    if not HMH:GetOption("assault") then return HUDAssaultCorner_animate_show_noreturn(self, point_of_no_return_panel, delay_time) end
    
	set_alpha(point_of_no_return_panel, 1)--LDDG Animation
end

local HUDAssaultCorner_flash_point_of_no_return_timer = HUDAssaultCorner.flash_point_of_no_return_timer
function HUDAssaultCorner:flash_point_of_no_return_timer( beep )
    if not HMH:GetOption("assault") then return HUDAssaultCorner_flash_point_of_no_return_timer(self, beep) end

	local flash_timer = function (o)
		local t = 0
		while t < 0.5 do
			t = t + coroutine.yield()
			local n = 1 - math.sin( t * 180 )
            o:set_font_size( math.lerp( 24 , (24) * 1.25, n) )
		end
  	end
  	local point_of_no_return_timer = self._noreturn_bg_box:child( "point_of_no_return_timer" )
	self:hide_casing()
	point_of_no_return_timer:animate( flash_timer )
end

local orig = HUDBGBox_create
function HUDBGBox_create(panel, params, config)
    if not HMH:GetOption("assault") then return orig(panel, params, config) end

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