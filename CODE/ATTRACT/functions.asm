/*
----------------------------------------------
        COMMON FUNCTIONS FOR ATTRACT
----------------------------------------------
*/

/*
    INFO: GET JUST PRESSED INPUTS FROM CONTROLLER 1
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
getPressedInputs:
;   GET ADDRESS OF CONTROLLER 1'S DATA
    LD HL, controlPort1
;   GET DIFFERENCE BETWEEN PREVIOUS INPUT
    LD A, (prevInput)
    CPL
;   BUTTON IS ONLY CONSIDERED PRESSED IF THERE WAS DIFFERENCE BETWEEN INPUTS AND BUTTON IS PRESSED NOW
    AND A, (HL)
    LD (pressedButtons), A
;   INPUT IS NOW PREVIOUS INPUT
    LD A, (HL)
    LD (prevInput), A
    RET


/*
    INFO: REMOVE "PLUS" LOGO ON SCREEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
plus_clrNametableArea:
;   ROW 0
    LD HL, NAMETABLE + (12 * 2) + (08 * $40) | VRAMWRITE
    RST setVDPAddress
    LD DE, $0502    ; FLAGS + TILE IDX
    LD BC, $08 * $100 + VDPDATA_PORT
-:
    OUT (C), E
    OUT (C), D
    DJNZ -
;   ROW 1
    LD HL, NAMETABLE + (12 * 2) + (09 * $40) | VRAMWRITE
    RST setVDPAddress
    LD A, BLANK_TILE
    LD BC, $10 * $100 + VDPDATA_PORT
-:
    OUT (C), A
    DJNZ -
    RET


/*
    INFO: ADD "PLUS" LOGO ON SCREEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
plus_setNametableArea:
;   ROW 0
    LD HL, NAMETABLE + (12 * 2) + (08 * $40) | VRAMWRITE
    RST setVDPAddress
    LD DE, $016C    ; FLAGS + TILE IDX
    LD BC, $08 * $100 + VDPDATA_PORT
-:
    OUT (C), E
    OUT (C), D
    INC E
    DJNZ -
;   ROW 1
    LD HL, NAMETABLE + (12 * 2) + (09 * $40) | VRAMWRITE
    RST setVDPAddress
    LD BC, $08 * $100 + VDPDATA_PORT
-:
    OUT (C), E
    OUT (C), D
    INC E
    DJNZ -
    RET


/*
    INFO: TOGGLE BETWEEN PAC-MAN AND MS. PAC-MAN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
titleToggleModes:
;   TOGGLE MODES (GAME)
@left:
    ; SAVE UPPER NIBBLE (STYLE)
    LD A, (plusBitFlags)
    AND A, $F0
    LD B, A
    ; $00 -> $0E [$0A] -> $08 [$04] -> $02 -> $00
    ; $01 -> $0F [$0B] -> $09 [$05] -> $03 -> $01
    ; DECREMENT TO NEXT GAME
    LD A, (plusBitFlags)
    SUB A, $02
    AND A, $0F
    ; CORRECT VALUE
    CP A, $04
    JR C, +
    SUB A, $04
+:
    OR A, B
    LD (plusBitFlags), A
    JR @noToggle
@right:
    ; SAVE UPPER NIBBLE (STYLE)
    LD A, (plusBitFlags)
    AND A, $F0
    LD B, A
    ; $00 -> $02 -> $04 -> $06 [$0A] -> $0C [$00]
    ; $01 -> $03 -> $05 -> $07 [$0B] -> $0D [$01]
    ; INCREMENT TO NEXT GAME
    LD A, (plusBitFlags)
    ADD A, $02
    LD (plusBitFlags), A
    ; CORRECT VALUE
    AND A, $0F
    CP A, $0C
    JR C, +
    SUB A, $0C
    OR A, B
    LD (plusBitFlags), A
    JR @noToggle
+:
    CP A, $06
    JR C, @noToggle
    ADD A, $04
    OR A, B
    LD (plusBitFlags), A
@noToggle:
    LD A, (plusBitFlags)
;   CHANGE BASE SPRITE TABLE ADDR
    AND A, ($01 << MS_PAC | $01 << JR_PAC | $01 << OTTO)
    RRCA
    ADD A, A
    ADD A, A
    ADD A, A
    CP A, $28
    JR NZ, +
    LD A, $18
+:
    LD D, $00
    LD E, A
    LD HL, titleCharTblSmooth
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JR Z, +
    LD HL, titleCharTblArcade
+:
    ADD HL, DE
    LD (pacBase), HL
;   FALL THROUGH


/*
    INFO: RENEW INACTIVITY TIMER (10 SECONDS)
    INPUT: NONE
    OUTPUT: NONE
    USES: HL
*/
setInactivityTimer:
;   RESET INACTIVITY TIMER
    LD HL, TITLE_TIMER_LEN
    LD (mainTimer0), HL
    RET



/*
    INFO: PLAY CREDIT SFX, WAIT UNTIL IT FINISHES
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
playCreditSnd:
;   PLAY CREDIT SFX
    LD B, $02       ; CHANNEL 2
    LD A, SFX_CREDIT
    CALL sndPlaySFX
-:
    CALL sndProcess
    HALT
;   CHECK IF CURRENTLY PLAYING SELECT SOUND
    LD A, (chan2 + SND_ID)
    CP A, SFX_CREDIT
    JR Z, -     ; IF SO, WAIT UNTIL NOT
;   ASSUME OPTIONS IS SELECTED
    LD HL, $01 * $100 + ATTRACT_OPTIONS
    LD (subGameMode), HL
;   CHECK IF IT ACTUALLY IS
    LD HL, lineMode
    BIT 1, (HL)
    RET NZ      ; IF SO, SWITCH TO OPTIONS MODE
;   ELSE, SWITCH TO GAME
    JP attractExit


/*
    INFO: PREPARATION FOR GAMEPLAY MODE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
attractExit:
;   SET TO FIRST READY MODE, SET MAIN STATE TO GAMEPLAY
    LD HL, GAMEPLAY_READY00 * $100 + M_STATE_GAMEPLAY
    LD (mainGameMode), HL
;   NEW STATE
    LD A, $01
    LD (isNewState), A
;   DO GAMEPLAY INITIALIZATION
    JP gamePlayInit


/*
    INFO: PREPARATION FOR DEMO MODE
    INPUT: NONE
    OUTPUT: NONE
    USES: HL
*/
demoPrep:
    ; GO INTO DEMO MODE
    LD HL, $01 * $100 + ATTRACT_READY01
    LD (subGameMode), HL
    ; DO GAMEPLAY INITIALIZATION
    JP gamePlayInit



/*
    INFO: DISPLAY TEXT (BACKGROUND PALETTE)
    INPUT: HL - ADDRESS OF TEXT TILEMAP DATA
    OUTPUT: NONE
    USES: AF
*/
introDisplayText:
    LD A, $01
-:
    OUTI
    OUT (C), A
    JR NZ, -
    RET

/*
    INFO: DISPLAY TEXT (SPRITE PALETTE)
    INPUT: HL - ADDRESS OF TEXT TILEMAP DATA
    OUTPUT: NONE
    USES: AF
*/
msIntroDisplayText:
    LD A, $09
-:
    OUTI
    OUT (C), A
    JR NZ, -
    RET


/*
    INFO: DISPLAY OPTION TEXT (ON TILEMAP)
    INPUT: A - INDEX, BC - OPTION TYPE ADDR, DE - TEXT ADDRESS, HL - VDP ADDRESS
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawOptionText:
    PUSH AF ; SAVE INDEX
    PUSH BC ; SAVE OPTION TYPE ADDR
;   SET VDP ADDRESS FOR TEXT
    RST setVDPAddress
;   WRITE TEXT
    EX DE, HL
    LD BC, $0A * $100 + VDPDATA_PORT
    CALL introDisplayText
;   SKIP 5 TILES
    LD B, $0A
-:
    IN F, (C)
    DJNZ -
;   WRITE OPTION TYPE
    POP HL  ; OPTION TYPE ADDR
    POP AF  ; INDEX
    CALL multiplyBy6
    RST addToHL
    LD B, $06
    JP introDisplayText


/*
    INFO: GENERAL SETUP FOR INTRO MODE [PART 1]
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
generalIntroSetup00:
;   CLEAR FLAG
    XOR A
    LD (isNewState), A
;   RESET PLAYER TYPE (1 PLAYER)
    LD (playerType), A
;   RESET 1UP FLASH
    LD (xUPCounter), A
;   SET INTRO'S SUB STATE
    LD (introSubState), A
;   RESET POINT SPR NUM (EAT MODE INDICATOR)
    LD (ghostPointSprNum), A
;   RESET POWER DOT PALETTE BUFFER/COUNTER
    LD (powDotFrameCounter), A
;   RESET GLOBAL GHOST VARS
    LD (frameCounter), A
    LD (flashCounter), A
;   SET TIMER
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   SETUP PLAYER TILE POINTERS
    CALL setupTilePtrs
;   TURN OFF SCREEN (AND VBLANK INTS)
    CALL turnOffScreen
;   CLEAR TILEMAP AND SPRITE TABLE
    LD HL, NAMETABLE | VRAMWRITE
    RST setVDPAddress
    ; WRITE ZEROS TO VRAM
    LD DE, $800
-:
    XOR A
    OUT (VDPDATA_PORT), A
    DEC DE
    LD A, D
    OR A, E
    JR NZ, -
;   USE PRIORITY TILE TO COVER ACTORS
    ; HIGH BYTE (PRIORITY / INDEX MSB)
    ; LOW BYTE (INDEX)
    LD DE, $11 * $100 + MASK_TILE
    ; ROW 0
    LD HL, NAMETABLE + (23 * 2) + ($0C * $40) | VRAMWRITE
    RST setVDPAddress
    LD BC, $09 * $100 + VDPDATA_PORT
-:
    OUT (C), E
    OUT (C), D
    DJNZ -
    ; ROW 1
    LD HL, NAMETABLE + (23 * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    LD B, $09
-:
    OUT (C), E
    OUT (C), D
    DJNZ -
;   LOAD HUD TEXT TILES....
;   LOAD SPRITE TILES
    JP loadTileAssets


/*
    INFO: GENERAL SETUP FOR INTRO MODE [PART 2]
    INPUT: NONE
    OUTPUT: NONE
    USES:
*/
generalIntroSetup01:
;   SET POWER PELLET COLOR BUFFER
    CALL powDotCyclingUpdate@refresh
;   DRAW STATIC HUD ELEMENTS
    ; 1UP
    CALL draw1UPDemo
    ; "HIGH SCORE" AND "SCORE"
    CALL drawScoresText
;   TURN ON DISPLAY
    CALL waitForVblank
    JP turnOnScreen