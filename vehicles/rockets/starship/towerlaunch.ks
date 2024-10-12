@LAZYGLOBAL OFF.
WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("constants").

CLEARSCREEN.




LOCAL FLIGHT_STATUS TO FLIGHT_STATUS_MODEL("STARTOWER LAUNCH CONTROL", "WAITING FOR LAUNCH INITIATION").
RUN_FLIGHT_STATUS_SCREEN(FLIGHT_STATUS).

UNTIL FALSE { 
    IF NOT CORE:MESSAGES:EMPTY { 

        LOCAL MESSAGE TO CORE:MESSAGES:POP:CONTENT.
        FLIGHT_STATUS:UPDATE(MESSAGE).

        IF MESSAGE = TOWER_DELUGE_START_MESSAGE { 
            FLIGHT_STATUS:UPDATE( "STARTING WATER DELUGE").

            AG4 ON.
            AG3 ON. 
        }
        ELSE IF MESSAGE = TOWER_RELEASE_MESSAGE { 
            FLIGHT_STATUS:UPDATE("CLAMPS RELEASE").

            LOCAL QD_ARM TO SHIP:PARTSTAGGED(QD_ARM_TAG)[0].
            LOCAL OLM TO SHIP:PARTSTAGGED(OLM_TAG)[0].
            
            QD_ARM:GETMODULE("ModuleSLESequentialAnimate"):DOEVENT("full retraction").
            WAIT 0.
            OLM:GETMODULE("ModuleDockingNode"):DOEVENT("undock").

            WAIT 0.5.
            FLIGHT_STATUS:UPDATE("SETTING BOOT FILE TO CATCH.").
            SET_ALTERNATE_BOOT_FILE("towercatch").
            WAIT 8.

            // deluge off
            AG4 OFF.
            AG3 OFF. 
            REBOOT.
        }
        ELSE { 
            FLIGHT_STATUS:UPDATE("RECEIVED INVALID MESSAGE").
        }
    }
    
    WAIT 0.
}

// PRINT TITLE.
// PRINT "WAITING FOR RELEASE COMMAND . . .".

// WAIT UNTIL NOT CORE:MESSAGES:EMPTY.
// LOCAL RECD_MSG TO CORE:MESSAGES:POP.    // Deluge message
// HANDLE_MESSAGE(RECD_MSG:CONTENT).
// WAIT UNTIL NOT CORE:MESSAGES:EMPTY.

// WAIT UNTIL FALSE. 

// FUNCTION HANDLE_MESSAGE { 
//     PARAMETER CONTENT. 
//     IF CONTENT = TOWER_DELUGE_START_MESSAGE { 
//                   
//     }
//     ELSE IF CONTENT = TOWER_RELEASE_MESSAGE { 

        // LOCAL MECHAZILLA TO SHIP:PARTSTAGGED(MECHAZILLA_TAG)[0]./S
        
        // LOCAL OLM_PLATE TO SHIP:PARTSTAGGED(OLM_PLATE_TAG)[0].               
        
//         WAIT 0. 
//         PRINT "RELEASING OLM".

//     }
//     ELSE { 
//         PRINT "WTF DID YOU SEND ME BRUH".
//     }
// }
