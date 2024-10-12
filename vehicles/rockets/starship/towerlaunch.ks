@LAZYGLOBAL OFF.
WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("constants").

CLEARSCREEN.
LOCAL TITLE TO "==== STARTOWER LAUNCH CONTROL ====".
PRINT TITLE.
PRINT "WAITING FOR RELEASE COMMAND . . .".

WHEN NOT CORE:MESSAGES:EMPTY THEN { 
    LOCAL RECD_MSG TO CORE:MESSAGES:POP.
    HANDLE_MESSAGE(RECD_MSG:CONTENT).
}

WAIT UNTIL FALSE. 

FUNCTION HANDLE_MESSAGE { 
    PARAMETER CONTENT. 

    IF CONTENT = TOWER_RELEASE_MESSAGE { 
        LOCAL MECHAZILLA TO SHIP:PARTSTAGGED("MECH_ARMS")[0].
        PRINT "RELEASING MECHAZILLA ARMS".
        MECHAZILLA:GETMODULE("ModuleSLEController"):DOEVENT("open arms").
        WAIT 0.75.
        PRINT "RAISING MECHAZILLA TO CATCH EXTENSION".
        MECHAZILLA:GETMODULE("ModuleSLEAnimate"):SETFIELD("target extension", 0).

        PRINT "SETTING BOOT FILE TO CATCH.". 
        SET_ALTERNATE_BOOT_FILE("towercatch").
        WAIT 4.
        REBOOT.
    }
    ELSE { 
        PRINT "WTF DID YOU SEND ME BRUH".
    }
}
