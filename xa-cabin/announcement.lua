local ANNOUNCEMENTS = {
    sounds = {},
    files = {}
}
function ANNOUNCEMENTS.play_sound(cabin_state)
    ANNOUNCEMENTS.stopSounds()
    if ANNOUNCEMENTS.sounds[cabin_state] then
        play_sound(ANNOUNCEMENTS.sounds[cabin_state])
        XA_CABIN_LOGGER.write_log("Playing announcement for cabin state: " .. cabin_state)
    else
        XA_CABIN_LOGGER.write_log("Error: No sound loaded for cabin state: " .. tostring(cabin_state))
    end
end

function ANNOUNCEMENTS.stopSounds()
    if ANNOUNCEMENTS.sounds then
        for i = 2, #ANNOUNCEMENT_STATES do
            if ANNOUNCEMENTS.sounds[ANNOUNCEMENT_STATES[i]] then
                stop_sound(ANNOUNCEMENTS.sounds[ANNOUNCEMENT_STATES[i]])
            end
        end
    end
end

function ANNOUNCEMENTS.unloadAllSounds()
    for index, not_used in paris(ANNOUNCEMENTS.sounds) do
        if ANNOUNCEMENTS.sounds[index] then
            ANNOUNCEMENTS.sounds[index] = false
        end
    end
    XA_CABIN_LOGGER.write_log("Unloaded all sounds")
end

function ANNOUNCEMENTS.loadSounds()
    ANNOUNCEMENTS.stopSounds()
    local language = XA_CABIN_SETTINGS.announcement.language
    local accent = XA_CABIN_SETTINGS.announcement.accent
    local speaker = XA_CABIN_SETTINGS.announcement.speaker
    for i = 1, #ANNOUNCEMENT_STATES do
        local cabin_state = ANNOUNCEMENT_STATES[i]
        local wav_file_path = SCRIPT_DIRECTORY ..
            "xa-cabin/announcements/" ..
            cabin_state .. "/" .. language .. "-" .. accent .. "-" .. speaker .. ".wav"
        local tmp = io.open(wav_file_path, "r")
        if tmp == nil then
            XA_CABIN_LOGGER.write_log("File not found: " .. wav_file_path)
        else
            tmp:close()
            local index = load_WAV_file(wav_file_path)
            ANNOUNCEMENTS.sounds[cabin_state] = index
            ANNOUNCEMENTS.files[cabin_state] = wav_file_path
        end
    end
    XA_CABIN_LOGGER.dumpTable(ANNOUNCEMENTS.sounds)
end

return ANNOUNCEMENTS
