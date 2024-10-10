local ANNOUNCEMENTS = {
    sounds = {},
    files = {}
}
function ANNOUNCEMENTS.play_sound(announcement_name)
    ANNOUNCEMENTS.stopSounds()
    play_sound(ANNOUNCEMENTS.sounds[announcement_name])
    XA_CABIN_LOGGER.write_log("Playing announcement for " .. ANNOUNCEMENTS.files[announcement_name])
end

function ANNOUNCEMENTS.stopSounds()
    if ANNOUNCEMENTS.sounds then
        for i = 2, #XA_CABIN_ANNOUNCEMENT_STATES do
            if ANNOUNCEMENTS.sounds[XA_CABIN_ANNOUNCEMENT_STATES[i]] then
                stop_sound(ANNOUNCEMENTS.sounds[XA_CABIN_ANNOUNCEMENT_STATES[i]])
            end
        end
    end
end

function ANNOUNCEMENTS.unloadAllSounds()
    for index, not_used in pairs(ANNOUNCEMENTS.sounds) do
        if ANNOUNCEMENTS.sounds[index] then
            ANNOUNCEMENTS.sounds[index] = false
        end
    end
    XA_CABIN_LOGGER.write_log("Unloaded all sounds")
end

function ANNOUNCEMENTS.loadSounds()
    ANNOUNCEMENTS.stopSounds()
    -- ANNOUNCEMENTS.unloadAllSounds()
    local language = XA_CABIN_SETTINGS.announcement.language
    local accent = XA_CABIN_SETTINGS.announcement.accent
    local speaker = XA_CABIN_SETTINGS.announcement.speaker
    XA_CABIN_LOGGER.dumpTable(XA_CABIN_ANNOUNCEMENT_STATES)
    for i = 2, #XA_CABIN_ANNOUNCEMENT_STATES do
        local announcement = XA_CABIN_ANNOUNCEMENT_STATES[i]
        local wav_file_path = SCRIPT_DIRECTORY ..
            "/xa-cabin/announcements/" ..
            announcement .. "/" .. language .. "-" .. accent .. "-" .. speaker .. ".wav"
        local tmp = io.open(wav_file_path, "r")
        if tmp == nil then
            XA_CABIN_LOGGER.write_log("File not found: " .. wav_file_path)
        else
            tmp:close()  -- Don't forget to close the file
            local index = load_WAV_file(wav_file_path)
            ANNOUNCEMENTS.sounds[announcement] = index
            ANNOUNCEMENTS.files[announcement] = wav_file_path
        end
    end
    XA_CABIN_LOGGER.dumpTable(ANNOUNCEMENTS.sounds)
end

return ANNOUNCEMENTS
