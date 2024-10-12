// WAIT UNTIL SHIP:UNPACKED.
// DELETEPATH("common").
// DELETEPATH("uipanels").
// SWITCH TO 0. 
// COPYPATH("common", "1:").
// COPYPATH("uipanels", "1:uipanels").
// SWITCH TO 1.
// CD("uipanels").
// RUNPATH("home").

WAIT UNTIL SHIP:UNPACKED.
RUNONCEPATH("0:/common/booting/commonboot", "uipanels", "home").

