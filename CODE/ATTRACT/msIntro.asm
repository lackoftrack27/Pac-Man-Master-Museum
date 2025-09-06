/*
-------------------------------------------------------
            INTRO MODE FOR MS. PAC-MAN
-------------------------------------------------------
*/
sStateAttractTable@msIntroMode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   GENERAL INTRO MODE SETUP
    CALL generalIntroSetup00
;   INIT. MARQUEE PALETTE BUFFER
    LD HL, marqueePalStart
    LD DE, marqueePalBuffer
    LD BC, $0E
    LDIR
;   LOAD ATTRACT TILES
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, msIntroTileData
    CALL zx7_decompressVRAM
;   LOAD MARQUEE TILES
    LD DE, BACKGROUND_ADDR + (110 * $20) | VRAMWRITE
    LD HL, msMarqueeTileData
    CALL zx7_decompressVRAM
;   DISABLE SPRITES AT INDEX $15
    LD HL, SPRITE_TABLE + $15 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   DISPLAY "MS. PAC-MAN"
    LD HL, NAMETABLE + ($09 * 2) + ($03 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, msIntroPacTextOrg
    LD B, $0A
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR Z, +
    LD HL, msIntroPacTextOrgPlus
    INC B
+:
    CALL msIntroDisplayText
;   DISPLAY MIDWAY LOGO (PART 1)
    ; ROW 0
    LD HL, NAMETABLE + ($06 * 2) + ($12 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, msIntroMidLogo@row0
    LD B, $04
    CALL msIntroDisplayText
    ; ROW 1
    EX DE, HL
    LD HL, NAMETABLE + ($06 * 2) + ($13 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 1
    LD B, $04
    CALL msIntroDisplayText
;   DISPLAY @ MIDWAY MFG CO
    ; HL: COPYRIGHT TEXT
    LD B, $0C
    CALL msIntroDisplayText
;   DISPLAY MIDWAY LOGO (PART 2)
    ; ROW 2
    EX DE, HL
    LD HL, NAMETABLE + ($06 * 2) + ($14 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 2
    LD B, $04
    CALL msIntroDisplayText
    ; ROW 3
    EX DE, HL
    LD HL, NAMETABLE + ($06 * 2) + ($15 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 3
    LD B, $04
    CALL msIntroDisplayText
;   DISPLAY YEAR
    EX DE, HL
    LD HL, NAMETABLE + ($0C * 2) + ($15 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; YEAR
    LD B, $08
    CALL msIntroDisplayText
;   DISPLAY MARQUEE
    ; ROW 0
    LD HL, NAMETABLE + ($07 * 2) + ($06 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, msIntroMarquee
    LD B, $0E
    CALL introDisplayText
    EX DE, HL       ; DE: MARQUEE
    ; ROW 1
    LD HL, NAMETABLE + ($07 * 2) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL       ; HL: MARQUEE
    LD B, $0E
    CALL introDisplayText
    EX DE, HL       ; DE: MARQUEE
    ; ROW 2
    LD HL, NAMETABLE + ($07 * 2) + ($08 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL       ; HL: MARQUEE
    LD B, $0E
    CALL introDisplayText
    EX DE, HL       ; DE: MARQUEE
    ; ROW 3
    LD HL, NAMETABLE + ($07 * 2) + ($09 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL       ; HL: MARQUEE
    LD B, $0E
    CALL introDisplayText
    EX DE, HL       ; DE: MARQUEE
    ; ROW 4
    LD HL, NAMETABLE + ($07 * 2) + ($0A * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL       ; HL: MARQUEE
    LD B, $0E
    CALL introDisplayText
    EX DE, HL       ; DE: MARQUEE
    ; ROW 5
    LD HL, NAMETABLE + ($07 * 2) + ($0B * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL       ; HL: MARQUEE
    LD B, $0E
    CALL introDisplayText
;   GENERAL INTRO MODE SETUP 2
    CALL generalIntroSetup01
@@draw:
@@update:
;   SET UP PORT C, AND DELAY TO MOVE CRAM DOTS DOWN
    LD BC, VDPDATA_PORT
-:  DJNZ -
-:  DJNZ -

;   GET JUST PRESSED INPUTS
    CALL getPressedInputs
;   CHECK IF BUTTON 1 WAS PRESSED
    LD A, (pressedButtons)
    BIT 4, A
    JP NZ, sStateAttractTable@introMode@@exit ; IF SO, EXIT BACK TO TITLE
;   UPDATE GHOST VISUAL COUNTERS
    CALL ghostVisCounterUpdate
;   SET BG MARQUEE PALETTE (DONE HERE TO MOVE CRAM DOTS DOWN)
    LD HL, $0001 | CRAMWRITE
    RST setVDPAddress
    LD HL, marqueePalBuffer
    LD BC, $09 * $100 + VDPDATA_PORT
    OTIR        ; WRITE FIRST 9 BYTES
    LD A, $3F
    OUT (VDPDATA_PORT), A   ; WRITE HUD TEXT COLOR (WHITE)
    LD B, $03
    OTIR        ; WRITE REMAINING 3 BYTES
;   UPDATE MARQUEE PALETTE BUFFER
    ; SAVE LAST BYTE FOR LATER
    LD HL, marqueePalBuffer + $0B
    LD A, (HL)
    LD D, A
    ; RIGHT ROTATE BUFFER
    LD B, $0B
-:
    DEC HL
    LD A, (HL)
    INC HL
    LD (HL), A
    DEC HL
    DJNZ -
    LD (HL), D
;   SUB FUNCTION EXEC
    LD HL, msIntroSubTable
    LD A, (introSubState)
    RST jumpTableExec
    RET




/*
-----------------------------------------
    ROUTINE TABLE FOR INTRODUCTION [MS. PAC-MAN]
-----------------------------------------
*/
msIntroSubTable:
    .DW @wait00         ; WAIT 1 SECOND
    .DW @showBlinky
    .DW @showPinky
    .DW @showInky
    .DW @showSue
    .DW @showMsPac
    .DW @wait01         ; WAIT 2 SECONDS


/*
-----------------------------------------
                ROUTINES
-----------------------------------------
*/
msIntroSubTable@wait00:
;   DECREMENT TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; END IF NOT 0
;   PREPARE FOR NEXT STATE
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; DISPLAY WITH TEXT
    LD HL, NAMETABLE + ($09 * 2) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, msIntroWithText
    LD B, $04
    CALL msIntroDisplayText
    ; DISPLAY BLINKY TEXT
    LD DE, msIntroBlinkyText@row0
    CALL msIntroDisplayGhostText
    ; SET UP BLINKY
    XOR A
    LD IX, blinky
    JP msIntroSetupGhost

msIntroSubTable@showBlinky:
;   DRAW BLINKY
    LD IX, blinky
    CALL displayGhostNormal
;   MOVE BLINKY
    LD B, $4C + 2       ; Y LIMIT
    CALL msIntroMoveGhost
    RET NZ  ; IF MOVEMENT ISN'T COMPLETE
;   PREPARE FOR NEXT STATE
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; CLEAR WITH TEXT
    LD HL, NAMETABLE + ($09 * 2) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    XOR A
    LD B, $04
    -: 
    OUT (C), A
    OUT (C), A
    DJNZ -
    ; DISPLAY PINKY TEXT
    LD DE, msIntroPinkyText@row0
    CALL msIntroDisplayGhostText
    ; SET UP PINKY
    LD A, $01
    LD IX, pinky
    JP msIntroSetupGhost


msIntroSubTable@showPinky:
;   DRAW PINKY
    LD IX, pinky
    CALL displayGhostNormal
;   MOVE PINKY
    LD B, $4C + $10 + 2     ; Y LIMIT
    CALL msIntroMoveGhost
    RET NZ  ; IF MOVEMENT ISN'T COMPLETE
;   PREPARE FOR NEXT STATE
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; DISPLAY INKY TEXT
    LD DE, msIntroInkyText@row0
    CALL msIntroDisplayGhostText
    ; SET UP INKY
    LD A, $02
    LD IX, inky
    JP msIntroSetupGhost

msIntroSubTable@showInky:
;   DRAW INKY
    LD IX, inky
    CALL displayGhostNormal
;   MOVE INKY
    LD B, $4C + $20 + 2     ; Y LIMIT
    CALL msIntroMoveGhost
    RET NZ  ; IF MOVEMENT ISN'T COMPLETE
;   PREPARE FOR NEXT STATE
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; DISPLAY SUE TEXT
    LD DE, msIntroSueText@row0
    CALL msIntroDisplayGhostText
    ; SET UP SUE
    LD A, $03
    LD IX, clyde
    JP msIntroSetupGhost

msIntroSubTable@showSue:
;   DRAW SUE
    LD IX, clyde
    CALL displayGhostNormal
;   MOVE SUE
    LD B, $4C + $30 + 2     ; Y LIMIT
    CALL msIntroMoveGhost
    RET NZ  ; IF MOVEMENT ISN'T COMPLETE
;   PREPARE FOR NEXT STATE
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; DISPLAY STARRING TEXT
    LD HL, NAMETABLE + ($09 * 2) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, msIntroStarText
    LD B, $07
    CALL msIntroDisplayText
    ; DISPLAY MS. PAC-MAN TEXT
        ; ROW 0
    EX DE, HL
    LD HL, NAMETABLE + ($09 * 2) + ($09 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 0
    LD B, $08
    CALL msIntroDisplayText
        ; ROW 1
    EX DE, HL
    LD HL, NAMETABLE + ($09 * 2) + ($0A * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 1
    LD B, $08
    CALL msIntroDisplayText
    ; SET UP MS. PAC
    LD A, $FF
    LD IX, pacman
    JP msIntroSetupGhost    ; WRITES $00FF00 TO BLINKY'S UP COLLISION TILE


msIntroSubTable@showMsPac:
;   DRAW MS. PAC
    CALL pacTileStreaming
    CALL displayPacMan
;   UPDATE POSITION
    LD HL, pacman.xPos
    INC (HL)
;   CHECK IF MS. PAC IS AT WANTED POSITION
    LD A, $75
    CP A, (HL)
    RET NZ  ; IF NOT, END
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; SET TWO SECOND TIMER
    LD A, 120
    LD (mainTimer0), A
    RET

msIntroSubTable@wait01:
;   DECREMENT TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; END IF NOT 0
;   ELSE, PREPARE TO DO DEMO
    JP demoPrep



/*
---------------------------------------
            HELPER FUNCTIONS
---------------------------------------
*/
msIntroDisplayGhostText:
; DISPLAY GHOST'S NAME
    ; ROW 0
    LD HL, NAMETABLE + ($0B * 2) + ($09 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; HL: TILEMAP PTR
    LD B, $06
    CALL msIntroDisplayText
    EX DE, HL   ; DE: TILEMAP PTR
    ; ROW 1
    LD HL, NAMETABLE + ($0B * 2) + ($0A * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; HL: TILEMAP PTR
    LD B, $06
    JP msIntroDisplayText


msIntroSetupGhost:
;   GHOST ID
    LD (IX + ID), A
;   SPRITE TABLE START
    SLA A
    SLA A
    ADD A, $05
    LD (IX + SPR_NUM), A
;   SET X AND Y POSITION
    XOR A
    LD (IX + SUBPIXEL), A
    LD (IX + X_WHOLE), A
    LD (IX + X_WHOLE + 1), A
    LD (IX + Y_WHOLE), $94
    LD (IX + Y_WHOLE + 1), A
;   CLEAR FLAGS
    LD (IX + EDIBLE_FLAG), A
    LD (IX + INVISIBLE_FLAG), A
    LD (IX + OFFSCREEN_FLAG), A
    LD (IX + STATE), A
;   FACING LEFT
    INC A   ; $01
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
;   SET FLAG
    LD (IX + ALIVE_FLAG), A
    RET


msIntroMoveGhost:
;   CHECK IF GHOST NEEDS TO GO RIGHT OR UP
    LD A, (IX + X_WHOLE)
    CP A, $C0
    JR Z, +
    INC (IX + X_WHOLE)  ; MOVE RIGHT
    OR A, $01
    RET     ; ALWAYS RETURNS NZ
+:
;   CHECK IF GHOST IS DONE GOING UP
    LD A, (IX + Y_WHOLE)
    CP A, B
    RET Z   ; Z - COMPLETE
;   FACING UP
    XOR A
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
    DEC (IX + Y_WHOLE)  ; MOVE UP
    RET     ; ALWAYS RETURNS NZ
