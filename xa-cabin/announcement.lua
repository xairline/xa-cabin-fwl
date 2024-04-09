local ANNOUNCEMENTS = {
    sounds = {},
    files = {}
}
function ANNOUNCEMENTS.play_sound(cabin_state)
    ANNOUNCEMENTS.stopSounds()
    play_sound(ANNOUNCEMENTS.sounds[cabin_state])
    write_log("Playing announcement for " .. ANNOUNCEMENTS.files[cabin_state])
end

function ANNOUNCEMENTS.stopSounds()
    if ANNOUNCEMENTS.sounds then
        for i = 2, #CABIN_STATES do
            if ANNOUNCEMENTS.sounds[CABIN_STATES[i]] then
                stop_sound(ANNOUNCEMENTS.sounds[CABIN_STATES[i]])
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
    write_log("Unloaded all sounds")
end

function ANNOUNCEMENTS.loadSounds()
    ANNOUNCEMENTS.stopSounds()
    -- ANNOUNCEMENTS.unloadAllSounds()
    for i = 2, #CABIN_STATES do
        local wav_file_path = SCRIPT_DIRECTORY .. "/announcements/" .. CABIN_STATES[i] .. "/audio.wav"
        local tmp = io.open(wav_file_path, "r")
        if tmp == nil then
            write_log("File not found: " .. wav_file_path)
        else
            local index = load_WAV_file(wav_file_path)
            ANNOUNCEMENTS.sounds[CABIN_STATES[i]] = index
            ANNOUNCEMENTS.files[CABIN_STATES[i]] = wav_file_path
        end
    end
    dumpTable(ANNOUNCEMENTS.sounds)
end

return ANNOUNCEMENTS
