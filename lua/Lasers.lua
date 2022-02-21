function UnitNetworkHandler:set_weapon_gadget_color(unit, red, green, blue, sender)
	if not self._verify_character_and_sender(unit, sender) then
	    return
	end

    if red and green and blue then 
	    local threshold = 0.66
	    if red * threshold > green + blue then
		    red = 1
		    green = 51
		    blue = 1
	    end
    end
    unit:inventory():sync_weapon_gadget_color(Color(red / 255, green / 255, blue / 255))
end