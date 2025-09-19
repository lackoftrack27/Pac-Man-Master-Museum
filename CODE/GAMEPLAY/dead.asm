/*
-------------------------------------------------------
                    DEAD 00 MODE
-------------------------------------------------------
*/
sStateGameplayTable@dead00Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   RESET GHOST POINT SPRITE NUM
    LD (ghostPointSprNum), A
;   SET TIMER
    LD A, DEAD00_TIMER_LEN
    LD (mainTimer0), A
;   TURN OFF GHOST FLASH
    LD HL, flashCounter
    RES 5, (HL)
;   STOP SOUNDS
    LD B, $01
    CALL sndStopChannel
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   CHECK FOR ALL DOTS EATEN (IN CASE OF DYING ON LAST DOT)
    CALL allDotsEatenCheck
;   GHOST VISUAL COUNTERS
    CALL ghostVisCounterUpdate
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   SET SUBSTATE TO DEAD01, SET NEW-STATE-FLAG
    LD HL, $01 * $100 + GAMEPLAY_DEAD01
    LD (subGameMode), HL
    RET



/*
-------------------------------------------------------
                    DEAD 01 MODE
-------------------------------------------------------
*/
sStateGameplayTable@dead01Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   REMOVE ACTORS FROM SCREEN
    ; MOVE OFFSCREEN
    LD H, A
    LD L, A
    LD (blinky + X_WHOLE), HL
    LD (pinky + X_WHOLE), HL
    LD (inky + X_WHOLE), HL
    LD (clyde + X_WHOLE), HL
    LD (fruit + X_WHOLE), HL
    LD (fruit + Y_WHOLE), HL
    ; SET OFFSCREEN FLAGS
    INC A
    LD (blinky + OFFSCREEN_FLAG), A
    LD (pinky + OFFSCREEN_FLAG), A
    LD (inky + OFFSCREEN_FLAG), A
    LD (clyde + OFFSCREEN_FLAG), A
    LD (fruit + OFFSCREEN_FLAG), A
;   CLEAR LOWER NIBBLE OF FRUIT STATUS
    LD HL, currPlayerInfo.fruitStatus
    LD A, (HL)
    AND A, $F0
    LD (HL), A
;   SET TIMER
    LD A, DEAD01_TIMER_LEN
    LD (mainTimer0), A
;   NOTIFY PAC-MAN
    CALL pacGameTrans_dead
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   UPDATE PAC-MAN
    LD HL, pacStateTable@update
    LD A, (pacman.state)
    RST jumpTableExec
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   SET SUBSTATE TO DEAD02, SET NEW-STATE-FLAG
    LD HL, $01 * $100 + GAMEPLAY_DEAD02
    LD (subGameMode), HL
    RET




/*
-------------------------------------------------------
                    DEAD 02 MODE
-------------------------------------------------------
*/
sStateGameplayTable@dead02Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   SET TIMER
    LD A, DEAD02_TIMER_LEN
    LD (mainTimer0), A
;   PLAY DEATH SOUND
    LD A, SFX_DEATH     ; ASSUME SFX FOR PAC-MAN
    LD B, A
    LD A, (plusBitFlags)    ; ISOLATE MS.PAC AND JR.PAC BITS
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    ADD A, B            ; ADD TO MUSIC ID
    LD B, $01           ; CHANNEL 1
    CALL sndPlaySFX
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   UPDATE PAC-MAN
    LD HL, pacStateTable@update
    LD A, (pacman.state)
    RST jumpTableExec
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   CLEAR MUTATED DOTS (JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    CALL NZ, removeMDots
;   SET DEATH FLAG
    LD A, $01
    LD (currPlayerInfo.diedFlag), A
;   CHECK IF THAT WAS LAST LIFE
    LD A, (currPlayerInfo.lives)
    OR A
    JR NZ, +    ; IF NOT, SKIP...
;   SWITCH TO GAME OVER
    LD HL, $01 * $100 + GAMEPLAY_GAMEOVER
    LD (subGameMode), HL
    RET
+:
;   CHECK IF TWO PLAYER MODE IS ENABLED
    LD HL, playerType
    BIT PLAYER_MODE, (HL)
    JR Z, + ; IF NOT, SKIP...
@@@swapPlayers:
;   TOGGLE CURRENT PLAYER BIT (BIT 1)
    LD A, $01 << CURR_PLAYER
    XOR A, (HL)
    LD (HL), A
;   SWAP PLAYER DATA (NON MAZE STUFF)
    LD IX, currPlayerInfo
    LD IY, altPlayerInfo
    LD B, _sizeof_playerInfo
-:
    LD E, (IX + 0)
    LD D, (IY + 0)
    LD (IY + 0), E
    LD (IX + 0), D
    INC IX
    INC IY
    DJNZ -
;   SWAP PLAYER DATA (MAZE STUFF)
    LD IX, mazeGroup1   ; CURRENT PLAYER
    LD IY, mazeGroup2   ; ALT PLAYER
    LD BC, _sizeof_mazeGroup1
-:
    LD E, (IX + 0)
    LD D, (IY + 0)
    LD (IY + 0), E
    LD (IX + 0), D
    INC IX
    INC IY
    CPI
    JP PE, -
+:
;   SWITCH TO SECOND READY MODE
    LD HL, $01 * $100 + GAMEPLAY_READY01
    LD (subGameMode), HL
;   GENERAL GAMEPLAY RESET
    JP generalResetFunc