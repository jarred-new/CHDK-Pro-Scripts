--[[
@title RAW Merger

@param n Number of RAW files
@default n 3
@range n 2 5

@param b Blend mode (0=Sum, 1=Average)
@default b 1
@range b 0 1

@param j Develop JPEG (0=No, 1=Yes)
@default j 1
@range j 0 1

@param c Cleanup originals (0=Keep, 1=Delete)
@default c 0
@range c 0 1
--]]

local ROOT = "A/"
local LOGFILE = "A/RAW_MERGE_METADATA.TXT"

local files = {}
local selected = {}
local merge_started = false
local merge_finished = false

-- ------------------------------------------------
-- Utility functions
-- ------------------------------------------------

local function message(s)
    print(s)
end

local function get_directory(path)
    local p = string.match(path, "^(.*/)")
    return p
end

local function get_basename(path)
    local name = string.match(path, "([^/]+)$")
    return name
end

local function get_extension(path)
    return string.upper(string.match(path, "(%.[^%.]+)$") or "")
end

local function write_log()
    local f = io.open(LOGFILE, "wb")

    if not f then
        message("Warning: Cannot write metadata log")
        return
    end

    f:write("CHDK RAW MERGER PRO\n")
    f:write("===================\n")
    f:write("Camera: Canon IXUS 75\n")
    f:write("Operation: " .. (b == 0 and "SUM" or "AVERAGE") .. "\n")
    f:write("RAW count: " .. tostring(n) .. "\n")
    f:write("Date: " .. os.date("%Y-%m-%d %H:%M:%S") .. "\n")

    f:write("\nINPUT FILES:\n")

    for i = 1, #files do
        f:write(tostring(i) .. ". " .. files[i] .. "\n")
    end

    f:write("\nMERGED RAW:\n")
    f:write(merged_raw .. "\n")

    f:write("\nJPEG DEVELOPMENT: " .. tostring(j) .. "\n")
    f:close()
end

-- ------------------------------------------------
-- Manual RAW selection
-- ------------------------------------------------

message("RAW MERGER PRO")
message("Select your RAW images.")

local common_dir = nil

for i = 1, n do

    message("Select image " .. i .. "/" .. n)

    local filename = file_browser(ROOT)

    if not filename or filename == "" then
        message("Cancelled. No merge performed.")
        return
    end

    -- Canon IXUS 75 CHDK RAW format
    if get_extension(filename) ~= ".CRW" then
        message("Invalid file: CHDK CRW required.")
        return
    end

    if selected[filename] then
        message("Duplicate file selected!")
        return
    end

    local directory = get_directory(filename)

    if not directory then
        message("Invalid file path!")
        return
    end

    if common_dir and directory ~= common_dir then
        message("Select files from the same folder!")
        return
    end

    common_dir = directory
    selected[filename] = true
    files[i] = filename

    message("Added: " .. get_basename(filename))
end

-- ------------------------------------------------
-- Determine merged RAW filename
-- ------------------------------------------------

local last_name = get_basename(files[n])
local base_name = string.gsub(last_name, "%.[^%.]+$", "")

-- CHDK RAW merger convention:
-- Result uses the last input filename with WAV extension.
merged_raw = common_dir .. base_name .. ".WAV"

message("Selected " .. n .. " RAW images.")
message("Output: " .. merged_raw)

-- ------------------------------------------------
-- Native RAW merging
-- ------------------------------------------------

message("Initializing RAW merger...")

local ok, err = pcall(function()

    raw_merge_start(b)
    merge_started = true

    for i = 1, n do

        message("Merging RAW " .. i .. "/" .. n)

        raw_merge_add(files[i])

    end

    message("Finishing RAW merge...")

    raw_merge_end()

    merge_started = false
    merge_finished = true

end)

if not ok then

    if merge_started then
        pcall(raw_merge_end)
        merge_started = false
    end

    message("RAW merge failed!")
    message(tostring(err))

    return
end

if not merge_finished then
    message("Merge was not completed.")
    return
end

message("RAW merge completed!")

-- ------------------------------------------------
-- Develop JPEG
-- ------------------------------------------------

if j == 1 then

    message("Preparing JPEG development...")

    if not get_mode() then
        message("Switch to RECORD mode and run again.")
        return
    end

    local develop_ok, develop_err = pcall(function()

        set_raw_develop(merged_raw)

        message("Developing merged RAW...")

        press("shoot_half")

        repeat
            sleep(10)
        until get_shooting()

        press("shoot_full")
        release("shoot_full")
        release("shoot_half")

        repeat
            sleep(50)
        until not get_shooting()

    end)

    if not develop_ok then

        set_raw_develop(nil)

        message("JPEG development failed!")
        message(tostring(develop_err))

        return
    end

    message("JPEG development completed.")
end

-- ------------------------------------------------
-- Metadata
-- ------------------------------------------------

write_log()

message("Metadata saved:")
message(LOGFILE)

-- ------------------------------------------------
-- Optional cleanup
-- ------------------------------------------------

if c == 1 then

    message("Deleting original RAW files...")

    local deleted = 0

    for i = 1, #files do

        local ok_delete = os.remove(files[i])

        if ok_delete then
            deleted = deleted + 1
            message("Deleted: " .. get_basename(files[i]))
        else
            message("Could not delete: " .. files[i])
        end

    end

    message("Deleted " .. deleted .. "/" .. n .. " files.")

else

    message("Original RAW files preserved.")

end

-- ------------------------------------------------
-- Finished
-- ------------------------------------------------

message("====================")
message("RAW MERGER FINISHED")
message("====================")
message("Review the JPEG in playback mode.")

