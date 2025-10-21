/*
----------------------------------------------
        DEFINES FOR GHOSTS (TEMP RAM)
----------------------------------------------
*/
;       PATHFINDING
.DEFINE     lowestDist      workArea + $3A   ; 2 BYTES
.DEFINE     idAddress       workArea + $3C   ; 2 BYTES
.DEFINE     newDir          workArea + $3E
.DEFINE     counter         workArea + $3F

;       CONSTANTS
.DEFINE     PATHFIND_TILES_PTR  pfWorkTiles - (_sizeof_actor - _sizeof_pfWorkTiles)


/*
------------------------------------------------
                GHOST STATE TABLE
------------------------------------------------
*/
ghostStateTable:
    @update:
        .dw @@scatter      ; 00 - ghostOutHomeUpdate
        .dw @@gotoHome     ; 01 --v
        .dw @@gotoCenter   ; 02 - ghostToHomeUpdate
        .dw @@gotoRest     ; 03 --^
        .dw @@rest         ; 04 - ghostHomeUpdate
        .dw @@gotoExit     ; 05 --^
    @draw:
        .dw @@scatter      ; 00
        .dw @@gotoHome     ; 01
        .dw @@gotoCenter   ; 02
        .dw @@gotoRest     ; 03
        .dw @@rest         ; 04
        .dw @@gotoExit     ; 05



/*
------------------------------------------------
                GHOST CODE
------------------------------------------------
*/
.INCLUDE "states.asm"
.INCLUDE "pathfind.asm"
.INCLUDE "trans.asm"
.INCLUDE "functions.asm"


.UNDEFINE     lowestDist, idAddress, newDir, counter    