
# Flight Announcement TTS Generator

This Python script generates flight announcements as audio files using OpenAI’s text-to-speech (TTS) API. The generated audio files are saved in .wav format and cover various phases of a flight, such as boarding, takeoff, landing, and more. The script supports multiple languages and accents, and allows custom voice options for generating announcements.

## Features

- Generates pre-defined flight announcements (e.g., boarding, safety, takeoff, landing) based on flight information.
- Supports multiple languages and accents.
- Converts generated audio to .wav format (44.1 kHz, mono, 16-bit PCM).
- Saves audio files in structured directories based on announcement phases.
- Asynchronous generation of TTS files using threading.

## Requirements

- Python 3.x
- OpenAI API key
- `pydub` for audio processing
- FFmpeg and FFprobe installed on your system (required by `pydub` for audio conversion)

## Python Libraries

- `openai`
- `pydub`

## Setup

### 1. Install required dependencies:

Install the required Python packages using pip:

```bash
pip install openai pydub
```

### 2. Install FFmpeg:

Make sure you have FFmpeg and FFprobe installed. You can install them using brew (on macOS) or other package managers:

```bash
brew install ffmpeg
```

### 3. Set FFmpeg and FFprobe paths:

Update the paths in the script to point to your FFmpeg and FFprobe installation:

```python
AudioSegment.converter = "/path/to/ffmpeg"
AudioSegment.ffprobe = "/path/to/ffprobe"
```

## Usage

To run the script, you need to pass flight-related information as command-line arguments. Here is the expected format of the arguments:

```bash
python script_name.py <airline> <flight_number> <destination> <eta> <language> <accent> <speaker> <departure_runway> <arrival_runway> <cruise_altitude> <flight_time_hours> <flight_time_minutes> <local_time_at_destination> <landing_time> <aircraft_type> <time_of_day>
```

### Example:

```bash
python script_name.py "XXX Airlines" "DAT01" "Paris" "14:30" "en" "us" "01" "Runway 25R" "Runway 27L" "35,000 ft" "2" "45" "10:30 AM" "15" "Boeing 737" "morning"
```

## Generated Announcements:

The script generates announcements for the following flight phases:

- Pre-Boarding
- Boarding
- Boarding Complete
- Safety Demonstration
- Takeoff
- Climb
- Cruise
- Prepare for Landing
- Final Approach
- Post Landing
- Emergency

## Configuration

You can modify the default data passed to the TTS system by updating the `fms_data` dictionary in the script. The script supports the following data fields:

- `airline`: Name of the airline.
- `flight_number`: Flight number.
- `destination`: Destination of the flight.
- `eta`: Estimated time of arrival.
- `language`: Language for the announcement (e.g., “en” for English).
- `accent`: Accent for the announcement (e.g., “us” for American English).
- `speaker`: Speaker ID for OpenAI TTS (if applicable).
- `departure_runway`: Departure runway.
- `arrival_runway`: Arrival runway.
- `cruise_altitude`: Altitude during cruise.
- `flight_time_hours`: Flight time in hours.
- `flight_time_minutes`: Flight time in minutes.
- `local_time_at_destination`: Local time at the destination.
- `aircraft_type`: Type of the aircraft.
- `time_of_day`: Time of day (e.g., “morning”, “afternoon”).

## Supported languages

The TTS model generally follows the Whisper model in terms of language support. Whisper supports the following languages and performs well despite the current voices being optimized for English:

Afrikaans, Arabic, Armenian, Azerbaijani, Belarusian, Bosnian, Bulgarian, Catalan, Chinese, Croatian, Czech, Danish, Dutch, English, Estonian, Finnish, French, Galician, German, Greek, Hebrew, Hindi, Hungarian, Icelandic, Indonesian, Italian, Japanese, Kannada, Kazakh, Korean, Latvian, Lithuanian, Macedonian, Malay, Marathi, Maori, Nepali, Norwegian, Persian, Polish, Portuguese, Romanian, Russian, Serbian, Slovak, Slovenian, Spanish, Swahili, Swedish, Tagalog, Tamil, Thai, Turkish, Ukrainian, Urdu, Vietnamese, and Welsh.

## Output

Generated audio files will be saved in a structured directory under the `announcements/` folder in the script directory. Each announcement phase will have its own subdirectory.

## License

This project is open-source. Feel free to modify and use it as needed.

## Disclaimer

Ensure that your OpenAI API key is kept private and secure. Do not hardcode your API key in shared repositories.
