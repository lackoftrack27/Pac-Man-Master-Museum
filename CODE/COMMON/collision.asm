/*
------------------------------------------------
        COLLISION RELEATED FUNCTIONS
------------------------------------------------
*/

/*
    INFO: CHECKS IF PAC-MAN INTERSECTS WITH ANY OF THE 4 GHOSTS (USING TILE POSITIONS)
    INPUT: NONE
    OUTPUT: NONE
    USES:  AF, BC, DE, HL, IX
*/
globalCollCheckTile:
;   VAR SETUP
    LD IX, clyde
    LD BC, -_sizeof_ghost
    LD HL, (pacman + CURR_X)
;   CLYDE
    ; CHECK IF GHOST IS ALIVE
    LD A, (clyde + ALIVE_FLAG)
    OR A
    JP Z, + ; IF NOT, CHECK NEXT GHOST
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD DE, (clyde + CURR_X)
    SBC HL, DE
    ADD HL, DE
    JP Z, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
;   INKY
+:
    ADD IX, BC  ; GHOST POINTER = INKY
    ; CHECK IF GHOST IS ALIVE
    LD A, (inky + ALIVE_FLAG)
    OR A
    JP Z, + ; IF NOT, CHECK NEXT GHOST
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD DE, (inky + CURR_X)
    SBC HL, DE
    ADD HL, DE
    JP Z, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
;   PINKY
+:
    ADD IX, BC  ; GHOST POINTER = PINKY
    ; CHECK IF GHOST IS ALIVE
    LD A, (pinky + ALIVE_FLAG)
    OR A
    JP Z, + ; IF NOT, CHECK NEXT GHOST
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD DE, (pinky + CURR_X)
    SBC HL, DE
    ADD HL, DE
    JP Z, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
;   BLINKY
+:
    ADD IX, BC  ; GHOST POINTER = BLINKY
    ; CHECK IF GHOST IS ALIVE
    LD A, (blinky + ALIVE_FLAG)
    OR A
    RET Z   ; IF NOT, END
    ; CHECK IF PAC-MAN AND GHOST ARE AT SAME TILE
    LD DE, (blinky + CURR_X)
    SBC HL, DE
    RET NZ      ; IF NOT, END
;   FALL THROUGH




/*
    INFO: DETERMINES WHAT TO DO WHEN PAC-MAN HAS COLLIDED WITH A GHOST
    INPUT: NONE
    OUTPUT: NONE
    USES:  AF, HL, IX
*/
interactDetermination:
;   SET GHOST POINTS SPR_NUM TO ID+1
    LD A, (IX + ID)
    INC A
    LD (ghostPointSprNum), A
;   CHECK IF GHOST IS EDIBLE
    BIT 0, (IX + EDIBLE_FLAG)
    JP Z, @ghostKill    ; IF NOT, GHOST WILL KILL PAC-MAN
@ghostEaten:
;   PAC-MAN IS EATING GHOST
    ; SWITCH TO EAT MODE
    LD A, $01
    LD (eatSubState), A
    ; SET GHOST POINT POSITION TO GHOST'S
    LD A, (IX + X_WHOLE)
    LD (ghostPointXpos), A
    LD A, (IX + X_WHOLE + 1)
    LD (ghostPointXpos + 1), A
    LD A, (IX + Y_WHOLE)
    LD (ghostPointYpos), A
    RET
@ghostKill:
;   GHOST IS KILLING PAC-MAN
    ; SWITCH TO FIRST DEAD MODE
    LD HL, $01 * $100 + GAMEPLAY_DEAD00
    LD (subGameMode), HL
    RET


/*
    INFO: CHECKS IF PAC-MAN INTERSECTS WITH ANY OF THE 4 GHOSTS (USING PIXEL POSITIONS)
    INPUT: NONE
    OUTPUT: NONE
    USES:  AF, BC, DE, HL, IX, IY
*/
globalCollCheckPixel:
;   CHECK IF A COLLISION WAS DETECTED BY THE 1ST COLLISION FUNCTION
    LD A, (ghostPointSprNum)
    OR A
    RET NZ  ; IF SO, EXIT
;   CHECK IF GAME MODE IS SUPER
    LD A, (pacPoweredUp)
    OR A
    RET Z   ; IF NOT, EXIT
;   SETUP
    LD IX, clyde
    LD BC, -_sizeof_ghost
    LD IY, pacman
;   CLYDE
    ; CHECK IF GHOST IS ALIVE
    LD A, (clyde + ALIVE_FLAG)
    OR A
    JP Z, +     ; IF NOT, CHECK NEXT GHOST
    ; CHECK IF GHOST IS WITHIN TOLERANCE OF PAC-MAN'S POSITION
    LD DE, (pacman + X_WHOLE)
    LD HL, (clyde + X_WHOLE)
    SBC HL, DE
    LD DE, $0004
    OR A
    SBC HL, DE
    JP NC, +    ; IF NOT, CHECK NEXT GHOST
    LD A, (clyde + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, $04
    JP C, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
;   INKY
+:
    ADD IX, BC  ; GHOST POINTER = INKY
    ; CHECK IF GHOST IS ALIVE
    LD A, (inky + ALIVE_FLAG)
    OR A
    JP Z, +     ; IF NOT, CHECK NEXT GHOST
    ; CHECK IF GHOST IS WITHIN TOLERANCE OF PAC-MAN'S POSITION
    LD DE, (pacman + X_WHOLE)
    LD HL, (inky + X_WHOLE)
    SBC HL, DE
    LD DE, $0004
    OR A
    SBC HL, DE
    JP NC, +    ; IF NOT, CHECK NEXT GHOST
    LD A, (inky + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, $04
    JP C, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
;   PINKY
+:
    ADD IX, BC  ; GHOST POINTER = PINKY
    ; CHECK IF GHOST IS ALIVE
    LD A, (pinky + ALIVE_FLAG)
    OR A
    JP Z, +     ; IF NOT, CHECK NEXT GHOST
    ; CHECK IF GHOST IS WITHIN TOLERANCE OF PAC-MAN'S POSITION
    LD DE, (pacman + X_WHOLE)
    LD HL, (pinky + X_WHOLE)
    SBC HL, DE
    LD DE, $0004
    OR A
    SBC HL, DE
    JP NC, +    ; IF NOT, CHECK NEXT GHOST
    LD A, (pinky + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, $04
    JP C, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
;   BLINKY
+:
    ADD IX, BC  ; GHOST POINTER = BLINKY
    ; CHECK IF GHOST IS ALIVE
    LD A, (blinky + ALIVE_FLAG)
    OR A
    RET Z   ; IF NOT, END
    ; CHECK IF GHOST IS WITHIN TOLERANCE OF PAC-MAN'S POSITION
    LD DE, (pacman + X_WHOLE)
    LD HL, (blinky + X_WHOLE)
    SBC HL, DE
    LD DE, $0004
    OR A
    SBC HL, DE
    RET NC      ; IF NOT, CHECK NEXT GHOST
    LD A, (blinky + Y_WHOLE)
    SUB A, (IY + Y_WHOLE)
    CP A, $04
    JP C, interactDetermination ; IF SO, CHECK GHOST'S STATE TO DETERMINE NEXT ACTION
    RET