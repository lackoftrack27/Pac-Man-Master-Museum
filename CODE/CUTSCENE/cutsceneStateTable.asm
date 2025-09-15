.DEFINE     cutsceneSubState       workArea + 4
.DEFINE     nakedFrameCounter      workArea + 5


/*
---------------------------------------------------
        SUB STATE TABLE FOR CUTSCENE MODE
---------------------------------------------------
*/
sStateCutsceneTable:
    .DW @pacScene0      ; 00
    .DW @pacScene1      ; 01
    .DW @pacScene2      ; 02
    .DW $0000           ; 03
    .DW @msScene0       ; 04
    .DW @msScene1       ; 05
    .DW @msScene2       ; 06
    .DW $0000           ; 07
    
    .DW switchToGameplay           ; 07
    .DW switchToGameplay           ; 07
    .DW switchToGameplay           ; 07
    ;.DW @jrScene0       ; 08
    ;.DW @jrScene1       ; 09
    ;.DW @jrScene2       ; 0A


/*
----------------------------------------------
            CUTSCENE MODE CODE
----------------------------------------------
*/
.INCLUDE "pacScene0.asm"
.INCLUDE "pacScene1.asm"
.INCLUDE "pacScene2.asm"

.INCLUDE "msScene0.asm"
.INCLUDE "msScene1.asm"
.INCLUDE "msScene2.asm"

.INCLUDE "functions.asm"


.UNDEFINE     cutsceneSubState, nakedFrameCounter
