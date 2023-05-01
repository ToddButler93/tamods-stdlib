local module = {}

module.name = "evilRouteStats"
module.opts = {
    X_Position = 82.0,
    Y_Position = 5,
    Text_Size = 1,
    Title_Text_Color = rgba(255, 255, 255, 200),
    Value_Text_Color = rgba(0, 0, 0, 255),
    Title_Border_Color = rgba(0, 255, 250, 170),
    Border_Highlight = rgba(0, 255, 250, 180),
    Value_Border_Color = rgba(250, 250, 250, 150),
    Title_Color = rgba(80, 100, 100, 180),
    Value_Color = rgba(255, 255, 255, 120),
    Changing_Value_Color = rgba(0, 255, 0, 40),
    Style = 1,
    Font_Values = 2,
    Font_Value_Shadow = 0,
    Font_Titles = 2,
    Font_Title_Shadow = 0,
    Fade_In_Duration_Seconds = 0,
    Fade_Out_Duration_Seconds = 0.5,
    Padding_Vertical = -10,
    Padding_Horizontal = 15,
    Row1 = true,
    Row2 = true,
    Row3 = true,
    Row4 = true,
    Row5 = true,
    Row6 = true,
    Row7 = true,
    Row8 = true,
    Row9 = true,
    Col1 = true,
    Col4 = true,
    Col5 = true,
    Col6 = true,
    ToggleCol1Key = "U",
    ToggleAllVisibilityKey = "I",
    Fade_In_Duration_Seconds = 1.5,
    Fade_Out_Duration_Seconds = 1.5,
    Title_Border_Top_Thickness = 1,
    Title_Border_Bottom_Thickness = 1,
    Title_Border_Left_Thickness = 5,
    Title_Border_Right_Thickness = 1,
    Title_BorderInset = -1,
    Title_BorderGap = 1,
    Value_Border_Top_Thickness = 1,
    Value_Border_Bottom_Thickness = 1,
    Value_Border_Left_Thickness = 1,
    Value_Border_Right_Thickness = 1,
    Value_BorderInset = -1,
    Value_BorderGap = 1,
    Background_Height = -6,
    Background_Width = 17,
}

local time_above_threshold = 0
local route_start_time = 0
local route_end_time = 0
local route_duration = 0
local accumulated_speed = 0
local is_above_threshold = false
local total_routes = 0
local total_time = 0
local grab_start_time = 0
local flag_previously_held = false


local function toggleCol1(key, eventType, ctrl, shift, alt)
    if eventType == enums.INPUT_EVENT_TYPE_PRESSED then
        module.opts.Col1 = not module.opts.Col1
    end
end

local function toggleAllVisibility(key, eventType, ctrl, shift, alt)
    if eventType == enums.INPUT_EVENT_TYPE_PRESSED then
        local toggle = not module.opts.Col1
        module.opts.Col1 = toggle
        module.opts.Col4 = toggle
        module.opts.Col5 = toggle
        module.opts.Col6 = toggle
        for i = 1, 7 do
            module.opts["Row" .. i] = toggle
        end
    end
end


bindKey(module.opts.ToggleCol1Key, enums.INPUT_EVENT_TYPE_PRESSED, toggleCol1)
bindKey(module.opts.ToggleAllVisibilityKey, enums.INPUT_EVENT_TYPE_PRESSED, toggleAllVisibility)


local info_map = {
    ["RouteAvg"]     = {text = "Route Avg",     row = 2, col = 1, colspan = 3},
    ["RouteSpeed"]   = {text = "Max Speed",   row = 3, col = 1, colspan = 3},
    ["GrabSpeed"]    = {text = "Grab Speed",   row = 4, col = 1, colspan = 3},
    ["RouteTime"]    = {text = "Route Time",    row = 5, col = 1, colspan = 3},
    ["AvgTime"]      = {text = "Avg Time",      row = 6, col = 1, colspan = 3},
    ["AvgGrab"]      = {text = "Avg Grab",      row = 7, col = 1, colspan = 3},
    ["TotalRoutes"]  = {text = "Total Routes",  row = 8, col = 1, colspan = 3},
    ["TotalTime"]    = {text = "Total Time",    row = 9, col = 1, colspan = 3},
    ["Curr"]         = {text = "Cur",          row = 1, col = 4},
    ["Prev"]         = {text = "Prev",          row = 1, col = 5},
    ["Top"]          = {text = "Max",           row = 1, col = 6},
}
local value_map = {
    ["current_route_avg"] = {value = 0,previous_value = nil, row = 2, col = 4, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["previous_route_avg"] = {value = 0,previous_value = nil, row = 2, col = 5, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["top_route_avg"] = {value = 0,previous_value = nil, row = 2, col = 6, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["current_route_speed"] = {value = 0,previous_value = nil, row = 3, col = 4, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["previous_route_speed"] = {value = 0,previous_value = nil, row = 3, col = 5, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["top_route_speed"] = {value = 0,previous_value = nil, row = 3, col = 6, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["current_grab_speed"] = {value = 0, row = 4, col = 4},
    ["previous_grab_speed"] = {value = 0,previous_value = nil, row = 4, col = 5, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["top_grab_speed"] = {value = 0,previous_value = nil, row = 4, col = 6, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["current_route_time"] = {value = 0,previous_value = nil, row = 5, col = 4, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["previous_route_time"] = {value = 0,previous_value = nil, row = 5, col = 5, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["avg_route_time"] = {value = 0,previous_value = nil, row = 6, col = 4, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["avg_grab_speed"] = {value = 0, previous_value = nil, row = 7, col = 4, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["total_routes"] = {value = 0,previous_value = nil, row = 8, col = 4, color_change_start_time = nil, module.opts.Color_Change_Duration},
    ["total_time"] = {value = 0,previous_value = nil, row = 9, col = 4, colspan = 2, color_change_start_time = nil, module.opts.Color_Change_Duration},
    }

local valuesReset = false

function resetGlobalValues()
    total_routes = 0
    total_time = 0
    total_grab_speeds = 0
    grab_speed_count = 0
end

function resetValues()
    if player.speed() < 25 and player.deaths() == 0 then
        if not valuesReset then
            for key, value in pairs(value_map) do
                value.value = 0
                value.previous_value = nil
                value.color_change_start_time = nil
            end
            resetGlobalValues()
            valuesReset = true
        end
    elseif player.deaths() > 0 then
        valuesReset = false
    end
end



local function countVisibleRows(row)
    local visibleRows = 0
    for i = 1, row - 1 do
        if module.opts["Row" .. i] then
            visibleRows = visibleRows + 1
        end
    end
    return visibleRows
end

local function countVisibleCols(col)
    local visibleCols = 0
    for key, info in pairs(info_map) do
        if info.col < col then
            local maxCol = info.col + (info.colspan or 1) - 1
            visibleCols = math.max(visibleCols, maxCol)
        end
    end
    return visibleCols
end

local function formatTime(total_seconds)
    local minutes = math.floor(total_seconds / 60)
    local seconds = math.floor(total_seconds % 60)
    return string.format("%dm %ds", minutes, seconds)
end

local default_background_height = 10
local default_background_width = 10

local function drawBackground(x, y, x2, y2, color, style, row, col, top_thickness, bottom_thickness, left_thickness, right_thickness, border_inset, border_gap, border_color, enable_highlight)

    local height_diff = module.opts.Background_Height - default_background_height
    local width_diff = module.opts.Background_Width - default_background_width


    y = y - height_diff / 2
    y2 = y2 + height_diff / 2
    x = x - width_diff / 2
    x2 = x2 + width_diff / 2

    if style == 0 then
        drawRect(x, y, x2, y2, color)
    elseif style == 1 then
        drawRect(x, y, x2, y2, color)
        drawRect(x + border_inset + border_gap, y + border_inset, x2 - border_inset - border_gap, y + border_inset + top_thickness, border_color) -- top border
        if enable_highlight == true then
            drawRect(x + border_inset, y + border_inset + border_gap, x + border_inset + left_thickness, y2 - border_inset - border_gap, module.opts.Border_Highlight) -- left border
        else
            drawRect(x + border_inset, y + border_inset + border_gap, x + border_inset + left_thickness, y2 - border_inset - border_gap, border_color) -- left border
        end
        drawRect(x2 - border_inset - right_thickness, y + border_inset + border_gap, x2 - border_inset, y2 - border_inset - border_gap, border_color) -- right border
        drawRect(x + border_inset + border_gap, y2 - border_inset - bottom_thickness, x2 - border_inset - border_gap, y2 - border_inset, border_color) -- bottom border
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
        drawRect(x + border_inset + border_gap, y + border_inset, x2 - border_inset - border_gap, y + border_inset + top_thickness, border_color) -- top border
        if enable_highlight == true then
            drawRect(x + border_inset, y + border_inset + border_gap, x + border_inset + left_thickness, y2 - border_inset - border_gap, module.opts.Border_Highlight) -- left border
        else
            drawRect(x + border_inset, y + border_inset + border_gap, x + border_inset + left_thickness, y2 - border_inset - border_gap, border_color) -- left border
        end
        drawRect(x2 - border_inset - right_thickness, y + border_inset + border_gap, x2 - border_inset, y2 - border_inset - border_gap, border_color) -- right border
        drawRect(x + border_inset + border_gap, y2 - border_inset - bottom_thickness, x2 - border_inset - border_gap, y2 - border_inset, border_color) -- bottom border
    end
end




local num_frames_above_threshold = 0
local total_grab_speeds = 0
local grab_speed_count = 0

function module.draw(res_x, res_y)
    resetValues()

    local current_speed = player.speed()
    local current_time = game.realTimeSeconds()
    local speed_threshold = 180

    if player.hasFlag() and not flag_previously_held then
        flag_previously_held = true
        grab_start_time = game.realTimeSeconds()
        value_map["previous_grab_speed"].value = current_speed
        value_map["top_grab_speed"].value = math.max(value_map["top_grab_speed"].value, current_speed)
        
        if current_speed > speed_threshold then
            total_grab_speeds = total_grab_speeds + current_speed
            grab_speed_count = grab_speed_count + 1
            value_map["avg_grab_speed"].value = total_grab_speeds / grab_speed_count
        end
    elseif not player.hasFlag() and flag_previously_held then
        flag_previously_held = false
    end

    if current_speed > speed_threshold and not player.hasFlag() then
        if not is_above_threshold then
            is_above_threshold = true
            route_start_time = current_time
            
        end
        accumulated_speed = accumulated_speed + current_speed
        num_frames_above_threshold = num_frames_above_threshold + 1
        time_above_threshold = current_time - route_start_time

        value_map["current_route_speed"].value = math.max(value_map["current_route_speed"].value, current_speed)

        if current_speed > value_map["top_route_speed"].value and not player.hasFlag() then
            value_map["top_route_speed"].value = current_speed
        end
    
    else
        if is_above_threshold and time_above_threshold >= 5 then
            route_end_time = current_time
            route_duration = route_end_time - route_start_time
            if route_duration >= 20 then

                total_routes = total_routes + 1
                total_time = total_time + route_duration

                value_map["previous_route_speed"].value = value_map["current_route_speed"].value
                value_map["previous_route_avg"].value = value_map["current_route_avg"].value
                value_map["previous_route_time"].value = value_map["current_route_time"].value
                if value_map["current_route_avg"].value > value_map["top_route_avg"].value then
                    value_map["top_route_speed"].value = value_map["current_route_speed"].value
                    value_map["top_route_avg"].value = value_map["current_route_avg"].value
                end
            end
        end
        is_above_threshold = false
        time_above_threshold = 0
        accumulated_speed = 0
        num_frames_above_threshold = 0
    end

    if is_above_threshold and time_above_threshold >= 5 then
        value_map["current_route_time"].value = time_above_threshold
        value_map["current_route_avg"].value = accumulated_speed / num_frames_above_threshold 
    else
        value_map["current_route_avg"].value = 0
        value_map["current_route_speed"].value = 0
        value_map["current_route_time"].value = 0
    end


    local xpos = math.floor(module.opts.X_Position / 100 * res_x)
    local ypos = math.floor(module.opts.Y_Position / 100 * res_y)
    local cell_width = 30 * module.opts.Text_Size 
    local cell_height = 30 * module.opts.Text_Size 
    local cell_spacing_x = module.opts.Padding_Horizontal * module.opts.Text_Size 
    local cell_spacing_y = module.opts.Padding_Vertical * module.opts.Text_Size 


    for key, info in pairs(info_map) do
        enable_highlight = true
        if module.opts["Row" .. info.row] and module.opts["Col" .. info.col] then
            local visibleRow = countVisibleRows(info.row)
            local visibleCol = countVisibleCols(info.col)
            local x = xpos + visibleCol * (cell_width + cell_spacing_x)
            local y = ypos + visibleRow * (cell_height + cell_spacing_y)
            local width = cell_width * (info.colspan or 1) + cell_spacing_x * ((info.colspan or 1) - 1)
            local height = cell_height

            local color = module.opts.Title_Color

            drawBackground(x, y, x + width, y + height, 
                            color, 
                            module.opts.Style, 
                            info.row, info.col, 
                            module.opts.Title_Border_Top_Thickness, 
                            module.opts.Title_Border_Bottom_Thickness, 
                            module.opts.Title_Border_Left_Thickness, 
                            module.opts.Title_Border_Right_Thickness, 
                            module.opts.Title_BorderInset, 
                            module.opts.Title_BorderGap,
                            module.opts.Title_Border_Color,
                            enable_highlight)

            local text_color = module.opts.Title_Text_Color

            if module.opts.Font_Titles == 1 then
                drawUTText(info.text, text_color, x + width / 2, y + height / 2, 1, module.opts.Font_Title_Shadow, module.opts.Text_Size/2)
            elseif module.opts.Font_Titles == 2 then
                drawSmallText(info.text, text_color, x + width / 2, y + height / 2, 1, module.opts.Font_Title_Shadow, module.opts.Text_Size)
            else
                drawText(info.text, text_color, x + width / 2, y + height / 2, 1, 1, module.opts.Text_Size)
            end

        end
        
    end

    if total_routes > 0 then
        value_map["avg_route_time"].value = total_time / total_routes
    else
        value_map["avg_route_time"].value = 0
    end

    local fade_in_duration = module.opts.Fade_In_Duration_Seconds
    local fade_out_duration = module.opts.Fade_Out_Duration_Seconds
    local time = game.realTimeSeconds()

    for key, value in pairs(value_map) do
        enable_highlight = false
        if key == "total_routes" then
            value.value = total_routes
        elseif key == "total_time" then
            value.value = total_time
        end
        if module.opts["Row" .. value.row] and module.opts["Col" .. value.col] then
            local visibleRow = countVisibleRows(value.row)
            local visibleCol = countVisibleCols(value.col)
            local x_bg = xpos + visibleCol * (cell_width + cell_spacing_x)
            local x_text
            if key == "total_time" then
                x_text = x_bg + (cell_width + cell_spacing_x)
            else
                x_text = x_bg + cell_width / 2
            end

            local y = ypos + visibleRow * (cell_height + cell_spacing_y)
            local color = module.opts.Value_Color
            local width = cell_width * (value.colspan or 1) + cell_spacing_x * ((value.colspan or 1) - 1)
            local height = cell_height
            local is_changing = value.previous_value ~= nil and value.value ~= value.previous_value
            local alpha = 0
    
            if is_changing then
                if value.change_start_time == nil then
                    value.change_start_time = time
                end
                alpha = math.min(1, (time - value.change_start_time) / fade_in_duration)
            elseif value.change_start_time ~= nil then
                alpha = 1 - math.min(1, (time - value.change_start_time) / fade_out_duration)
                if alpha == 0 then
                    value.change_start_time = nil
                end
            end

            local color = lerpColor(module.opts.Value_Color, module.opts.Changing_Value_Color, alpha)

            drawBackground(x_bg, y, x_bg + width, y + height, 
                            color, 
                            module.opts.Style, 
                            value.row, value.col, 
                            module.opts.Value_Border_Top_Thickness, 
                            module.opts.Value_Border_Bottom_Thickness, 
                            module.opts.Value_Border_Left_Thickness, 
                            module.opts.Value_Border_Right_Thickness, 
                            module.opts.Value_BorderInset, 
                            module.opts.Value_BorderGap,
                            module.opts.Value_Border_Color,
                            enable_highlight)

            local text_color = module.opts.Value_Text_Color

            if key == "total_time" then
                local formatted_time = formatTime(value.value)
                if module.opts.Font_Values == 1 then
                    drawUTText(formatted_time, text_color, x_text, y + cell_height / 2, 1, module.opts.Font_Value_Shadow, module.opts.Text_Size)
                elseif module.opts.Font_Values == 2 then
                    drawSmallText(formatted_time, text_color, x_text, y + cell_height / 2, 1, module.opts.Font_Value_Shadow, module.opts.Text_Size)
                else
                    drawText(formatted_time, text_color, x_text, y + cell_height / 2, 1, 1, module.opts.Text_Size)
                end
            else
                local value_to_display = math.floor(value.value)
                if key == "current_route_time" or key == "previous_route_time" or key == "avg_route_time" then
                    value_to_display = tostring(value_to_display) .. "s"
                end
                if module.opts.Font_Values == 1 then
                    drawUTText(value_to_display, text_color, x_text, y + cell_height / 2, 1, module.opts.Font_Value_Shadow, module.opts.Text_Size)
                elseif module.opts.Font_Values == 2 then
                    drawSmallText(value_to_display, text_color, x_text, y + cell_height / 2, 1, module.opts.Font_Value_Shadow, module.opts.Text_Size)
                else
                    drawText(value_to_display, text_color, x_text, y + cell_height / 2, 1, 1, module.opts.Text_Size)
                end
                value.previous_value = value.value
            end
            
            
        end
    end
    
end
return module
