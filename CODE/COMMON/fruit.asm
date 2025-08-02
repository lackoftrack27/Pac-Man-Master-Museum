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
    JR NZ, +
;   CHECK IF PAC-MAN HAS EATEN FRUIT (PAC-MAN)
    LD HL, (pacman.xPos)    ; YX
    LD DE, (fruitPos)
    OR A    ; CLEAR CARRY
    SBC HL, DE
    RET NZ  ; IF NOT, END
@ateFruit:
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
+:
;   COMPARE PAC-MAN'S POSITION TO MOVING FRUIT'S
    LD HL, (pacman.xPos)
    LD DE, (fruitPos)
    ; CHECK Y
    LD A, H
    SUB A, D
    ADD A, $03
    CP A, $06
    RET NC  ; IF NOT WITHIN RANGE, EXIT
    ; CHECK X
    LD A, L
    SUB A, E
    ADD A, $03
    CP A, $06
    RET NC  ; IF NOT WITHIN RANGE, EXIT
;   CENTER Y POS WITHIN MAZE WALLS (FOR SCORE)
    LD A, D
    AND A, ~$07
    ADD A, $04
    LD (fruitPos + 1), A
;   FINISH UP (SCORE, TIMER, ETC)
    JR checkEatenFruit@ateFruit



/*
    INFO: UPDATES FRUIT IN MAZE
        IF LOW NIBBLE IS 0: 
            IF HIGH NIBBLE IS 0: CHECK FIRST DOT COUNT. IF PASSED, INCREMENT NIBBLE
            ELSE, CHECK SECOND DOT COUNT. IF PASSED, INCREMENT NIBBLE
        IF LOW LIBBLE IS 1: 
            DECREMENT COUNTER. IF 0, TOGGLE BIT 4 AND RESET LOW NIBBLE AND END
            ELSE, CHECK IF PAC-MAN IS EATING FRUIT. IF SO, INCREMENT NIBBLE
        IF LOW NIBBLE IS 2:
            DECREMENT COUNTER. IF 0, TOGGLE BIT 4 AND RESET LOW NIBBLE AND END

    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
fruitUpdate:
;   DON'T UPDATE DURING EAT
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, msFruitUpdate    ; IF SO, SKIP
;   CHECK IF FRUIT OR FRUIT POINTS ARE ACTIVE (ON SCREEN)
    LD HL, currPlayerInfo.fruitStatus
    LD A, $0F
    AND A, (HL)         ; CHECK IF LOW NIBBLE IS 0
    JR Z, @dotCheck     ; IF SO, SKIP...
;   FRUIT (1) OR POINTS (2) ARE ON SCREEN
@updateFruitTimer:
    ; DECREMENT FRUIT TIMER
    LD DE, (mainTimer3)
    DEC DE
    LD (mainTimer3), DE
    ; CHECK IF 0
    LD A, D
    OR A, E
    RET NZ  ; IF NOT, END
;   TIMER HAS EXPIRED
@timerExpired:
    ; TOGGLE BIT 4 AND CLEAR LOWER NIBBLE
    LD A, $10
    XOR A, (HL)
    AND A, $F0
    LD (HL), A
    ; CLEAR FRUIT POSITION
    LD HL, $0000
    LD (fruitPos), HL
    RET
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
    ; FRUIT POSITION
    LD HL, $9480
    LD (fruitPos), HL
    ; SET TIMER FOR 10 SECONDS
    LD HL, FRUIT_TIME
    LD (mainTimer3), HL
    RET
;   ----------------------------------
;       MS. PAC-MAN FRUIT CODE
;   ----------------------------------
msFruitUpdate:
;   CHECK IF FRUIT OR FRUIT POINTS ARE ACTIVE (ON SCREEN)
    LD HL, currPlayerInfo.fruitStatus
    LD A, $0F
    AND A, (HL) ; CHECK IF LOW NIBBLE IS 0
    JR Z, @dotCheck    ; IF SO, SKIP...
    DEC A   ; CHECK IF LOW NIBBLE WAS 1
    JR Z, @moveFruit    ; IF SO, SKIP...
;   POINTS (2) IS ON SCREEN
    JR fruitUpdate@updateFruitTimer
;   FRUIT (1) IS ON SCREEN
@moveFruit:
    ; GET BOUNCE OFFSET
    LD A, (fruitPathBounce)
    ADD A, A
    LD HL, fruitBounceFrames
    RST addToHL
    RST getDataAtHL
    ; ADD TO FRUIT POSITION
    LD DE, (fruitPos)
    ADD HL, DE
    LD (fruitPos), HL
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
    LD E, (HL)  ; X
    INC HL
    LD D, (HL)  ; Y
    LD (fruitPos), DE
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
    LD A, (fruitPos)
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