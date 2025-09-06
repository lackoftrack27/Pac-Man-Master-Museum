/*
-------------------------------------------------------
                    TITLE MODE
-------------------------------------------------------
*/
sStateAttractTable@titleMode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CLEAR FLAG
    XOR A
    LD (isNewState), A
;   CLEAR PLAYER MODE BIT (1 PLAYER)
    LD HL, playerType
    RES 0, (HL)
;   SET LINE
    LD (lineMode), A    ; WHAT LINE IS SELECTED.        0 - "1 PLAYER", 1 - "2 PLAYERS", 2 - "OPTIONS"
;   ANIMATION COUNTER
    LD (pacAniCounter), A
;   SET INACTIVITY TIMER
    CALL setInactivityTimer
;   TURN OFF SCREEN (AND VBLANK INTS)
    CALL turnOffScreen
;   LOAD TILEMAP
    LD DE, NAMETABLE | VRAMWRITE
    LD HL, titleTileMap
    CALL zx7_decompressVRAM
;   LOAD SPRITES
    ; ARROWS
    LD DE, SPRITE_ADDR + TILE_SIZE | VRAMWRITE
    LD HL, titleArrowData
    CALL zx7_decompressVRAM
;   LOAD BACKGROUND TILES
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, titleTileData
    CALL zx7_decompressVRAM
;   LOAD BACKGROUND PALETTE
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD HL, titlePal
    LD BC, BG_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   LOAD SPRITE PALETTE
    LD HL, sprPalData
    LD B, SPR_CRAM_SIZE
    OTIR
;   REMOVE "PLUS" IF BIT ISN'T SET
    LD HL, plusBitFlags
    BIT PLUS, (HL)
    CALL Z, plus_clrNametableArea
;   SET SELECTOR SPRITE
    CALL titleToggleModes@noToggle
    LD HL, playerTileList
    LD DE, P1_SPR_POS
    LD (pacPos), DE
    XOR A
    CALL display4TileSprite     ; SETUP SPRITE IN SAT
;   DISABLE OTHER SPRITES
    LD HL, SPRITE_TABLE + $04 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   TURN ON DISPLAY
    CALL waitForVblank
    CALL turnOnScreen
@@draw:
;   DRAW SELECTOR SPRITE
    LD HL, playerTileList
    LD DE, (pacPos)
    XOR A
    CALL display4TileSprite
@@update:
    ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0B20 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
;   UPDATE SELECTOR SPRITE ANIMATION
    LD A, (pacAniCounter)
    AND A, $0F
    SRL A
    SRL A
    ADD A, A
    LD HL, (pacBase)        ; ADD TO BASE SPRITE TABLE
    RST addToHL
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    CALL pacTileStreaming@writeToVRAM
    LD HL, pacAniCounter    ; INCREMENT COUNTER
    INC (HL)
;   DECREMENT INACTIVITY TIMER
    LD HL, (mainTimer0)
    DEC HL
    LD (mainTimer0), HL
;   CHECK IF TIMER IS 0
    LD A, L
    OR A, H
    JR NZ, @@@titleUpdate   ; IF NOT, SKIP...
    ; ELSE, GO TO ATTRACT MODE
    LD HL, $01 * $100 + ATTRACT_INTRO
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC | $01 << JR_PAC | $01 << OTTO)
    BIT OTTO, A
    JR Z, +
    LD A, $03
+:
    RST addToHL
    LD (subGameMode), HL
    RET
@@@titleUpdate:
;   GET JUST PRESSED INPUTS
    CALL getPressedInputs
;   PREP FOR LINE PROCESSING
    LD HL, pressedButtons
;   CHECK IF LEFT OR RIGHT IS PRESSED
    BIT 2, (HL)
    JP NZ, titleToggleModes     ; IF SO, TOGGLE BETWEEN GAMES
    BIT 3, (HL)
    JP NZ, titleToggleModes     ; IF SO, TOGGLE BETWEEN GAMES
;   CHECK IF BUTTON 1 WAS PRESSED
    BIT 4, (HL)
    JP NZ, playCreditSnd    ; IF SO, PLAY CREDIT SOUND AND WAIT
;   CHECK IF BUTTON 2 WAS PRESSED (PLUS)
    BIT 5, (HL)
    JR Z, +     ; IF NOT, SKIP
    ; SET INACTIVITY TIMER
    CALL setInactivityTimer
    ; TOGGLE BIT 0 OF PLUS FLAGS
    LD HL, plusBitFlags
    LD A, $01 << PLUS
    XOR A, (HL)
    LD (HL), A
    BIT PLUS, A
    JP Z, plus_clrNametableArea
    JP plus_setNametableArea
+:
;   CHECK WHAT LINE IS SELECTED
    LD A, (lineMode)
    OR A
    JR Z, @@@onePlayerLine  ; LINE 0
    DEC A
    JR Z, @@@twoPlayerLine  ; LINE 1
    ; FALL THROUGH TO LINE 2

    


/*
    "OPTIONS" PROCESSING
*/
@@@optionsLine:
;   CHECK IF UP IS PRESSED
    BIT P1_DIR_UP, (HL)
    JR Z, +     ; IF NOT, SKIP
;   MOVE ARROW UP
    ; POINT TO "2 PLAYER"
    LD HL, P2_SPR_POS
    LD (pacPos), HL
    ; CHANGE LINE VAR
    LD A, $01
    LD (lineMode), A
    ; SET PLAYER MODE BIT (2 PLAYERS)
    LD HL, playerType
    SET 0, (HL)
    ; RENEW INACTIVITY TIMER
    JP setInactivityTimer
+:
;   CHECK IF DOWN IS PRESSED
    BIT P1_DIR_DOWN, (HL)
    RET Z       ; IF NOT, END
;   MOVE ARROW TO "1 PLAYER"
    JR @@@twoPlayerLine@p1Selected



/*
    "1 PLAYER" PROCESSING
*/
@@@onePlayerLine:
;   CHECK IF DOWN IS PRESSED
    BIT P1_DIR_DOWN, (HL)
    JR Z, + ; IF NOT, SKIP
;   MOVE ARROW DOWN
    ; POINT TO "2 PLAYER"
    LD HL, P2_SPR_POS
    LD (pacPos), HL
    ; CHANGE LINE VAR
    LD A, $01
    LD (lineMode), A
    ; SET PLAYER MODE BIT (2 PLAYERS)
    LD HL, playerType
    SET 0, (HL)
    ; RENEW INACTIVITY TIMER
    JP setInactivityTimer
+:
;   CHECK IF UP IS PRESSED
    BIT P1_DIR_UP, (HL)
    RET Z       ; IF NOT, END
;   MOVE ARROW TO "OPTIONS"
    JR @@@twoPlayerLine@optionSelected




/*
    "2 PLAYERS" PROCESSING
*/
@@@twoPlayerLine:
;   CHECK IF DOWN IS PRESSED
    BIT P1_DIR_DOWN, (HL)
    JR Z, +   ; IF NOT, CHECK UP
@@@@optionSelected:
;   MOVE ARROW DOWN
    ; POINT TO "OPTIONS"
    LD HL, OP_SPR_POS
    LD (pacPos), HL
    ; CHANGE LINE VAR
    LD A, $02
    LD (lineMode), A
    ; RENEW INACTIVITY TIMER
    JP setInactivityTimer
+:
;   CHECK IF UP IS PRESSED
    BIT P1_DIR_UP, (HL)
    RET Z       ; IF NOT, END
@@@@p1Selected:
;   MOVE ARROW UP
    ; POINT TO "1 PLAYER"
    LD HL, P1_SPR_POS
    LD (pacPos), HL
    ; CHANGE LINE VAR
    XOR A
    LD (lineMode), A
    ; CLEAR PLAYER MODE BIT (1 PLAYER)
    LD HL, playerType
    RES 0, (HL)
    ; RENEW INACTIVITY TIMER
    JP setInactivityTimer