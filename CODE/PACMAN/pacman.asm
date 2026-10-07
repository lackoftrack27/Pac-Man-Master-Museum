; ------------------------------------------------
;             PAC-MAN STATE TABLE
; ------------------------------------------------
pacStateTable:
@update:
    .dw PacNormal_U
    .dw PacSuper_U
    .dw PacDead_U
@draw:
    .dw PacNormal_D
    .dw PacSuper_D
    .dw PacDead_D
    .dw PacBig_D



; ------------------------------------------------
;                 PAC-MAN CODE
; ------------------------------------------------
.INCLUDE "states.asm"
.INCLUDE "trans.asm"
.INCLUDE "functions.asm"


