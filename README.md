# AI Powered Cabin Announcement

The AI Powered Cabin Announcement plugin is a powerful tool that enhances the cabin announcement system in aircraft. It utilizes advanced artificial intelligence algorithms to generate high-quality and natural-sounding announcements.

Compared to older plugins, the AI Powered Cabin Announcement plugin offers several advantages. Firstly, it provides more realistic and human-like voice synthesis, resulting in a more immersive and engaging experience for passengers. The AI algorithms used in this plugin have been trained on vast amounts of data, enabling them to produce highly accurate and expressive speech.

Additionally, the plugin offers greater flexibility and customization options. It allows for easy configuration of both global settings and specific settings for different aircraft types. This ensures that the announcements are tailored to the unique characteristics of each aircraft, enhancing the overall passenger experience.

Furthermore, the plugin supports the addition of sound packs, allowing airlines to incorporate their own branding and unique audio elements into the announcements. This level of customization helps to create a distinct and memorable cabin environment for passengers.

Lastly, the plugin includes a live generation feature, which is currently a work in progress (TODO). This feature will enable real-time generation of announcements based on dynamic factors such as flight status, weather conditions, and passenger demographics. This ensures that the announcements remain relevant and up-to-date throughout the flight.

Overall, the AI Powered Cabin Announcement plugin revolutionizes the cabin announcement system by leveraging AI technology to deliver superior audio quality, customization options, and dynamic generation capabilities.

# Installation

> **NOTE:** FlyWithLua is required

To install the plugin, follow these steps:

1. Download the plugin files.
2. Unzip the downloaded file.
3. Locate the `FlyWithLua/Scripts` folder in your flight simulator installation directory.
4. Copy all the files and folders from the unzipped plugin folder into the `FlyWithLua/Scripts` folder.

After the installation, the file structure should look like this:

```
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
```

# Configuration
## Global Config
The configuration is stored in xa-cabin.ini. Most configurations are avialable in the GUI

here are the available options:

[simbrief] section: (also in GUI)
- username: This option allows you to specify a username for SimBrief, which is a flight planning tool. You can set a value for this option to provide your SimBrief username.

[mode] section: (also in GUI)

- automated: This option is set to true, indicating that the cabin announcements will be played automatically without any manual intervention.
- live: This option is also set to true, indicating that the announcements will be generated in real-time. (WIP)

[announcement] section:

- language: This option allows you to specify the language for the cabin announcements. In this case, it is set to en for English.
- accent: This option allows you to specify the accent for the cabin announcements. In this case, it is set to in for Indian accent.
- speaker: This option allows you to specify the speaker for the cabin announcements. In this case, it is set to 01.

## Aircraft Config
A file named `xa-cabin.ini` is automatically created the first time you load that plane. The defaut configuration is using XPlane's default dataref which might not work for a lot of 3rd pary planes. You will need to configure it for each plane. If you want to run manually mode, this is not required.

[LANDING_GEAR]:

- operator: This option specifies the comparison operator used to evaluate the condition. In this case, it is set to ~=, which means "approximately equal to".

- threshold: This option sets the threshold value for the condition. Here, it is set to 0.
- dataref_str: This option specifies the data reference string, which is a reference to a specific data value in the simulation. In this case, it is set to sim/flightmodel2/gear/deploy_ratio.

[DOOR]:

- operator: This option specifies the comparison operator used to evaluate the condition. Here, it is set to >, which means "greater than".
- threshold: This option sets the threshold value for the condition. It is set to 0.9.
- dataref_str: This option specifies the data reference string, which is a reference to a specific data value in the simulation. In this case, it is set to sim/flightmodel2/misc/door_open_ratio.

[RWY_LIGHTS]:

- operator: This option specifies the comparison operator used to evaluate the condition. Here, it is set to ===, which means "strictly equal to".
- threshold: This option sets the threshold value for the condition. It is set to 1.
- dataref_str: This option specifies the data reference string, which is a reference to a specific data value in the simulation. In this case, it is set to ckpt/oh/rwyTurnOff/anim.


# Sound Pack
Currently, all announcements are generated using AI technology. However, we are actively working on developing a dedicated tool that will allow you to create your own custom sound pack in the future.
## Add Sound Pack (TODO)

## Live Generation (TODO)