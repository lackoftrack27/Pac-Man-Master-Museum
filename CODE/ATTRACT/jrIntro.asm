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
;   DISABLE SPRITES AT INDEX $15
    LD HL, SPRITE_TABLE + $15 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   CUTSCENE SETUP
    LD HL, jrAttractProgTable
    CALL jrCutSetup
    /*
;   SET BANK FOR ATTRACT MODE GFX
    LD A, bank(titleTileMap)
    LD (MAPPER_SLOT2), A
;   LOAD ATTRACT TILES
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, msIntroTileData
    CALL zx7_decompressVRAM
;   LOAD ATTRACT TILEMAP
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    */
    XOR A
    LD L, A
    LD H, A
    LD (jrScrollReal), HL
    LD (jrOldScrollReal), HL
    LD (jrColumnToUpdate), A
    LD (updateColFlag), A
    LD A, $01
    LD (enableScroll), A
    LD A, $28 + $28
    LD (jrCameraPos), A
;   GENERAL INTRO MODE SETUP 2
    CALL generalIntroSetup01
@@draw:
@@update:
;   GET JUST PRESSED INPUTS
    CALL getPressedInputs
;   CHECK IF BUTTON 1 WAS PRESSED
    LD A, (pressedButtons)
    BIT 4, A
    JP NZ, sStateAttractTable@introMode@@exit ; IF SO, EXIT BACK TO TITLE
;   TEXT UPDATE
;   CUTSCENE SUBPROGRAM UPDATE
    JP jrSceneCommonDrawUpdate