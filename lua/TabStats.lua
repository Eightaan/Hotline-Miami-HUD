if not HMH:GetOption("tab") or (VHUDPlus and VHUDPlus:getSetting({"TabStats", "ENABLED"}, true)) then 
    return
end

if RequiredScript == "lib/managers/hud/newhudstatsscreen" then
	local medium_font = tweak_data.menu.pd2_medium_font
	local tiny_font = tweak_data.menu.pd2_tiny_font
	local medium_font_size = tweak_data.menu.pd2_medium_font_size
	local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

	function HudTrackedAchievement:init(parent, id, black_bg)
		HudTrackedAchievement.super.init(self, parent, {
			border = 10,
			padding = 4,
			fixed_w = parent:w()
		})

		self._info = managers.achievment:get_info(id)
		self._visual = tweak_data.achievement.visual[id]
		self._progress = self._visual and self._visual.progress
		local placer = self:placer()
		local texture, texture_rect = tweak_data.hud_icons:get_icon_or(self._visual.icon_id, "guis/dlcs/unfinished/textures/placeholder")
		local bitmap = placer:add_bottom(self:bitmap({
			w = 50,
			h = 50,
			texture = texture,
			texture_rect = texture_rect
		}))
		local awarded = self._info.awarded

		if not awarded then
			bitmap:set_color(Color.white:with_alpha(0.1))
			self._panel:bitmap({
				texture = "guis/dlcs/trk/textures/pd2/lock",
				color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
				w = bitmap:w(),
				h = bitmap:h(),
				x = bitmap:x(),
				y = bitmap:y()
		    })
	    end

		local title_text = managers.localization:text(self._visual.name_id)
		local desc_text = managers.localization:text(self._visual.desc_id)

		placer:add_right(self:fine_text({
			text = title_text,
			color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
			font = medium_font,
			font_size = medium_font_size
		}))

		local desc = self:text({
			wrap = true,
			word_wrap = true,
			text = desc_text,
			font = tiny_font,
			font_size = tiny_font_size,
			color = tweak_data.screen_colors.achievement_grey,
			w = self:row_w() - placer:current_left()
		})

		self.limit_text_rows(desc, 2)
		placer:add_bottom(self.make_fine_text(desc), 0)

		if self._progress then
			self._bar = placer:add_bottom(TextProgressBar:new(self, {
				w = 300,
				h = 10,
				back_color = Color(255, 60, 60, 65) / 255,
				max = type(self._progress.max) == "function" and self._progress:max() or self._progress.max
			}, {
				font_size = 12,
				font = tiny_font
			}, self._progress:get()))
		end

		if black_bg then
			self:rect({
				layer = -1,
				color = Color.black:with_alpha(0.6)
			})
		end
	end

	function HUDStatsScreen:_trade_delay_time(time)
		time = math.max(math.floor(time), 0)
		local minutes = math.floor(time / 60)
		time = time - minutes * 60
		local seconds = math.round(time)
		local text = ""

		return text .. (minutes < 10 and "0" .. minutes or minutes) .. ":" .. (seconds < 10 and "0" .. seconds or seconds)
	end	

	function HUDStatsScreen:recreate_left()
		self._left:clear()
		self._left:bitmap({
			texture = "guis/textures/test_blur_df",
			layer = -1,
			render_template = "VertexColorTexturedBlur3D",
			valign = "grow",
			w = self._left:w(),
			h = self._left:h()
		})

		local lb = HUDBGBox_create(self._left, {}, {
			blend_mode = "normal",
			color = Color.white
		})

		lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
		lb:child("bg"):set_alpha(1)

		local placer = UiPlacer:new(10, 10, 0, 8)
		local job_data = managers.job:current_job_data()
		local stage_data = managers.job:current_stage_data()

		if job_data and managers.job:current_job_id() == "safehouse" and Global.mission_manager.saved_job_values.playedSafeHouseBefore then
			self._left:set_visible(false)
			return
		end

		local is_whisper_mode = managers.groupai and managers.groupai:state():whisper_mode()

		if stage_data then
			if managers.crime_spree:is_active() then
				local level_data = managers.job:current_level_data()
				local mission = managers.crime_spree:get_mission(managers.crime_spree:current_played_mission())

				if mission then
					local level_str = managers.localization:to_upper_text(tweak_data.levels[mission.level.level_id].name_id) or ""

					placer:add_bottom(self._left:fine_text({
						font = tweak_data.hud_stats.objectives_font,
						font_size = tweak_data.hud_stats.objectives_title_size,
						color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
						text = level_str
					}))
				end
    	        placer:new_row(8)

				placer:add_bottom(self._left:fine_text({
					font = medium_font,
					font_size = tweak_data.hud_stats.loot_size,
					text = managers.localization:to_upper_text("menu_lobby_difficulty_title"),
					color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
				}), 16)

				local str = managers.localization:text("menu_cs_level", {
					level = managers.experience:cash_string(managers.crime_spree:server_spree_level(), "")
				})

				placer:add_right(self._left:fine_text({
					font = medium_font,
					font_size = tweak_data.hud_stats.loot_size,
					text = str,
					color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color(255, 255, 255, 0) / 255
				}))

				placer:new_row(8, 0)

				local civ_kills = managers.statistics:session_total_civilian_kills() ~= 0 and managers.localization:to_upper_text("victory_civilians_killed_penalty") .. " " .. managers.statistics:session_total_civilian_kills() .. managers.localization:get_default_macro("BTN_SKULL") or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
					text = civ_kills
				}), 6)

		    	local trade_delay = (5 + (HMH.CivKill * 30))
                local total_time = trade_delay and trade_delay > 30					
				local delay = total_time and managers.localization:to_upper_text("hud_trade_delay", {TIME = tostring(self:_trade_delay_time(trade_delay))}) or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
					text = delay
				}), 0)

				local total_kills = HMH.TotalKills
				local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills .. managers.localization:get_default_macro("BTN_SKULL") or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
					text = kill_count
				}), 16)

				local total_accuracy = managers.statistics:session_hit_accuracy()
				local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
					text = accuracy 
				}), 0)

				local max_units = managers.gage_assignment:count_all_units()
                local remaining = managers.gage_assignment:count_active_units()
				local package_text = managers.job:current_level_id() ~= "chill_combat" and managers.job:current_level_id() ~= "chill" and managers.job:current_level_id() ~= "haunted" and managers.job:current_level_id() ~= "hvh" and managers.localization:to_upper_text("menu_asset_gage_assignment") .. ":" .. " " .. tostring(max_units - remaining) .."/".. tostring(max_units) or ""
				if remaining < max_units then
				    placer:add_bottom(self._left:fine_text({
				     	keep_w = true,
				    	font = tweak_data.hud_stats.objectives_font,
				    	font_size = tweak_data.hud_stats.loot_size,
				    	color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
				    	text = package_text
				    }), 16)
				end

		        local dominated = 0
				local enemy_count = 0
		        for _, unit in pairs(managers.enemy:all_enemies()) do
				    enemy_count = enemy_count + 1
			        if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
				        dominated = dominated + 1
			        end
		        end

				local enemies = enemy_count - dominated
				if HMH:GetOption("enemy_count") and enemies > 0 then
				    placer:add_bottom(self._left:fine_text({
					    keep_w = true,
					    font = tweak_data.hud_stats.objectives_font,
					    font_size = tweak_data.hud_stats.loot_size,
					    color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
					    text = managers.localization:to_upper_text("menu_mutators_category_enemies") .. ": " .. enemies
				    }), 16)
                end
			else
				local job_chain = managers.job:current_job_chain_data()
				local day = managers.job:current_stage()
				local days = job_chain and #job_chain or 0
				local level_data = managers.job:current_level_data()
				local space
				local heist_title
	            if level_data then
	                heist_title = managers.localization:to_upper_text(level_data.name_id) .. ":"
					space = string.rep(" ", 2)
	            else
 	               heist_title = ""
 	               space = ""
 	           end				

				local day_title = placer:add_bottom(self._left:fine_text({
					font = tweak_data.hud_stats.objectives_font,
					font_size = 30,
					color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
					text = heist_title .. space .. managers.localization:to_upper_text("hud_days_title", {
						DAY = day,
						DAYS = days
					})
				}))

				if managers.job:is_level_ghostable(managers.job:current_level_id()) then
				    local ghost_color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color(255, 59, 174, 254) / 255
					local loud_color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color(255, 255, 51, 51) / 255
					local ghost_color = is_whisper_mode and ghost_color or loud_color
					local ghost = placer:add_right(self._left:bitmap({
						texture = "guis/textures/pd2/cn_minighost",
						name = "ghost_icon",
						h = 16,
						blend_mode = "add",
						w = 16,
						color = ghost_color
					}))
					ghost:set_center_y(day_title:center_y())
				end

				placer:new_row(8)

				placer:add_bottom(self._left:fine_text({
					font = medium_font,
					font_size = tweak_data.hud_stats.loot_size,
					text = managers.localization:to_upper_text("menu_lobby_difficulty_title"),
					color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white
				}), 16)

				if job_data then
					local job_stars = managers.job:current_job_stars()
					local difficulty_stars = managers.job:current_difficulty_stars()
					local difficulty = tweak_data.difficulties[difficulty_stars + 2] or 1
					local difficulty_string = managers.localization:to_upper_text(tweak_data.difficulty_name_ids[difficulty])
					local risk_color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color(255, 255, 204, 0) / 255
					local normal_color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white
					local difficulty_text = self._left:fine_text({
						font = medium_font,
						font_size = tweak_data.hud_stats.loot_size,
						text = difficulty_string,
						color = difficulty_stars > 0 and risk_color or normal_color
					})

					if Global.game_settings.one_down then
						local one_down_string = managers.localization:to_upper_text("menu_one_down")

						difficulty_text:set_text(difficulty_string .. " " .. one_down_string)
						difficulty_text:set_range_color(#difficulty_string + 1, math.huge, tweak_data.screen_colors.one_down)
					end

					local _, _, tw, th = difficulty_text:text_rect()

					difficulty_text:set_size(tw, th)
					placer:add_right(difficulty_text)
				end

				placer:new_row(8, 0)

				local payout = managers.localization:text("hud_day_payout", {
					MONEY = managers.experience:cash_string(managers.money:get_potential_payout_from_current_stage())
				})

				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
					font_size = tweak_data.hud_stats.loot_size,
					text = payout
				}), 0)

				local civ_kills = managers.statistics:session_total_civilian_kills() ~= 0 and managers.localization:to_upper_text("victory_civilians_killed_penalty") .. " " .. managers.statistics:session_total_civilian_kills() .. managers.localization:get_default_macro("BTN_SKULL") or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
					text = civ_kills
				}), 6)

		    	local trade_delay = (5 + (HMH.CivKill * 30))
                local total_time = trade_delay and trade_delay > 30			
				local delay = total_time and managers.localization:to_upper_text("hud_trade_delay", {TIME = tostring(self:_trade_delay_time(trade_delay))}) or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
					text = delay
				}), 0)

				local total_kills = HMH.TotalKills
				local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills .. managers.localization:get_default_macro("BTN_SKULL") or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
					text = kill_count
				}), 16)

				local total_accuracy = managers.statistics:session_hit_accuracy()
				local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
				placer:add_bottom(self._left:fine_text({
					keep_w = true,
					font = tweak_data.hud_stats.objectives_font,
					font_size = tweak_data.hud_stats.loot_size,
					color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
					text = accuracy 
				}), 0)

				local max_units = managers.gage_assignment:count_all_units()
                local remaining = managers.gage_assignment:count_active_units()
				local package_text = managers.job:current_level_id() ~= "chill_combat" and managers.job:current_level_id() ~= "chill" and managers.job:current_level_id() ~= "haunted" and managers.job:current_level_id() ~= "hvh" and managers.localization:to_upper_text("menu_asset_gage_assignment") .. ":" .. " " .. tostring(max_units - remaining) .."/".. tostring(max_units) or ""
				if remaining < max_units then
				    placer:add_bottom(self._left:fine_text({
				     	keep_w = true,
				    	font = tweak_data.hud_stats.objectives_font,
				    	font_size = tweak_data.hud_stats.loot_size,
				    	color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
				    	text = package_text
				    }), 16)
				end

		        local dominated = 0
				local enemy_count = 0
		        for _, unit in pairs(managers.enemy:all_enemies()) do
				    enemy_count = enemy_count + 1
			        if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
				        dominated = dominated + 1
			        end
		        end

				local enemies = enemy_count - dominated
				if HMH:GetOption("enemy_count") and enemies > 0 then
				    placer:add_bottom(self._left:fine_text({
					    keep_w = true,
					    font = tweak_data.hud_stats.objectives_font,
					    font_size = tweak_data.hud_stats.loot_size,
					    color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
					    text = managers.localization:to_upper_text("menu_mutators_category_enemies") .. ": " .. enemies
				    }), 16)
                end
			end

			placer:new_row()
		end

		local loot_panel = ExtendedPanel:new(self._left, {
			w = self._left:w() - 16 - 8
		})
		placer = UiPlacer:new(16, 0, 8, 4)

		if not is_whisper_mode and managers.player:has_category_upgrade("player", "convert_enemies") then
			local dominated = 0
		    for _, unit in pairs(managers.enemy:all_enemies()) do
			    if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
				    dominated = dominated + 1
			    end
		    end
	        local dominated_text = placer:add_bottom(loot_panel:fine_text({
			    keep_w = true,
			    text = managers.localization:text("hmh_hud_stats_enemies_dominated"),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)
			local dominated_texture = "guis/textures/pd2/skilltree/icons_atlas"
			local dominated_rect = {128,512,64,64}
			local dominated_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				texture = dominated_texture,
				texture_rect = dominated_rect
			}))

			dominated_icon:set_center_y(dominated_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(dominated),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			placer:new_row()

			local minion_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_enemies_converted"),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)

			local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
			local minion_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				texture = minion_texture,
				texture_rect = minion_rect
			}))

			minion_icon:set_center_y(minion_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:num_local_minions()),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			if managers.crime_spree:is_active() then
			    loot_panel:set_size(placer:most_rightbottom())
			    loot_panel:set_leftbottom(0, self._left:h() - 16)
			end
			placer:new_row()
		end

		if is_whisper_mode then
			local pagers_used = managers.groupai:state():get_nr_successful_alarm_pager_bluffs()
			local max_pagers_data = managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff") and tweak_data.player.alarm_pager.bluff_success_chance_w_skill or tweak_data.player.alarm_pager.bluff_success_chance
			local max_num_pagers = #max_pagers_data

			for i, chance in ipairs(max_pagers_data) do
				if chance == 0 then
					max_num_pagers = i - 1
					break
				end
			end

			local pagers_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_pagers_used"),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)

			local pagers_texture, pagers_rect = tweak_data.hud_icons:get_icon_data("pagers_used")
			local pagers_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				texture = pagers_texture,
				texture_rect = pagers_rect
			}))

			pagers_icon:set_center_y(pagers_text:center_y())
			placer:add_left(loot_panel:fine_text({
				text = tostring(pagers_used) .. "/" .. tostring(max_num_pagers),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}), 7)
			placer:new_row()

			local body_text = placer:add_bottom(loot_panel:fine_text({
		 	    keep_w = true,
		 	    text = managers.localization:to_upper_text("hud_body_bags"),
			    color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
		 	    font = medium_font,
			    font_size = medium_font_size
	   		}))

	   	 	placer:add_right(nil, 0)

			local body_texture, body_rect = tweak_data.hud_icons:get_icon_data("equipment_body_bag")
			local body_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
				texture = body_texture,
				texture_rect = body_rect
			}))
			body_icon:set_center_y(body_text:center_y())

			placer:add_left(loot_panel:fine_text({
				text = tostring(managers.player:get_body_bags_amount()),
				font = medium_font,
				color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
				font_size = medium_font_size
			}), 7)
			if managers.crime_spree:is_active() then
			    loot_panel:set_size(placer:most_rightbottom())
			    loot_panel:set_leftbottom(0, self._left:h() - 16)
			end
			placer:new_row()
		end

		if not managers.crime_spree:is_active() then
			local mandatory_bags_data = managers.loot:get_mandatory_bags_data()
			local mandatory_amount = mandatory_bags_data and mandatory_bags_data.amount
			local secured_amount = managers.loot:get_secured_mandatory_bags_amount()
			local bonus_amount = managers.loot:get_secured_bonus_bags_amount()
			local bag_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_bags_secured"),
				font = medium_font,
				color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)

			local bag_texture, bag_rect = tweak_data.hud_icons:get_icon_data("bag_icon")
			local bag_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 16,
				h = 16,
				color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
				texture = bag_texture,
				texture_rect = bag_rect
			}))
			bag_icon:set_center_y(bag_text:center_y())

			if mandatory_amount and mandatory_amount > 0 then
				local str = bonus_amount > 0 and string.format("%d/%d+%d", secured_amount, mandatory_amount, bonus_amount) or string.format("%d/%d", secured_amount, mandatory_amount)

				placer:add_left(loot_panel:fine_text({
					text = str,
					font = medium_font,
					color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
					font_size = medium_font_size
				}))
			else
				placer:add_left(loot_panel:fine_text({
					text = tostring(bonus_amount),
					font = medium_font,
					color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
					font_size = medium_font_size
				}))
			end
			placer:new_row()
		end
       
	    if managers.money and managers.statistics and managers.experience and not managers.crime_spree:is_active() then 
       	    local money_current_stage = managers.money:get_potential_payout_from_current_stage() or 0
			local offshore_rate = managers.money:get_tweak_value("money_manager", "offshore_rate") or 0
			local offshore_total = money_current_stage - math.round(money_current_stage * offshore_rate)
			local offshore_text = managers.experience:cash_string(offshore_total)
			local civilian_kills = managers.statistics:session_total_civilian_kills() or 0
			local cleaner_costs	= (managers.money:get_civilian_deduction() or 0) * civilian_kills
			local spending_cash = money_current_stage * offshore_rate - cleaner_costs
			local spending_cash_text = managers.experience:cash_string(spending_cash)

			placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("menu_cash_spending"),
				font = medium_font,
				color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
				font_size = medium_font_size
			}), 12)

			placer:add_right(nil, 0)

			placer:add_left(loot_panel:fine_text({
				text = spending_cash_text,
				font = medium_font,
				color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
				font_size = medium_font_size
			}))
			placer:new_row()

			placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:to_upper_text("hud_offshore_account"),
				font = medium_font,
				color = HMH:GetOption("custom_tab_color") and Color("ff80df") or Color.white,
				font_size = medium_font_size
			}))
			placer:add_right(nil, 0)
			placer:add_left(loot_panel:fine_text({
				text = offshore_text,
				color = HMH:GetOption("custom_tab_color") and Color("ff80df") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))
			loot_panel:set_size(placer:most_rightbottom())
			loot_panel:set_leftbottom(0, self._left:h() - 16)
		end
	end

    local HUDStatsScreen_recreate_right = HUDStatsScreen.recreate_right
	function HUDStatsScreen:recreate_right(...)
		if _G.LobbyPlayerInfo and LobbyPlayerInfo.settings.show_skills_in_stats_screen then
            return HUDStatsScreen_recreate_right(self, ...) -- LobbyPlayerInfo compatability
		end
	
		if self._destroy_player_info then -- Enhanced Crew Loadout compatability
			self:_destroy_player_info()
		end

	    self._right:clear()
	    self._right:bitmap({
		    texture = "guis/textures/test_blur_df",
		    layer = -1,
		    render_template = "VertexColorTexturedBlur3D",
		    valign = "grow",
		    w = self._right:w(),
		    h = self._right:h()
	    })

	    local rb = HUDBGBox_create(self._right, {}, {
		    blend_mode = "normal",
		    color = Color.white
	    })

	    rb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
	    rb:child("bg"):set_alpha(1)

	    if managers.mutators:are_mutators_active() then
		    self:_create_mutators_list(self._right)
	    else
		    self:_create_tracked_list(self._right)
	    end

    	local track_text = self._right:fine_text({
	    	text = managers.localization:to_upper_text("menu_es_playing_track") .. " " .. managers.music:current_track_string(),
		    font_size = tweak_data.menu.pd2_small_font_size,
		    font = medium_font,
		    color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white
	    })

	    track_text:set_leftbottom(10, self._right:h() - 10)

	    if self._create_player_info then -- Enhanced Crew Loadout compatability
		    self:_create_player_info()
	    end
    end

	function HUDStatsScreen:_create_tracked_list(panel)
		local placer = UiPlacer:new(10, 10, 0, 8)

		placer:add_bottom(self._right:fine_text({
			text_id = "hud_stats_tracked",
			color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
			font = medium_font,
			font_size = tweak_data.hud_stats.objectives_title_size
		}))

		local tracked = managers.achievment:get_tracked_fill()

		if #tracked == 0 then
			placer:add_bottom(self._right:fine_text({
				wrap = true,
				word_wrap = true,
				text_id = "hud_stats_no_tracked",
				color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
				font = medium_font,
				font_size = medium_font_size,
				w = self._right:w() - placer:current_left() * 2
			}))
		end

		self._tracked_items = {}
		local placer = UiPlacer:new(0, placer:most().bottom, 0, 0)
		local with_bg = true

		for _, id in pairs(tracked) do
			local t = placer:add_row(HudTrackedAchievement:new(self._right, id, with_bg), 0, 0)

			if t._progress and t._progress.update and table.contains({
				"realtime",
				"second"
			}, t._progress.update) then
				table.insert(self._tracked_items, t)
			end

			with_bg = not with_bg
		end
	end

	function HUDStatsScreen:_create_mutators_list(panel)
		local placer = UiPlacer:new(10, 10)

		placer:add_bottom(self._right:fine_text({
			text = managers.localization:to_upper_text("menu_mutators"),
			color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
			font = medium_font,
			font_size = tweak_data.hud_stats.objectives_title_size
		}))

		for i, active_mutator in ipairs(managers.mutators:active_mutators()) do
			placer:add_row(self._right:fine_text({
				text = active_mutator.mutator:name(),
				color = HMH:GetOption("custom_tab_color") and Color("66ffff") or Color.white,
				font = tweak_data.hud_stats.objectives_font,
				font_size = tweak_data.hud_stats.day_description_size
			}), 8, 2)
		end
    end

elseif RequiredScript == "lib/managers/hud/hudstatsscreenskirmish" then
    local medium_font = tweak_data.menu.pd2_medium_font
    local medium_font_size = tweak_data.menu.pd2_medium_font_size

    function HUDStatsScreenSkirmish:recreate_left()
	    self._left:clear()
	    self._left:bitmap({
			texture = "guis/textures/test_blur_df",
			layer = -1,
			render_template = "VertexColorTexturedBlur3D",
			valign = "grow",
			w = self._left:w(),
			h = self._left:h()
		})

		local lb = HUDBGBox_create(self._left, {}, {
			blend_mode = "normal",
			color = Color.white
		})

		lb:child("bg"):set_color(Color(0, 0, 0):with_alpha(0.75))
		lb:child("bg"):set_alpha(1)

		local placer = UiPlacer:new(10, 10, 0, 8)

		local level_data = managers.job:current_level_data()

		if level_data then
			placer:add_bottom(self._left:fine_text({
				text = managers.localization:to_upper_text(level_data.name_id),
				color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
				font = medium_font,
				font_size = tweak_data.hud_stats.objectives_title_size
			}))
			placer:new_row()
		end

		placer:new_row(8)

		local total_kills = HMH.TotalKills
		local kill_count = total_kills and managers.localization:to_upper_text("menu_aru_job_3_obj") ..": ".. total_kills ..managers.localization:get_default_macro("BTN_SKULL") or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = tweak_data.hud_stats.loot_size,
			color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
			text = kill_count
		}), 16)

		local total_accuracy = managers.statistics:session_hit_accuracy()
		local accuracy = total_accuracy and managers.localization:to_upper_text("menu_stats_hit_accuracy") .." ".. total_accuracy.."%" or ""
		placer:add_bottom(self._left:fine_text({
			keep_w = true,
			font = tweak_data.hud_stats.objectives_font,
			font_size = tweak_data.hud_stats.loot_size,
			color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
			text = accuracy 
		}), 0)

		local dominated = 0
		local enemy_count = 0
		for _, unit in pairs(managers.enemy:all_enemies()) do
		    enemy_count = enemy_count + 1
		    if (unit and unit.unit and alive(unit.unit)) and (unit.unit:anim_data() and unit.unit:anim_data().hands_up or unit.unit:anim_data() and unit.unit:anim_data().surrender or unit.unit:base() and unit.unit:base().mic_is_being_moved)then
				dominated = dominated + 1
			end
		end

		local enemies = enemy_count - dominated
		if HMH:GetOption("enemy_count") and enemies > 0 then
			placer:add_bottom(self._left:fine_text({
				keep_w = true,
				font = tweak_data.hud_stats.objectives_font,
				font_size = tweak_data.hud_stats.loot_size,
			    color = HMH:GetOption("custom_tab_color") and Color("ff6666") or Color.white,
				text = managers.localization:to_upper_text("menu_mutators_category_enemies") .. ": " .. enemies
	        }), 16)
        end

		placer:new_row(8, 0)

		local loot_panel = ExtendedPanel:new(self._left, {
			w = self._left:w() - 16 - 8
		})
		placer = UiPlacer:new(16, 0, 8, 4)

		if managers.player:has_category_upgrade("player", "convert_enemies") then
			local minion_text = placer:add_bottom(loot_panel:fine_text({
				keep_w = true,
				text = managers.localization:text("hud_stats_enemies_converted"),
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				font = medium_font,
				font_size = medium_font_size
			}))

			placer:add_right(nil, 0)

			local minion_texture, minion_rect = tweak_data.hud_icons:get_icon_data("minions_converted")
			local minion_icon = placer:add_left(loot_panel:fit_bitmap({
				w = 17,
				h = 17,
				color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
				texture = minion_texture,
				texture_rect = minion_rect
			}))
	 	    minion_icon:set_center_y(minion_text:center_y())

	 	   	placer:add_left(loot_panel:fine_text({
			    text = tostring(managers.player:num_local_minions()),
		    	color = HMH:GetOption("custom_tab_color") and Color("ffcc66") or Color.white,
			    font = medium_font,
			    font_size = medium_font_size
		    }), 7)
		    placer:new_row()
	    end

	    placer:add_bottom(loot_panel:fine_text({
		    keep_w = true,
		    text = managers.localization:to_upper_text("hud_skirmish_ransom"),
		    color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
		    font = medium_font,
		    font_size = medium_font_size
	    }))

	    local ransom_amount = managers.skirmish:current_ransom_amount()

	    placer:add_right(nil, 0)

	    placer:add_left(loot_panel:fine_text({
		    text = managers.experience:cash_string(ransom_amount),
		    color = HMH:GetOption("custom_tab_color") and Color("66ff99") or Color.white,
		    font = medium_font,
		    font_size = medium_font_size
	    }))
	    loot_panel:set_size(placer:most_rightbottom())
	    loot_panel:set_leftbottom(0, self._left:h() - 16)
    end
end