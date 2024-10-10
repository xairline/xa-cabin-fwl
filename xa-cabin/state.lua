local STATE = {
    climb_counter = 0,
    cruise_counter = 0,
    descend_counter = 0,
    bording_delay_counter = 0,
}

function STATE.initialize_states()
    if XA_CABIN_DATAREFS.GS == nil then
        XA_CABIN_DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
    end
    if XA_CABIN_DATAREFS.ALT_AGL == nil then
        XA_CABIN_DATAREFS.ALT_AGL = dataref_table('sim/flightmodel/position/y_agl')
    end
    if XA_CABIN_DATAREFS.ONGROUND == nil then
        XA_CABIN_DATAREFS.ONGROUND = dataref_table('sim/flightmodel/failures/onground_any')
    end

    local on_ground = XA_CABIN_DATAREFS.ONGROUND[0] == 1
    local gs = XA_CABIN_DATAREFS.GS[0]
    local alt_agl = XA_CABIN_DATAREFS.ALT_AGL[0]

    -- Check if the aircraft is on the runway (e.g., ground speed zero, on ground, at runway heading)
    if on_ground and gs < 1 and alt_agl < 10 then
        -- Aircraft is on the ground, but we need to determine if it's at the gate or runway
        -- For simplicity, let's assume that if the door is closed, we're on the runway ready for takeoff
        if not HELPERS.is_door_open() then
            -- Set flight state to 'takeoff'
            XA_CABIN_STATES.flight_state = {
                parked = false,
                taxi_out = false,
                takeoff = true,
                climb = false,
                cruise = false,
                descent = false,
                approach = false,
                taxi_in = false,
                current_state = "takeoff"
            }
            XA_CABIN_LOGGER.write_log("Flight started from the runway. Setting flight state to 'takeoff'.")

            -- Set cabin state to 'takeoff' or the appropriate state
            XA_CABIN_STATES.cabin_state = {
                pre_boarding = false,
                boarding = false,
                boarding_complete = false,
                safety_demonstration = false,
                takeoff = true,
                climb = false,
                cruise = false,
                prepare_for_landing = false,
                final_approach = false,
                post_landing = false,
                current_state = "takeoff"
            }
            XA_CABIN_LOGGER.write_log("Cabin state set to 'takeoff' due to runway start.")
        else
            -- If door is open, assume we're at the gate
            XA_CABIN_LOGGER.write_log("Door is open. Assuming aircraft is parked at the gate.")
        end
    end
end

function change_flight_state(new_state)
    if XA_CABIN_STATES.flight_state[new_state] == nil then
        logMsg("Invalid flight state: " .. new_state)
        return
    end
    XA_CABIN_STATES.flight_state[XA_CABIN_STATES.flight_state.current_state] = false
    XA_CABIN_STATES.flight_state[new_state] = true
    XA_CABIN_STATES.flight_state.current_state = new_state
    XA_CABIN_LOGGER.write_log("Flight state changed to: " .. new_state)
end

function STATE.update_flight_state()
    -- process PARKED state
    if XA_CABIN_STATES.flight_state.current_state == "parked" then
        if XA_CABIN_DATAREFS.GS == nil then
            XA_CABIN_DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
        end
        if XA_CABIN_DATAREFS.GEAR_FORCE == nil then
            XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if XA_CABIN_DATAREFS.GS[0] > 5 / 1.9 and XA_CABIN_DATAREFS.GEAR_FORCE[0] > 1 then
            change_flight_state("taxi_out")
        end
        return
    end

    -- process TAXI_OUT state
    if XA_CABIN_STATES.flight_state.current_state == "taxi_out" then
        if XA_CABIN_DATAREFS.N1 == nil then
            XA_CABIN_DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
        end

        if XA_CABIN_DATAREFS.N1[0] > 75 then
            change_flight_state("takeoff")
        end
        return
    end

    -- process TAKEOFF state
    if XA_CABIN_STATES.flight_state.current_state == "takeoff" then
        if XA_CABIN_DATAREFS.VS == nil then
            XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end
        if XA_CABIN_DATAREFS.GEAR_FORCE == nil then
            XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if XA_CABIN_DATAREFS.VS[0] > 200 and XA_CABIN_DATAREFS.GEAR_FORCE[0] < 1 then
            change_flight_state("climb")
        end
        return
    end

    -- process CLIMB state
    if XA_CABIN_STATES.flight_state.current_state == "climb" then
        if XA_CABIN_DATAREFS.VS == nil then
            XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end

        if XA_CABIN_DATAREFS.VS[0] > -500 and XA_CABIN_DATAREFS.VS[0] < 500 then
            STATE.cruise_counter = STATE.cruise_counter + 1
        else
            STATE.cruise_counter = 0
        end

        if XA_CABIN_DATAREFS.VS[0] < -500 then
            STATE.descend_counter = STATE.descend_counter + 1
        else
            STATE.descend_counter = 0
        end

        if STATE.cruise_counter > 15 then
            change_flight_state("cruise")
            return
        end

        if STATE.descend_counter > 15 then
            change_flight_state("descent")
            return
        end
        return
    end

    -- process CRUISE state
    if XA_CABIN_STATES.flight_state.current_state == "cruise" then
        if XA_CABIN_DATAREFS.VS == nil then
            XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end

        if XA_CABIN_DATAREFS.VS[0] > 500 then
            STATE.climb_counter = STATE.climb_counter + 1
        else
            STATE.climb_counter = 0
        end

        if XA_CABIN_DATAREFS.VS[0] < -500 then
            STATE.descend_counter = STATE.descend_counter + 1
        else
            STATE.descend_counter = 0
        end

        if STATE.climb_counter > 30 then
            change_flight_state("climb")
            return
        end

        if STATE.descend_counter > 30 then
            change_flight_state("descent")
            return
        end
        return
    end

    -- process DESCENT state
    if XA_CABIN_STATES.flight_state.current_state == "descent" then
        if XA_CABIN_DATAREFS.VS == nil then
            XA_CABIN_DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end
        if XA_CABIN_DATAREFS.AGL == nil then
            XA_CABIN_DATAREFS.AGL = dataref_table('sim/flightmodel/position/y_agl')
        end
        if XA_CABIN_DATAREFS.GEAR_FORCE == nil then
            XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if XA_CABIN_DATAREFS.VS[0] > 500 then
            STATE.climb_counter = STATE.climb_counter + 1
        else
            STATE.climb_counter = 0
        end

        if XA_CABIN_DATAREFS.VS[0] < 500 and XA_CABIN_DATAREFS.VS[0] > -500 then
            STATE.cruise_counter = STATE.cruise_counter + 1
        else
            STATE.cruise_counter = 0
        end

        if STATE.climb_counter > 15 then
            change_flight_state("climb")
            return
        end

        if STATE.cruise_counter > 15 then
            change_flight_state("cruise")
            return
        end

        if XA_CABIN_DATAREFS.AGL[0] < 800 and XA_CABIN_DATAREFS.GEAR_FORCE[0] < 5 and XA_CABIN_DATAREFS.VS[0] < -200 then
            change_flight_state("approach")
            return
        end
        return
    end

    -- process APPROACH state
    if XA_CABIN_STATES.flight_state.current_state == "approach" then
        if XA_CABIN_DATAREFS.GS == nil then
            XA_CABIN_DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
        end
        if XA_CABIN_DATAREFS.GEAR_FORCE == nil then
            XA_CABIN_DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if XA_CABIN_DATAREFS.GS[0] < 50 / 1.9 and XA_CABIN_DATAREFS.GEAR_FORCE[0] > 10 then
            change_flight_state("taxi_in")
        end
        return
    end

    -- process TAXI_IN state
    if XA_CABIN_STATES.flight_state.current_state == "taxi_in" then
        if XA_CABIN_DATAREFS.GS == nil then
            XA_CABIN_DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
        end
        if XA_CABIN_DATAREFS.N1 == nil then
            XA_CABIN_DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
        end

        if XA_CABIN_DATAREFS.GS[0] < 1 / 1.9 and XA_CABIN_DATAREFS.N1[0] > 15 then
            change_flight_state("parked")
        end
        return
    end
end

function change_cabin_state(new_state)
    if XA_CABIN_STATES.cabin_state[new_state] == nil then
        logMsg("Invalid Cabin state: " .. new_state)
        return
    end
    XA_CABIN_STATES.cabin_state[XA_CABIN_STATES.cabin_state.current_state] = false
    XA_CABIN_STATES.cabin_state[new_state] = true
    XA_CABIN_STATES.cabin_state.current_state = new_state
    if XA_CABIN_SETTINGS.mode.automated then
        local announcement_name = cabin_state_to_announcement_name(new_state)
        if announcement_name then
            ANNOUNCEMENTS.play_sound(announcement_name)
            XA_CABIN_LOGGER.write_log("Playing announcement: " .. announcement_name)
        else
            XA_CABIN_LOGGER.write_log("No announcement found for cabin state: " .. new_state)
        end
    end
    XA_CABIN_LOGGER.write_log("Cabin state changed to: " .. new_state)
end

function STATE.update_cabin_state()
    if XA_CABIN_STATES.cabin_state.current_state == "pre_boarding" then
        if HELPERS.is_door_open() and XA_CABIN_STATES.flight_state.parked then
            STATE.bording_delay_counter = STATE.bording_delay_counter + 1

            -- Generate and store the random delay threshold once
            if not STATE.boarding_delay_threshold then
                STATE.boarding_delay_threshold = math.random(90, 120)
                XA_CABIN_LOGGER.write_log("Boarding delay threshold set to: " .. STATE.boarding_delay_threshold)
            end

            -- Compare the counter against the stored threshold
            if STATE.bording_delay_counter > STATE.boarding_delay_threshold then
                change_cabin_state("boarding")
                -- Reset counter and threshold for future use
                STATE.bording_delay_counter = 0
                STATE.boarding_delay_threshold = nil
            end
        else
            -- Reset counter and threshold if conditions are not met
            STATE.bording_delay_counter = 0
            STATE.boarding_delay_threshold = nil
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "boarding" then
        if not HELPERS.is_door_open() and not XA_CABIN_STATES.flight_state.taxi_out then
            change_cabin_state("boarding_complete")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "boarding_complete" then
        if XA_CABIN_STATES.flight_state.taxi_out then
            change_cabin_state("safety_demonstration")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "safety_demonstration" then
        if HELPERS.is_landing_ligths_on() and XA_CABIN_STATES.flight_state.taxi_out then
            change_cabin_state("takeoff")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "takeoff" then
        if XA_CABIN_DATAREFS.AGL == nil then
            XA_CABIN_DATAREFS.AGL = dataref_table('sim/flightmodel/position/y_agl')
        end
        if XA_CABIN_STATES.flight_state.climb and XA_CABIN_DATAREFS.AGL[0] > 1000 then
            change_cabin_state("climb")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "climb" then
        if XA_CABIN_STATES.flight_state.cruise then
            change_cabin_state("cruise")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "cruise" then
        if XA_CABIN_STATES.flight_state.descent then
            change_cabin_state("prepare_for_landing")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "prepare_for_landing" then
        if XA_CABIN_STATES.flight_state.approach then
            change_cabin_state("final_approach")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "final_approach" then
        if XA_CABIN_STATES.flight_state.taxi_in then
            change_cabin_state("post_landing")
        end
        return
    end

    if XA_CABIN_STATES.cabin_state.current_state == "post_landing" then
        if XA_CABIN_STATES.flight_state.parked then
            change_cabin_state("pre_boarding")
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
        "post_landing"
    }

    for _, cabin_state in ipairs(cabin_states) do
        local ann_name = cabin_state_to_announcement_name(cabin_state)
        if ann_name == announcement_name then
            return cabin_state
        end
    end

    XA_CABIN_LOGGER.write_log("Unknown announcement name: " .. tostring(announcement_name))
    return nil
end

function cabin_state_to_announcement_name(cabin_state)
    if cabin_state == "pre_boarding" then
        return XA_CABIN_ANNOUNCEMENT_STATES[1]
    elseif cabin_state == "boarding" then
        return XA_CABIN_ANNOUNCEMENT_STATES[2]
    elseif cabin_state == "boarding_complete" then
        return XA_CABIN_ANNOUNCEMENT_STATES[3]
    elseif cabin_state == "safety_demonstration" then
        return XA_CABIN_ANNOUNCEMENT_STATES[4]
    elseif cabin_state == "takeoff" then
        return XA_CABIN_ANNOUNCEMENT_STATES[5]
    elseif cabin_state == "climb" then
        return XA_CABIN_ANNOUNCEMENT_STATES[6]
    elseif cabin_state == "cruise" then
        return XA_CABIN_ANNOUNCEMENT_STATES[7]
    elseif cabin_state == "prepare_for_landing" then
        return XA_CABIN_ANNOUNCEMENT_STATES[8]
    elseif cabin_state == "final_approach" then
        return XA_CABIN_ANNOUNCEMENT_STATES[9]
    elseif cabin_state == "post_landing" then
        return XA_CABIN_ANNOUNCEMENT_STATES[10]
    end
end

STATE.initialize_states()

return STATE
