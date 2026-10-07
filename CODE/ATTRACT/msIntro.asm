; -------------------------------------------------------
;             INTRO MODE FOR MS. PAC-MAN
; -------------------------------------------------------

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
;   SET BANK FOR ATTRACT MODE GFX
    LD A, bank(titleTileMap)
    LD (MAPPER_SLOT2), A
;   LOAD ATTRACT TILES
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, msIntroTileData
    CALL zx7_decompressVRAM
;   LOAD MARQUEE TILES
    LD DE, BACKGROUND_ADDR + (110 * $20) | VRAMWRITE
    LD HL, msMarqueeTileData
    CALL zx7_decompressVRAM
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
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
        ; DISPLAY "MS. PAC PLUS" IF IN PLUS MODE
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    JR NC, +
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




; -----------------------------------------
;     ROUTINE TABLE FOR INTRODUCTION [MS. PAC-MAN]
; -----------------------------------------
msIntroSubTable:
    .DW @wait00         ; WAIT 1 SECOND
    .DW @showBlinky
    .DW @showPinky
    .DW @showInky
    .DW @showSue
    .DW @showMsPac
    .DW @wait01         ; WAIT 2 SECONDS


; -----------------------------------------
;                 ROUTINES
; -----------------------------------------
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
    JP msIntroSetupGhostWait

msIntroSubTable@showBlinky:
;   DRAW BLINKY
    LD IX, blinky
    CALL displayGhostNormal
;   MOVE BLINKY
    LD B, $4D           ; Y LIMIT [OG: $94 - 71]
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
    JP msIntroSetupGhostWait


msIntroSubTable@showPinky:
;   DRAW PINKY
    LD IX, pinky
    CALL displayGhostNormal
;   MOVE PINKY
    LD B, $4D + $10         ; Y LIMIT
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
    JP msIntroSetupGhostWait

msIntroSubTable@showInky:
;   DRAW INKY
    LD IX, inky
    CALL displayGhostNormal
;   MOVE INKY
    LD B, $4D + $20         ; Y LIMIT
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
    JR msIntroSetupGhostWait

msIntroSubTable@showSue:
;   DRAW SUE
    LD IX, clyde
    CALL displayGhostNormal
;   MOVE SUE
    LD B, $4D + $30         ; Y LIMIT
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
    CALL msIntroSetupGhostWait  ; WRITES $00FF00 TO BLINKY'S UP COLLISION TILE
    INC (HL)                    ; OG: MS.PAC-MAN'S NAME APPEARS A FRAME AFTER 'STARRING', SO SHE WAITS 1 MORE (HL: mainTimer0)
    RET


msIntroSubTable@showMsPac:
;   DRAW MS. PAC
    CALL pacTileStreaming
    CALL displayPacMan
;   WAIT IF NEEDED
    CALL msIntroWait
    RET NZ
;   UPDATE POSITION
    LD HL, pacman.xPos
    INC (HL)
;   CHECK IF MS. PAC IS AT WANTED POSITION [OG: 114 PIXELS]
    LD A, $72
    CP A, (HL)
    RET NZ  ; IF NOT, END
    ; INCREMENT STATE
    LD HL, introSubState
    INC (HL)
    ; SET TIMER [OG: SETN, 127 FRAME PAUSE, END]
    LD A, 130
    LD (mainTimer0), A
    RET

msIntroSubTable@wait01:
;   DECREMENT TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; END IF NOT 0
;   ELSE, PREPARE TO DO DEMO
    JP demoPrep



; ---------------------------------------
;             HELPER FUNCTIONS
; ---------------------------------------
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

;   MS.PAC-MAN'S INTRO ENTERS HERE (PAC-MAN'S INTRO USES msIntroSetupGhost AND COUNTS FRAMES IN mainTimer0)
msIntroSetupGhostWait:
;   WAIT 3 FRAMES BEFORE MOVING [OG: SETPOS, SETCHAR, SETN]
    LD HL, mainTimer0
    LD (HL), $03
;   FALL THROUGH

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
;   WAIT IF NEEDED
    CALL msIntroWait
    RET NZ
;   CHECK IF GHOST NEEDS TO GO RIGHT OR UP
    LD A, (IX + X_WHOLE)
    CP A, $C0
    JR Z, +
    INC A   ; MOVE RIGHT
    LD (IX + X_WHOLE), A
    ; OG: 1 FRAME WAIT AFTER 112 PIXELS [SETN], 3 AT THE CORNER [SETCHAR, SETN, FIRST STEP UP IS 0 PIXELS]
    CP A, $70
    JR Z, @wait1
    CP A, $C0
    RET NZ  ; RETURNS NZ
    ; FACING UP
    XOR A
    LD (IX + CURR_DIR), A
    LD (IX + NEXT_DIR), A
    LD (HL), $02
@wait1:
    INC (HL)
    RET     ; ALWAYS RETURNS NZ
+:
;   CHECK IF GHOST IS DONE GOING UP
    LD A, (IX + Y_WHOLE)
    CP A, B
    RET Z   ; Z - COMPLETE
;   FACING UP
    DEC A   ; MOVE UP
    LD (IX + Y_WHOLE), A
    ; OG: NEXT NAME APPEARS 2 FRAMES AFTER THE LAST STEP, SO WAIT 1 FRAME BEFORE REPORTING COMPLETE
    CP A, B
    JR Z, @wait1
    RET     ; ALWAYS RETURNS NZ


    ; INFO: COUNTS DOWN THE WAIT TIMER OF MS.PAC-MAN'S INTRO
    ; INPUT: NONE
    ; OUTPUT: NZ IF WAITING, Z IF NOT
    ; USES: AF, HL
msIntroWait:
    LD HL, mainTimer0
    LD A, (HL)
    OR A
    RET Z
    DEC (HL)
    OR A
    RET
