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
    .DW msSNTileTbl
    .DW jrSNTileTbl
    .DW jrSNTileTbl
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
    .DW msANTileTbl
    .DW jrANTileTbl
    .DW jrANTileTbl
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
    .DW msSNDeathTileTbl
    .DW pacSNDeathTileTbl;jrSNDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoSNDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    ; ARCADE
    .DW pacANDeathTileTbl
    .DW msANDeathTileTbl
    .DW jrANDeathTileTbl
    .DW $0000   ; INVALID
    .DW $0000   ; INVALID
    .DW ottoANDeathTileTbl
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
    .DW msSNTileTbl@hudPtr
    .DW jrSNTileTbl@hudPtr
    .DW jrSNTileTbl@hudPtr
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
    .DW msANTileTbl@hudPtr
    .DW jrANTileTbl@hudPtr
    .DW jrANTileTbl@hudPtr
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

/*
------------------------------------------------
                PAC-MAN DATA
------------------------------------------------
*/
pacSNTileTbl:
;   UP
@up:
    .DW pacTileS08 pacTileS12 pacTileS03 pacTileS13 ; HALF
    .DW pacTileS00 pacTileS12 pacTileS01 pacTileS13 ; OPEN
    .DW pacTileS08 pacTileS12 pacTileS03 pacTileS13 ; HALF
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED
;   LEFT
@left:
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED
@hudPtr:
    .DW pacTileS09 pacTileS12 pacTileS03 pacTileS13 ; HALF
    .DW pacTileS02 pacTileS14 pacTileS03 pacTileS13 ; OPEN
    .DW pacTileS09 pacTileS12 pacTileS03 pacTileS13 ; HALF
;   DOWN
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED
    .DW pacTileS0A pacTileS16 pacTileS03 pacTileS13 ; HALF
    .DW pacTileS04 pacTileS07 pacTileS05 pacTileS07 ; OPEN
    .DW pacTileS0A pacTileS16 pacTileS03 pacTileS13 ; HALF
;   RIGHT
@titlePtr:
    .DW pacTileS0B pacTileS12 pacTileS0C pacTileS13 ; HALF
    .DW pacTileS06 pacTileS15 pacTileS07 pacTileS07 ; OPEN
    .DW pacTileS0B pacTileS12 pacTileS0C pacTileS13 ; HALF
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED


pacSPTileTbl:
;   UP
    .DW pacTileS0E pacTileS12 pacTileS03 pacTileS13 ; HALF PLUS
    .DW pacTileS00 pacTileS12 pacTileS01 pacTileS13 ; OPEN
    .DW pacTileS0E pacTileS12 pacTileS03 pacTileS13 ; HALF PLUS
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED
;   LEFT
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED
@hudPtr:
    .DW pacTileS0F pacTileS12 pacTileS03 pacTileS13 ; HALF PLUS
    .DW pacTileS02 pacTileS14 pacTileS03 pacTileS13 ; OPEN
    .DW pacTileS0F pacTileS12 pacTileS03 pacTileS13 ; HALF PLUS
;   DOWN
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED
    .DW pacTileS10 pacTileS16 pacTileS03 pacTileS13 ; HALF PLUS
    .DW pacTileS04 pacTileS07 pacTileS05 pacTileS07 ; OPEN
    .DW pacTileS10 pacTileS16 pacTileS03 pacTileS13 ; HALF PLUS
;   RIGHT
    .DW pacTileS11 pacTileS12 pacTileS0C pacTileS13 ; HALF PLUS
    .DW pacTileS06 pacTileS15 pacTileS07 pacTileS07 ; OPEN
    .DW pacTileS11 pacTileS12 pacTileS0C pacTileS13 ; HALF PLUS
    .DW pacTileS0D pacTileS12 pacTileS03 pacTileS13 ; CLOSED


pacANTileTbl:
;   UP
@up:
    .DW pacTileA08 pacTileA17 pacTileA09 pacTileA18 ; HALF
    .DW pacTileA00 pacTileA17 pacTileA01 pacTileA18 ; OPEN
    .DW pacTileA08 pacTileA17 pacTileA09 pacTileA18 ; HALF
    .DW pacTileA0F pacTileA17 pacTileA09 pacTileA18 ; CLOSED
;   LEFT
@left:
    .DW pacTileA10 pacTileA1C pacTileA03 pacTileA1A ; CLOSED
@hudPtr:
    .DW pacTileA0A pacTileA1C pacTileA03 pacTileA1A ; HALF
    .DW pacTileA02 pacTileA19 pacTileA03 pacTileA1A ; OPEN
    .DW pacTileA0A pacTileA1C pacTileA03 pacTileA1A ; HALF
;   DOWN
    .DW pacTileA11 pacTileA1F pacTileA0C pacTileA1E ; CLOSED
    .DW pacTileA0B pacTileA1D pacTileA0C pacTileA1E ; HALF
    .DW pacTileA04 pacTileA07 pacTileA05 pacTileA07 ; OPEN
    .DW pacTileA0B pacTileA1D pacTileA0C pacTileA1E ; HALF
;   RIGHT
@titlePtr:
    .DW pacTileA0D pacTileA1F pacTileA0E pacTileA1E ; HALF
    .DW pacTileA06 pacTileA1B pacTileA07 pacTileA07 ; OPEN
    .DW pacTileA0D pacTileA1F pacTileA0E pacTileA1E ; HALF
    .DW pacTileA11 pacTileA1F pacTileA0C pacTileA1E ; CLOSED


pacAPTileTbl:
;   UP
    .DW pacTileA12 pacTileA17 pacTileA09 pacTileA18 ; HALF PLUS
    .DW pacTileA00 pacTileA17 pacTileA01 pacTileA18 ; OPEN
    .DW pacTileA12 pacTileA17 pacTileA09 pacTileA18 ; HALF PLUS
    .DW pacTileA0F pacTileA17 pacTileA09 pacTileA18 ; CLOSED
;   LEFT
    .DW pacTileA10 pacTileA1C pacTileA03 pacTileA1A ; CLOSED
@hudPtr:
    .DW pacTileA13 pacTileA1C pacTileA03 pacTileA1A ; HALF PLUS
    .DW pacTileA02 pacTileA19 pacTileA03 pacTileA1A ; OPEN
    .DW pacTileA13 pacTileA1C pacTileA03 pacTileA1A ; HALF PLUS
;   DOWN
    .DW pacTileA11 pacTileA1F pacTileA0C pacTileA1E ; CLOSED
    .DW pacTileA14 pacTileA20 pacTileA0C pacTileA1E ; HALF PLUS
    .DW pacTileA04 pacTileA07 pacTileA05 pacTileA07 ; OPEN
    .DW pacTileA14 pacTileA20 pacTileA0C pacTileA1E ; HALF PLUS
;   RIGHT
    .DW pacTileA15 pacTileA1F pacTileA16 pacTileA1E ; HALF PLUS
    .DW pacTileA06 pacTileA1B pacTileA07 pacTileA07 ; OPEN
    .DW pacTileA15 pacTileA1F pacTileA16 pacTileA1E ; HALF PLUS
    .DW pacTileA11 pacTileA1F pacTileA0C pacTileA1E ; CLOSED



pacSNDeathTileTbl:
    .DW pacDTileS00 pacDTileS14 pacDTileS01 pacDTileS0F
    .DW pacDTileS02 pacDTileS15 pacDTileS03 pacDTileS16
    .DW pacDTileS04 pacDTileS17 pacDTileS05 pacDTileS18
    .DW pacDTileS06 pacDTileS17 pacDTileS07 pacDTileS18

    .DW pacDTileS08 pacDTileS19 pacDTileS09 pacDTileS1A
    .DW pacDTileS0A pacDTileS1B pacDTileS0B pacDTileS1C
    .DW pacDTileS0C pacDTileS1D pacDTileS0D pacDTileS1E
    .DW pacDTileS0E pacDTileS1F pacDTileS0F pacDTileS20

    .DW pacDTileS10 pacDTileS21 pacDTileS0F pacDTileS22
    .DW pacDTileS11 pacDTileS23 pacDTileS0F pacDTileS0F
    .DW pacDTileS12 pacDTileS24 pacDTileS13 pacDTileS25
    .DW pacDTileS0F pacDTileS0F pacDTileS0F pacDTileS0F


pacANDeathTileTbl:
    .DW pacDTileA00 pacDTileA13 pacDTileA01 pacDTileA0F
    .DW pacDTileA02 pacDTileA14 pacDTileA03 pacDTileA15
    .DW pacDTileA04 pacDTileA14 pacDTileA05 pacDTileA15
    .DW pacDTileA06 pacDTileA16 pacDTileA07 pacDTileA17

    .DW pacDTileA08 pacDTileA18 pacDTileA09 pacDTileA19
    .DW pacDTileA0A pacDTileA1A pacDTileA0B pacDTileA1B
    .DW pacDTileA0C pacDTileA1C pacDTileA0D pacDTileA1D
    .DW pacDTileA0E pacDTileA1E pacDTileA0F pacDTileA1F

    .DW pacDTileA10 pacDTileA20 pacDTileA0F pacDTileA21
    .DW pacDTileA10 pacDTileA22 pacDTileA0F pacDTileA0F
    .DW pacDTileA11 pacDTileA23 pacDTileA12 pacDTileA24
    .DW pacDTileA0F pacDTileA0F pacDTileA0F pacDTileA0F



;   FRAMES TIMES
pacmanDeathTimes:
    .DB $1E $08 $07 $08 $07 $08 $07 $08 $07 $08 $0F $55

jrDeathTimes:
    .DB $1E $08 $07 $08 $07 $08 $07 $08 $07 $08 $07 $5D


/*
    MACRO AND LIST FOR PAC-MAN TILES [BIG - CUTSCENE 1]
*/
.MACRO pacBigSprDefs ARGS, VAL
@open:
    .DB VAL, VAL+$06, VAL+$0C, VAL+$01, VAL+$07, VAL+$0D, VAL+$02, BLANK_TILE, VAL+$0E
@half:
    .DB VAL, VAL+$06, VAL+$0C, VAL+$03, VAL+$08, VAL+$0F, VAL+$04, VAL+$09, VAL+$10
@closed:
    .DB VAL, VAL+$06, VAL+$0C, VAL+$03, VAL+$0A, VAL+$0F, VAL+$05, VAL+$0B, VAL+$11
.ENDM

pacBigTileDefs:
    pacBigSprDefs (SPRITE_ADDR + PAC_CUT_VRAM) / TILE_SIZE

pacBigSpriteTable:
;   00 - 03
    .DW pacBigTileDefs@half     ; 00
;   04 - 07
    .DW pacBigTileDefs@open     ; 02
;   08 - 0B
    .DW pacBigTileDefs@half     ; 04
;   0C - 0F
    .DW pacBigTileDefs@closed   ; 06



/*
-----------------------------------------------
                MS. PAC-MAN
-----------------------------------------------
*/



;   MS.PAC-MAN [SMOOTH] TILE TABLE
msSNTileTbl:
;   UP
@up:
    .DW msTileS00 msTileS16 msTileS01 msTileS17 ; OPEN
    .DW msTileS08 msTileS16 msTileS09 msTileS17 ; HALF
    .DW msTileS0F msTileS16 msTileS10 msTileS17 ; CLOSED
    .DW msTileS08 msTileS16 msTileS09 msTileS17 ; HALF
;   LEFT
@left:
    .DW msTileS0A msTileS1D msTileS03 msTileS17 ; HALF
    .DW msTileS11 msTileS20 msTileS03 msTileS17 ; CLOSED
    .DW msTileS0A msTileS1D msTileS03 msTileS17 ; HALF
    .DW msTileS02 msTileS18 msTileS03 msTileS17 ; OPEN 
;   DOWN
    .DW msTileS0B msTileS1E msTileS0C msTileS1F ; HALF
    .DW msTileS12 msTileS22 msTileS13 msTileS17 ; CLOSED
    .DW msTileS0B msTileS1E msTileS0C msTileS1F ; HALF
    .DW msTileS04 msTileS19 msTileS05 msTileS1A ; OPEN
;   RIGHT
@titlePtr:
    .DW msTileS06 msTileS1B msTileS07 msTileS1C ; OPEN
@hudPtr:
    .DW msTileS0D msTileS20 msTileS0E msTileS21 ; HALF
    .DW msTileS14 msTileS20 msTileS15 msTileS17 ; CLOSED
    .DW msTileS0D msTileS20 msTileS0E msTileS21 ; HALF


;   MS.PAC-MAN [ARCADE] TILE TABLE
msANTileTbl:
;   UP
@up:
    .DW msTileA00 msTileA15 msTileA01 msTileA16 ; OPEN
    .DW msTileA08 msTileA15 msTileA09 msTileA16 ; HALF
    .DW msTileA0F msTileA15 msTileA10 msTileA16 ; CLOSED
    .DW msTileA08 msTileA15 msTileA09 msTileA16 ; HALF
;   LEFT
@left:
    .DW msTileA0A msTileA1D msTileA03 msTileA18 ; HALF
    .DW msTileA11 msTileA21 msTileA03 msTileA18 ; CLOSED
    .DW msTileA0A msTileA1D msTileA03 msTileA18 ; HALF
    .DW msTileA02 msTileA17 msTileA03 msTileA18 ; OPEN
;   DOWN
    .DW msTileA0B msTileA1E msTileA0C msTileA18 ; HALF
    .DW msTileA12 msTileA22 msTileA03 msTileA18 ; CLOSED
    .DW msTileA0B msTileA1E msTileA0C msTileA18 ; HALF
    .DW msTileA04 msTileA19 msTileA05 msTileA1A ; OPEN
;   RIGHT
@titlePtr:
    .DW msTileA06 msTileA1B msTileA07 msTileA1C ; OPEN
@hudPtr:
    .DW msTileA0D msTileA1F msTileA0E msTileA20 ; HALF
    .DW msTileA13 msTileA1F msTileA14 msTileA23 ; CLOSED
    .DW msTileA0D msTileA1F msTileA0E msTileA20 ; HALF


;   MS.PAC-MAN DEATH [SMOOTH] TILE TABLE
msSNDeathTileTbl:
    .DW msTileS0B msTileS1E msTileS0C msTileS1F ; DOWN HALF
    .DW msTileS0A msTileS1D msTileS03 msTileS17 ; LEFT HALF
    .DW msTileS08 msTileS16 msTileS09 msTileS17 ; UP HALF
    .DW msTileS0D msTileS20 msTileS0E msTileS21 ; RIGHT HALF

    .DW msTileS0B msTileS1E msTileS0C msTileS1F ; DOWN HALF
    .DW msTileS0A msTileS1D msTileS03 msTileS17 ; LEFT HALF
    .DW msTileS08 msTileS16 msTileS09 msTileS17 ; UP HALF
    .DW msTileS0D msTileS20 msTileS0E msTileS21 ; RIGHT HALF

    .DW msTileS0B msTileS1E msTileS0C msTileS1F ; DOWN HALF
    .DW msTileS0A msTileS1D msTileS03 msTileS17 ; LEFT HALF
    .DW msTileS08 msTileS16 msTileS09 msTileS17 ; UP HALF
    .DW msTileS08 msTileS16 msTileS09 msTileS17 ; UP HALF


;   MS.PAC-MAN DEATH [ARCADE] TILE TABLE
msANDeathTileTbl:
    .DW msTileA0B msTileA1E msTileA0C msTileA18 ; DOWN HALF
    .DW msTileA0A msTileA1D msTileA03 msTileA18 ; LEFT HALF
    .DW msTileA08 msTileA15 msTileA09 msTileA16 ; UP HALF
    .DW msTileA0D msTileA1F msTileA0E msTileA20 ; RIGHT HALF

    .DW msTileA0B msTileA1E msTileA0C msTileA18 ; DOWN HALF
    .DW msTileA0A msTileA1D msTileA03 msTileA18 ; LEFT HALF
    .DW msTileA08 msTileA15 msTileA09 msTileA16 ; UP HALF
    .DW msTileA0D msTileA1F msTileA0E msTileA20 ; RIGHT HALF

    .DW msTileA0B msTileA1E msTileA0C msTileA18 ; DOWN HALF
    .DW msTileA0A msTileA1D msTileA03 msTileA18 ; LEFT HALF
    .DW msTileA08 msTileA15 msTileA09 msTileA16 ; UP HALF
    .DW msTileA08 msTileA15 msTileA09 msTileA16 ; UP HALF


/*
-----------------------------------------------
                CRAZY OTTO
-----------------------------------------------
*/


ottoSNTileTbl:
;   UP
@up:
    .DW ottoTileS00 ottoTileS1B ottoTileS01 ottoTileS1C ; OPEN
    .DW ottoTileS08 ottoTileS21 ottoTileS01 ottoTileS1C ; HALF 0
    .DW ottoTileS00 ottoTileS26 ottoTileS0E ottoTileS27 ; CLOSED
    .DW ottoTileS00 ottoTileS2C ottoTileS0E ottoTileS27 ; HALF 1
;   LEFT
@left:
    .DW ottoTileS15 ottoTileS2D ottoTileS16 ottoTileS2E ; HALF 1
    .DW ottoTileS0F ottoTileS28 ottoTileS10 ottoTileS29 ; CLOSED
    .DW ottoTileS09 ottoTileS22 ottoTileS0A ottoTileS23 ; HALF 0
    .DW ottoTileS02 ottoTileS1D ottoTileS03 ottoTileS1E ; OPEN
;   DOWN
    .DW ottoTileS17 ottoTileS2C ottoTileS12 ottoTileS27 ; HALF 1
    .DW ottoTileS11 ottoTileS26 ottoTileS12 ottoTileS27 ; CLOSED
    .DW ottoTileS0B ottoTileS21 ottoTileS05 ottoTileS1C ; HALF 0
    .DW ottoTileS04 ottoTileS1B ottoTileS05 ottoTileS1C ; OPEN
;   RIGHT
@titlePtr:
    .DW ottoTileS06 ottoTileS1F ottoTileS07 ottoTileS20 ; OPEN
    .DW ottoTileS0C ottoTileS24 ottoTileS0D ottoTileS25 ; HALF 0
    .DW ottoTileS13 ottoTileS2A ottoTileS14 ottoTileS2B ; CLOSED
@hudPtr:
    .DW ottoTileS18 ottoTileS2F ottoTileS0D ottoTileS30 ; HALF 1
    
    
ottoANTileTbl:
;   UP
@up:
    .DW ottoTileA00 ottoTileA1C ottoTileA01 ottoTileA1D ; OPEN
    .DW ottoTileA08 ottoTileA22 ottoTileA01 ottoTileA1D ; HALF 0
    .DW ottoTileA00 ottoTileA27 ottoTileA0E ottoTileA28 ; CLOSED
    .DW ottoTileA00 ottoTileA2C ottoTileA0E ottoTileA28 ; HALF 1
;   LEFT
@left:
    .DW ottoTileA15 ottoTileA2D ottoTileA16 ottoTileA2E ; HALF 1
    .DW ottoTileA0F ottoTileA29 ottoTileA10 ottoTileA2A ; CLOSED
    .DW ottoTileA09 ottoTileA23 ottoTileA0A ottoTileA24 ; HALF 0
    .DW ottoTileA02 ottoTileA1E ottoTileA03 ottoTileA1F ; OPEN
;   DOWN
    .DW ottoTileA17 ottoTileA2C ottoTileA12 ottoTileA28 ; HALF 1
    .DW ottoTileA11 ottoTileA27 ottoTileA12 ottoTileA28 ; CLOSED
    .DW ottoTileA0B ottoTileA22 ottoTileA05 ottoTileA1D ; HALF 0
    .DW ottoTileA04 ottoTileA1C ottoTileA05 ottoTileA1D ; OPEN
;   RIGHT
@titlePtr:
    .DW ottoTileA06 ottoTileA20 ottoTileA07 ottoTileA21 ; OPEN
    .DW ottoTileA0C ottoTileA25 ottoTileA0D ottoTileA26 ; HALF 0
    .DW ottoTileA13 ottoTileA2B ottoTileA14 ottoTileA1D ; CLOSED
@hudPtr:
    .DW ottoTileA18 ottoTileA2F ottoTileA19 ottoTileA30 ; HALF 1




ottoSNDeathTileTbl:
    .DW ottoTileS00 ottoTileS2C ottoTileS0E ottoTileS27 ; UP HALF 1
    .DW ottoTileS18 ottoTileS2F ottoTileS0D ottoTileS30 ; RIGHT HALF 1
    .DW ottoTileS17 ottoTileS2C ottoTileS12 ottoTileS27 ; DOWN HALF 1
    .DW ottoTileS15 ottoTileS2D ottoTileS16 ottoTileS2E ; LEFT HALF 1

    .DW ottoTileS00 ottoTileS2C ottoTileS0E ottoTileS27 ; UP HALF 1
    .DW ottoTileS18 ottoTileS2F ottoTileS0D ottoTileS30 ; RIGHT HALF 1
    .DW ottoTileS17 ottoTileS2C ottoTileS12 ottoTileS27 ; DOWN HALF 1
    .DW ottoTileS15 ottoTileS2D ottoTileS16 ottoTileS2E ; LEFT HALF 1

    .DW ottoTileS00 ottoTileS2C ottoTileS0E ottoTileS27 ; UP HALF 1
    .DW ottoTileS18 ottoTileS2F ottoTileS0D ottoTileS30 ; RIGHT HALF 1
    .DW ottoTileS17 ottoTileS2C ottoTileS12 ottoTileS27 ; DOWN HALF 1
    .DW ottoTileS19 ottoTileS31 ottoTileS1A ottoTileS32 ; DEATH


ottoANDeathTileTbl:
    .DW ottoTileA00 ottoTileA2C ottoTileA0E ottoTileA28 ; UP HALF 1
    .DW ottoTileA18 ottoTileA2F ottoTileA19 ottoTileA30 ; RIGHT HALF 1
    .DW ottoTileA17 ottoTileA2C ottoTileA12 ottoTileA28 ; DOWN HALF 1
    .DW ottoTileA15 ottoTileA2D ottoTileA16 ottoTileA2E ; LEFT HALF 1

    .DW ottoTileA00 ottoTileA2C ottoTileA0E ottoTileA28 ; UP HALF 1
    .DW ottoTileA18 ottoTileA2F ottoTileA19 ottoTileA30 ; RIGHT HALF 1
    .DW ottoTileA17 ottoTileA2C ottoTileA12 ottoTileA28 ; DOWN HALF 1
    .DW ottoTileA15 ottoTileA2D ottoTileA16 ottoTileA2E ; LEFT HALF 1

    .DW ottoTileA00 ottoTileA2C ottoTileA0E ottoTileA28 ; UP HALF 1
    .DW ottoTileA18 ottoTileA2F ottoTileA19 ottoTileA30 ; RIGHT HALF 1
    .DW ottoTileA17 ottoTileA2C ottoTileA12 ottoTileA28 ; DOWN HALF 1
    .DW ottoTileA1A ottoTileA31 ottoTileA1B ottoTileA32 ; DEATH
    
    

annaSNTileTbl:
@up:
    .DW annaTileS00 annaTileS14 annaTileS01 annaTileS15 ; OPEN
    .DW annaTileS06 annaTileS1A annaTileS01 annaTileS15 ; HALF 0
    .DW annaTileS00 annaTileS1E annaTileS0B annaTileS1F ; CLOSED
    .DW annaTileS00 annaTileS24 annaTileS0B annaTileS1F ; HALF 1
@left:
    .DW annaTileS10 annaTileS25 annaTileS11 annaTileS26 ; HALF 1
    .DW annaTileS0C annaTileS20 annaTileS0D annaTileS21 ; CLOSED
    .DW annaTileS07 annaTileS1B annaTileS08 annaTileS13 ; HALF 0
    .DW annaTileS02 annaTileS16 annaTileS03 annaTileS17 ; OPEN
@right:
    .DW annaTileS04 annaTileS18 annaTileS05 annaTileS19 ; OPEN
    .DW annaTileS09 annaTileS1C annaTileS0A annaTileS1D ; HALF 0
    .DW annaTileS0E annaTileS22 annaTileS0F annaTileS23 ; CLOSED
    .DW annaTileS12 annaTileS27 annaTileS0A annaTileS28 ; HALF 1


annaANTileTbl:
@up:
    .DW annaTileA00 annaTileA15 annaTileA01 annaTileA16 ; OPEN
    .DW annaTileA06 annaTileA1B annaTileA01 annaTileA16 ; HALF 0
    .DW annaTileA00 annaTileA1F annaTileA0B annaTileA20 ; CLOSED
    .DW annaTileA00 annaTileA24 annaTileA0B annaTileA20 ; HALF 1
@left:
    .DW annaTileA10 annaTileA25 annaTileA11 annaTileA26 ; HALF 1
    .DW annaTileA0C annaTileA21 annaTileA0D annaTileA22 ; CLOSED
    .DW annaTileA07 annaTileA1C annaTileA08 annaTileA14 ; HALF 0
    .DW annaTileA02 annaTileA17 annaTileA03 annaTileA18 ; OPEN
@right:
    .DW annaTileA04 annaTileA19 annaTileA05 annaTileA1A ; OPEN
    .DW annaTileA09 annaTileA1D annaTileA0A annaTileA1E ; HALF 0
    .DW annaTileA0E annaTileA23 annaTileA0F annaTileA16 ; CLOSED
    .DW annaTileA12 annaTileA27 annaTileA13 annaTileA28 ; HALF 1



/*
-----------------------------------------------
                JR. PAC-MAN
-----------------------------------------------
*/


jrSNTileTbl:
;   UP
@up:
    .DW jrTileS00 jrTileS16 jrTileS01 jrTileS17 ; OPEN
    .DW jrTileS07 jrTileS16 jrTileS08 jrTileS1E ; HALF
    .DW jrTileS0E jrTileS23 jrTileS0F jrTileS24 ; CLOSED
    .DW jrTileS07 jrTileS16 jrTileS08 jrTileS1E ; HALF
;   LEFT
@left:
    .DW jrTileS09 jrTileS1F jrTileS0A jrTileS19 ; HALF
    .DW jrTileS10 jrTileS25 jrTileS11 jrTileS19 ; CLOSED
    .DW jrTileS09 jrTileS1F jrTileS0A jrTileS19 ; HALF
    .DW jrTileS02 jrTileS18 jrTileS03 jrTileS19 ; OPEN 
;   DOWN
@down:
    .DW jrTileS0B jrTileS20 jrTileS0A jrTileS19 ; HALF
    .DW jrTileS12 jrTileS25 jrTileS13 jrTileS19 ; CLOSED
    .DW jrTileS0B jrTileS20 jrTileS0A jrTileS19 ; HALF
    .DW jrTileS04 jrTileS1A jrTileS03 jrTileS1B ; OPEN
;   RIGHT
@right:
@titlePtr:
    .DW jrTileS05 jrTileS1C jrTileS06 jrTileS1D ; OPEN
@hudPtr:
    .DW jrTileS0C jrTileS21 jrTileS0D jrTileS22 ; HALF
    .DW jrTileS14 jrTileS21 jrTileS15 jrTileS26 ; CLOSED
    .DW jrTileS0C jrTileS21 jrTileS0D jrTileS22 ; HALF

jrANTileTbl:
;   UP
@up:
    .DW jrTileA00 jrTileA13 jrTileA01 jrTileA14 ; OPEN
    .DW jrTileA07 jrTileA13 jrTileA08 jrTileA1B ; HALF
    .DW jrTileA0D jrTileA13 jrTileA08 jrTileA1F ; CLOSED
    .DW jrTileA07 jrTileA13 jrTileA08 jrTileA1B ; HALF
;   LEFT
@left:
    .DW jrTileA09 jrTileA1C jrTileA0A jrTileA16 ; HALF
    .DW jrTileA0E jrTileA20 jrTileA0F jrTileA16 ; CLOSED
    .DW jrTileA09 jrTileA1C jrTileA0A jrTileA16 ; HALF
    .DW jrTileA02 jrTileA15 jrTileA03 jrTileA16 ; OPEN 
;   DOWN
@down:
    .DW jrTileA04 jrTileA1D jrTileA0A jrTileA16 ; HALF
    .DW jrTileA04 jrTileA21 jrTileA10 jrTileA16 ; CLOSED
    .DW jrTileA04 jrTileA1D jrTileA0A jrTileA16 ; HALF
    .DW jrTileA04 jrTileA17 jrTileA03 jrTileA18 ; OPEN
;   RIGHT
@right:
@titlePtr:
    .DW jrTileA05 jrTileA19 jrTileA06 jrTileA1A ; OPEN
@hudPtr:
    .DW jrTileA0B jrTileA19 jrTileA0C jrTileA1E ; HALF
    .DW jrTileA11 jrTileA19 jrTileA12 jrTileA22 ; CLOSED
    .DW jrTileA0B jrTileA19 jrTileA0C jrTileA1E ; HALF

jrSNDeathTileTbl:


jrANDeathTileTbl:
    .DW jrDTileA00 jrDTileA11 jrDTileA01 jrDTileA12
    .DW jrDTileA02 jrDTileA13 jrDTileA03 jrDTileA14
    .DW jrDTileA04 jrDTileA15 jrDTileA05 jrDTileA16
    .DW jrDTileA06 jrDTileA17 jrDTileA07 jrDTileA18

    .DW jrDTileA08 jrDTileA19 jrDTileA09 jrDTileA1A
    .DW jrDTileA06 jrDTileA1B jrDTileA07 jrDTileA07
    .DW jrDTileA0A jrDTileA1C jrDTileA07 jrDTileA07
    .DW jrDTileA0B jrDTileA1D jrDTileA07 jrDTileA1E

    .DW jrDTileA0C jrDTileA1F jrDTileA0D jrDTileA20
    .DW jrDTileA0E jrDTileA21 jrDTileA07 jrDTileA22
    .DW jrDTileA0F jrDTileA23 jrDTileA07 jrDTileA07
    .DW jrDTileA10 jrDTileA24 jrDTileA07 jrDTileA25