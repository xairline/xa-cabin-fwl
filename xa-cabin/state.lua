-- Assuming ANNOUNCEMENTS is part of a module, require it:
ANNOUNCEMENTS = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/announcement.lua")
STATE = {
    climb_counter = 0,
    cruise_counter = 0,
    descend_counter = 0,
    boarding_delay_counter = 0,
    last_state_change_time = os.clock(), -- Reentrancy guard
    debounce_threshold = 0, -- Seconds to wait between state changes
}

-- Initialize datarefs only once
function STATE.initialize_states()
    -- Initialize datarefs only once
    if XA_CABIN_DATAREFS.GS == nil then
        XA_CABIN_DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
    end
    if XA_CABIN_DATAREFS.ALT_AGL == nil then
        XA_CABIN_DATAREFS.ALT_AGL = dataref_table('sim/flightmodel/position/y_agl')
    end
    if XA_CABIN_DATAREFS.N1 == nil then
        XA_CABIN_DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
    end
    if XA_CABIN_DATAREFS.ONGROUND == nil then
        XA_CABIN_DATAREFS.ONGROUND = dataref_table('sim/flightmodel/failures/onground_any')
    end
    if XA_CABIN_DATAREFS.GEAR_DEPLOY == nil then
        XA_CABIN_DATAREFS.GEAR_DEPLOY = dataref_table('sim/flightmodel2/gear/deploy_ratio')
    end
        -- Initialize GEAR_FORCE dataref
    if XA_CABIN_DATAREFS.GEAR_FORCE == nil then
        XA_CABIN_LOGGER.write_log("Initializing GEAR_FORCE Dataref.")
        XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
    end
    if XA_CABIN_DATAREFS.VS == nil then
        XA_CABIN_LOGGER.write_log("Initializing VS Dataref.")
        XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
    end
    
    local on_ground = XA_CABIN_DATAREFS.ONGROUND[0] == 1
    local gs = XA_CABIN_DATAREFS.GS[0]
    local alt_agl = XA_CABIN_DATAREFS.ALT_AGL[0]
    local engine_n1 = XA_CABIN_DATAREFS.N1[0]
    local gear_deploy = XA_CABIN_DATAREFS.GEAR_DEPLOY[0] -- Gear deployment ratio (1 = down, 0 = up)
    
    -- Determine initial flight phase based on conditions
    if on_ground then
        if gs < 1 and engine_n1 < 30 and alt_agl < 10 then
            -- Aircraft is parked
            if HELPERS.is_door_open() then
                XA_CABIN_LOGGER.write_log("Aircraft is parked at the gate.")
                STATE.change_flight_state("parked", "Aircraft is on the ground, engines off, doors open")
                STATE.change_cabin_state("pre_boarding", "Doors are open at the gate")
            else
                XA_CABIN_LOGGER.write_log("Aircraft is parked on the runway.")
                STATE.change_flight_state("parked", "Aircraft is on the ground, engines off, doors closed")
                STATE.change_cabin_state("boarding_complete", "Ready for taxi")
            end
        elseif gs > 1 and gs < 30 then
            -- Aircraft is taxiing
            XA_CABIN_LOGGER.write_log("Aircraft is taxiing.")
            STATE.change_flight_state("taxi_out", "Ground speed indicates taxi phase")
            STATE.change_cabin_state("safety_demonstration", "Safety demo during taxi")
        elseif gs > 30 and alt_agl < 10 and engine_n1 > 60 then
            -- Aircraft is preparing for takeoff (on the runway)
            XA_CABIN_LOGGER.write_log("Aircraft is on the runway, preparing for takeoff.")
            STATE.change_flight_state("takeoff", "High N1 and high ground speed, preparing for takeoff")
            STATE.change_cabin_state("takeoff", "Takeoff initiated")
        end
    else
        -- Aircraft is in the air
        if alt_agl > 800 and gs > 50 then
            -- Aircraft is in flight, at cruise
            XA_CABIN_LOGGER.write_log("Aircraft is in cruise flight.")
            STATE.change_flight_state("cruise", "Aircraft is in flight, stable altitude")
            STATE.change_cabin_state("cruise", "Cruise altitude reached")
        elseif alt_agl < 800 and gear_deploy > 0 then
            -- Aircraft is descending for approach
            XA_CABIN_LOGGER.write_log("Aircraft is in approach phase.")
            STATE.change_flight_state("approach", "Aircraft descending, gear deployed")
            STATE.change_cabin_state("prepare_for_landing", "Approach started, preparing for landing")
        elseif alt_agl < 100 and gear_deploy > 0 then
            -- Aircraft is landing
            XA_CABIN_LOGGER.write_log("Aircraft is landing.")
            STATE.change_flight_state("landing", "Low altitude, gear deployed, preparing to land")
        end
    end
    
    -- Call the original door and system checks
    XA_CABIN_LOGGER.write_log("Flight phase initialization complete.")

    -- Play the appropriate announcement after initialization
    local announcement_name = cabin_state_to_announcement_name(XA_CABIN_STATES.cabin_state.current_state)
    if announcement_name then
        ANNOUNCEMENTS.play_sound(announcement_name)
    else
        XA_CABIN_LOGGER.write_log("No announcement found for cabin state: " .. XA_CABIN_STATES.cabin_state.current_state)
    end
end

function STATE.change_flight_state(new_state, condition_reason)
    local current_time = os.clock()
    XA_CABIN_LOGGER.write_log("Attempting to change flight state. Current state: " .. XA_CABIN_STATES.flight_state.current_state .. ", New state: " .. new_state)

    if XA_CABIN_STATES.flight_state.current_state ~= new_state and (current_time - STATE.last_state_change_time > STATE.debounce_threshold) then
        XA_CABIN_LOGGER.write_log("Flight state changed to: " .. new_state .. ". Reason: " .. condition_reason)
        XA_CABIN_STATES.flight_state[XA_CABIN_STATES.flight_state.current_state] = false
        XA_CABIN_STATES.flight_state[new_state] = true
        XA_CABIN_STATES.flight_state.current_state = new_state
        STATE.last_state_change_time = current_time  -- Update debounce timer here
    else
        XA_CABIN_LOGGER.write_log("Debounce active or state unchanged. Skipping flight state change. Time since last change: " .. (current_time - STATE.last_state_change_time) .. " seconds.")
    end
end

function STATE.update_flight_state()
    if XA_CABIN_STATES.flight_state.current_state == "parked" then
        if XA_CABIN_DATAREFS.GS[0] > 5 / 1.9 and XA_CABIN_DATAREFS.GEAR_FORCE[0] > 1 then
            STATE.change_flight_state("taxi_out", "Ground speed > 5 and gear force > 1 (start taxi)")
            STATE.change_cabin_state("safety_demonstration", "Safety demo starts with taxi")
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "taxi_out" then
        if XA_CABIN_DATAREFS.N1 == nil then
            XA_CABIN_DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
        end

        if XA_CABIN_DATAREFS.N1[0] > 60 then
            STATE.change_flight_state("takeoff", "N1 > 60% (starting takeoff)")
            STATE.change_cabin_state("takeoff", "Takeoff initiated")
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "takeoff" then
        if XA_CABIN_DATAREFS.VS == nil then
            XA_CABIN_LOGGER.write_log("Initializing Vertical Speed (VS) Dataref")
            XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end
        if XA_CABIN_DATAREFS.GEAR_FORCE == nil then
            XA_CABIN_LOGGER.write_log("Initializing Gear Force Dataref")
            XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        -- Log the values of VS and GEAR_FORCE for debugging
        XA_CABIN_LOGGER.write_log("Current Vertical Speed (VS): " .. tostring(XA_CABIN_DATAREFS.VS[0]))
        XA_CABIN_LOGGER.write_log("Current Gear Force: " .. tostring(XA_CABIN_DATAREFS.GEAR_FORCE[0]))

        -- Check if the vertical speed is high enough and the gear force is low (indicating flight)
        if XA_CABIN_DATAREFS.VS[0] > 200 and XA_CABIN_DATAREFS.GEAR_FORCE[0] < 1 then
            local reason = "Vertical Speed is above 200 fpm and Gear Force is below 1"
            XA_CABIN_LOGGER.write_log("Conditions met for climb: " .. reason)
            STATE.change_flight_state("climb", reason)
            STATE.change_cabin_state("climb", reason)
        else
            XA_CABIN_LOGGER.write_log("Conditions not met for climb.")
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "climb" then
        local vs = XA_CABIN_DATAREFS.VS[0]

        if vs > -500 and vs < 500 then
            STATE.cruise_counter = math.min(STATE.cruise_counter + 1, 30)
        else
            STATE.cruise_counter = 0
        end

        if vs < -500 then
            STATE.descend_counter = math.min(STATE.descend_counter + 1, 30)
        else
            STATE.descend_counter = 0
        end

        if STATE.cruise_counter > 15 then
            STATE.change_flight_state("cruise", "Vertical Speed stabilized near 0")
            STATE.change_cabin_state("cruise", "Aircraft reached cruise altitude")
            return
        end

        if STATE.descend_counter > 10 then
            STATE.change_flight_state("descent", "Vertical Speed negative for extended period (starting descent)")
            STATE.change_cabin_state("prepare_for_landing", "Descent started")
            return
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "cruise" then
        local vs = XA_CABIN_DATAREFS.VS[0]

        if vs > 500 then
            STATE.climb_counter = math.min(STATE.climb_counter + 1, 30)
        else
            STATE.climb_counter = 0
        end

        if vs < -500 then
            STATE.descend_counter = math.min(STATE.descend_counter + 1, 30)
        else
            STATE.descend_counter = 0
        end

        if STATE.climb_counter > 30 then
            STATE.change_flight_state("climb", "Vertical Speed > 500 (resuming climb)")
            STATE.change_cabin_state("climb", "Resuming climb")
            return
        end

        if STATE.descend_counter > 30 then
            STATE.change_flight_state("descent", "Vertical Speed < -500 (starting descent)")
            STATE.change_cabin_state("prepare_for_landing", "Preparing for descent")
            return
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "descent" then
        local vs = XA_CABIN_DATAREFS.VS[0]
        local agl = XA_CABIN_DATAREFS.ALT_AGL[0]
        local gear_force = XA_CABIN_DATAREFS.GEAR_FORCE[0]

        if vs > 500 then
            STATE.climb_counter = math.min(STATE.climb_counter + 1, 30)
        else
            STATE.climb_counter = 0
        end

        if vs < 500 and vs > -500 then
            STATE.cruise_counter = math.min(STATE.cruise_counter + 1, 30)
        else
            STATE.cruise_counter = 0
        end

        if STATE.climb_counter > 15 then
            STATE.change_flight_state("climb", "Climb conditions met during descent")
            STATE.change_cabin_state("climb", "Returning to climb")
            return
        end

        if STATE.cruise_counter > 15 then
            STATE.change_flight_state("cruise", "Cruise conditions met during descent")
            STATE.change_cabin_state("cruise", "Returning to cruise")
            return
        end

        if agl < 800 and gear_force < 5 and vs < -200 then
            STATE.change_flight_state("approach", "Altitude < 800 AGL and descending")
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "approach" then
        local gs = XA_CABIN_DATAREFS.GS[0]
        local gear_force = XA_CABIN_DATAREFS.GEAR_FORCE[0]

        if gs < 50 / 1.9 and gear_force > 10 then
            STATE.change_flight_state("taxi_in", "Groundspeed < 50 and gear force high (landing complete)")
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "taxi_in" then
        local gs = XA_CABIN_DATAREFS.GS[0]
        local n1 = XA_CABIN_DATAREFS.N1[0]

        if gs < 1 / 1.9 and n1 > 15 then
            STATE.change_flight_state("parked", "Aircraft stopped after landing")
        end
        return
    end
end

function STATE.change_cabin_state(new_state, condition_reason)
    condition_reason = condition_reason or "Unknown reason"
    if XA_CABIN_STATES.cabin_state.current_state == new_state then
        XA_CABIN_LOGGER.write_log("Cabin state is already " .. new_state .. ". No change needed.")
        return
    end

    local current_time = os.clock()

    if (current_time - STATE.last_state_change_time > STATE.debounce_threshold) then
        XA_CABIN_LOGGER.write_log("Cabin state changing to: " .. new_state .. ". Reason: " .. condition_reason)
        XA_CABIN_STATES.cabin_state[XA_CABIN_STATES.cabin_state.current_state] = false
        XA_CABIN_STATES.cabin_state[new_state] = true
        XA_CABIN_STATES.cabin_state.current_state = new_state
        STATE.last_state_change_time = current_time

        if XA_CABIN_SETTINGS.mode.automated then
            local announcement_name = cabin_state_to_announcement_name(new_state)
            if announcement_name then
                ANNOUNCEMENTS.stopSounds()
                ANNOUNCEMENTS.play_sound(announcement_name)
                XA_CABIN_LOGGER.write_log("Playing announcement: " .. announcement_name)
            else
                XA_CABIN_LOGGER.write_log("No announcement found for cabin state: " .. new_state)
            end
        end
    else
        XA_CABIN_LOGGER.write_log("Debounce active. Skipping cabin state change to: " .. new_state)
    end
end

function STATE.update_cabin_state()
    if XA_CABIN_STATES.cabin_state.current_state == "pre_boarding" then
        if not HELPERS.is_door_open() and XA_CABIN_STATES.cabin_state.current_state ~= "boarding_complete" then
            XA_CABIN_LOGGER.write_log("Doors closed during pre-boarding. Transitioning to 'boarding_complete'.")
            STATE.change_cabin_state("boarding_complete", "Doors closed during pre-boarding")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "boarding" then
        if not HELPERS.is_door_open() then
            XA_CABIN_LOGGER.write_log("Doors closed before boarding completed. Transitioning to 'boarding_complete'.")
            STATE.change_cabin_state("boarding_complete", "Doors closed before boarding completed")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "boarding_complete" then
        if XA_CABIN_STATES.flight_state.taxi_out then
            STATE.change_cabin_state("safety_demonstration", "Taxi started, safety demo begins")
        end
        return
    end

    if XA_CABIN_STATES.flight_state.current_state == "takeoff" and 
       XA_CABIN_STATES.cabin_state.current_state == "safety_demonstration" then
        STATE.change_cabin_state("takeoff", "Takeoff initiated, safety demo completed")
    end

    if XA_CABIN_STATES.cabin_state.current_state == "safety_demonstration" then
        if ANNOUNCEMENTS.is_safety_demo_done then
            STATE.change_cabin_state("takeoff", "Safety demo completed")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "climb" then
        if XA_CABIN_STATES.flight_state.cruise then
            STATE.change_cabin_state("cruise", "Aircraft reached cruise altitude")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "cruise" then
        if XA_CABIN_STATES.flight_state.descent then
            STATE.change_cabin_state("prepare_for_landing", "Descent started")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "prepare_for_landing" then
        if XA_CABIN_STATES.flight_state.approach then
            STATE.change_cabin_state("final_approach", "Final approach started")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "final_approach" then
        if XA_CABIN_STATES.flight_state.taxi_in then
            STATE.change_cabin_state("post_landing", "Landing completed")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "post_landing" then
        if XA_CABIN_STATES.flight_state.parked then
            STATE.change_cabin_state("pre_boarding", "Aircraft parked, ready for next boarding")
        end
        return
    end
end

function announcement_name_to_cabin_state(announcement_name)
    local cabin_states = {
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

    for index, ann_name in ipairs(XA_CABIN_ANNOUNCEMENT_STATES) do
        if ann_name == announcement_name then
            return cabin_states[index]
        end
    end

    XA_CABIN_LOGGER.write_log("Unknown announcement name: " .. tostring(announcement_name))
    return nil
end

function cabin_state_to_announcement_name(cabin_state)
    local cabin_states = {
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

    for index, state in ipairs(cabin_states) do
        if state == cabin_state then
            return XA_CABIN_ANNOUNCEMENT_STATES[index]
        end
    end

    XA_CABIN_LOGGER.write_log("Unknown cabin state: " .. tostring(cabin_state))
    return nil
end
ANNOUNCEMENTS.loadSounds()
STATE.initialize_states()
ANNOUNCEMENTS.loadSounds()
return STATE