/*
------------------------------------------------
            MS. PAC-MAN FUNCTIONS
------------------------------------------------
*/


/*
    INFO: DETERMINE WHAT INDEX TO USE (GIVEN A TABLE) GIVEN THE CURRENT LEVEL
    INPUT: HL - TABLE WE WANT AN INDEX FOR
    OUTPUT: NONE
    USES: AF, HL
*/
getMazeIndex:
;   CHECK IF LEVEL IS GREATER IS 13 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $0D
    JR NC, @clamp13  ; IF SO, REDUCE IT UNTIL IT IS UNDER
@lookup:
;   GET OFFSET BYTE FROM LUT
    PUSH HL     ; SAVE PREV. TABLE
    LD HL, @dataLUT
    RST addToHL
    POP HL      ; RESTORE
;   GET CORRECT MAZE ADDRESS
    ADD A, A
    RST addToHL
    JP getDataAtHL
@clamp13:
    SUB A, $0D
-:
    SUB A, $08
    JP NC, -
    ADD A, $0D
    JP @lookup
@dataLUT:
    .DB 0 0 1 1 1 2 2 2 2 3 3 3 3




jrGetMazeIndex:
;   CHECK IF LEVEL IS GREATER IS 14 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $0E
    JR NC, @clamp14  ; IF SO, REDUCE IT UNTIL IT IS UNDER
@lookup:
;   GET OFFSET BYTE FROM LUT
    PUSH HL     ; SAVE PREV. TABLE
    LD HL, @dataLUT
    RST addToHL
    POP HL      ; RESTORE
;   GET CORRECT MAZE ADDRESS
    ADD A, A
    RST addToHL
    JP getDataAtHL
@clamp14:
    SUB A, $0E
-:
    SUB A, $04
    JP NC, -
    ADD A, $0E
    JP @lookup
@dataLUT:
    .DB 1 0 3 2 5 4 6 2 5 4 6 2 5 4