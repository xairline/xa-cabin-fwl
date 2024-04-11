local xml2lua = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/xml/xml2lua.lua")
local handler = dofile(SCRIPT_DIRECTORY .. "/xa-cabin/xml/tree.lua")
local socket = require "socket"
local http = require "socket.http"

local SIMBRIEF = {
    Origin = "",
    OrigName = "",
    OrigRwy = "",
    Destination = "",
    DestName = "",
    DestRwy = "",
    Callsign = "",
    Distance = 0,
    Ete = 0,
    Route = "",
    Level = 0,
}

function get_simbrief_data()
    local webRespose, webStatus = http.request("http://www.simbrief.com/api/xml.fetcher.php?username=" ..
        XA_CABIN_SETTINGS.simbrief.username)

    if webStatus ~= 200 then
        LOGGER.write_log("Simbrief API is not responding OK")
        return false
    end

    local f = io.open(SCRIPT_DIRECTORY .. "simbrief.xml", "w")
    f:write(webRespose)
    f:close()

    LOGGER.write_log("Simbrief XML data downloaded")
    return true
end

function readXML()
    -- New XML parser
    local xml_file = io.open(SCRIPT_DIRECTORY .. "simbrief.xml", "r")
    if xml_file == nil then
        LOGGER.write_log("No Simbrief XML file found")
        return false
    end

    local xfile = xml2lua.loadFile(SCRIPT_DIRECTORY .. "simbrief.xml")
    local parser = xml2lua.parser(handler)
    parser:parse(xfile)
    SIMBRIEF["Status"] = handler.root.OFP.fetch.status

    if SIMBRIEF["Status"] ~= "Success" then
        logMsg("XML status is not success")
        return false
    end

    SIMBRIEF["Origin"] = handler.root.OFP.origin.icao_code
    SIMBRIEF["OrigName"] = handler.root.OFP.origin.name
    SIMBRIEF["OrigRwy"] = handler.root.OFP.origin.plan_rwy

    SIMBRIEF["Destination"] = handler.root.OFP.destination.icao_code
    SIMBRIEF["DestName"] = handler.root.OFP.destination.name
    SIMBRIEF["DestRwy"] = handler.root.OFP.destination.plan_rwy

    SIMBRIEF["Callsign"] = handler.root.OFP.atc.callsign
    SIMBRIEF["Distance"] = handler.root.OFP.general.route_distance
    SIMBRIEF["Ete"] = handler.root.OFP.times.est_time_enroute
    SIMBRIEF["Route"] = handler.root.OFP.general.route
    SIMBRIEF["Level"] = handler.root.OFP.general.initial_altitude
end

local status, err = pcall(get_simbrief_data)
if not status then
    LOGGER.write_log("Error: " .. err)
end

status, err = pcall(readXML)
if not status then
    LOGGER.write_log("Error in update flight state: " .. err)
end
LOGGER.dumpTable(SIMBRIEF)



return SIMBRIEF
