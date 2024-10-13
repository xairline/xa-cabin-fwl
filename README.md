AI Powered Cabin Announcement

The AI Powered Cabin Announcement plugin enhances the cabin announcement system for flight simulations by utilizing cutting-edge artificial intelligence algorithms to generate high-quality, natural-sounding announcements.

Compared to older plugins, the AI Powered Cabin Announcement offers several advantages:

	1.	Human-like Voice Synthesis: The AI engine generates highly realistic and expressive speech, resulting in a more immersive experience for passengers.
	2.	Flexibility and Customization: The plugin allows easy configuration of both global and aircraft-specific settings, enabling tailored announcements based on each aircraft’s unique characteristics.
	3.	Sound Pack Integration: Airlines can incorporate their own branding and unique audio elements into announcements, creating a distinctive cabin environment.
	4.	Dynamic Announcement Generation: The plugin now supports real-time generation of announcements using generate_announcements.py. This feature adapts announcements based on dynamic factors like flight status, weather conditions, and passenger information, keeping them relevant throughout the flight.

Overall, the AI Powered Cabin Announcement plugin revolutionizes the in-flight announcement experience by leveraging AI technology to deliver superior audio quality, customization, and dynamic real-time generation.

Installation

	Note: FlyWithLua is required.

Follow these steps to install the plugin:

	1.	Download the plugin files.
	2.	Unzip the downloaded file.
	3.	Navigate to the FlyWithLua/Scripts folder in your flight simulator directory.
	4.	Copy all the files and folders from the unzipped plugin folder into the FlyWithLua/Scripts folder.

After installation, the file structure should look like this:

  Resources
    ...
    |- plugins
      ...
      |- FlyWithLua
        ...
        |- Scripts
          ...
          |- xa-cabin
          xa-cabin.lua
          xa-cabin.ini 

Configuration

Global Configurations

The main configuration file is xa-cabin.ini, where most options can also be modified through the in-game GUI.

[simbrief] section (also configurable in the GUI):

	•	username: Specify your SimBrief username to integrate flight planning data.

[mode] section (also configurable in the GUI):

	•	automated: Set to true to play cabin announcements automatically.
	•	live: Set to true to enable real-time announcement generation using generate_announcements.py.

[announcement] section:

	•	language: Specifies the language of the announcements (e.g., en for English).
	•	accent: Specifies the accent for the announcements (e.g., in for Indian accent).
	•	speaker: Sets the speaker ID (e.g., 01).

Aircraft-Specific Configuration

An aircraft-specific configuration file (xa-cabin.ini) is automatically created the first time you load the plane. This file uses X-Plane’s default datarefs, but for third-party aircraft, you may need to configure the datarefs manually for accurate announcement triggers.

Example Configurations:

	•	[LANDING_GEAR]:
	•	operator: The comparison operator, such as ~= (“approximately equal to”).
	•	threshold: The threshold value (e.g., 0).
	•	dataref_str: The data reference string (e.g., sim/flightmodel2/gear/deploy_ratio).
	•	[DOOR]:
	•	operator: Set to > for greater than.
	•	threshold: Set to 0.9.
	•	dataref_str: Reference for door position (e.g., sim/flightmodel2/misc/door_open_ratio).
	•	[LANDING_LIGHTS]:
	•	operator: Set to === for strict equality.
	•	threshold: Set to 1.
	•	dataref_str: Data reference string for runway lights (e.g., ckpt/oh/rwyTurnOff/anim).

Sound Pack

All announcements are currently generated using AI technology. However, we are working on a tool that will allow users to create custom sound packs in the future.

List of Available Sounds

Language	Accent	Speaker	Description
en	gb	1	British Accent
en	ca	1	Canadian Accent (SAS special)
en	in	1	Indian Accent

Adding a Custom Sound Pack

To add a custom sound pack:

	1.	Follow the naming convention above.
	2.	Place your .wav files in the corresponding folders under xa-cabin/announcements/.
	3.	Update the xa-cabin.ini configuration:

[announcement]
language=en
accent=gb
speaker=1

Real-Time Announcement Generation

The live generation feature is now implemented using the generate_announcements.py script. This script allows for dynamic generation of announcements based on real-time flight data, such as departure runways, estimated flight time, local time at destination, and weather conditions.

How to Use generate_announcements.py

The Python script generate_announcements.py dynamically generates announcements in real time when the language is set to custom.

	Note: Currently, you must run generate_announcements.py manually while X-Plane 12 is running, and then reload the Lua script. If you have already generated announcements for your flight, you do not need to run the script again.

Steps:

	1.	Ensure Python is installed on your system.
	2.	Set the language option to custom in the xa-cabin.ini file.
	3.	Once X-Plane 12 is running, manually run the Python script.
	4.	After running the script, reload the Lua script within X-Plane to load the generated announcements.

During the start of XA-CABIN, check the log file. The system will print the Python command along with all the parameters fetched from SimBrief. You can copy and run this command directly to generate the announcements.

Example Command:

/usr/local/bin/python3 "xa-cabin/generate_announcements.py" \
"XXXX Airlines" "DAT01" "Paris" "14:30" "en" "us" "01" \
"Runway 25R" "Runway 27L" "35,000 ft" "2" "30" "10:30 AM" \
"Boeing 737" "morning"

This command generates announcements for a flight based on SimBrief data, with real-time parameters like flight number, destination, ETA, and more.

The AI Powered Cabin Announcement plugin transforms in-flight audio by integrating AI technology, real-time capabilities, and flexible configuration options for creating a more realistic and engaging flight experience.