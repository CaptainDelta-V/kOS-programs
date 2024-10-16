RUNONCEPATH("1:common/control").
RUNONCEPATH("1:common/math").

FUNCTION BOOSTBACK_BURN_CONTROLLER {     
    PARAMETER LANDING_STATUS.
    PARAMETER LANDING_STEERING.

    FUNCTION CALCULATE_OVERSHOOT { 
        PARAMETER DISTANCE. 
        PARAMETER ECCENTRICITY. 

        RETURN 0. 
    }
    

    FUNCTION ENGAGE { 
        PARAMETER BOOST_PITCH TO 0.
        PARAMETER MIN_ERROR TO 10_000.
        PARAMETER THROTTLE_CURVE TO -1.
        PARAMETER USE_VECT_STEER TO FALSE.    

        LOCAL COURSE_CORRECTION_ITERATIONS TO 1. // NEED TO ACCOUNT FOR WHEN THE FIRST ITERATION GOES PAST THE SITE, NOT TO TURN AROUND
        LOCAL COURSE_CORRECTION_IDX TO 1.
        UNTIL COURSE_CORRECTION_IDX > COURSE_CORRECTION_ITERATIONS {             
            LOCAL INIT_HDG TO LANDING_STATUS:HEADING_FROM_IMPACT_TO_TARGET().                

            IF USE_VECT_STEER { 
                LOCK STEERING TO LANDING_STEERING:STEERING_VECTOR().
            }
            ELSE { 
                LOCK STEERING TO HEADING(INIT_HDG, BOOST_PITCH).
            }
            WAIT 1.
            WAIT_UNTIL_OREINTED(25, 50).
            SET INIT_HDG TO LANDING_STATUS:HEADING_FROM_IMPACT_TO_TARGET().
            IF THROTTLE_CURVE = -1 {
                LOCK THROTTLE TO 1.            
            }
            ELSE { 
                LOCK THROTTLE TO LINEAR_FALLOFF(0.00005, LANDING_STATUS:TRAJECTORY_ERROR_METERS(), 1). 
            }
            WAIT 0.1.        

            // UNTIL ERROR STARTS INCREASING, MEANS GOT AS CLOSE AS WE COULD
            LOCAL PREV_ERR_METERS TO LANDING_STATUS:TRAJECTORY_ERROR_METERS() + 1.
            UNTIL FALSE {        

                LOCAL ERR_CURR IS LANDING_STATUS:TRAJECTORY_ERROR_METERS().                

                LOCAL MIN_THROTTLE TO 0.05.
                IF (ERR_CURR > PREV_ERR_METERS OR THROTTLE < MIN_THROTTLE) AND ERR_CURR < MIN_ERROR {    
                    LOCK THROTTLE TO 0.
                    SET COURSE_CORRECTION_IDX TO COURSE_CORRECTION_IDX + 1.
                    BREAK.
                }

                SET PREV_ERR_METERS TO ERR_CURR.
                WAIT 0. 
            }
        }       
    }

    RETURN LEXICON( 
        "ENGAGE", ENGAGE@
    ).      
}