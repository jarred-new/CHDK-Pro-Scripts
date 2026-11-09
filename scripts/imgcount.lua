--[[
@title Image Count Checker
--]]

local disksize = get_disk_size()
local expc = get_exp_count()
local jpgc = get_jpg_count()
local rawc = get_raw_count()

print("SD Card Size: " .. disksize)
print("Exposure Count: " .. expc)
print("JPG Count: " .. jpgc)
print("Raw (DNG) Count: " .. rawc)