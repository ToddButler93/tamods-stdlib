local module = {}

module.name                      = "senexsCredits"  -- This HAS to be the same as the filename minus the trailing .lua
module.opts                      = {}
module.opts.X_Position           = 90
module.opts.Y_Position           = 10
module.opts.Credits              = rgba(227,238,230,255)
module.opts.CreditsTag           = rgba(209,236,230,255)
module.opts.Background           = rgba(113,116,113,120)
module.opts.Border               = rgba(0,0,0,200)
module.opts.Background_Width     = 115
module.opts.Background_Height    = 60
module.opts.Credits_Alignment    = 1
module.opts.CreditsTag_Alignment = 0
module.opts.Credits_Shadow       = 1
module.opts.Credits_Size         = 2
module.opts.CreditsTag_Shadow    = 0
module.opts.CreditsTag_Size      = 1
module.opts.Credits_Font         = 2
module.opts.CreditsTag_Font      = 0
module.opts.CreditsTag_X_Position_Adj   = 0
module.opts.CreditsTag_Y_Position_Adj   = 0
module.opts.Credits_X_Position_Adj      = 0
module.opts.Credits_Y_Position_Adj      = 0



function module.draw(res_x, res_y)

	local xpos = math.floor(module.opts.X_Position / 100 * res_x)
	local ypos = math.floor(module.opts.Y_Position / 100 * res_y)

	drawBox(xpos, ypos, xpos + module.opts.Background_Width, ypos + module.opts.Background_Height, module.opts.Border)
	drawRect(xpos, ypos, xpos + module.opts.Background_Width, ypos + module.opts.Background_Height, module.opts.Background)

	if module.opts.Credits_Font == 1 then
		drawUTText(player.credits(), module.opts.Credits, xpos + 55 + module.opts.Credits_X_Position_Adj, ypos + 40 + module.opts.Credits_Y_Position_Adj, module.opts.Credits_Alignment, module.opts.Credits_Shadow, module.opts.Credits_Size)
	elseif module.opts.Credits_Font == 2 then
		drawSmallText(player.credits(), module.opts.Credits, xpos + 55 + module.opts.Credits_X_Position_Adj, ypos + 40 + module.opts.Credits_Y_Position_Adj, module.opts.Credits_Alignment, module.opts.Credits_Shadow, module.opts.Credits_Size)
	else
		drawText(player.credits(), module.opts.Credits, xpos + 55 + module.opts.Credits_X_Position_Adj, ypos + 40 + module.opts.Credits_Y_Position_Adj, module.opts.Credits_Alignment, module.opts.Credits_Size)
	end

	if module.opts.CreditsTag_Font == 1 then
		drawUTText("Credits", module.opts.CreditsTag, xpos + 22 + module.opts.CreditsTag_X_Position_Adj, ypos + 15 + module.opts.CreditsTag_Y_Position_Adj, module.opts.CreditsTag_Alignment, module.opts.CreditsTag_Shadow, module.opts.CreditsTag_Size)
	elseif module.opts.CreditsTag_Font == 2 then
		drawSmallText("Credits", module.opts.CreditsTag, xpos + 22 + module.opts.CreditsTag_X_Position_Adj, ypos + 15 + module.opts.CreditsTag_Y_Position_Adj, module.opts.CreditsTag_Alignment, module.opts.CreditsTag_Shadow, module.opts.CreditsTag_Size)
	else
		drawText("Credits", module.opts.CreditsTag, xpos + 22 + module.opts.CreditsTag_X_Position_Adj, ypos + 15 + module.opts.CreditsTag_Y_Position_Adj, module.opts.CreditsTag_Alignment, module.opts.CreditsTag_Size)
	end

end

return module
