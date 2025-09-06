/*
-------------------------------------------------------
                    READY 00 MODE
-------------------------------------------------------
*/
sStateGameplayTable@ready00Mode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   LOAD STATE TIMER
    LD A, READY00_TIMER_LEN          ; SET TIMER 0 FOR HOW LONG THIS STATE WILL LAST
    LD (mainTimer0), A
;   CLEAR NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   PLAY START MUSIC
    LD HL, plusBitFlags
    LD A, MUS_START ; ASSUME MUSIC FOR PAC-MAN
    BIT MS_PAC, (HL)
    JR Z, +
    LD A, MUS_START_MS
+:
    BIT JR_PAC, (HL)
    JR Z, +
    LD A, MUS_START_JR
+:
    CALL sndPlayMusic
;   DRAW "PLAYER ONE"
    CALL drawPlayerTilemap
;   DRAW "READY!"
    CALL drawReadyTilemap
@@draw:
;   DRAW 1UP
    CALL draw1UP    ; !!!
@@update:
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   ERASE PLAYER TEXT
    LD HL, SPRITE_TABLE + $01 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
.REPEAT $08
    OUT (VDPDATA_PORT), A
.ENDR
;
    LD HL, SPRITE_ADDR + PAC_VRAM + $80 | VRAMWRITE
    RST setVDPAddress
    LD HL, workArea
    LD BC, $80 * $100 + VDPDATA_PORT
    OTIR
;   REMOVE A LIFE
    CALL removeLifeonScreen
;   SET SUBSTATE TO READY01, SET NEW-STATE-FLAG
    LD HL, $01 * $100 + GAMEPLAY_READY01
    LD (subGameMode), HL
@@end:
    RET


/*
-------------------------------------------------------
                    READY 01 MODE
-------------------------------------------------------
*/
sStateGameplayTable@ready01Mode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   LOAD STATE TIMER
    LD A, READY01_TIMER_LEN          ; SET TIMER 0 FOR HOW LONG THIS STATE WILL LAST
    LD HL, plusBitFlags
    BIT JR_PAC, (HL)
    JR Z, +
    LD A, READY01_TIMER_LEN_JR
+:
    LD (mainTimer0), A
;   CLEAR NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   DRAW MAZE TEXT
    ; SETUP RETURN ADDRESS
    LD HL, @@@afterTextDraw
    PUSH HL
    ; CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT
    JP Z, drawGameOverTilemap   ; IF SO, DRAW 'GAME  OVER' (VIA TILEMAP)
    JP drawReadyTilemap         ; ELSE, DRAW 'READY' (VIA SPRITES)
    ; RETURN HERE
@@@afterTextDraw:
    ; CHECK IF PAC-MAN HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    CALL NZ, removeLifeonScreen ; IF SO, DECREMENT LIFE
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
    ; SWITCH TO NORMAL MODE AND SETUP
    LD HL, $01 * $100 + GAMEPLAY_NORMAL
    LD (subGameMode), HL
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    RET NZ  ; IF SO, SKIP...
    ; ELSE, ERASE READY TEXT
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    LD B, $05
-:
    OUT (VDPDATA_PORT), A
    DJNZ -
@@end:
    RET