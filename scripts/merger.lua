--[[
@title Merge (RAW Only!)
@param r How Many Files
@default r 2
@range r 2 5
@param b Blending Type (0=sum, 1=average)
@default b 0
@range b 0 1
--]]

local defdir = "A/"

raw_merge_start(b) -- start merging here

for i = 1, r do
    print("Opening for No. " .. i)
    local selected_file = file_browser(defdir)

    if selected_file then
        raw_merge_add(selected_file)
    end
    
    assert(selected_file == "", "No File Selected, quitting and discarding")
end

raw_merge_end()
