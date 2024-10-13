-- xa-cabin.lua

-- Define SCRIPT_DIRECTORY if not already defined
if not SCRIPT_DIRECTORY then
    SCRIPT_DIRECTORY = debug.getinfo(1, "S").source:match("@?(.*/)")
end

-- Load required scripts
LIP = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/LIP.lua")
XA_CABIN_LOGGER = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/logging.lua")
HELPERS = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/helpers.lua")

-- Load settings and plane config first
XA_CABIN_SETTINGS = LIP.load(SCRIPT_DIRECTORY .. "xa-cabin.ini")

-- Load globals after settings
dofile(SCRIPT_DIRECTORY .. "/xa-cabin/globals.lua")

-- Now load scripts that depend on globals
local STATE = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/state.lua")
local GUI = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/GUI.lua")

-- Finally, load announcements
ANNOUNCEMENTS = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/announcement.lua")
-- Initialize Announcements
ANNOUNCEMENTS.loadSounds()
-- Check for imgui support
if not SUPPORTS_FLOATING_WINDOWS then
    logMsg("imgui not supported by your FlyWithLua version")
    return
end

-- Check if plane config file exists, if not, create it
local plane_config_file_path = AIRCRAFT_PATH .. "/xa-cabin.ini"

local plane_config_file = io.open(plane_config_file_path, "r")
if plane_config_file == nil then
    XA_CABIN_LOGGER.write_log("Creating new plane config file")
    LIP.save(plane_config_file_path, XA_CABIN_PLANE_CONFIG)
end

XA_CABIN_PLANE_CONFIG = LIP.load(AIRCRAFT_PATH .. "/xa-cabin.ini")

-- Handle potential legacy config
if XA_CABIN_PLANE_CONFIG.RWY_LIGHTS ~= nil then
    XA_CABIN_PLANE_CONFIG["LANDING_LIGHTS"] = XA_CABIN_PLANE_CONFIG.LANDING_LIGHTS
    XA_CABIN_PLANE_CONFIG.RWY_LIGHTS = nil
    LIP.save(AIRCRAFT_PATH .. "/xa-cabin.ini", XA_CABIN_PLANE_CONFIG)
    XA_CABIN_PLANE_CONFIG = LIP.load(AIRCRAFT_PATH .. "/xa-cabin.ini")
end

XA_CABIN_LOGGER.dumpTable(XA_CABIN_PLANE_CONFIG)
XA_CABIN_LOGGER.write_log("Loaded plane config file")

-- Load Simbrief script
SIMBRIEF = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/simbrief.lua")

-- GUI Building Function
function xa_cabin_on_build(xa_cabin_wnd, x, y)
    local win_width = imgui.GetWindowWidth()
    local win_height = imgui.GetWindowHeight()
    imgui.Columns(2)
    imgui.SetColumnWidth(0, win_width * 0.5)

    GUI.SimbriefInfo(win_width, win_height)
    imgui.NextColumn()

    GUI.Configuration(win_width, win_height)
    imgui.Columns()

    imgui.Separator()
    imgui.Spacing()
    imgui.Spacing()
    imgui.Spacing()
    imgui.Spacing()

    GUI.Announcements(win_width, win_height)
end

-- Show/Hide Window Functions
xa_cabin_wnd = nil

function xa_cabin_show_wnd()
    xa_cabin_wnd = float_wnd_create(680, 500, 1, true)
    float_wnd_set_title(xa_cabin_wnd, "XA Cabin " .. XA_CABIN_VERSION)
    float_wnd_set_imgui_builder(xa_cabin_wnd, "xa_cabin_on_build")
end

function xa_cabin_hide_wnd()
    if xa_cabin_wnd then
        float_wnd_destroy(xa_cabin_wnd)
    end
end

xa_cabin_show_only_once = 0
xa_cabin_hide_only_once = 0

function toggle_xa_cabin_window()
    xa_cabin_show_window = not xa_cabin_show_window
    if xa_cabin_show_window then
        if xa_cabin_show_only_once == 0 then
            xa_cabin_show_wnd()
            xa_cabin_show_only_once = 1
            xa_cabin_hide_only_once = 0
        end
    else
        if xa_cabin_hide_only_once == 0 then
            xa_cabin_hide_wnd()
            xa_cabin_hide_only_once = 1
            xa_cabin_show_only_once = 0
        end
    end
end

-- Add Macro and Command
add_macro("XA Cabin", "xa_cabin_show_wnd()", "xa_cabin_hide_wnd()", "activate")
create_command("xa_cabin_menus/show_toggle", "open/close XA Cabin Menu window", "toggle_xa_cabin_window()", "", "")

-- Update State Function
function xa_cabin_update_state()
    local status, err = pcall(STATE.update_flight_state)
    if not status then
        XA_CABIN_LOGGER.write_log("Error in update flight state: " .. err)
    end

    local status2, err2 = pcall(STATE.update_cabin_state)
    if not status2 then
        XA_CABIN_LOGGER.write_log("Error in update cabin state: " .. err2)
    end
end

-- Function to Generate Announcements
function generate_announcements()
    local airline = SIMBRIEF["Airline"] or "Datanised Airlines"
    local flight_number = SIMBRIEF["Callsign"] or "DAT01"
    local destination = SIMBRIEF["DestName"] or "SBSP"
    local eta_seconds = SIMBRIEF["Ete"] or 0
    local eta_hours = math.floor(eta_seconds / 3600)
    local eta_minutes = math.floor((eta_seconds % 3600) / 60)
    local eta = string.format("%d hours and %d minutes", eta_hours, eta_minutes)

    -- New variables for runway, altitude, etc.
    local departure_runway = SIMBRIEF["OrigRwy"] or "Runway 01"
    local arrival_runway = SIMBRIEF["DestRwy"] or "Runway 02"
    local cruise_altitude = SIMBRIEF["Level"] or "35,000 ft"
    local flight_time_hours = eta_hours
    local flight_time_minutes = eta_minutes
    local local_time_at_destination = SIMBRIEF["DestTime"] or "12:00 PM"
    local aircraft_type = SIMBRIEF["AircraftType"] or "Boeing 737"
    local local_time_sec_ref = dataref_table("sim/time/local_time_sec")
    -- Function to classify time of day based on local time seconds
    function get_time_of_day()
        -- Get the time in seconds since midnight from the dataref
        local time_in_seconds = local_time_sec_ref[0]
        -- Convert seconds to hours (since midnight)
        local time_in_hours = time_in_seconds / 3600

        -- Determine time of day based on hours
        if time_in_hours >= 5 and time_in_hours < 12 then
            return "morning"
        elseif time_in_hours >= 12 and time_in_hours < 18 then
            return "afternoon"
        else
            return "night"
        end
    end
    local time_of_day = get_time_of_day()
    -- Language, accent, and speaker from configuration
    local language = XA_CABIN_LANGUAGE or "en"
    local accent = XA_CABIN_ACCENT or "gb"
    local speaker = XA_CABIN_SETTINGS.announcement.speaker or "01"  -- Ensure 'speaker' is fetched

    local python_script_path = SCRIPT_DIRECTORY .. "xa-cabin/generate_announcements.py"

 -- Only generate audio if language is "custom"
    if language == "custom" then
        local python_script_path = SCRIPT_DIRECTORY .. "xa-cabin/generate_announcements.py"

        -- Updated string.format with all the necessary variables passed to the Python script
        local command = string.format(
            '/usr/local/bin/python3 "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s" "%s"',
            python_script_path,
            airline,
            flight_number,
            destination,
            eta,
            language,
            accent,
            speaker,
            departure_runway,
            arrival_runway,
            cruise_altitude,
            flight_time_hours,
            flight_time_minutes,
            local_time_at_destination,
            aircraft_type,
            time_of_day
        )

        XA_CABIN_LOGGER.write_log("Generating announcements with command: " .. command)
        -- Use io.popen to capture output from the Python script
        -- local handle = io.popen(command)
        -- local result = handle:read("*a")  -- Capture all output from the Python script
        -- handle:close()

        -- -- Print the captured output from the Python script
        -- print("Command output: " .. result)

        -- -- Log the output from the Python script (optional)
        -- XA_CABIN_LOGGER.write_log("Announcement generation output: " .. result)

        -- After generating announcements, load them
        --ANNOUNCEMENTS.loadSounds()
    else
        XA_CABIN_LOGGER.write_log("Skipping announcement generation since language is not 'custom'.")
    end
end


-- Generate Announcements on Initialization
generate_announcements()
-- Schedule State Updates
do_often("xa_cabin_update_state()")

