/*
------------------------------------------------
            UNSORTED FUNCTIONS
------------------------------------------------
*/



/*
    INFO: ADD TASK TO LIST (USED ONLY FOR PATHFINDING)
    INPUT: A - TASK ID
    OUTPUT: NONE
    USES: AF, HL
*/
addTask:
;   STORE TASK ID, INCREMENT TASK LIST POINTER
    LD HL, (taskListEnd)
    LD (HL), A
    INC HL
    LD (taskListEnd), HL
    RET


/*
    INFO: DETERMINE WHAT BG PALETTE TO USE BASED ON GAME AND CURRENT LEVEL
    INPUT: NONE
    OUTPUT: HL - BG PALETTE PTR
    USES: AF, HL
*/
getbgPalPtr:
;   CHECK IF GAME IS MS.PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @msSection   ; IF SO, SKIP
;   CHECK IF GAME IS JR.PAC
    BIT JR_PAC, A
    JR NZ, @jrSection   ; IF SO, SKIP
;   ----------------------------------------
    LD HL, bgPalPac     ; ASSUME GAME IS PAC-MAN
;   CHECK IF GAME IS PLUS (PAC-MAN)
    BIT PLUS, A
    RET Z               ; IF NOT, END
    LD HL, bgPalPlus    ; ELSE, LOAD PAL DATA FOR PLUS
    RET
;   ----------------------------------------
@msSection:
;   CHECK IF GAME IS PLUS
    LD HL, msLevelPalTable      ; ASSUME GAME IS NORMAL
    BIT PLUS, A
    JR Z, +                     ; IF NOT, SKIP
    LD HL, msLevelPalTable@plus ; LOAD TABLE FOR PLUS VERSION
+:
;   CHECK IF LEVEL IS GREATER THAN 21
    LD A, (currPlayerInfo.level)
    CP A, $15
    JR NC, +    ; IF SO, REDUCE
@@msGetPal:
;   GET PALETTE FOR CURRENT LEVEL
    RST addToHL
    ; GET DATA AND DOUBLE IT
    ADD A, A
    ; ADD TO PALETTE TABLE
    LD HL, msPalTable
    RST addToHL
    ; GET PALETTE
    JP getDataAtHL
;   LEVEL REDUCTION
+:
    SUB A, $15  ; SUBTRACT 21
-:
    SUB A, $10  ; SUBTRACT 16 UNTIL NEGATIVE
    JR NC, -
    ADD A, $15  ; ADD BACK 21
    JR @@msGetPal
;   ----------------------------------------
@jrSection:
;   CHECK IF GAME IS PLUS
    LD HL, jrLevelPalTable      ; ASSUME GAME IS NORMAL
    BIT PLUS, A
    JR Z, +                     ; IF NOT, SKIP
    LD HL, jrLevelPalTable@plus ; LOAD TABLE FOR PLUS VERSION
+:
;   CHECK IF LEVEL IS GREATER THAN 21
    LD A, (currPlayerInfo.level)
    CP A, $15
    JR NC, +    ; IF SO, REDUCE
@@jrGetPal:
;   GET PALETTE FOR CURRENT LEVEL
    RST addToHL
    ; GET DATA AND DOUBLE IT
    ADD A, A
    ; ADD TO PALETTE TABLE
    LD HL, jrPalTable
    RST addToHL
    ; GET PALETTE
    JP getDataAtHL
;   LEVEL REDUCTION
+:
    SUB A, $15  ; SUBTRACT 21
-:
    SUB A, $10  ; SUBTRACT 16 UNTIL NEGATIVE
    JR NC, -
    ADD A, $15  ; ADD BACK 21
    JR @@jrGetPal



/*
    INFO: WRITE MAZE PALETTE TO RAM BUFFER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE
*/
cpyMazePalToRam:
;   LOAD BG PALETTE TO RAM
    CALL getbgPalPtr
    LD DE, mazePalette
    LD BC, BG_CRAM_SIZE
    LDIR
;   MODIFY IF STYLE IS "ARCADE"
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    RET Z     ; IF NOT, END
    XOR A
    LD (mazePalette + BGPAL_SHADE0), A  ; SHADE 0 BECOMES BLACK
    LD A, (mazePalette + BGPAL_WALLS)   ; SHADE 1 BECOMES WALL COLOR
    LD (mazePalette + BGPAL_SHADE1), A
    LD A, (mazePalette + BGPAL_PDOT1)   ; PDOT0 BECOMES PDOT1,2,3
    LD (mazePalette + BGPAL_PDOT0), A
    RET




/*
    INFO: SETUP TILE POINTERS FOR PLAYER OBJECT (LOOK AT pacmanData.asm)
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL
*/
setupTilePtrs:
;   PLAYER TILE DEFINITION TABLE SETUP
    LD HL, playerTileTblList
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0 | $01 << OTTO | $01 << JR_PAC | $01 << MS_PAC | $01 << PLUS
    ADD A, A
    RST addToHL
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    LD (playerTileTblPtr), HL
;   DEATH TILE DEFINITION TABLE SETUP
    LD HL, deathTileTblList
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0 | $01 << OTTO | $01 << JR_PAC | $01 << MS_PAC
    RST addToHL
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    LD (deathTileTblPtr), HL
    RET
    