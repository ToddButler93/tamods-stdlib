local module = {}

module.name              = "sqShieldIndicator"  -- This HAS to be the same as the filename minus the trailing .lua
module.opts              = {}
module.opts.Width        = 50
module.opts.Color        = rgba(0,120,200,60)

-- The drawing function for this module
function module.draw(res_x, res_y)
	if not player.isShielded() then
		return
	end
	drawRect(0, 0, module.opts.Width, res_y, module.opts.Color)
	drawRect(res_x - module.opts.Width, 0, res_x, res_y, module.opts.Color)
end

return module
