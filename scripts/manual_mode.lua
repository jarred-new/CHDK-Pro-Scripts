--[[
@title DSLR Manual Mode
@chdk_version 1.6.1

@param t Shutter Speed
@default t 4
@values t 0 1 2 3 4 5 6 7 8 9 10

@param i ISO Value
@default i 1
@values i 0 1 2 3 4 5

@param n ND Filter
@default n 0
@values n 0 1
--]]

local tv96_table = {
    957,  -- 1/1000
    861,  -- 1/500
    765,  -- 1/250
    669,  -- 1/125
    566,  -- 1/60
    470,  -- 1/30
    374,  -- 1/15
    192,  -- 1/4
    0,    -- 1s
    -96,  -- 2s
    -192  -- 4s
}

local iso_table = {80, 100, 200, 400, 800, 1600}

local shutter_display_strings = {
    "1/1000", "1/500", "1/250", "1/125", "1/60",
    "1/30", "1/15", "1/4", "1s", "2s", "4s"
}

local function clear_overrides()
    pcall(set_iso_market, 0)
    pcall(set_nd_filter, 0)
end

print("Initializing Manual Mode...")

local ok, err = pcall(function()
    set_iso_market(iso_table[i + 1])

    if n == 0 then
        set_nd_filter(2) -- ND out
    else
        set_nd_filter(1) -- ND in
    end

    print("------------------------")
    print(" Shutter: " .. shutter_display_strings[t + 1])
    print(" ISO    : " .. iso_table[i + 1])
    print(" ND Filt: " .. (n == 0 and "OUT" or "IN"))
    print("------------------------")
    print("Press SHUTTER to shoot.")
    print("Press MENU to exit.")

    while true do
        wait_click(100)

        if is_key("menu") then
            break
        end

        if is_key("shoot_full") then
            print("Capturing manual frame...")
            set_tv96_direct(tv96_table[t + 1])
            shoot()
            print("Shot captured.")
        end
    end
end)

clear_overrides()

if not ok then
    print("Script error: " .. tostring(err))
end

print("Manual Mode Closed.")
