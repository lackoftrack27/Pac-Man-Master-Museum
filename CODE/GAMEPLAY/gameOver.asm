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
;   REMOVE PAC-MAN FROM SCREEN
    LD HL, SPRITE_TABLE + $01 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   REMOVE FRUIT FROM SCREEN
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   DISPLAY "PLAYER ONE" OR "PLAYER TWO" IF IN 2 PLAYER MODE
    ; CHECK IF TWO PLAYER MODE IS ENABLED
    LD A, (playerType)
    BIT PLAYER_MODE, A
    CALL NZ, drawPlayerTilemap  ; IF SO, DRAW
;   LOAD TILE MAP FOR "GAME OVER"
    CALL drawGameOverTilemap
;   CLEAR POWER DOT PALETTE INDEXES
    LD HL, ($0000 + BGPAL_PDOT0) | CRAMWRITE
    RST setVDPAddress
    XOR A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
@@draw:
;   DRAW 1UP
    CALL draw1UP    ; !!!
@@update:
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   CHECK IF TWO PLAYER MODE IS ENABLED
    LD HL, playerType
    BIT PLAYER_MODE, (HL) 
    RES PLAYER_MODE, (HL) ; SET TO 1 PLAYER MODE
    JP NZ, sStateGameplayTable@dead02Mode@@exit@swapPlayers  ; SWAP PLAYERS IF TWO PLAYER MODE WAS ENABLED
;   ELSE, RESET GAME
    POP HL  ; REMOVE FSM CALLER
    DI      ; DISABLE INTS
    JP resetFromGameOver