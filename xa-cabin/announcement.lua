local debounce_duration = 5  -- Set debounce time (in seconds)
local last_play_times = {}  -- Track last play times for all announcements
local is_announcement_playing = false  -- Track if any announcement is currently playing

ANNOUNCEMENTS = {
    sounds = {},
    files = {},
    pending_sounds = {},
    is_loaded = false,
    is_safety_demo_playing = false  -- Flag to track if safety demo is playing
}

local ANNOUNCEMENTS_DIR = SCRIPT_DIRECTORY .. "xa-cabin/announcements/"

local phases = {
    "pre_boarding",
    "boarding",
    "boarding_complete",
    "safety_demonstration",
    "takeoff",
    "climb",
    "cruise",
    "prepare_for_landing",
    "final_approach",
    "post_landing",
    "emergency"  -- Add any additional announcements as needed
}

function ANNOUNCEMENTS.play_sound(announcement_name)
    local current_time = os.clock()
    ANNOUNCEMENTS.stopSounds()
    -- Check if another announcement is playing, and stop it before playing a new one
    if is_announcement_playing then
        ANNOUNCEMENTS.stopSounds()  -- Stop the currently playing sound
        XA_CABIN_LOGGER.write_log("Stopping current sound to play: " .. announcement_name)
    end

    -- Initialize last play time for the announcement if it doesn't exist
    if not last_play_times[announcement_name] then
        last_play_times[announcement_name] = 0
    end

    -- Debounce logic: Skip if debounce duration has not passed
    if current_time - last_play_times[announcement_name] < debounce_duration then
        XA_CABIN_LOGGER.write_log("Debounce active for announcement: " .. announcement_name .. ". Skipping.")
        return
    end

    -- Update last play time and mark announcement as playing
    last_play_times[announcement_name] = current_time
    is_announcement_playing = true

    -- Continue playing the sound
    XA_CABIN_LOGGER.write_log("Attempting to play sound for: " .. announcement_name)
    local sound_handle = ANNOUNCEMENTS.sounds[announcement_name]

    if sound_handle then
        XA_CABIN_LOGGER.write_log("Playing sound file: " .. ANNOUNCEMENTS.files[announcement_name])
        play_sound(sound_handle)
    else
        XA_CABIN_LOGGER.write_log("Sound not found for announcement: " .. announcement_name)
        is_announcement_playing = false  -- Reset the flag immediately if no sound is found
    end
end

function ANNOUNCEMENTS.on_sound_complete()
    is_announcement_playing = false  -- Reset the flag to allow the next announcement
    XA_CABIN_LOGGER.write_log("Announcement has finished playing.")
end

function ANNOUNCEMENTS.stopSounds()
    -- Stop all currently playing sounds
    XA_CABIN_LOGGER.write_log("Stopping all current sounds")
    for _, phase in ipairs(phases) do
        local sound_handle = ANNOUNCEMENTS.sounds[phase]
        if sound_handle then
            stop_sound(sound_handle)
        end
    end
    is_announcement_playing = false  -- Ensure the flag is reset when all sounds are stopped
end

function ANNOUNCEMENTS.unloadAllSounds()
    for index, _ in pairs(ANNOUNCEMENTS.sounds) do
        if ANNOUNCEMENTS.sounds[index] then
            ANNOUNCEMENTS.sounds[index] = false
        end
    end
    XA_CABIN_LOGGER.write_log("Unloaded all sounds")
end

-- Load the sounds and mark them as ready once done
function ANNOUNCEMENTS.loadSounds()
    ANNOUNCEMENTS.stopSounds()
    for _, announcement_name in ipairs(XA_CABIN_ANNOUNCEMENT_STATES) do
        local formatted_name = announcement_name
        local wav_file_path = ANNOUNCEMENTS_DIR .. formatted_name .. "/" .. XA_CABIN_LANGUAGE .. "-" .. XA_CABIN_ACCENT .. "-1.wav"
        
        local file = io.open(wav_file_path, "r")
        if file then
            file:close()
            local sound_handle = load_WAV_file(wav_file_path)
            ANNOUNCEMENTS.sounds[announcement_name] = sound_handle
            ANNOUNCEMENTS.files[announcement_name] = wav_file_path
            XA_CABIN_LOGGER.write_log("Successfully loaded announcement: " .. wav_file_path)
        else
            XA_CABIN_LOGGER.write_log("Announcement file not found: " .. wav_file_path)
        end
    end

    -- Mark loading as complete
    ANNOUNCEMENTS.is_loaded = true
    XA_CABIN_LOGGER.write_log("All announcements loaded successfully.")

    -- Play any pending announcements queued during loading
    ANNOUNCEMENTS.play_pending_sounds()
end

-- Play any sounds that were queued while loading was happening
function ANNOUNCEMENTS.play_pending_sounds()
    for _, sound_name in ipairs(ANNOUNCEMENTS.pending_sounds) do
        XA_CABIN_LOGGER.write_log("Playing deferred announcement: " .. sound_name)
        ANNOUNCEMENTS.play_sound(sound_name)
    end

    -- Clear the pending queue
    ANNOUNCEMENTS.pending_sounds = {}
end

return ANNOUNCEMENTS