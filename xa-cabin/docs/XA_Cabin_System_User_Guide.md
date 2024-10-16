
# XA Cabin System User Guide

This user guide provides detailed instructions on how to use the **XA Cabin System**, which includes components for flight announcements, cabin configuration, and state management in flight simulation environments. Below are the main modules and features of the system, and how to operate them effectively.

## Table of Contents

1. [Introduction](#introduction)
2. [System Overview](#system-overview)
3. [Installation](#installation)
4. [Components Overview](#components-overview)
   - [ANNOUNCEMENTS Module](#announcements-module)
   - [Flight Announcement TTS Generator](#flight-announcement-tts-generator)
   - [XA Cabin Flight](#xa-cabin-flight)
   - [XA Cabin System](#xa-cabin-system)
5. [Usage](#usage)
6. [Configuration](#configuration)
7. [Logs](#logs)
8. [Dependencies](#dependencies)

---

## 1. Introduction

The **XA Cabin System** is a Lua-based script designed for flight simulation environments using FlyWithLua. It manages flight announcements, cabin configurations, and various flight phases to provide an immersive in-flight experience. It also integrates SimBrief data for generating realistic flight announcements, and offers support for custom languages through a Python-based TTS system.

---

## 2. System Overview

The system consists of several key components:
- Dynamic announcements based on flight phases.
- Integration with SimBrief for real-time flight data.
- A graphical user interface (GUI) for configuring and controlling the cabin system.
- Support for custom announcements using Python for text-to-speech (TTS) generation.

---

## 3. Installation

### Required Components:
1. **FlyWithLua**: This system is designed to run within FlyWithLua.
2. **Python**: For generating custom TTS announcements using OpenAI’s API.
3. **SimBrief Integration**: To pull real-time flight data.
4. **Sound Files**: Announcement audio files must be correctly placed in the `xa-cabin/announcements/` directory.

### Steps:
1. Place all required Lua files (e.g., `LIP.lua`, `logging.lua`, etc.) in the `xa-cabin/` directory.
2. Install and configure Python for TTS generation (if using custom language).
3. Ensure sound files are correctly placed in the appropriate directory.
4. Load the script using FlyWithLua.

---

## 4. Components Overview

### 4.1 ANNOUNCEMENTS Module

The ANNOUNCEMENTS module manages flight announcements, including playing, stopping, and queuing sounds. It supports several phases of flight and ensures smooth transitions between announcements.

- **Supported Phases**:
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

- **Debounce Logic**: Prevents the same announcement from playing multiple times within a short duration.

For more details, see the [ANNOUNCEMENTS Module Documentation](39).

### 4.2 Flight Announcement TTS Generator

This Python script generates flight announcements as audio files using OpenAI's TTS API. It supports multiple languages and accents, and generates announcements for various phases of the flight.

- **Features**:
  - Generates announcements based on flight information (airline, flight number, etc.).
  - Saves generated audio files in .wav format.
  - Supports asynchronous generation using threading.

For more details, see the [Flight Announcement TTS Generator Documentation](40).

### 4.3 XA Cabin Flight

This module handles flight and cabin state management. It monitors the phases of the flight (e.g., parked, takeoff, cruise) and triggers cabin activities accordingly.

- **Flight States**:
  - Parked
  - Taxi Out
  - Takeoff
  - Climb
  - Cruise
  - Descent
  - Approach
  - Taxi In
  - Parked (After Taxi In)

- **Cabin States**:
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

For more details, see the [XA Cabin Flight Documentation](41).

### 4.4 XA Cabin System

The main system script integrates various modules, including announcements, SimBrief data, and GUI elements. It ensures smooth transitions between cabin states and provides detailed logs for tracking actions and debugging.

- **Features**:
  - Dynamic announcements based on SimBrief data.
  - Custom TTS generation using Python.
  - Real-time updates for flight and cabin states.
  - GUI integration using ImGui for interactive controls.

For more details, see the [XA Cabin System Documentation](42).

---

## 5. Usage

To use the XA Cabin System, follow these steps:

1. **Load the Script**: Use FlyWithLua to load the script in your flight simulation environment.
2. **Configure the Cabin System**: Use the GUI to adjust cabin settings and start announcements.
3. **Monitor Flight Phases**: The system will automatically detect flight phases and trigger appropriate announcements.
4. **Custom Announcements**: If using a custom language, ensure Python is configured to generate TTS announcements dynamically.

---

## 6. Configuration

### INI Configuration:
The system reads configuration data from `xa-cabin.ini`. This file contains settings for aircraft type, preferred runways, announcement language, and more.

- Example of setting the language to custom:
  ```
  [announcement]
  language=custom
  ```

For more details on configuring custom announcements, see the [Flight Announcement TTS Generator Documentation](40).

---

## 7. Logs

All system events, including sound loading, state changes, and error handling, are logged using `XA_CABIN_LOGGER`. This logger is essential for debugging and monitoring the system’s performance during flights.

- Example Log Entry:
  ```
  XA Cabin Log: Successfully loaded announcement: /path/to/sound/en-gb-1.wav
  ```

---

## 8. Dependencies

- **FlyWithLua**: Required to run the system in flight simulation environments.
- **Python**: Needed for custom TTS announcement generation using OpenAI API.
- **SimBrief**: Required to retrieve real-time flight data for accurate announcements.

---

By following this user guide, you can set up and operate the XA Cabin System to simulate realistic and customizable flight announcements, tailored to each flight's specific conditions.

