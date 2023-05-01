local module = {}

module.name                = "evilGraphs"
module.opts                = {}
module.opts.X_Position     = 38.0
module.opts.Y_Position     = 95.0
module.opts.Speed_Graph_Width    = 204
module.opts.Speed_Graph_Height   = 24
module.opts.FrameTime_Graph_Width    = 204
module.opts.FrameTime_Graph_Height   = 24
module.opts.FPS_Graph_Width    = 204
module.opts.FPS_Graph_Height   = 24
module.opts.Ping_Graph_Width    = 204
module.opts.Ping_Graph_Height   = 24
module.opts.Energy_Graph_Width    = 204
module.opts.Energy_Graph_Height   = 24
module.opts.Energy_Line_Color = rgb(0, 133, 196)
module.opts.Speed_Line_Color = rgb(255, 255, 196)
module.opts.Ping_Line_Color = rgb(250, 250, 250)
module.opts.FPS_Line_Color = rgb(0, 250, 0)
module.opts.FrameTime_Line_Color = rgb(250, 100, 0)
module.opts.Background_Color = rgba(0, 0, 0, 30)
module.opts.Grid_Color     = rgba(0, 255, 255, 25)
module.opts.Grid_Spacing   = 12
module.opts.Update_Interval = 0.05 
module.opts.Text_Update_Interval = 0.2 
module.opts.Label_Color    = rgba(255, 255, 255, 255)
module.opts.Font_Type      = 2 
module.opts.Font_Size      = 1
module.opts.FPS_Font_Alignment = 0
module.opts.Ping_Font_Alignment = 0
module.opts.FrameTime_Font_Alignment = 0
module.opts.Shadow_Size    = 1
module.opts.Border_Top_Thickness         = 1 
module.opts.Border_Bottom_Thickness         = 1 
module.opts.Border_Right_Thickness         = 1 
module.opts.Border_Left_Thickness         = 1 
module.opts.Border_Gap     = 0 
module.opts.Border_Color   = rgba(255, 255, 255, 255)
module.opts.Font_Spacing        = 2
module.opts.Label_X_Offset = 0
module.opts.Label_Y_Offset = 0
module.opts.Gradient_Background = true
module.opts.Gradient_Steps  = 15
module.opts.Ping_Gradient_Direction = 1 
module.opts.Energy_Gradient_Direction = 0
module.opts.FPS_Gradient_Direction = 1
module.opts.FrameTime_Gradient_Direction = 1
module.opts.Speed_Gradient_Direction = 0
module.opts.Enable_Frame_Rate_Graph = true
module.opts.Enable_Frame_Time_Graph = true
module.opts.Frame_Time_Graph_X_Offset = 0
module.opts.Frame_Time_Graph_Y_Offset = -50
module.opts.Max_Graph_History_Size = 60
module.opts.Enable_Ping_Graph = true
module.opts.Ping_Graph_X_Offset = 0
module.opts.Ping_Graph_Y_Offset = -100
module.opts.Graph_Spacing = 0
module.opts.FPS_Graph_X_Offset = 0
module.opts.FPS_Graph_Y_Offset = 0
module.opts.Border_Inset = 0

module.opts.Show_FPS_Text = true
module.opts.Show_FrameTime_Text = true
module.opts.Show_Ping_Text = true

module.opts.FPS_Gradient_Color1 = rgba(0, 250, 255, 75)
module.opts.FPS_Gradient_Color2 = rgba(55, 150, 255, 75)
module.opts.FrameTime_Gradient_Color1 = rgba(250, 150, 055, 75)
module.opts.FrameTime_Gradient_Color2 = rgba(255, 150, 255, 75)
module.opts.Ping_Gradient_Color1 = rgba(0, 0, 0, 75)
module.opts.Ping_Gradient_Color2 = rgba(55, 150, 0, 75)
module.opts.Enable_Speed_Graph = true
module.opts.Speed_Graph_X_Offset = 0
module.opts.Speed_Graph_Y_Offset = -150
module.opts.Speed_Gradient_Color1 = rgba(240, 170, 41, 128)
module.opts.Speed_Gradient_Color2 = rgba(59, 48, 27, 128)
module.opts.Show_Speed_Text = true
module.opts.Speed_Font_Alignment = 0
module.opts.Enable_Energy_Graph = true
module.opts.Energy_Graph_X_Offset = 0
module.opts.Energy_Graph_Y_Offset = -200

module.opts.Energy_Gradient_Color1 = rgba(65, 124, 221, 100)
module.opts.Energy_Gradient_Color2 = rgba(65, 73, 87, 150)
module.opts.Show_Energy_Text = true
module.opts.Energy_Font_Alignment = 0

module.opts.ToggleFrameRateGraphKey = " "
module.opts.ToggleFrameTimeGraphKey = " "
module.opts.ToggleEnergyGraphKey = " "
module.opts.ToggleSpeedGraphKey = " "
module.opts.TogglePingGraphKey = " "
module.opts.ToggleAllGraphsKey = "CapsLock"






local pingHistory = {}
local frameTimeHistory = {}
local frameTimeHistory = {}
local speedHistory = {}
local energyHistory = {}
local prevMaxGraphHistorySize = module.opts.Max_Graph_History_Size
local lastFrameTime = 0
local lastUpdateTime = 0
local lastTextUpdateTime = 0
local currentFps = 0
local onePercentLow = 0
local lastAliveState = false
local currentPing = 0
local lastPingUpdateTime = 0
local lastTextUpdateTime = 0

local function toggleGraph(graphName, key, eventType, ctrl, shift, alt)
    if eventType == enums.INPUT_EVENT_TYPE_PRESSED then
        module.opts[graphName] = not module.opts[graphName]
    end
end

local function toggleAllGraphs(key, eventType, ctrl, shift, alt)
    if eventType == enums.INPUT_EVENT_TYPE_PRESSED then
        local toggle = not module.opts.Enable_Frame_Rate_Graph
        module.opts.Enable_Frame_Rate_Graph = toggle
        module.opts.Enable_Frame_Time_Graph = toggle
        module.opts.Enable_Energy_Graph = toggle
        module.opts.Enable_Speed_Graph = toggle
        module.opts.Enable_Ping_Graph = toggle
    end
end

bindKey(module.opts.ToggleFrameRateGraphKey, enums.INPUT_EVENT_TYPE_PRESSED, function(key, eventType, ctrl, shift, alt)
    toggleGraph("Enable_Frame_Rate_Graph", key, eventType, ctrl, shift, alt)
end)

bindKey(module.opts.ToggleFrameTimeGraphKey, enums.INPUT_EVENT_TYPE_PRESSED, function(key, eventType, ctrl, shift, alt)
    toggleGraph("Enable_Frame_Time_Graph", key, eventType, ctrl, shift, alt)
end)

bindKey(module.opts.ToggleEnergyGraphKey, enums.INPUT_EVENT_TYPE_PRESSED, function(key, eventType, ctrl, shift, alt)
    toggleGraph("Enable_Energy_Graph", key, eventType, ctrl, shift, alt)
end)

bindKey(module.opts.ToggleSpeedGraphKey, enums.INPUT_EVENT_TYPE_PRESSED, function(key, eventType, ctrl, shift, alt)
    toggleGraph("Enable_Speed_Graph", key, eventType, ctrl, shift, alt)
end)

bindKey(module.opts.TogglePingGraphKey, enums.INPUT_EVENT_TYPE_PRESSED, function(key, eventType, ctrl, shift, alt)
    toggleGraph("Enable_Ping_Graph", key, eventType, ctrl, shift, alt)
end)

bindKey(module.opts.ToggleAllGraphsKey, enums.INPUT_EVENT_TYPE_PRESSED, toggleAllGraphs)


function updateEnergyHistory(energy)
    table.insert(energyHistory, energy)
    if #energyHistory > module.opts.Max_Graph_History_Size then
        table.remove(energyHistory, 1)
    end
end

function updatePingHistory(ping)
    table.insert(pingHistory, ping)
    if #pingHistory > module.opts.Max_Graph_History_Size then
        table.remove(pingHistory, 1)
    end
end
function updateSpeedHistory(speed)
    table.insert(speedHistory, speed)
    if #speedHistory > module.opts.Max_Graph_History_Size then
        table.remove(speedHistory, 1)
    end
end

local function drawCustomText(text, color, x, y, alignment, fontSize, shadowSize)
    if module.opts.Font_Type == 1 then
        drawText(text, color, x, y, alignment, fontSize)
    elseif module.opts.Font_Type == 2 then
        drawSmallText(text, color, x, y, alignment, shadowSize, fontSize)
    elseif module.opts.Font_Type == 3 then
        drawUTText(text, color, x, y, alignment, shadowSize, fontSize)
    end
end


function drawBorder(x1, y1, x2, y2, gap, color)
    local inset = module.opts.Border_Inset
    drawRect(x1 + gap + inset, y1 - module.opts.Border_Top_Thickness + inset, x2 - gap - inset, y1 + inset, color) -- top border
    drawRect(x1 + gap + inset, y2 - inset, x2 - gap - inset, y2 + module.opts.Border_Bottom_Thickness - inset, color) -- bottom border
    drawRect(x1 - module.opts.Border_Left_Thickness + inset, y1 + gap + inset, x1 + inset, y2 - gap - inset, color) -- left border
    drawRect(x2 - inset, y1 + gap + inset, x2 + module.opts.Border_Right_Thickness - inset, y2 - gap - inset, color) -- right border
end




function resetVariables()
    fpsHistory = {}
    frameTimeHistory = {}  
    pingHistory = {}       
    lastFrameTime = 0
    lastUpdateTime = 0
    lastTextUpdateTime = 0
    currentFps = 0
    onePercentLow = 0
    avgFrameTime = 0       
    onePercentHigh = 0    
    currentPing = 0   
end


function updateFpsHistory(fps)
    table.insert(fpsHistory, fps)
    if #fpsHistory > module.opts.Max_Graph_History_Size then
        table.remove(fpsHistory, 1)
    end
end

function calculateLowPercentile(percentile)
    local sortedFpsHistory = {}
    for i, v in ipairs(fpsHistory) do
        sortedFpsHistory[i] = v
    end
    table.sort(sortedFpsHistory)
    local index = math.ceil(#sortedFpsHistory * percentile)
    return sortedFpsHistory[index]
end

function updateFrameTimeHistory(frameTime)
    table.insert(frameTimeHistory, frameTime)
    if #frameTimeHistory > module.opts.Max_Graph_History_Size then
        table.remove(frameTimeHistory, 1)
    end
end



function calculateHighPercentile(percentile)
    local sortedFrameTimeHistory = {}
    for i, v in ipairs(frameTimeHistory) do
        sortedFrameTimeHistory[i] = v
    end
    table.sort(sortedFrameTimeHistory, function(a, b) return a > b end)
    local index = math.ceil(#sortedFrameTimeHistory * percentile)
    return sortedFrameTimeHistory[index]
end

function drawGradientRect(x1, y1, x2, y2, color1, color2, steps, gradientDirection)
    local width = x2 - x1
    local height = y2 - y1
    local stepWidth = width / steps
    local stepHeight = height / steps
    
    if gradientDirection == 1 then
        for i = 0, steps - 1 do
            local t = i / (steps - 1)
            local color = lerpColor(color1, color2, t)
            drawRect(x1 + i * stepWidth, y1, x1 + (i + 1) * stepWidth, y2, color)
        end
    else
        for i = 0, steps - 1 do
            local t = i / (steps - 1)
            local color = lerpColor(color1, color2, t)
            drawRect(x1, y1 + i * stepHeight, x2, y1 + (i + 1) * stepHeight, color)
        end
    end
end

function calculateAverageFrameTime()
    local totalFrameTime = 0
    local count = #frameTimeHistory

    if count == 0 then
        return nil
    end

    for _, frameTime in ipairs(frameTimeHistory) do
        totalFrameTime = totalFrameTime + frameTime
    end

    return totalFrameTime / count
end


function drawPingGraph(xpos, ypos)
    if module.opts.Gradient_Background then
        drawGradientRect(xpos, ypos, xpos + module.opts.Ping_Graph_Width, ypos + module.opts.Ping_Graph_Height, module.opts.Ping_Gradient_Color1, module.opts.Ping_Gradient_Color2, module.opts.Gradient_Steps, module.opts.Ping_Gradient_Direction)
    else
        drawRect(xpos, ypos, xpos + module.opts.Ping_Graph_Width, ypos + module.opts.Ping_Graph_Height, module.opts.Background_Color)
    end

    local gridThickness = 1
    for i = 0, module.opts.Ping_Graph_Width, module.opts.Grid_Spacing do
        drawRect(xpos + i - gridThickness / 2, ypos, xpos + i + gridThickness / 2, ypos + module.opts.Ping_Graph_Height, module.opts.Grid_Color)
    end

    for i = 0, module.opts.Ping_Graph_Height, module.opts.Grid_Spacing do
        drawRect(xpos, ypos + i - gridThickness / 2, xpos + module.opts.Ping_Graph_Width, ypos + i + gridThickness / 2, module.opts.Grid_Color)
    end

    local maxPing = 0
    if #pingHistory > 0 then
        maxPing = math.max(table.unpack(pingHistory))
    end
    local scaleX = module.opts.Ping_Graph_Width / (module.opts.Max_Graph_History_Size - 1)
    local scaleY = (module.opts.Ping_Graph_Height - 6) / maxPing

    for i = 2, #pingHistory do
        local x1 = xpos + (i - 2) * scaleX
        local x2 = xpos + (i - 1) * scaleX
        local y1 = ypos + module.opts.Ping_Graph_Height - pingHistory[i - 1] * scaleY - 3
        local y2 = ypos + module.opts.Ping_Graph_Height - pingHistory[i] * scaleY - 3        

        draw2dLine(x1, y1, x2, y2, module.opts.Ping_Line_Color)
    end

    local labelX = xpos + module.opts.Ping_Graph_Width + 5 + module.opts.Label_X_Offset
    local labelY = ypos + module.opts.Label_Y_Offset
    local labelSpacing = 16

    if module.opts.Show_Ping_Text then
        drawCustomText(string.format("Ping: %.0f ms", currentPing), module.opts.Label_Color, labelX, labelY + module.opts.Font_Spacing, module.opts.Ping_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
    end

    drawBorder(xpos, ypos, xpos + module.opts.Ping_Graph_Width, ypos + module.opts.Ping_Graph_Height, module.opts.Border_Gap, module.opts.Border_Color)

end

function drawFrameRateGraph(xpos, ypos)
    if module.opts.Gradient_Background then
        drawGradientRect(xpos, ypos, xpos + module.opts.FPS_Graph_Width, ypos + module.opts.FPS_Graph_Height, module.opts.FPS_Gradient_Color1, module.opts.FPS_Gradient_Color2, module.opts.Gradient_Steps, module.opts.FPS_Gradient_Direction)
    else
        drawRect(xpos, ypos, xpos + module.opts.FPS_Graph_Width, ypos + module.opts.FPS_Graph_Height, module.opts.Background_Color)
    end
    

    local gridThickness = 1
    for i = 0, module.opts.FPS_Graph_Width, module.opts.Grid_Spacing do
        drawRect(xpos + i - gridThickness / 2, ypos, xpos + i + gridThickness / 2, ypos + module.opts.FPS_Graph_Height, module.opts.Grid_Color)
    end

    for i = 0, module.opts.FPS_Graph_Height, module.opts.Grid_Spacing do
        drawRect(xpos, ypos + i - gridThickness / 2, xpos + module.opts.FPS_Graph_Width, ypos + i + gridThickness / 2, module.opts.Grid_Color)
    end

    local maxFps = math.max(table.unpack(fpsHistory))
    local scaleX = module.opts.FPS_Graph_Width / (module.opts.Max_Graph_History_Size - 1)
    local scaleY = (module.opts.FPS_Graph_Height - 6) / maxFps

    for i = 2, #fpsHistory do
        local x1 = xpos + (i - 2) * scaleX
        local x2 = xpos + (i - 1) * scaleX
        local y1 = ypos + module.opts.FPS_Graph_Height - fpsHistory[i - 1] * scaleY - 3
        local y2 = ypos + module.opts.FPS_Graph_Height - fpsHistory[i] * scaleY - 3

        draw2dLine(x1, y1, x2, y2, module.opts.FPS_Line_Color)
    end

    local labelX = xpos + module.opts.FPS_Graph_Width + 5 + module.opts.Label_X_Offset
    local labelY = ypos + module.opts.Label_Y_Offset
    local labelSpacing = 16

    if module.opts.Show_FPS_Text then
        drawCustomText(string.format("FPS: %.0f", currentFps), module.opts.Label_Color, labelX, labelY + module.opts.Font_Spacing, module.opts.FPS_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
    drawCustomText(string.format("1%% Low: %.0f", onePercentLow), module.opts.Label_Color, labelX, labelY + module.opts.Font_Size * 16 + 2 * module.opts.Font_Spacing, module.opts.FPS_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
    end


    drawBorder(xpos, ypos, xpos + module.opts.FPS_Graph_Width, ypos + module.opts.FPS_Graph_Height, module.opts.Border_Gap, module.opts.Border_Color)
    
end

function drawFrameTimeGraph(xpos, ypos)
    if module.opts.Gradient_Background then
        drawGradientRect(xpos, ypos, xpos + module.opts.FrameTime_Graph_Width, ypos + module.opts.FrameTime_Graph_Height, module.opts.FrameTime_Gradient_Color1, module.opts.FrameTime_Gradient_Color2, module.opts.Gradient_Steps, module.opts.FrameTime_Gradient_Direction)
    else
        drawRect(xpos, ypos, xpos + module.opts.FrameTime_Graph_Width, ypos + module.opts.FrameTime_Graph_Height, module.opts.Background_Color)
    end

    
    local gridThickness = 1
    for i = 0, module.opts.FrameTime_Graph_Width, module.opts.Grid_Spacing do
        drawRect(xpos + i - gridThickness / 2, ypos, xpos + i + gridThickness / 2, ypos + module.opts.FrameTime_Graph_Height, module.opts.Grid_Color)
    end

    for i = 0, module.opts.FrameTime_Graph_Height, module.opts.Grid_Spacing do
        drawRect(xpos, ypos + i - gridThickness / 2, xpos + module.opts.FrameTime_Graph_Width, ypos + i + gridThickness / 2, module.opts.Grid_Color)
    end

    local maxFrameTime = math.max(table.unpack(frameTimeHistory))
    local scaleX = module.opts.FrameTime_Graph_Width / (module.opts.Max_Graph_History_Size - 1)
    local scaleY = (module.opts.FrameTime_Graph_Height - 6) / maxFrameTime

    for i = 2, #frameTimeHistory do
        local x1 = xpos + (i - 2) * scaleX
        local x2 = xpos + (i - 1) * scaleX
        local y1 = ypos + module.opts.FrameTime_Graph_Height - frameTimeHistory[i - 1] * scaleY - 3
        local y2 = ypos + module.opts.FrameTime_Graph_Height - frameTimeHistory[i] * scaleY - 3



        draw2dLine(x1, y1, x2, y2, module.opts.FrameTime_Line_Color)
    end

    local labelX = xpos + module.opts.FrameTime_Graph_Width + 5 + module.opts.Label_X_Offset
    local labelY = ypos + module.opts.Label_Y_Offset
    local labelSpacing = 16

    if module.opts.Show_FrameTime_Text then
        drawCustomText(string.format("Avg Frame Time: %.2f ms", avgFrameTime), module.opts.Label_Color, labelX, labelY + module.opts.Font_Spacing, module.opts.FrameTime_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
        drawCustomText(string.format("1%% High: %.2f ms", onePercentHigh), module.opts.Label_Color, labelX, labelY + module.opts.Font_Size * 16 + 2 * module.opts.Font_Spacing, module.opts.FrameTime_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
    end


    drawBorder(xpos, ypos, xpos + module.opts.FrameTime_Graph_Width, ypos + module.opts.FrameTime_Graph_Height, module.opts.Border_Gap, module.opts.Border_Color)

end

function drawSpeedGraph(xpos, ypos)
    if module.opts.Gradient_Background then
        drawGradientRect(xpos, ypos, xpos + module.opts.Speed_Graph_Width, ypos + module.opts.Speed_Graph_Height, module.opts.Speed_Gradient_Color1, module.opts.Speed_Gradient_Color2, module.opts.Gradient_Steps, module.opts.Speed_Gradient_Direction)
    else
        drawRect(xpos, ypos, xpos + module.opts.Speed_Graph_Width, ypos + module.opts.Speed_Graph_Height, module.opts.Background_Color)
    end

    local gridThickness = 1
    for i = 0, module.opts.Speed_Graph_Width, module.opts.Grid_Spacing do
        drawRect(xpos + i - gridThickness / 2, ypos, xpos + i + gridThickness / 2, ypos + module.opts.Speed_Graph_Height, module.opts.Grid_Color)
    end

    for i = 0, module.opts.Speed_Graph_Height, module.opts.Grid_Spacing do
        drawRect(xpos, ypos + i - gridThickness / 2, xpos + module.opts.Speed_Graph_Width, ypos + i + gridThickness / 2, module.opts.Grid_Color)
    end

    local maxSpeed = math.max(table.unpack(speedHistory))
    local scaleX = module.opts.Speed_Graph_Width / (module.opts.Max_Graph_History_Size - 1)
    local scaleY = (module.opts.Speed_Graph_Height - 6) / maxSpeed

    for i = 2, #speedHistory do
        local x1 = xpos + (i - 2) * scaleX
        local x2 = xpos + (i - 1) * scaleX
        local y1 = ypos + module.opts.Speed_Graph_Height - speedHistory[i - 1] * scaleY - 3
        local y2 = ypos + module.opts.Speed_Graph_Height - speedHistory[i] * scaleY - 3

        draw2dLine(x1, y1, x2, y2, module.opts.Speed_Line_Color)
    end

    local labelX = xpos + module.opts.Speed_Graph_Width + 5 + module.opts.Label_X_Offset
    local labelY = ypos + module.opts.Label_Y_Offset
    local labelSpacing = 16

    if module.opts.Show_Speed_Text then
        drawCustomText(string.format("Speed: %.0f", speedHistory[#speedHistory] or 0), module.opts.Label_Color, labelX, labelY + module.opts.Font_Spacing, module.opts.Speed_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
    end

    drawBorder(xpos, ypos, xpos + module.opts.Speed_Graph_Width, ypos + module.opts.Speed_Graph_Height, module.opts.Border_Gap, module.opts.Border_Color)
end

function drawEnergyGraph(xpos, ypos)
    if module.opts.Gradient_Background then
        drawGradientRect(xpos, ypos, xpos + module.opts.Energy_Graph_Width, ypos + module.opts.Energy_Graph_Height, module.opts.Energy_Gradient_Color1, module.opts.Energy_Gradient_Color2, module.opts.Gradient_Steps, module.opts.Energy_Gradient_Direction)
    else
        drawRect(xpos, ypos, xpos + module.opts.Energy_Graph_Width, ypos + module.opts.Energy_Graph_Height, module.opts.Background_Color)
    end

    local gridThickness = 1
    for i = 0, module.opts.Energy_Graph_Width, module.opts.Grid_Spacing do
        drawRect(xpos + i - gridThickness / 2, ypos, xpos + i + gridThickness / 2, ypos + module.opts.Energy_Graph_Height, module.opts.Grid_Color)
    end

    for i = 0, module.opts.Energy_Graph_Height, module.opts.Grid_Spacing do
        drawRect(xpos, ypos + i - gridThickness / 2, xpos + module.opts.Energy_Graph_Width, ypos + i + gridThickness / 2, module.opts.Grid_Color)
    end

    local maxEnergy = math.max(table.unpack(energyHistory))
    local scaleX = module.opts.Energy_Graph_Width / (module.opts.Max_Graph_History_Size -1)
    local scaleY = (module.opts.Energy_Graph_Height - 6) / maxEnergy


    for i = 2, #energyHistory do
        local x1 = xpos + (i - 2) * scaleX
        local x2 = xpos + (i - 1) * scaleX
        local y1 = ypos + module.opts.Energy_Graph_Height - energyHistory[i - 1] * scaleY - 3
        local y2 = ypos + module.opts.Energy_Graph_Height - energyHistory[i] * scaleY - 3
        draw2dLine(x1, y1, x2, y2, module.opts.Energy_Line_Color)
    end
    
    

    local labelX = xpos + module.opts.Energy_Graph_Width + 5 + module.opts.Label_X_Offset
    local labelY = ypos + module.opts.Label_Y_Offset
    local labelSpacing = 16

    if module.opts.Show_Energy_Text then
        drawCustomText(string.format("Energy: %.0f", energyHistory[#energyHistory] or 0), module.opts.Label_Color, labelX, labelY + module.opts.Font_Spacing, module.opts.Energy_Font_Alignment, module.opts.Font_Size, module.opts.Shadow_Size)
    end

    drawBorder(xpos, ypos, xpos + module.opts.Energy_Graph_Width, ypos + module.opts.Energy_Graph_Height, module.opts.Border_Gap, module.opts.Border_Color)
end

function module.draw(res_x, res_y)
    local currentPlayerAlive = hud_data.alive

    if currentPlayerAlive ~= lastAliveState then
        if currentPlayerAlive then
            resetVariables()
        end
        lastAliveState = currentPlayerAlive
    end

    if prevMaxGraphHistorySize ~= module.opts.Max_Graph_History_Size then
        fpsHistory = {}
        frameTimeHistory = {}
        prevMaxGraphHistorySize = module.opts.Max_Graph_History_Size
    end

    if not currentPlayerAlive then return end

    local xpos = math.floor(module.opts.X_Position / 100 * res_x)
    local ypos = math.floor(module.opts.Y_Position / 100 * res_y)

    local time = game.realTimeSeconds()

    if time - lastUpdateTime >= module.opts.Update_Interval then
        local fps = 1 / (time - lastFrameTime)
        updateFpsHistory(fps)
        updateFrameTimeHistory(1000 / fps) 
        lastUpdateTime = time
        updateSpeedHistory(player.speed())
        updateEnergyHistory(player.energy())

    end

    currentFps = fpsHistory[#fpsHistory] or 0
    onePercentLow = calculateLowPercentile(0.01) or 0
    avgFrameTime = calculateAverageFrameTime() or 0
    onePercentHigh = calculateHighPercentile(0.01) or 0
    currentPing = player.ping()


    lastFrameTime = game.realTimeSeconds()

    if module.opts.Enable_Speed_Graph then
        drawSpeedGraph(xpos + module.opts.Speed_Graph_X_Offset, ypos + module.opts.Speed_Graph_Y_Offset + 3 * module.opts.Graph_Spacing)
    end
    
        
    if module.opts.Enable_Frame_Rate_Graph then
        drawFrameRateGraph(xpos + module.opts.FPS_Graph_X_Offset, ypos + module.opts.FPS_Graph_Y_Offset)
    end
    
    if module.opts.Enable_Frame_Time_Graph then
        drawFrameTimeGraph(xpos + module.opts.Frame_Time_Graph_X_Offset, ypos + module.opts.Frame_Time_Graph_Y_Offset + module.opts.Graph_Spacing)
    end

    if module.opts.Enable_Energy_Graph then
        drawEnergyGraph(xpos + module.opts.Energy_Graph_X_Offset, ypos + module.opts.Energy_Graph_Y_Offset + 3 * module.opts.Graph_Spacing)
    end
    

    if module.opts.Enable_Ping_Graph then
        local ping = player.ping()

        if time - lastPingUpdateTime >= module.opts.Update_Interval then
            updatePingHistory(ping)
            lastPingUpdateTime = time
        end

        if time - lastTextUpdateTime >= module.opts.Text_Update_Interval then
            currentPing = pingHistory[#pingHistory] or 0
            lastTextUpdateTime = time
        end

        drawPingGraph(xpos + module.opts.Ping_Graph_X_Offset, ypos + module.opts.Ping_Graph_Y_Offset + 2 * module.opts.Graph_Spacing)
    end   
end

return module
