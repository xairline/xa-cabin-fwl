STATE = {
    climb_counter = 0,
    cruise_counter = 0,
    descend_counter = 0,
    boarding_delay_counter = 0,
    last_update_time = os.clock(),
    last_flight_update_time = os.clock(),
    last_cabin_update_time = os.clock(),
}
-- Initialize the cabin and flight state variables
STATE.flight_phase = "parked"      -- Initial state of the flight
STATE.cabin_state = "pre_boarding" -- Initial state of the cabin

function STATE.should_update(last_update_time)
    local current_time = os.clock()
    if current_time - last_update_time >= 10 then  -- or 60 for one minute
        return true, current_time
    else
        return false, last_update_time
    end
end

function STATE.update_flight_state_every_minute()
    LOGGER.write_log("Updating flight state. Current state: " .. STATE.flight_phase)
    local shouldUpdate, newTime = STATE.should_update(STATE.last_flight_update_time)
    if shouldUpdate then
        STATE.last_flight_update_time = newTime
        STATE.update_flight_state()
    end
end

function STATE.update_cabin_state_every_minute()
    LOGGER.write_log("Updating cabin state. Current state: " .. STATE.cabin_state)
    local shouldUpdate, newTime = STATE.should_update(STATE.last_cabin_update_time)
    if shouldUpdate then
        STATE.last_cabin_update_time = newTime
        sync_cabin_state_with_flight_state(STATE.flight_phase)
    end
end

-- Change flight state with checks to avoid redundant changes
function STATE.change_flight_state(new_state)
    if XA_CABIN_STATES.flight_state.current_state == new_state then
        LOGGER.write_log("Flight state is already: " .. new_state)
        return -- Exit if the flight state is already the new_state
    end

    if XA_CABIN_STATES.flight_state[new_state] == nil then
        LOGGER.write_log("Invalid flight state: " .. new_state)
        return
    end

    -- Update flight state
    LOGGER.write_log("Changing flight state from: " .. XA_CABIN_STATES.flight_state.current_state .. " to: " .. new_state)
    XA_CABIN_STATES.flight_state[XA_CABIN_STATES.flight_state.current_state] = false
    XA_CABIN_STATES.flight_state[new_state] = true
    XA_CABIN_STATES.flight_state.current_state = new_state
    STATE.flight_phase = new_state  -- Update the global flight phase

    -- Sync the cabin state with the new flight state
    sync_cabin_state_with_flight_state(new_state)

    -- Log the change
    LOGGER.write_log("Flight state changed to: " .. new_state)
end

-- Sync the cabin state based on the flight state
function sync_cabin_state_with_flight_state(flight_state)
    LOGGER.write_log("Syncing cabin state with flight state: " .. flight_state)
    if flight_state == "taxi_out" then
        STATE.change_cabin_state("safety_demonstration")
    elseif flight_state == "takeoff" then
        STATE.change_cabin_state("takeoff")
    elseif flight_state == "climb" then
        STATE.change_cabin_state("climb")
    elseif flight_state == "cruise" then
        STATE.change_cabin_state("cruise")
    elseif flight_state == "descent" then
        STATE.change_cabin_state("prepare_for_landing")
    elseif flight_state == "approach" then
        STATE.change_cabin_state("final_approach")
    elseif flight_state == "taxi_in" then
        STATE.change_cabin_state("post_landing")
    elseif flight_state == "parked" then
        STATE.change_cabin_state("pre_boarding")
    end
end

function STATE.update_flight_state()
    local KNOTS_TO_MPS = 0.514444
    local TAXI_SPEED_THRESHOLD_KNOTS = 10 -- Knots
    local TAXI_SPEED_THRESHOLD = TAXI_SPEED_THRESHOLD_KNOTS * KNOTS_TO_MPS
    local APPROACH_SPEED_THRESHOLD_KNOTS = 50 -- Knots
    local APPROACH_SPEED_THRESHOLD = APPROACH_SPEED_THRESHOLD_KNOTS * KNOTS_TO_MPS
    local TAXI_IN_SPEED_THRESHOLD_KNOTS = 1 -- Knots
    local TAXI_IN_SPEED_THRESHOLD = TAXI_IN_SPEED_THRESHOLD_KNOTS * KNOTS_TO_MPS
    -- Vertical speed thresholds in feet per minute
    local LEVEL_FLIGHT_VS_THRESHOLD = 500  -- Feet per minute
    -- process PARKED state
    if XA_CABIN_STATES.flight_state.current_state == "parked" then
        if XA_CABIN_DATAREFS.GS[0] > TAXI_SPEED_THRESHOLD and XA_CABIN_DATAREFS.GEAR_FORCE[0] > 1 then
            STATE.change_flight_state("taxi_out")
        end
        return
    end

    -- process TAXI_OUT state
    if XA_CABIN_STATES.flight_state.current_state == "taxi_out" then
        if XA_CABIN_DATAREFS.N1[0] > 75 then
            STATE.change_flight_state("takeoff")
        end
        return
    end

    -- process TAKEOFF state
    if XA_CABIN_STATES.flight_state.current_state == "takeoff" then
        if XA_CABIN_DATAREFS.VS[0] > 200 and XA_CABIN_DATAREFS.GEAR_FORCE[0] < 1 then
            STATE.change_flight_state("climb")
        end
        return
    end

    -- process CLIMB state
    if XA_CABIN_STATES.flight_state.current_state == "climb" then
        if XA_CABIN_DATAREFS.VS[0] > -LEVEL_FLIGHT_VS_THRESHOLD and XA_CABIN_DATAREFS.VS[0] < LEVEL_FLIGHT_VS_THRESHOLD then
            STATE.cruise_counter = STATE.cruise_counter + 1
        else
            STATE.cruise_counter = 0
        end

        if XA_CABIN_DATAREFS.VS[0] < -LEVEL_FLIGHT_VS_THRESHOLD then
            STATE.descend_counter = STATE.descend_counter + 1
        else
            STATE.descend_counter = 0
        end

        if STATE.cruise_counter > 15 then
            STATE.change_flight_state("cruise")
            return
        end

        if STATE.descend_counter > 15 then
            STATE.change_flight_state("descent")
            return
        end
        return
    end

    -- process CRUISE state
    if XA_CABIN_STATES.flight_state.current_state == "cruise" then
        if XA_CABIN_DATAREFS.VS[0] > LEVEL_FLIGHT_VS_THRESHOLD then
            -- Climbing
            STATE.climb_counter = STATE.climb_counter + 1
            STATE.cruise_counter = 0
            STATE.descend_counter = 0
        elseif XA_CABIN_DATAREFS.VS[0] < -LEVEL_FLIGHT_VS_THRESHOLD then
            -- Descending
            STATE.descend_counter = STATE.descend_counter + 1
            STATE.climb_counter = 0
            STATE.cruise_counter = 0
        else
            -- Level flight
            STATE.cruise_counter = STATE.cruise_counter + 1
            STATE.climb_counter = 0
            STATE.descend_counter = 0
        end

        if STATE.climb_counter > 30 then
            STATE.change_flight_state("climb")
            return
        end

        if STATE.descend_counter > 30 then
            STATE.change_flight_state("descent")
            return
        end
        return
    end

    -- process DESCENT state
    if XA_CABIN_STATES.flight_state.current_state == "descent" then
        if XA_CABIN_DATAREFS.VS[0] > LEVEL_FLIGHT_VS_THRESHOLD then
            STATE.climb_counter = STATE.climb_counter + 1
        else
            STATE.climb_counter = 0
        end

        if XA_CABIN_DATAREFS.VS[0] > -LEVEL_FLIGHT_VS_THRESHOLD and XA_CABIN_DATAREFS.VS[0] < LEVEL_FLIGHT_VS_THRESHOLD then
            -- Level flight
            STATE.cruise_counter = STATE.cruise_counter + 1
            STATE.climb_counter = 0
            STATE.descend_counter = 0
        else
            STATE.cruise_counter = 0
        end

        if STATE.climb_counter > 15 then
            STATE.change_flight_state("climb")
            return
        end

        if STATE.cruise_counter > 15 then
            STATE.change_flight_state("cruise")
            return
        end

        if XA_CABIN_DATAREFS.AGL[0] < 800 and XA_CABIN_DATAREFS.GEAR_FORCE[0] < 5 and XA_CABIN_DATAREFS.VS[0] < -200 then
            STATE.change_flight_state("approach")
            return
        end
        return
    end

    -- process APPROACH state
    if XA_CABIN_STATES.flight_state.current_state == "approach" then
        if XA_CABIN_DATAREFS.GS[0] < APPROACH_SPEED_THRESHOLD and XA_CABIN_DATAREFS.GEAR_FORCE[0] > 10 then
            STATE.change_flight_state("taxi_in")
        end
        return
    end

    -- process TAXI_IN state
    if XA_CABIN_STATES.flight_state.current_state == "taxi_in" then
        if XA_CABIN_DATAREFS.GS[0] < TAXI_IN_SPEED_THRESHOLD  and XA_CABIN_DATAREFS.N1[0] > 15 then
            STATE.change_flight_state("parked")
        end
        return
    end
end

-- Change cabin state safely
function STATE.change_cabin_state(new_state)
    if new_state == XA_CABIN_STATES.cabin_state.current_state then
        return -- Prevent unnecessary state change and potential loop
    end

    if XA_CABIN_STATES.cabin_state[new_state] == nil then
        LOGGER.write_log("Invalid cabin state: " .. new_state)
        return
    end

    XA_CABIN_STATES.cabin_state[XA_CABIN_STATES.cabin_state.current_state] = false
    XA_CABIN_STATES.cabin_state[new_state] = true
    XA_CABIN_STATES.cabin_state.current_state = new_state
    STATE.cabin_state = new_state -- Ensure this updates the global variable

    if XA_CABIN_SETTINGS.mode.automated then
        ANNOUNCEMENTS.play_sound(new_state)
        LOGGER.write_log("Playing announcement for cabin state: " .. new_state)
    end

    LOGGER.write_log("Cabin state changed to: " .. new_state)
end

-- Define the mapping table at the beginning of your script
CABIN_STATE_MAPPING = {
    ["pre_boarding"] = "mapped_state_1",
    ["boarding"] = "mapped_state_2",
    ["boarding_complete"] = "mapped_state_3",
    ["safety_demonstration"] = "mapped_state_4",
    ["takeoff"] = "mapped_state_5",
    ["climb"] = "mapped_state_6",
    ["cruise"] = "mapped_state_7",
    ["prepare_for_landing"] = "mapped_state_8",
    ["final_approach"] = "mapped_state_9",
    ["post_landing"] = "mapped_state_10",
}

function cabin_state_to_CABIN_XA_CABIN_STATES(cabin_state)
    LOGGER.write_log("Mapping cabin state to CABIN: " .. cabin_state)
    local mapped_state = CABIN_STATE_MAPPING[cabin_state]
    if mapped_state then
        return mapped_state
    else
        LOGGER.write_log("Invalid cabin state: " .. tostring(cabin_state))
        return nil
    end
end

function STATE.initialize_datarefs()
    XA_CABIN_DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
    XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
    XA_CABIN_DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
    XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
    XA_CABIN_DATAREFS.AGL = dataref_table('sim/flightmodel/position/y_agl')
    -- Initialize other required datarefs here
end

-- Call this function at the start of your script
STATE.initialize_datarefs()
-- Register update functions
do_every_frame("STATE.update_flight_state_every_minute()")
do_every_frame("STATE.update_cabin_state_every_minute()")

return STATE