/*
-------------------------------------------------------
                CUTSCENE 2 [JR. PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@jrScene1:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CUTSCENE 2 SETUP FOR JR. PAC
    LD HL, jrScene1ProgTable
    CALL jrCutSetup
;   LOAD BACKGROUND PALETTE
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD HL, bgPalJrFD
    LD BC, BG_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   LOAD BACKGROUND TILES
    LD A, bank(jrCut1Tiles)
    LD (MAPPER_SLOT2), A
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, jrCut1Tiles
    CALL zx7_decompressVRAM
;   LOAD BACKGROUND TILEMAP
    LD A, bank(jrCut1Tilemap)
    LD (MAPPER_SLOT2), A
    LD DE, mazeGroup1
    LD HL, jrCut1Tilemap
    CALL zx7_decompress
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   SET INITIAL SCROLL POSITION
    XOR A   ; DISABLE NORMAL SCROLL STUFF
    LD (enableScroll), A
    LD A, $50
    LD (jrCameraPos), A
    LD A, $D8
    LD (jrScrollReal), A
        ; WRITE TO VDP HERE DUE TO 'WAIT FOR VBLANK'
    OUT (VDPCON_PORT), A
    LD A, $88
    OUT (VDPCON_PORT), A
;   LOAD VISIBLE PART OF TILEMAP TO VRAM
    CALL jrLoadStartingTileMapArea
;   PLAY MUSIC
    LD A, MUS_INTER1_JR
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
;   TEXT REMOVAL
    LD HL, (mainTimer0)
    ; CHECK IF TEXT HAS ALREADY BEEN REMOVED
    BIT 7, H
    JP NZ, jrSceneCommonDrawUpdate  ; IF SO, SKIP
    ; INCREMENT AND CHECK IF ENOUGH TIME HAVE PASSED
    INC HL
    LD (mainTimer0), HL
    LD DE, 5 * 60
    OR A
    SBC HL, DE
    JP NZ, jrSceneCommonDrawUpdate  ; IF NOT, SKIP
    ; SET FLAG
    LD A, $FF
    LD (mainTimer0 + 1), A
    ; REMOVE TEXT
    LD BC, $06 * $100 + VDPCON_PORT
    LD HL, NAMETABLE + (02 * $02) + (10 * $40) | VRAMWRITE
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