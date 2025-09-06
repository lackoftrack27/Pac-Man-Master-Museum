
/*
------------------------------------------------
        RESET FUNCTIONS FOR GHOSTS
------------------------------------------------
*/
blinkyReset:
;   SPRITE TABLE START
    LD A, 05
    LD (blinky.sprTableNum), A
;   IN SCATTER STATE
    LD A, GHOST_SCATTER
    LD (blinky.state), A
;   SET X AND Y POSITION
    LD HL, $0080
    LD (blinky.xPos), HL
    LD HL, $0064
    LD (blinky.yPos), HL
;   GHOST ID
    LD (blinky.id), A
;   FACING LEFT
    LD A, $01
    LD (blinky.currDir), A
    LD (blinky.nextDir), A
;   SET GENERAL ACTOR/GHOST STUFF
    LD IX, blinky
    CALL actorReset
    JR ghostReset

pinkyReset:
;   SPRITE TABLE START
    LD A, 09
    LD (pinky.sprTableNum), A
;   IN REST STATE
    LD A, GHOST_REST
    LD (pinky.state), A
;   SET X AND Y POSITION
    LD HL, $0080
    LD (pinky.xPos), HL
    LD HL, $007C
    LD (pinky.yPos), HL
;   GHOST ID
    LD A, $01
    LD (pinky.id), A
;   FACING DOWN
    INC A   ; $02
    LD (pinky.currDir), A
    LD (pinky.nextDir), A
;   SET GENERAL ACTOR/GHOST STUFF
    LD IX, pinky
    CALL actorReset
    JR ghostReset

inkyReset:
;   SPRITE TABLE START
    LD A, 13
    LD (inky.sprTableNum), A
;   GHOST ID
    LD A, $02
    LD (inky.id), A
;   IN REST STATE
    LD A, GHOST_REST
    LD (inky.state), A
;   SET X AND Y POSITION
    LD HL, $0090
    LD (inky.xPos), HL
    LD HL, $007C
    LD (inky.yPos), HL
;   FACING UP
    XOR A
    LD (inky.currDir), A
    LD (inky.nextDir), A
;   SET GENERAL ACTOR/GHOST STUFF
    LD IX, inky
    CALL actorReset
    JR ghostReset

clydeReset:
;   SPRITE TABLE START
    LD A, 17
    LD (clyde.sprTableNum), A
;   GHOST ID
    LD A, $03
    LD (clyde.id), A
;   IN REST STATE
    LD A, GHOST_REST
    LD (clyde.state), A
;   SET X AND Y POSITION
    LD HL, $0070
    LD (clyde.xPos), HL
    LD HL, $007C
    LD (clyde.yPos), HL
;   FACING UP
    XOR A
    LD (clyde.currDir), A
    LD (clyde.nextDir), A
;   SET GENERAL ACTOR/GHOST STUFF
    LD IX, clyde
    CALL actorReset
;   FALL THROUGH


ghostReset:
;   RESET FLAGS
    XOR A
    LD (IX + INVISIBLE_FLAG), A
    LD (IX + REVE_FLAG), A
    LD (IX + EDIBLE_FLAG), A
;   GHOST IS ALIVE
    INC A
    LD (IX + ALIVE_FLAG), A
    RET



/*
------------------------------------------------
            GHOST DISPLAY FUNCTIONS
------------------------------------------------
*/
displayGhostNormal:
;   GET NEXT DIRECTION
    LD A, (IX + NEXT_DIR)
    ADD A, A    ; MULT BY 8
    ADD A, A
    ADD A, A
    LD E, A     ; SAVE FOR LATER ADD
;   ADD 4 IF GHOST FRAME COUNTER IS MULTIPLE OF 8 (THIS MAKES IT SO THEIR FEET MOVE EVERY 8 FRAMES)
    LD A, (frameCounter)
    AND A, $08
    RRCA
    ADD A, E
    LD E, A
;   ADD (ID * 32) TO GET CORRECT OFFSET FOR GHOST
    LD A, (IX + ID)
    RRCA
    RRCA
    RRCA
    ADD A, E
    LD B, A
;   ADD NEXT DIRECTION TO BASE TABLE ADDRESS OF TILE DEFS
    LD HL, ghostNormalTileDefs
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    JP Z, +
    LD HL, ottoGhostSNTileDefs
+:
    LD A, B
    LD E, A
    LD D, $00
    ADD HL, DE
@skipCalc:
;   GET X AND Y POSITION
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (IX + SPR_NUM)
;   DISPLAY 4 TILE SPRITE
    JP display4TileSprite



displayGhostScared:
;   ADD 4 IF GHOST FRAME COUNTER IS MULTIPLE OF 8
    LD A, (frameCounter)
    AND A, $08
    RRCA
    LD E, A
;   ADD 8 IF BIT 4 OF FLASH IS SET
    LD A, (flashCounter)
    AND A, $10
    RRCA
    ADD A, E
    LD B, A
;   ADD NEXT DIRECTION TO BASE TABLE ADDRESS OF TILE DEFS
    LD HL, ghostScaredTileDefs
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    JP Z, +
    LD HL, ottoGhostScaredSNTileDefs
+:
    LD A, B
    LD E, A
    LD D, $00
    ADD HL, DE
;   GET X AND Y POSITION
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (IX + SPR_NUM)
;   EXECUTE
    JP display4TileSprite



displayGhostEyes:
    LD HL, ghostEyesTileDefs
;   USE NEXT DIR AS OFFSET
    LD A, (IX + NEXT_DIR)
    ADD A, A    ; MULT BY 2
    LD E, A
    LD D, $00
    ADD HL, DE
;   GET X AND Y POSITION
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (IX + SPR_NUM)
;   DISPLAY HORIZONTAL 2 TILE SPRITE
    JP display2HTileSprite




ghostSpriteFlicker:
@emptySprite:
;   MOVE SPRITE AREA TO OFFSCREEN
    ; SET VDP ADDRESS
    LD A, (IX + SPR_NUM)
    OUT (VDPCON_PORT), A   ; LOW BYTE
    LD A, hibyte(SPRITE_TABLE) | hibyte(VRAMWRITE)
    OUT (VDPCON_PORT), A   ; HIGH BYTE
    ; SET Y POSITION TO $F8
    LD A, $F7
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    RET



;   FOR BLINKY
updateDiffFlags:
;   CHECK IF CLYDE IS OUT OF HOME
    LD A, (clyde.state)
    CP A, GHOST_REST
    RET Z               ; IF NOT, EXIT
    LD HL, currPlayerInfo.dotCount
;   CHECK IF DIFF FLAG IS 1
    LD A, (difficultyState)
    BIT 0, A
    JR NZ, +     ; IF SO, SKIP
;   CHECK IF DOTS EATEN IS GREATER OR EQUAL TO FIRST DOT COUNT
    LD A, $F4
    SUB A, (HL)
    LD B, A
    LD A, (speedUpDotCount)
    CP A, B
    RET C           ; IF NOT, EXIT
    ; IF SO, SET STATE TO 1
    LD A, $01
    LD (difficultyState), A
+:
;   STOP HERE IF GAME IS JR.PAC (JR.PAC DOESN'T USE SECOND DIFF FLAG)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    RET NZ
;   CHECK IF DIFF FLAG IS 2
    LD A, (difficultyState)
    BIT 1, A
    RET NZ      ; IF SO, END
;   CHECK IF DOTS EATEN IS GREATER OR EQUAL TO SECOND DOT COUNT
    LD A, $F4
    SUB A, (HL)
    LD B, A
    LD A, (speedUpDotCount)
    RRCA    ; !!!
    CP A, B
    RET C           ; IF NOT, EXIT
    ; IF SO, SET STATE TO 2
    LD A, $02
    LD (difficultyState), A
    RET


/*
    0 - SCATTER / NORMAL SPEED
    1 - CHASE   / FASTER SPEED
    2 - CHASE   / FASTEST SPEED
    CHECK IF CLYDE IS OUT: RETURN IF NOT
    CHECK FLAG 1: IF SET, SKIP DOT CHECK. ELSE, IF DOT COUNT IS MET, SET FLAG AND FALL THROUGH. ELSE, END
    CHECK FLAG 2: IF SET, END. ELSE, IF DOT COUNT IS MET, SET FLAG. ELSE, END
*/