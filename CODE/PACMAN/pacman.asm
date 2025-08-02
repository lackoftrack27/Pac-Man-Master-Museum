/*
------------------------------------------------
            PAC-MAN STATE TABLE
------------------------------------------------
*/
pacStateTable:
@update:
    .dw @@normalMode    ; 00
    .dw @@superMode     ; 01
    .dw @@deadMode      ; 02
    ;.DW @@bigMode      ; 03
@draw:
    .dw @@normalMode    ; 00
    .dw @@superMode     ; 01
    .dw @@deadMode      ; 02
    .DW @@bigMode       ; 03




/*
------------------------------------------------
                PAC-MAN CODE
------------------------------------------------
*/
.INCLUDE "states.asm"
.INCLUDE "trans.asm"
.INCLUDE "functions.asm"


