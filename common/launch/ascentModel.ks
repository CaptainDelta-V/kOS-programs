
@LAZYGLOBAL OFF.
// For 2nd Stages
FUNCTION ASCENT_MODEL { 

    FUNCTION TIME_TO_APOAPSIS { 
        RETURN SHIP:ORBIT:ETA:APOAPSIS.
    }

    RETURN LEXICON(
        "TIME_TO_APOAPSIS", TIME_TO_APOAPSIS@
    ).
}