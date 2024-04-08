VERSION = "v0.0.1"
CABIN_STAGES = {
    "Pre-Boarding",
    "Boarding Completed",
    "Safety Demonstration",
    "Takeoff",
    "Climb",
    "Cruise",
    "Prepare for Landing",
    "Final Approach",
    "Post-Landing"
}

SETTINGS = {
    simbrief = {
        username = ""
    },
    mode = {
        automated = false
    }
}

STATES = {
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
        safety_demonstration = false, -- FA are doing safety demonstration
        takeoff = false,              -- FA are seated for takeoff
        climb = false,                -- FA are seated for climb
        cruise = false,               -- FA are seated for cruise
        prepare_for_landing = false,  -- FA are seated for landing
        final_approach = false,       -- FA are seated for final approach
        post_landing = false,         -- FA are seated post landing
        current_state = "pre_boarding"
    },
    -- plane_state = {
    --     parking_brake = true,
    --     taxi_out = false,
    --     takeoff = false,
    --     climb = false,
    --     cruise = false,
    --     descent = false,
    --     approach = false,
    --     taxi_in = false,
    --     current_state = "parked"
    -- }
}


DATAREFS = {}
