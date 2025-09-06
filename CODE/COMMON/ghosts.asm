/*
------------------------------------------------
            GHOST RELATED FUNCTIONS
------------------------------------------------
*/


/*
    INFO: DETERMINES WHEN GHOST REVERSE DIRECTION AND CHANGE TARGETING ALGORITHM (SCATTER / CHASE)
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
scatterChaseCheck:
;   CHECK IF NORMAL
    LD A, (pacPoweredUp)
    OR A
    RET NZ  ; IF NOT, EXIT
;   CHECK IF INDEX IS 7 (LAST PHASE)
    LD A, (scatterChaseIndex)
    CP A, $07
    RET Z       ; IF SO, END
;   INCREMENT SCATTER/CHASE TIMER
    LD DE, (mainTimer2)
    INC DE
    LD (mainTimer2), DE
;   USE INDEX AS OFFSET INTO DURATION TABLE
    ADD A, A
    LD HL, (scatterChasePtr)
    RST addToHL
;   GET DURATION VALUE
    RST getDataAtHL
;   CHECK IF TIMER MATCHES VALUE
    OR A        ; CLEAR CARRY
    SBC HL, DE
    RET NZ      ; IF NOT, END
;   UPDATE INDEX
    LD HL, scatterChaseIndex
    ; CHECK IF GAME IS MS.PAC OR JR.PAC
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC | $01 << JR_PAC)
    JR Z, +         ; IF NOT, SKIP
    LD (HL), $00    ; ELSE, RESET INDEX TO 0
+:
    ; INCREMENT INDEX
    INC (HL)
;   NOTIFY ALL GHOSTS
    LD A, $01
    LD (blinky + REVE_FLAG), A
    LD (pinky + REVE_FLAG), A
    LD (inky + REVE_FLAG), A
    LD (clyde + REVE_FLAG), A
    RET




/*
    INFO: UPDATES GHOST'S DOT COUNTERS WHICH ARE USED TO DETERMINE WHEN TO LEAVE HOME
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, B, DE, HL
*/
ghostUpdateDotCounters:
;   CHECK IF PAC-MAN HAS DIED IN THIS LEVEL
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JR Z, +     ; IF NOT, SKIP...
;   ELSE, INCREMENT GLOBAL DOT COUNTER FOR GHOSTS
    LD HL, globalDotCounter
    INC (HL)
    RET
+:
;   UPDATE PERSONAL DOT COUNTERS
    LD B, GHOST_REST    ; STATE COMPARE
    ; CHECK IF CLYDE IS AT REST
    LD A, (clyde.state)
    CP A, B
    RET NZ  ; IF NOT, END...
    ; CHECK IF INKY IS AT REST
    LD A, (inky.state)
    CP A, B
    JR Z, + ; IF SO, SKIP...
    ; IF NOT, INCREMENT CLYDE'S DOT COUNTER
    LD HL, clyde.dotCounter
    INC (HL)
    RET
+:
    ; CHECK IF PINKY IS AT REST
    LD A, (pinky.state)
    CP A, B
    JR Z, + ; IF SO, SKIP...
    ; IF NOT, INCREMENT INKY'S DOT COUNTER
    LD HL, inky.dotCounter
    INC (HL)
    RET
+:
    ; INCREMENT PINKY'S DOT COUNTER
    LD HL, pinky.dotCounter
    INC (HL)
    RET



/*
    INFO: UPDATES DOT EXPIRE TIMER WHICH IS ALSO USED TO DETERMINE WHEN TO LEAVE HOME
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL, IX
*/
dotExpireUpdate:
;   CHECK IF DOTS EATEN MATCHES DOTS EATEN SINCE LAST MOVE
    LD HL, dotExpireCounter
    LD A, (currPlayerInfo.dotCount)
    CP A, (HL)
    LD HL, mainTimer4
    JR Z, +     ; IF SO, SKIP
    ; IF NOT, RESET DOT EXPIRE TIMER AND END
    LD (HL), $00
    RET
+:
;   INCREMENT DOT EXPIRE TIMER
    INC (HL)
;   CHECK IF IT MATCHES DOT EXPIRE LIMIT
    LD A, (dotExpireTime)
    CP A, (HL)
    RET NZ      ; IF NOT, RETURN
;   ELSE, RESET TIMER
    LD (HL), $00
;   NOTIFY GHOSTS
    LD IX, pinky
    CALL ghostGameTrans_dotExpire
    RET Z   ; IF PINKY WAS RELEASED, END...
    LD IX, inky
    CALL ghostGameTrans_dotExpire
    RET Z   ; IF INKY WAS RELEASED...
    LD IX, clyde
    JP ghostGameTrans_dotExpire
    





/*
    INFO: DETERMINES IF A GHOST CAN LEAVE HOME BASED ON PERSONAL OR GLOBAL DOT COUNTER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, HL
*/
ghostDotReleaser:
    LD B, GHOST_REST
    LD A, (plusBitFlags)
    LD C, A
;   DO DIFFERENT CHECKS IF PLAYER HAS DIED IN THE LEVEL
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JP Z, @pinky
@pinkyDiedFlag:
;   SKIP IF PINKY IS AT REST
    LD A, (pinky + STATE)
    CP A, B
    JP NZ, @inkyDiedFlag
;   CHECK IF GLOBAL DOT COUNTER == $07, >= $07 IF GAME IS JR
    LD A, (globalDotCounter)
    CP A, $07
    JP Z, +
    BIT JR_PAC, C
    JP Z, @inkyDiedFlag
    CP A, $07
    JP C, @inkyDiedFlag
;   RELEASE PINKY
+:
    LD A, GHOST_GOTOEXIT
    LD (pinky + STATE), A
    LD A, $01
    LD (pinky + NEW_STATE_FLAG), A
@inkyDiedFlag:
;   SKIP IF INKY IS AT REST
    LD A, (inky + STATE)
    CP A, B
    JP NZ, @clydeDiedFlag
;   CHECK IF GLOBAL DOT COUNTER == $11, >= $11 IF GAME IS JR
    LD A, (globalDotCounter)
    CP A, $11
    JP Z, +
    BIT JR_PAC, C
    JP Z, @clydeDiedFlag
    CP A, $11
    JP C, @clydeDiedFlag
;   RELEASE INKY
+:
    LD A, GHOST_GOTOEXIT
    LD (inky + STATE), A
    LD A, $01
    LD (inky + NEW_STATE_FLAG), A
@clydeDiedFlag:
;   END IF CLYDE IS AT REST
    LD A, (clyde + STATE)
    CP A, B
    RET NZ
;   CHECK IF GLOBAL DOT COUNTER == $20, >= $20 IF GAME IS JR
    LD A, (globalDotCounter)
    CP A, $20
    JP Z, +
    BIT JR_PAC, C
    RET Z
    CP A, $20
    RET C
;   RESET DIED FLAG AND GLOBAL DOT COUNTER
+:
    XOR A
    LD (currPlayerInfo.diedFlag), A
    LD (globalDotCounter), A
    RET
@pinky:
    LD HL, personalDotCounts
;   SKIP IF PINKY IS AT REST
    LD A, (pinky + STATE)
    CP A, B
    JP NZ, @inky
;   SKIP IF PINKY'S DOT COUNTER HASN'T REACHED SET LIMIT
    LD A, (pinky + DOT_COUNTER)
    CP A, (HL)
    JP C, @inky
;   RELEASE PINKY
    LD A, GHOST_GOTOEXIT
    LD (pinky + STATE), A
    LD A, $01
    LD (pinky + NEW_STATE_FLAG), A
@inky:
    INC HL
;   SKIP IF INKY IS AT REST
    LD A, (inky + STATE)
    CP A, B
    JP NZ, @clyde
;   SKIP IF INKY'S DOT COUNTER HASN'T REACHED SET LIMIT
    LD A, (inky + DOT_COUNTER)
    CP A, (HL)
    JP C, @clyde
;   RELEASE INKY
    LD A, GHOST_GOTOEXIT
    LD (inky + STATE), A
    LD A, $01
    LD (inky + NEW_STATE_FLAG), A
@clyde:
    INC HL
;   END IF CLYDE IS AT REST
    LD A, (clyde + STATE)
    CP A, B
    RET NZ
;   END IF CLYDE'S DOT COUNTER HASN'T REACHED SET LIMIT
    LD A, (clyde + DOT_COUNTER)
    CP A, (HL)
    RET C
;   RELEASE CLYDE
    LD A, GHOST_GOTOEXIT
    LD (clyde + STATE), A
    LD A, $01
    LD (clyde + NEW_STATE_FLAG), A
    RET




/*
    INFO: UPDATES A GHOST'S STATE AFTER IT HAS BEEN EATEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
ghostUpdateDeadState:
;   DETERMINE WHICH GHOST WAS EATEN
    AND A, $7F  ; CLEAR BIT 7
    DEC A
    ; 0-BLINKY,1-PINKY,2-INKY,3-CLYDE
    LD E, A     ; E = (SPR_NUM - 5) / 4
    LD H, _sizeof_ghost
    CALL multiply8Bit
    EX DE, HL
    LD IX, blinky
    ADD IX, DE
;   SET FLAGS FOR EATEN GHOST
    ; SET STATE TO "GO HOME"
    LD (IX + STATE), GHOST_GOTOHOME
    ; SET GHOST TO DEAD
    LD (IX + ALIVE_FLAG), $00
;   SHOW NEXT GHOST POINT VALUE
    LD HL, ghostPointIndex
    INC (HL)
;   RESET EAT SUB STATE
    XOR A
    LD (eatSubState), A
    RET



/*
    INFO: UPDATES GHOSTS IF THEY ARE OUTSIDE OF HOME
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
ghostOutHomeUpdate:
;   BLINKY
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (blinky + STATE)
    OR A
    JR NZ, +    ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    LD A, (blinky + ALIVE_FLAG)
    OR A
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, blinky
    CALL ghostStateTable@update@scatter
+:
;   PINKY
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (pinky + STATE)
    OR A
    JR NZ, +    ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    LD A, (pinky + ALIVE_FLAG)
    OR A
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, pinky
    CALL ghostStateTable@update@scatter
+:
;   INKY
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (inky + STATE)
    OR A
    JR NZ, +    ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    LD A, (inky + ALIVE_FLAG)
    OR A
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, inky
    CALL ghostStateTable@update@scatter
+:
;   CLYDE
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (clyde + STATE)
    OR A
    RET NZ      ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    LD A, (clyde + ALIVE_FLAG)
    OR A
    RET Z       ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, clyde
    JP ghostStateTable@update@scatter



/*
    INFO: UPDATES GHOSTS IF THEY ARE GOING TO HOME
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
ghostToHomeUpdate:
;   BLINKY
    ; CHECK IF GHOST IS GOING HOME
    LD A, (blinky + STATE)
    OR A
    JR Z, +     ; IF NOT, SKIP
    CP A, GHOST_REST
    JR NC, +    ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, blinky
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   PINKY
    ; CHECK IF GHOST IS GOING HOME
    LD A, (pinky + STATE)
    OR A
    JR Z, +     ; IF NOT, SKIP
    CP A, GHOST_REST
    JR NC, +    ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, pinky
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   INKY
    ; CHECK IF GHOST IS GOING HOME
    LD A, (inky + STATE)
    OR A
    JR Z, +     ; IF NOT, SKIP
    CP A, GHOST_REST
    JR NC, +    ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, inky
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   CLYDE
    ; CHECK IF GHOST IS GOING HOME
    LD A, (clyde + STATE)
    OR A
    RET Z       ; IF NOT, SKIP
    CP A, GHOST_REST
    RET NC      ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, clyde
    LD HL, ghostStateTable@update
    JP jumpTableExec



/*
    INFO: UPDATES GHOSTS IF THEY ARE INSIDE OF HOME
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
ghostHomeUpdate:
;   DON'T UPDATE DURING EAT
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   SPEED PATTERN FOR GHOSTS INSIDE HOME
    LD HL, inHomeSpdPatt
    RLC (HL)
    RET NC  ; RETURN IF NO CARRY FROM RIGHT SHIFT
;   BLINKY
    ; CHECK IF GHOST IS IN HOME
    LD A, (blinky + STATE)
    CP A, GHOST_REST
    JR C, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, blinky
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   PINKY
    ; CHECK IF GHOST IS IN HOME
    LD A, (pinky + STATE)
    CP A, GHOST_REST
    JR C, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, pinky
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   INKY
    ; CHECK IF GHOST IS IN HOME
    LD A, (inky + STATE)
    CP A, GHOST_REST
    JR C, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, inky
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   CLYDE
    ; CHECK IF GHOST IS IN HOME
    LD A, (clyde + STATE)
    CP A, GHOST_REST
    RET C       ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD IX, clyde
    LD HL, ghostStateTable@update
    JP jumpTableExec
