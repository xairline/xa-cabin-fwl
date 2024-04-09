LIP = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/LIP.lua")
dofile(SCRIPT_DIRECTORY .. "/xa-cabin/logging.lua")
dofile(SCRIPT_DIRECTORY .. "/xa-cabin/globals.lua")
dofile(SCRIPT_DIRECTORY .. "/xa-cabin/helpers.lua")
local STATE = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/state.lua")
local GUI = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/GUI.lua")


--[[
IMGUI Blank Template
Author: Joe Kipfer 2019-06-06
Use in conjuction with Folko's IMGUI Demo script for some great examples and explaination.
When Using IMGUI Demo script mentioned above, don't forget to put the imgui demo.jpg in with it or
you'll get an error.
]]

if not SUPPORTS_FLOATING_WINDOWS then
    -- to make sure the script doesn't stop with old FlyWithLua versions
    logMsg("imgui not supported by your FlyWithLua version")
    return
end
-----------------------------------Variables go here--------------------------------------------
--Set you variables here, datarefs, etc...
SETTINGS = LIP.load(SCRIPT_DIRECTORY .. "xa-cabin.ini")
-- check if file exists, if not, create it
local plane_config_file_path = AIRCRAFT_PATH .. "/xa-cabin.ini"

local plane_config_file = io.open(plane_config_file_path, "r")
if plane_config_file == nil then
    write_log("Creating new plane config file")
    LIP.save(plane_config_file_path, PLANE_CONFIG)
end
PLANE_CONFIG = LIP.load(AIRCRAFT_PATH .. "/xa-cabin.ini")
write_log("Loaded plane config file")






-------------------------------------Build Your GUI Here----------------------------------------

function xa_cabin_on_build(xa_cabin_wnd, x, y) --<-- your GUI code goes in this section.
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
end -- function xa_cabin_on_build

-------------------------------------------------------------------------------------------------







-------------------Show Hide Window Section with Toggle functionaility---------------------------

xa_cabin_wnd = nil           -- flag for the show_wnd set to nil so that creation below can happen - float_wnd_create

function xa_cabin_show_wnd() -- This is called when user toggles window on/off, if the next toggle is for ON
    xa_cabin_wnd = float_wnd_create(680, 500, 1, true)
    float_wnd_set_title(xa_cabin_wnd, "XA Cabin " .. VERSION)
    float_wnd_set_imgui_builder(xa_cabin_wnd, "xa_cabin_on_build")
end

function xa_cabin_hide_wnd() -- This is called when user toggles window on/off, if the next toggle is for OFF
    if xa_cabin_wnd then
        float_wnd_destroy(xa_cabin_wnd)
    end
end

xa_cabin_show_only_once = 0
xa_cabin_hide_only_once = 0

function toggle_xa_cabin_window() -- This is the toggle window on/off function
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

------------------------------------------------------------------------------------------------






----"add_macro" - adds the option to the FWL macro menu in X-Plane
----"create command" - creates a show/hide toggle command that calls the toggle_xa_cabin_window()
add_macro("XA Cabin", "xa_cabin_show_wnd()",
    "xa_cabin_hide_wnd()", "activate")
create_command("xa_cabin_menus/show_toggle", "open/close XA Cabin Menu window",
    "toggle_xa_cabin_window()", "", "")

--[[
footnotes:  If changing color using PushStyleColor, here are common color codes:
    BLACK       = 0xFF000000;
    DKGRAY      = 0xFF444444;
    GRAY        = 0xFF888888;
    LTGRAY      = 0xFFCCCCCC;
    WHITE       = 0xFFFFFFFF;
    RED         = 0xFFFF0000;
    GREEN       = 0xFF00FF00;
    BLUE        = 0xFF0000FF;
    YELLOW      = 0xFFFFFF00;
    CYAN        = 0xFF00FFFF;
    MAGENTA     = 0xFFFF00FF;
    ]]

function update_state()
    local status, err = pcall(STATE.update_flight_state)
    if not status then
        write_log("Error in update flight state: " .. err)
    end

    local status2, err2 = pcall(STATE.update_cabin_state)
    if not status2 then
        write_log("Error in update cabin state: " .. err2)
    end
end

do_often("update_state()")
