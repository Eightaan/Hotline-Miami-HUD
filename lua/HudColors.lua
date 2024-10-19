local HMH = HMH
local Color = Color

function TweakData:HMM()
	if HMH:GetOption("custom_color") then
		for i = 1, 5 do
			local player_color = HMH:GetColor("Player" .. (i <= 4 and i or "Ai"))
			if player_color then
				self.chat_colors[i] = player_color
				self.peer_vector_colors[i] = Vector3(player_color:unpack())
				if i <= 4 then
					self.preplanning_peer_colors[i] = player_color
				end
			end
		end
		self.system_chat_color = HMH:GetColor("System")
	end
	
	self.contour.interactable.standard_color = HMH:GetColor("interactcolor")
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