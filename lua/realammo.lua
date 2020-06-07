local set_teammate_ammo_amount_orig = HUDManager.set_teammate_ammo_amount

function HUDManager:set_teammate_ammo_amount(id, selection_index, max_clip, current_clip, current_left, max, ...)
	if HMH:GetOption("trueammo") then
		local total_left = current_left - current_clip
		if total_left >= 0 then
			current_left = total_left
			max = max - current_clip
		end
	end
	return set_teammate_ammo_amount_orig(self, id, selection_index, max_clip, current_clip, current_left, max, ...)
end