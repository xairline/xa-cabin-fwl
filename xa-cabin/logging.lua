function write_log(message)
	logMsg(os.date('%H:%M:%S ') .. '[XA Cabin ' .. VERSION .. ']: ' .. message)
end

function write_leds_to_log(buffer)
	local on_leds = {} -- Table to hold names of LEDs that are on
	for led_name, led_position in pairs(LED) do
		local bank = led_position[1]
		local bit = led_position[2]

		-- Check if the corresponding bit in data is on (true)
		if buffer[bank] and buffer[bank][bit] == true then
			table.insert(on_leds, led_name)
		end
	end

	if #on_leds > 0 then
		local on_leds_string = table.concat(on_leds, ", ")
		if on_leds_string == last_buffer_str then
			return
		end
		last_buffer_str = on_leds_string
		write_log("LEDs ON: " .. on_leds_string) -- Using print as a stand-in for your actual logging mechanism
	end
end

function dumpTable(tbl, indent)
    if not indent then indent = 0 end
    for k, v in pairs(tbl) do
        formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            write_log(formatting)
            dumpTable(v, indent + 1)
        else
            write_log(formatting .. tostring(v))
        end
    end
end