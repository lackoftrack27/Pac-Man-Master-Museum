/*
-------------------------------------------------------
                CUTSCENE 3 [JR. PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@jrScene2:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CUTSCENE 3 SETUP FOR JR. PAC
    LD HL, jrScene2ProgTable
    CALL jrCutSetup
;   RESET BACKGROUND PALETTE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD B, BG_CRAM_SIZE
    XOR A
-:
    OUT (VDPDATA_PORT), A
    DJNZ -
;   LOAD BACKGROUND TILES
    LD A, bank(jrCut2Tiles)
    LD (MAPPER_SLOT2), A
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, jrCut2Tiles
    CALL zx7_decompressVRAM
;   LOAD BACKGROUND TILEMAP
    LD A, bank(jrCut2Tilemap)
    LD (MAPPER_SLOT2), A
    LD DE, NAMETABLE | VRAMWRITE
    LD HL, jrCut2Tilemap
    CALL zx7_decompressVRAM
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   SET INITIAL SCROLL POSITION
    XOR A   ; DISABLE NORMAL SCROLL STUFF
    LD (enableScroll), A
    LD (jrCameraPos), A
    LD (jrScrollReal), A
    OUT (VDPCON_PORT), A
    LD A, $88
    OUT (VDPCON_PORT), A
;   FILL RAM TILEMAP WITH BLANK TILES
    LD HL, mazeGroup1
    LD DE, mazeGroup1 + $02
    LD BC, $0100
    LD (mazeGroup1), BC
    LD BC, _sizeof_mazeGroup1 - $02
    LDIR
;   PLAY MUSIC
    LD A, MUS_INTER2_JR
    CALL sndPlayMusic
;   WAIT FOR VBLANK
    CALL waitForVblank
    JP turnOnScreen
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
;   TEXT UPDATE
    LD HL, (mainTimer0)
    ; CHECK IF TEXT HAS ALREADY BEEN REMOVED
    BIT 7, H
    JP NZ, jrSceneCommonDrawUpdate  ; IF SO, SKIP
    ; INCREMENT AND CHECK IF ENOUGH TIME HAVE PASSED
    INC HL
    LD (mainTimer0), HL
    ; 1ST CHECK
    LD DE, 11 * 60
    OR A
    SBC HL, DE
    ADD HL, DE
    JP NZ, +  ; IF NOT, SKIP
        ; DRAW TEXT
    LD BC, $09 * $100 + VDPCON_PORT
    LD HL, NAMETABLE + (04 * $02) + (20 * $40) | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
    LD HL, $0159
-:
    OUT (C), L
    OUT (C), H
    INC L
    DJNZ -
    JP jrSceneCommonDrawUpdate
+:
    ; 2ND CHECK
    LD DE, 15 * 60
    SBC HL, DE
    ADD HL, DE
    JP NZ, jrSceneCommonDrawUpdate
        ; SET FLAG
    LD A, $FF
    LD (mainTimer0 + 1), A
        ; REMOVE TEXT
    LD BC, $09 * $100 + VDPCON_PORT
    LD HL, NAMETABLE + (04 * $02) + (20 * $40) | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
    LD HL, $0100
-:
    OUT (C), L
    OUT (C), H
    DJNZ -
;   DO COMMON DRAW AND UPDATE
    JP jrSceneCommonDrawUpdate
@@update:
;   END