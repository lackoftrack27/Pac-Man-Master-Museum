/*
------------------------------------------------
            FRUIT RELEATED FUNCTIONS
------------------------------------------------
*/


/*
    INFO: CHECK IF PAC-MAN IS EATING A FRUIT
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
checkEatenFruit:
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @msCheck
    BIT JR_PAC, A
    JR NZ, @jrCheck
;   CHECK IF PAC-MAN HAS EATEN FRUIT (PAC-MAN)
    ; X
    LD HL, (pacman.xPos)
    LD A, (pacman.yPos)
    LD H, A
    LD DE, (fruitXPos)
    LD A, (fruitYPos)
    LD D, A
    OR A    ; CLEAR CARRY
    SBC HL, DE
    RET NZ  ; IF NOT, END
@ateFruit:
    ; ADJUST FRUIT POSITION IF GAME IS PAC-MAN
    LD A, (plusBitFlags)
    AND A, $01 << MS_PAC | $01 << JR_PAC | $01 << OTTO
    JR NZ, +
    LD A, (fruitXPos)
    ADD A, $02
    LD (fruitXPos), A
+:
    ; SET LOW NIBBLE TO 2 (FRUIT POINTS)
    LD HL, currPlayerInfo.fruitStatus
    INC (HL)
    ; SET TIMER FOR 2 SECONDS
    LD HL, POINT_TIME
    LD (mainTimer3), HL
    ; PLAY SOUND
    LD HL, ch2SoundControl
    SET 2, (HL)
    ; PAC-MAN PLUS CODE (SWITCH TO SUPER MODE, HIDE GHOSTS)
    LD HL, plusBitFlags
    BIT PLUS, (HL)
    CALL NZ, plus_fruitSuper
    ; ADD TO SCORE
    LD HL, (fruitScoreVal)
    JP addToScore
@msCheck:
;   COMPARE PAC-MAN'S POSITION TO MOVING FRUIT'S
    ; CHECK X
    LD A, (pacman.xPos)
    LD DE, (fruitXPos)
    SUB A, E
    ADD A, $03
    CP A, $06
    RET NC  ; IF NOT WITHIN RANGE, EXIT
    ; CHECK Y
    LD A, (pacman.yPos)
    LD DE, (fruitYPos)
    SUB A, E
    ADD A, $03
    CP A, $06
    RET NC  ; IF NOT WITHIN RANGE, EXIT
;   CENTER Y POS WITHIN MAZE WALLS (FOR SCORE)
    LD A, E
    AND A, ~$07 ; ROUND DOWN TO CLOSEST MULTIPLE OF 8
    ADD A, $04  ; ALIGN WITHIN MAZE WALLS   
    LD (fruitYPos), A
;   FINISH UP (SCORE, TIMER, ETC)
    JR checkEatenFruit@ateFruit
@jrCheck:
;   COMPARE PAC-MAN'S POSITION TO MOVING FRUIT'S
    ; CHECK X
    LD HL, (pacman.xPos)
    LD DE, (fruitXPos)
    OR A
    SBC HL, DE
    LD DE, $0004
    ADD HL, DE
    LD DE, $0008
    SBC HL, DE
    RET NC  ; IF NOT WITHIN RANGE, EXIT
    ; CHECK Y
    LD A, (pacman.yPos)
    LD DE, (fruitYPos)
    SUB A, E
    ADD A, $04
    CP A, $08
    RET NC  ; IF NOT WITHIN RANGE, EXIT
;   CENTER Y POS WITHIN MAZE WALLS (FOR SCORE)
    LD A, E
    AND A, ~$07 ; ROUND DOWN TO CLOSEST MULTIPLE OF 8
    ADD A, $04  ; ALIGN WITHIN MAZE WALLS   
    LD (fruitYPos), A
;   FINISH UP (SCORE, TIMER, ETC)
    JR checkEatenFruit@ateFruit




/*
    INFO: UPDATES FRUIT IN MAZE
        --------
        DECREMENT FRUIT TIMER IF IT ISN'T 0
        IF TIMER IS 0 AFTER DECREMENT:
            TOGGLE BIT 4 (FRUIT NUMBER) AND RESET LOW NIBBLE, END
        --------
        PAC-MAN:
            IF LOW NIBBLE IS 0:
                IF HIGH NIBBLE IS 0: CHECK FIRST DOT COUNT. IF PASSED, INCREMENT NIBBLE
                ELSE, CHECK SECOND DOT COUNT. IF PASSED, INCREMENT NIBBLE
            IF LOW NIBBLE IS 1: END
            IF LOW NIBBLE IS 2: END
        --------
        MS.PAC-MAN:
            IF LOW NIBBLE IS 0:
                IF HIGH NIBBLE IS 0: CHECK FIRST DOT COUNT. IF PASSED, INCREMENT NIBBLE
                ELSE, CHECK SECOND DOT COUNT. IF PASSED, INCREMENT NIBBLE
            IF LOW NIBBLE IS 1: UPDATE FRUIT MOVEMENT / BOUNCE / ETC
            IF LOW NIBBLE IS 2: END
        --------
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
fruitUpdate:
    LD HL, currPlayerInfo.fruitStatus
;   UPDATE FRUIT TIMER IF IT ISN'T 0
    LD DE, (mainTimer3)
    LD A, E
    OR A, D
    JR Z, + ; SKIP IF 0
    ; DECREMENT TIMER
    DEC DE
    LD (mainTimer3), DE
    LD A, E
    OR A, D
    JR NZ, + ; IF NOT 0, SKIP
@timerExpired:
    ; TOGGLE BIT 4 AND CLEAR LOWER NIBBLE
    LD A, $10
    XOR A, (HL)
    AND A, $F0
    LD (HL), A
    ; CLEAR FRUIT POSITION
    LD HL, $0000
    LD (fruitXPos), HL
    LD (fruitYPos), HL
    RET
+:
;   DON'T UPDATE DURING EAT
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, msFruitUpdate    ; IF SO, SKIP
    BIT JR_PAC, A
    JP NZ, jrFruitUpdate
;   CHECK IF FRUIT AND FRUIT POINTS AREN'T ACTIVE (ON SCREEN)
    LD A, $0F
    AND A, (HL) ; CHECK IF LOW NIBBLE IS 0 (NO FRUIT OR SCORE POINTS)
    RET NZ      ; IF NOT, EXIT
@dotCheck:
;   FRUIT (1) AND POINTS (2) ARE NOT ON SCREEN
    ; PREPARE DOT COUNT TO CHECK FOR
    LD A, 70    ; ASSUME DOT COUNT FOR FIRST FRUIT
    BIT 4, (HL) ; CHECK IF BIT 4 ISN'T SET (IF FIRST FRUIT SHOULD COME)
    JR Z, +     ; IF SO, SKIP...
    LD A, 170   ; ELSE, CHANGE DOT COUNT TO SECOND FRUIT
+:
    LD B, A     ; STORE IN B
    ; CHECK DOT COUNT AGAINST DOTS LEFT IN MAZE
    LD A, (currPlayerInfo.dotCount) ; MARK
    CP A, B
    RET NZ  ; IF NO MATCH, END
    ; SET LOW NIBBLE TO ONE
    INC (HL)
    ; PREPARE FRUIT/POINTS/SCORE
    CALL prepareFruit
    ; SET FIXED FRUIT POSITION
    LD HL, $0080
    LD (fruitXPos), HL
    LD HL, $0094
    LD (fruitYPos), HL
    ; SET TIMER FOR 10 SECONDS
    LD HL, FRUIT_TIME
    LD (mainTimer3), HL
    RET
;   ----------------------------------
;       MS. PAC-MAN FRUIT CODE
;   ----------------------------------
msFruitUpdate:
;   CHECK IF FRUIT OR FRUIT POINTS ARE ACTIVE (ON SCREEN)
    LD A, $0F
    AND A, (HL)     ; CHECK IF LOW NIBBLE IS 0
    JR Z, @dotCheck ; IF SO, FRUIT OR POINTS AREN'T ON SCREEN, CHECK DOT COUNTS
    DEC A           ; CHECK IF LOW NIBBLE WAS 1
    RET NZ          ; IF NOT, END
;   FRUIT (1) IS ON SCREEN
@moveFruit:
    ; GET BOUNCE OFFSET
    LD A, (fruitPathBounce)
    ADD A, A
    LD HL, fruitBounceFrames
    RST addToHL
    RST getDataAtHL
    ; ADD TO FRUIT POSITION
        ; X
    LD A, (fruitXPos)
    ADD A, L
    LD (fruitXPos), A
        ; Y
    LD A, (fruitYPos)
    ADD A, H
    LD (fruitYPos), A
    ; INCREMENT BOUNCE
    LD HL, fruitPathBounce
    INC (HL)
    LD A, (HL)
    AND A, $0F
    RET NZ  ; END IF (BOUNCE & $0F) != 0
    ; CHECK IF PATH IS COMPLETED
    LD HL, fruitPathLen
    DEC (HL)
    JP M, prepNextFruitPath ; IF SO, GET NEXT PATH
    ; SET UP BOUNCE COUNTER [PART 1]
    LD A, (HL)
    LD D, A
    SRL A
    SRL A
    ; PLAY SOUND
    LD HL, ch2SoundControl
    SET 4, (HL)
    ; SET UP BOUNCE COUNTER [PART 2]
    LD HL, (fruitPathPtr)
    RST addToHL
    LD C, A
    LD A, $03
    AND A, D
    JR Z, +
-:
    SRL C
    SRL C
    DEC A
    JR NZ, -
+:
    LD A, $03
    AND A, C
    RLCA
    RLCA
    RLCA
    RLCA
    LD (fruitPathBounce), A
    RET
;   MS. PAC-MAN DOT CHECK FOR FRUIT
@dotCheck:
;   FRUIT (1) AND POINTS (2) ARE NOT ON SCREEN
    ; PREPARE DOT COUNT TO CHECK FOR
    LD A, $40   ; ASSUME DOT COUNT FOR FIRST FRUIT
    BIT 4, (HL) ; CHECK IF BIT 4 ISN'T SET (IF FIRST FRUIT SHOULD COME)
    JR Z, +     ; IF SO, SKIP...
    LD A, $B0   ; ELSE, CHANGE DOT COUNT TO SECOND FRUIT
+:
    LD B, A     ; STORE IN B
    ; CHECK DOT COUNT AGAINST DOTS LEFT IN MAZE
    LD A, (currPlayerInfo.dotCount) ; MARK
    CP A, B
    RET NZ  ; IF NO MATCH, END
    ; SET LOW NIBBLE TO ONE
    INC (HL)
    ; PREPARE FRUIT/POINTS/SCORE
    CALL prepareFruit
    ; SET UP FRUIT ENTRY PATH
    LD HL, msMazeFruitEntries
    CALL setupFruitPath
    ; SET UP STARTING FRUIT POSITION
    INC HL
    LD A, (HL)  ; X
    LD (fruitXPos), A
    INC HL
    LD A, (HL)  ; Y
    LD (fruitYPos), A
    RET

/*
    INFO: PREPARE NEXT PATH FOR FRUIT TO TAKE (MS. PAC-MAN ONLY)
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, B, DE, HL, R
*/
prepNextFruitPath:
;   CHECK IF FRUIT HAS FINISHED PATH (IS NOW OFFSCREEN)
    LD HL, currPlayerInfo.fruitStatus
    LD A, (fruitXPos)
    CP A, $F4   ; EXITED FROM LEFT SIDE
    JP Z, fruitUpdate@timerExpired
    CP A, $0C   ; EXITED FROM RIGHT SIDE
    JP Z, fruitUpdate@timerExpired
;   CHECK IF FRUIT NEEDS TO DO GHOST PATH
    LD HL, (fruitPathPtr)
    LD DE, msMazeGhostPath
    OR A
    SBC HL, DE          ; (CHECK IF PATH POINTER ISN'T ALREADY GHOST PATH)
    JR NZ, doGhostPath  ; IF SO, SKIP...
;   ELSE, FRUIT NEEDS TO DO EXIT PATH
    LD HL, msMazeFruitExits
    ; FALL THROUGH
setupFruitPath:
;   GET MAZE PATHS' ADDR
    CALL getMazeIndex
;   GET A RANDOM VALUE [(R & 3) * 5]
    LD A, R
    AND A, $03
    LD B, A
    ADD A, A
    ADD A, A
    ADD A, B
;   USE THAT AS OFFSET INTO PATHS
    RST addToHL
;   GET PATH POINTER
    LD E, (HL)
    INC HL
    LD D, (HL)
    LD (fruitPathPtr), DE
;   GET PATH LENGTH
    INC HL
    LD A, (HL)
@ghostSkip:
    LD (fruitPathLen), A
;   INITIALIZE BOUNCE
    LD A, $1F
    LD (fruitPathBounce), A
    RET
doGhostPath:
;   SET UP PATH POINTER
    LD HL, msMazeGhostPath
    LD (fruitPathPtr), HL
;   SET UP PATH LENGTH
    LD A, $1D
    JR setupFruitPath@ghostSkip ; FINISH UP


;   ----------------------------------
;       JR. PAC-MAN FRUIT CODE
;   ----------------------------------
jrFruitUpdate:
    RET



/*
    INFO: PREPARE TO RELEASE FRUIT IN LEVEL
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, R
*/
prepareFruit:
;   SET FRUIT TILE DEF POINTER 
    ; CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @msSetFruit  ; IF SO, SETUP FRUIT DIFFERENTLY
    BIT JR_PAC, A
    JR NZ, @jrSetFruit
;   ---------------
;   PAC-MAN FRUIT SETUP
;   ---------------
    ; CHECK IF LEVEL IS 20 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, 20
    JR C, +     ; IF NOT, SKIP
    LD A, 19    ; ELSE, CAP TO 19
+:
    ; USE AS OFFSET INTO FRUIT TABLE
    ADD A, A
    LD HL, fruitTable
    RST addToHL
    ; USE AS OFFSET INTO FRUIT TILE DEF TABLE
    ADD A, A
    ADD A, A
    EX DE, HL   ; DE: FRUIT TABLE PTR (SAVE FOR LATER)
    LD HL, fruitTileDefs
    RST addToHL
    LD (fruitTileDefPtr), HL
;   SET FRUIT POINT TILE DEF. POINTER
    ; GET SCORE INDEX OF CURRENT FRUIT
    EX DE, HL   ; GET BACK FRUIT TABLE PTR
    INC HL
    LD A, (HL)
    ; USE AS OFFSET INTO FRUIT POINT TILE DEF TABLE
    ADD A, A
    ADD A, A
    EX DE, HL   ; DE: FRUIT TABLE PTR (SAVE FOR LATER)
    LD HL, fruitPointTileDefs
    RST addToHL
    LD (fruitPointTDefPtr), HL
;   SET FRUIT POINTS VALUE
    EX DE, HL   ; GET BACK PTR
    LD A, (HL)
    ; USE AS OFFSET INTO FRUIT SCORE TABLE
    ADD A, A
    LD HL, fruitScoreTable
    RST addToHL
    RST getDataAtHL
    LD (fruitScoreVal), HL
    RET
;   ---------------
;   MS. PAC-MAN FRUIT SETUP
;   ---------------
@msSetFruit:
    ; CHECK IF LEVEL IS 7 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $07
    JR C, + ; IF NOT, USE LEVEL NUMBER DIRECTLY
    ; ELSE, PICK A RANDOM FRUIT
    LD B, $07
    LD A, R     ; RANDOMNESS COMES FROM R REGISTER [(R % 32) % 7]
    AND A, $1F
-:
    SUB A, B
    JR NC, -
    ADD A, B
+:
    ; USE AS OFFSET INTO FRUIT TILE DEF TABLE
    ADD A, A
    ADD A, A
    PUSH AF  ; SAVE FRUIT OFFSET
    LD HL, fruitTileDefs
    RST addToHL
    LD (fruitTileDefPtr), HL
;   SET FRUIT POINT TILE DEF. POINTER
    POP AF  ; RESTORE FRUIT OFFSET
    PUSH AF ; PUT BACK ONTO STACK
    LD HL, msFruitPointTileDefs
    RST addToHL
    LD (fruitPointTDefPtr), HL
;   SET FRUIT POINTS VALUE
    POP AF  ; RESTORE FRUIT OFFSET
    SRL A   ; DIVIDE BY 2
    LD HL, msFruitScoreTable
    RST addToHL
    RST getDataAtHL
    LD (fruitScoreVal), HL
    RET
;   ---------------
;   JR. PAC-MAN FRUIT SETUP
;   ---------------
@jrSetFruit:
    RET
