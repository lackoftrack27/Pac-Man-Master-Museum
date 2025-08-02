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
    LD A, MUS_START ; ASSUME MUSIC FOR PAC-MAN
    LD B, A
    LD A, (plusBitFlags)    ; ISOLATE MS. PAC BIT
    AND A, $01 << MS_PAC
    ADD A, B        ; ADD TO MUSIC ID
    CALL sndPlayMusic
;   DRAW "PLAYER ONE"
    CALL drawPlayerTilemap
;   DRAW "READY!"
    CALL drawReadyTilemap
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
;   REMOVE A LIFE
    CALL removeLifeonScreen
;   ERASE PLAYER TEXT
    LD HL, NAMETABLE + PLAYER_TEXT | VRAMWRITE
    RST setVDPAddress
    LD HL, workArea + $10
    LD BC, PLAYER_TEXT_SIZE * $100 + VDPDATA_PORT
    OTIR
;   SET IN MAZE TEXT COLOR TO YELLOW
    LD HL, BGPAL_TEXT | CRAMWRITE
    RST setVDPAddress
    LD A, CLR_YELLOW
    OUT (VDPDATA_PORT), A
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
    LD (mainTimer0), A
;   CLEAR NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   SET VDP ADDRESS FOR MAZE TEXT COLOR...
    LD HL, BGPAL_TEXT | CRAMWRITE
    RST setVDPAddress
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    JR NZ, +  ; IF SO, SKIP...
    ; SET IN MAZE TEXT COLOR
    LD A, CLR_YELLOW
    OUT (VDPDATA_PORT), A
    ; DRAW "READY!"
    CALL drawReadyTilemap
    JR ++
+:
    ; SET IN MAZE TEXT COLOR
    LD A, CLR_RED
    OUT (VDPDATA_PORT), A
    ; DRAW "GAME  OVER"
    CALL drawGameOverTilemap
++:
    ; CHECK IF PAC-MAN HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    CALL NZ, removeLifeonScreen ; IF SO, DECREMENT LIFE
;   ENABLE SPRITES
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, $C0
    OUT (VDPDATA_PORT), A
;   SIGNAL TO CLEAR SUPER PAC-MAN SPRITE AREA
    LD A, $02
    LD (pacSprControl), A
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
    ; ELSE...
    ; ERASE READY TEXT - ROW 0
    LD HL, NAMETABLE + READY_TEXT_ROW0 | VRAMWRITE
    RST setVDPAddress
    LD HL, workArea + $10 + PLAYER_TEXT_SIZE
    LD BC, READY_TEXT_SIZE * $100 + VDPDATA_PORT
    OTIR
    EX DE, HL   ; SAVE HL (workArea ptr)
    ; ERASE READY TEXT - ROW 1
    LD HL, NAMETABLE + READY_TEXT_ROW1 | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; RESTORE
    LD B, READY_TEXT_SIZE
    OTIR
@@end:
    RET