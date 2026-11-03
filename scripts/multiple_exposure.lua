--[[
@title Multi-Exposure Bracket
@chdk_version 1.3.0

@param   s Total Shots
@default s 2
@values  s 2 3 4 5

@param   m Exposure Mode
@default m 1
@values  m Native Equalized

@param   d Delay Between (ms)
@default d 300
@range   d 0 60000
--]]

local num_shots = s + 2
local mode = m
local original_ev = get_ev()

function restore()
    if original_ev ~= nil then
        set_ev(original_ev)
    end
end

set_exit_key("menu")

print("Multi-Exposure Ready.")
print("Shots to take: " .. num_shots)
if mode == 1 then
    print("Mode: Equalized exposure")
else
    print("Mode: Native exposure")
end
print("------------------------")
print("Separate files; no blending.")
print("SHUTTER: capture, MENU: exit.")

local ev_adjustment = 0
if mode == 1 then
    ev_adjustment = -math.floor(96 * math.log(num_shots) / math.log(2) + 0.5)
end

while true do
    wait_click(100)
    
    if is_key("shoot_full") then
        print("Starting sequence...")

        local completed = true
        for shot = 1, num_shots do
            print("Taking exposure " .. shot .. "/" .. num_shots)

            set_ev(original_ev + ev_adjustment)
            local result = shoot()
            if result ~= 0 then
                print("Capture failed: " .. tostring(result))
                completed = false
                break
            end

            if shot < num_shots then
                sleep(d)
            end
        end

        restore()
        if completed then
            print("Sequence complete.")
            print("Ready for next bracket.")
        else
            print("Sequence stopped early.")
        end
    end
end
