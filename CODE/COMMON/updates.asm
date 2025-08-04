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
    CALL ghostUpdateDeadState
;   UPDATE GHOSTS THAT ARE GOING HOME
    CALL ghostToHomeUpdate
;   GHOST POINTS UPDATE (SHOW / REMOVE) IF POINTS ARE SHOWING, END AFTER
    LD A, (ghostPointSprNum)
    OR A
    JR NZ, eatModeUpdate
;   COLLISION CHECK BETWEEN PAC-MAN AND GHOSTS
    CALL globalCollCheck
    CALL globalCollCheck02  ; SECOND CHECK WHICH ONLY APPLIES DURING SUPER MODE
    ; EXIT IF COLLISION OCCURED
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   GET PLAYER INPUT
    CALL getInput
;   UPDATE PAC-MAN
    LD HL, pacStateTable@update
    LD A, (pacman.state)
    RST jumpTableExec
;   UPDATE MAZE (IF NEEDED)
    ;CALL mazeUpdate
;   UPDATE ALL GHOSTS (THAT ARE OUTSIDE OF HOME)
    CALL ghostOutHomeUpdate
;   CONTROL SUPER TIMER (ONLY IN SUPER MODE)
    CALL superTimerUpdate
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
    JR NZ, @update
@enter:
;   SET TIMER
    LD A, EAT_TIMER_LEN
    LD (mainTimer0), A
;   INCREASE SCORE
    LD A, (ghostPointIndex) ; CONVERT INDEX TO OFFSET
    ADD A, A
    LD HL, ghostScoreTable  ; ADD TO SCORE TABLE
    RST addToHL
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
    ; REST OF PLAYER 2
    IN A, CONTROLPORT2
    CPL
    LD (controlPort2), A
;   SET UP PORTS
    LD A, (controlPort1)
    LD B, A
    LD A, (controlPort2)
    LD C, A
;   CHECK WHICH PLAYER IS PLAYING
    LD A, (playerType)
    BIT 1, A
    JR NZ, +    ; IF PLAYER 2, SKIP...
;   GET INPUTS FROM PLAYER 1 (LEFT, RIGHT, UP, DOWN)
    ; ASSUME LEFT IS PRESSED
    LD A, DIR_LEFT
    BIT 2, B    
    JR NZ, @setWanted ; IF SO, SET WANTED DIR TO LEFT
    ; ASSUME RIGHT...
    LD A, DIR_RIGHT
    BIT 3, B
    JR NZ, @setWanted
    ; ASSUME UP...
    LD A, DIR_UP
    BIT 0, B
    JR NZ, @setWanted
    ; ASSUME DOWN...
    LD A, DIR_DOWN
    BIT 1, B
    JR NZ, @setWanted
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
    JR NZ, @setWanted ; IF SO, SET WANTED DIR TO LEFT
    ; ASSUME RIGHT...
    LD A, DIR_RIGHT
    BIT 1, C
    JR NZ, @setWanted
    ; ASSUME UP...
    LD A, DIR_UP
    BIT 6, B
    JR NZ, @setWanted
    ; ASSUME DOWN...
    LD A, DIR_DOWN
    BIT 7, B
    JR NZ, @setWanted
    ; NO DIRECTION WAS PRESSED
    JR @noDir




/*
    INFO: ADDS A BCD NUMBER TO SCORE
    INPUT: HL - NUMBER TO ADD
    OUTPUT: NONE
    USES: AF, HL, BC, DE, HL
*/
addToScore:
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    RET NZ  ; IF SO, EXIT...
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
;   CHECK IF EXTRA LIFE WAS ALREADY GIVEN
    LD A, (currPlayerInfo.awarded1UPFlag)
    OR A
    JR NZ, @compareHS   ; IF SO, SKIP...
;   CHECK IF CURRENT SCORE IS GREATER OR EQUAL TO THE SCORE REQUIRED TO GET EXTRA LIFE
    ; COMPARE UPPER BYTES
    LD A, (DE)  ; POINTED TO currPlayerInfo.score + 2
    LD B, A
    LD A, (bonusValue + 2)
    CP A, B    
    JR C, +     ; CARRY SET IF SCORE > BONUS
    JR NZ, @compareHS       ; IF NOT EQUAL, SKIP
    ; IF UPPER BYTE IS EQUAL, COMPARE LOWER WORDS
    LD HL, (bonusValue)
    LD BC, (currPlayerInfo.score)
    SBC HL, BC  ; CARRY SET IF SCORE > BONUS (CARRY CLEARED)
    JR Z, +     ; IF SCORE AND BONUS MATCH, GIVE EXTRA LIFE
    JR NC, @compareHS       ; IF SCORE ISN'T GREATER THAN BONUS, SKIP
+:
    ; INCREASE LIFE COUNT
    LD HL, currPlayerInfo.lives
    INC (HL)
    ; SET FLAG ASWELL
    LD HL, currPlayerInfo.awarded1UPFlag
    INC (HL)
@compareHS:
;   COMPARE SCORE TO HIGH SCORE
    ; COMPARE UPPER BYTES
    LD A, (DE)  ; POINTED TO currPlayerInfo.score + 2
    LD B, A
    LD A, (highScore + 2)
    SUB A, B    
    JR C, +     ; CARRY SET IF SCORE > HIGHSCORE
    RET NZ      ; IF NOT EQUAL, RETURN
    ; IF UPPER BYTE IS EQUAL, COMPARE LOWER WORDS
    LD HL, (highScore)
    LD DE, (currPlayerInfo.score)
    SBC HL, DE  ; CARRY SET IF SCORE > HIGHSCORE (CARRY CLEARED)
    RET NC      ; IF SCORE ISN'T GREATER THAN HIGHSCORE, RETURN
+:
;   SET HIGH SCORE TO PLAYER'S SCORE
    LD HL, (currPlayerInfo.score)
    LD (highScore), HL
    LD A, (currPlayerInfo.score + 2)
    LD (highScore + 2), A
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
    JR Z, @smooth   ; IF SO, SKIP
;   CHECK IF FRAME COUNTER IS AT LIMIT
    LD A, POW_DOT_CYCLE_TIMER
    CP A, (HL)
    RET NZ          ; IF NOT, END...
;   RESET FRAME COUNTER
    LD (HL), $00    ; CLEAR FRAME COUNTER
;   CHECK IF FIRST INDEX IS 0
    LD A, (powDotPalette)
    OR A
    JR Z, @refresh  ; IF SO, SKIP
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
    JR Z, @refresh  ; IF SO, SKIP
;   CALCULATE PALETTE FROM TABLE
    LD HL, powDotPalTable
    RST addToHL
    LD DE, powDotPalette
    LD A, (mazePalette + BGPAL_PDOT1)   ; GET MAX COLOR FROM PALETTE
    LD C, A
    LD B, $04
-:
    LD IXH, C
    LD A, (HL)
    OR A
    JR Z, ++
    LD IXH, $00
    ; R
    LD A, C
    AND A, $03
    SUB A, (HL)
    JR NC, +
    XOR A
+:
    OR A, IXH
    LD IXH, A
    ; G
    LD A, C
    RRCA
    RRCA
    AND A, $03
    SUB A, (HL)
    JR NC, +
    XOR A
+:
    RLCA
    RLCA
    OR A, IXH
    LD IXH, A
    ; B
    LD A, C
    RRCA
    RRCA
    RRCA
    RRCA
    AND A, $03
    SUB A, (HL)
    JR NC, +
    XOR A
+:
    RLCA
    RLCA
    RLCA
    RLCA
    OR A, IXH
    LD IXH, A
++:
    ; WRITE TO NEW COLOR TO BUFFER
    LD A, IXH
    LD (DE), A
    ; PREPARE FOR NEXT LOOP
    INC HL
    INC DE
    DJNZ -
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
    LD C, VDPDATA_PORT      ; SET C FOR DATA PORT
    LD HL, (tileMapPointer) ; SET VDP ADDRESS TO TILE'S VRAM LOCATION
    RST setVDPAddress
;   JUMP IF AT POWER DOT
    JR NZ, @atPowerDot    ; JUMP IF POWER DOT WAS ATE (WAS 3, NOW 1)
;   ELSE, A REGULAR DOT WAS ATE (WAS 2, NOW 0)
    ; SET TILE BUFFER ADDRESS
    LD (tileBufferAddress), HL
    ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    LD HL, tileQuadrant     ; GET ADDRESS OF TILE QUAD INTO HL (DONE HERE TO SLOW VDP ACCESS)
    IN A, (C)   ; GET INDEX (ONLY NEED LOWER 8 BITS)
    ADD A, A    ; MULTIPLY BY 4 (EVERY TILE IS 4 BYTES LONG)
    ADD A, A
    ADD A, (HL)    ; ADD QUADRANT NUMBER TO OFFSET (DETERMINES WHICH AREA PAC-MAN INTERACTED WITH)
    ; ADD OFFSET TO BASE TABLE
    LD HL, mazeEatenDotTable    ; LOAD BASE TABLE ADDRESS AND SET LOW BYTE TO OFFSET
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
    IN C, (C)   ; GET FLIPPING IN C
    XOR A, C    ; XOR WITH FLIP FLAGS OF CURRENT TILE
    LD (tileBuffer + 2), A  ; STORE AS HIGH BYTE
    ; SET OFFSET
    XOR A
    LD (tileBuffer), A
    ; SET COUNT
    INC A   ; $01
    LD (tileBufferCount), A
    ; SET PAC-MAN'S DOT DELAY TIMER
    LD (pacPelletTimer), A  ; 0.83333 FOR PAL
    ; ADD TO SCORE
    LD HL, $0010
    CALL addToScore
    ; GENERAL FINISH
    JP @updateCollision
@atPowerDot:
;   A POWER DOT HAS BEEN EATEN
    IN F, (C)   ; SKIP INDEX
    ; SET HL TO BASE ADDRESS OF POWER DOT TABLE (DONE HERE TO SLOW VDP ACCESS)
    LD HL, mazePowDotTable
    NOP
    ; GET TILEMAP INFO AT ADDRESS
    IN A, (C)   ; SAVE FLIPPING IN A
    ; DETERMINE WHICH POWER DOT PAC-MAN ATE
    AND A, $60  ; BITS 6, 5 DETERMINE WHICH POWER DOT WAS EATEN
    ; PUT BITS 6, 5 IN POSITION OF BITS 0, 1
    RLCA
    RLCA
    RLCA
    ; ADD POWER DOT NUMBER TO BASE TABLE ADDRESS TO GET POWER DOT OFFSET WITHIN TABLE
    LD L, A     ; LOW BYTE IS 0, SO JUST OVERWRITE LOW BYTE
    LD L, (HL)  ; OVERWRITE LOW BYTE AGAIN WITH VALUE AT OFFSET
    ; NOW POINTING TO INFO FOR POWER DOT PAC-MAN IS CURRENTLY ON
    ; GET DOT INFO
    LD B, (HL)      ; SETUP COUNTER FOR LOOP
    LD DE, tileBufferCount
    LDI ; COPY COUNT
    LDI ; COPY LOW BYTE OF ABSOLUTE VRAM ADDRESS
    LDI ; COPY HIGH BYTE OF ABSOLUTE VRAM ADDRESS
    ; PREPARE FOR LOOP
    LD DE, tileBuffer
    ; HL: MAZE DOT POW TABLE POINTER
    ; DE: TILE BUFFER POINTER
-:
    ; SET VRAM OFFSET OF CURRENT TILE IN LIST
    LDI             ; COPY VRAM OFFSET TO TILE BUFFER        
    DEC DE          ; POINT BACK TO VRAM OFFSET IN TILE BUFFER
    PUSH HL         ; SAVE POSITION OF POW DOT TABLE (NOW POINTING TO QUAD)
    ; ADDRESS OF QUAD IS ON STACK
    LD C, VDPDATA_PORT
    ; ADD OFFSET TO BASE ADDRESS
    LD HL, (tileBufferAddress)
    LD A, (DE)
    RST addToHL
    RST setVDPAddress
    ; GET TILE INFO
    POP HL      ; RESTORE POW DOT TABLE ADDRESS (POINTING TO QUAD)
    PUSH HL     ; SAVE BACK ONTO STACK (QUAD ADDRESS)
    IN A, (C)   ; GET TILE INDEX
    ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    ADD A, A    ; MULTIPLY BY 4 (EVERY TILE IS 4 BYTES LONG)
    ADD A, A
    ADD A, (HL) ; ADD QUADRANT NUMBER TO OFFSET (DETERMINES WHICH AREA PAC-MAN INTERACTED WITH)
    ; ADD OFFSET TO BASE TABLE
    LD HL, mazeEatenDotTable    ; LOAD BASE TABLE ADDRESS AND SET LOW BYTE TO OFFSET
    LD L, A
    ; SET INDEX IN BUFFER
    LD A, (HL)  ; GET VALUE AT OFFSET
    LD L, A     ; SAVE IN L FOR LATER
    AND A, $3F  ; REMOVE FLIP BITS
    INC DE      ; POINT TO LOW BYTE OF TILE IN TILE BUFFER
    LD (DE), A      ; STORE AS LOW BYTE
    ; SET FLIPPING IN BUFFER
    LD A, L     ; GET ORIGINAL VALUE
    ; PUT FLIP FLAGS (BIT 6, 7) IN SAME SPOT AS VRAM (BIT 1, 2)
    RLCA
    RLCA
    RLCA
    AND A, $06  ; CLEAR ALL BITS EXCEPT FLIP FLAGS
    IN L, (C)   ; GET HORIZONTAL/VERTICAL FLIPPING
    XOR A, L    ; XOR WITH FLIP FLAGS OF CURRENT TILE
    INC DE      ; POINT TO HIGH BYTE OF TILE IN TILE BUFFER
    LD (DE), A  ; STORE AS HIGH BYTE
    ; PREPARE FOR NEXT LOOP
    INC DE      ; POINT TO VRAM OFFSET FOR NEXT TILE IN LIST
    POP HL      ; RESTORE QUAD ADDRESS BACK INTO HL
    INC L       ; NOW POINTING TO VRAM OFFSET OF NEXT TILE IN LIST
    ; COUNTER CHECK
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
    ; CHANGE PAC-MAN'S SPRITE NUMBER
    INC A   ; $01
    LD (pacman.sprTableNum), A
    ; SWITCH STATE TO SUPER
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
    LD H, $00
    ; MULTIPLY Y TILE BY 16 (COLLISION MAP IS 32 TILES HORIZONTAL, 1 TILE PER NIBBLE)
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ; ADD X TILE TO OFFSET
    LD A, (pacman + CURR_X)
    LD B, A
    LD A, $3D
    SUB A, B
    LD E, A ; EVEN/ODD FLAG
    RRA     ; DIVIDE BY 2 (NIBBLE FORMAT)
    RST addToHL
    ; ADD INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeCollisionPtr
    ADD HL, BC
    ; CLEAR UPPER OR LOWER NIBBLE, DEPENDING ON EVEN OR ODD
    BIT 0, E
    LD A, $FC   ; ASSUME CLEARING LOWER NIBBLE (ODD)
    JR NZ, +    ; IF IT IS ODD, SKIP..
    LD A, $CF   ; ELSE, CLEAR UPPER NIBBLE
+:
    AND A, (HL)
    LD (HL), A
    ; UPDATE COLLISION TILE FOR PAC-MAN
    BIT 0, E
    JR NZ, +    ; JUMP IF ODD
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
    ; DECREMENT DOT COUNTER
    LD HL, currPlayerInfo.dotCount
    INC (HL)
    ; UPDATE GHOSTS' DOT COUNTERS (IF NECESSARY)
    CALL ghostUpdateDotCounters
    ; PLAY DOT EATEN SFX
    LD A, (currPlayerInfo.dotCount)
    LD HL, ch2SoundControl
    RRCA    ; PLAY DIFFERENT SOUND DEPENDING ON ODD/EVEN DOT COUNT
    JR C, +
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
;   CHECK IF SUB GAME MODE IS SUPER 
    LD A, (pacPoweredUp)
    OR A
    RET Z   ; IF NOT, EXIT
;   CHECK IF ALL GHOSTS ARE EATEN
    LD IX, blinky + EDIBLE_FLAG + (_sizeof_ghost * 3 - $7F)
    LD A, (IX - (_sizeof_ghost * 3 - $7F))
    OR A, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost)
    OR A, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost + _sizeof_ghost)
    OR A, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost + _sizeof_ghost + _sizeof_ghost)
    JR Z, + ; IF ALL GHOSTS ARE NOT SCARED. EXIT OUT OF SUPER MODE
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
;   CHANGE PAC-MAN'S SPRITE NUMBER
    LD A, 21
    LD (pacman.sprTableNum), A
    RET


