if not HMH:GetOption("timer") then
    return
end

Hooks:PostHook(HUDHeistTimer, "init", "HMMTimer", function(self, ...)
    self._timer_text:set_color(HMH:GetColor("TimerColor"))
	self._timer_text:set_alpha(HMH:GetOption("TimerAlpha"))
end)