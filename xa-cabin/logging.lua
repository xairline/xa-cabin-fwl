local XA_CABIN_LOGGER = {}
function XA_CABIN_LOGGER.write_log(message)
	logMsg(os.date('%H:%M:%S ') .. '[XA Cabin ' .. XA_CABIN_VERSION .. ']: ' .. message)
end

function XA_CABIN_LOGGER.dumpTable(tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		formatting = string.rep("  ", indent) .. k .. ": "
		if type(v) == "table" then
			XA_CABIN_LOGGER.write_log(formatting)
			XA_CABIN_LOGGER.dumpTable(v, indent + 1)
		else
			XA_CABIN_LOGGER.write_log(formatting .. tostring(v))
		end
	end
end

return XA_CABIN_LOGGER
