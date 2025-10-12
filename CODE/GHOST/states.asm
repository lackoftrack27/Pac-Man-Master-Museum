/*
------------------------------------------------
            STATE UPDATE FUNCTIONS
------------------------------------------------
*/



/*
------------------------------------------------
                SCATTER MODE
------------------------------------------------
*/
ghostStateTable@update@scatter:
@@@enter:
@@@update:
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - SPEED PATTERN CHECK
------------------------------------------------
*/
@@@@speedPatCheck:
;   CHECK IF GHOST IS BLINKY
    LD A, (IX + ID)
    OR A
    CALL Z, updateDiffFlags   ; IF SO, UPDATE DIFFICULTY FLAGS
;   CHECK IF SLOWDOWN BIT OF TILE ID IS SET
    LD HL, SPD_PATT_SLOW_00
    BIT 2, (IX + CURR_ID)
    JP Z, +     ; IF NOT, SKIP...
    ; IGNORE SLOWDOWN BIT IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    BIT JR_PAC, A
    JP NZ, +
    ; SKIP NEXT CHECK IF GAME ISN'T MS.PAC
    AND A, $01 << MS_PAC
    JP Z, @@@@execSpdPattern
    ; CHECK IF LEVEL IS 3 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $03
    JP C, @@@@execSpdPattern    ; IF NOT, USE SLOW SPEED PATTERN
+:
;   CHECK IF GHOST IS SCARED
    LD HL, SPD_PATT_SCARED_00
    BIT 0, (IX + EDIBLE_FLAG)
    JP NZ, @@@@execSpdPattern    ; IF SO, USE SCARED SPEED PATTERN
;   CHECK IF GHOST IS BLINKY
    LD HL, SPD_PATT_NORM_00
    LD A, (IX + ID)
    OR A
    JP NZ, @@@@execSpdPattern   ; IF NOT, USE NORMAL SPEED PATTERN
;   CHECK IF 2ND DIFF FLAG IS SET (BIT 0)
    LD HL, spdPatternDiff1
    LD A, (difficultyState)
    RRCA
    JP C, + ; IF SO, USE 2ND DIFF SPEED PATTERN
;   CHECK IF 1ST DIFF FLAG IS SET (BIT 1)
    LD HL, spdPatternDiff0
    RRCA
    JP C, + ; IF SO, USE 1ST DIFF SPEED PATTERN
;   ELSE, USE REGULAR SPEED PATTERN
    LD HL, SPD_PATT_NORM_00
;   ADD SPEED PATTERN OFFSET TO GHOST'S ADDRESS
@@@@execSpdPattern:
    LD D, IXH
    LD E, IXL
    ADD HL, DE
+:
    actorSpdPatternUpdate
.IF LOAD_TEST == $00
    RET NC
.ENDIF
    INC HL
    INC HL
    INC (HL)
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - CHECK IF GHOST IS AT CENTER POINT
------------------------------------------------
*/
@@@@chkCenterPoint:
;   CHECK IF AT CENTER OF TILE
    LD A, (IX + X_WHOLE)
    BIT 0, (IX + CURR_DIR) ; 00 - UP, 01 - LEFT, 02 - DOWN, 03 - RIGHT
    JP NZ, +
    LD A, (IX + Y_WHOLE)
+:
    AND A, $07
    CP A, $04
    JP NZ, @@@@prepareAxis
;   GHOST IS AT CENTER POINT OF TILE
    ; CHECK IF GHOST IS ABOUT TO TELEPORT
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    CALL Z, actorWarpCheck
    JP C, ++    ; IF SO, SKIP PATHFINDING
    ; CHECK IF GHOST IS SCARED
    BIT 0, (IX + EDIBLE_FLAG)
    JP NZ, +    ; IF SO, SKIP NEXT CHECK
    ; CHECK IF GHOST IS AT TILE WHERE IT DOESN'T PATHFIND
    BIT 3, (IX + NEXT_ID)   ; CHECK IF BIT 3 OF TILE ID IS SET
    JP NZ, ++   ; IF SO, SKIP
+:
    ; SET PATHFINDING FLAG (WILL DO PATHFINDING ON NEXT MOVE)
    LD A, (IX + ID)
    CALL addTask
++:
    ; CHECK IF GHOST MUST REVERSE DIRECTION
    BIT 0, (IX + REVE_FLAG)
    JP Z, + ; IF NOT, DON'T SET NEXT DIRECTION TO REVERSE DIRECTION
    ; CLEAR REVERSE FLAG
    LD (IX + REVE_FLAG), $00
    ; SET NEXT DIRECTION TO REVERSE DIRECTION
    LD A, (IX + REVE_DIR)
    LD (IX + NEXT_DIR), A
+:
    ; SET NEXT TILE TO NEXT TILE IN CURRENT DIRECTION
    CALL setNextTile
    ; SET CURRENT DIRECTION TO NEXT DIRECTION
    LD A, (IX + NEXT_DIR)
    LD (IX + CURR_DIR), A
    ; SET REVERSE DIRECTION
    XOR A, $02
    LD (IX + REVE_DIR), A
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - PREPARE FOR MOVEMENT
------------------------------------------------
*/
@@@@prepareAxis:
    LD HL, dirVectors
    ; CONVERT CURRENT DIRECTION INTO OFFSET
    LD A, (IX + CURR_DIR)
    ADD A, A
    addToHL_M   ; HL NOW POINTS TO CORRECT MOVEMENT FOR CURRENT DIRECTION
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - APPLY MAIN AXIS MOVEMENT TO GHOST
------------------------------------------------
*/ 
@@@@chooseAxis:
    EX DE, HL   ; DE: WANTED VECTOR
;   ADD Y PART OF VECTOR TO POSITION
    LD A, (DE)
    LD L, (IX + Y_WHOLE)
    LD H, (IX + Y_WHOLE + 1)
    addToHLSigned
    LD (IX + Y_WHOLE), L
    LD (IX + Y_WHOLE + 1), H
;   ADD X PART OF VECTOR TO POSITION
    INC DE
    LD A, (DE)
    LD L, (IX + X_WHOLE)
    LD H, (IX + X_WHOLE + 1)
    addToHLSigned
    LD (IX + X_WHOLE), L
    LD (IX + X_WHOLE + 1), H
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - UPDATE TILES
------------------------------------------------
*/
@@@@updateCenters:
;   UPDATE ACTOR'S COLLISION TILES, CENTERS, ETC...
    JP actorUpdate
@@@exit:
;   NO EXIT
@@@end:




/*
------------------------------------------------
                GOTO HOME MODE
------------------------------------------------
*/
ghostStateTable@update@gotoHome:
@@@enter:
@@@update:
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@chkCenterPoint
;   CHECK IF GHOST IS AT HOME ENTRENCE
    LD L, (IX + X_WHOLE)
    LD H, (IX + Y_WHOLE)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, +
;   PAC-MAN/MS.PAC-MAN CHECKING
    LD DE, $6480
    SBC HL, DE
    JP Z, @@@exit
    RET
+:
;   JR.PAC-MAN CHECKING
    LD DE, $5CE8
    SBC HL, DE
    RET NZ
@@@exit:
;   SWITCH TO "GOTO CENTER" MODE
    INC (IX + STATE)
    LD (IX + NEW_STATE_FLAG), $01
    RET




/*
------------------------------------------------
        GOTO CENTER [OF HOME] MODE
------------------------------------------------
*/
ghostStateTable@update@gotoCenter:
@@@enter:
@@@update:
;   FORCE GHOST TO GO DOWN
    LD (IX + CURR_DIR), DIR_DOWN
    LD (IX + NEXT_DIR), DIR_DOWN
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@prepareAxis
;   CHECK IF GHOST'S Y IS AT HOME ENTRENCE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    LD A, $80
    JP Z, +
    SUB A, $08
+:
    CP A, (IX + Y_WHOLE)
    RET NZ  ; IF NOT, EXIT
@@@exit:
;   SET VARS FOR BLINKY AND PINKY HERE
    LD A, (IX + ID)
    CP A, $02
    JP NC, ++     ; SKIP IF INKY OR CLYDE
    ; GHOST ISN'T VISIBLY SCARED (EDIBLE)
    LD (IX + EDIBLE_FLAG), $00
    ; GHOST IS ALIVE
    LD (IX + ALIVE_FLAG), $01
    ; SET TILE POSITION
    LD HL, $2F2E
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, $2E3B
+:
    LD (IX + NEXT_X), L
    LD (IX + NEXT_Y), H
    LD (IX + CURR_X), L
    LD (IX + CURR_Y), H
    ; SET TILE ID
    EX DE, HL
    CALL getTileID
    LD (IX + NEXT_ID), A
    LD (IX + CURR_ID), A
++:
;   ASSUME STATE FOR GOTO_REST
    INC (IX + STATE)
;   SET STATE FLAG
    LD (IX + NEW_STATE_FLAG), $01
;   ADDITIONAL STATE INCREMENT DEPENDING ON GHOST
    LD A, (IX + ID)
    CP A, $02
    RET NC  ; EXIT HERE IF INKY OR CLYDE
    INC (IX + STATE)    ; GHOST_REST
    OR A
    RET NZ  ; EXIT HERE IF PINKY
    INC (IX + STATE)    ; GHOST_GOTOEXIT
    RET     ; EXIT HERE IF BLINKY




/*
------------------------------------------------
        GOTO REST [SPOT OF HOME] MODE
------------------------------------------------
*/
ghostStateTable@update@gotoRest:
;   CHECK STATE
    BIT 0, (IX + NEW_STATE_FLAG)    ; CHECK THIS IS A NEW STATE
    JP Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
;   STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
;   SET DIRECTION
    LD A, (IX + ID) ; END RESULT: INKY - LEFT, CLYDE - RIGHT
    AND A, $01
    ADD A, A
    XOR A, DIR_LEFT
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
@@@update:
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@prepareAxis
;   CHANGE POSITION CHECK DEPENDING ON GHOST
    LD A, $90   ; ASSUME GHOST IS INKY, SO SET FOR HIS REST POSITION
    ; CHECK IF GHOST IS INKY
    BIT 0, (IX + ID)
    JP Z, +
    LD A, $70   ; IF NOT, SET FOR CLYDE'S REST POSITION
+:
    ; FURTHER CHANGE POS IF GAME IS JR.PAC
    LD HL, plusBitFlags
    BIT JR_PAC, (HL)
    JP Z, +
    ADD A, $68  ; WON'T OVERFLOW, MAP ISN'T BIG ENOUGH TO WORRY ABOUT 8TH BIT
+:
;   CHECK IF GHOST IS AT REST SPOT
    CP A, (IX + X_WHOLE)
    RET NZ  ; IF NOT, EXIT
@@@exit:
;   SWITCH TO "REST" MODE
    INC (IX + STATE)
    LD (IX + NEW_STATE_FLAG), $01
;   GHOST IS ALIVE
    LD (IX + ALIVE_FLAG), $01
;   GHOST ISN'T VISIBLY SCARED (EDIBLE)
    LD (IX + EDIBLE_FLAG), $00
;   FORCE GHOST TO GO DOWN
    LD (IX + CURR_DIR), DIR_DOWN
    LD (IX + NEXT_DIR), DIR_DOWN
;   SET TILE POSITION FOR INKY OR CLYDE HERE
    LD HL, $2F30    ; INKY
    BIT 0, (IX + ID)
    JP Z, +         ; 02 - INKY, 03 - CLYDE
    LD HL, $2F2C    ; CLYDE
+:
    ; CHANGE POS IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD DE, $FF0D
    ADD HL, DE
+:
    ; SET TILE POSITION
    LD (IX + NEXT_X), L
    LD (IX + NEXT_Y), H
    LD (IX + CURR_X), L
    LD (IX + CURR_Y), H
    ; SET TILE ID
    EX DE, HL
    CALL getTileID
    LD (IX + NEXT_ID), A
    LD (IX + CURR_ID), A
    RET



/*
------------------------------------------------
            REST [SPOT OF HOME] MODE
------------------------------------------------
*/
ghostStateTable@update@rest:
@@@enter:
@@@update:
;   CHECK IF GHOST NEEDS TO REVERSE
    LD A, (IX + Y_WHOLE)
    LD HL, plusBitFlags
    BIT JR_PAC, (HL)
    JP Z, +
    ADD A, $08
+:
    CP A, $78   ; (TOP OF HOUSE)
    JP Z, @@@@reverseDir     ; IF SO, REVERSE
    CP A, $80   ; (BOTTOM OF HOUSE)
    JP Z, @@@@reverseDir     ; IF SO, REVERSE
;   MOVE GHOST
    JP ghostStateTable@update@scatter@@@update@prepareAxis
@@@@reverseDir:
;   REVERSE DIRECTION
    LD A, (IX + CURR_DIR)
    XOR A, $02
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
;   MOVE GHOST
    JP ghostStateTable@update@scatter@@@update@prepareAxis




/*
------------------------------------------------
            GOTO EXIT [OF HOME] MODE
------------------------------------------------
*/
ghostStateTable@update@gotoExit:
;   CHECK STATE
    BIT 0, (IX + NEW_STATE_FLAG)    ; CHECK THIS IS A NEW STATE
    JP Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
    ; STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
    ; CHECK IF GHOST IS EITHER BLINKY OR PINKY
    LD A, (IX + ID)
    CP A, $02
    LD A, DIR_UP    ; ASSUME GHOST IS BLINKY OR PINKY (FLAGS NOT TOUCHED)
    JP C, +         ; IF SO, THEY ARE ALREADY AT THE CORRECT Y POSITION, SO SKIP...
    ; SET DIRECTION DEPENDING ON GHOST
    LD A, DIR_RIGHT   ; ASSUME GHOST IS INKY (GOING RIGHT)
    JP Z, +         ; IF SO, SET DIRECTION
    LD A, DIR_LEFT   ; ELSE, GHOST IS CLYDE (GOING LEFT)
+:
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
@@@update:
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@prepareAxis
;   CHECK IF GHOST IS OUT OF HOME
    LD HL, plusBitFlags
    LD A, $64
    ; MODIFY POS IF GAME IS JR.PAC
    BIT JR_PAC, (HL)
    JP Z, +
    SUB A, $08
+:
    CP A, (IX + Y_WHOLE)
    JP Z, ++
;   CONTINUE MOVING TOWARDS HOME EXIT
    ; CHECK GHOST IS AT CENTER OF HOUSE IN X AXIS
    LD A, $80
    ; MODIFY POS IF GAME IS JR.PAC
    BIT JR_PAC, (HL)
    JP Z, +
    ADD A, $68
+:
    CP A, (IX + X_WHOLE)
    RET NZ
    ; ELSE, SET DIRECTION TO BE UP AND START MOVING TOWARDS EXIT IN Y AXIS
    LD (IX + CURR_DIR), DIR_UP
    LD (IX + NEXT_DIR), DIR_UP
    RET
++:
;   PREPARE TO LEAVE HOME
    ; SET NEW STATE FLAG
    LD (IX + NEW_STATE_FLAG), $01
    ; SET STATE
    LD A, GHOST_SCATTER
    LD (IX + STATE), A
;   SET TILE POSITION
    LD HL, $2C2E
    ; CHANGE POS IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, $2B3B
+:
    LD (IX + NEXT_X), L
    LD (IX + NEXT_Y), H
;   SET TILE ID
    EX DE, HL
    CALL getTileID
    LD (IX + NEXT_ID), A
;   FORCE GHOST TO LEFT
    LD (IX + CURR_DIR), DIR_LEFT
    LD (IX + NEXT_DIR), DIR_LEFT
;   SET REVERSE DIRECTION
    LD (IX + REVE_DIR), DIR_RIGHT
    RET





/*
------------------------------------------------
        DRAW FUNCTIONS OF GHOST STATES
------------------------------------------------
*/
ghostStateTable@draw@scatter:
ghostStateTable@draw@rest:
ghostStateTable@draw@gotoExit:
;   CHECK IF GHOST SHOULD BE INVISIBLE (PLUS) OR IS OFFSCREEN
    LD A, (IX + INVISIBLE_FLAG)
    OR A, (IX + OFFSCREEN_FLAG)
    JP NZ, displayEmptySprite   ; IF SO, DISPLAY NOTHING
;   GHOST IS INVSIBLE WHEN BEING EATEN
    LD A, (ghostPointSprNum)
    DEC A
    CP A, (IX + ID)
    JP Z, displayEmptySprite
;   CHECK IF GHOST IS VISIBLY SCARED
    BIT 0, (IX + EDIBLE_FLAG)
    JP Z, displayGhostNormal    ; IF NOT, DISPLAY NORMAL SPRITES
    JP displayGhostScared       ; ELSE, DISPLAY SCARED SPRITES



ghostStateTable@draw@gotoHome:
ghostStateTable@draw@gotoCenter:
ghostStateTable@draw@gotoRest:
;   INVISIBLE FLAG ALWAYS RESET
    LD (IX + INVISIBLE_FLAG), $00
;   DISPLAY NOTHING IF OFFSCREEN FLAG IS SET OR IF GAME IS CRAZY OTTO
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    OR A, (IX + OFFSCREEN_FLAG)
    JP NZ, displayEmptySprite   ; IF SO, DISPLAY NOTHING
;   DISPLAY SCARED SPRITES
    JP displayGhostEyes