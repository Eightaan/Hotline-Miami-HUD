Hooks:PostHook(HUDHeistTimer, "init", "HMMTimer", function(self, ...)
    if HMH:GetOption("timer") then
        self._timer_text:set_color(BeardLib and hotlinemiamihud and hotlinemiamihud.Options:GetValue("Timer") or Color("66ffff"))
	end
end)