local ANNOUNCEMENTS = {
    sounds = {},
    files = {}
}
function ANNOUNCEMENTS.play_sound(cabin_state)
    ANNOUNCEMENTS.stopSounds()
    play_sound(ANNOUNCEMENTS.sounds[cabin_state])
    LOGGER.write_log("Playing announcement for " .. ANNOUNCEMENTS.files[cabin_state])
end

function ANNOUNCEMENTS.stopSounds()
    if ANNOUNCEMENTS.sounds then
        for i = 2, #XA_CABIN_CABIN_XA_CABIN_STATES do
            if ANNOUNCEMENTS.sounds[XA_CABIN_CABIN_XA_CABIN_STATES[i]] then
                stop_sound(ANNOUNCEMENTS.sounds[XA_CABIN_CABIN_XA_CABIN_STATES[i]])
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
    LOGGER.write_log("Unloaded all sounds")
end

function ANNOUNCEMENTS.loadSounds()
    ANNOUNCEMENTS.stopSounds()
    -- ANNOUNCEMENTS.unloadAllSounds()
    local language = XA_CABIN_SETTINGS.announcement.language
    local accent = XA_CABIN_SETTINGS.announcement.accent
    local speaker = XA_CABIN_SETTINGS.announcement.speaker
    LOGGER.dumpTable(XA_CABIN_CABIN_XA_CABIN_STATES)
    for i = 2, #XA_CABIN_CABIN_XA_CABIN_STATES do
        local wav_file_path = SCRIPT_DIRECTORY ..
            "xa-cabin/announcements/" ..
            XA_CABIN_CABIN_XA_CABIN_STATES[i] .. "/" .. language .. "-" .. accent .. "-" .. speaker .. ".wav"
        local tmp = io.open(wav_file_path, "r")
        if tmp == nil then
            LOGGER.write_log("File not found: " .. wav_file_path)
        else
            local index = load_WAV_file(wav_file_path)
            ANNOUNCEMENTS.sounds[XA_CABIN_CABIN_XA_CABIN_STATES[i]] = index
            ANNOUNCEMENTS.files[XA_CABIN_CABIN_XA_CABIN_STATES[i]] = wav_file_path
        end
    end
    LOGGER.dumpTable(ANNOUNCEMENTS.sounds)
end

return ANNOUNCEMENTS
