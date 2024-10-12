@LAZYGLOBAL OFF.
WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("constants").

CLEARSCREEN.
LOCAL TITLE TO "==== STARTOWER CATCH CONTROL ====".

SET SHIP:NAME TO TOWER_VESSEL_NAME.
LOCAL MECHAZILLA TO SHIP:PARTSTAGGED("MECH_ARMS")[0].
LOCAL MECHANIM_MODULE TO MECHAZILLA:GETMODULE("ModuleSLEAnimate").
LOCAL MECH_SLE_MODULE TO MECHAZILLA:GETMODULE("ModuleSLEController").

LOCAL FLIGHT_STATUS TO FLIGHT_STATUS_MODEL("STARTOWER CATCH CONTROL", "WAITING FOR CATCH COMMAND").
RUN_FLIGHT_STATUS_SCREEN(FLIGHT_STATUS).

UNTIL FALSE { 
    IF NOT SHIP:MESSAGES:EMPTY { 
        LOCAL MESSAGE TO SHIP:MESSAGES:POP:CONTENT.

        IF MESSAGE = TOWER_CATCH_MESSAGE {                 
            FLIGHT_STATUS:UPDATE("RAISING MECHAZILLA TO CATCH EXTENSION").
            MECHANIM_MODULE:SETFIELD("target extension", 4).
            FLIGHT_STATUS:UPDATE("CLOSING MECHAZILLA ARMS").
            MECH_SLE_MODULE:DOEVENT("close arms").
            FLIGHT_STATUS:UPDATE("CATCHING IT").
        }
        ELSE IF MESSAGE = TOWER_CATCH_DAMPEN_MESSAGE {
            MECHANIM_MODULE:SETFIELD("target extension", 6).
            WAIT 1.9.
            MECHANIM_MODULE:SETFIELD("target speed", 1).
            MECHANIM_MODULE:SETFIELD("target extension", 8).            
            WAIT 1.
            MECHANIM_MODULE:SETFIELD("target speed", 0.5).
            MECHANIM_MODULE:SETFIELD("target extension", 9).                        

            SET CORE:BOOTFILENAME TO "".
            SHUTDOWN.
        }
        ELSE { 
            FLIGHT_STATUS:UPDATE("RECEIVED INVALID MESSAGE").        
        }    
    }    

    WAIT 0.1.
}

WAIT UNTIL FALSE.