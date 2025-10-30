/*
-----------------------------------------------
                MS. PAC-MAN DATA
-----------------------------------------------
*/

;   MS.PAC-MAN [SMOOTH, NON-PLUS] TILE TABLE
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


;   MS.PAC-MAN [SMOOTH, PLUS] TILE TABLE
msSPTileTbl:
;   UP
@up:
    .DW msTileS00 msTileS16 msTileS01 msTileS17 ; OPEN
    .DW msTileS23 msTileS16 msTileS09 msTileS17 ; HALF PLUS
    .DW msTileS0F msTileS16 msTileS10 msTileS17 ; CLOSED
    .DW msTileS23 msTileS16 msTileS09 msTileS17 ; HALF PLUS
;   LEFT
@left:
    .DW msTileS24 msTileS1D msTileS03 msTileS17 ; HALF PLUS
    .DW msTileS11 msTileS20 msTileS03 msTileS17 ; CLOSED
    .DW msTileS24 msTileS1D msTileS03 msTileS17 ; HALF PLUS
    .DW msTileS02 msTileS18 msTileS03 msTileS17 ; OPEN 
;   DOWN
    .DW msTileS25 msTileS1E msTileS0C msTileS1F ; HALF PLUS
    .DW msTileS12 msTileS22 msTileS13 msTileS17 ; CLOSED
    .DW msTileS25 msTileS1E msTileS0C msTileS1F ; HALF PLUS
    .DW msTileS04 msTileS19 msTileS05 msTileS1A ; OPEN
;   RIGHT
    .DW msTileS06 msTileS1B msTileS07 msTileS1C ; OPEN
@hudPtr:
    .DW msTileS26 msTileS20 msTileS0E msTileS21 ; HALF PLUS
    .DW msTileS14 msTileS20 msTileS15 msTileS17 ; CLOSED
    .DW msTileS26 msTileS20 msTileS0E msTileS21 ; HALF PLUS


;   MS.PAC-MAN [ARCADE, NON-PLUS] TILE TABLE
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


;   MS.PAC-MAN [ARCADE, PLUS] TILE TABLE
msAPTileTbl:
;   UP
@up:
    .DW msTileA00 msTileA15 msTileA01 msTileA16 ; OPEN
    .DW msTileA24 msTileA15 msTileA09 msTileA16 ; HALF PLUS
    .DW msTileA0F msTileA15 msTileA10 msTileA16 ; CLOSED
    .DW msTileA24 msTileA15 msTileA09 msTileA16 ; HALF PLUS
;   LEFT
@left:
    .DW msTileA25 msTileA1D msTileA03 msTileA18 ; HALF PLUS
    .DW msTileA11 msTileA21 msTileA03 msTileA18 ; CLOSED
    .DW msTileA25 msTileA1D msTileA03 msTileA18 ; HALF PLUS
    .DW msTileA02 msTileA17 msTileA03 msTileA18 ; OPEN
;   DOWN
    .DW msTileA26 msTileA1E msTileA0C msTileA18 ; HALF PLUS
    .DW msTileA12 msTileA22 msTileA03 msTileA18 ; CLOSED
    .DW msTileA26 msTileA1E msTileA0C msTileA18 ; HALF PLUS
    .DW msTileA04 msTileA19 msTileA05 msTileA1A ; OPEN
;   RIGHT
    .DW msTileA06 msTileA1B msTileA07 msTileA1C ; OPEN
@hudPtr:
    .DW msTileA27 msTileA1F msTileA0E msTileA20 ; HALF PLUS
    .DW msTileA13 msTileA1F msTileA14 msTileA23 ; CLOSED
    .DW msTileA27 msTileA1F msTileA0E msTileA20 ; HALF PLUS


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