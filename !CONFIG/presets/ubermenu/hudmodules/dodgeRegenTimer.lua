local module = {}
--Hi I'm Implo And I Made Most Of This
--Hi I'm Giga and I fixed some bugs
module.name                = "dodgeRegenTimer"  -- This HAS to be the same as the filename minus the trailing .lua
module.opts                = {}         -- Options, you can add your own here
module.opts.X_Position     = 16      -- Position variables should be screen percentage based
module.opts.Y_Position     = 50
module.opts.Alignment      = 0
module.opts.Font           = 1
module.opts.Text           = rgba(255,255,255,255)
module.opts.TextSize       = 1
module.opts.TextShadowSize = 1
module.opts.color1         = rgb(255,0,0)
module.opts.color2         = rgb(255,255,255)
module.hpStart             = player.healthMax()
module.enStart             = player.energy()
module.endTime             = 0
module.timerOn             = false
module.status              = true
-- The drawing function for this module
function module.draw(res_x, res_y)
	if hud_data.alive then
		--get the current regen time
		local time = math.ceil(module.endTime - game.realTimeSeconds())
		damageCheck()
		if module.timerOn == true then
			if time >= 0 then
				local xpos = math.floor(module.opts.X_Position / 100 * res_x)
				local ypos = math.floor(module.opts.Y_Position / 100 * res_y)
				local color = lerpColor(module.opts.color1, module.opts.color2, time / 14)
				if module.opts.Font == 1 then
					drawUTText(time, color, xpos, ypos, module.opts.Alignment, module.opts.TextShadowSize, module.opts.TextSize)
				elseif module.opts.Font == 2 then
					drawSmallText(time, color, xpos, ypos, module.opts.Alignment, module.opts.TextShadowSize, module.opts.TextSize)
				else
					drawText(time, color, xpos, ypos, module.opts.Alignment, module.opts.TextSize)
				end
			end
		end
	else
		--reset the timer with an extra second to account for the respawn delay
		module.endTime = game.realTimeSeconds() + 14 + 1
		module.timerOn = false
		module.status = true
	end
end

function setTimer()
	module.endTime = game.realTimeSeconds() + 14
	module.timerOn = true
end

--check if the player takes damage
function damageCheck()
	--doesn't show timer if player is full hp, has the flag, or has rage
	if player.health() < player.healthMax() and not player.hasFlag() and not player.isRaged() then
		module.timerOn = true
		--turns timer on if hit while shield are on
		if player.isShielded() and player.energy() < module.enStart - 5 then
			setTimer()
		end
		--turns timer on if health goes down
		if player.health() < module.hpStart then
			setTimer()
		end
		--checks if you drop the flag or lose rage
		if player.hasFlag() ~= module.status and player.isRaged() ~= module.status then
			setTimer()
		end
		--turns timer off if you use an invo station
		if player.health() > module.hpStart and player.health() < module.hpStart + 100 then
			module.timerOn = false
		end
		module.hpStart = player.health()
		module.enStart = player.energy()
		
	else
		module.timerOn = false
	end
	if player.hasFlag() or player.isRaged() then
		module.status = true
	else
		module.status = false
	end
end

return module