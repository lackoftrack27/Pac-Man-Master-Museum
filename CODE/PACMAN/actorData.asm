/*
------------------------------------------------
                ACTOR DATA
------------------------------------------------
*/
        ;XXYY
dirVectors:
    .DW $00FF   ; UP
    .DW $0100   ; LEFT
    .DW $0001   ; DOWN
    .DW $FF00   ; RIGHT

jrTileList:
    .DB $55 $56 $57 $58
playerTileList:
    .DB $59 $5A $5B $5C
playerTwoTileList:
    .DB $5D $5E $5F $60


/*
    POINTER TABLE FOR PLAYER TILE DEFS
*/
playerTileTblList:
    ; SMOOTH
    .DW pacSNTileTbl
    .DW pacSPTileTbl
    .DW msSNTileTbl
    .DW msSPTileTbl
    .DW jrSNTileTbl
    .DW jrSPTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoSNTileTbl
    .DW ottoSNTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    ; ARCADE
    .DW pacANTileTbl
    .DW pacAPTileTbl
    .DW msANTileTbl
    .DW msAPTileTbl
    .DW jrANTileTbl
    .DW jrAPTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoANTileTbl
    .DW ottoANTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID

/*
    POINTER TABLE FOR DEATH TILE DEFS
*/
deathTileTblList:
    ; SMOOTH
    .DW pacSNDeathTileTbl
    .DW pacSNDeathTileTbl
    .DW msSNDeathTileTbl
    .DW msSPDeathTileTbl
    .DW jrSNDeathTileTbl
    .DW jrSPDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoSNDeathTileTbl
    .DW ottoSNDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    ; ARCADE
    .DW pacANDeathTileTbl
    .DW pacANDeathTileTbl
    .DW msANDeathTileTbl
    .DW msAPDeathTileTbl
    .DW jrANDeathTileTbl
    .DW jrAPDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoANDeathTileTbl
    .DW ottoANDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID


/*
    POINTER TABLE FOR HUD TILE DEFS
*/
hudTileTblList:
    ; SMOOTH
    .DW pacSNTileTbl@hudPtr
    .DW pacSPTileTbl@hudPtr
    .DW msSNTileTbl@hudPtr
    .DW msSPTileTbl@hudPtr
    .DW jrSNTileTbl@hudPtr  ; UNUSED
    .DW jrSNTileTbl@hudPtr  ; UNUSED
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoSNTileTbl@hudPtr
    .DW ottoSNTileTbl@hudPtr
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    ; ARCADE
    .DW pacANTileTbl@hudPtr
    .DW pacAPTileTbl@hudPtr
    .DW msANTileTbl@hudPtr
    .DW msAPTileTbl@hudPtr
    .DW jrANTileTbl@hudPtr  ; UNUSED
    .DW jrANTileTbl@hudPtr  ; UNUSED
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoANTileTbl@hudPtr
    .DW ottoANTileTbl@hudPtr
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID