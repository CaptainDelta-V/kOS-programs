@LAZYGLOBAL OFF.
WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").

CLEARSCREEN.

LOCAL FLIGHT_STATUS TO FLIGHT_STATUS_MODEL("STARSHIP LAUNCH", "BOOSTER RIDE").
RUN_FLIGHT_STATUS_SCREEN(FLIGHT_STATUS, 0.75).

WAIT UNTIL ALTITUDE > 20_000.
FLIGHT_STATUS:UPDATE("WAITING FOR ASCENT HANDOFF . . .").

WAIT UNTIL NOT CORE:MESSAGES:EMPTY. 
LOCAL RECD_MSG TO CORE:MESSAGES:POP. 

IF RECD_MSG:CONTENT = STARSHIP_ASCENT_HANDOFF_MESSAGE {     
    WAIT UNTIL STAGE:READY.
    STAGE.            
    FLIGHT_STATUS:UPDATE("BOOTING INTO ASCENT MODE").
    SET_ALTERNATE_BOOT_FILE("starshipascent").
    WAIT 0.
    REBOOT. 
}
ELSE {    
    FLIGHT_STATUS:UPDATE("WTF").
}

