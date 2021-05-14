function TweakData:HMM()
    if HMH:GetOption("custom_color") then
        self.chat_colors[1] = BeardLib and hotlinemiamihud.Options:GetValue("Player1") or Color("66ff99")
        self.chat_colors[2] = BeardLib and hotlinemiamihud.Options:GetValue("Player2") or Color("66ffff")
        self.chat_colors[3] = BeardLib and hotlinemiamihud.Options:GetValue("Player3") or Color("ff6666")
        self.chat_colors[4] = BeardLib and hotlinemiamihud.Options:GetValue("Player4") or Color("ffcc66")
        self.chat_colors[5] = BeardLib and hotlinemiamihud.Options:GetValue("PlayerAi") or Color(0.2, 0.8, 1)
        self.system_chat_color = BeardLib and hotlinemiamihud.Options:GetValue("System") or Color("ff80df")

	    self.peer_vector_colors[1] = Vector3(self.chat_colors[1]:unpack())
        self.peer_vector_colors[2] = Vector3(self.chat_colors[2]:unpack())
        self.peer_vector_colors[3] = Vector3(self.chat_colors[3]:unpack())
        self.peer_vector_colors[4] = Vector3(self.chat_colors[4]:unpack())
        self.peer_vector_colors[5] = Vector3(self.chat_colors[5]:unpack())

        self.preplanning_peer_colors = {
            BeardLib and hotlinemiamihud.Options:GetValue("Player1") or Color("66ff99"), --Host.
            BeardLib and hotlinemiamihud.Options:GetValue("Player2") or Color("66ffff"), --Peer2.
            BeardLib and hotlinemiamihud.Options:GetValue("Player3") or Color("ff6666"), --Peer3.
            BeardLib and hotlinemiamihud.Options:GetValue("Player4") or Color("ffcc66")  --Peer4.
        }
    end

    if HMH:GetOption("custom_menu_color") then
        self.screen_colors.resource = Color("66ffff")
        self.screen_colors.button_stage_2 = Color("66ffff")
        self.screen_colors.button_stage_3 = Color("ff80df")
        self.screen_colors.item_stage_3 = Color("ff80df")
        self.screen_colors.title = Color("ff80df")
        self.screen_colors.text = Color("66ff99")
        self.screen_colors.risk = Color("ffcc66")
        self.overlay_effects.spectator.color = Color("66ffff")
	    self.screen_colors.crime_spree_risk = Color("ffcc66")
    	self.screen_colors.skirmish_color = Color("ff6666")
	    self.screen_colors.dlc_color = Color("ffcc66")
    	self.screen_colors.community_color = Color("66ffff")
        self.screen_colors.crimenet_lines = Color("ff80df")
    	self.screen_colors.important_1 = Color("ff6666")
    end
end
tweak_data:HMM()