@LAZYGLOBAL OFF.

LOCAL DEFAULT_LOG_FILENAME TO "0:output/out" + TIME:MINUTE + "" + TIME:SECOND + ".txt".

GLOBAL FUNCTION DESCRIBE_PART_ITEM {
    PARAMETER PART.

    FOR MODULE_NAME IN PART:ALLMODULES { 
        PRINT "Module name: " + MODULE_NAME.
        DECLARE LOCAL MODULE TO PART:GETMODULE(MODULE_NAME).
        FOR FIELD_NAME IN MODULE:ALLFIELDNAMES {
            PRINT "    Field: " + FIELD_NAME.
        }
        FOR ACTION_NAME IN MODULE:ALLACTIONNAMES { 
            PRINT "    Action: " + ACTION_NAME.
        }
        FOR EVENT_NAME IN MODULE:ALLEVENTNAMES { 
            PRINT "    Event: " + EVENT_NAME.
        }
    }

}

GLOBAL FUNCTION DESCRIBE_PART_ITEM_TO_FILE {
    PARAMETER PART.
    PARAMETER FILENAME IS DEFAULT_LOG_FILENAME.

    FOR MODULE_NAME IN PART:ALLMODULES { 
        LOG "Module name: " + MODULE_NAME TO FILENAME.
        DECLARE LOCAL MODULE TO PART:GETMODULE(MODULE_NAME).

        FOR fieldName IN MODULE:ALLFIELDNAMES {
            LOG "    Field: " + fieldName + " " + MODULE:GETFIELD(fieldName) TO FILENAME.
        }
        FOR ACTION_NAME IN MODULE:ALLACTIONNAMES { 
            LOG "    Action: " + ACTION_NAME TO FILENAME.
        }
        FOR EVENT_NAME IN MODULE:ALLEVENTNAMES { 
            LOG  "    Event: " + EVENT_NAME TO FILENAME.
        }
    }
}

GLOBAL FUNCTION DESCRIBE_MODULE_TO_FILE { 
    PARAMETER MODULE.
    PARAMETER FILENAME IS DEFAULT_LOG_FILENAME. 

    FOR FIELD_NAME IN MODULE:ALLFIELDNAMES { 
        LOCAL FIELD TO MODULE:GETFIELD(FIELD_NAME).
        LOG "    Field: " + FIELD_NAME TO FILENAME.
        LOG "       Value: "  TO FILENAME.
        LOG "   Suffix names: " TO FILENAME.    
        FOR SUFFIX_NAME IN FIELD:SUFFIXNAMES { 
            LOG "       Suffix: " + SUFFIX_NAME to FILENAME.
        }
    }    
}

GLOBAL FUNCTION DESCRIBE_SUFFIXNAMES_TO_FILE { 
    PARAMETER THING.
    PARAMETER FILENAME IS DEFAULT_LOG_FILENAME.

    FOR SN IN THING:SUFFIXNAMES {
        LOG SN TO FILENAME.
    }
}

