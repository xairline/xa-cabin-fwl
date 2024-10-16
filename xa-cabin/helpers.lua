local HELPERS = {}

local previous_door_state = nil -- To track the previous state of the door

function HELPERS.is_door_open()
    -- Initialize DOOR config and function only if they haven't been initialized already
    if not XA_CABIN_PLANE_CONFIG.DOOR["Func"] then
        XA_CABIN_LOGGER.write_log("Initializing DOOR config and function.")

        -- Initialize the DOOR dataref table if not done
        if XA_CABIN_DATAREFS.DOOR == nil then
            XA_CABIN_DATAREFS.DOOR = dataref_table(XA_CABIN_PLANE_CONFIG.DOOR.dataref_str)
            XA_CABIN_LOGGER.write_log("DOOR Dataref initialized: " .. XA_CABIN_PLANE_CONFIG.DOOR.dataref_str)
        end

        -- Validate operator and threshold
        local operator = XA_CABIN_PLANE_CONFIG.DOOR.operator
        local threshold = tonumber(XA_CABIN_PLANE_CONFIG.DOOR.threshold)

        if not operator or operator == "" then
            XA_CABIN_LOGGER.write_log("Invalid operator for DOOR: " .. tostring(operator))
            return false
        end
        if not threshold then
            XA_CABIN_LOGGER.write_log("Invalid threshold for DOOR: " .. tostring(threshold))
            return false
        end

        -- Construct the function code to evaluate the door state
        local funcCode = string.format([[
            return function(x)
                return x %s %s
            end
        ]], operator, threshold)

        -- Load the function
        local func, loadError = load(funcCode)
        if not func then
            XA_CABIN_LOGGER.write_log("Error loading Func for DOOR: " .. tostring(loadError))
            XA_CABIN_PLANE_CONFIG.DOOR["Func"] = nil
            return false
        else
            local success, execError = pcall(function()
                XA_CABIN_PLANE_CONFIG.DOOR["Func"] = func()
            end)
            if not success then
                XA_CABIN_LOGGER.write_log("Error executing Func for DOOR: " .. tostring(execError))
                XA_CABIN_PLANE_CONFIG.DOOR["Func"] = nil
                return false
            else
                XA_CABIN_LOGGER.write_log("Successfully loaded Func for DOOR.")
            end
        end
    end

    -- If the function is nil (which should not happen), assume door is closed
    if not XA_CABIN_PLANE_CONFIG.DOOR["Func"] then
        XA_CABIN_LOGGER.write_log("Func for DOOR is nil. Assuming door is closed.")
        return false
    end

    -- Evaluate the door state using the cached function
    local door_value = XA_CABIN_DATAREFS.DOOR[0]
    local is_open = XA_CABIN_PLANE_CONFIG.DOOR["Func"](door_value)

    -- Log state change only if it differs from previous state
    if is_open ~= previous_door_state then
        XA_CABIN_LOGGER.write_log("Door Dataref Value: " .. tostring(door_value))
        XA_CABIN_LOGGER.write_log("Comparison: x " .. XA_CABIN_PLANE_CONFIG.DOOR.operator .. " " .. tostring(XA_CABIN_PLANE_CONFIG.DOOR.threshold))
        XA_CABIN_LOGGER.write_log("Door state changed to: " .. tostring(is_open))
        previous_door_state = is_open
    end

    return is_open
end

function HELPERS.open_door()
    -- Initialize a writable dataref for door control (not relying on XA_CABIN_DATAREFS.DOOR)
    local writable_door_dataref = dataref_table("sim/cockpit2/switches/door_open")

    -- Check if the writable dataref is initialized correctly
    if writable_door_dataref then
        writable_door_dataref[0] = 1 -- Set the first door (index 0) to open
        XA_CABIN_LOGGER.write_log("Writable door dataref set: sim/cockpit2/switches/door_open, index 0, value 1 (open)")
    else
        XA_CABIN_LOGGER.write_log("Failed to initialize writable door dataref.")
    end
end

function HELPERS.is_landing_lights_on()
    -- Check if the landing lights dataref exists
    if XA_CABIN_DATAREFS.LANDING_LIGHTS == nil then
        XA_CABIN_LOGGER.write_log("Error: LANDING_LIGHTS dataref is nil.")
        return false
    end

    -- Check if the landing lights value is available
    local landing_lights_value = XA_CABIN_DATAREFS.LANDING_LIGHTS[0]
    if landing_lights_value == nil then
        XA_CABIN_LOGGER.write_log("Error: Unable to retrieve LANDING_LIGHTS value.")
        return false
    end

    -- Log the landing lights state and return true if they are on (1)
    XA_CABIN_LOGGER.write_log("Landing Lights State: " .. tostring(landing_lights_value))
    return landing_lights_value == 1
end

return HELPERS