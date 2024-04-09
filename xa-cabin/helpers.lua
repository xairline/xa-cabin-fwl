local HELPERS = {}
function HELPERS.is_door_open()
    if XA_CABIN_DATAREFS.DOOR == nil then
        XA_CABIN_DATAREFS.DOOR = dataref_table(XA_CABIN_PLANE_CONFIG.DOOR.dataref_str)
        local funcCode = [[
            return function(x, debug)
                if debug then
                    LOGGER.write_log('Dataref: ' .. x)
                    LOGGER.write_log('Debug: ' .. tostring(debug))
                end
                return x]] .. XA_CABIN_PLANE_CONFIG.DOOR.operator .. XA_CABIN_PLANE_CONFIG.DOOR.threshold .. [[
            end
        ]]
        XA_CABIN_PLANE_CONFIG.DOOR["Func"] = load(funcCode)()
    end
    return XA_CABIN_PLANE_CONFIG.DOOR["Func"](XA_CABIN_DATAREFS.DOOR[0], false)
end

function HELPERS.is_rwy_ligths_on()
    if XA_CABIN_DATAREFS.RWY_LIGHTS == nil then
        XA_CABIN_DATAREFS.RWY_LIGHTS = dataref_table(XA_CABIN_PLANE_CONFIG.RWY_LIGHTS.dataref_str)
        local funcCode = [[
            return function(x, debug)
                if debug then
                    LOGGER.write_log('Dataref: ' .. x)
                    LOGGER.write_log('Debug: ' .. tostring(debug))
                end
                return x]] .. XA_CABIN_PLANE_CONFIG.RWY_LIGHTS.operator .. XA_CABIN_PLANE_CONFIG.RWY_LIGHTS.threshold .. [[
            end
        ]]
        XA_CABIN_PLANE_CONFIG.RWY_LIGHTS["Func"] = load(funcCode)()
    end
    return XA_CABIN_PLANE_CONFIG.RWY_LIGHTS["Func"](XA_CABIN_DATAREFS.RWY_LIGHTS[0], false)
end

return HELPERS
