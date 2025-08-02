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
;   CHECK STATE
    BIT 0, (IX + NEW_STATE_FLAG)    ; CHECK THIS IS A NEW STATE
    JR Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
    ; STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
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
    JR Z, +     ; IF NOT, SKIP...
    ; CHECK IF GAME IS MS.PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR Z, @@@@execSpdPattern    ; IF NOT, SKIP NEXT CHECK
    ; CHECK IF LEVEL IS 3 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $03
    JR C, @@@@execSpdPattern    ; IF NOT, USE SLOW SPEED PATTERN
+:
;   CHECK IF GHOST IS SCARED
    LD HL, SPD_PATT_SCARED_00
    BIT 0, (IX + EDIBLE_FLAG)
    JR NZ, @@@@execSpdPattern    ; IF SO, USE SCARED SPEED PATTERN
;   CHECK IF GHOST IS BLINKY
    LD HL, SPD_PATT_NORM_00
    LD A, (IX + ID)
    OR A
    JR NZ, @@@@execSpdPattern   ; IF NOT, USE NORMAL SPEED PATTERN
;   CHECK IF DIFF FLAG IS 2
    LD HL, spdPatternDiff1
    LD A, (difficultyState)
    BIT 1, A
    JR NZ, +                    ; IF SO, USE SECOND DIFF SPEED PATTERN
;   CHECK IF DIFF FLAG IS 1
    LD HL, spdPatternDiff0
    BIT 0, A
    JR NZ, +                    ; IF SO, USE FIRST DIFF SPEED PATTERN
    LD HL, SPD_PATT_NORM_00
;   ADD SPEED PATTERN OFFSET TO GHOST'S ADDRESS
@@@@execSpdPattern:
    LD D, IXH
    LD E, IXL
    ADD HL, DE
+:
    CALL actorSpdPatternUpdate
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - CHECK IF GHOST IS AT CENTER POINT
------------------------------------------------
*/
@@@@chkCenterPoint:
;   CHECK IF AT CENTER OF TILE
    LD A, (IX + X_WHOLE)
    BIT 0, (IX + CURR_DIR) ; 00 - UP, 01 - LEFT, 02 - DOWN, 03 - RIGHT
    JR NZ, +
    LD A, (IX + Y_WHOLE)
+:
    AND A, $07
    CP A, $04
    JR NZ, @@@@prepareAxis
;   GHOST IS AT CENTER POINT OF TILE
    ; CHECK IF GHOST IS ABOUT TO TELEPORT
    CALL actorWarpCheck
    JR C, ++    ; IF SO, SKIP PATHFINDING
    ; CHECK IF GHOST IS SCARED
    BIT 0, (IX + EDIBLE_FLAG)
    JR NZ, +    ; IF SO, SKIP NEXT CHECK
    ; CHECK IF GHOST IS AT TILE WHERE IT DOESN'T PATHFIND
    BIT 3, (IX + NEXT_ID)   ; CHECK IF BIT 3 OF TILE ID IS SET
    JR NZ, ++   ; IF SO, SKIP
+:
    ; SET PATHFINDING FLAG (WILL DO PATHFINDING ON NEXT MOVE)
    LD A, (IX + ID)
    CALL addTask
++:
    ; CHECK IF GHOST MUST REVERSE DIRECTION
    BIT 0, (IX + REVE_FLAG)
    JR Z, + ; IF NOT, DON'T SET NEXT DIRECTION TO REVERSE DIRECTION
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
    ; CONVERT CURRENT DIRECTION INTO OFFSET
    LD A, (IX + CURR_DIR)
    ADD A, A
    ; ADD OFFSET TO VECTOR TABLE
    LD HL, dirVectors
    RST addToHL
    ; HL NOW POINTS TO CORRECT MOVEMENT FOR CURRENT DIRECTION
/*
------------------------------------------------
    [SCATTER MODE] UPDATE - APPLY MAIN AXIS MOVEMENT TO GHOST
------------------------------------------------
*/ 
@@@@chooseAxis:
;   ADD Y PART OF VECTOR TO POSITION
    LD A, (IX + Y_WHOLE)
    ADD A, (HL)
    LD (IX + Y_WHOLE), A
;   ADD X PART OF VECTOR TO POSITION
    INC HL
    LD A, (IX + X_WHOLE)
    ADD A, (HL)
    LD (IX + X_WHOLE), A
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
;   CHECK STATE
    BIT 0, (IX + NEW_STATE_FLAG)    ; CHECK THIS IS A NEW STATE
    JR Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
@@@update:
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@chkCenterPoint
;   CHECK IF GHOST IS AT HOME ENTRENCE
    LD L, (IX + X_WHOLE)    ; HL: YX
    LD H, (IX + Y_WHOLE)
    LD DE, $6480
    OR A        ; CLEAR CARRY
    SBC HL, DE
    RET NZ      ; IF NOT, EXIT
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
;   CHECK STATE
    BIT 0, (IX + NEW_STATE_FLAG)    ; CHECK THIS IS A NEW STATE
    JR Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
;   STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
@@@update:
;   FORCE GHOST TO GO DOWN
    LD (IX + CURR_DIR), DIR_DOWN
    LD (IX + NEXT_DIR), DIR_DOWN
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@prepareAxis
;   CHECK IF GHOST'S Y IS AT HOME ENTRENCE
    LD A, (IX + Y_WHOLE)
    CP A, $80
    RET NZ  ; IF NOT, EXIT
@@@exit:
;   SET VARS FOR BLINKY AND PINKY HERE
    LD A, (IX + ID)
    CP A, $02
    JR NC, +     ; SKIP IF INKY OR CLYDE
    ; GHOST ISN'T VISIBLY SCARED (EDIBLE)
    LD (IX + EDIBLE_FLAG), $00
    ; GHOST IS ALIVE
    LD (IX + ALIVE_FLAG), $01
    ; SET TILE POSITION
    LD HL, $2F2E
    LD (IX + NEXT_X), L
    LD (IX + NEXT_Y), H
    LD (IX + CURR_X), L
    LD (IX + CURR_Y), H
    ; SET TILE ID
    EX DE, HL
    CALL getTileID
    LD (IX + NEXT_ID), A
    LD (IX + CURR_ID), A
+:
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
    JR Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
;   STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
;   SET DIRECTION
    LD A, (IX + ID) ; END RESULT: INKY - LEFT, CLYDE - RIGHT
    AND A, $01
    RLCA
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
    JR Z, +
    LD A, $70   ; IF NOT, SET FOR CLYDE'S REST POSITION
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
    JR Z, +         ; 02 - INKY, 03 - CLYDE
    LD HL, $2F2C    ; CLYDE
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
;   CHECK STATE
    BIT 0, (IX + NEW_STATE_FLAG)    ; CHECK THIS IS A NEW STATE
    JR Z, @@@update                 ; IF NOT, SKIP TRANSITION 
@@@enter:
;   STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
@@@update:
;   CHECK IF GHOST NEEDS TO REVERSE
    LD A, (IX + Y_WHOLE)
    CP A, $78   ; (TOP OF HOUSE)
    JR Z, +     ; IF SO, REVERSE
    CP A, $80   ; (BOTTOM OF HOUSE)
    JR Z, +     ; IF SO, REVERSE
;   MOVE GHOST
    JP ghostStateTable@update@scatter@@@update@prepareAxis
+:
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
    JR Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
    ; STATE IS NO LONGER NEW
    LD (IX + NEW_STATE_FLAG), $00
    ; CHECK IF GHOST IS EITHER BLINKY OR PINKY
    LD A, (IX + ID)
    CP A, $02
    LD A, DIR_UP    ; ASSUME GHOST IS BLINKY OR PINKY (FLAGS NOT TOUCHED)
    JR C, +         ; IF SO, THEY ARE ALREADY AT THE CORRECT Y POSITION, SO SKIP...
    ; SET DIRECTION DEPENDING ON GHOST
    LD A, DIR_RIGHT   ; ASSUME GHOST IS INKY (GOING RIGHT)
    JR Z, +         ; IF SO, SET DIRECTION
    LD A, DIR_LEFT   ; ELSE, GHOST IS CLYDE (GOING LEFT)
+:
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
@@@update:
;   MOVE GHOST
    CALL ghostStateTable@update@scatter@@@update@prepareAxis
;   CHECK IF GHOST IS OUT OF HOME
    LD A, (IX + Y_WHOLE)
    CP A, $64
    JR Z, +     ; IF SO, SKIP...
;   CONTINUE MOVING TOWARDS HOME EXIT
    ; CHECK GHOST IS AT CENTER OF HOUSE IN X AXIS
    LD A, (IX + X_WHOLE)
    CP A, $80
    RET NZ
    ; ELSE, SET DIRECTION TO BE UP AND START MOVING TOWARDS EXIT IN Y AXIS
    LD (IX + CURR_DIR), DIR_UP
    LD (IX + NEXT_DIR), DIR_UP
    RET
+:
;   PREPARE TO LEAVE HOME
    ; SET NEW STATE FLAG
    LD (IX + NEW_STATE_FLAG), $01
    ; SET STATE
    LD A, GHOST_SCATTER
    LD (IX + STATE), A
;   SET TILE POSITION
    LD HL, $2C2E
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
;   CHECK IF GHOST SHOULD BE INVISIBLE (PLUS)
    BIT 0, (IX + INVISIBLE_FLAG)
    JP NZ, ghostSpriteFlicker@emptySprite   ; IF SO, DISPLAY NOTHING
;   GHOST IS INVSIBLE WHEN BEING EATEN
    LD A, (ghostPointSprNum)
    CP A, (IX + SPR_NUM)
    JP Z, ghostSpriteFlicker@emptySprite
;   DO SPRITE FLICKER PROCESSING
    CALL ghostSpriteFlicker
;   CHECK IF GHOST IS VISIBLY SCARED
    BIT 0, (IX + EDIBLE_FLAG)
    JP Z, displayGhostNormal    ; IF NOT, DISPLAY NORMAL SPRITES
    JP displayGhostScared       ; ELSE, DISPLAY SCARED SPRITES



ghostStateTable@draw@gotoHome:
ghostStateTable@draw@gotoCenter:
ghostStateTable@draw@gotoRest:
;   INVISIBLE FLAG ALWAYS RESET
    LD (IX + INVISIBLE_FLAG), $00
;   DO SPRITE FLICKER PROCESSING
    CALL ghostSpriteFlicker
;   DISPLAY SCARED SPRITES
    JP displayGhostEyes