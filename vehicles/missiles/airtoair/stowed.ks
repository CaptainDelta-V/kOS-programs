

RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("constants").

CLEARSCREEN. 

LOCAL FLIGHT_STATUS TO FLIGHT_STATUS_MODEL("AIM-8 MISSILE CONTROL", "STOWED").
FLIGHT_STATUS:ADD_FIELD("READY", "YEP").

GET_LAUNCH_CONFIRMATION(FLIGHT_STATUS:GET_TITLE()).
RUN_FLIGHT_STATUS_SCREEN(FLIGHT_STATUS, 0.25).

FLIGHT_STATUS:UPDATE("MISSLE LAUNCH INITIATED").
SET BEEPER TO GETVOICE(1).
BEEPER:PLAY( NOTE(400, 0.20) ).

SET_ALTERNATE_BOOT_FILE("missleguidance").



