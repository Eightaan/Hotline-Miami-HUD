if WolfHUD and WolfHUD:getSetting({"CustomHUD", "ENABLED"}, true) then return end

if RequiredScript == "lib/managers/hudmanagerpd2" then
    function HUDManager:set_bulletstorm( state )
	    self._teammate_panels[ HUDManager.PLAYER_PANEL ]:_set_bulletstorm( state )
    end

elseif RequiredScript == "lib/managers/hud/hudteammate" then

    local init_original = HUDTeammate.init
    local set_ammo_amount_by_type_original = HUDTeammate.set_ammo_amount_by_type

    function HUDTeammate:init(...)
        init_original(self, ...)
	    if self._main_player then
	        self:inject_ammo_glow()
	    end
    end

    function HUDTeammate:inject_ammo_glow()
	    self._primary_ammo = self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):bitmap({
		    align           = "center",
		    w 				= 50,
		    h 				= 45,
		    name 			= "primary_ammo",
	    	visible 		= false,
    		texture 		= "guis/textures/pd2/crimenet_marker_glow",
	    	color 			= Color("00AAFF"),
    		layer 			= 2,
	    	blend_mode 		= "add"
    	})
	    self._secondary_ammo = self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):bitmap({
    		align           = "center",
    		w 				= 50,
	    	h 				= 45,
    		name 			= "secondary_ammo",
    		visible 		= false,
    		texture 		= "guis/textures/pd2/crimenet_marker_glow",
    		color 			= Color("00AAFF"),
    		layer 			= 2,
	    	blend_mode 		= "add"
	    })
	    self._primary_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
	    self._secondary_ammo:set_center_y(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):y() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):h() / 2 - 2)
        self._primary_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("primary_weapon_panel"):child("ammo_clip"):w() / 2)
	    self._secondary_ammo:set_center_x(self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):x() + self._player_panel:child("weapons_panel"):child("secondary_weapon_panel"):child("ammo_clip"):w() / 2)
    end

    function HUDTeammate:set_ammo_amount_by_type(type, ...)
    	set_ammo_amount_by_type_original(self, type, ...)

    	local weapon_panel = self._player_panel:child( "weapons_panel" ):child( type .. "_weapon_panel" )
	    local ammo_clip = weapon_panel:child( "ammo_clip" )
	
    	if self._main_player and self._bullet_storm then
	        ammo_clip:set_color(Color.white)
	    	ammo_clip:set_text( "8" )
    		ammo_clip:set_rotation( 90 )
    		ammo_clip:set_font_size(30)
    	else
    		ammo_clip:set_rotation( 0 )
    	end
    end

    function HUDTeammate:_set_bulletstorm( state )
		if not HMH:GetOption("bulletstorm") then return end
	    self._bullet_storm = state

        if state then   
		    local pweapon_panel = self._player_panel:child( "weapons_panel" ):child( "primary_weapon_panel" )
		    local pammo_clip = pweapon_panel:child( "ammo_clip" )
	    	local sweapon_panel = self._player_panel:child( "weapons_panel" ):child( "secondary_weapon_panel" )
	    	local sammo_clip = sweapon_panel:child( "ammo_clip" )

	    	self._primary_ammo:set_visible(true)
    		self._secondary_ammo:set_visible(true)
	    	self._secondary_ammo:animate( callback( self, self, "_animate_glow" ) )
    		self._primary_ammo:animate( callback( self , self , "_animate_glow" ) )

    		pammo_clip:set_color(Color.white)
    		pammo_clip:set_text( "8" )
    		pammo_clip:set_rotation( 90 )
    		pammo_clip:set_font_size(30)

	    	sammo_clip:set_font_size(30)
	    	sammo_clip:set_color(Color.white)
	    	sammo_clip:set_text( "8" )
	    	sammo_clip:set_rotation( 90 )
        else
            self._primary_ammo:set_visible(false)
	    	self._secondary_ammo:set_visible(false)
	    end
    end

    function HUDTeammate:_animate_glow( glow )
	    local t = 0
	    while true do
	    	t = t + coroutine.yield()
	    	glow:set_alpha( ( math.abs( math.sin( ( 4 + t ) * 360 * 4 / 4 ) ) ) )
	    end
    end

elseif RequiredScript == "lib/managers/playermanager" then
    local add_to_temporary_property_original = PlayerManager.add_to_temporary_property

    function PlayerManager:_clbk_bulletstorm_expire()
    	self._bullet_storm_clbk = nil
    	managers.hud:set_bulletstorm( false )

    	if managers.player and managers.player:player_unit() and managers.player:player_unit():inventory() then
    		for id , weapon in pairs( managers.player:player_unit():inventory():available_selections() ) do
	    		managers.hud:set_ammo_amount( id , weapon.unit:base():ammo_info() )
	    	end
	    end
    end

    function PlayerManager:add_to_temporary_property(name, time, value, ...)
        add_to_temporary_property_original(self, name, time, value, ...)

	    if name == "bullet_storm" and time then
		    if not self._bullet_storm_clbk then
			    self._bullet_storm_clbk = "infinite"
			    managers.hud:set_bulletstorm( true )
			    managers.enemy:add_delayed_clbk( self._bullet_storm_clbk , callback( self , self , "_clbk_bulletstorm_expire" ) , TimerManager:game():time() + time )
		    end
	    end
    end
end
