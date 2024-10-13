XA Cabin System

This Lua script manages a comprehensive cabin announcement and configuration system for flight simulations using FlyWithLua. It integrates various components such as settings, logging, GUI, SimBrief data, and announcement generation, ensuring smooth and customizable flight announcements in multiple phases of a flight.

Features

	•	Dynamic Announcements: Generates flight announcements based on SimBrief data, including information such as airline, flight number, destination, estimated time of arrival (ETA), departure runway, and more.
	•	Flight Phases Support: Provides announcements for pre-defined flight phases (e.g., boarding, takeoff, cruise, landing).
	•	Debounce Logic: Prevents repetitive announcement playback within a short time frame.
	•	Custom Language Support: Allows custom announcement generation using Python if the language is set to “custom”.
	•	Real-time Updates: Tracks and updates the flight and cabin state throughout the flight.
	•	Graphical User Interface (GUI): Displays flight and cabin information in an interactive window using ImGui.
	•	Plane Configuration Management: Automatically loads and handles plane-specific configurations.
	•	SimBrief Integration: Retrieves flight data directly from SimBrief to generate accurate and up-to-date announcements.

Components

1. Loading and Initialization

The script initializes by loading required components, settings, and plane configurations:

	•	LIP: For managing INI files and configurations.
	•	Logging: Custom logging system for debugging and tracking cabin system behavior.
	•	Global Variables: Loads necessary global variables to ensure smooth operation.

2. Announcement Management

The system manages the loading, playing, stopping, and queuing of announcement sounds using the ANNOUNCEMENTS module. It ensures no overlapping sounds and provides clear logging for all sound events.

	•	Announcement Phases: The following phases are supported:
	•	Pre-boarding
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
	•	Debounce: A debounce system is in place to avoid rapid consecutive plays of the same announcement within a short period (configurable via debounce_duration).

3. SimBrief Data Integration

The script retrieves key flight data from SimBrief, including:

	•	Airline name
	•	Flight number and callsign
	•	Destination and origin runways
	•	ETA, flight duration, and time of day classification (morning, afternoon, night).

This data is then used to dynamically generate announcements using the Python-based TTS generator if the language is set to “custom”.

4. GUI Integration

The script includes a graphical interface built with ImGui, providing an easy-to-use window that displays flight information, cabin configuration options, and controls for playing announcements.

	•	Window Control: Functions to show, hide, and toggle the visibility of the cabin window (xa_cabin_show_wnd, xa_cabin_hide_wnd, toggle_xa_cabin_window).
	•	Customizable GUI: Displays SimBrief information, announcement settings, and allows control over flight states and cabin settings.

5. Custom Python TTS Announcements

When custom announcements are needed (e.g., for non-standard languages or accents), the script calls a Python script (generate_announcements.py) to create TTS audio files. This integration allows flexibility in generating personalized flight announcements.

6. Configuration Management

The script handles reading and saving the configuration from a plane-specific INI file (xa-cabin.ini). If the file does not exist, it creates a new one with default values. The configuration includes settings such as the type of aircraft, preferred runways, language, and accent for announcements.

7. Real-time State Updates

The system continuously updates the flight and cabin states in real-time using the xa_cabin_update_state function, ensuring that the cabin announcements and GUI reflect the current flight conditions.

Usage

Running the Script

To use this script, it must be placed in the appropriate FlyWithLua directory structure. The script relies on several components, including Python for TTS generation and sound handling, so ensure your environment is correctly set up:

	1.	Place all required Lua files (e.g., LIP.lua, logging.lua, helpers.lua, etc.) in the xa-cabin/ directory.
	2.	Ensure Python is installed and correctly configured to run TTS generation (if using custom language).
	3.	Make sure the sound files are correctly placed in the xa-cabin/announcements/ directory.
	4.	Load the script using FlyWithLua.

Customizing Announcements

If custom announcements are required:

	1.	Set the language to “custom” in the configuration (xa-cabin.ini).
	2.	Ensure the Python script for TTS generation (generate_announcements.py) is correctly configured.
	3.	The script will dynamically generate announcements using the command and Python script provided.

GUI Interaction

To interact with the cabin system GUI, use the following commands:

	•	Show/Hide Window: Use the XA Cabin macro or the created command xa_cabin_menus/show_toggle to open and close the GUI.

Example SimBrief Configuration

The system pulls data from SimBrief to generate accurate flight information. Ensure you have valid SimBrief data for realistic announcements.

Logs

All actions, including sound events, error handling, and state updates, are logged using the XA_CABIN_LOGGER, which records all operations for troubleshooting and debugging.

Example Log Entry:

XA Cabin Log: Successfully loaded announcement: /path/to/sound/en-gb-1.wav

Dependencies

	•	FlyWithLua: This script is designed to work within the FlyWithLua environment.
	•	SimBrief: For retrieving real-time flight data.
	•	Python: Required for generating custom TTS announcements using the OpenAI API.

License

This script is open-source. You are free to modify and distribute it under the terms of the applicable license.

By using this cabin system, you can simulate realistic and customizable cabin announcements, tailored to the specifics of each flight using real-world data from SimBrief.