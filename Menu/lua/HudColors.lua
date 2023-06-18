function TweakData:HMM()
    if HMH:GetOption("custom_color") then
        local player1 = HMH:GetColor("Player1")
        local player2 = HMH:GetColor("Player2")
        local player3 = HMH:GetColor("Player3")
        local player4 = HMH:GetColor("Player4")
        local ai = HMH:GetColor("PlayerAi")
        self.chat_colors[1] = player1
        self.chat_colors[2] = player2
        self.chat_colors[3] = player3
        self.chat_colors[4] = player4
        self.chat_colors[5] = ai
        self.system_chat_color = HMH:GetColor("System")

	    self.peer_vector_colors[1] = Vector3(player1:unpack())
        self.peer_vector_colors[2] = Vector3(player2:unpack())
        self.peer_vector_colors[3] = Vector3(player3:unpack())
        self.peer_vector_colors[4] = Vector3(player4:unpack())
        self.peer_vector_colors[5] = Vector3(ai:unpack())

        self.preplanning_peer_colors[1] = player1 -- Host
        self.preplanning_peer_colors[2] = player2 -- Peer 2
        self.preplanning_peer_colors[3] = player3 -- Peer 3
        self.preplanning_peer_colors[4] = player4 -- Peer 4
    end

    if HMH:GetOption("custom_menu_color") then
        self.screen_colors.resource = Color("66ffff")
        self.screen_colors.button_stage_2 = Color("66ffff")
        self.screen_colors.button_stage_3 = Color("ff80df")
        self.screen_colors.item_stage_3 = Color("ff80df")
        self.screen_colors.title = Color("66ff99")
        self.screen_colors.text = Color("66ff99")
        self.screen_colors.risk = Color("ffcc66")
        self.overlay_effects.spectator.color = Color("66ffff")
	    self.screen_colors.crime_spree_risk = Color("ffcc66")
    	self.screen_colors.skirmish_color = Color("ff6666")
	    self.screen_colors.dlc_color = Color("ffcc66")
    	self.screen_colors.community_color = Color("66ffff")
        self.screen_colors.crimenet_lines = Color("ff80df")
    	self.screen_colors.important_1 = Color("ff6666")
		self.screen_colors.friend_color = Color("66ff99")
		self.screen_colors.ghost_color = Color("66ffff")
		self.screen_colors.item_stage_1 = Color("66ffff")
		self.screen_colors.important_2 = Color("ff6666")
		self.screen_colors.dlc_buy_color = Color("ffcc66")
		self.menu.default_font_row_item_color = Color("66ff99")
    end
end
tweak_data:HMM()