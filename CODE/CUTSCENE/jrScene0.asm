/*
-------------------------------------------------------
                CUTSCENE 1 [JR. PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@jrScene0:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CUTSCENE 1 SETUP FOR JR. PAC
    LD HL, jrScene0ProgTable
    CALL jrCutSetup
;   LOAD BACKGROUND PALETTE
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    ; CRAM
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD HL, bgPalJrFE
    LD BC, $10 * $100 + VDPDATA_PORT
    OTIR
    ; RAM BUFFER
    LD HL, bgPalJrFE
    LD DE, mazePalette
    LD BC, $10
    LDIR
;   LOAD BACKGROUND TILES
    LD A, bank(jrCut0Tiles)
    LD (MAPPER_SLOT2), A
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, jrCut0Tiles
    CALL zx7_decompressVRAM
;   LOAD BACKGROUND TILEMAP
    LD A, bank(jrCut0Tilemap)
    LD (MAPPER_SLOT2), A
    LD DE, NAMETABLE | VRAMWRITE
    LD HL, jrCut0Tilemap
    CALL zx7_decompressVRAM
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   PLAY MUSIC
    LD A, MUS_INTER0_JR
    CALL sndPlayMusic
;   WAIT FOR VBLANK
    CALL waitForVblank
    JP turnOnScreen
@@draw:
;   SET ORANGE COLOR FOR ROOF
    LD HL, $0007 | CRAMWRITE
    RST setVDPAddress
    LD A, $0B
    OUT (VDPDATA_PORT), A
;   TEXT REMOVAL
    LD HL, mainTimer0
    ; CHECK IF TEXT HAS ALREADY BEEN REMOVED
    BIT 7, (HL)
    JP NZ, +    ; IF SO, SKIP
    ; INCREMENT AND CHECK IF TWO SECONDS HAVE PASSED
    INC (HL)
    LD A, $78
    CP A, (HL)
    JP NZ, +    ; IF NOT, SKIP
    ; SET FLAG, REMOVE TEXT
    SET 7, (HL)
    LD BC, $0C * $100 + VDPCON_PORT
    LD HL, NAMETABLE + (10 * $02) + (15 * $40) | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
    LD HL, $0100
-:
    OUT (C), L
    OUT (C), H
    DJNZ -
+:
;   POWER PELLET PALETTE CYCLING
    CALL drawPowDots
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   DO COMMON DRAW AND UPDATE
    CALL jrSceneCommonDrawUpdate
;   EXIT IF STATE CHANGE OCCURED
    LD A, (isNewState)
    OR A
    RET NZ
;   COLOR CHANGE
    ; WAIT UNTIL SCANLINE IS HIGH ENOUGH
-:
    IN A, ($7E)
    CP A, 144
    JP NZ, -
    ; BUSY LOOP TO HIDE CRAM DOTS
    LD B, $07
-:  DJNZ -
    ; SET ORANGE COLOR FOR 'GHOST CAVE'
    LD HL, $0007 | CRAMWRITE
    RST setVDPAddress
    LD A, $06
    OUT (VDPDATA_PORT), A
    RET
@@update:
;   END