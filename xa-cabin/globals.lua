XA_CABIN_VERSION = "v0.1.0"
ANNOUNCEMENT_STATES = {
    "pre_boarding",
    "boarding",
    "boarding_complete",
    "safety_demonstration",
    "takeoff",
    "climb",
    "cruise",
    "prepare_for_landing",
    "final_approach",
    "post_landing",
    "emergency"
}

XA_CABIN_SETTINGS = {
    simbrief = {
        username = ""
    },
    mode = {
        automated = false
    },
    announcement = {
        language = "en",
        accent = "in",
        speaker = "01"
    }
}

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
        operator = ">",
        threshold = 0.9
    },
    LANDING_GEAR = {
        dataref_str = 'sim/flightmodel2/gear/deploy_ratio',
        operator = "~=",
        threshold = 0
    },
    LANDING_LIGHTS = {
        dataref_str = 'ckpt/oh/rwyTurnOff/anim',
        operator = "==",
        threshold = 1
    },
}

DISPLAY_NAME_TO_STATE = {
    ["Pre-Boarding"] = "pre_boarding",
    ["Boarding"] = "boarding",
    ["Boarding Complete"] = "boarding_complete",
    ["Safety Demonstration"] = "safety_demonstration",
    ["Takeoff"] = "takeoff",
    ["Climb"] = "climb",
    ["Cruise"] = "cruise",
    ["Prepare for Landing"] = "prepare_for_landing",
    ["Final Approach"] = "final_approach",
    ["Post Landing"] = "post_landing",
    ["Emergency"] = "emergency" -- Assuming you have this state defined
}