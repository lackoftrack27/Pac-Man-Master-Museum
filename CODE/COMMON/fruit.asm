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
;   EACH GAME CHECKS DIFFERENTLY
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS.PAC
    JP C, @msCheck
    RRCA    ; JR.PAC
    JP C, @jrCheck
;   ----------------------------------
;   PAC-MAN FRUIT X-ING PLAYER CODE
;   ----------------------------------
;   CHECK IF PAC-MAN HAS EATEN FRUIT (PAC-MAN)
    ; X
    LD HL, (pacman.xPos)
    LD A, (pacman.yPos)
    LD H, A
    LD DE, (fruit + X_WHOLE)
    LD A, (fruit + Y_WHOLE)
    LD D, A
    OR A    ; CLEAR CARRY
    SBC HL, DE
    RET NZ  ; IF NOT, END
@ateFruit:
    ; ADJUST FRUIT POSITION IF GAME IS PAC-MAN
    LD A, (plusBitFlags)
    AND A, $01 << MS_PAC | $01 << JR_PAC | $01 << OTTO
    JP NZ, +
    LD HL, fruit + X_WHOLE
    INC (HL)
    INC (HL)
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
;   ----------------------------------
;   MS.PAC-MAN FRUIT X-ING PLAYER CODE
;   ----------------------------------
@msCheck:
;   COMPARE PAC-MAN'S POSITION TO MOVING FRUIT'S
    ; CHECK X
    LD A, (pacman.xPos)
    LD DE, (fruit + X_WHOLE)
    SUB A, E
    ADD A, $03
    CP A, $06
    RET NC  ; IF NOT WITHIN RANGE, EXIT
    ; CHECK Y
    LD A, (pacman.yPos)
    LD DE, (fruit + Y_WHOLE)
    SUB A, E
    ADD A, $03
    CP A, $06
    RET NC  ; IF NOT WITHIN RANGE, EXIT
;   CENTER Y POS WITHIN MAZE WALLS (FOR SCORE)
    LD A, E
    AND A, ~$07 ; ROUND DOWN TO CLOSEST MULTIPLE OF 8
    ADD A, $04  ; ALIGN WITHIN MAZE WALLS   
    LD (fruit + Y_WHOLE), A
;   FINISH UP (SCORE, TIMER, ETC)
    JP checkEatenFruit@ateFruit
;   ----------------------------------
;   JR.PAC-MAN FRUIT X-ING PLAYER CODE
;   ----------------------------------
@jrCheck:
;   COMPARE PAC-MAN'S POSITION TO MOVING FRUIT'S
    ; CHECK X
    LD HL, (pacman.xPos)
    LD DE, (fruit + X_WHOLE)
    OR A
    SBC HL, DE
    LD DE, $0004
    ADD HL, DE
    LD DE, $0008
    SBC HL, DE
    RET NC  ; IF NOT WITHIN RANGE, EXIT
    ; CHECK Y
    LD A, (pacman.yPos)
    LD DE, (fruit + Y_WHOLE)
    SUB A, E
    ADD A, $04
    CP A, $08
    RET NC  ; IF NOT WITHIN RANGE, EXIT
;   CENTER Y POS WITHIN MAZE WALLS (FOR SCORE)
    LD A, E
    AND A, ~$07 ; ROUND DOWN TO CLOSEST MULTIPLE OF 8
    ADD A, $04  ; ALIGN WITHIN MAZE WALLS   
    LD (fruit + Y_WHOLE), A
;   FINISH UP (SCORE, TIMER, ETC)
    JP checkEatenFruit@ateFruit




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
    JP Z, + ; SKIP IF 0
    ; DECREMENT TIMER
    DEC DE
    LD (mainTimer3), DE
    LD A, E
    OR A, D
    JP NZ, + ; IF NOT 0, SKIP
@timerExpired:
    ; CLEAR LOWER NIBBLE
    LD A, (HL)
    AND A, $F0
    LD (HL), A
    ; CLEAR FRUIT POSITION
    XOR A
    LD H, A
    LD L, A
    LD (fruit + X_WHOLE), HL
    LD (fruit + Y_WHOLE), HL
    ; SET OFFSCREEN FLAG
    INC A
    LD (fruit + OFFSCREEN_FLAG), A
    RET
+:
;   DO EXPLOSION REGARDLESS IF EATING
    LD A, (fruit + STATE)
    CP A, $06
    JP Z, fruitState6
;   DON'T UPDATE DURING EAT
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   DIFFERENT MAIN UPDATES DEPENDING ON GAME
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS.PAC
    JP C, msFruitUpdate
    RRCA    ; JR.PAC
    JP C, jrFruitUpdate
;   ----------------------------------
;           PAC-MAN FRUIT CODE
;   ----------------------------------
;   CHECK IF FRUIT AND FRUIT POINTS AREN'T ACTIVE (ON SCREEN)
    LD A, $0F
    AND A, (HL) ; CHECK IF LOW NIBBLE IS 0 (NO FRUIT OR SCORE POINTS)
    RET NZ      ; IF NOT, EXIT
@dotCheck:
;   FRUIT (1) AND POINTS (2) ARE NOT ON SCREEN
    LD A, (currPlayerInfo.dotCount)
;   DOT COUNT 1 CHECK
    CP A, $46
    JP NZ, +
    ; EXIT IF FLAG IS ALREADY SET
    BIT 4, (HL)
    RET NZ
    ; SET FLAG
    LD A, $10
    JP @@countMatch
+:
;   DOT COUNT 2 CHECK
    CP A, $AA
    RET NZ
    ; EXIT IF FLAG IS ALREADY SET
    BIT 5, (HL)
    RET NZ
    ; SET FLAG
    LD A, $20
@@countMatch:
    OR A, (HL)
    LD (HL), A
    ; SET LOW NIBBLE TO ONE
    INC (HL)
    ; PREPARE FRUIT/POINTS/SCORE
    CALL prepareFruit
    ; SET FIXED FRUIT POSITION
    LD HL, $0080
    LD (fruit + X_WHOLE), HL
    LD HL, $0094
    LD (fruit + Y_WHOLE), HL
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
    JP Z, @dotCheck ; IF SO, FRUIT OR POINTS AREN'T ON SCREEN, CHECK DOT COUNTS
    DEC A           ; CHECK IF LOW NIBBLE WAS 1
    RET NZ          ; IF NOT, END
@moveFruit:
;   FRUIT (1) IS ON SCREEN
    ; GET BOUNCE OFFSET
    LD A, (fruitPathBounce)
    ADD A, A
    LD HL, fruitBounceFrames
    RST addToHL
    RST getDataAtHL
    ; ADD TO FRUIT POSITION
        ; X
    LD A, (fruit + X_WHOLE)
    ADD A, L
    LD (fruit + X_WHOLE), A
        ; Y
    LD A, (fruit + Y_WHOLE)
    ADD A, H
    LD (fruit + Y_WHOLE), A
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
    JP Z, +
-:
    SRL C
    SRL C
    DEC A
    JP NZ, -
+:
    LD A, $03
    AND A, C
    RLCA
    RLCA
    RLCA
    RLCA
    LD (fruitPathBounce), A
    RET
@dotCheck:
;   FRUIT (1) AND POINTS (2) ARE NOT ON SCREEN
    LD A, (currPlayerInfo.dotCount)
;   DOT COUNT 1 CHECK
    CP A, $40
    JP NZ, +
    ; EXIT IF FLAG IS ALREADY SET
    BIT 4, (HL)
    RET NZ
    ; SET FLAG
    LD A, $10
    JP @@countMatch
+:
;   DOT COUNT 2 CHECK
    CP A, $B0
    RET NZ
    ; EXIT IF FLAG IS ALREADY SET
    BIT 5, (HL)
    RET NZ
    ; SET FLAG
    LD A, $20
@@countMatch:
    OR A, (HL)
    LD (HL), A
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
    LD (fruit + X_WHOLE), A
    INC HL
    LD A, (HL)  ; Y
    LD (fruit + Y_WHOLE), A
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
    LD A, (fruit + X_WHOLE)
    CP A, $F4   ; EXITED FROM LEFT SIDE
    JP Z, fruitUpdate@timerExpired
    CP A, $0C   ; EXITED FROM RIGHT SIDE
    JP Z, fruitUpdate@timerExpired
;   CHECK IF FRUIT NEEDS TO DO GHOST PATH
    LD HL, (fruitPathPtr)
    LD DE, msMazeGhostPath
    OR A
    SBC HL, DE          ; (CHECK IF PATH POINTER ISN'T ALREADY GHOST PATH)
    JP NZ, doGhostPath  ; IF SO, SKIP...
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
    JP setupFruitPath@ghostSkip ; FINISH UP


;   ----------------------------------
;       JR. PAC-MAN FRUIT CODE
;   ----------------------------------
jrFruitUpdate:
;   CHECK IF FRUIT IS ONSCREEN
    LD A, (fruit + Y_WHOLE)
    OR A
    JP NZ, @moveFruit   ; IF SO, UPDATE ITS MOVEMENT
;   CHECK 
    BIT 0, (HL)
    JP Z, @dotCheck
;   RELEASE FRUIT
    ; PREPARE FRUIT/POINTS/SCORE
    CALL prepareFruit
    ; SET FRUIT POSITION
    LD HL, $00E8
    LD (fruit + X_WHOLE), HL
    LD HL, $005C
    LD (fruit + Y_WHOLE), HL    
    ; SET STATE TO 1
    LD A, $01
    LD (fruit + STATE), A
    RET
;   FRUIT (1) IS ON SCREEN
@moveFruit:
;   EXIT IF DISPLAYING FRUIT POINTS
    BIT 1, (HL)
    RET NZ
;   EXECUTE STATE'S ROUTINE
    LD HL, fruitStateTable
    LD A, (fruit + STATE)
    JP jumpTableExec
;   JR.PAC-MAN DOT CHECK FOR FRUIT
@dotCheck:
;   FRUIT (1) AND POINTS (2) ARE NOT ON SCREEN
    EX DE, HL       ; DE: fruitStatus
    LD BC, (currPlayerInfo.jrDotCount)
    LD A, (DE)
;   1ST FLAG
.IF FREE_FRUIT_JR == $00
    LD HL, $60
.ELSE
    LD HL, $00
.ENDIF
    OR A
    SBC HL, BC
    JP NZ, +
    ; EXIT IF FLAG IS ALREADY SET
    BIT 4, A
    RET NZ
    OR A, $10
    JP @@end
+:
;   2ND FLAG
    LD HL, $D0
    OR A
    SBC HL, BC
    JP NZ, +
    ; EXIT IF FLAG IS ALREADY SET
    BIT 5, A
    RET NZ
    OR A, $20
    JP @@end
+:
;   3RD FLAG
    LD HL, $140
    OR A
    SBC HL, BC
    JP NZ, +
    ; EXIT IF FLAG IS ALREADY SET
    BIT 6, A
    RET NZ
    OR A, $40
    JP @@end
+:
;   4TH FLAG
    LD HL, $1B0
    OR A
    SBC HL, BC
    RET NZ
    ; EXIT IF FLAG IS ALREADY SET
    BIT 7, A
    RET NZ
    OR A, $80
@@end:
    LD (DE), A
    ; SET LOW NIBBLE TO ONE
    EX DE, HL
    INC (HL)
    RET





/*
    INFO: PREPARE TO RELEASE FRUIT IN LEVEL
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, R
*/
prepareFruit:
;   CLEAR OFFSCREEN FLAG
    XOR A
    LD (fruit + OFFSCREEN_FLAG), A
;   SET FRUIT TILE DEF POINTER 
    ; DIFFERENT POINTER SETUP FOR EACH GAME
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS.PAC
    JP C, @msSetFruit
    RRCA    ; JR.PAC
    JP C, @jrSetFruit
;   ---------------
;   PAC-MAN FRUIT SETUP
;   ---------------
    ; CHECK IF LEVEL IS 20 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, 20
    JP C, +     ; IF NOT, SKIP
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
    JP C, @@calcPtrs ; IF NOT, USE LEVEL NUMBER DIRECTLY
    ; ELSE, PICK A RANDOM FRUIT
    LD B, $07
    LD A, R     ; RANDOMNESS COMES FROM R REGISTER [(R % 32) % 7]
    AND A, $1F
-:
    SUB A, B
    JP NC, -
    ADD A, B
@@calcPtrs:
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
    ; CHECK IF LEVEL IS 7 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $07
    JP C, prepareFruit@msSetFruit@calcPtrs
    LD A, $06
    JP prepareFruit@msSetFruit@calcPtrs




/*
------------------------------------------------
            JR.PAC-MAN'S FRUIT STATES
------------------------------------------------
*/
;   STATE TABLE
fruitStateTable:
    .DW fruitState0 ; NOTHING
    .DW fruitState1 ; INIT
    .DW fruitState2 ; UPDATE
    .DW fruitState3 ; ^
    .DW fruitState0 ; NOTHING
    .DW fruitState5 ; AT TARGET

;   STATE 0 - NOTHING
fruitState0:
    RET

;   STATE 1 - PREPARE FRUIT
fruitState1:
;   CLEAR VARS
    XOR A
    ; POWER DOT SELECTOR [$4931] IS UNINITIALIZED BESIDES HARD RESET (CLEARING RAM)
    LD (fruitPathPtr), A        ; FRUIT TARGET TYPE [$4919]
    LD (fruitPathBounce), A     ; PATHFIND FLAG [$491C]
    LD (fruitPathLen), A        ; MOVEMENT COUNTER [$491B]
;   SUBTRACT 2 FROM Y POS (WHY?)
    LD HL, fruit + Y_WHOLE
    DEC (HL)
    DEC (HL)
;   SET STATE TO 2
    LD A, $02
    LD (fruit + STATE), A
;   ASSUME FRUIT WILL GO LEFT
    LD HL, $2B3B    ; TILE POSITION
    LD B, $01       ; DIRECTION
;   SET DIRECTION / POSITION BASED ON SCROLL
    LD A, (jrCameraPos)
    CP A, $28
    JP C, +
    ; MAKE FRUIT GO RIGHT
    LD HL, $2B3A    ; TILE POSITION
    LD B, $03       ; DIRECTION
+:
    ; SET FRUIT TILE POSITION
    LD (fruit + CURR_X), HL
    ; SET DIRECTION
    LD A, B
    LD (fruit.currDir), A
    LD (fruit.nextDir), A
    RET

;   STATE 2/3 - GENERAL MOVEMENT
fruitState2:
fruitState3:
;   UPDATE MOVE COUNTER, EXIT IF IT DOESN'T EQUAL 3
    LD HL, fruitPathLen
    INC (HL)
    LD A, (HL)
    CP A, $03
    RET NZ
;   RESET COUNTER
    LD (HL), $00
;   CHECK IF FRUIT IS AT CENTER OF TILE
    LD HL, fruit.xPos
    LD A, (fruit.currDir)
    RRCA
    JP C, +
    INC HL
    INC HL
+:
    LD A, (HL)
    AND A, $07
    CP A, $04
    JP NZ, @updateFruitPos
;   FRUIT IS AT CENTER OF TILE
    ; GET ID OF FRUIT'S CURRENT TILE
    LD DE, (fruit + CURR_X)
    CALL getTileID
    PUSH AF ; SAVE ID
    ; CALL IF FRUIT IS ON NORMAL DOT TILE
    CP A, $02
    CALL Z, updateCollMapFruitMDot  ; SET TILE TO MUTATED DOT [COLLISION MAP && TILEMAP]
    POP AF  ; RESTORE ID
    LD E, A ; PUT ID INTO E
    ; SKIP IF PATHFIND FLAG IS 0
    LD A, (fruitPathBounce)
    OR A
    JP Z, +
    ; CALL HELPER
    CALL fruitHelper00
    RET C   ; RETURN IF FRUIT STATE BECAME 5
    ; UPDATE FRUIT TILE POS (NEXT DIRECTION)
    LD A, (fruit + NEXT_DIR)
    CALL fruitSetTile
    ; UPDATE FRUIT DIRECTION
    LD A, (fruit.nextDir)
    LD (fruit.currDir), A
    JP ++
+:
    ; UPDATE FRUIT TILE POS (CURRENT DIRECTION)
    LD A, (fruit + CURR_DIR)
    CALL fruitSetTile
++:
    ; SET PATHFIND FLAG
    LD HL, fruitPathBounce
    SCF
    RL (HL)
    ; ADD PATHFIND TASK
    LD A, $05
    CALL addTask
@updateFruitPos:
;   SET WHICH AXIS TO APPLY MOVEMENT AND HOW
    LD HL, dirVectors
    LD A, (fruit.currDir)
    ADD A, A
    addToHL_M
    EX DE, HL   ; DE: WANTED VECTOR
;   ADD Y PART OF VECTOR TO POSITION
    LD A, (DE)
    LD HL, (fruit + Y_WHOLE)
    addToHLSigned
    LD (fruit + Y_WHOLE), HL
;   ADD X PART OF VECTOR TO POSITION
    INC DE
    LD A, (DE)
    LD HL, (fruit + X_WHOLE)
    addToHLSigned
    LD (fruit + X_WHOLE), HL
@updatePtrs:
    ; TILE Y CENTER POINT
    LD A, (fruit + CURR_Y)
    SUB A, $21              ; COLLISION Y INDEX STARTS AT $21...
    CALL multiplyBy6
    ADD A, $03 + $02    ; MID POINT + MAZE OFFSET
    LD (fruitTileYCenter), A
    ; TILE X CENTER POINT
    LD A, (fruit + CURR_X)
    LD B, A
    LD A, $57           ; COLLISION X INDEX STARTS AT $1E AND INCREASES GOING LEFT
    SUB A, B            ; REVERSE ORDER AND CORRECT INDEX BY DOING ((X_START + X_LENGTH - 1) - X_TILE)
    LD L, A
    LD H, $00
    CALL multBy6_16
    LD DE, $03 - $0A    ; MID POINT - MAZE OFFSET
    ADD HL, DE
    LD A, L
    LD (fruitTileXCenter), A
;   --------------
;   RAM NAMETABLE POINTER UPDATE (SCROLLING)
;   --------------
    ; GET X TILE (DIVIDE BY 8)
    SRL H
    RR L
    SRL H
    RR L
    SRL H
    RR L
    LD B, L     ; STORE IN B (RAM_COL)
    LD A, B
    LD (fruitTileMapCol), A
    PUSH BC     ; SAVE RAM_COL FOR LATER
    ; GET Y TILE (DIVIDE BY 8)
    LD A, (fruitTileYCenter)
    ; DIVIDE BY 8
    RRCA
    RRCA
    RRCA
    AND A, $1F
    LD L, A     ; STORE IN H (RAM_ROW)
    LD H, $00
    PUSH HL     ; SAVE RAM_ROW FOR LATER
    ; MULTIPLY BY 41 (TILES PER ROW)
    multBy41
    ; ADD X AND Y
    LD C, B
    LD B, $00
    ADD HL, BC
    ; MULTIPLY BY 2 (TILES ARE 2 BYTES EACH)
    ADD HL, HL
    ; STORE
    LD DE, mazeGroup1.tileMap
    ADD HL, DE
    LD (fruitTileMapRamPtr), HL
;   --------------
;   VRAM NAMETABLE POINTER UPDATE (SCROLLING)
;   --------------
    ; RAM_ROW PROCESS
    POP HL  ; GET RAM_ROW (H)
    INC L   ; APPLY 1 ROW OFFSET (TOP ROW ON SCREEN IS RESERVED FOR HUD)
    ; MULTIPLY BY YTILE 64 (EACH ROW IS 64 BYTES [32 TILES * 2])
    XOR A
    SRL H
    RR L
    RRA
    SRL H
    RR L
    RRA
    LD H, L     ; RESULT IN HL
    LD L, A
    ; RAM_COL PROCESS
    POP DE  ; GET RAM_COL (D)
    LD E, D ; MOVE TO E
    LD D, $00
    ; ADJUST TO SCREEN VIEW
    LD A, (jrScrollReal)
    SRA A           ; SIGNED DIVIDE BY 8
    SRA A
    SRA A
    NEG
    ADD A, E        ; RAM_COL -= XSCROLL_TILE
    AND A, $1F  ; LIMIT TO 0 - 31 (VALID COLUMN RANGE)
    ; ADD LEFT MOST TILE
    LD E, A
    LD A, (jrLeftMostTile)
    NEG
    ADD A, E
    AND A, $1F  ; LIMIT TO 0 - 31 (VALID COLUMN RANGE)
    ADD A, A    ; MULTIPLY XTILE BY 2  (2 BYTES PER TILE)
    LD E, A     ; STORE IN E
    ; ADD X AND Y TOGETHER
    ADD HL, DE
    ; STORE VRAM POINTER
    LD (fruitTileMapPointer), HL
;   --------------
;   TILE QUADRANT DERTERMINATION (SCROLLING)
;   --------------
;   |----|----|
;   |  0 |  2 |
;   |    |    |
;   |____|____|
;   |    |    |
;   |  1 |  3 |
;   |    |    |
;   |----|----|
    ; GET FLIP BITS FROM RAM TILEMAP
    LD HL, (fruitTileMapRamPtr)
    INC HL
    LD A, (HL)  ; GET HORIZONTAL/VERTICAL FLIP BITS
    ; REG SETUP (B = XOR MASK, C = QX, D = $04, E = FLIP BITS)
    LD E, A
    LD D, $04
    ; QX's XOR MASK
    AND A, $02  ; XOR MASK = (FLIP & $02) << $01
    ADD A, A
    LD B, A
    ; QX = ((POS ^ XOR_MASK) & $04) >> $02
    LD A, (fruitTileXCenter)
    XOR A, B
    AND A, D
    RRCA
    LD C, A     ; C = QX << $01
    ; QY's XOR MASK
    LD A, E     ; XOR MASK = (FLIP & $04)
    AND A, D
    LD B, A
    ; QY = ((POS ^ XOR_MASK) & $04) >> $02
    LD A, (fruitTileYCenter)
    XOR A, B
    AND A, D
    RRCA
    RRCA
    ; QUAD = QY | (QX << $01)
    OR A, C
    ; STORE RESULT
    LD (fruitTileQuadrant), A
@fruitBounce:
;   ASSUME FRUIT IS MOVING IN X AXIS
    LD A, (fruit.currDir)
    LD B, A
    LD A, (fruit.xPos)
    LD HL, fruit + Y_WHOLE
    BIT 0, B
    JP NZ, +    ; SKIP IF IT IS
    ; ELSE, FRUIT IS MOVING IN Y AXIS
    LD A, (fruit.yPos)
    LD HL, fruit + X_WHOLE
+:
    PUSH HL ; SAVE FOR LATER
;   CHECK IF FRUIT IS AT CENTER OF TILE?
    ADD A, $04
    AND A, $07
    JP NZ, +    ; IF NOT, SKIP
    ; PLAY BOUNCE SOUND
    LD HL, ch2SndControlJR
    SET 0, (HL)
+:
;   GET PIXEL OFFSET FROM TABLE
    LD HL, jrBounceTable
    ADD A, A
    addToHL_M
    LD E, (HL)  ;   STORE IN DE
    INC HL
    LD D, (HL)
;   NEGATE VALUE IN MOVING DOWN OR LEFT
    INC B
    BIT 1, B
    JP NZ, +
    ; NEGATE PIXEL OFFSET
    XOR A
    SUB A, E
    LD E, A
    SBC A, A
    SUB A, D
    LD D, A
+:
;   ADD OFFSET TO POSITION
    POP HL      ; HL = POSITION PTR
    PUSH HL     ; STILL NEED IT FOR LATER
    ; GET POSITION VALUE FROM PTR
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; ADD PIXEL OFFSET
    ADD HL, DE
    EX DE, HL   ; DE = NEW POSITION
    POP HL      ; HL = POSITION PTR
    ; STORE NEW POSITION
    LD (HL), E
    INC HL
    LD (HL), D
    RET
jrBounceTable:
    .DW $0000 $FFFF $FFFF $0000 $0000 $0001 $0001 $0000
;   0 1 2 3 = UP LEFT DOWN RIGHT
;   1 2 3 0 = LEFT DOWN RIGHT UP
;   0 1 2 3 = RIGHT DOWN LEFT UP
;   1 2 3 0 = DOWN LEFT UP RIGHT


;   STATE 5 - FRUIT IS AT POWER DOT TARGET
fruitState5:
;   GET ID OF FRUIT'S CURRENT TILE
    LD DE, (fruit + CURR_X)
    CALL getTileID
    AND A, $03
    JP NZ, +    ; SKIP IF IT ISN'T A BLANK TILE
    ; ELSE, SET FRUIT STATE TO 2 (TARGET TYPE IS PLAYER)
    LD A, $02
    LD (fruit + STATE), A
    RET
+:
;   EXIT IF FRUIT IS OFFSCREEN
    LD A, (fruit + OFFSCREEN_FLAG)
    OR A
    RET NZ
;   EXIT IF FRUIT ISN'T WITHIN CERTAIN BOUNDARIES

;   EXPLOSION STATE
    LD A, $06
    LD (fruit + STATE), A
;   INCREMENT LOWER NIBBLE (JR CAN'T EAT IT ANYMORE)
    LD HL, currPlayerInfo.fruitStatus
    INC (HL)
;   BLANK OUT TILE (TILEMAP && COLLMAP)
    CALL updateCollMapFruitPDot
;   UPDATE DOT COUNT
    CALL updatePlayerDotCount 
;   RESET EXPLOSION COUNTER
    XOR A
    LD (fruitPathLen), A    ; HNIBB: LIMITER, LNIBB: FRAME
;   REMOVE FRUIT (CLEAR POSITION AND MAKE INVISIBLE)
    RET

;   STATE 6 - EXPLOSION!
fruitState6:
;   INCREMENT AND CHECK IF FRAME COUNTER IS 5
    LD HL, fruitPathLen
    INC (HL)
    LD A, (HL)
    AND A, $0F
    CP A, $05
    RET NZ  ; EXIT IF NOT
;   CLEAR FRAME COUNTER
    LD A, (HL)
    AND A, $F0
    LD (HL), A
;   INCREMENT SPRITE COUNTER
    ADD A, $10
    LD (HL), A
;   PLAY CREDIT SFX
    LD HL, ch2SndControlJR
    SET 1, (HL)
    RET NC  ; ANIMATION ENDS WHEN SPRITE COUNTER OVERFLOWS
;   CLEAR STATE
    XOR A
    LD (fruit + STATE), A
;   CLEAR OTHER FRUIT STUFF
    LD HL, currPlayerInfo.fruitStatus
    JP fruitUpdate@timerExpired





fruitHelper00:
;   JUMP IF FRUIT STATE ISN'T TWO
    LD A, (fruit + STATE)
    CP A, $02
    JP NZ, @clrCarryEnd
;   JUMP IF FRUIT TARGET IS SET TO PLAYER
    LD A, (fruitPathPtr)
    CP A, $02
    JP Z, @setState
;   JUMP IF FRUIT ISN'T ON POWER DOT TILE
    LD A, E     ; E = CURR_ID
    CP A, $03
    JP NZ, @clrCarryEnd
;   JUMP IF FRUIT ISN'T AT POWER DOT TARGET
    LD A, (fruitPathPtr)
    CP A, $01
    JP NZ, @clrCarryEnd
;   SET STATE TO 5, SET CARRY
    LD A, $05
    LD (fruit + STATE), A
    SCF
    RET
@setState:
    LD A, $03
    LD (fruit + STATE), A
@clrCarryEnd:
    OR A
    RET


;   AF, DE, HL
fruitSetTile:
    LD HL, dirVectors
;   USE DIRECTION AS OFFSET INTO TABLE
    ADD A, A    ; DOUBLE DIRECTION
    addToHL_M
;   ADD Y
    LD A, (fruit + CURR_Y)
    ADD A, (HL)
    LD (fruit + CURR_Y), A
    LD D, A
;   ADD X
    INC HL
    LD A, (fruit + CURR_X)
    ADD A, (HL)
    LD (fruit + CURR_X), A
    LD E, A
;   GET ID    
    CALL getTileID
    LD (fruit + CURR_ID), A
    RET


/*
------------------------------------------------
        JR.PAC-MAN'S FRUIT PATHFINDING
------------------------------------------------
*/
    ; HELPER0 USES LOWER NIBBLE
    ; HELPER1 USES UPPER NIBBLE
    ; NIBBLE REPRESENTS POWER DOT INDEX
fruitPowerDotTable:
    .DB $04 $03 $51 $52 $42 $40 $13 $15

fruitPathFindingAI:
;   EXIT IF PATHFIND FLAG IS 0
    LD A, (fruitPathBounce)
    OR A
    RET Z
;   DETERMINE TARGET TILE
    ; PUSH RETURN ADDRESS FOR TARGET FUNCTIONS
    LD HL, @helperRet
    PUSH HL
    ; DO ONE OF TWO FUNCTIONS DEPENDING ON PATHFIND FLAG
    DEC A
    JP NZ, fruitPFTargetHelper1 ; $AA87
    JP fruitPFTargetHelper0     ; $AA5E (TARGET INITIALIZER)
@helperRet:
;   CALC REVERSE DIRECTION
    LD A, (fruit + NEXT_DIR)
    XOR A, $02
    LD (fruit + REVE_DIR), A
;   GET SURROUNDING TILES
    LD IX, fruit
    CALL updateCollTiles
;   COPY TILES INTO PATHFIND WORK AREA
    LD HL, fruit.collisionTiles
    LD DE, pfWorkTiles
    LD BC, _sizeof_pfWorkTiles
    LDIR
;   DETERMINE NEXT DIRECTION
    JP ghostPathFindingAI@normalPathFinding


/*
    TARGET INITIALIZER (ONLY CALLED ON 1ST PATHFIND?)
*/
fruitPFTargetHelper0:   ; $AA5E
;   UPDATE POWER DOT TARGET STATE
    LD A, (fruitPathPtr + 1)
    INC A
    AND A, $07
    LD (fruitPathPtr + 1), A
;   USE LOWER 3 BITS AS OFFSET (POWER DOT SELECTOR)
    LD HL, fruitPowerDotTable
    addToHL_M
    LD A, (HL)
    AND A, $0F  ; USE LOWER NIBBLE
@skipLUT:
;   GET POWER DOT'S COORDS
    PUSH AF ; SAVE INDEX
    LD HL, jrMazePDotTargets
    CALL jrGetMazeIndex
    POP AF  ; RESTORE INDEX
    ADD A, A
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   SET TARGET
    LD (fruit + TARGET_X), HL
;   TARGET TYPE IS "NOT AT TARGET"
    XOR A
    LD (fruitPathPtr), A
    RET


/*
    STANDARD TARGET FINDER/HELPER
*/
fruitPFTargetHelper1:   ; $AA87
;   EXECUTE ROUTINE BASED ON UPPER NIBBLE OF POWER DOT TARGET STATE
    LD A, (fruitPathPtr + 1)
    AND A, $F0
    RRCA
    RRCA
    RRCA
    ;RRCA
    ;ADD A, A
    LD HL, @subRoutineTable
    addToHL_M
    JP (HL)

;   JUMP TABLE FOR TARGET HELPER 1
@subRoutineTable:
    JR @subRoutine00
    JR @subRoutine01
    JR @subRoutine02


;   SUB ROUTINE 1   $AA97
@subRoutine00:
;   CHECK IF FRUIT IS WITHIN CERTAIN RANGE OF TARGET
    LD HL, (fruit + TARGET_X)
    LD A, L ; SWAP
    LD L, H
    LD H, A
    LD BC, (fruit + CURR_X)
    LD A, C ; SWAP
    LD C, B
    LD B, A
    ; RANGE CHECK
    LD A, H
    SUB A, B
    ADD A, $0E
    CP A, $1C
    RET NC
;   SET BIT 4 OF POWER DOT TARGET STATE (INCREMENT STATE)
    LD A, (fruitPathPtr + 1)
    AND A, $07
    LD E, A
    OR A, $10
    LD (fruitPathPtr + 1), A
;   USE LOWER 3 BITS AS OFFSET (POWER DOT SELECTOR)
    LD HL, fruitPowerDotTable
    LD D, $00
    ADD HL, DE
    LD A, (HL)
    AND A, $F0  ; USE UPPER NIBBLE
    RRCA
    RRCA
    RRCA
    RRCA
;   GET TARGET, ETC
    JP fruitPFTargetHelper0@skipLUT

;   SUB ROUTINE 2   $AAC9
@subRoutine01:
;   CHECK IF FRUIT IS WITHIN CERTAIN RANGE OF TARGET
    LD HL, (fruit + TARGET_X)
    LD A, L ; SWAP
    LD L, H
    LD H, A
    LD BC, (fruit + CURR_X)
    LD A, C ; SWAP
    LD C, B
    LD B, A
    ; RANGE CHECK
    LD A, H
    SUB A, B
    ADD A, $07
    CP A, $0E
    RET NC
;   SET BIT 5 OF POWER DOT TARGET STATE (INCREMENT STATE)
    LD A, (fruitPathPtr + 1)
    AND A, $0F
    OR A, $20
    LD (fruitPathPtr + 1), A
    RET

;   SUB ROUTINE 3   $AAE1
@subRoutine02:
;   JUMP IF TARGET TYPE IS PLAYER
    LD A, (fruitPathPtr)
    CP A, $02
    JP Z, setTargetToJR
;   CHECK IF TARGET TILE IS STILL A POWER DOT
    LD DE, (fruit + TARGET_X)
    CALL getTileID
    CP A, $03   ; 0 - EMPTY, 1 - WALL, 2 - DOT, 3 - POWER DOT
    JP Z, +
;   IF NOT, TRY TO FIND ANOTHER POWER DOT TO TARGET
    CALL findNewTarget
;   IF NONE EXIST, SET TARGET TO PLAYER
    JP Z, setTargetToJR
;   ELSE, SET NEW TARGET
    LD (fruit + TARGET_X), DE
+:
;   CHECK IF FRUIT IS AT TARGET
    XOR A
    LD HL, (fruit + CURR_X)
    LD BC, (fruit + TARGET_X)
    SBC HL, BC
    JP NZ, +
    INC A
+:
.IF FREE_FRUIT_JR != $00
    XOR A
.ENDIF
;   SET TARGET TYPE
    LD (fruitPathPtr), A    ; 0 - NOT AT (POWER DOT) TARGET, 1 - AT (POWER DOT) TARGET, 2 - TARGET IS PLAYER
    RET


/*
    HELPER FUNCTIONS FOR THE TARGET FINDERS/HELPERS
*/

;   TRYS TO FIND A NEW POWER DOT TARGET IF THE CURRENT TARGET ISN'T A POWER DOT ANYMORE
;   OUTPUT: NZ - FOUND NEW TARGET, Z - UNABLE TO FIND NEW TARGET
findNewTarget:
    LD IYH, $06
    LD HL, jrMazePDotTargets
    CALL jrGetMazeIndex
-:
    LD E, (HL)
    INC HL
    LD D, (HL)
    INC HL
    PUSH HL ; SAVE PTR
    PUSH DE ; SAVE TARGET
    CALL getTileID
    POP DE  ; RESTORE TARGET
    POP HL  ; RESTORE PTR
    OR A    ; TILE ID WILL NEVER BE 1 OR 2. CHECKING FOR EITHER 0 OR 3
    RET NZ  ; NEW TARGET FOUND (IYH != 0, ID != 0)
    DEC IYH
    JP NZ, -
    RET     ; COULDN'T FIND NEW TARGET (IYH = 0, ID = 0)




setTargetToJR:
;   SET TARGET TYPE TO PLAYER
    LD A, $02
    LD (fruitPathPtr), A
;   SET TARGET TILE TO PLAYER'S CURRENT TILE
    LD HL, (pacman + CURR_X)
    LD (fruit + TARGET_X), HL
    RET



updateCollMapFruitMDot:
;   OFFSET = X_TILE + (Y_TILE * 32)
    LD A, (fruit + CURR_Y)
    SUB A, $21
    LD L, A
    multBy29
;   ADD X TILE TO OFFSET
    LD A, (fruit + CURR_X)
    SUB A, $1E
    LD E, A ; EVEN/ODD FLAG
    RRA     ; DIVIDE BY 2 (NIBBLE FORMAT)
    LD C, A
    LD B, $00
    ADD HL, BC
;   ADD INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeGroup1.collMap
    ADD HL, BC
;   SET BIT 2 OR BIT 5, DEPENDING ON EVEN OR ODD
    BIT 0, E
    LD A, $04   ; ASSUME CLEARING LOWER NIBBLE (ODD)
    JP NZ, +    ; IF IT IS ODD, SKIP..
    LD A, $40   ; ELSE, CLEAR UPPER NIBBLE
+:
    OR A, (HL)
    LD (HL), A
    /*
;   UPDATE COLLISION TILE FOR FRUIT
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
    LD (fruit + CURR_ID), A
    */
;   FALL THROUGH



updateTileMapFruitMDot:
;   GET TILE ID && FLIPPING IN TILEMAP
    LD HL, (fruitTileMapRamPtr)
    LD A, (HL)
    INC HL
    LD B, (HL)
    EX DE, HL   ; DE: TILEMAP PTR
;   USE TILE ID AND TILE QUADRANT TO GENERATE OFFSET
    LD HL, mazeMutatedTbl
    LD C, (HL)  ; TILE OFFSET
    ADD A, A
    ADD A, A 
    JP NC, +
    INC H
+:
    LD IY, fruitTileQuadrant    ; GET ADDRESS OF TILE QUAD INTO HL
    ADD A, (IY + 0)             ; ADD QUADRANT NUMBER TO OFFSET
    LD L, A
;   CALCULATE NEW TILE ID
    LD A, (HL)
    AND A, $3F
    ADD A, C
    LD C, A     ; STORE IN C
;   CALCULATE NEW FLIP BITS
    LD A, (HL)
    RLCA
    RLCA
    RLCA
    AND A, $06
    XOR A, B
    EX DE, HL   ; HL: TILEMAP PTR
    LD (HL), A
;   STORE NEW TILE ID
    DEC HL
    LD (HL), C
;   CHECK IF TILE IS IN VRAM TILEMAP
    LD A, (jrLeftMostTile)
    INC A   ; REMOVE $FF (-1)
    LD B, A
    LD A, (fruitTileMapCol)
    INC A
    CP A, B
    RET C   ; EXIT IF FRUIT'S COLUMN < LEFT MOST [VISIBLE] TILE (COLUMN)
    SET 5, B    ; ADD 32, (VRAM TILEMAP WIDTH)
    CP A, B
    RET NC  ; EXIT IF FRUIT'S COLUMN >= 1ST NON VISIBLE COLUMN ON RIGHT SIDE
;   UPDATE VRAM TILEMAP
    LD A, (HL)
    INC HL
    LD B, (HL)
    LD HL, (fruitTileMapPointer)
    LD (fruitTileBufAddr), HL   ; VRAM ADDRESS
    LD HL, fruitTileBufFlag
    LD (HL), $01    ; FLAG
    INC HL
    LD (HL), $01    ; COUNT
    INC HL          ; VRAM ADDRESS L (SKIP)
    INC HL          ; VRAM ADDRESS H (SKIP)
    INC HL
    LD (HL), $00    ; OFFSET
    INC HL
    LD (HL), A      ; LOW BYTE
    INC HL
    LD (HL), B      ; HIGH BYTE
    RET


updateCollMapFruitPDot:
;   OFFSET = X_TILE + (Y_TILE * 32)
    LD A, (fruit + CURR_Y)
    SUB A, $21
    LD L, A
    multBy29
;   ADD X TILE TO OFFSET
    LD A, (fruit + CURR_X)
    SUB A, $1E
    LD E, A ; EVEN/ODD FLAG
    RRA     ; DIVIDE BY 2 (NIBBLE FORMAT)
    LD C, A
    LD B, $00
    ADD HL, BC
;   ADD INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeGroup1.collMap
    ADD HL, BC
;   BLANK, DEPENDING ON EVEN OR ODD
    BIT 0, E
    LD A, $FC   ; ASSUME CLEARING LOWER NIBBLE (ODD)
    JP NZ, +    ; IF IT IS ODD, SKIP..
    LD A, $CF   ; ELSE, CLEAR UPPER NIBBLE
+:
    AND A, (HL)
    LD (HL), A

updateTileMapFruitPDot:
;   GET UPPER BYTE OF TILE
    LD HL, (fruitTileMapRamPtr)
    INC HL
    LD A, (HL)
;   DETERMINE WHICH POWER DOT FRUIT IS ON
    AND A, $E0  ; BITS 7, 6, 5 DETERMINE WHICH POWER DOT WAS EATEN
    ; PUT BITS 7, 6, 5 IN POSITION OF BITS 2, 1, 0
    RLCA
    RLCA
    RLCA
;   ADD POWER DOT NUMBER TO BASE TABLE ADDRESS TO GET POWER DOT OFFSET WITHIN TABLE
    LD H, hiByte(mazePowTbl)
    LD L, A     ; LOW BYTE IS 0, SO JUST OVERWRITE LOW BYTE
    LD L, (HL)  ; OVERWRITE LOW BYTE AGAIN WITH VALUE AT OFFSET
;   NOW POINTING TO INFO FOR POWER DOT
    ; GET DOT INFO
    LD B, (HL)      ; SETUP COUNTER FOR LOOP
    LD C, $FF       ; COUNTERACT LDI's DECREMENT
    LD DE, fruitTileBufCount
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
    LD (fruitTileBufAddr), HL
        ; GET BACK PDOT TABLE POINTER
    POP HL
    ; PREPARE FOR LOOP
    LD DE, fruitTileBuf
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
    ; GET TILE INFO
    LD HL, mazeMutatedTbl
    CP A, (HL)
    JP NC, @mutatedDot
@normalDot:
        ; USE TILE INDEX AS OFFSET INTO RAM TABLE
    POP HL      ; RESTORE POW DOT TABLE ADDRESS (POINTING TO QUAD)
    PUSH HL     ; SAVE BACK ONTO STACK (QUAD ADDRESS)
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
    JP @prepNextLoop
@mutatedDot:
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
@prepNextLoop:
    ; PREPARE FOR NEXT LOOP
    INC DE      ; POINT TO VRAM OFFSET FOR NEXT TILE IN LIST
    POP HL      ; RESTORE QUAD ADDRESS BACK INTO HL
    INC L       ; NOW POINTING TO VRAM OFFSET OF NEXT TILE IN LIST
    DJNZ -      ; KEEP GOING IF COUNT IS NOT 0
;   SET TILE BUFFER FLAG
    LD A, $01
    LD (fruitTileBufFlag), A
    RET