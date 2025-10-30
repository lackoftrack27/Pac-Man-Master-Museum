/*
------------------------------------------------
                PAC-MAN DATA
------------------------------------------------
*/

;   PAC-MAN [SMOOTH, NON-PLUS] TILE TABLE
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



;   PAC-MAN [SMOOTH, PLUS] TILE TABLE
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



;   PAC-MAN [SMOOTH] DEATH TILE TABLE
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



;   PAC-MAN [ARCADE, NON-PLUS] TILE TABLE
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



;   PAC-MAN [ARCADE, PLUS] TILE TABLE
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



;   PAC-MAN [ARCADE] DEATH TILE TABLE
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