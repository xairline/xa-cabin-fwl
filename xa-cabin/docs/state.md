
# XA Cabin Flight

This script handles various states of flight and cabin operations in an aircraft simulation environment. It monitors flight status (e.g., parked, takeoff, cruise) and cabin activities (e.g., boarding, safety demonstration) and triggers state changes based on certain conditions.

## Features

- **Flight Phases**: Automatically detects the current flight phase (e.g., parked, takeoff, climb) and transitions between phases based on conditions such as speed, altitude, and engine power.
- **Cabin States**: Tracks cabin activities like boarding, safety demonstrations, and announcements, synchronizing them with flight phases.
- **Debouncing**: Prevents rapid state changes with a configurable debounce threshold.
- **Logging**: Detailed logs for debugging and auditing state transitions.
- **Automated Announcements**: Plays cabin announcements based on flight and cabin states, such as boarding complete, takeoff, and landing preparation.

## Flight States

The script tracks the following flight states to manage transitions during the flight:

1. **Parked**
   - Initial state when the aircraft is on the ground with engines off or at idle and the parking brake applied.
   - **Triggers**:
     - Ground speed < 1 m/s, altitude AGL < 10 ft, engine N1 < 30%.
     - If doors are open, the state transitions to pre_boarding. If doors are closed, it transitions to boarding_complete.

2. **Taxi Out**
   - The aircraft is preparing for takeoff and moving on the ground.
   - **Triggers**:
     - Ground speed > 5 m/s and gear force > 1.
     - Engine N1 > 75%.

3. **Takeoff**
   - The aircraft is accelerating for takeoff.
   - **Triggers**:
     - N1 exceeds 75% and vertical speed (VS) > 200 ft/min, gear force < 1.

4. **Climb**
   - The aircraft is climbing after takeoff.
   - **Triggers**:
     - Vertical speed (VS) remains stable between -500 and +500 ft/min for an extended period.

5. **Cruise**
   - The aircraft has reached cruising altitude and maintains stable vertical speed.
   - **Triggers**:
     - VS is stable between -500 and +500 ft/min for over 15 consecutive checks.

6. **Descent**
   - The aircraft starts descending toward the destination.
   - **Triggers**:
     - VS < -500 ft/min for over 15 consecutive checks.

7. **Approach**
   - The aircraft is in the approach phase, preparing for landing.
   - **Triggers**:
     - Altitude AGL < 800 feet, gear deployed, VS < -200 ft/min.

8. **Taxi In**
   - The aircraft has landed and is taxiing to the gate.
   - **Triggers**:
     - Ground speed < 50/1.9 m/s and gear force > 10.

9. **Parked (After Taxi In)**
   - The aircraft is parked at the gate after landing.
   - **Triggers**:
     - Ground speed < 1/1.9 m/s and N1 > 15%.

## Cabin States

The script tracks cabin states to manage activities like boarding, safety demonstrations, and announcements. Cabin state transitions are triggered by flight state changes and door status:

1. **Pre-Boarding**
   - Initial state before passengers board.
   - **Triggers**:
     - Doors open, flight parked.

2. **Boarding**
   - Passengers are boarding.
   - **Triggers**:
     - Random delay after doors open and flight is parked.

3. **Boarding Complete**
   - Boarding is complete, and preparations for departure begin.
   - **Triggers**:
     - Doors closed, aircraft ready for taxi-out.

4. **Safety Demonstration**
   - Safety demonstration announcement.
   - **Triggers**:
     - Taxi-out begins, landing lights on.

5. **Takeoff (Cabin)**
   - Cabin secured for takeoff.
   - **Triggers**:
     - Takeoff initiated after safety demo.

6. **Climb (Cabin)**
   - Cabin is in the climb phase.
   - **Triggers**:
     - The flight enters the climb phase.

7. **Cruise (Cabin)**
   - Cabin is in the cruise phase.
   - **Triggers**:
     - The flight reaches the cruise phase.

8. **Prepare for Landing**
   - Cabin prepares for landing.
   - **Triggers**:
     - The flight enters descent.

9. **Final Approach**
   - Cabin secured for landing.
   - **Triggers**:
     - The flight enters the approach phase.

10. **Post Landing**
   - Post-landing procedures.
   - **Triggers**:
     - The flight state changes to taxi-in after landing.

## State Change Debouncing

To prevent frequent state changes due to transient conditions, the script implements a debouncing mechanism:

- States cannot change more than once within a configurable time (default: 5 seconds).
- This helps avoid rapid, recursive state changes that could destabilize the simulation.

## Logging

All state transitions and actions are logged using `XA_CABIN_LOGGER` for debugging and auditing purposes. These logs help track the flow of state changes throughout the flight and cabin procedures.

## Usage

To use the script, ensure that the required datarefs are properly initialized, and the announcements are correctly loaded. The script will automatically detect and manage flight and cabin states based on flight conditions and cabin operations.

## Announcements

Announcements are played according to cabin state transitions. Make sure to include the appropriate sound files in the designated directory for each state. If a sound file is not found, a log entry will indicate the missing announcement.
