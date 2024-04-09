local STATE = {
    climb_counter = 0,
    cruise_counter = 0,
    descend_counter = 0,
}

function change_flight_state(new_state)
    if STATES.flight_state[new_state] == nil then
        logMsg("Invalid flight state: " .. new_state)
        return
    end
    STATES.flight_state[STATES.flight_state.current_state] = false
    STATES.flight_state[new_state] = true
    STATES.flight_state.current_state = new_state
    LOGGER.write_log("Flight state changed to: " .. new_state)
end

function STATE.update_flight_state()
    -- process PARKED state
    if STATES.flight_state.current_state == "parked" then
        if DATAREFS.GS == nil then
            DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
        end
        if DATAREFS.GEAR_FORCE == nil then
            DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if DATAREFS.GS[0] > 5 / 1.9 and DATAREFS.GEAR_FORCE[0] > 1 then
            change_flight_state("taxi_out")
        end
        return
    end

    -- process TAXI_OUT state
    if STATES.flight_state.current_state == "taxi_out" then
        if DATAREFS.N1 == nil then
            DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
        end

        if DATAREFS.N1[0] > 75 then
            change_flight_state("takeoff")
        end
        return
    end

    -- process TAKEOFF state
    if STATES.flight_state.current_state == "takeoff" then
        if DATAREFS.VS == nil then
            DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end
        if DATAREFS.GEAR_FORCE == nil then
            DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if DATAREFS.VS[0] > 200 and DATAREFS.GEAR_FORCE[0] < 1 then
            change_flight_state("climb")
        end
        return
    end

    -- process CLIMB state
    if STATES.flight_state.current_state == "climb" then
        if DATAREFS.VS == nil then
            DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end

        if DATAREFS.VS[0] > -500 and DATAREFS.VS[0] < 500 then
            STATE.cruise_counter = STATE.cruise_counter + 1
        else
            STATE.cruise_counter = 0
        end

        if DATAREFS.VS[0] < -500 then
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
    if STATES.flight_state.current_state == "cruise" then
        if DATAREFS.VS == nil then
            DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end

        if DATAREFS.VS[0] > 500 then
            STATE.climb_counter = STATE.climb_counter + 1
        else
            STATE.climb_counter = 0
        end

        if DATAREFS.VS[0] < -500 then
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
    if STATES.flight_state.current_state == "descent" then
        if DATAREFS.VS == nil then
            DATAREFS.VS = dataref_table('sim/flightmodel/position/vh_ind_fpm')
        end
        if DATAREFS.AGL == nil then
            DATAREFS.AGL = dataref_table('sim/flightmodel/position/y_agl')
        end
        if DATAREFS.GEAR_FORCE == nil then
            DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if DATAREFS.VS[0] > 500 then
            STATE.climb_counter = STATE.climb_counter + 1
        else
            STATE.climb_counter = 0
        end

        if DATAREFS.VS[0] < 500 and DATAREFS.VS[0] > -500 then
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

        if DATAREFS.AGL[0] < 800 and DATAREFS.GEAR_FORCE[0] < 5 and DATAREFS.VS[0] > -200 then
            change_flight_state("approach")
        end
        return
    end

    -- process APPROACH state
    if STATES.flight_state.current_state == "approach" then
        if DATAREFS.GS == nil then
            DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
        end
        if DATAREFS.GEAR_FORCE == nil then
            DATAREFS.GEAR_FORCE = dataref_table('sim/flightmodel/forces/fnrml_gear')
        end

        if DATAREFS.GS[0] < 50 / 1.9 and DATAREFS.GEAR_FORCE[0] > 10 then
            change_flight_state("taxi_in")
        end
        return
    end

    -- process TAXI_IN state
    if STATES.flight_state.current_state == "approach" then
        if DATAREFS.GS == nil then
            DATAREFS.GS = dataref_table('sim/flightmodel/position/groundspeed')
        end
        if DATAREFS.N1 == nil then
            DATAREFS.N1 = dataref_table('sim/cockpit2/engine/indicators/N1_percent')
        end

        if DATAREFS.GS[0] < 1 / 1.9 and DATAREFS.N1[0] > 15 then
            change_flight_state("parked")
        end
        return
    end
end

function change_cabin_state(new_state)
    if STATES.cabin_state[new_state] == nil then
        logMsg("Invalid flight state: " .. new_state)
        return
    end
    STATES.cabin_state[STATES.cabin_state.current_state] = false
    STATES.cabin_state[new_state] = true
    STATES.cabin_state.current_state = new_state
    if SETTINGS.mode.automated then
        ANNOUNCEMENTS.play_sound(cabin_state_to_CANBIN_STATES(new_state))
    end
    LOGGER.write_log("Flight state changed to: " .. new_state)
end

function STATE.update_cabin_state()
    -- pre_boarding = true,          -- before FA are on board
    -- boarding = false,             -- FA are on board
    -- safety_demonstration = false, -- FA are doing safety demonstration
    -- takeoff = false,              -- FA are seated for takeoff
    -- climb = false,                -- FA are seated for climb
    -- cruise = false,               -- FA are seated for cruise
    -- prepare_for_landing = false,  -- FA are seated for landing
    -- final_approach = false,       -- FA are seated for final approach
    -- post_landing = false,         -- FA are seated post landing
    if STATES.cabin_state.current_state == "pre_boarding" then
        if HELPERS.is_door_open() and STATES.flight_state.parked then
            change_cabin_state("boarding")
        end
        return
    end

    if STATES.cabin_state.current_state == "boarding" then
        if not HELPERS.is_door_open() and STATES.flight_state.parked then
            change_cabin_state("safety_demonstration")
        end
        return
    end

    if STATES.cabin_state.current_state == "safety_demonstration" then
        if HELPERS.is_rwy_ligths_on() and STATES.flight_state.taxi_out then
            change_cabin_state("takeoff")
        end
        return
    end

    if STATES.cabin_state.current_state == "takeoff" then
        if DATAREFS.AGL == nil then
            DATAREFS.AGL = dataref_table('sim/flightmodel/position/y_agl')
        end
        if STATES.flight_state.climb and DATAREFS.AGL[0] > 1000 then
            change_cabin_state("climb")
        end
        return
    end

    if STATES.cabin_state.current_state == "climb" then
        if STATES.flight_state.cruise then
            change_cabin_state("cruise")
        end
        return
    end

    if STATES.cabin_state.current_state == "cruise" then
        if STATES.flight_state.descent then
            change_cabin_state("prepare_for_landing")
        end
        return
    end

    if STATES.cabin_state.current_state == "prepare_for_landing" then
        if STATES.flight_state.approach then
            change_cabin_state("final_approach")
        end
        return
    end

    if STATES.cabin_state.current_state == "final_approach" then
        if STATES.flight_state.taxi_in then
            change_cabin_state("post_landing")
        end
        return
    end

    if STATES.cabin_state.current_state == "post_landing" then
        if STATES.flight_state.parked then
            change_cabin_state("pre_boarding")
        end
        return
    end
end

function cabin_state_to_CANBIN_STATES(cabin_state)
    if cabin_state == "pre_boarding" then
        return CABIN_STATES[1]
    elseif cabin_state == "boarding" then
        return CABIN_STATES[2]
    elseif cabin_state == "safety_demonstration" then
        return CABIN_STATES[3]
    elseif cabin_state == "takeoff" then
        return CABIN_STATES[4]
    elseif cabin_state == "climb" then
        return CABIN_STATES[5]
    elseif cabin_state == "cruise" then
        return CABIN_STATES[6]
    elseif cabin_state == "prepare_for_landing" then
        return CABIN_STATES[7]
    elseif cabin_state == "final_approach" then
        return CABIN_STATES[8]
    elseif cabin_state == "post_landing" then
        return CABIN_STATES[9]
    end
end

return STATE
