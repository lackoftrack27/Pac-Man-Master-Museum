/*
-------------------------------------------------------
                    GAMEOVER MODE
-------------------------------------------------------
*/
sStateGameplayTable@gameoverMode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   SET TIMER
    LD A, GOVER_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY "PLAYER ONE" OR "PLAYER TWO" IF IN 2 PLAYER MODE
    ; CHECK IF TWO PLAYER MODE IS ENABLED
    LD A, (playerType)
    BIT 0, A
    CALL NZ, drawPlayerTilemap  ; IF SO, DRAW
;   CLEAR POWER DOT PALETTE BUFFER
    LD HL, powDotPalette
    LD DE, powDotPalette + 1
    LD (HL), $00    ; $00
    LDI             ; $01
    LDI             ; $02
    LDI             ; $03
;   LOAD TILE MAP FOR "GAME OVER"
    CALL drawGameOverTilemap
;   SET V COUNTER
    LD A, $60   ; LINE: 95
    OUT (VDPCON_PORT), A
    LD A, $8A
    OUT (VDPCON_PORT), A
;   TURN ON LINE INTERRUPTS
    CALL turnOnLineInts
@@draw:
;   SET MAZE TEXT COLOR FOR "PLAYER ONE" / "PLAYER TWO"
    LD HL, BGPAL_TEXT | CRAMWRITE
    RST setVDPAddress
    LD A, CLR_CYAN
    OUT (VDPDATA_PORT), A
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   TURN OFF LINE INTERRUPTS (AND V COUNTER)
    CALL turnOffLineInts
;   SET MAZE TEXT COLOR FOR "GAME  OVER"
    LD HL, BGPAL_TEXT | CRAMWRITE
    RST setVDPAddress
    LD A, CLR_RED
    OUT (VDPDATA_PORT), A
;   CHECK IF TWO PLAYER MODE IS ENABLED
    LD HL, playerType
    BIT 0, (HL) 
    RES 0, (HL) ; SET TO 1 PLAYER MODE
    JP NZ, sStateGameplayTable@dead02Mode@@exit@swapPlayers  ; SWAP PLAYERS IF TWO PLAYER MODE WAS ENABLED
;   CLEAR STACK
    POP HL      ; REMOVE FSM CALLER
;   DISABLE INTS
    DI
;   GENERAL RESET
    JP resetFromGameOver