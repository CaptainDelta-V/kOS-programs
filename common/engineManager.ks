
RUNONCEPATH("1:common/constants").
RUNONCEPATH("1:common/exceptions").

DECLARE GLOBAL TUNDRA_ENGINE_MODULE_NAME TO "ModuleTundraEngineSwitch".
DECLARE GLOBAL TUNDRA_ENGINE_SWITCH_NEXT TO "next engine mode".
DECLARE GLOBAL TUNDRA_ENGINE_SWITCH_PREV TO "previous engine mode".
DECLARE GLOBAL ENG_MODE_ALL TO "All Engines".
DECLARE GLOBAL ENG_MODE_MID_INR TO "Middle Inner".
DECLARE GLOBAL ENG_MODE_CTR TO "Center Three".

FUNCTION ENGINE_MANAGER { 
    PARAMETER ENGINE_MODULE. 
    PARAMETER VESSEL_TYPE.
    // TODO: add param for module type

    FUNCTION SET_ENGINE_STATE { 
        PARAMETER STATE. 

        IF VESSEL_TYPE = VESSEL_TYPE_SUPER_HEAVY_BOOSTER {         
            IF STATE { 
                ENGINE_MODULE:DOACTION("activate engine", TRUE).
            }
            ELSE { 
                ENGINE_MODULE:DOACTION("shutdown engine", TRUE).
            }
        }
        ELSE IF VESSEL_TYPE = VESSEL_TYPE_STARSHIP {
            THROW("Vessel type not supported.").
        }
        ELSE { 
            THROW("Vessel type not supported.").
        }
    }

    FUNCTION SET_ENGINE_MODE { 
        PARAMETER TARGET_MODE.

        IF VESSEL_TYPE = VESSEL_TYPE_SUPER_HEAVY_BOOSTER {             
            LOCAL CURR_MODE IS ENGINE_MODULE:GETFIELD("mode").            

            IF CURR_MODE = ENG_MODE_ALL AND TARGET_MODE = ENG_MODE_MID_INR {     
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            ELSE IF CURR_MODE = ENG_MODE_MID_INR AND TARGET_MODE = ENG_MODE_CTR {
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            ELSE IF CURR_MODE = ENG_MODE_CTR AND TARGET_MODE = ENG_MODE_MID_INR {
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_PREV).
            }
            ELSE IF CURR_MODE = ENG_MODE_MID_INR AND TARGET_MODE = ENG_MODE_ALL { 
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_PREV).
            }
        }
        ELSE IF VESSEL_TYPE = VESSEL_TYPE_FALCON_BOOSTER { 
            LOCAL CURR_MODE IS ENGINE_MODULE:GETFIELD("mode").       

            IF CURR_MODE = ENG_MODE_ALL AND TARGET_MODE = ENG_MODE_MID_INR {     
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            ELSE IF CURR_MODE = ENG_MODE_MID_INR AND TARGET_MODE = ENG_MODE_CTR {
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_NEXT).
            }
            ELSE IF CURR_MODE = ENG_MODE_CTR AND TARGET_MODE = ENG_MODE_MID_INR {
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_PREV).
            }
            ELSE IF CURR_MODE = ENG_MODE_MID_INR AND TARGET_MODE = ENG_MODE_ALL { 
                ENGINE_MODULE:DOEVENT(TUNDRA_ENGINE_SWITCH_PREV).
            }
        }
        ELSE {         
            THROW("Not implemented").
        }
    }

    RETURN LEXICON(         
        "SET_ENGINE_STATE", SET_ENGINE_STATE@,
        "SET_ENGINE_MODE", SET_ENGINE_MODE@
    ).
}