@LAZYGLOBAL OFF.
WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("constants").
RUNONCEPATH("../../../common/exceptions").
RUNONCEPATH("../../../common/constants").
RUNONCEPATH("../../../common/landing/sites").
RUNONCEPATH("../../../common/engineManager").
RUNONCEPATH("../../../common/flightStatus/flightStatusModel").
RUNONCEPATH("../../../common/landing/landingStatusModel").
RUNONCEPATH("../../../common/landing/landingSteeringModel").
RUNONCEPATH("../../../common/landing/landingBurnModel").
RUNONCEPATH("../../../common/landing/gridFinManager").
RUNONCEPATH("../../../common/landing/boostbackBurnController").
RUNONCEPATH("../../../common/flight/hover").
RUNONCEPATH("../../../common/infos").
RUNONCEPATH("../../../common/control").
RUNONCEPATH("../../../common/nav").
RUNONCEPATH("../../../common/booting/bootUtils").

SET SHIP:NAME TO ACTIVE_STARSHIP_BOOSTER_VESSEL_NAME.
PARAMETER SKIP_BOOSTBACK TO FALSE.
PARAMETER SKIP_WAIT_FOR_INITIATE_MESSAGE TO FALSE.

LOCAL ENGINES TO SHIP:PARTSTAGGED("BOOSTER_RAPTORS")[0].
LOCAL ENGINE_MODULE TO ENGINES:GETMODULE("ModuleTundraEngineSwitch").
LOCAL GRID_FINS TO SHIP:PARTSTAGGED("GRID_FIN").

LOCAL ENGINE_MANAGEMENT TO ENGINE_MANAGER(ENGINE_MODULE, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).
LOCAL GRID_FIN_MANAGEMENT TO GRID_FIN_MANAGER(GRID_FINS, VESSEL_TYPE_SUPER_HEAVY_BOOSTER).

LOCAL TOWER_STATUS TO "NOT CONNECTED".
LOCAL LANDING_SITE IS LANDING_SITES[KEY_KSC_PAD_MAIN].
LOCAL LANDING_STATUS TO LANDING_STATUS_MODEL(LANDING_SITE).
LOCAL LANDING_STEERING TO LANDING_STEERING_MODEL(LANDING_SITE).

LOCAL RADAR_OFFSET TO 63.25.
LOCAL TOWER_CATCH_ALT TO 137.
LOCAL FLIGHT_STATUS TO FLIGHT_STATUS_MODEL("SUPER HEAVY BOOSTER LANDING GUIDANCE").

LOCAL REAL_LANDING_STATUS TO LANDING_STATUS_MODEL(LANDING_SITE).
FLIGHT_STATUS:ADD_FIELD("TOWER", TOWER_STATUS).
FLIGHT_STATUS:ADD_FIELD("LATITUDE ERROR", REAL_LANDING_STATUS:LATITUDE_ERROR@).
FLIGHT_STATUS:ADD_FIELD("LONGITUDE ERROR", REAL_LANDING_STATUS:LONGITUDE_ERROR@).
FLIGHT_STATUS:ADD_FIELD("TRAJECTORY ERROR METERS", REAL_LANDING_STATUS:TRAJECTORY_ERROR_METERS@).
FLIGHT_STATUS:ADD_FIELD("POSITION_ERROR_METERS", REAL_LANDING_STATUS:POSITION_ERROR_METERS@).
FLIGHT_STATUS:ADD_FIELD("RETROGRADE", {
    LOCAL RETRO TO -SHIP:VELOCITY:SURFACE.
    RETURN "HDG: " + HEADING_OF_VECTOR(RETRO) + "P: " + PITCH_OF_VECTOR(RETRO).
}).
FLIGHT_STATUS:ADD_FIELD("ECC", REAL_LANDING_STATUS:ECCENTRICITY@).

// LOCAL BOOSTBACK_PITCH TO 45. // tanker weight
LOCAL BOOSTBACK_PITCH TO 14. // base systems weight

RUN_FLIGHT_STATUS_SCREEN(FLIGHT_STATUS, 0.25).
RESET_TORQUE().

LOCK THROTTLE TO 0.
SAS OFF. 
RCS ON.
WAIT 0.

ENGINE_MANAGEMENT:SET_ENGINE_STATE(TRUE).
ENGINE_MANAGEMENT:SET_ENGINE_MODE(ENG_MODE_MID_INR).
ENGINE_MANAGEMENT:SET_ENGINE_MODE(ENG_MODE_ALL).

RCS ON.
LOCK STEERING TO HEADING(LANDING_STATUS:RETROGRADE_HEADING(), BOOSTBACK_PITCH, 90). 

FLIGHT_STATUS:UPDATE("CHECKING FOR LANDING SEQUENCE INITIATION MESSAGE").
WAIT 0.5.

IF NOT SKIP_WAIT_FOR_INITIATE_MESSAGE { 
    LOCAL START_BOOSTBACK TO FALSE.
    WHEN NOT SHIP:MESSAGES:EMPTY THEN { 
        LOCAL MESSAGE TO SHIP:MESSAGES:PEEK:CONTENT.
        IF MESSAGE = INITIATE_LANDING_SEQUENCE_MESSAGE { 
            SET START_BOOSTBACK TO TRUE. 
        }      
    }

    WAIT UNTIL START_BOOSTBACK.
}

IF NOT SKIP_BOOSTBACK { 
    FLIGHT_STATUS:UPDATE("BOOSTBACK ORIENTATION").
    LOCAL BOOSTBACK_CONTROLLER TO BOOSTBACK_BURN_CONTROLLER(LANDING_STATUS, LANDING_STEERING).
    BOOSTBACK_CONTROLLER:ENGAGE(BOOSTBACK_PITCH, 5_000, 0.00005).
}

FLIGHT_STATUS:UPDATE("POST BOOSTBACK COAST").
RCS ON.

LOCAL VIRTUAL_TARGET_ALTITUDE TO 1_000.
LOCAL TRUE_LANDING_STATUS IS LANDING_STATUS_MODEL(LANDING_SITE).

WAIT UNTIL ALTITUDE < 80_000.
    FLIGHT_STATUS:UPDATE("GRID FIN CORRECTION").
    
    SET LANDING_STATUS TO LANDING_STATUS_MODEL(LANDING_SITE, VIRTUAL_TARGET_ALTITUDE):OVERSHOOT(50).    

    SET LANDING_STEERING TO LANDING_STEERING_MODEL(LANDING_STATUS).
    LANDING_STEERING:SET_MAX_AOA(30).
    LOCAL LANDING_BURN TO LANDING_BURN_MODEL(RADAR_OFFSET).    

    FLIGHT_STATUS:ADD_FIELD("IMPACT TIME", LANDING_BURN:IMPACT_TIME@).
    FLIGHT_STATUS:ADD_FIELD("IDEAL THROTTLE", LANDING_BURN:IDEAL_THROTTLE@).
    FLIGHT_STATUS:ADD_FIELD("STOP DISTANCE", LANDING_BURN:STOP_DISTANCE@).
    FLIGHT_STATUS:ADD_FIELD("VIRUTAL TARGET ALTITUDE", LANDING_STATUS:GET_TARGET_ALTITUDE@).
    FLIGHT_STATUS:ADD_FIELD("SPEED LAT", { RETURN ROUND(LANDING_STATUS:SPEED_LATITUDE(), 2). }).
    FLIGHT_STATUS:ADD_FIELD("SPEED LONG", { RETURN ROUND(LANDING_STATUS:SPEED_LONGITUDE(), 2). }).
    // FLIGHT_STATUS:ADD_FIELD("", { RETURN LANDING_STATUS: }).

    LOCK STEERING TO HEADING(LANDING_STATUS:RETROGRADE_HEADING() + 180, 45, 0). 
   

WAIT UNTIL ALTITUDE < 70_000.   

    GRID_FIN_MANAGEMENT:SET_ENABLED(TRUE).
    GRID_FIN_MANAGEMENT:SET_AUTHORITY_LIMIT(48).
    LANDING_STEERING:SET_ERROR_SCALING(2).    

    LANDING_STATUS:SET_TARGET_ALTITUDE(VIRTUAL_TARGET_ALTITUDE).    
    LANDING_STEERING:SET_MAX_AOA(25).    

    FLIGHT_STATUS:ADD_FIELD("TARGET AOA", LANDING_STEERING:GET_TARGET_AOA@).
    FLIGHT_STATUS:ADD_FIELD("TARGET AOA RAW", LANDING_STEERING:GET_TARGET_AOA_RAW@).

    FLIGHT_STATUS:UPDATE("DIRECT TRAJECTORY").
    LANDING_STEERING:SET_MAX_AOA(42).    
    LANDING_STATUS:SET_LANDING_SITE(LANDING_SITE).
    LOCK STEERING TO LANDING_STEERING:STEERING_VECTOR().

WAIT UNTIL ALTITUDE < 40_000. 
    LANDING_STATUS:SET_LANDING_SITE(LANDING_SITE).
    RCS OFF.

WAIT UNTIL ALTITUDE < 25_000.     
    LANDING_STATUS:SET_LANDING_SITE(LANDING_STATUS_MODEL(LANDING_SITE):OVERSHOOT(50):GET_LANDING_SITE()).     
    LANDING_STEERING:SET_ERROR_SCALING(1).
    LANDING_STEERING:SET_MAX_AOA(22).

WAIT UNTIL ALTITUDE < 5_000.     
    LANDING_STATUS:SET_LANDING_SITE(LANDING_STATUS_MODEL(LANDING_SITE):OVERSHOOT(25):GET_LANDING_SITE()).     

LANDING_BURN:SET_RADAR_OFFSET(750).
LOCAL SUICIDE_MARGIN TO 400.
WHEN LANDING_BURN:TRUE_RADAR() < LANDING_BURN:STOP_DISTANCE() + SUICIDE_MARGIN THEN {
    LOCK THROTTLE TO 1.
    FLIGHT_STATUS:UPDATE("LANDING BURN").
    STOP_RUN_FLIGHT_STATUS_SCREEN().
    RUN_FLIGHT_STATUS_SCREEN(FLIGHT_STATUS, 0.25).
    
    LOCAL LANDING_OFFSET TO 0.
    
    LANDING_BURN:SET_RADAR_OFFSET(RADAR_OFFSET).   
    LANDING_STATUS:SET_LANDING_SITE(LANDING_STATUS_MODEL(LANDING_SITE):OFFSET(LANDING_OFFSET, 0):GET_LANDING_SITE()).                                                                                     
    LANDING_STEERING:SET_MAX_AOA(-1.5).
    LANDING_STEERING:SET_ERROR_SCALING(1).
    LANDING_STATUS:SET_TARGET_ALTITUDE(0).    
    
    WAIT UNTIL SHIP:VERTICALSPEED > -200.
        ENGINE_MANAGEMENT:SET_ENGINE_MODE(ENG_MODE_MID_INR).        
        WAIT 0. 
        LANDING_STEERING:SET_MAX_AOA(-14).
        LANDING_STEERING:SET_ERROR_SCALING(10).        
        FLIGHT_STATUS:UPDATE("LANDING BURN - INNER").                        
        LANDING_STATUS:SET_LANDING_SITE(LANDING_STATUS_MODEL(LANDING_SITE):OFFSET(LANDING_OFFSET, 0):GET_LANDING_SITE()).                       

    WAIT UNTIL SHIP:VERTICALSPEED > -150.
        LOCK THROTTLE TO LANDING_BURN:IDEAL_THROTTLE().    

    WAIT UNTIL ALTITUDE < 450.                 
        LANDING_STATUS:SET_LANDING_SITE(LANDING_STATUS_MODEL(LANDING_SITE):OFFSET(LANDING_OFFSET, 0):GET_LANDING_SITE()).                       
        LANDING_STEERING:SET_ERROR_SCALING(16).        

    WAIT UNTIL LANDING_BURN:TRUE_RADAR() < 150.         
        LANDING_STATUS:SET_LANDING_SITE(LANDING_STATUS_MODEL(LANDING_SITE):OFFSET(LANDING_OFFSET, 0):GET_LANDING_SITE()).      

    LOCAL LANDING_ROTATION_START TO FALSE. 
    UNTIL LANDING_ROTATION_START { 
        SET LANDING_ROTATION_START TO LANDING_BURN:TRUE_RADAR() < 50.
        WAIT 0.
    }

    LOCK STEERING TO HEADING(0, 90, 60).                
    // LANDING_STEERING:SET_MAX_AOA(-2).
    // LANDING_STEERING:SET_ERROR_SCALING(20).        

    LOCAL HOVER_START TO FALSE. 
    UNTIL HOVER_START {         
        SET HOVER_START TO SHIP:VERTICALSPEED > -2 OR LANDING_BURN:TRUE_RADAR() < 0.5.              
        WAIT 0.                
    }

    GRID_FIN_MANAGEMENT:SET_ENABLED(FALSE).        
    FLIGHT_STATUS:UPDATE("HOVER FOR CATCH").

    LOCAL TOWER_VESSEL TO VESSEL(TOWER_VESSEL_NAME).
    TOWER_VESSEL:CONNECTION:SENDMESSAGE(TOWER_CATCH_MESSAGE).    
    RUN_ALTITUDE_HOLD(TOWER_CATCH_ALT, 3).            
    LOCK THROTTLE TO LANDING_BURN:IDEAL_THROTTLE().  
    // TOWER_VESSEL:CONNECTION:SENDMESSAGE(TOWER_CATCH_DAMPEN_MESSAGE).
    WAIT 0.5.
    LOCK THROTTLE TO 0.
                        
    SET SHIP:NAME TO "RETURNED BOOSTER".
    SET CORE:BOOTFILENAME TO "".         
    SHUTDOWN.                                                     
}

WAIT UNTIL FALSE.

