ANNOUNCEMENTS Module Documentation

This Lua module provides functionality to manage and play flight announcements. It handles loading, playing, stopping, and queuing sounds with support for debounce logic to prevent repetitive playback within a short time frame. The script is designed to be integrated with a cabin announcement system, tracking the phases of a flight and ensuring smooth audio transitions between different announcements.

Features

	•	Debounce Logic: Prevents rapid consecutive plays of the same announcement within a configurable duration.
	•	Async Sound Handling: Manages the loading and playing of sounds asynchronously to avoid conflicts between announcements.
	•	Announcement Phases: Supports a variety of flight phases, from pre-boarding to post-landing.
	•	Pending Sound Queue: Handles pending sounds that may have been triggered while the system was loading.
	•	Safety Demo Handling: Special flag to manage the playing state of the safety demonstration.
	•	Sound Stop Functionality: Ensures all sounds are stopped before playing a new one to avoid overlapping audios.

Announcement Phases

The following announcement phases are supported:

	•	Pre-Boarding
	•	Boarding
	•	Boarding Complete
	•	Safety Demonstration
	•	Takeoff
	•	Climb
	•	Cruise
	•	Prepare for Landing
	•	Final Approach
	•	Post Landing
	•	Emergency

These phases can be expanded or customized as needed.

Functions

ANNOUNCEMENTS.play_sound(announcement_name)

Plays the specified announcement sound.

	•	Parameters:
	•	announcement_name (string): The name of the announcement phase to play.
	•	Logic:
	•	Checks for any currently playing announcement and stops it before playing the new one.
	•	Implements debounce logic to prevent multiple plays of the same announcement within a short duration.
	•	Updates the last play time for the announcement.
	•	Logs the status of the play action, whether successful or if the sound file is not found.

ANNOUNCEMENTS.stopSounds()

Stops all currently playing sounds.

	•	Functionality:
	•	Iterates through all phases and stops any sounds that are currently playing.
	•	Resets the is_announcement_playing flag.

ANNOUNCEMENTS.unloadAllSounds()

Unloads all loaded sounds from memory.

	•	Functionality:
	•	Marks all loaded sounds as false to release them.
	•	Logs the unloading process for each sound.

ANNOUNCEMENTS.loadSounds()

Loads the announcement sounds from the specified directory and marks them as ready.

	•	Logic:
	•	Attempts to load .wav files for each announcement phase from the predefined directory.
	•	Logs success or failure of the loading process for each announcement.
	•	If loading is successful, plays any pending sounds queued during the loading process.

ANNOUNCEMENTS.on_sound_complete()

Called when an announcement finishes playing to reset the playing state.

	•	Functionality:
	•	Resets the is_announcement_playing flag to allow subsequent sounds to be played.

ANNOUNCEMENTS.play_pending_sounds()

Plays any sounds that were queued while sounds were being loaded.

	•	Functionality:
	•	Iterates through the pending sounds queue and plays each sound.
	•	Clears the queue after all sounds are played.

Variables

debounce_duration

	•	Type: Number
	•	Description: The time (in seconds) to prevent repeated playing of the same announcement. Default is set to 5 seconds.

last_play_times

	•	Type: Table
	•	Description: Tracks the last play time for each announcement to enforce debounce logic.

is_announcement_playing

	•	Type: Boolean
	•	Description: Flag to track if any announcement is currently playing. Prevents overlap of announcements.

ANNOUNCEMENTS_DIR

	•	Type: String
	•	Description: The directory where all announcement sound files are stored.

ANNOUNCEMENTS.sounds

	•	Type: Table
	•	Description: Stores the loaded sound handles for each announcement phase.

ANNOUNCEMENTS.files

	•	Type: Table
	•	Description: Stores the file paths for each loaded sound.

ANNOUNCEMENTS.pending_sounds

	•	Type: Table
	•	Description: Queues sounds triggered during the loading process to be played once loading is complete.

ANNOUNCEMENTS.is_loaded

	•	Type: Boolean
	•	Description: Indicates whether all announcements have been successfully loaded.

ANNOUNCEMENTS.is_safety_demo_playing

	•	Type: Boolean
	•	Description: Tracks whether the safety demonstration announcement is currently playing to manage its specific state.

Logging

The module logs various actions and states (e.g., sound loading, sound playing, debounce skipping, etc.) using the XA_CABIN_LOGGER.write_log function, which is expected to handle logging in the cabin system. Make sure this logger is set up in your environment for proper debugging and tracking.

Directory Structure

The announcement files are expected to follow this directory structure:

/xa-cabin/announcements/
    pre_boarding/
    boarding/
    boarding_complete/
    ...

Each subdirectory contains the respective .wav files for different language and accent combinations, such as:

en-gb-1.wav
en-us-1.wav

Integration

This module is designed to be integrated with a cabin system that handles playing sounds during a flight’s lifecycle. Ensure the announcement files are correctly placed in the ANNOUNCEMENTS_DIR and that the logger (XA_CABIN_LOGGER) is properly set up for the script to function as expected.