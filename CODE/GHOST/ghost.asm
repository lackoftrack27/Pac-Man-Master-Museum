; ----------------------------------------------
;         DEFINES FOR GHOSTS (TEMP RAM)
; ----------------------------------------------

;       PATHFINDING
.DEFINE     lowestDist      workArea + $3A   ; 2 BYTES
.DEFINE     idAddress       workArea + $3C   ; 2 BYTES
.DEFINE     newDir          workArea + $3E
.DEFINE     counter         workArea + $3F

;       CONSTANTS
.DEFINE     PATHFIND_TILES_PTR  pfWorkTiles - (_sizeof_actor - _sizeof_pfWorkTiles)



; ------------------------------------------------
;                 GHOST STATE TABLE
; ------------------------------------------------

ghostStateTable:
@update:
    ; UPDATE ROUTINES
    .dw GhostScatter_U
    .dw GhostGotoHome_U
    .dw GhostGotoCenter_U
    .dw GhostGotoRest_U
    .dw GhostRest_U
    .dw GhostGotoExit_U
@draw:
    ; DRAW ROUTINES
    .dw GhostScatter_D
    .dw GhostGotoHome_D
    .dw GhostGotoCenter_D
    .dw GhostGotoRest_D
    .dw GhostRest_D
    .dw GhostGotoExit_D


; ------------------------------------------------
;                 GHOST CODE
; ------------------------------------------------

.INCLUDE "states.asm"
.INCLUDE "pathfind.asm"
.INCLUDE "trans.asm"
.INCLUDE "functions.asm"


.UNDEFINE     lowestDist, idAddress, newDir, counter    