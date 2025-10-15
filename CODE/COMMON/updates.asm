/*
------------------------------------------------
    UPDATE FUNCTIONS FOR DIFFERENT STUFF
------------------------------------------------
*/



/*
    INFO: COMMON UPDATE FUNCTION USED FOR NORMAL MODE
    INPUT: NONE
    OUTPUT: NONE
    USES: DE, HL, AF
*/
generalGameplayUpdate:
;   DEAD STATE UPDATE FUNC (OG)
;   EXIT IF DEAD
    LD A, (subGameMode)
    CP A, GAMEPLAY_DEAD00
    RET Z
;   IF GHOST IS BEING EATEN, CHANGE ITS STATE (OG) [ONLY EXECUTED WHEN EATING IS DONE]
    LD A, (eatSubState)
    OR A
    CALL M, ghostUpdateDeadState
;   UPDATE GHOSTS THAT ARE GOING HOME
    CALL ghostToHomeUpdate
;   GHOST POINTS UPDATE (SHOW / REMOVE) IF POINTS ARE SHOWING, END AFTER
    LD A, (ghostPointSprNum)
    OR A
    JR NZ, eatModeUpdate
.IF INVINCIBLE == $00
;   COLLISION CHECK BETWEEN PAC-MAN AND GHOSTS
    CALL globalCollCheckTile
    CALL globalCollCheckPixel  ; SECOND CHECK WHICH ONLY APPLIES DURING SUPER MODE
.ENDIF
    ; EXIT IF COLLISION OCCURED
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   GET PLAYER INPUT
    CALL getInput
;   UPDATE PAC-MAN (AND MAYBE MAZE)
    LD HL, pacStateTable@update
    LD A, (pacman.state)
    RST jumpTableExec
;   UPDATE ALL GHOSTS (THAT ARE OUTSIDE OF HOME)
    CALL ghostOutHomeUpdate
;   CONTROL SUPER TIMER (ONLY IN SUPER MODE)
    LD A, (pacPoweredUp)
    OR A
    CALL NZ, superTimerUpdate
;   CHECK IF GHOSTS CAN LEAVE HOME (DOT COUNTER)
    JP ghostDotReleaser


/*
    INFO: UPDATE FUNCTION WHEN PAC-MAN IS EATING GHOST
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
eatModeUpdate:
;   CHECK WHICH SUBSTATE IS ACTIVE
    LD A, (eatSubState)
    DEC A
    JP NZ, @update
@enter:
;   SET TIMER
    LD A, EAT_TIMER_LEN
    LD (mainTimer0), A
;   INCREASE SCORE
    LD A, (ghostPointIndex) ; CONVERT INDEX TO OFFSET
    ADD A, A
    LD HL, ghostScoreTable  ; ADD TO SCORE TABLE
    addToHL_M
    RST getDataAtHL         ; GET SCORE VALUE FROM TABLE
    CALL addToScore         ; ADD TO SCORE
;   PLAY GHOST ATE SOUND
    LD HL, ch2SoundControl
    SET 3, (HL)
;   UPDATE SUBSTATE
    LD A, $02
    LD (eatSubState), A
    RET
@update:
;   UPDATE EATING TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ      ; END IF NOT 0
@exit:
;   UPDATE EATEN GHOST'S STATE
    LD A, (ghostPointSprNum)
    OR A, $80
    LD (eatSubState), A
;   UPDATE GHOST POINTS SPR NUM
    XOR A
    LD (ghostPointSprNum), A
    RET


/*
    INFO: GETS PLAYER INPUT
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, B
*/
getInput:
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    RET NZ  ; IF SO, END...
;   SET INPUT FLAG (ASSUME PLAYER WILL GIVE INPUT)
    LD HL, inputFlag
    LD (HL), $01
;   READ CONTROLLERS
    ; PLAYER 1 / SOME OF PLAYER 2
    IN A, CONTROLPORT1
    CPL     ; INVERT SO 1 = PRESSED, 0 = NO PRESS
    LD (controlPort1), A
    LD B, A
    ; REST OF PLAYER 2
    IN A, CONTROLPORT2
    CPL
    LD (controlPort2), A
    LD C, A
;   CHECK WHICH PLAYER IS PLAYING
    LD A, (playerType)
    AND A, $01 << CURR_PLAYER
    JP NZ, +    ; IF PLAYER 2, SKIP...
;   GET INPUTS FROM PLAYER 1 (LEFT, RIGHT, UP, DOWN)
    ; ASSUME LEFT IS PRESSED
    LD A, DIR_LEFT
    BIT 2, B    
    JP NZ, @setWanted ; IF SO, SET WANTED DIR TO LEFT
    ; ASSUME RIGHT...
    LD A, DIR_RIGHT
    BIT 3, B
    JP NZ, @setWanted
    ; ASSUME UP...
    LD A, DIR_UP
    BIT 0, B
    JP NZ, @setWanted
    ; ASSUME DOWN...
    LD A, DIR_DOWN
    BIT 1, B
    JP NZ, @setWanted
@noDir:
    ; NO DIRECTION WAS PRESSED
    DEC (HL)    ; CLEAR INPUT FLAG
    LD A, (pacman.currDir)  ; WANTED DIRECTION WILL BE CURRENT DIRECTION
@setWanted:
    LD (pacman.nextDir), A  ; SET WANTED DIRECTION
    RET
+:
;   GET INPUTS FROM PLAYER 2 (LEFT, RIGHT, UP, DOWN)
    ; ASSUME LEFT IS PRESSED
    LD A, DIR_LEFT
    BIT 0, C
    JP NZ, @setWanted ; IF SO, SET WANTED DIR TO LEFT
    ; ASSUME RIGHT...
    LD A, DIR_RIGHT
    BIT 1, C
    JP NZ, @setWanted
    ; ASSUME UP...
    LD A, DIR_UP
    BIT 6, B
    JP NZ, @setWanted
    ; ASSUME DOWN...
    LD A, DIR_DOWN
    BIT 7, B
    JP NZ, @setWanted
    ; NO DIRECTION WAS PRESSED
    JP @noDir




/*
    INFO: ADDS A BCD NUMBER TO SCORE
    INPUT: HL - NUMBER TO ADD
    OUTPUT: NONE
    USES: AF, HL, BC, DE, HL
*/
addToScore:
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    OR A
    RET Z  ; IF SO, EXIT...
    LD DE, currPlayerInfo.score
;   ADD FIRST TWO DIGITS OF BOTH NUMBERS
    LD A, (DE)
    ADD A, L
    DAA         ; CORRECT BCD BALUE
    LD (DE), A  ; STORE
;   ADD NEXT PAIR OF DIGITS OF BOTH NUMBERS
    INC DE
    LD A, (DE)
    ADC A, H    ; ADD TOGETHER (WITH CARRY FROM PREVIOUS DIGITS)
    DAA         ; CORRECT BCD BALUE
    LD (DE), A  ; STORE
;   CORRECT UPPER TWO DIGITS 
    INC DE
    LD A, (DE)
    ADC A, $00  ; ADD CARRY IF NEED BE
    DAA         ; CORRECT BCD BALUE (PROBABLY NOT NEEDED)
    LD (DE), A  ; STORE
;   UPDATE TILEMAP BUFFER
    CALL scoreTileMapUpdate
;   CHECK IF EXTRA LIFE WAS ALREADY GIVEN
    LD A, (currPlayerInfo.awarded1UPFlag)
    OR A
    JP NZ, @compareHS   ; IF SO, SKIP...
;   CHECK IF CURRENT SCORE IS GREATER OR EQUAL TO THE SCORE REQUIRED TO GET EXTRA LIFE
    ; COMPARE UPPER BYTES
    LD A, (currPlayerInfo.score + 2)
    LD B, A
    LD A, (bonusValue + 2)
    CP A, B    
    JP C, +     ; CARRY SET IF SCORE > BONUS
    JP NZ, @compareHS       ; IF NOT EQUAL, SKIP
    ; IF UPPER BYTE IS EQUAL, COMPARE LOWER WORDS
    LD BC, (bonusValue)
    LD HL, (currPlayerInfo.score)
    SBC HL, BC
    JP C, @compareHS
+:
    ; INCREASE LIFE COUNT
    LD HL, currPlayerInfo.lives
    INC (HL)
    ; SET FLAG ASWELL
    LD HL, currPlayerInfo.awarded1UPFlag
    INC (HL)
    ; PLAY 1UP SOUND
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, ch2SndControlJR
    SET 2, (HL)
    JP @compareHS
+:
    LD A, SFX_BONUS
    LD B, $00       ; CHANNEL 0
    CALL sndPlaySFX
@compareHS:
    XOR A
    LD (drawHScoreFlag), A
;   COMPARE SCORE TO HIGH SCORE
    ; COMPARE UPPER BYTES
    LD A, (currPlayerInfo.score + 2)
    LD B, A
    LD A, (highScore + 2)
    SUB A, B    
    JP C, +     ; CARRY SET IF SCORE > HIGHSCORE
    RET NZ      ; IF NOT EQUAL, RETURN
    ; IF UPPER BYTE IS EQUAL, COMPARE LOWER WORDS
    LD HL, (highScore)
    LD DE, (currPlayerInfo.score)
    SBC HL, DE  ; CARRY SET IF SCORE > HIGHSCORE (CARRY CLEARED)
    RET NC      ; IF SCORE ISN'T GREATER THAN HIGHSCORE, RETURN
+:
;   SET HIGH SCORE TO PLAYER'S SCORE
    LD HL, drawHScoreFlag
    INC (HL)
    LD HL, (currPlayerInfo.score)
    LD (highScore), HL
    LD A, (currPlayerInfo.score + 2)
    LD (highScore + 2), A
    RET


/*
    INFO: INITIALIZES SCORE TILEMAP BUFFER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
scoreTilemapRstBuffer:
;   SET FIRST FOUR DIGITS TO BLANK
    LD HL, scoreTileMapBuffer
    LD A, MASK_TILE
    LD (HL), A
    INC HL
    LD (HL), A
    INC HL
    LD (HL), A
    INC HL
    LD (HL), A
    INC HL
;   SET LAST TWO DIGITS TO 0
    LD A, HUDZERO_INDEX
    LD (HL), A
    INC HL
    LD (HL), A
    RET


/*
    INFO: CONVERTS SCORE (BCD) TO TILEMAP
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
scoreTileMapUpdate:
;   SCORE TILEMAP UPDATE ROUTINE
    LD BC, $000F   ; LEADING ZERO FLAG / NIBBLE BITMASK
    LD DE, scoreTileMapBuffer
    LD HL, currPlayerInfo.score + 2
;   317 CYCLES
    ; DIGIT 0 (LEFT MOST)
    LD A, (HL)
    RRCA
    RRCA
    RRCA
    RRCA
    AND A, C
    ADD A, B
    JP Z, +
    SUB A, B
    ADD A, HUDZERO_INDEX
    LD (DE), A
    INC B
+:
    INC DE
    ; DIGIT 1
    LD A, (HL)
    AND A, C
    ADD A, B
    JP Z, +
    SUB A, B
    ADD A, HUDZERO_INDEX
    LD (DE), A
    INC B
+:
    INC DE
    DEC HL
    ; DIGIT 2
    LD A, (HL)
    RRCA
    RRCA
    RRCA
    RRCA
    AND A, C
    ADD A, B
    JP Z, +
    SUB A, B
    ADD A, HUDZERO_INDEX
    LD (DE), A
    INC B
+:
    INC DE
    ; DIGIT 3
    LD A, (HL)
    AND A, C
    ADD A, B
    JP Z, +
    SUB A, B
    ADD A, HUDZERO_INDEX
    LD (DE), A
+:
    INC DE
    DEC HL
    ; DIGIT 4 (ZERO IS ALWAYS DRAWN)
    LD A, (HL)
    RRCA
    RRCA
    RRCA
    RRCA
    AND A, C
    ADD A, HUDZERO_INDEX
    LD (DE), A
    ; DIGIT 5 IS ALWAYS ZERO
    RET


/*
    INFO: DOES PALETTE CYCLING ON POWER PELLETS WHEN IT IS TIME TO DO SO
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
powDotCyclingUpdate:
;   INCREMENT FRAME COUNTER
    LD HL, powDotFrameCounter
    INC (HL)
;   CHECK IF STYLE IS "SMOOTH"
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JP Z, @smooth   ; IF SO, SKIP
;   CHECK IF FRAME COUNTER IS AT LIMIT
    LD A, POW_DOT_CYCLE_TIMER
    CP A, (HL)
    RET NZ          ; IF NOT, END...
;   RESET FRAME COUNTER
    LD (HL), $00    ; CLEAR FRAME COUNTER
;   CHECK IF FIRST INDEX IS 0
    LD A, (powDotPalette)
    OR A
    JP Z, @refresh  ; IF SO, SKIP
;   CLEAR PALETTE BUFFER
    XOR A
    LD HL, powDotPalette
    LD DE, powDotPalette + $01
    LD (HL), A
    LDI
    LDI
    LDI
    RET
@smooth:
;   CHECK IF FRAME COUNTER IS AT LIMIT
    BIT 1, (HL) ; 2
    RET Z   ; IF NOT, END
;   RESET FRAME COUNTER
    RES 1, (HL)
;   CHECK IF PALETTE NEEDS TO BE REFRESHED
    LD A, (HL)
    CP A, $24       ; $09 << $02
    JP Z, @refresh  ; IF SO, SKIP
;   CALCULATE PALETTE FROM TABLE
    LD H, hibyte(powDotPalTable)
    ADD A, $80
    LD L, A
    LD DE, powDotPalette
    LD IXH, $04
    LD B, hibyte(colorDecTable) 
-:
    LD A, (HL)
    OR A
    JP Z, @@decBy0
    DEC A
    JP Z, @@decBy1
    DEC A
    JP Z, @@decBy2
@@decBy3:
    XOR A
    JP +        ; 63
@@decBy2:
    LD A, (mazePalette + BGPAL_PDOT1)
    ADD A, $40
    LD C, A
    LD A, (BC)
    JP +        ; 90
@@decBy1:
    LD A, (mazePalette + BGPAL_PDOT1)
    LD C, A
    LD A, (BC)
    JP +        ; 69
@@decBy0:
    LD A, (mazePalette + BGPAL_PDOT1)   ; 34
+:
    LD (DE), A
    INC HL
    INC DE
    DEC IXH
    JP NZ, -
;   UPDATE TABLE COUNTER
    LD A, (powDotFrameCounter)
    ADD A, $04
    LD (powDotFrameCounter), A
    RET
@refresh:
;   RESET
    XOR A
    LD (powDotFrameCounter), A
;   REFRESH PALETTE
    LD HL, mazePalette + BGPAL_PDOT0
    LD DE, powDotPalette
    LDI
    LDI
    LDI
    LDI
    RET



/*
    INFO: UPDATES RAM BUFFER WHEN MAZE NEEDS TO CHANGE (DOT EATEN)
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
mazeUpdate:
;   CHECK IF FRUIT IS ON SCREEN
    LD HL, currPlayerInfo.fruitStatus
    LD A, $0F
    AND A, (HL)
    DEC A       ; CHECK IF LOW NIBBLE IS 1
    CALL Z, checkEatenFruit ; IF SO, CHECK IF PAC-MAN IS EATING FRUIT
;   RESET DOT DELAY
    LD A, $FF
    LD (pacPelletTimer), A
;   CHECK IF PAC-MAN IS AT WALL
    LD A, (pacman + CURR_ID)
    AND A, $03
    SUB A, $02          ; CHECK IF TILE WAS 0/1 (EMPTY/WALL)
    RET C   ; IF SO, END
;   SETUP VARS
    LD HL, (tileMapRamPtr)      ; POINTER WITHIN TILEMAP IN RAM
;   JUMP IF AT POWER DOT
    JP NZ, @atPowerDot          ; JUMP IF POWER DOT WAS ATE (WAS 3, NOW 1)
    ; SET TILE BUFFER ADDRESS
    LD DE, (tileMapPointer)
    LD (tileBufferAddress), DE  ; STORE ACTUAL VDP ADDRESS
    ; CHECK IF DOT IS MUTATED (JR)
    LD A, (mazeMutatedTbl)
    LD B, A
    LD A, (HL)
    CP A, B
    JP NC, @mutatedDot
;   ELSE, A REGULAR DOT WAS ATE (WAS 2, NOW 0)
    ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    INC HL
    EX DE, HL   ; SAVE VRAM PTR IN DE
    ADD A, A    ; MULTIPLY BY 4 (EVERY TILE IS 4 BYTES LONG)
    ADD A, A
    LD HL, tileQuadrant ; GET ADDRESS OF TILE QUAD INTO HL
    ADD A, (HL)         ; ADD QUADRANT NUMBER TO OFFSET (DETERMINES WHICH AREA PAC-MAN INTERACTED WITH)
    ; ADD OFFSET TO BASE TABLE
    LD H, hiByte(mazeEatenTbl)  ; LOAD BASE TABLE ADDRESS AND SET LOW BYTE TO OFFSET
    LD L, A
    ; SET INDEX IN BUFFER
    LD A, (HL)  ; GET VALUE AT OFFSET
    LD B, A     ; SAVE IN B ALSO
    AND A, $3F  ; REMOVE FLIP BITS
    LD (tileBuffer + 1), A  ; STORE AS LOW BYTE
    ; SET FLIPPING IN BUFFER
    LD A, B     ; GET ORIGNAL VALUE
    ; PUT FLIP FLAGS (BIT 6, 7) IN SAME SPOT AS VRAM (BIT 1, 2)
    RLCA
    RLCA
    RLCA
    AND A, $06  ; CLEAR ALL BITS EXCEPT FLIP FLAGS
    LD B, A
    LD A, (DE)
    XOR A, B    ; XOR WITH FLIP FLAGS OF CURRENT TILE
    LD (tileBuffer + 2), A  ; STORE AS HIGH BYTE
    ; SET OFFSET
    XOR A
    LD (tileBuffer), A
    ; SET COUNT
    INC A   ; $01
    LD (tileBufferCount), A
    ; SET PAC-MAN'S DOT DELAY TIMER
    LD (pacPelletTimer), A  ; 0.83333 FOR PAL
    ; UPDATE TILEMAP IN VRAM
    LD HL, (tileMapRamPtr)
    LD A, (tileBuffer + 1)
    LD (HL), A
    INC HL
    LD A, (tileBuffer + 2)
    LD (HL), A
    ; ADD TO SCORE
    LD HL, $0010
    CALL addToScore
    ; GENERAL FINISH
    JP @updateCollision
@mutatedDot:
;   MUTATED DOT HAS BEEN EATEN
    INC HL
    EX DE, HL   ; SAVE VRAM PTR IN DE
    ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    LD H, hiByte(mazeEatenMutatedTbl)
    SUB A, B                ; SUBTRACT MUTATED DOT OFFSET
    ADD A, A                ; MULTIPLY BY 4
    ADD A, A
    LD IY, tileQuadrant     ; ADD QUADRANT NUMBER TO OFFSET
    ADD A, (IY + 0)
    ADD A, A                ; DOUBLE OFFSET (TILES ARE 8 BYTES INSTEAD OF 4)
    JP NC, +
    INC H
+:
    LD L, A
    ; SET INDEX IN BUFFER
    LD A, (HL)              ; GET VALUE AT OFFSET
    LD (tileBuffer + 1), A  ; STORE AS LOW BYTE
    ; SET FLIPPING IN BUFFER
    INC L
    LD B, (HL)
    LD A, (DE)
    XOR A, B    ; XOR WITH FLIP FLAGS OF CURRENT TILE
    LD (tileBuffer + 2), A  ; STORE AS HIGH BYTE
    ; SET OFFSET
    XOR A
    LD (tileBuffer), A
    ; SET COUNT
    INC A   ; $01
    LD (tileBufferCount), A
    ; SET PAC-MAN'S DOT DELAY TIMER
    LD A, $03
    LD (pacPelletTimer), A
    ; UPDATE TILEMAP IN VRAM
    LD HL, (tileMapRamPtr)
    LD A, (tileBuffer + 1)
    LD (HL), A
    INC HL
    LD A, (tileBuffer + 2)
    LD (HL), A
    ; ADD TO SCORE
    LD HL, $0050
    CALL addToScore
    ; GENERAL FINISH
    JP @updateCollision
@atPowerDot:
;   A POWER DOT HAS BEEN EATEN
    ; GET UPPER BYTE OF TILE
    INC HL
    LD A, (HL)
    ; DETERMINE WHICH POWER DOT PAC-MAN ATE
    AND A, $E0  ; BITS 7, 6, 5 DETERMINE WHICH POWER DOT WAS EATEN
    ; PUT BITS 7, 6, 5 IN POSITION OF BITS 2, 1, 0
    RLCA
    RLCA
    RLCA
    ; ADD POWER DOT NUMBER TO BASE TABLE ADDRESS TO GET POWER DOT OFFSET WITHIN TABLE
    LD H, hiByte(mazePowTbl)
    LD L, A     ; LOW BYTE IS 0, SO JUST OVERWRITE LOW BYTE
    LD L, (HL)  ; OVERWRITE LOW BYTE AGAIN WITH VALUE AT OFFSET
    ; NOW POINTING TO INFO FOR POWER DOT PAC-MAN IS CURRENTLY ON
    ; GET DOT INFO
    LD B, (HL)      ; SETUP COUNTER FOR LOOP
    LD C, $FF       ; COUNTERACT LDI's DECREMENT
    LD DE, tileBufferCount
    LDI ; COPY COUNT
        ; GET ROW AND COL OF POWER DOT
    LD E, (HL)
    INC HL
    LD D, (HL)
    INC HL
    PUSH HL ; SAVE PDOT TABLE POINTER
    PUSH DE ; SAVE RAM/COL
        ; CALCULATE RAM PTR
    EX DE, HL   ; HL: ROW/COL, DE: N/A
    CALL rowColToRamPtr
    PUSH HL
    POP IX      ; IX = BASE RAM PTR
        ; CALCULATE VRAM PTR
    POP HL  ; GET BACK RAM/COL
    CALL rowColToVramPtr
    LD (tileBufferAddress), HL
        ; GET BACK PDOT TABLE POINTER
    POP HL
    ; PREPARE FOR LOOP
    LD DE, tileBuffer
    ; HL: MAZE DOT POW TABLE POINTER
    ; DE: TILE BUFFER POINTER
-:
    ; SET VRAM OFFSET OF CURRENT TILE IN LIST
    LD A, (HL)
    INC HL
    LD (DE), A
    CP A, $52
    JP C, +
    SUB A, $12  ; $52 - $40 (TILEMAP_WIDTH - VRAM_WIDTH)
    LD (DE), A
    ADD A, $12
+:
    PUSH HL         ; SAVE POSITION OF POW DOT TABLE (NOW POINTING TO QUAD)
    ; ADDRESS OF QUAD IS ON STACK
    ; ADD OFFSET TO BASE RAM PTR
    PUSH IX
    POP HL      ; HL = BASE RAM PTR
    addToHL_M
    LD A, (HL)
    PUSH HL
    POP IY      ; IY = (BASE + OFFSET ADDRESS) IN RAM TILEMAP
    INC HL
    LD C, (HL)  ; HIGH BYTE: FLIP FLAGS, ETC
    ; JUMP IF TILE HAS MUTATED DOTS
    LD HL, mazeMutatedTbl
    CP A, (HL)
    JP NC, @@mutatedDot
@@normalDot:
    POP HL      ; RESTORE POW DOT TABLE ADDRESS (POINTING TO QUAD)
    PUSH HL     ; SAVE BACK ONTO STACK (QUAD ADDRESS)
    ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    ADD A, A    ; MULTIPLY BY 4 (EVERY TILE IS 4 BYTES LONG)
    ADD A, A
    ADD A, (HL) ; ADD QUADRANT NUMBER TO OFFSET (DETERMINES WHICH AREA PAC-MAN INTERACTED WITH)
    ; ADD OFFSET TO BASE TABLE
    LD H, hibyte(mazeEatenTbl)  ; LOAD BASE TABLE ADDRESS AND SET LOW BYTE TO OFFSET
    LD L, A
    ; SET INDEX IN BUFFER
    LD A, (HL)  ; GET VALUE AT OFFSET
    LD L, A     ; SAVE IN L FOR LATER
    AND A, $3F  ; REMOVE FLIP BITS
    INC DE      ; POINT TO LOW BYTE OF TILE IN TILE BUFFER
    LD (DE), A      ; STORE AS LOW BYTE
    LD (IY + 0), A
    ; SET FLIPPING IN BUFFER
    LD A, L     ; GET ORIGINAL VALUE
    ; PUT FLIP FLAGS (BIT 6, 7) IN SAME SPOT AS VRAM (BIT 1, 2)
    RLCA
    RLCA
    RLCA
    AND A, $06  ; CLEAR ALL BITS EXCEPT FLIP FLAGS
    XOR A, C    ; XOR WITH FLIP FLAGS OF CURRENT TILE
    INC DE      ; POINT TO HIGH BYTE OF TILE IN TILE BUFFER
    LD (DE), A  ; STORE AS HIGH BYTE
    LD (IY + 1), A
    JP @@prepNextLoop
@@mutatedDot:
    SUB A, (HL)
        ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    POP HL      ; RESTORE POW DOT TABLE ADDRESS (POINTING TO QUAD)
    PUSH HL     ; SAVE BACK ONTO STACK (QUAD ADDRESS)
    ADD A, A    ; MULTIPLY BY 4 (EVERY TILE IS 4 BYTES LONG)
    ADD A, A
    ADD A, (HL) ; ADD QUADRANT NUMBER TO OFFSET (DETERMINES WHICH AREA PAC-MAN INTERACTED WITH)
        ; ADD OFFSET TO BASE TABLE
    LD H, hibyte(mazeEatenMutatedTbl)  ; LOAD BASE TABLE ADDRESS AND SET LOW BYTE TO OFFSET
    ADD A, A
    JP NC, +
    INC H
+:
    LD L, A
        ; SET INDEX IN BUFFER
    LD A, (HL)
    INC DE
    LD (DE), A
    LD (IY + 0), A
        ; SET FLIPPING IN BUFFER
    INC HL
    LD A, (HL)
    XOR A, C
    INC DE
    LD (DE), A
    LD (IY + 1), A
@@prepNextLoop:
    ; PREPARE FOR NEXT LOOP
    INC DE      ; POINT TO VRAM OFFSET FOR NEXT TILE IN LIST
    POP HL      ; RESTORE QUAD ADDRESS BACK INTO HL
    INC L       ; NOW POINTING TO VRAM OFFSET OF NEXT TILE IN LIST
    DJNZ -      ; KEEP GOING IF COUNT IS NOT 0
;   PREPARE FOR SUPER MODE
    ; SET PAC-MAN'S DOT DELAY TIMER
    LD A, $06
    LD (pacPelletTimer), A
    ; SET POWER DOT'S TIME
    LD HL, (powDotTime)
    LD (mainTimer1), HL
    ; ADD TO SCORE
    LD HL, $0050
    CALL addToScore
    ; RESET FLASH COUNTER AND POINT INDEX
    XOR A
    LD (flashCounter), A
    LD (ghostPointIndex), A
    ; SWITCH STATE TO SUPER
    INC A
    LD (pacPoweredUp), A
    ; NOTIFY ACTORS
    CALL pacGameTrans_super
    LD IX, blinky
    CALL ghostGameTrans_super
    LD IX, pinky
    CALL ghostGameTrans_super
    LD IX, inky
    CALL ghostGameTrans_super
    LD IX, clyde
    CALL ghostGameTrans_super
    ; CHECK IF GAME IS PLUS
    LD HL, plusBitFlags
    BIT PLUS, (HL)
    CALL NZ, plus_powerDotRNG   ; IF SO, DO SOMETHING RANDOM
@updateCollision:
    ; UPDATE MAZE COLLISION
    ; OFFSET = X_TILE + (Y_TILE * 32)
    LD A, (pacman + CURR_Y)
    SUB A, $21
    LD L, A
    ; MULTIPLY BY EITHER 16 (PAC/MS.) OR 29 (JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, +
    LD H, $00
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    JP @addX
+:
    multBy29
@addX:
    ; ADD X TILE TO OFFSET
    LD A, (pacman + CURR_X)
    SUB A, $1E
    LD E, A ; EVEN/ODD FLAG
    RRA     ; DIVIDE BY 2 (NIBBLE FORMAT)
    addToHL_M
    ; ADD INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeGroup1.collMap
    ADD HL, BC
    ; CLEAR UPPER OR LOWER NIBBLE, DEPENDING ON EVEN OR ODD
    BIT 0, E
    LD A, $FC   ; ASSUME CLEARING LOWER NIBBLE (ODD)
    JP NZ, +    ; IF IT IS ODD, SKIP..
    LD A, $CF   ; ELSE, CLEAR UPPER NIBBLE
+:
    AND A, (HL)
    LD (HL), A
    ; UPDATE COLLISION TILE FOR PAC-MAN
    BIT 0, E
    JP NZ, +    ; JUMP IF ODD
    ; SET ID TO HIGH NIBBLE
    AND A, $F0  ; CLEAR LOWER NIBBLE
    RRCA        ; SHIFT TO LOW
    RRCA
    RRCA
    RRCA
+:
    ; REMOVE HIGH NIBBLE (ONLY FOR IF X WAS EVEN)
    AND A, $0F
    LD (pacman + CURR_ID), A
    ; SET TILE BUFFER FLAG
    LD A, $01
    LD (tileBufferFlag), A
    ; UPDATE PLAYER'S DOT COUNT
    CALL updatePlayerDotCount
    ; UPDATE GHOSTS' DOT COUNTERS (IF NECESSARY)
    CALL ghostUpdateDotCounters
    ; PLAY DOT EATEN SFX
    LD HL, ch2SoundControl
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    ;   JR.PAC PROCESS
    SET 0, (HL)
    RES 1, (HL)
    LD A, (pacPelletTimer)
    SRL A
    RET Z
    RES 0, (HL)
    SET 1, (HL)
    RET
+:
    ; PLAY DOT EATEN SFX
    LD A, (currPlayerInfo.dotCount)
    RRCA    ; PLAY DIFFERENT SOUND DEPENDING ON ODD/EVEN DOT COUNT
    JP C, +
    SET 0, (HL)
    RES 1, (HL)
    RET
+:
    RES 0, (HL)
    SET 1, (HL)
    RET




/*
    INFO: UPDATES SUPER TIMER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL, IX
*/

superTimerUpdate:
;   CHECK IF ALL GHOSTS ARE EATEN
    LD IX, blinky + EDIBLE_FLAG + (_sizeof_ghost * 3 - $7F)
    LD A, (IX - (_sizeof_ghost * 3 - $7F))
    OR A, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost)
    OR A, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost + _sizeof_ghost)
    OR A, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost + _sizeof_ghost + _sizeof_ghost)
    JP Z, + ; IF ALL GHOSTS ARE NOT SCARED. EXIT OUT OF SUPER MODE
;   UPDATE POWER DOT TIMER
    ; DECREMENT TIMER
    LD HL, (mainTimer1)
    DEC HL
    LD (mainTimer1), HL
    ; CHECK IF 0
    LD A, L
    OR A, H
    RET NZ  ; IF NOT, EXIT
+:
;   NOTIFY ACTORS
    CALL pacGameTrans_normal
    LD IX, blinky
    CALL ghostGameTrans_normal
    LD IX, pinky
    CALL ghostGameTrans_normal
    LD IX, inky
    CALL ghostGameTrans_normal
    LD IX, clyde
    CALL ghostGameTrans_normal
;   SWITCH TO NORMAL
    XOR A
    LD (pacPoweredUp), A
    INC A
    LD (isNewState), A
;   TURN OFF GHOST FLASH
    LD HL, flashCounter
    RES 5, (HL)
    RET



/*
    INFO: CHECKS IF ALL DOTS IN THE MAZE ARE EATEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
allDotsEatenCheck:
.IF RACK_ADV != $00
    POP HL      ; REMOVE FUNCTION CALLER FROM STACK
    LD HL, $01 * $100 + GAMEPLAY_COMP00
    LD (subGameMode), HL
    RET
.ELSE
    LD L, $F4   ; DOT AMOUNT FOR PAC-MAN (ASSUME GAME IS PAC-MAN)
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    RRCA
    RRCA
    JP C, @msCheck
;   CHECK IF GAME IS JR. PAC
    RRCA
    JP C, @jrCheck
@pacCheck:
;   CHECK IF DOTS EATEN COUNTER MATCHES MAZE AMOUNT
    LD A, (currPlayerInfo.dotCount)
    CP A, L
    RET NZ      ; IF NOT, LEVEL ISN'T COMPLETE, EXIT
@lvlDone:
;   ELSE, SET MODE TO FIRST LEVEL COMPLETE STATE
    POP HL      ; REMOVE FUNCTION CALLER FROM STACK
    LD HL, $01 * $100 + GAMEPLAY_COMP00
    LD (subGameMode), HL
    RET
@msCheck:
;   GET DOT COUNT FOR CURRENT LEVEL
    LD HL, msMazeDotCounts
    CALL getMazeIndex   ; L = DOT COUNT FOR CURRENT MAZE
    JP @pacCheck
@jrCheck:
    LD HL, jrMazeDotCounts
    CALL jrGetMazeIndex
    EX DE, HL
    LD HL, (currPlayerInfo.jrDotCount)
    OR A
    SBC HL, DE
    RET NZ
    JP @lvlDone
.ENDIF



/*
    INFO: UPDATE PLAYER'S DOT COUNTER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
updatePlayerDotCount:
;   CHECK IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @incNormalDot ; IF NOT, JUST INCREMENT NORMAL DOT COUNT
;   INCREMENT JR DOT COUNT
    LD HL, (currPlayerInfo.jrDotCount)
    INC HL
    LD (currPlayerInfo.jrDotCount), HL
;   CHECK IF JR DOT COUNT IS ODD
    RRC L
    RET NC  ; IF NOT, END
;   CHECK IF NORMAL DOT COUNT == $F4
    LD A, (currPlayerInfo.dotCount)
    CP A, $F4
    RET Z   ; IF SO, END
;   ELSE, ALSO INCREMENT NORMAL DOT COUNT
@incNormalDot:
    LD HL, currPlayerInfo.dotCount
    INC (HL)
    RET




/*
    INFO: UPDATES SCROLL RELATED VARS SUCH AS...
        SCROLL, LEFT-MOST TILE, OFFSCREEN FLAGS, ETC
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
;   $28 <-> $00 <-> $D8
updateJRScroll:
    ; CHANGE BANK FOR TABLES
    LD A, JR_TABLES_BANK
    LD (MAPPER_SLOT2), A
;   UPDATE REAL SCROLL VALUE
    ; NEW TO OLD
    LD A, (jrScrollReal)
    LD (jrOldScrollReal), A
    ; SCALE PAC-MAN'S POS TO 3/4 USING TABLE
        ; POS -> INDEX
    LD A, (pacman + X_WHOLE)
    LD L, A
    LD A, (pacman + X_WHOLE + 1)
    LD H, A
    ADD HL, HL
        ; ADD HIGH BYTES
    LD A, H
    ADD A, hibyte(jrScaleTable)
    LD H, A
        ; GET VALUE
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; GET NEW SCROLL VALUE FROM TABLE
    LD A, H
    ADD A, hiByte(jrRealScrollTable)
    LD H, A
    LD A, (HL)
    LD (jrScrollReal), A
;   UPDATE LEFT MOST TILE (FROM TABLE)
    LD H, hibyte(jrLeftTileTable)
    LD L, A
    LD A, (HL)
    LD (jrLeftMostTile), A
@cutsceneJump:
;   UPDATE CAMERA POS
    LD A, (jrScrollReal)
    LD B, A
    LD A, $28   ; MAX SCROLL
    SUB A, B
    LD (jrCameraPos), A
;   UPDATE ACTOR OFFSCREEN FLAGS
    LD B, $00   ; FLAG TO SET REVERSE FLAG IN OFFSCREEN ROUTINE
    LD IX, blinky
    CALL actorOffScreenCheck
    LD IX, pinky
    CALL actorOffScreenCheck
    LD IX, inky
    CALL actorOffScreenCheck
    LD IX, clyde
    CALL actorOffScreenCheck
    ; UPDATE FRUIT'S OFFSCREEN FLAG IF ITS ACTIVE
    LD A, (fruit + Y_WHOLE)
    OR A
    JP Z, + ; IF NOT, SKIP
    LD B, $01   ; DON'T TOUCH REVERSE FLAG (FRUIT DOESN'T HAVE ONE)
    LD IX, fruit
    CALL actorOffScreenCheck
+:
    ; REVERT BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   DETERMINE WHICH COLUMN TO UPDATE
    LD A, (jrScrollReal)
    ADD A, $02
    AND A, $F8  ; ADD OFFSET THAN ROUND DOWN TO CLOSEST MULT OF 8
    NEG
    RRCA
    RRCA
    RRCA
    AND A, $1F
    LD (jrColumnToUpdate), A
;   UPDATE SCROLL FLAG
    LD A, (jrScrollReal)
    LD B, A
    LD A, (jrOldScrollReal)
    XOR A, B
    AND A, $F8
    RET Z
    LD A, $01
    LD (updateColFlag), A
    RET



/*
    INFO: REMOVES ALL MUTATED DOTS FROM COLLISION MAP & TILE MAP
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
removeMDots:
;   REMOVE MUTATED DOTS FROM COLLISION MAP
    LD HL, mazeGroup1.collMap
    LD BC, _sizeof_mazeGroup1.collMap
-:
    ; CLEAR BITS 2 & 3 OF EACH NIBBLE
    LD A, (HL)
    AND A, $33
    LD (HL), A
    INC HL
    DEC BC
    LD A, B
    OR A, C
    JP NZ, -
;   REMOVE MUTATED DOTS FROM TILE MAP
    LD HL, mazeGroup1.tileMap
    LD D, hibyte(mazeRstMutatedTbl)
    LD IX, _sizeof_mazeGroup1.tileMap >> $01
    LD BC, (mazeMutatedTbl)
-:
    LD A, (HL)
    CP A, B
    JP NC, +
    CP A, C
    JP C, +
    SUB A, C
    ADD A, $40
    LD E, A
    LD A, (DE)
    LD (HL), A
+:
    INC HL
    INC HL
    DEC IX
    LD A, IXH
    OR A, IXL
    JP NZ, -
;   CLEAR VBLANK FLAG
    XOR A
    LD (vblankFlag), A
    RET
    