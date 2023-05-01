local module = {}

module.name = "evilKeysVisualizer"
module.opts = {
    X_Position = 90.0,
    Y_Position = 85.0,
    Text_Size = 1,
    Text_Color = rgba(255, 255, 255, 100),
    Border_Color = rgba(0, 0, 0, 180),
    Color = rgba(0, 255, 0, 80),
    Opacity = 100,
    Style = 1,
    BorderThickness = 0.5,
    BorderGap = 0,
    Fade_In_Duration_Seconds = 0,
    Fade_Out_Duration_Seconds = 0.5,
    Vertical_Padding = 5,
    Horizontal_Padding = 5,
    MovementKeys = {
        ["Q"] = "Q",
        ["W"] = "^",
        ["E"] = "E",
        ["R"] = "R",
        ["A"] = "<",
        ["S"] = "v",
        ["D"] = ">",
        ["F"] = "F",
        ["Z"] = "Z",
        ["X"] = "X",
        ["C"] = "C",
        ["V"] = "V",
    },
}

local key_map = {
    ["Q"] = {text = module.opts.MovementKeys["Q"], row = 1, col = 2},
    ["W"] = {text = module.opts.MovementKeys["W"], row = 1, col = 3},
    ["E"] = {text = module.opts.MovementKeys["E"], row = 1, col = 4},
    ["R"] = {text = module.opts.MovementKeys["R"], row = 1, col = 5},
    ["LeftShift"] = {text = "Shft", row = 2, col = 1},
    ["A"] = {text = module.opts.MovementKeys["A"], row = 2, col = 2},
    ["S"] = {text = module.opts.MovementKeys["S"], row = 2, col = 3},
    ["D"] = {text = module.opts.MovementKeys["D"], row = 2, col = 4},
    ["F"] = {text = module.opts.MovementKeys["F"], row = 2, col = 5},
    ["Z"] = {text = module.opts.MovementKeys["Z"], row = 3, col = 2},
    ["X"] = {text = module.opts.MovementKeys["X"], row = 3, col = 3},
    ["C"] = {text = module.opts.MovementKeys["C"], row = 3, col = 4},
    ["V"] = {text = module.opts.MovementKeys["V"], row = 3, col = 5},
    ["LeftControl"] = {text = "Ctrl", row = 4, col = 1},
    ["LeftAlt"] = {text = "Alt", row = 4, col = 2},
    ["SpaceBar"] = {text = "Space", row = 4, col = 3, colspan = 3},
    ["LeftMouseButton"] = {text = "Fire", row = 0, col = 2, colspan = 2},
    ["RightMouseButton"] = {text = "Jet", row = 0, col = 4, colspan = 2},
    }


    local function drawBackground(x, y, x2, y2, color, style, row, col)
        if style == 0 then
            drawRect(x, y, x2, y2, color)
        elseif style == 1 then
            drawRect(x, y, x2, y2, color)
            local border_color = module.opts.Border_Color
            local border_size = module.opts.BorderThickness
            local border_gap = module.opts.BorderGap
            drawRect(x + border_gap, y + border_gap, x2 - border_gap, y + border_gap + border_size, border_color) -- top border
            drawRect(x + border_gap, y + border_gap, x + border_gap + border_size, y2 - border_gap, border_color) -- left border
            drawRect(x2 - border_gap - border_size, y + border_gap, x2 - border_gap, y2 - border_gap, border_color) -- right border
            drawRect(x + border_gap, y2 - border_gap - border_size, x2 - border_gap, y2 - border_gap, border_color) -- bottom border
        elseif style == 2 then
        local gradient_steps = 5
        local start_color = rgba(255, 255, 255, 0)
        for i = 1, gradient_steps do
            local alpha = i / gradient_steps
            local gradient_color = lerpColor(start_color, color, alpha)
            local rwidth = (i / gradient_steps) * (x2 - x)
            local rheight = (i / gradient_steps) * (y2 - y)
            drawRect(x + (x2 - x) / 2 - rwidth / 2, y + (y2 - y) / 2 - rheight / 2, x + (x2 - x) / 2 + rwidth / 2, y + (y2 - y) / 2 + rheight / 2, gradient_color)
        end
        local border_color = module.opts.Border_Color
        local border_size = module.opts.BorderThickness
        local border_gap = module.opts.BorderGap
        drawRect(x + border_gap, y + border_gap, x2 - border_gap, y + border_gap + border_size, border_color) -- top border
        drawRect(x + border_gap, y + border_gap, x + border_gap + border_size, y2 - border_gap, border_color) -- left border
        drawRect(x2 - border_gap - border_size, y + border_gap, x2 - border_gap, y2 - border_gap, border_color) -- right border
        drawRect(x + border_gap, y2 - border_gap - border_size, x2 - border_gap, y2 - border_gap, border_color) -- bottom border
    end
end



    local pressed_keys = {}
    local key_times = {}
    

    local function keyEventHandler(key, eventType, ctrl, shift, alt)
        local mapped_key = key_map[key]
    
        if mapped_key then
            if eventType == enums.INPUT_EVENT_TYPE_PRESSED then
                pressed_keys[key] = true
                key_times[key] = game.realTimeSeconds()
            elseif eventType == enums.INPUT_EVENT_TYPE_RELEASED then
                pressed_keys[key] = nil
                key_times[key] = game.realTimeSeconds()
            end
        end
    end
    
    for key, _ in pairs(key_map) do
    bindKey(key, enums.INPUT_EVENT_TYPE_PRESSED, keyEventHandler)
    bindKey(key, enums.INPUT_EVENT_TYPE_RELEASED, keyEventHandler)
    end
    
    function module.draw(res_x, res_y)

        local fade_in_duration = module.opts.Fade_In_Duration_Seconds
        local fade_out_duration = module.opts.Fade_Out_Duration_Seconds

        if not hud_data.alive then return end
        
        local time = game.realTimeSeconds()
        local xpos = math.floor(module.opts.X_Position / 100 * res_x)
        local ypos = math.floor(module.opts.Y_Position / 100 * res_y)
        local key_size = 30 * module.opts.Text_Size 
        local cell_spacing_x = module.opts.Horizontal_Padding * module.opts.Text_Size 
        local cell_spacing_y = module.opts.Vertical_Padding * module.opts.Text_Size 
    
        for key, key_info in pairs(key_map) do
            local x = xpos + (key_info.col - 1) * (key_size + cell_spacing_x)
            local y = ypos + (key_info.row - 1) * (key_size + cell_spacing_y)
            local width = key_size * (key_info.colspan or 1) + cell_spacing_x * ((key_info.colspan or 1) - 1)
            local color = rgba(0, 0, 0, module.opts.Opacity)
    
            if pressed_keys[key] or key_times[key] then
                local alpha = 0
                if pressed_keys[key] then
                    alpha = math.min(1, (time - key_times[key]) / fade_in_duration)
                else
                    alpha = 1 - math.min(1, (time - key_times[key]) / fade_out_duration)
                end
                color = lerpColor(rgba(0, 0, 0, module.opts.Opacity), module.opts.Color, alpha)
            end
    
            drawBackground(x, y, x + width, y + key_size, color, module.opts.Style, key_info.row, key_info.col) 
            local text_color = module.opts.Text_Color
            drawSmallText(key_info.text, text_color, x + width / 2, y + key_size / 2, 1, 0, module.opts.Text_Size)
        end
    end

return module
