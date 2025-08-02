/*
------------------------------------------------
        COLLISION RELEATED FUNCTIONS
------------------------------------------------
*/

/*
    INFO: CHECKS IF PAC-MAN INTERSECTS WITH ANY OF THE 4 GHOSTS
    INPUT: NONE
    OUTPUT: Z FLAG | NZ - NO COLLISION | Z - COLLISION
    USES:  AF, BC, DE, HL, IX
*/
globalCollCheck:
    LD IX, clyde
    LD BC, -_sizeof_ghost
;   CLYDE
    ; CHECK IF GHOST IS ALIVE
    LD A, (clyde + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD HL, (pacman + CURR_X)
    LD DE, (clyde + CURR_X)
    SBC HL, DE
    JR Z, interactDetermination
;   INKY
+:
    ADD IX, BC
    ; CHECK IF GHOST IS ALIVE
    LD A, (inky + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD HL, (pacman + CURR_X)
    LD DE, (inky + CURR_X)
    SBC HL, DE
    JR Z, interactDetermination
;   PINKY
+:
    ADD IX, BC
    ; CHECK IF GHOST IS ALIVE
    LD A, (pinky + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD HL, (pacman + CURR_X)
    LD DE, (pinky + CURR_X)
    SBC HL, DE
    JR Z, interactDetermination
;   BLINKY
+:
    ADD IX, BC
    ; CHECK IF GHOST IS ALIVE
    LD A, (blinky + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD HL, (pacman + CURR_X)
    LD DE, (blinky + CURR_X)
    SBC HL, DE
    JR Z, interactDetermination
+:
    RET




/*
    INFO: DETERMINES WHAT TO DO WHEN PAC-MAN HAS COLLIDED WITH A GHOST
    INPUT: NONE
    OUTPUT: Z FLAG | Z - COLLISION
    USES:  AF, HL, IX
*/
interactDetermination:
;   SET GHOST POINTS SPR_NUM TO GHOST
    LD A, (IX + SPR_NUM)
    LD (ghostPointSprNum), A
;   CHECK IF GHOST IS EDIBLE
    BIT 0, (IX + EDIBLE_FLAG)
    JR Z, @ghostKill    ; IF NOT, GHOST WILL KILL PAC-MAN
@ghostEaten:
;   ELSE, PAC-MAN IS EATING GHOST
    ; SWITCH TO EAT MODE
    LD A, $01
    LD (eatSubState), A
    ; HIDE GHOST (DOESN'T ACTUALLY BUT SIGNALS TO SPRITE FLICKER CODE)
    LD (IX + INVISIBLE_FLAG), A ; OVERRIDDEN IF GHOST FLASHING STARTS ON SAME FRAME
    RET
@ghostKill:
;   GHOST IS KILLING PAC-MAN
    ; SWITCH TO FIRST DEAD MODE
    LD HL, $01 * $100 + GAMEPLAY_DEAD00
    LD (subGameMode), HL
    RET


/*
    INFO: CHECKS IF PAC-MAN INTERSECTS WITH ANY OF THE 4 GHOSTS
        IF COLLISION OCCURED AND GHOST WAS SCARED, SWITCH TO EAT MODE
        IF COLLISION OCCURED AND GHOST WAS SCATTER/CHASE, SWITCH TO DEAD MODE
    INPUT: NONE
    OUTPUT: Z FLAG | NZ - NO COLLISION | Z - COLLISION
    USES:  AF, BC, DE, HL, IX
*/
globalCollCheck02:
;   CHECK IF GAME MODE IS SUPER
    LD A, (pacPoweredUp)
    OR A
    RET Z   ; IF NOT, EXIT
;   SETUP
    LD E, $04       ; COLLISION TOLERANCE
    LD IX, clyde
    LD BC, -_sizeof_ghost
    LD IY, pacman
;   CLYDE
    ; CHECK IF GHOST IS ALIVE
    LD A, (clyde + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK POSITIONS
    LD A, (clyde + X_WHOLE)
    SUB A, (IY + X_WHOLE)
    CP A, E
    JR NC, +
    LD A, (clyde + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, E
    JR C, interactDetermination
;   INKY
+:
    ADD IX, BC
    ; CHECK IF GHOST IS ALIVE
    LD A, (inky + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK POSITIONS
    LD A, (inky + X_WHOLE)
    SUB A, (IY + X_WHOLE)
    CP A, E
    JR NC, +
    LD A, (inky + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, E
    JR C, interactDetermination
;   PINKY
+:
    ADD IX, BC
    ; CHECK IF GHOST IS ALIVE
    LD A, (pinky + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK POSITIONS
    LD A, (pinky + X_WHOLE)
    SUB A, (IY + X_WHOLE)
    CP A, E
    JR NC, +
    LD A, (pinky + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, E
    JP C, interactDetermination
;   BLINKY
+:
    ADD IX, BC
    ; CHECK IF GHOST IS ALIVE
    LD A, (blinky + ALIVE_FLAG)
    OR A
    JR Z, +
    ; CHECK POSITIONS
    LD A, (blinky + X_WHOLE)
    SUB A, (IY + X_WHOLE)
    CP A, E
    JR NC, +
    LD A, (blinky + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, E
    JP C, interactDetermination
+:
    RET