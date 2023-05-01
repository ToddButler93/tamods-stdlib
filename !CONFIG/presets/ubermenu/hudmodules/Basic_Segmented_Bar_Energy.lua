local module = {}

module.name                = "Basic_Segmented_Bar_Energy"  -- This HAS to be the same as the filename minus the trailing .lua
module.opts                = {}
module.opts.X_Position     = 50.0
module.opts.Y_Position     = 30.0
module.opts.Horizontal     = true
module.opts.Segments       = 10
module.opts.Margin         = 2
module.opts.Width          = 12
module.opts.Height         = 18
module.opts.Dynamic_Color  = true
module.opts.Full           = rgba(0,255,0,255)
module.opts.Low            = rgba(255,0,0,255)
module.opts.Empty_Segments = rgba(0,0,0,120)

function module.draw(res_x, res_y)
	if not hud_data.alive then return end

	local xpos = math.floor(module.opts.X_Position / 100 * res_x)
	local ypos = math.floor(module.opts.Y_Position / 100 * res_y)
	local pct = player.energyPct()
	local color
	if module.opts.Dynamic_Color then
		color = lerpColor(module.opts.Low, module.opts.Full, pct)
	else
		color = module.opts.Full
	end

	local segments = math.ceil(module.opts.Segments * pct)

	for i = 1,module.opts.Segments do
		if i > segments then color = module.opts.Empty_Segments end

		drawRect(xpos, ypos, xpos + module.opts.Width, ypos + module.opts.Height, color)

		if module.opts.Horizontal then
			xpos = xpos + module.opts.Margin + module.opts.Width
		else
			ypos = ypos - module.opts.Margin - module.opts.Height
		end
	end
end

return module
