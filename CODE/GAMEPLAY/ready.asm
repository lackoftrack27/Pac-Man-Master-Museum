; -------------------------------------------------------
;                     READY 00 MODE
; -------------------------------------------------------
Ready00Mode:
@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @draw    ; IF NOT, SKIP TRANSITION CODE
@enter:
;   LOAD STATE TIMER
    LD A, READY00_TIMER_LEN          ; SET TIMER 0 FOR HOW LONG THIS STATE WILL LAST
    CALL setTickTimer0
;   CLEAR NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   PLAY START MUSIC
    LD A, MUS_START ; ASSUME MUSIC FOR PAC-MAN
    LD HL, plusBitFlags
    BIT MS_PAC, (HL)
    JR Z, +
    LD A, MUS_START_MS
+:
    BIT JR_PAC, (HL)
    JR Z, +
    LD A, MUS_START_JR
+:
    CALL sndPlayMusic
;   DRAW STATIC MAZE TEXT
    CALL drawPlayerTilemap  ; DRAW "PLAYER ONE"
    CALL drawReadyTilemap   ; DRAW "READY!"
@draw:
;   DRAW 1UP
    CALL draw1UP
@update:
;   DECREMENT TIMER 0
    CALL tickTimer0
    RET NZ  ; IF NOT 0, EXIT...
@exit:
;   SET SUBSTATE TO READY01, SET NEW-STATE-FLAG
    LD HL, READY_FROM_START * $100 + GAMEPLAY_READY01
    LD (subGameMode), HL
;   REMOVE A LIFE
    CALL removeLifeonScreen
;   PREPARE FOR SECOND READY STATE DIFFERENTLY DEPENDING ON GAME...
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @jrExit
;   PREPARE FOR SECOND READY STATE (PAC/MS.PAC)
    ; ERASE PLAYER TEXT (PAC/MS.PAC)
    LD HL, SPRITE_TABLE + $01 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
.REPEAT $08
    OUT (VDPDATA_PORT), A
.ENDR
    ; RESTORE GHOST TILES (PAC/MS.PAC)
    LD HL, SPRITE_ADDR + PAC_VRAM + $80 | VRAMWRITE
    RST setVDPAddress
    LD HL, playerSprBuffer
    LD BC, $80 * $100 + VDPDATA_PORT
    OTIR
    RET
@jrExit:
;   PREPARE FOR SECOND READY STATE (JR.PAC)
    ; RESTORE MAZE TILEMAP (JR)
    LD C, VDPCON_PORT
        ; PLAYER ROW 0
    LD DE, NAMETABLE + ($0C * $02) + ($08 * $40) | VRAMWRITE
    OUT (C), E
    OUT (C), D
    DEC C
    LD HL, mazeTextBuffer
    LD B, $12
    OTIR
        ; PLAYER ROW 1
    INC C
    LD DE, NAMETABLE + ($0C * $02) + ($09 * $40) | VRAMWRITE
    OUT (C), E
    OUT (C), D
    DEC C
    LD B, $12
    OTIR
    RET



; -------------------------------------------------------
;                     READY 01 MODE
; -------------------------------------------------------

Ready01Mode:
@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @draw    ; IF NOT, SKIP TRANSITION CODE
@enter:
;   GET TABLE ENTRY FOR THIS GAME AND WHERE WE CAME FROM (NEW-STATE-FLAG IS ONE OF READY_FROM_*)
    DEC A
    LD C, A     ; 0 - 3
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    ADD A, A    ; 4 ENTRIES PER GAME
    ADD A, C
    ADD A, A    ; 2 BYTES PER ENTRY
    LD HL, SecondReadyTimerTable
    RST addToHL
    LD B, A     ; B: HOW LONG THIS STATE WILL LAST
    INC HL
;   OG'S TICK COUNTER [$4C86] RUNS THROUGH THE WHOLE TRANSITION. OURS MISSES THE MAZE RELOAD AND THE PART
;   OF READY THAT WAS CUT TO MAKE UP FOR IT, SO GIVE THE 1 SEC COUNT THE 1/10 SEC TICKS IT MISSED
    LD A, (tickTenths)
    SUB A, (HL)
    JR NC, +
    ADD A, TICK_TENTHS
+:
    LD (tickTenths), A
;   PAC-MAN / MS.PAC-MAN AFTER A DEATH: OG'S TIMER STARTED BEFORE THE RELOAD AND COUNTS 1/10 SEC TICKS,
;   SO ADD THE FRAMES LEFT UNTIL THE NEXT TICK
    LD A, C
    CP A, READY_FROM_DEATH - $01
    JR NZ, +
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, +
    LD A, (tickFrames)
    ADD A, B
    LD B, A
+:
;   LOAD STATE TIMER
    LD A, B
    LD (mainTimer0), A
;   CLEAR NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   DRAW MAZE TEXT
    LD HL, drawReadyTilemap     ; ASSUME WE WILL DRAW 'READY!'
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT       ; CHECK IF WE ACTUALLY WILL (GAME ISN'T IN DEMO MODE)
    JR NZ, +
    LD HL, drawGameOverTilemap  ; IF NOT, DRAW 'GAME  OVER'
+:
    CALL indirectHLCall
;   REMOVE A LIFE IF PLAYER DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    CALL NZ, removeLifeonScreen
@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@update:
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@exit:
;   SWITCH TO NORMAL MODE AND SETUP
    LD HL, $01 * $100 + GAMEPLAY_NORMAL
    LD (subGameMode), HL
;   OG ALWAYS STARTS PLAY RIGHT ON A 1/10 SEC TICK (ALL OF ITS TIMERS UP TO HERE COUNT TICKS), SO DO THE SAME.
;   GHOST EAT PAUSE, FRUIT TIMES AND THE LEVEL COMPLETE WAIT DEPEND ON WHERE THE TICKS FALL
    LD A, TICK_FRAMES - 1
    LD (tickFrames), A
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    RET NZ  ; IF SO, SKIP...
;   REMOVE 'READY!' TEXT ON BG LAYER IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @end     ; ELSE, SKIP
    LD BC, $0A * $100 + VDPCON_PORT
    LD DE, NAMETABLE + ($0E * $02) + ($0D * $40) | VRAMWRITE
    OUT (C), E
    OUT (C), D
    DEC C
    LD HL, mazeTextBuffer + $24
    OTIR
@end:
    ; DISABLE UNNEEDED SPRITES
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
    RET



;   FOR EACH GAME AND EACH OF READY_FROM_LEVEL, READY_FROM_START, READY_FROM_DEATH, READY_FROM_CUT:
;   HOW LONG THIS STATE LASTS, 1/10 SEC TICKS OG'S COUNTER GETS AHEAD OF OURS BY (MEASURED AGAINST OG)
SecondReadyTimerTable:
    ; PAC-MAN
    .DB READY01_TIMER_LEN_PAC_LVL, 4
    .DB READY01_TIMER_LEN - 1, 0        ; (GAME START: TICKS DON'T MATTER)
    .DB READY01_TIMER_LEN_PAC_DEAD, 4
    .DB READY01_TIMER_LEN_PAC_CUT, 7
    ; MS.PAC-MAN
    .DB READY01_TIMER_LEN_MS_LVL, 4
    .DB READY01_TIMER_LEN - 1, 0
    .DB READY01_TIMER_LEN_PAC_DEAD, 4
    .DB READY01_TIMER_LEN_MS_CUT, 5
    ; JR.PAC-MAN (NOTHING IN JR USES THE 1 SEC COUNT. FIRST CUTSCENE WOULD NEED 6)
    .DB READY01_TIMER_LEN_JR_LVL, 6
    .DB READY01_TIMER_LEN_JR, 0
    .DB READY01_TIMER_LEN_JR_DEAD, 6
    .DB READY01_TIMER_LEN_JR_LVL, 4