
/*
------------------------------------------------
                PAC-PLUS FUNCTIONS
------------------------------------------------
*/

/*
    INFO: RANDOMNESS FOR WHEN PAC-MAN EATS POWER DOT [PLUS]
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
plus_powerDotRNG:
;   CHECK IF GAME IS IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT
    RET Z   ; IF SO, EXIT
;   RESET ALL INVISIBLE FLAGS
    XOR A
    LD (blinky + INVISIBLE_FLAG), A
    LD (pinky + INVISIBLE_FLAG), A
    LD (inky + INVISIBLE_FLAG), A
    LD (clyde + INVISIBLE_FLAG), A
;   COPY RNG VALUE TO C
    LD A, (plusRNGValue)
    LD C, A
;   AND WITH 0x40
    AND A, $40
    JR NZ, @mazeInvisible   ; IF NOT 0, SKIP GHOST SWITCH
;   AND RNG VALUE WITH 0x03, THEN USE AS OFFSET INTO GHOSTS
    LD IX, blinky
    LD A, C
    AND A, $03
    JR Z, + ; SKIP IF RESULT IS 0
    LD B, A
    LD DE, _sizeof_ghost
-:
    ADD IX, DE
    DJNZ -
+:
;   MAKE SELECTED GHOST NOT TURN SCARED
    CALL ghostGameTrans_normal
    LD (IX + NEW_STATE_FLAG), $00
@mazeInvisible:
;   CHECK IF LEVEL IS 2 OR GREATER
    LD A, (currPlayerInfo.level)
    CP A, $02
    RET C   ; IF NOT, END
;   AND RNG VALUE WITH 0x10
    LD A, C
    AND A, $10
    RET NZ  ; END IF RESULT ISN'T 0
    SET 7, (HL) ; SET BIT 7 OF PLUS FLAGS (SIGNIFY TO TURN MAZE INVISIBLE)
    RET


/*
    INFO: FOR WHEN PAC-MAN EATS A FRUIT [PLUS]
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL, IX
*/
plus_fruitSuper:
;   RESET GHOST FLASH COUNTER
    XOR A
    LD (flashCounter), A
;   CHANGE PAC-MAN'S SPRITE NUMBER
    INC A   ; $01
    LD (pacman.sprTableNum), A
;   SET GHOST POINT INDEX TO START AT 1 (400)
    LD (ghostPointIndex), A
;   NOTIFY ACTORS
    CALL pacGameTrans_super
    LD IX, blinky
    CALL ghostGameTrans_super
    LD IX, pinky
    CALL ghostGameTrans_super
    LD IX, inky
    CALL ghostGameTrans_super
    LD IX, clyde
    CALL ghostGameTrans_super
;   SET INVISIBLE FLAGS OF GHOSTS
    LD A, $01
    LD (blinky + INVISIBLE_FLAG), A
    LD (pinky + INVISIBLE_FLAG), A
    LD (inky + INVISIBLE_FLAG), A
    LD (clyde + INVISIBLE_FLAG), A
;   SWITCH STATE TO SUPER
    LD (pacPoweredUp), A
;   SET POWER DOT'S TIME
    LD HL, (plusFruitSuperTime)
    LD (mainTimer1), HL
    RET
