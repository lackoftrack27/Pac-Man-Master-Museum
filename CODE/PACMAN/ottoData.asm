/*
-----------------------------------------------
                CRAZY OTTO DATA
-----------------------------------------------
*/

;   OTTO [SMOOTH] TILE TABLE
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
    


;   OTTO DEATH [SMOOTH] TILE TABLE
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



;   OTTO [ARCADE] TILE TABLE
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



;   OTTO DEATH [ARCADE] TILE TABLE
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
    


;   ANNA [SMOOTH] TILE TABLE
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



;   ANNA [ARCADE] TILE TABLE
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