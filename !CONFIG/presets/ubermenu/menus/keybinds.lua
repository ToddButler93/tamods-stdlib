local current_gamma = 2.2
local gamma_low = false
function gamma_plus()
	current_gamma = current_gamma + 0.1
	gamma(current_gamma)
end
function gamma_minus()
	current_gamma = current_gamma - 0.1
	gamma(current_gamma)
end
function gamma_toggle()
	current_gamma = gamma_low and current_gamma + 1.2 or current_gamma - 1.2
	gamma_low = not gamma_low
	gamma(current_gamma)
end

local current_route = 0
function next_route()
	local count = route.getTeam()

	if count < 1 then
		notify("TAMods error", "No routes for this side found")
		return
	end

	if current_route < count then
		current_route = current_route + 1
	else
		current_route = 1
	end

	route.load(current_route)
end
function prev_route()
	local count = route.getTeam()

	if count < 1 then
		notify("TAMods error", "No routes for this side found")
		return
	end

	if current_route > count or current_route <= 1 then
		current_route = count
	else
		current_route = current_route - 1
	end

	route.load(current_route)
end
function play_random_enemy_route()
	local count = route.getEnemy()

	if count > 0 then
		local rand = math.random(count)
		route.enableBot(true)
		returnFlags()
		route.load(rand)
		route.replayStart(0.0)
	else
		notify("TAMods error", "No enemy routes found")
	end
end

local onInputEventOld
if type(onInputEvent) == "function" then
	onInputEventOld = onInputEvent
end

local instigator_released = false
function onInputEvent(key, event)
	if onInputEventOld then onInputEventOld(key, event) end

	if not ubermenu.keyprompt then return end

	if event == Input.RELEASED then
		if not instigator_released then
			instigator_released = true
			return
		end

		-- get exactly one keypress
		ubermenu.keyprompt = false
		instigator_released = false

		-- escape cancels without doing anything
		if key == "Escape" then return end

		-- is key already bound?
		for k,v in pairs(ubermenu.opts) do
			if k:match("^key_") then
				if key == v then
					-- key is already bound, notify the user
					local title = ubermenu.title or "Menu"
					notify(title, "Key " .. key .. " is already bound to " .. k)
					return
				end
			end
		end

		-- get current menu items key
		local m = ubermenu.current_submenu
		local selected = m:get_selected_item()
		local oldkey = m:get_var(selected.varname)

		if key == "Backspace" then key = "" end

		-- check if we bind the same key again
		if oldkey == key then
			return
		end

		-- unbind old key and bind new key
		if (oldkey and oldkey ~= "") then unbindKey(oldkey, Input.PRESSED) end

		if selected.dorepeat then
			if (oldkey and oldkey ~= "") then unbindKey(oldkey, Input.REPEAT) end
			if key ~= "" then bindKey(key, Input.REPEAT, selected.call) end
		end
		if key ~= "" then bindKey(key, Input.PRESSED, selected.call) end
		m:set_var(selected.varname, key)
	end
end

local sub = ubermenu:add_submenu({ title = "Keybinds" })
	sub:add_item({ title = "Help", description = "While binding a key, you can press ESCAPE to cancel\nor press BACKSPACE to unbind." })
	sub:add_separator({ title = "Gamma" })
	sub:add_keybind({ title = "Increase Gamma", varname =
	"ubermenu.opts.key_gamma_increase", default = ubermenu.opts.key_gamma_increase or "", dorepeat = true, call = function() gamma_plus() end })
	sub:add_keybind({ title = "Decrease Gamma", varname = "ubermenu.opts.key_gamma_decrease", default = ubermenu.opts.key_gamma_decrease or "", dorepeat = true, call = function() gamma_minus() end })
	sub:add_keybind({ title = "Toggle Gamma",   varname = "ubermenu.opts.key_gamma_toggle",   default = ubermenu.opts.key_gamma_toggle or "",   dorepeat = false, call = function() gamma_toggle() end })

	sub:add_separator({ title = "Stopwatch" })
	sub:add_keybind({ title = "Start Stopwatch",  varname = "ubermenu.opts.key_stopwatch_start",  default = ubermenu.opts.key_stopwatch_start or "",        dorepeat = false, call = function() stopwatch.start() end })
	sub:add_keybind({ title = "Stop Stopwatch",   varname = "ubermenu.opts.key_stopwatch_stop",   default = ubermenu.opts.key_stopwatch_stop or "",         dorepeat = false, call = function() stopwatch.stop() end })
	sub:add_keybind({ title = "Toggle Stopwatch", varname = "ubermenu.opts.key_stopwatch_toggle", default = ubermenu.opts.key_stopwatch_toggle or "Insert", dorepeat = false, call = function() stopwatch.toggle() end })

	sub:add_separator({ title = "Route Recording" })
	sub:add_keybind({ title = "Start Recording",  varname = "ubermenu.opts.key_route_startrec",   default = ubermenu.opts.key_route_startrec or "Home", dorepeat = false, call = function() route.recStart() end })
	sub:add_keybind({ title = "Stop Recording",   varname = "ubermenu.opts.key_route_stoprec",    default = ubermenu.opts.key_route_stoprec or "End",   dorepeat = false, call = function() route.recStop() end })
	sub:add_keybind({ title = "Toggle Recording", varname = "ubermenu.opts.key_route_togglerec",  default = ubermenu.opts.key_route_togglerec or "",    dorepeat = false, call = function() route.rec() end })
	sub:add_keybind({ title = "Save Recording",   varname = "ubermenu.opts.key_route_saverec",    default = ubermenu.opts.key_route_saverec or "",      dorepeat = false, call = function() openConsole("/routesave YOUR_DESCRIPTION_HERE") end })

	sub:add_separator({ title = "Route Playback" })
	sub:add_keybind({ title = "Start Playback",          varname = "ubermenu.opts.key_route_play",       default = ubermenu.opts.key_route_play or "",             dorepeat = false, call = function() route.replayStart(0.0) end })
	sub:add_keybind({ title = "Stop Playback",           varname = "ubermenu.opts.key_route_stop",       default = ubermenu.opts.key_route_stop or "",             dorepeat = false, call = function() route.replayStop() end })
	sub:add_keybind({ title = "Toggle Playback",         varname = "ubermenu.opts.key_route_toggleplay", default = ubermenu.opts.key_route_toggleplay or "",       dorepeat = false, call = function() route.replay() end })
	sub:add_keybind({ title = "Load Next Route",         varname = "ubermenu.opts.key_route_loadnext",   default = ubermenu.opts.key_route_loadnext or "PageDown", dorepeat = true,  call = function() next_route() end })
	sub:add_keybind({ title = "Load Previous Route",     varname = "ubermenu.opts.key_route_loadprev",   default = ubermenu.opts.key_route_loadprev or "PageUp",   dorepeat = true,  call = function() prev_route() end })
	sub:add_keybind({ title = "Play Random Enemy Route", varname = "ubermenu.opts.key_route_loadrand",   default = ubermenu.opts.key_route_loadrand or "",         dorepeat = false, call = function() play_random_enemy_route() end })
	sub:add_keybind({ title = "Reset Route",             varname = "ubermenu.opts.key_route_reset",      default = ubermenu.opts.key_route_reset or "Delete",      dorepeat = false, call = function() route.reset() end })

	sub:add_separator({ })
	local sub1 = sub:add_submenu({ title = "More" })
	sub1:add_separator({ title = "Ubermenu" })
	sub1:add_keybind({ title = "Toggle Menu",                   varname = "ubermenu.opts.key_menu_toggle",    default = ubermenu.opts.key_menu_toggle,    dorepeat = false, call = function() ubermenu:toggle() end })
	sub1:add_keybind({ title = "Up",                            varname = "ubermenu.opts.key_menu_prev",      default = ubermenu.opts.key_menu_prev,      dorepeat = true,  call = function() ubermenu:go_prev() end })
	sub1:add_keybind({ title = "Down",                          varname = "ubermenu.opts.key_menu_next",      default = ubermenu.opts.key_menu_next,      dorepeat = true,  call = function() ubermenu:go_next() end })
	sub1:add_keybind({ title = "Enter Submenu or set Variable", varname = "ubermenu.opts.key_menu_enter",     default = ubermenu.opts.key_menu_enter,     dorepeat = false, call = function() ubermenu:go_enter() end })
	sub1:add_keybind({ title = "Back",                          varname = "ubermenu.opts.key_menu_parent",    default = ubermenu.opts.key_menu_parent,    dorepeat = true,  call = function() ubermenu:go_parent() end })
	sub1:add_keybind({ title = "Increase Variable",             varname = "ubermenu.opts.key_menu_inc_var",   default = ubermenu.opts.key_menu_inc_var,   dorepeat = true,  call = function() ubermenu:increment_var() end })
	sub1:add_keybind({ title = "Decrease Variable",             varname = "ubermenu.opts.key_menu_dec_var",   default = ubermenu.opts.key_menu_dec_var,   dorepeat = true,  call = function() ubermenu:decrement_var() end })
	sub1:add_keybind({ title = "Reset Variable",                varname = "ubermenu.opts.key_menu_reset_var", default = ubermenu.opts.key_menu_reset_var, dorepeat = false, call = function() ubermenu:reset_var() end })

	sub1:add_separator({ title = "Roam Map" })
	sub1:add_keybind({ title = "Return Flags",                  varname = "ubermenu.opts.key_return_flags",   default = ubermenu.opts.key_return_flags or "",   dorepeat = false, call = function() returnFlags() end })
	sub1:add_keybind({ title = "Toggle Base Turrets",           varname = "ubermenu.opts.key_toggle_turrets", default = ubermenu.opts.key_toggle_turrets or "", dorepeat = false, call = function() toggleTurrets() end })
	sub1:add_keybind({ title = "Toggle Generator Power",        varname = "ubermenu.opts.key_toggle_power",   default = ubermenu.opts.key_toggle_power or "",   dorepeat = false, call = function() togglePower() end })
	sub1:add_keybind({ title = "Save Current Location",         varname = "ubermenu.opts.key_state_save",     default = ubermenu.opts.key_state_save or "",     dorepeat = false, call = function() state.save() end })
	sub1:add_keybind({ title = "Teleport to Saved Location",    varname = "ubermenu.opts.key_teleport",       default = ubermenu.opts.key_teleport or "",       dorepeat = false, call = function() state.tp() end })
	sub1:add_keybind({ title = "Recall Saved Location",         varname = "ubermenu.opts.key_state_recall",   default = ubermenu.opts.key_state_recall or "",   dorepeat = false, call = function() state.recall() end })
	sub1:add_keybind({ title = "Reset Saved Locations",         varname = "ubermenu.opts.key_state_reset",    default = ubermenu.opts.key_state_reset or "",    dorepeat = false, call = function() state.reset() end })
	sub1:add_keybind({ title = "Set Saved Locations to Spawns", varname = "ubermenu.opts.key_state_spawns",   default = ubermenu.opts.key_state_spawns or "",   dorepeat = false, call = function() state.setToSpawns() end })

sub = nil
sub1= nil
