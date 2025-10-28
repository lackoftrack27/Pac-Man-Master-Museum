/*
-------------------------------------------------------
            INTRO MODE FOR JR. PAC-MAN
-------------------------------------------------------
*/
sStateAttractTable@jrIntroMode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   GENERAL INTRO MODE SETUP
    CALL generalIntroSetup00
;   CUTSCENE SETUP
    LD HL, jrAttractProgTable
    CALL jrCutSetup
;   LOAD BACKGROUND PALETTE
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD HL, bgPalJrFD
    LD BC, BG_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   LOAD BACKGROUND TILES
    LD A, bank(jrAttractTiles)
    LD (MAPPER_SLOT2), A
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, jrAttractTiles
    CALL zx7_decompressVRAM
;   LOAD BACKGROUND TILEMAP
    LD A, bank(jrAttractTilemap)
    LD (MAPPER_SLOT2), A
    LD DE, mazeGroup1
    LD HL, jrAttractTilemap
    CALL zx7_decompress
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   RESET TEXT TIMER
    LD HL, $0000
    LD (mainTimer0), HL
;   SET INITIAL SCROLL POSITION
    XOR A   ; DISABLE NORMAL SCROLL STUFF
    LD (enableScroll), A
    LD A, $50
    LD (jrCameraPos), A
    LD A, $D8
    LD (jrScrollReal), A
;   LOAD VISIBLE PART OF TILEMAP TO VRAM
    LD HL, NAMETABLE | VRAMWRITE
    RST setVDPAddress
        ; POINT TO LEFT MOST TILE OF MAZE
    LD HL, mazeGroup1 + ($24 * $02)
        ; LOOP SETUP
    LD D, $18
-:
        ; WRITE ROW [SCROLLED TO RIGHT EDGE]
    LD BC, $0A * $100 + VDPDATA_PORT
    OTIR
        ; WRITE ROW
    LD BC, -($36 + $0A)
    ADD HL, BC
    LD BC, $36 * $100 + VDPDATA_PORT
    OTIR
        ; POINT TO NEXT ROW
    LD BC, ($05 * $02) + ($48)
    ADD HL, BC
        ; DO FOR WHOLE SCREEN
    DEC D
    JR NZ, -
;   GENERAL INTRO MODE SETUP 2
    CALL generalIntroSetup01
@@draw:
;   WRITE SCROLL TO VDP
    LD A, (jrScrollReal)
    OUT (VDPCON_PORT), A
    LD A, $88
    OUT (VDPCON_PORT), A
;   DRAW NEW COLUMN IF NEEDED
    LD A, (updateColFlag)
    OR A
    CALL NZ, drawNewColumnCutscene
@@update:
;   GET JUST PRESSED INPUTS
    CALL getPressedInputs
;   CHECK IF BUTTON 1 WAS PRESSED
    LD A, (pressedButtons)
    BIT 4, A
    JP NZ, sStateAttractTable@introMode@@exit ; IF SO, EXIT BACK TO TITLE
;   TEXT UPDATE
    LD HL, (mainTimer0)
    ; CHECK IF TEXT UPDATE IS COMPLETE
    BIT 7, H
    JP NZ, jrSceneCommonDrawUpdate  ; IF SO, SKIP
    ; INCREMENT COUNTER
    INC HL
    LD (mainTimer0), HL
    LD C, VDPDATA_PORT
    ; DISPLAY "WITH BLINKY" [AT 03 SECS]
    LD DE, $00B4
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (16 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, jrIntroBlinkyTxt
    LD B, $09
    CALL introDisplayText
    JP jrSceneCommonDrawUpdate
+:
    ; REMOVE "WITH BLINKY"  [AT 07 SECS]
    LD DE, $01A4
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (16 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD B, $09
    CALL introClearText
    JP jrSceneCommonDrawUpdate
+:
    ; DISPLAY "PINKY"       [AT 10 SECS]
    LD DE, $0258
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (19 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, jrIntroPinkyTxt
    LD B, $05
    CALL introDisplayText
    JP jrSceneCommonDrawUpdate
+:
    ; REMOVE "PINKY"        [AT 14 SECS]
    LD DE, $0348
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (19 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD B, $05
    CALL introClearText
    JP jrSceneCommonDrawUpdate
+:
    ; DISPLAY "INKY"        [AT 17 SECS]
    LD DE, $03FC
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (20 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, jrIntroInkyTxt
    LD B, $03
    CALL introDisplayText
    JP jrSceneCommonDrawUpdate
+:
    ; REMOVE "INKY"         [AT 21 SECS]
    LD DE, $04EC
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (20 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD B, $03
    CALL introClearText
    JP jrSceneCommonDrawUpdate
+:
    ; DISPLAY "TIM"         [AT 24 SECS]
    LD DE, $05A0
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +
    LD HL, (20 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, jrIntroTimTxt
    LD B, $02
    CALL introDisplayText
    JP jrSceneCommonDrawUpdate
+:
    ; REMOVE "TIM"          [AT 28 SECS]
    LD DE, $0690
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, jrSceneCommonDrawUpdate
    LD HL, (20 * $02) + (13 * $40) | VRAMWRITE
    RST setVDPAddress
    LD B, $02
    CALL introClearText
    LD HL, $FFFF
    LD (mainTimer0), HL
;   CUTSCENE SUBPROGRAM UPDATE
    JP jrSceneCommonDrawUpdate