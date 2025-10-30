/*
-----------------------------------------------
            JR. PAC-MAN DATA
-----------------------------------------------
*/

;   JR.PAC-MAN [SMOOTH, NON-PLUS] TILE TABLE
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


;   JR.PAC-MAN [SMOOTH, PLUS] TILE TABLE
jrSPTileTbl:
;   UP
@up:
    .DW jrTileS00 jrTileS16 jrTileS01 jrTileS17 ; OPEN
    .DW jrTileS27 jrTileS16 jrTileS08 jrTileS1E ; HALF PLUS
    .DW jrTileS0E jrTileS23 jrTileS0F jrTileS24 ; CLOSED
    .DW jrTileS27 jrTileS16 jrTileS08 jrTileS1E ; HALF PLUS
;   LEFT
@left:
    .DW jrTileS28 jrTileS1F jrTileS0A jrTileS19 ; HALF PLUS
    .DW jrTileS10 jrTileS25 jrTileS11 jrTileS19 ; CLOSED
    .DW jrTileS28 jrTileS1F jrTileS0A jrTileS19 ; HALF PLUS
    .DW jrTileS02 jrTileS18 jrTileS03 jrTileS19 ; OPEN 
;   DOWN
@down:
    .DW jrTileS29 jrTileS20 jrTileS0A jrTileS19 ; HALF PLUS
    .DW jrTileS12 jrTileS25 jrTileS13 jrTileS19 ; CLOSED
    .DW jrTileS29 jrTileS20 jrTileS0A jrTileS19 ; HALF PLUS
    .DW jrTileS04 jrTileS1A jrTileS03 jrTileS1B ; OPEN
;   RIGHT
@right:
@titlePtr:
    .DW jrTileS05 jrTileS1C jrTileS06 jrTileS1D ; OPEN
@hudPtr:
    .DW jrTileS2A jrTileS21 jrTileS0D jrTileS22 ; HALF PLUS
    .DW jrTileS14 jrTileS21 jrTileS15 jrTileS26 ; CLOSED
    .DW jrTileS2A jrTileS21 jrTileS0D jrTileS22 ; HALF PLUS


;   JR.PAC-MAN [ARCADE, NON-PLUS] TILE TABLE
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


;   JR.PAC-MAN [ARCADE, PLUS] TILE TABLE
jrAPTileTbl:
;   UP
@up:
    .DW jrTileA00 jrTileA13 jrTileA01 jrTileA14 ; OPEN
    .DW jrTileA23 jrTileA13 jrTileA08 jrTileA1B ; HALF PLUS
    .DW jrTileA0D jrTileA13 jrTileA08 jrTileA1F ; CLOSED
    .DW jrTileA23 jrTileA13 jrTileA08 jrTileA1B ; HALF PLUS
;   LEFT
@left:
    .DW jrTileA24 jrTileA25 jrTileA0A jrTileA16 ; HALF PLUS
    .DW jrTileA0E jrTileA20 jrTileA0F jrTileA16 ; CLOSED
    .DW jrTileA24 jrTileA25 jrTileA0A jrTileA16 ; HALF PLUS
    .DW jrTileA02 jrTileA15 jrTileA03 jrTileA16 ; OPEN 
;   DOWN
@down:
    .DW jrTileA04 jrTileA26 jrTileA0A jrTileA16 ; HALF PLUS
    .DW jrTileA04 jrTileA21 jrTileA10 jrTileA16 ; CLOSED
    .DW jrTileA04 jrTileA26 jrTileA0A jrTileA16 ; HALF PLUS
    .DW jrTileA04 jrTileA17 jrTileA03 jrTileA18 ; OPEN
;   RIGHT
@right:
@titlePtr:
    .DW jrTileA05 jrTileA19 jrTileA06 jrTileA1A ; OPEN
@hudPtr:
    .DW jrTileA0B jrTileA19 jrTileA27 jrTileA28 ; HALF PLUS
    .DW jrTileA11 jrTileA19 jrTileA12 jrTileA22 ; CLOSED
    .DW jrTileA0B jrTileA19 jrTileA27 jrTileA28 ; HALF PLUS


;   JR.PAC-MAN DEATH [SMOOTH] TILE TABLE
jrSNDeathTileTbl:
    .DW jrDTileS00 jrDTileS14 jrDTileS01 jrDTileS15
    .DW jrDTileS02 jrDTileS16 jrDTileS03 jrDTileS17
    .DW jrDTileS04 jrDTileS18 jrDTileS05 jrDTileS19
    .DW jrDTileS06 jrDTileS1A jrDTileS07 jrDTileS1B

    .DW jrDTileS08 jrDTileS1C jrDTileS09 jrDTileS1D
    .DW jrDTileS0A jrDTileS1E jrDTileS0B jrDTileS0B
    .DW jrDTileS0C jrDTileS1F jrDTileS0B jrDTileS0B
    .DW jrDTileS0D jrDTileS20 jrDTileS0E jrDTileS21

    .DW jrDTileS0F jrDTileS22 jrDTileS10 jrDTileS23
    .DW jrDTileS0D jrDTileS20 jrDTileS0E jrDTileS21
    .DW jrDTileS11 jrDTileS24 jrDTileS0B jrDTileS25
    .DW jrDTileS12 jrDTileS26 jrDTileS13 jrDTileS27


;   JR.PAC-MAN DEATH [ARCADE] TILE TABLE
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



;   FRAMES TIMES
jrDeathTimes:
    .DB $1E $08 $07 $08 $07 $08 $07 $08 $07 $08 $07 $5D