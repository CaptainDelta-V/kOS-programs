
@LAZYGLOBAL OFF.
RUNONCEPATH("1:common/constants").

FUNCTION GRID_FIN_MANAGER { 

    PARAMETER GRID_FINS. 
    PARAMETER VESSEL_TYPE.

    FUNCTION SET_ENABLED { 
        PARAMETER ENABLE.

        IF ENABLE { 
            IF VESSEL_TYPE = VESSEL_TYPE_SUPER_HEAVY_BOOSTER { 
                FOR FIN IN GRID_FINS {             
                    FIN:GETMODULE("ModuleControlSurface"):DOACTION("activate roll control", TRUE).
                    FIN:GETMODULE("ModuleControlSurface"):DOACTION("toggle pitch control", TRUE).
                    FIN:GETMODULE("ModuleControlSurface"):DOACTION("activate yaw control", TRUE).            
                }
            }
        }
        ELSE { 
            IF VESSEL_TYPE = VESSEL_TYPE_SUPER_HEAVY_BOOSTER { 
                FOR FIN IN GRID_FINS {             
                    FIN:GETMODULE("ModuleControlSurface"):DOACTION("deactivate roll control", TRUE).
                    FIN:GETMODULE("ModuleControlSurface"):DOACTION("toggle pitch control", TRUE).
                    FIN:GETMODULE("ModuleControlSurface"):DOACTION("deactivate yaw control", TRUE).            
                }
            }
       }
    }

    FUNCTION SET_AUTHORITY_LIMIT { 
        PARAMETER LIMIT. 

        FOR FIN IN GRID_FINS {             
            FIN:GETMODULE("ModuleControlSurface"):SETFIELD("authority limiter", LIMIT).
        }    
    }

    RETURN LEXICON(
        "SET_ENABLED", SET_ENABLED@,
        "SET_AUTHORITY_LIMIT", SET_AUTHORITY_LIMIT@
    ).
}