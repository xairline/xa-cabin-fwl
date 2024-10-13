import sys
import openai
import os
import threading
from pydub import AudioSegment
import io

# Ensure pydub can find ffmpeg
AudioSegment.converter = "/opt/homebrew/bin/ffmpeg"  # Update this path based on your ffmpeg installation
AudioSegment.ffprobe = "/opt/homebrew/bin/ffprobe"   # Update this path based on your ffprobe installation

# Directory to save announcement sound files
SCRIPT_DIRECTORY = os.path.dirname(os.path.abspath(__file__))
output_base_dir = os.path.join(SCRIPT_DIRECTORY, "announcements")
os.makedirs(output_base_dir, exist_ok=True)

# FMS data passed from Lua script as command-line arguments
# Expected arguments: airline, flight_number, destination, eta, language, accent, speaker
fms_data = {
    "airline": sys.argv[1] if len(sys.argv) > 1 else "Datanised Airlines",
    "flight_number": sys.argv[2] if len(sys.argv) > 2 else "DAT01",
    "destination": sys.argv[3] if len(sys.argv) > 3 else "Unknown",
    "eta": sys.argv[4] if len(sys.argv) > 4 else "Unknown",
    "language": sys.argv[5] if len(sys.argv) > 5 else "en",
    "accent": sys.argv[6] if len(sys.argv) > 6 else "gb",
    "speaker": sys.argv[7] if len(sys.argv) > 7 else "01",
    "departure_runway": sys.argv[8] if len(sys.argv) > 8 else "Runway 01",
    "arrival_runway": sys.argv[9] if len(sys.argv) > 9 else "Runway 02",
    "cruise_altitude": sys.argv[10] if len(sys.argv) > 10 else "35,000 ft",
    "flight_time_hours": sys.argv[11] if len(sys.argv) > 11 else "2",
    "flight_time_minutes": sys.argv[12] if len(sys.argv) > 12 else "30",
    "local_time_at_destination": sys.argv[13] if len(sys.argv) > 13 else "12:00 PM",
    "landing_time": sys.argv[14] if len(sys.argv) > 14 else "15",
    "aircraft_type": sys.argv[15] if len(sys.argv) > 15 else "Boeing 737",
    "time_of_day": sys.argv[16] if len(sys.argv) > 16 else "morning"
}

# Announcements for each stage of the flight
announcements = {
    "Pre-Boarding": f"""
    Ladies and gentlemen, welcome aboard {fms_data['airline']} flight {fms_data['flight_number']}.
    We will begin boarding shortly. Please ensure you have your boarding pass and identification ready.
    """,

    "Boarding": f"""
    Ladies and gentlemen, we are now ready to board {fms_data['airline']} flight {fms_data['flight_number']} bound for {fms_data['destination']}.
    Please listen for your group number, and ensure your boarding pass is ready as you approach the gate.
    """,

    "Boarding Complete": f"""
    Ladies and gentlemen, boarding for flight {fms_data['flight_number']} is now complete.
    Please stow your larger carry-on items in the overhead bins and smaller items under the seat in front of you.
    Ensure your seatbelt is fastened, your seatback is upright, and your tray table is stowed. 
    We will be departing from runway {fms_data['departure_runway']} shortly.
    """,

    "Safety Demonstration": f"""
    Ladies and gentlemen, for your safety, please direct your attention to the cabin crew as they demonstrate the safety features of this {fms_data['aircraft_type']}.
    Even if you are a frequent flyer, we ask that you pay close attention, as procedures may vary.
    """,

    "Takeoff": f"""
    Cabin crew, please prepare for takeoff. 
    Ladies and gentlemen, we are cleared for takeoff from runway {fms_data['departure_runway']}.
    Please ensure your seatbelt is securely fastened and all electronics are switched to airplane mode. 
    We expect smooth conditions on departure.
    """,

    "Climb": f"""
    Good {fms_data['time_of_day']}, this is your captain speaking. 
    We are now climbing to our cruising altitude of {fms_data['cruise_altitude']} feet, en route to {fms_data['destination']}.
    Please keep your seatbelt fastened as we continue our ascent. 
    The expected flight time is approximately {fms_data['flight_time_hours']} hours and {fms_data['flight_time_minutes']} minutes.
    """,

    "Cruise": f"""
    Ladies and gentlemen, we have now reached our cruising altitude of {fms_data['cruise_altitude']} feet.
    The seatbelt sign is turned off, but we recommend you keep your seatbelt fastened while seated, just in case of unexpected turbulence.
    Our cabin crew will be coming through the cabin with in-flight service shortly.
    """,

    "Prepare for Landing": f"""
    Ladies and gentlemen, we have begun our descent into {fms_data['destination']}, where the local time is {fms_data['local_time_at_destination']}.
    Please return to your seat, fasten your seatbelt, and make sure your seatback and tray table are in their upright and locked positions.
    We expect to land on runway {fms_data['arrival_runway']} in approximately 20 minutes.
    """,

    "Final Approach": f"""
    Cabin crew, please prepare the cabin for landing. 
    Ladies and gentlemen, we are on our final approach to {fms_data['destination']}. 
    Please ensure your seatbelt is fastened, and all personal items are properly stowed.
    """,

    "Post Landing": f"""
    Ladies and gentlemen, welcome to {fms_data['destination']}. The local time is {fms_data['local_time_at_destination']}.
    Please remain seated with your seatbelt fastened until the captain turns off the seatbelt sign. 
    Be careful when opening the overhead bins, as items may have shifted during the flight.
    """,

    "Emergency": """
    Ladies and gentlemen, we are experiencing an emergency situation. Please remain calm and follow all instructions from the cabin crew.
    Your safety is our priority, and we are prepared to assist you.
    """
}

# Initialize OpenAI client with your API key
openai.api_key = "xxxxxxxxxxxxxx"
client = openai

# Function to generate TTS using OpenAI's API with streaming response
def generate_tts(phase, text, language, accent, speaker):
    # Create subdirectory for the phase without replacing spaces
    phase_dir = os.path.join(output_base_dir, phase)  # Retain exact phase name
    os.makedirs(phase_dir, exist_ok=True)

    # Determine the voice parameter
    if language.lower() == "custom":
        voice = accent.lower()  # Use 'accent' as 'voice' for custom
    else:
        # Map predefined languages and accents to OpenAI voices
        voice_map = {
            ("en", "gb"): "Onyx",
            ("en", "us"): "Echo",
            ("es", "mx"): "Nova",
            # Add more mappings as needed
        }
        voice = voice_map.get((language.lower(), accent.lower()), "alloy")  # Default to 'alloy'

    # Construct the filename
    file_path = os.path.join(phase_dir, f"{language.lower()}-{accent.lower()}-1.wav")

    # Remove existing file if it exists
    if os.path.exists(file_path):
        os.remove(file_path)
        print(f"Removed existing file: {file_path}")

    # Generate the new audio file using OpenAI's streaming TTS API

    # Generate the new audio file using OpenAI's streaming TTS API
    try:
        with client.audio.speech.with_streaming_response.create(
            model="tts-1",  # Or "tts-1-hd" for high-definition quality
            voice=voice,
            input=text,
        ) as audio_content:
           # Save the audio file (initially as an mp3 or as received)
            mp3_path = file_path.replace(".wav", ".mp3")
            audio_content.stream_to_file(mp3_path)
            print(f"Generated new file: {mp3_path}")

        # Convert the file to a valid WAV format
        audio = AudioSegment.from_file(mp3_path)
        
        # Set parameters to ensure proper WAV format: 44.1 kHz, mono, 16-bit PCM
        audio = audio.set_frame_rate(44100).set_channels(1).set_sample_width(2)

        # Export as a valid WAV file
        audio.export(file_path, format="wav")
        print(f"Converted and saved as WAV: {file_path}")

        # Optionally remove the original mp3 file
        os.remove(mp3_path)
        print(f"Generated and converted file: {file_path}")

    except Exception as e:
        print(f"Error generating TTS for {phase}: {e}")

# Function to generate TTS files asynchronously
def generate_tts_files():
    threads = []
    for phase, text in announcements.items():
        # Create a thread for each TTS task using OpenAI's API
        t = threading.Thread(target=generate_tts, args=(phase, text, fms_data['language'], fms_data['accent'], fms_data['speaker']))
        threads.append(t)
        t.start()

    # Wait for all threads to complete
    for t in threads:
        t.join()
    return 

# Generate the audio files asynchronously
if __name__ == "__main__":
    generate_tts_files()