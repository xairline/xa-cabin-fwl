local LOGGER = {}
function LOGGER.write_log(message)
	logMsg(os.date('%H:%M:%S ') .. '[XA Cabin ' .. VERSION .. ']: ' .. message)
end

function LOGGER.dumpTable(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			LOGGER.write_log(formatting)
			LOGGER.dumpTable(v, indent + 1)
		else
			LOGGER.write_log(formatting .. tostring(v))
		end
	end
end

return LOGGER
