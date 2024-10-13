-- globals.lua

XA_CABIN_VERSION = "v0.0.1"

XA_CABIN_ANNOUNCEMENT_STATES = {
    "Pre-Boarding",
    "Boarding",
    "Boarding Complete",
    "Safety Demonstration",
    "Takeoff",
    "Climb",
    "Cruise",
    "Prepare for Landing",
    "Final Approach",
    "Post Landing",
    "Emergency"
}

-- XA_CABIN_SETTINGS should already be loaded from ini before globals.lua is executed

XA_CABIN_LANGUAGE = XA_CABIN_SETTINGS.announcement.language or "en"
XA_CABIN_ACCENT = XA_CABIN_SETTINGS.announcement.accent or "gb"

XA_CABIN_STATES = {
    flight_state = {
        parked = true,
        taxi_out = false,
        takeoff = false,
        climb = false,
        cruise = false,
        descent = false,
        approach = false,
        taxi_in = false,
        current_state = "parked"
    },
    cabin_state = {
        pre_boarding = true,          -- before FA are on board
        boarding = false,             -- FA are on board
        boarding_complete = false,    -- FA are seated and boarding is complete
        safety_demonstration = false, -- FA are doing safety demonstration
        takeoff = false,              -- FA are seated for takeoff
        climb = false,                -- FA are seated for climb
        cruise = false,               -- FA are seated for cruise
        prepare_for_landing = false,  -- FA are seated for landing
        final_approach = false,       -- FA are seated for final approach
        post_landing = false,         -- FA are seated post landing
        current_state = "pre_boarding"
    },
}

XA_CABIN_DATAREFS = {}

XA_CABIN_PLANE_CONFIG = {
    DOOR = {
        dataref_str = 'sim/flightmodel2/misc/door_open_ratio',
        operator = ">=",
        threshold = 0.5
    },
    LANDING_GEAR = {
        dataref_str = 'sim/flightmodel2/gear/deploy_ratio',
        operator = "~=",
        threshold = 0
    },
    LANDING_LIGHTS = {
        dataref_str = 'sim/cockpit/electrical/landing_lights_on',
        operator = "==",
        threshold = 1
    },
}

-- Log the loaded language and accent for debugging
XA_CABIN_LOGGER.write_log("XA_CABIN_LANGUAGE set to: " .. XA_CABIN_LANGUAGE)
XA_CABIN_LOGGER.write_log("XA_CABIN_ACCENT set to: " .. XA_CABIN_ACCENT)