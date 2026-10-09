
; ----------------------------------------------
;         DEFINES FOR CUTSCENE MODE (TEMP RAM)
; ----------------------------------------------

;       PAC-MAN
.DEFINE     cutsceneSubState        workArea
.DEFINE     nakedFrameCounter       workArea + $01
.DEFINE     plusGhostSprBuffer      workArea + $02  ; $40 BYTES
;       MS.PAC/JR.PAC
.DEFINE     msCut_MainTileTblPtr    workArea + $00  ; 2 BYTES
.DEFINE     msCut_SubTileTblPtr     workArea + $02  ; 2 BYTES
.DEFINE     msCut_GhostTileTblPtr   workArea + $04  ; 2 BYTES
.DEFINE     jrCut_JrTileTblPtr      workArea + $06  ; 2 BYTES
.DEFINE     jrCutsceneVarFB         workArea + $08
.DEFINE     jrSwingCounter          workArea + $09
.DEFINE     jrCut_OverrideFlags     workArea + $0A  ; 7 BYTES
.DEFINE     jrCutScreenFlagList     jrCut_OverrideFlags + PROG_AMOUNT   ; 7 BYTES




; ---------------------------------------------------
;         SUB STATE TABLE FOR CUTSCENE MODE
; ---------------------------------------------------

sStateCutsceneTable:
    .DW PacScene0       ; 00
    .DW PacScene1       ; 01
    .DW PacScene2       ; 02
    .DW switchToGameplay; 03
    .DW MsScene0        ; 04
    .DW MsScene1        ; 05
    .DW MsScene2        ; 06
    .DW switchToGameplay; 07
    .DW JrScene0        ; 08
    .DW JrScene1        ; 09
    .DW JrScene2        ; 0A



; ----------------------------------------------
;             CUTSCENE MODE CODE
; ----------------------------------------------

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


.UNDEFINE   cutsceneSubState, nakedFrameCounter, plusGhostSprBuffer
.UNDEFINE   msCut_MainTileTblPtr, msCut_SubTileTblPtr, msCut_GhostTileTblPtr
.UNDEFINE   jrCut_JrTileTblPtr, jrCutsceneVarFB, jrCut_OverrideFlags, jrCutScreenFlagList