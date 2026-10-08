; -------------------------------------------------------
;                     GAMEOVER MODE
; -------------------------------------------------------
GameoverMode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @draw    ; IF NOT, SKIP TRANSITION CODE
@enter:
;   RESET NEW STATE FLAG AND VBLANK FLAG
    XOR A
    LD (isNewState), A
    LD (vblankFlag), A  ; ENTER TRANSITION WILL TAKE TOO MUCH TIME
;   SET TIMER
    LD A, GOVER_TIMER_LEN
    LD (mainTimer0), A
    ; DO 1/10 SEC TICKS IF IN 2P MODE
    LD A, (playerType)
    RRCA
    CALL C, tickTimer0
    LD HL, tickFlags
    RES TICK_TIMER0, (HL)
;   REMOVE ALL SPRITES
    LD HL, SPRITE_TABLE + $01 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    LD B, $07 * $04
-:
    OUT (VDPDATA_PORT), A
    DJNZ - 
;   WRITE "PLAYER ONE/TWO" TILES TO VRAM (IF GAME ISN'T JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @displayTileMaps
    ; SET VDP ADDRESS
    LD HL, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    RST setVDPAddress
    ; WRITE TO VRAM
    LD HL, mazeTxtTilePLAYER
    LD A, bank(mazeTxtTilePLAYER)
    LD (MAPPER_SLOT2), A
    LD BC, VDPDATA_PORT     ; 8 TILES ("PLAYER ONE")
    OTIR
    LD B, $03 * TILE_SIZE   ; 3 TILES ("TWO")
    OTIR
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
@displayTileMaps:
;   DISPLAY "PLAYER ONE" OR "PLAYER TWO" IF IN 2 PLAYER MODE
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
;   SAVE HIGH SCORE TO SRAM
    JP saveScoreToSRAM
@draw:
;   LATCH SCROLL VALUE FOR H-INT
    LD A, (jrScrollReal)
    LD (jrScrollVDP), A
;   UPDATE NEW COLUMN FOR SCROLLING (FLAG MUST BE SET && GAME MUST BE JR)
    LD HL, updateColFlag
    LD A, (plusBitFlags)    ; JR_PAC
    RRCA    ; BIT 2 -> BIT 0
    RRCA
    AND A, (HL)
    CALL NZ, drawNewColumn
;   DRAW 1UP
    CALL draw1UP
@update:
;   MOVE SCREEN TO CENTER (IF GAME IS JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    CALL NZ, centerJRScroll
;   DECREMENT TIMER 0
    CALL tickTimer0
    RET NZ  ; IF NOT 0, EXIT...
@exit:
;   PREPARE FOR NEXT GAME STATE
    ; CHECK IF TWO PLAYER MODE IS ENABLED
    LD HL, playerType
    BIT PLAYER_MODE, (HL) 
    JR Z, @resetGame
    RES PLAYER_MODE, (HL)   ; SET TO 1 PLAYER MODE
    CALL swapPlayerData     ; SWAP PLAYER DATA
    ; ACCOUNT FOR TICK DIFFERENCE WHEN SWAPPING PLAYERS
    LD HL, tickTenths
    LD A, (HL)
    ADD A, GOVER_TICKS_BACK
    CP A, TICK_TENTHS
    JR C, +
    SUB A, TICK_TENTHS
+:
    LD (HL), A
    LD HL, READY_FROM_DEATH * $100 + GAMEPLAY_READY01
    LD (subGameMode), HL    ; SWITCH TO SECOND READY STATE
    JP generalResetFunc     ; GENERAL GAMEPLAY RESET
@resetGame:
    ; IF NOT, RESET GAME
    POP HL  ; REMOVE FSM CALLER
    ; TURN OFF SCREEN, KEEP VBLANK ON
    CALL turnOffScreenVBlank
    DI      ; DISABLE INTS
    JP resetFromGameOver