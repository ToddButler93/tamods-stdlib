local module = {}

module.name = "evilIndicators"
module.opts = {
    Show_Shield = true,
    Show_Rage = true,
    Show_Flag = true,
    Shield_Offset_X = 0.0,
    Shield_Offset_Y = 0.0,
    Rage_Offset_X = 0.0,
    Rage_Offset_Y = 0.0,
    Flag_Offset_X = 0.0,
    Flag_Offset_Y = 0.0,
    Text_Size = 2,
    Text_Color = rgba(250, 255, 250, 255),
    Background_Color = rgba(0, 0, 0, 128),
    Border_Color = rgba(255, 255, 255, 255),
    Padding = 10,
    Border_Width_Top = 1,
    Border_Width_Bottom = 1,
    Border_Width_Left = 6,
    Border_Width_Right = 6,
    Border_Insets = -1,
    Border_Gap = -2,
    Flag_Width = 38,
    Flag_Height = 3,
    Rage_Width = 38,
    Rage_Height = 3,
    Shield_Width = 38,
    Shield_Height = 3,
    X_Position = 47,
    Y_Position = 75,
    Font = 2,
    Font_Shadow = 0,
    Animation_Duration = 0,
    Color_Shift_Speed = 0.25,
    Shield_Color = rgba(85, 180, 250, 50),
    Rage_Color = rgba(250, 80, 80, 50),
    Flag_Color = rgba(0, 255, 185, 50),
    Indicator_Spacing = 46,
    Show_Kill = true,
    Kill_Offset_X = -42,
    Kill_Offset_Y = 0.0,
    Kill_Width = 70,
    Kill_Height = 6,
    Kill_Color = rgba(255, 165, 0, 50),
    Kill_Lifetime = 5,
}
-- Initialize animation start time
local animation_start_time = 0
local show_kill_indicator = false
local kill_indicator_end_time = 0
local kill_indicators = {}
onKillMessageOld = onKillMessage

local function resetKillIndicators()
    kill_indicators = {}
end



local function getAnimatedOffsetY(index, total_indicators)
    local elapsed_time = game.realTimeSeconds() - animation_start_time
    local animation_duration = module.opts.Animation_Duration
    local max_offset_y = module.opts.Indicator_Spacing * (index - 1)

    if elapsed_time > animation_duration then
        return max_offset_y
    else
        return max_offset_y * (elapsed_time / animation_duration)
    end
end

function onKillMessage(text, name)
    if onKillMessageOld then onKillMessageOld(text, name) end  
    -- Create a new kill indicator and add it to the table
    table.insert(kill_indicators, {
        text = name,
        start_time = game.realTimeSeconds(),
        end_time = game.realTimeSeconds() + module.opts.Kill_Lifetime
    })
end



function module.draw(res_x, res_y)
    if not hud_data.alive then return end

    if player.kills() < 1 then
        resetKillIndicators()
    end

    local indicators = {}
    local xpos, ypos

    if module.opts.Show_Kill then
        for _, kill_indicator in ipairs(kill_indicators) do
            if game.realTimeSeconds() <= kill_indicator.end_time then
                xpos = math.floor(module.opts.X_Position / 100 * res_x) + module.opts.Kill_Offset_X
                ypos = math.floor(module.opts.Y_Position / 100 * res_y) + module.opts.Kill_Offset_Y
                table.insert(indicators, {
                    text = kill_indicator.text,
                    type = "Kill",
                    x = xpos,
                    y = ypos,
                    width = module.opts.Kill_Width * module.opts.Text_Size * 1.5,
                    height = module.opts.Kill_Height * module.opts.Text_Size * 1.5,
                    active = true
                })
            else
                -- Remove the kill indicator if its lifetime has expired
                table.remove(kill_indicators, _)
            end
        end
    end
    
    
    

    if module.opts.Show_Shield and player.isShielded() then
        xpos = math.floor(module.opts.X_Position / 100 * res_x) + module.opts.Shield_Offset_X
        ypos = math.floor(module.opts.Y_Position / 100 * res_y) + module.opts.Shield_Offset_Y
        table.insert(indicators, {
            text = "Shield", 
            type = "Shield",
            x = xpos, 
            y = ypos, 
            width = module.opts.Shield_Width * module.opts.Text_Size * 1.5, 
            height = module.opts.Shield_Height * module.opts.Text_Size * 1.5,
            active = true
        })
    end

    if module.opts.Show_Rage and player.isRaged() then
        xpos = math.floor(module.opts.X_Position / 100 * res_x) + module.opts.Rage_Offset_X
        ypos = math.floor(module.opts.Y_Position / 100 * res_y) + module.opts.Rage_Offset_Y
        table.insert(indicators, {
            text = "Rage", 
            type = "Rage",
            x = xpos, 
            y = ypos, 
            width = module.opts.Rage_Width * module.opts.Text_Size * 1.5, 
            height = module.opts.Rage_Height * module.opts.Text_Size * 1.5,
            active = true
        })
    end

    if module.opts.Show_Flag and player.hasFlag() then
        xpos = math.floor(module.opts.X_Position / 100 * res_x) + module.opts.Flag_Offset_X
        ypos = math.floor(module.opts.Y_Position / 100 * res_y) + module.opts.Flag_Offset_Y
        table.insert(indicators, {
            text = "Flag", 
            type = "Flag",
            x = xpos, 
            y = ypos, 
            width = module.opts.Flag_Width * module.opts.Text_Size * 1.5, 
            height = module.opts.Flag_Height * module.opts.Text_Size * 1.5,
            active = true
        })
    end

    local active_indicators = 0
    for _, indicator in ipairs(indicators) do
        if indicator.active then
            active_indicators = active_indicators + 1
        end
    end

    if active_indicators > 1 and animation_start_time == 0 then
        animation_start_time = game.realTimeSeconds()
    elseif active_indicators <= 1 then
        animation_start_time = 0
    end

    local is_first_active = true
    local indicator_colors = {
        Shield = module.opts.Shield_Color,
        Rage = module.opts.Rage_Color,
        Flag = module.opts.Flag_Color,
        Kill = module.opts.Kill_Color,
    }
    if game.realTimeSeconds() >= kill_indicator_end_time then
        show_kill_indicator = false
    end
    
    local active_indicator_index = 0
    for _, indicator in ipairs(indicators) do
        if active_indicators > 1 and indicator.active then
            active_indicator_index = active_indicator_index + 1
            indicator.y = indicator.y + getAnimatedOffsetY(active_indicator_index, active_indicators)
        end


        local x1, y1, x2, y2 = indicator.x - module.opts.Padding, indicator.y - module.opts.Padding, indicator.x + indicator.width + module.opts.Padding, indicator.y + indicator.height + module.opts.Padding

        local animation_speed = module.opts.Color_Shift_Speed
        local animation_offset = (indicator.text == "Flag" and active_indicators > 1) and 0.5 or 0 -- Offset the animation for the "Flag" indicator when there are multiple active indicators
        local animation_progress = math.sin((game.realTimeSeconds() + animation_offset) * animation_speed * 2 * math.pi) * 0.5 + 0.5
        local base_color = module.opts.Background_Color
            
        local indicator_type = indicator.type or indicator.text
        local animated_color = indicator_colors[indicator_type]  -- Use indicator_type instead of indicator.text

        local interpolated_color = lerpColor(base_color, animated_color, animation_progress)

        -- Draw the animated background
        drawRect(x1, y1, x2, y2, interpolated_color)
        
        -- Draw the border with insets and gap
        drawRect(x1 - module.opts.Border_Width_Left - module.opts.Border_Insets, y1 + module.opts.Border_Gap, x1 - module.opts.Border_Insets, y2 - module.opts.Border_Gap, module.opts.Border_Color) -- Left border
        drawRect(x2 + module.opts.Border_Insets, y1 + module.opts.Border_Gap, x2 + module.opts.Border_Width_Right + module.opts.Border_Insets, y2 - module.opts.Border_Gap, module.opts.Border_Color) -- Right border
        drawRect(x1 + module.opts.Border_Gap, y1 - module.opts.Border_Width_Top - module.opts.Border_Insets, x2 - module.opts.Border_Gap, y1 - module.opts.Border_Insets, module.opts.Border_Color) -- Top border
        drawRect(x1 + module.opts.Border_Gap, y2 + module.opts.Border_Insets, x2 - module.opts.Border_Gap, y2 + module.opts.Border_Width_Bottom + module.opts.Border_Insets, module.opts.Border_Color) -- Bottom border

        local textSize
        if module.opts.Font == 1 then
            textSize = getUTTextSize(indicator.text, module.opts.Text_Size)
        else
            textSize = getSmallTextSize(indicator.text, module.opts.Text_Size)
        end
        
        local centeredX = indicator.x + (indicator.width - textSize.x) / 2
        local centeredY = indicator.y + (indicator.height - textSize.y) / 2 + 17

        if indicator.type == "Kill" then 

            local killed_x_offset = -9  
            local killed_y_offset = -9  
            local killed_text_size = getSmallTextSize("Killed", module.opts.Text_Size / 2)
            local killed_text_x = indicator.x + killed_x_offset
            local killed_text_y = indicator.y + killed_y_offset

            local rect_x1 = killed_text_x 
            local rect_y1 = killed_text_y + killed_text_size.y - 19
            local rect_x2 = killed_text_x + killed_text_size.x + 2
            local rect_y2 = rect_y1 + 11

            drawRect(rect_x1, rect_y1, rect_x2, rect_y2, module.opts.Border_Color)
            drawSmallText("Killed", rgba(0,0,0,255), killed_text_x, killed_text_y+3, 0, module.opts.Font_Shadow, module.opts.Text_Size / 2)
        end
        

        if module.opts.Font == 1 then
            drawUTText(indicator.text, module.opts.Text_Color, centeredX, centeredY +10, 0, module.opts.Font_Shadow, module.opts.Text_Size)
        else
            drawSmallText(indicator.text, module.opts.Text_Color, centeredX, centeredY, 0, module.opts.Font_Shadow, module.opts.Text_Size)
        end
    end  
end
return module
    