if string.lower(RequiredScript) == "lib/managers/hudmanagerpd2" then    
	local set_slot_ready_orig = HUDManager.set_slot_ready
	local force_ready_clicked = 0
	
	function HUDManager:set_slot_ready(peer, peer_id, ...)
		set_slot_ready_orig(self, peer, peer_id, ...)
		
		if Network:is_server() and not Global.game_settings.single_player then
			local session = managers.network and managers.network:session()
			local local_peer = session and session:local_peer()
			if local_peer and local_peer:id() == peer_id then
				force_ready_clicked = force_ready_clicked + 1
				if game_state_machine and force_ready_clicked >= 3 then
					game_state_machine:current_state():start_game_intro()
				end
			end
		end
	end
end