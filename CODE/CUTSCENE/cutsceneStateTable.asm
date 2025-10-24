/*
----------------------------------------------
        DEFINES FOR CUTSCENE MODE (TEMP RAM)
----------------------------------------------
*/
;       PAC-MAN
.DEFINE     cutsceneSubState        workArea
.DEFINE     nakedFrameCounter       workArea + $01
;       MS.PAC/JR.PAC
.DEFINE     msCut_MainTileTblPtr    workArea + $00  ; 2 BYTES
.DEFINE     msCut_SubTileTblPtr     workArea + $02  ; 2 BYTES
.DEFINE     msCut_GhostTileTblPtr   workArea + $04  ; 2 BYTES
.DEFINE     jrCut_JrTileTblPtr      workArea + $06  ; 2 BYTES
.DEFINE     jrCutsceneVarFB         workArea + $08  ; 2 BYTES
.DEFINE     jrCut_OverrideFlags     workArea + $09  ; 8 BYTES
.DEFINE     jrCutScreenFlagList     workArea + $11  ; 8 BYTES
.DEFINE     jrSwingCounter          workArea + $1A



/*
---------------------------------------------------
        SUB STATE TABLE FOR CUTSCENE MODE
---------------------------------------------------
*/
sStateCutsceneTable:
    .DW @pacScene0      ; 00
    .DW @pacScene1      ; 01
    .DW @pacScene2      ; 02
    .DW switchToGameplay; 03
    .DW @msScene0       ; 04
    .DW @msScene1       ; 05
    .DW @msScene2       ; 06
    .DW switchToGameplay; 07
    .DW @jrScene0       ; 08
    .DW @jrScene1       ; 09
    .DW @jrScene2       ; 0A


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

.INCLUDE "jrScene0.asm"
.INCLUDE "jrScene1.asm"
.INCLUDE "jrScene2.asm"

.INCLUDE "functions.asm"


.UNDEFINE     cutsceneSubState, nakedFrameCounter
