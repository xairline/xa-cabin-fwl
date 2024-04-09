function is_door_open()
    if DATAREFS.DOOR == nil then
        DATAREFS.DOOR = dataref_table(PLANE_CONFIG.DOOR.dataref_str)
        local funcCode = [[
            return function(x, debug)
                if debug then
                    write_log('Dataref: ' .. x)
                    write_log('Debug: ' .. tostring(debug))
                end
                return x]] .. PLANE_CONFIG.DOOR.operator .. PLANE_CONFIG.DOOR.threshold .. [[
            end
        ]]
        PLANE_CONFIG.DOOR["Func"] = load(funcCode)()
    end
    return PLANE_CONFIG.DOOR["Func"](DATAREFS.DOOR[0], false)
end

function is_rwy_ligths_on()
    if DATAREFS.RWY_LIGHTS == nil then
        DATAREFS.RWY_LIGHTS = dataref_table(PLANE_CONFIG.RWY_LIGHTS.dataref_str)
        local funcCode = [[
            return function(x, debug)
                if debug then
                    write_log('Dataref: ' .. x)
                    write_log('Debug: ' .. tostring(debug))
                end
                return x]] .. PLANE_CONFIG.RWY_LIGHTS.operator .. PLANE_CONFIG.RWY_LIGHTS.threshold .. [[
            end
        ]]
        PLANE_CONFIG.RWY_LIGHTS["Func"] = load(funcCode)()
    end
    return PLANE_CONFIG.RWY_LIGHTS["Func"](DATAREFS.RWY_LIGHTS[0], false)
end
