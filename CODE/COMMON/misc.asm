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
getBgPalPtr:
;   LOAD DIFFERENT PALETTES DEPENDING ON GAME...
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS_PAC
    JR C, @msSection
    RRCA    ; JR_PAC
    JR C, @jrSection
;   --------------------
;       PAC-MAN CODE
;   --------------------
    LD HL, bgPalPac     ; ASSUME GAME IS NORMAL
;   CHECK IF GAME IS PLUS (PAC-MAN)
    AND A, $01 << (PLUS + $05)
    RET Z               ; IF NOT, END
    LD HL, bgPalPlus    ; ELSE, LOAD PAL DATA FOR PLUS
    RET
;   --------------------
;      MS.PAC-MAN CODE
;   --------------------
@msSection:
;   CHECK IF GAME IS PLUS
    LD HL, msLevelPalTable      ; ASSUME GAME IS NORMAL
    AND A, $01 << (PLUS + $06)
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
;   --------------------
;      JR.PAC-MAN CODE
;   --------------------
@jrSection:
;   CHECK IF GAME IS PLUS
    LD HL, jrLevelPalTable      ; ASSUME GAME IS NORMAL
    AND A, $01 << (PLUS + $05)
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
    CALL getBgPalPtr
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
    AND A, $01 << STYLE_0 | $01 << OTTO | $01 << JR_PAC | $01 << MS_PAC | $01 << PLUS
    ADD A, A
    RST addToHL
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    LD (deathTileTblPtr), HL
    RET


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
    JP NC, @clamp13  ; IF SO, REDUCE IT UNTIL IT IS UNDER
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



/*
    [JR VARIANT]
    INFO: DETERMINE WHAT INDEX TO USE (GIVEN A TABLE) GIVEN THE CURRENT LEVEL
    INPUT: HL - TABLE WE WANT AN INDEX FOR
    OUTPUT: NONE
    USES: AF, HL
*/
jrGetMazeIndex:
;   CHECK IF LEVEL IS GREATER IS 14 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $0E
    JP NC, @clamp14  ; IF SO, REDUCE IT UNTIL IT IS UNDER
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


/*
------------------------------------------------
                PLUS FUNCTIONS
------------------------------------------------
*/

/*
    INFO: RANDOMNESS FOR WHEN PLAYER EATS POWER DOT [PLUS]
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
plus_powerDotRNG:
;   CHECK IF GAME IS IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT
    RET Z   ; IF SO, EXIT
;   RESET ALL INVISIBLE FLAGS
    XOR A
    LD (blinky + INVISIBLE_FLAG), A
    LD (pinky + INVISIBLE_FLAG), A
    LD (inky + INVISIBLE_FLAG), A
    LD (clyde + INVISIBLE_FLAG), A
;   COPY RNG VALUE TO C
    LD A, (plusRNGValue)
    LD C, A
;   AND WITH 0x40
    AND A, $40
    JP NZ, @mazeInvisible   ; IF NOT 0, SKIP GHOST SWITCH
;   AND RNG VALUE WITH 0x03, THEN USE AS OFFSET INTO GHOSTS
    LD A, C
    AND A, $03
    LD B, A
    INC B
    LD IX, blinky - _sizeof_ghost
    LD DE, _sizeof_ghost
-:
    ADD IX, DE
    DJNZ -
;   MAKE SELECTED GHOST NOT TURN SCARED
    CALL ghostGameTrans_normal
    LD (IX + NEW_STATE_FLAG), $00
@mazeInvisible:
;   CALCULATE LEVEL LIMIT
    ; SUBTRACT 1 IF GAME IS JR (LEVEL 1 - RIGHT AFTER 1ST CUTSCENE)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    RRCA
    RRCA
    LD B, A
    LD A, $02   ; PAC/MS.PAC: LEVEL 2 - RIGHT AFTER 1ST CUTSCENE
    SUB A, B
    LD B, A
;   CHECK IF LEVEL IS 2 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, B
    RET C   ; IF NOT, END
;   AND RNG VALUE WITH 0x10
    LD A, C
    AND A, $10
    RET NZ  ; END IF RESULT ISN'T 0
    SET 7, (HL) ; SET BIT 7 OF PLUS FLAGS (SIGNIFY TO TURN MAZE INVISIBLE)
    RET


/*
    INFO: FOR WHEN PLAYER EATS A FRUIT [PLUS]
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL, IX
*/
plus_fruitSuper:
;   RESET GHOST FLASH COUNTER
    XOR A
    LD (flashCounter), A
;   SET GHOST POINT INDEX TO START AT 1 (400)
    INC A
    LD (ghostPointIndex), A
;   SET INVISIBLE FLAGS OF GHOSTS
    LD (blinky + INVISIBLE_FLAG), A
    LD (pinky + INVISIBLE_FLAG), A
    LD (inky + INVISIBLE_FLAG), A
    LD (clyde + INVISIBLE_FLAG), A
;   SWITCH STATE TO SUPER
    LD (pacPoweredUp), A
;   NOTIFY ACTORS
    CALL pacGameTrans_super
    LD IX, blinky
    CALL ghostGameTrans_super
    LD IX, pinky
    CALL ghostGameTrans_super
    LD IX, inky
    CALL ghostGameTrans_super
    LD IX, clyde
    CALL ghostGameTrans_super
;   SET POWER DOT'S TIME
    LD HL, (plusFruitSuperTime)
    LD (mainTimer1), HL
    RET


/*
------------------------------------------------
                SRAM FUNCTIONS
------------------------------------------------
*/

/*
    INFO: CHECK TO SEE IF SRAM HAS BEEN INITIALIZED. IF NOT, IT INITIALIZES IT
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
initSRAM:
;   CHECK IF SRAM IS PRESENT
    ; ENABLE SRAM
    LD A, $01 << SRAM_EN
    LD (MAPPER_RAM), A
    ; CLEAR PRESENT FLAG
    XOR A
    LD (sramFlag), A 
    ; DO A TEST WRITE
    LD DE, SRAM_WORD_0
    LD (sramScores.testWrite), DE
    LD HL, (sramScores.testWrite)
    SBC HL, DE  ; CARRY CLEARED
    JR NZ, @end
    ; SET FLAG (SRAM IS PRESENT)
    LD HL, sramFlag
    INC (HL)
;   CHECK IF SRAM HAS BEEN INITIALIZED
    ; CHECK IF SIGNITURE IS PRESENT
    LD HL, (sramScores.sramSig)
    SBC HL, DE  ; CARRY CLEARED
    JR NZ, @initScores
    LD HL, (sramScores.sramSig + $02)
    LD DE, SRAM_WORD_1
    SBC HL, DE  ; CARRY CLEARED
    JR Z, @end
@initScores:
;   INITIALIZE SRAM
    ; CLEAR SCORES
    LD HL, sramScores
    LD DE, sramScores + $01
    LD (HL), $00
    LD BC, _sizeof_sramScores - $01
    LDIR
    ; SET SIGNATURE
    LD HL, SRAM_WORD_0
    LD (sramScores.sramSig), HL
    LD HL, SRAM_WORD_1
    LD (sramScores.sramSig + $02), HL
@end:
;   DISABLE SRAM
    XOR A
    LD (MAPPER_RAM), A
    RET


/*
    INFO: LOAD HIGH SCORE FROM SRAM IF AVAILABLE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
loadScorefromSRAM:
;   EXIT IF SRAM ISN'T PRESENT
    LD A, (sramFlag)
    OR A
    RET Z
;   GET HIGH SCORE FROM SRAM
    CALL getSRAMScore
;   LOAD TO HIGH SCORE IN RAM
    LD (highScore + 2), A
    LD (highScore), DE
    JR initSRAM@end



/*
    INFO: SAVE HIGH SCORE TO SRAM IF AVAILABLE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
saveScoreToSRAM:
;   EXIT IF SRAM ISN'T PRESENT
    LD A, (sramFlag)
    OR A
    RET Z
;   GET HIGH SCORE FROM SRAM
    CALL getSRAMScore
;   COMPARE TO HIGH SCORE
    ; UPPER BYTES
    LD A, (highScore + 2)
    LD B, A
    LD A, (HL)
    SUB A, B
    EX DE, HL   ; HL: SRAM SCORE LOW WORD, DE: SRAM SCORE PTR + 2
    JR C, +     ; CARRY SET IF SRAMSCORE < HIGHSCORE
    JR NZ, initSRAM@end
    ; LOWER WORDS
    LD BC, (highScore)
    SBC HL, BC          ; CARRY SET IF SRAMSCORE < HIGHSCORE (CARRY CLEARED)
    JR NC, initSRAM@end ; IF SCORE ISN'T GREATER THAN HIGHSCORE, RETURN
+:
;   SAVE HIGH SCORE TO SRAM
    LD HL, highScore + 2
    LDD
    LDD
    LDD
    JR initSRAM@end


/*
    [HELPER]
    INFO: GETS HIGH SCORE FROM SRAM ACCORDING TO GAME MODE/TYPE
    INPUT: NONE
    OUTPUT: DE - HIGH SCORE (LOW WORD), A - HIGH SCORE (UPPER BYTE), HL - SRAM SCORE PTR + 2
    USES: AF, BC, DE, HL
*/
getSRAMScore:
;   ENABLE SRAM
    LD A, $01 << SRAM_EN
    LD (MAPPER_RAM), A
;   CALCULATE CORRECT OFFSET
    LD A, (speedUpFlag)
    ADD A, A
    ADD A, A
    ADD A, A
    LD C, A     ; BIT 3
    LD A, (plusBitFlags)
    AND A, $01 << PLUS | $01 << MS_PAC | $01 << JR_PAC
    ADD A, C
    LD B, A     ; * 3
    ADD A, A
    ADD A, B
    LD HL, sramScores
    RST addToHL
;   GET HIGH SCORE
    LD E, (HL)
    INC L
    LD D, (HL)
    INC L
    LD A, (HL)
    RET