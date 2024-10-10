local HELPERS = {}
function HELPERS.is_door_open()
    if XA_CABIN_SETTINGS.bypass_door_check then
        XA_CABIN_LOGGER.write_log("Bypassing door check")
        return true  -- Always return true if bypassing the door check
    end

    XA_CABIN_LOGGER.write_log("Checking door status")
    if XA_CABIN_DATAREFS.DOOR == nil then
        XA_CABIN_DATAREFS.DOOR = dataref_table(XA_CABIN_PLANE_CONFIG.DOOR.dataref_str)
        XA_CABIN_LOGGER.write_log("Door dataref initialized: " .. tostring(XA_CABIN_PLANE_CONFIG.DOOR.dataref_str))
    end

    local door_status = XA_CABIN_DATAREFS.DOOR[0] > 0
    XA_CABIN_LOGGER.write_log("Door status value: " .. tostring(XA_CABIN_DATAREFS.DOOR[0]))
    XA_CABIN_LOGGER.write_log("Door comparison result: " .. tostring(door_status))

    return door_status
end

function HELPERS.is_landing_ligths_on()
    if XA_CABIN_DATAREFS.LANDING_LIGHTS == nil then
        XA_CABIN_DATAREFS.LANDING_LIGHTS = dataref_table(XA_CABIN_PLANE_CONFIG.LANDING_LIGHTS.dataref_str)
        local funcCode = [[
            return function(x, debug)
                if debug then
                    XA_CABIN_LOGGER.write_log('Dataref: ' .. x)
                    XA_CABIN_LOGGER.write_log('Debug: ' .. tostring(debug))
                end
                return x]] .. XA_CABIN_PLANE_CONFIG.LANDING_LIGHTS.operator .. XA_CABIN_PLANE_CONFIG.LANDING_LIGHTS.threshold .. [[
            end
        ]]
        XA_CABIN_PLANE_CONFIG.LANDING_LIGHTS["Func"] = load(funcCode)()
    end
    return XA_CABIN_PLANE_CONFIG.LANDING_LIGHTS["Func"](XA_CABIN_DATAREFS.LANDING_LIGHTS[0], false)
end

return HELPERS
