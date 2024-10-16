RUNONCEPATH("1:common/math").

FUNCTION LANDING_STEERING_MODEL {
    PARAMETER LANDING_MODEL.
    PARAMETER ERROR_SCALING TO 1.

    LOCAL _MAX_AOA TO 0.
    LOCAL _ERROR_SCALING TO ERROR_SCALING.
    LOCAL _TARGET_AOA_RAW TO 0.
    LOCAL _TARGET_AOA_CAPPED TO 0.

    FUNCTION SET_MAX_AOA { 
        PARAMETER AOA.
        PARAMETER USE_DYNAMIC TO FALSE.
        PARAMETER MIN_A TO 0.        
        PARAMETER RATE TO 0.
        PARAMETER INVERT TO FALSE.
         
        IF USE_DYNAMIC { 
            LOCK _MAX_AOA TO MAX_AOA_DYNAMIC(MIN_A, AOA,
                LANDING_MODEL:ERROR_VECTOR():MAG, RATE, INVERT).
        }
        ELSE { 
            LOCK _MAX_AOA TO AOA.
        }
    }

    FUNCTION MAX_AOA { 
        RETURN _MAX_AOA.
    }

    FUNCTION GET_TARGET_AOA_RAW { 
        RETURN _TARGET_AOA_RAW.
    }

    FUNCTION GET_TARGET_AOA { 
        RETURN _TARGET_AOA_CAPPED.
    }

    FUNCTION SET_ERROR_SCALING { 
        PARAMETER SCALING.
        SET _ERROR_SCALING TO SCALING.
    }
    
    FUNCTION STEERING_VECTOR { 
        PARAMETER ROLL.

        LOCAL ERROR_VECTOR IS LANDING_MODEL:ERROR_VECTOR().
        LOCAL VELVECTOR IS -SHIP:VELOCITY:SURFACE.
        LOCAL RESULT IS VELVECTOR + ERROR_VECTOR * _ERROR_SCALING.

        SET _TARGET_AOA_RAW TO VANG(RESULT, VELVECTOR).

        IF VANG(RESULT, VELVECTOR) > _MAX_AOA
        {
            SET RESULT TO VELVECTOR:NORMALIZED
                            + TAN(_MAX_AOA) * ERROR_VECTOR:NORMALIZED.
        }        

        SET _TARGET_AOA_CAPPED TO VANG(RESULT, VELVECTOR).            
        LOCAL RESULT_DIRECTION TO LOOKDIRUP(RESULT, FACING:TOPVECTOR).
        
        RETURN R(RESULT_DIRECTION:PITCH, RESULT_DIRECTION:YAW, ROLL).
    }

    FUNCTION MAX_AOA_DYNAMIC { 
        PARAMETER MIN_A.
        PARAMETER MAX_A.    
        PARAMETER ERR_MTRS.
        PARAMETER RATE.         
        PARAMETER INVERT IS FALSE.
        
        LOCAL RET TO MIN(MAX(LINEAR_FUNC(RATE, ERR_MTRS, MIN_A), MIN_A), MAX_A).
        IF INVERT  { 
            SET RET TO -RET.
        }
        RETURN RET.
    }


    RETURN LEXICON(
        "SET_ERROR_SCALING", SET_ERROR_SCALING@,
        "STEERING_VECTOR", STEERING_VECTOR@,
        "SET_MAX_AOA", SET_MAX_AOA@,
        "MAX_AOA", MAX_AOA@,
        "GET_TARGET_AOA", GET_TARGET_AOA@, 
        "GET_TARGET_AOA_RAW", GET_TARGET_AOA_RAW@,
        "MAX_AOA_DYNAMIC", MAX_AOA_DYNAMIC@
    ).
}