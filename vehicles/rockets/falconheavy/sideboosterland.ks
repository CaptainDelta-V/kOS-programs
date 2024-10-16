@LAZYGLOBAL OFF.
WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/landing/landingStatusModel"). 
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/launch/boosterLaunchModel").
RUNONCEPATH("../../../common/launch/utils").
RUNONCEPATH("constants").

PARAMETER BOOSTER_SIDE. // north/south
PARAMETER LANDING_SITE_KEY. 

LOCAL LANDING_SITE TO LANDING_SITES[LANDING_SITES].

SET SHIP:NAME TO "FH_SIDE_BOOSTER_" + BOOSTER_SIDE.
LOCAL ENGINE TO SHIP:PARTSTAGGED("MERLINS")[0].
LOCAL ENGINE_MODULE TO ENGINE:GETMODULE(TUNDRA_ENGINE_MODULE_NAME).
LOCAL ENGINE_MANAGER TO ENGINE_MANAGER(ENGINE_MODULE, VESSEL_TYPE_FALCON_BOOSTER).

LOCAL FLIGHT_STATUS TO FLIGHT_STATUS_MODEL("FALCON HEAVY SIDE BOOSTER LANDING", "INITIALIZATION").

FLIGHT_STATUS:UPDATE("WAITING FOR LANDING INITIALIZATION MESSAGE").

LOCAL START_BOOSTER_LANDING TO FALSE. 
UNTIL START_BOOSTER_LANDING { 

    IF NOT SHIP:MESSAGES:EMPTY { 
        LOCAL MESSAGE TO SHIP:MESSAGES:POP:CONTENT.
        IF MESSAGE =  SIDE_BOOSTER_LANDING_INIT_MESSAGE { 
            SET START_BOOSTER_LANDING TO TRUE. 
        }   
        ELSE {
            FLIGHT_STATUS:UPDATE("RECEIVED INVALID MESSAGE").
        }
    }
    
    WAIT 0. 
}

FLIGHT_STATUS:UPDATE("BOOSTER LANDING ENGAGE").

WAIT UNTIL FALSE. 









