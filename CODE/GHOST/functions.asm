
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
    LD HL, $6480    ; YX
    LD (blinky.xPos), HL
    XOR A
    LD (blinky.subPixel), A
;   GHOST ID
    LD (blinky.id), A
;   FACING LEFT
    INC A   ; $01
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
    LD HL, $7C80
    LD (pinky.xPos), HL
    XOR A
    LD (pinky.subPixel), A
;   GHOST ID
    INC A   ; $01
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
    LD HL, $7C90
    LD (inky.xPos), HL
    XOR A
    LD (inky.subPixel), A
;   FACING UP
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
    LD HL, $7C70
    LD (clyde.xPos), HL
    XOR A
    LD (clyde.subPixel), A
;   FACING UP
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
;   
    INC A
    LD (IX + ALIVE_FLAG), A
;   SETUP GHOST IN SAT (FALL THROUGH)



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
;   ADD NEXT DIRECTION TO BASE TABLE ADDRESS OF TILE DEFS
    LD HL, ghostNormalTileDefs
    RST addToHL
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
;   ADD OFFSET TO BASE TABLE
    LD HL, ghostScaredTileDefs
    RST addToHL
;   GET X AND Y POSITION
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (IX + SPR_NUM)
;   EXECUTE
    JP display4TileSprite


displayGhostEyes:
;   GET NEXT DIRECTION
    LD A, (IX + NEXT_DIR)
    ADD A, A    ; MULT BY 2
;   ADD TO TABLE ADDRESS
    LD HL, ghostEyesTileDefs
    RST addToHL
;   GET X AND Y POSITION
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (IX + SPR_NUM)
;   DISPLAY HORIZONTAL 2 TILE SPRITE
    JP display2HTileSprite



ghostSpriteFlicker:
;   CHECK IF SPRITE FLICKERING IS HAPPENING
    LD A, (sprFlickerControl)
    CP A, $20
    RET C       ; IF NOT, END
;   SELECT WHICH GHOST TO NOT DISPLAY
    LD B, (IX + ID)
    INC B
-:
    RRCA        ; RIGHT SHIFT BY ID + 1
    DJNZ -
    RET NC      ; IF UNDERFLOW ON LAST SHIFT DIDN'T OCCUR, RETURN AND DISPLAY GHOST
;   DON'T DISPLAY GHOST
    ; REMOVE CALLER
    POP HL
    ; DISPLAY EMPTY SPRITE OFFSCREEN (CLEARS GHOST SPRITES IN S.A.T.)
@emptySprite:
    LD A, (IX + SPR_NUM)
    LD DE, $00C0
    LD HL, EMPTY_PTR
    JP display1TileSprite



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