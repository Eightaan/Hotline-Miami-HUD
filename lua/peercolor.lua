function TweakData:HMM()
    if HMH:GetOption("custom_color") then
        self.chat_colors[1] = HMH.Green
        self.chat_colors[2] = HMH.Blue
        self.chat_colors[3] = HMH.Red
        self.chat_colors[4] = HMH.Yellow
        self.chat_colors[5] = Color(0.2, 0.8, 1)
        self.system_chat_color = HMH.Pink

	    self.peer_vector_colors[1] = Vector3(self.chat_colors[1]:unpack())
        self.peer_vector_colors[2] = Vector3(self.chat_colors[2]:unpack())
        self.peer_vector_colors[3] = Vector3(self.chat_colors[3]:unpack())
        self.peer_vector_colors[4] = Vector3(self.chat_colors[4]:unpack())
        self.peer_vector_colors[5] = Vector3(self.chat_colors[5]:unpack())

        self.preplanning_peer_colors = {
            HMH.Green, --Host.
            HMH.Blue, --Peer2.
            HMH.Red, --Peer3.
            HMH.Yellow  --Peer4.
        }
    end

    if HMH:GetOption("custom_menu_color") then
        self.screen_colors.resource = HMH.Blue
        self.screen_colors.button_stage_2 = HMH.Blue
        self.screen_colors.button_stage_3 = HMH.Pink
        self.screen_colors.item_stage_3 = HMH.Pink
        self.screen_colors.title = HMH.Pink
        self.screen_colors.text = HMH.Green
        self.screen_colors.risk = HMH.Yellow
        self.overlay_effects.spectator.color = HMH.Blue
	    self.screen_colors.crime_spree_risk = HMH.Yellow
    	self.screen_colors.skirmish_color = HMH.Red
	    self.screen_colors.dlc_color = HMH.Pink
    	self.screen_colors.community_color = HMH.Blue
        self.screen_colors.crimenet_lines = HMH.Pink
    	self.screen_colors.important_1 = HMH.Red
    end
end
tweak_data:HMM()