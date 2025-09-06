.DEFINE     lowestDist  workArea + 58
.DEFINE     idAddress   workArea + 60
.DEFINE     newDir      workArea + 62
.DEFINE     counter     workArea + 63


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
        .DW @@gotoExit     ; 05 --^
    @draw:
        .dw @@scatter      ; 00
        .dw @@gotoHome     ; 01
        .dw @@gotoCenter   ; 02
        .dw @@gotoRest     ; 03
        .dw @@rest         ; 04
        .DW @@gotoExit     ; 05



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