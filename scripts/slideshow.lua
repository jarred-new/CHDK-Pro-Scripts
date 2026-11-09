--[[
@title Custom Slideshow
@param a Change Delay (ms)
@default a 1000
@param b Wheel or Button (0=wheel, 1=button)
@default b 1
@range b 0 1
--]]

local capmode = require("capmode")

if capmode.get_name() == "PLAY" then
    print("Starting Slideshow")
    print("To stop slideshow, press MENU Button")  
    sleep(1000)  
    cls()
    
    while true do
        wait_click(a) -- seconds from parameters
      
        -- Check if the MENU button was the one clicked
        if is_key("menu") then
            break
        end
        
        if b == 1 then
            click("right")  -- going right
        elseif b == 0 then
            wheel_right()
        end
    end
else
    print("Please put it on play mode...")
end

print("Slideshow End...")
