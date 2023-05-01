
local module = {}

module.name = "evilHitmarkers"
module.opts = {
    Color = rgb(255, 0, 0),
    Display_Duration = 0.15,
    Hitmarker_Length = 13,
    Hitmarker_Gap = 5,
    Thickness = 3,
}

local damage_numbers = {}
-- List of values used to cycle through rainbow colors
local color_list = {rgb(255, 0, 0), rgb(255, 127, 0), rgb(255, 255, 0), rgb(127, 255, 0),
		    rgb(0, 255, 0), rgb(0, 255, 127), rgb(0, 255, 255), rgb(0, 127, 255),
		    rgb(0, 0, 255), rgb(127, 0, 255), rgb(255, 0, 255), rgb(255, 0, 127)}
-- The current index in the rainbow color
local color_idx = 0

-- Save reference to any existing onDamageNumberCreate handler
local onDamageNumberCreateOld
if type(onDamageNumberCreate) == "function" then
    onDamageNumberCreateOld = onDamageNumberCreate
end

-- onDamageNumberCreate function
function damageNumberCreate(dam_nums, number, loc, is_shield)
    if number < damageNumbersLimit then return end

    color_idx = color_idx + 1
    local num = DamageNumber(number, 1.70, loc, is_shield)
    if showRainbow == false then
        num.color = damageNumbersColorMin 
    else
        num.color = color_list[color_idx % 12 + 1]
    end
    dam_nums:add(num)
end

function onDamageNumberCreate(existingDamageNumbers, damage_value, location, is_shield)
    -- If there's an existing handler, call it
    if onDamageNumberCreateOld then onDamageNumberCreateOld(existingDamageNumbers, damage_value, location, is_shield) end

    -- Call the damageNumberCreate function
    damageNumberCreate(existingDamageNumbers, damage_value, location, is_shield)

    local damage_num = {
        value = damage_value,
        loc = location,
        shield = is_shield,
        timer = game.realTimeSeconds()
    }
    table.insert(damage_numbers, damage_num)
    return false -- Allow the default damage number behavior
end

local function lerp(start, finish, t)
    return start + (finish - start) * t
end

function module.draw(res_x, res_y)
    local current_time = game.realTimeSeconds()
    for i = #damage_numbers, 1, -1 do
        local damage_num = damage_numbers[i]

        if current_time - damage_num.timer > module.opts.Display_Duration then
            table.remove(damage_numbers, i)
        else
            local pos = 200
    
            local centerX = res_x / 2
            local centerY = res_y / 2
            local hitmarkerLength = module.opts.Hitmarker_Length
            local hitmarkerGap = module.opts.Hitmarker_Gap
            local thickness = module.opts.Thickness
    
            -- Calculate the fraction of the animation that has elapsed
            local elapsed_fraction = (current_time - damage_num.timer) / module.opts.Display_Duration
    
            -- Determine the length of the lines based on the elapsed fraction
            local line_length
            if elapsed_fraction < 0.25 then
                line_length = lerp(hitmarkerGap, hitmarkerLength, elapsed_fraction / 0.25)

            elseif elapsed_fraction < 0.75 then
                line_length = hitmarkerLength
            else
                line_length = lerp(hitmarkerLength, hitmarkerGap, (elapsed_fraction - 0.75) / 0.25)
            end
    
            -- Draw each line in parallel with an offset based on thickness
            for j = 0, thickness - 1 do
                

                -- Top-left to bottom-right line
                draw2dLine(centerX - line_length - j, centerY - line_length, centerX - hitmarkerGap - j, centerY - hitmarkerGap, module.opts.Color)
    
                -- Top-right to bottom-left line
                draw2dLine(centerX + line_length + j, centerY - line_length, centerX + hitmarkerGap + j, centerY - hitmarkerGap, module.opts.Color)
    
                -- Bottom-left to top-right line
                draw2dLine(centerX - line_length - j, centerY + line_length, centerX - hitmarkerGap - j, centerY + hitmarkerGap, module.opts.Color)
    
                -- Bottom-right to top-left line
                draw2dLine(centerX + line_length + j, centerY + line_length , centerX + hitmarkerGap + j, centerY + hitmarkerGap, module.opts.Color)
            end
        end
    end
end

return module