/*
-------------------------------------------------------
                    GAMEOVER MODE
-------------------------------------------------------
*/
sStateGameplayTable@gameoverMode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   SET TIMER
    LD A, GOVER_TIMER_LEN
    LD (mainTimer0), A
;   REMOVE ALL SPRITES
    LD HL, SPRITE_TABLE + $01 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    LD B, $07
-:
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    DJNZ - 
;   WRITE "PLAYER ONE/TWO" TILES TO VRAM (IF GAME ISN'T JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @@@displayTileMaps
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
@@@displayTileMaps:
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
;   SAVE HIGH SCORE TO SRAM
    CALL saveScoreToSRAM
;   CAP PAC-MAN'S POSITION (ONLY USED IN JR FOR SCROLLING)
    LD HL, (pacman.xPos)
    LD DE, $015A
    OR A
    SBC HL, DE
    ADD HL, DE
    JR C, +
    LD (pacman.xPos), DE
    JR @@@enterEnd
+:
    LD DE, $007A
    OR A
    SBC HL, DE
    JR NC, @@@enterEnd
    LD (pacman.xPos), DE
@@@enterEnd:
    ; TOOK LONGER THAN A FRAME, SO CLEAR VBLANK FLAG
    XOR A
    LD (vblankFlag), A
    RET 
@@draw:
;   UPDATE NEW COLUMN FOR SCROLLING (FLAG MUST BE SET && GAME MUST BE JR)
    LD HL, updateColFlag
    LD A, (plusBitFlags)    ; JR_PAC
    RRCA    ; BIT 2 -> BIT 0
    RRCA
    AND A, (HL)
    CALL NZ, drawNewColumn
;   DRAW 1UP
    CALL draw1UP
@@update:
;   MOVE SCREEN TO CENTER (IF GAME IS JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @@@updateTimer
    LD HL, (pacman.xPos)
    LD DE, $00E8
    SBC HL, DE
    ADD HL, DE
    JR Z, @@@updateTimer
    JR C, +
    DEC HL
    LD (pacman.xPos), HL
    JP @@@updateTimer
+:
    INC HL
    LD (pacman.xPos), HL
@@@updateTimer:
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
    ; TURN OFF SCREEN, KEEP VBLANK ON
    LD A, $A0
    OUT (VDPCON_PORT), A
    LD A, $81
    OUT (VDPCON_PORT), A
    DI      ; DISABLE INTS
    JP resetFromGameOver