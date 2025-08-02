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
    ; CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
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
    USES: AF, B, DE, HL, IX
*/
ghostDotReleaser:
;   PREPARE LOOP
    LD IX, pinky
    LD B, $03
    LD DE, _sizeof_ghost
;   CHECK IF PAC-MAN HAS DIED IN LEVEL (OR HASN'T EATEN ENOUGH DOTS POST DEATH)
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JR NZ, @globalCount ; IF SO, CHECK GLOBAL COUNTERS
-:
    ; CHECK IF GHOST IS AT HOME
    LD A, (IX + STATE)
    CP A, GHOST_REST
    JR NZ, @nextGhost   ; IF NOT, CHECK NEXT GHOST
    ; CONVERT ID INTO OFFSET
    LD A, (IX + ID)
    DEC A
    ; ADD STATE TO BASE TABLE
    LD HL, personalDotCounts
    RST addToHL
    ; CHECK TO SEE IF GHOST'S DOT COUNTER IS [GREATER OR EQUAL] TO THEIR SET LIMIT
    LD A, (IX + DOT_COUNTER)
    CP A, (HL)
    JR NC, @exit    ; IF SO, RELEASE GHOST
@nextGhost:
    ; POINT TO NEXT GHOST
    ADD IX, DE
    DJNZ -  ; KEEP LOOPING UNTIL GHOSTS ARE CHECKED
    RET
@globalCount:
    ; CHECK IF GHOST IS AT HOME
    LD A, (IX + STATE)
    CP A, GHOST_REST
    JR NZ, @next   ; IF NOT, CHECK NEXT GHOST
    ; CONVERT ID INTO OFFSET
    LD A, (IX + ID)
    DEC A
    ; ADD STATE TO BASE TABLE
    LD HL, globalDotCounterTable
    RST addToHL
    ; CHECK TO SEE IF GLOBAL DOT COUNTER IS [ONLY EQUAL] TO THEIR SET LIMIT
    LD A, (globalDotCounter)
    CP A, (HL)
    JR Z, + ; IF SO, SKIP...
@next:
    ; POINT TO NEXT GHOST
    ADD IX, DE
    DJNZ @globalCount  ; KEEP LOOPING UNTIL GHOSTS ARE CHECKED
    RET
+:
    ; CHECK IF GHOST BEING RELEASED IS CLYDE
    LD A, B
    DEC A           ; IF COUNTER IS 1
    JR NZ, @exit    ; IF NOT, SKIP..
    ; RESET GLOBAL DOT COUNTER FLAG (SWITCH BACK TO PERSONAL DOT COUNTERS)
    LD (currPlayerInfo.diedFlag), A
@exit:
;   SWITCH TO "GOTO EXIT" MODE
    LD (IX + STATE), GHOST_GOTOEXIT
    LD (IX + NEW_STATE_FLAG), $01
    RET




/*
    INFO: UPDATES A GHOST'S STATE AFTER IT HAS BEEN EATEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
ghostUpdateDeadState:
;   CHECK IF BIT 7 IS SET OF EAT SUBSTATE
    LD A, (eatSubState)
    OR A
    RET P       ; IF NOT, EATING HASN'T JUST FINISHED
;   DETERMINE WHICH GHOST WAS EATEN
    AND A, $7F  ; CLEAR BIT 7
    SUB A, $05
    RRCA
    RRCA
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
    LD IX, blinky
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (IX + STATE)
    OR A
    JR NZ, +    ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   PINKY
    LD IX, pinky
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (IX + STATE)
    OR A
    JR NZ, +    ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   INKY
    LD IX, inky
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (IX + STATE)
    OR A
    JR NZ, +    ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   CLYDE
    LD IX, clyde
    ; CHECK IF GHOST IS OUTSIDE OF HOME (BUT NOT GOING TO HOME)
    LD A, (IX + STATE)
    OR A
    RET NZ      ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    RET Z       ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    JP jumpTableExec



/*
    INFO: UPDATES GHOSTS IF THEY ARE GOING TO HOME
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
ghostToHomeUpdate:
;   BLINKY
    LD IX, blinky
    ; CHECK IF GHOST IS GOING HOME
    LD A, (IX + STATE)
    OR A
    JR Z, +     ; IF NOT, SKIP
    CP A, GHOST_REST
    JR NC, +    ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   PINKY
    LD IX, pinky
    ; CHECK IF GHOST IS GOING HOME
    LD A, (IX + STATE)
    OR A
    JR Z, +     ; IF NOT, SKIP
    CP A, GHOST_REST
    JR NC, +    ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   INKY
    LD IX, inky
    ; CHECK IF GHOST IS GOING HOME
    LD A, (IX + STATE)
    OR A
    JR Z, +     ; IF NOT, SKIP
    CP A, GHOST_REST
    JR NC, +    ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   CLYDE
    LD IX, clyde
    ; CHECK IF GHOST IS GOING HOME
    LD A, (IX + STATE)
    OR A
    RET Z       ; IF NOT, SKIP
    CP A, GHOST_REST
    RET NC      ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
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
    LD IX, blinky
    ; CHECK IF GHOST IS IN HOME
    LD A, (IX + STATE)
    CP A, GHOST_REST
    JR C, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   PINKY
    LD IX, pinky
    ; CHECK IF GHOST IS IN HOME
    LD A, (IX + STATE)
    CP A, GHOST_REST
    JR C, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   INKY
    LD IX, inky
    ; CHECK IF GHOST IS IN HOME
    LD A, (IX + STATE)
    CP A, GHOST_REST
    JR C, +     ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    RST jumpTableExec
+:
;   CLYDE
    LD IX, clyde
    ; CHECK IF GHOST IS IN HOME
    LD A, (IX + STATE)
    CP A, GHOST_REST
    RET C       ; IF NOT, SKIP
    ; ELSE, UPDATE GHOST
    LD HL, ghostStateTable@update
    JP jumpTableExec
