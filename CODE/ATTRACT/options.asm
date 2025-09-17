/*
-------------------------------------------------------
                    OPTIONS MODE
-------------------------------------------------------
*/
sStateAttractTable@optionsMode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CLEAR FLAG
    XOR A
    LD (isNewState), A
;   SET LINE
    LD (lineMode), A    ; WHAT LINE IS SELECTED.        0 - "LIVES", 1 - "DIFFICULTY", 2 - "BONUS", 3 - "SPEED", 4 - "STYLE"
;   
    LD (sndTestIndex), A
;   TURN OFF SCREEN (AND VBLANK INTS)
    CALL turnOffScreen
;   SET BANK FOR ATTRACT MODE GFX
    LD A, bank(titleTileMap)
    LD (MAPPER_SLOT2), A
;   LOAD BACKGROUND TILES
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, optionsTileData
    CALL zx7_decompressVRAM
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   CLEAR TILEMAP
    LD HL, NAMETABLE | VRAMWRITE
    RST setVDPAddress
    LD DE, MAZE_TILEMAP_SIZE
-:
    XOR A
    OUT (VDPDATA_PORT), A
    DEC DE
    LD A, D
    OR A, E
    JR NZ, -
;   DRAW LIVES TEXT AND TYPE
    LD A, (liveIndex)
    LD BC, optionTileMaps@lives
    LD DE, optionLivesText
    LD HL, NAMETABLE + ($04 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
;   DRAW DIFFICULTY TEXT AND TYPE
    LD A, (diffIndex)
    LD BC, optionTileMaps@diff
    LD DE, optionDiffText
    LD HL, NAMETABLE + ($04 * $02) + (DIFF_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
;   DRAW BONUS TEXT AND TYPE
    LD A, (bonusIndex)
    LD BC, optionTileMaps@bonus
    LD DE, optionBonusText
    LD HL, NAMETABLE + ($04 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
;   DRAW SPEED TEXT AND TYPE
    LD A, (speedIndex)
    LD BC, optionTileMaps@speed
    LD DE, optionSpeedText
    LD HL, NAMETABLE + ($04 * $02) + (SPEED_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
;   DRAW BONUS TEXT AND TYPE
    LD A, (bonusIndex)
    LD BC, optionTileMaps@bonus
    LD DE, optionBonusText
    LD HL, NAMETABLE + ($04 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
;   DRAW STYLE TEXT AND TYPE
    LD A, (styleIndex)
    LD BC, optionTileMaps@style
    LD DE, optionStyleText
    LD HL, NAMETABLE + ($04 * $02) + (STYLE_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
;   DRAW SOUND TEXT AND TYPE
    LD A, (liveIndex)           ; IGNORE
    LD BC, optionTileMaps@lives ; IGNORE
    LD DE, optionSndText
    LD HL, NAMETABLE + ($04 * $02) + (SND_YPOS * $40) | VRAMWRITE
    CALL drawOptionText
    CALL updateSndTestTilemap
;   DRAW HELP TEXT
    LD HL, NAMETABLE + ($04 * $02) + (HELP_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionHelpText
    LD BC, $17 * $100 + VDPDATA_PORT
    CALL introDisplayText
;   SET HORIZONTAL ARROW SPRITES
    ; SET ON LIVES
    LD HL, titleArrowTable
    LD DE, $10 * $100 + (LIVES_YPOS * $08)  ; SPR X/Y
    XOR A
    CALL display1TileSprite
    ; SET POINTER ARROWS
    DEC HL
    LD DE, $88 * $100 + (LIVES_YPOS * $08)  ; TILE X/Y
    LD A, $01
    CALL display1TileSprite
    LD DE, $D0 * $100 + (LIVES_YPOS * $08)  ; TILE X/Y
    LD A, $02
    CALL display1TileSprite
;   DISABLE SPRITES $03 AND BEYOND
    LD HL, SPRITE_TABLE + $03 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   TURN ON DISPLAY
    CALL waitForVblank
    CALL turnOnScreen
@@draw:
@@update:
;   GET JUST PRESSED INPUTS
    CALL getPressedInputs
;   PREP
    LD HL, pressedButtons
;   CHECK IF A IS PRESSED
    BIT P1_BTN_1, (HL)
    JR Z, +     ; IF NOT, SKIP
@@exit:
;   SET SUBSTATE TO TITLE, SET NEW-STATE-FLAG
    LD HL, $01 * $100 + ATTRACT_TITLE
    LD (subGameMode), HL
;   STOP ALL SOUNDS, THEN END
    JP sndStopAll
+:
;   SETUP
    LD DE, liveIndex
;   CHECK WHAT LINE IS SELECTED
    LD A, (lineMode)    ; CHECK IF ON LIVES (0)
    OR A
    JP Z, @@@livesLine  ; IF SO, GO PROCESS
    INC DE      ; POINT TO INDEX FOR DIFFICULTY
    DEC A       ; CHECK IF ON DIFFICULTY (1)
    JP Z, @@@diffLine   ; IF SO, GO PROCESS
    INC DE      ; POINT TO INDEX FOR BONUS
    DEC A       ; CHECK IF ON BONUS (2)
    JP Z, @@@bonusLine  ; IF SO, GO PROCESS
    INC DE      ; POINT TO INDEX FOR SPEED
    DEC A       ; CHECK IF ON SPEED (3)
    JP Z, @@@speedLine   ; IF SO, GO PROCESS
    INC DE      ; POINT TO INDEX FOR STYLE
    DEC A       ; CHECK IF ON STYLE (4)
    JR Z, @@@styleLine  ; IF SO, GO PROCESS
    LD DE, sndTestIndex


/*
    "SOUND TEST" PROCESSING  [LINE INDEX: 5]
*/
@@@sndTestLine:
;   CHECK IF USER PRESSED UP
    BIT P1_DIR_UP, (HL)
    JP NZ, changeArrows@style
;   CHECK IF USER PRESSED DOWN
    BIT P1_DIR_DOWN, (HL)
    JP NZ, changeArrows@lives
;   CHECK IF USER PRESSED LEFT
    BIT P1_DIR_LEFT, (HL)
    JR Z, ++ ; IF NOT, SKIP
    ; DECREMENT SND ID
    LD A, (DE)
    DEC A
    JP P, +     ; UNDERFLOW CHECK
    LD A, MUS_INTER2_JR - SFX_STOP
+:
    LD (DE), A
    ; UPDATE TILEMAP
    JP updateSndTestTilemap
++:
;   CHECK IF USER PRESSED RIGHT
    BIT P1_DIR_RIGHT, (HL)
    JR Z, ++ ; IF NOT, SKIP
    ; INCREMENT SND ID
    LD A, (DE)
    INC A
    CP A, MUS_INTER2_JR - SFX_STOP + 1
    JR C, +     ; OVERFLOW CHECK
    XOR A
+:
    LD (DE), A
    ; UPDATE TILEMAP
    JP updateSndTestTilemap
++:
;   CHECK IF USER PRESSED BUTTON 2
    BIT P1_BTN_2, (HL)
    RET Z   ; IF NOT, EXIT
    ; PREPARE TO PLAY SND ID
    PUSH DE
    CALL sndStopAll ; STOP ALL SOUND
    POP DE
    ; EXIT IF ID IS 0
    LD A, (DE)
    OR A
    RET Z
    ; PLAY SND ID
    ADD A, SFX_STOP ; CONVERT TO $80 BASED
    CP A, MUS_START
    JP NC, sndPlayMusic
    LD B, $02       ; CHANNEL 2
    JP sndPlaySFX


/*
    "STYLE" PROCESSING  [LINE INDEX: 4]
*/
@@@styleLine:
;   CHECK IF USER PRESSED UP
    BIT P1_DIR_UP, (HL)
    JP NZ, changeArrows@speed 
;   CHECK IF USER PRESSED DOWN
    BIT P1_DIR_DOWN, (HL)
    JP NZ, changeArrows@sndTest
;   CHECK IF LEFT OR RIGHT IS PRESSED
    LD A, $01 << P1_DIR_LEFT |  $01 << P1_DIR_RIGHT
    AND A, (HL)
    RET Z   ; IF NOT, END
    ; TOGGLE FLAG
    LD A, (plusBitFlags)
    XOR A, $01 << STYLE_0
    LD (plusBitFlags), A
    ; TOGGLE LINE ITEM
    LD A, (DE)
    XOR A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (STYLE_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@style
    LD A, (DE)
    CALL multiplyBy6
    RST addToHL
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText


/*
    "SPEED" PROCESSING  [LINE INDEX: 3]
*/
@@@speedLine:
;   CHECK IF USER PRESSED UP
    BIT P1_DIR_UP, (HL)
    JP NZ, changeArrows@bonus
;   CHECK IF USER PRESSED DOWN
    BIT P1_DIR_DOWN, (HL)
    JP NZ, changeArrows@style
;   CHECK IF LEFT OR RIGHT IS PRESSED
    LD A, $01 << P1_DIR_LEFT |  $01 << P1_DIR_RIGHT
    AND A, (HL)
    RET Z   ; IF NOT, END
    ; TOGGLE FLAG
    LD A, (speedUpFlag)
    XOR A, $01
    LD (speedUpFlag), A
    ; TOGGLE LINE ITEM
    LD A, (DE)
    XOR A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (SPEED_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@speed
    LD A, (DE)
    CALL multiplyBy6
    RST addToHL
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText


/*
    "LIVES" PROCESSING  [LINE INDEX: 0]
*/
@@@livesLine:
;   CHECK IF USER PRESSED DOWN
    BIT P1_DIR_DOWN, (HL)
    JP NZ, changeArrows@diff
;   CHECK IF USER PRESSED UP
    BIT P1_DIR_UP, (HL)
    JP NZ, changeArrows@sndTest
;   CHECK WHAT ITEM IS SELECTED
    LD A, (DE)
    OR A
    JR Z, @@@@one
    DEC A
    JR Z, @@@@two
    DEC A
    JR Z, @@@@three
;   FIVE PROCESSING (CAN MOVE TO EITHER 1 OR 3)
    ; CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    JR Z, + ; IF NOT, SKIP
    ; SET LIVES
    LD A, $03
    LD (startingLives), A
    ; CHANGE ITEM SELECTED
    LD A, $02
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@lives + ($02 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
    ; CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    RET Z   ; IF NOT, END
    JR @@@@two@selected1

;   ONE PROCESSING (CAN MOVE TO EITHER 5 OR 2)
@@@@one:
    ; CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    JR Z, + ; IF NOT, SKIP
    ; SET LIVES
    LD A, $02
    LD (startingLives), A
    ; CHANGE ITEM SELECTED
    LD A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@lives + ($01 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
    ; CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    RET Z   ; IF NOT, END
    JR @@@@three@selected5

;   TWO PROCESSING (CAN MOVE TO EITHER 1 OR 3)
@@@@two:
;   CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    JR Z, +   ; IF NOT, CHECK FOR RIGHT
@@@@@selected1:
    ; SET LIVES
    LD A, $01
    LD (startingLives), A
    ; CHANGE ITEM SELECTED
    LD A, $00
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@lives + ($00 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
;   CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    RET Z   ; IF NOT, END
    ; SET LIVES
    LD A, $03
    LD (startingLives), A
    ; CHANGE ITEM SELECTED
    LD A, $02
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@lives + ($02 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText

;   THREE PROCESSING (CAN MOVE TO EITHER 2 OR 5)
@@@@three:
    ; CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    JR Z, +   ; IF NOT, CHECK FOR RIGHT
    ; SET LIVES
    LD A, $02
    LD (startingLives), A
    ; CHANGE ITEM SELECTED
    LD A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@lives + ($01 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
    ; CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    RET Z   ; IF NOT, END
@@@@@selected5:
    ; SET LIVES
    LD A, $05
    LD (startingLives), A
    ; CHANGE ITEM SELECTED
    LD A, $03
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (LIVES_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@lives + ($03 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
    
    


/*
    "DIFFICULTY" PROCESSING [LINE INDEX: 1]
*/
@@@diffLine:
;   CHECK IF USER PRESSED DOWN
    BIT P1_DIR_DOWN, (HL)
    JP NZ, changeArrows@bonus
;   CHECK IF USER PRESSED UP
    BIT P1_DIR_UP, (HL)
    JP NZ, changeArrows@lives
;   CHECK IF LEFT OR RIGHT IS PRESSED
    LD A, $01 << P1_DIR_LEFT |  $01 << P1_DIR_RIGHT
    AND A, (HL)
    RET Z   ; IF NOT, END
    ; TOGGLE FLAG
    LD A, (normalFlag)
    XOR A, $01
    LD (normalFlag), A
    ; TOGGLE LINE ITEM
    LD A, (DE)
    XOR A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (DIFF_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@diff
    LD A, (DE)
    CALL multiplyBy6
    RST addToHL
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText



/*
    "BONUS" PROCESSING  [LINE INDEX: 2]
*/
@@@bonusLine
;   CHECK IF USER PRESSED DOWN
    BIT P1_DIR_DOWN, (HL)
    JP NZ, changeArrows@speed
;   CHECK IF USER PRESSED UP
    BIT P1_DIR_UP, (HL)
    JP NZ, changeArrows@diff
;   CHECK WHAT ITEM IS SELECTED
    LD A, (DE)
    OR A
    JR Z, @@@@tenK
    DEC A
    JP Z, @@@@fiveOneK
    DEC A 
    JP Z, @@@@twoZeroK

;   "OFF" PROCESSING (MOVE EITHER TO 20K OR 10K)
;   CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    JR Z, +   ; IF NOT, CHECK FOR RIGHT
    ; BONUS AT 20K
    LD HL, $0000
    LD (bonusValue), HL
    LD A, $02
    LD (bonusValue + 2), A
    ; CHANGE ITEM SELECTED
    LD A, $02
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@bonus + ($02 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
;   CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    RET Z   ; IF NOT, END
    JR @@@@fiveOneK@tenKSelected

;   "20K" PROCESSING (MOVE EITHER TO 10K OR OFF)
@@@@twoZeroK:
;   CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    JR Z, +   ; IF NOT, CHECK FOR RIGHT
    ; BONUS AT 15K
    LD HL, $5000
    LD (bonusValue), HL
    LD A, $01
    LD (bonusValue + 2), A
    ; CHANGE ITEM SELECTED
    LD A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@bonus + ($01 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
;   CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    RET Z   ; IF NOT, END
@@@@@offSelected:
    ; NO BONUS
    LD HL, $FFFF
    LD (bonusValue), HL
    LD A, $FF
    LD (bonusValue + 2), A
    ; CHANGE ITEM SELECTED
    LD A, $03
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@bonus + ($03 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText


;   "10K" PROCESSING (MOVE EITHER TO OFF OR 15K)
@@@@tenK:
;   CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    JR Z, + ; IF NOT, SKIP
    ; BONUS AT 15K
    LD HL, $5000
    LD (bonusValue), HL
    LD A, $01
    LD (bonusValue + 2), A
    ; CHANGE ITEM SELECTED
    LD A, $01
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@bonus + ($01 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
;   CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    RET Z   ; IF NOT, END
    JR @@@@twoZeroK@offSelected

;   "15K" PROCESSING (MOVE EITHER TO 10K OR 20K)
@@@@fiveOneK:
;   CHECK IF LEFT IS PRESSED
    BIT P1_DIR_LEFT, (HL)
    JR Z, +   ; IF NOT, CHECK FOR RIGHT
@@@@@tenKSelected:
    ; BONUS AT 10K
    LD HL, $0000
    LD (bonusValue), HL
    LD A, $01
    LD (bonusValue + 2), A
    ; CHANGE ITEM SELECTED
    XOR A
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@bonus + ($00 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText
+:
;   CHECK IF RIGHT IS PRESSED
    BIT P1_DIR_RIGHT, (HL)
    RET Z   ; IF NOT, END
    ; BONUS AT 20K
    LD HL, $0000
    LD (bonusValue), HL
    LD A, $02
    LD (bonusValue + 2), A
    ; CHANGE ITEM SELECTED
    LD A, $02
    LD (DE), A
    ; UPDATE TILE MAP
    LD HL, NAMETABLE + ($13 * $02) + (BONUS_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, optionTileMaps@bonus + ($02 * $06)
    LD BC, $06 * $100 + VDPDATA_PORT
    JP introDisplayText



/*
--------------------------------------
            HELPER FUNCTIONS
--------------------------------------
*/


/*
    INFO: CHANGES ARROWS' POSITIONS
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
changeArrows:
@lives:
    ; POINT TO "LIVES"
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, (LIVES_YPOS * $08) - 1
    OUT (VDPDATA_PORT), A
    ; SET POINTER ARROWS
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; CHANGE LINE VAR
    XOR A
    LD (lineMode), A
    RET
@diff:
    ; POINT TO "DIFFICULTY"
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, (DIFF_YPOS * $08) - 1
    OUT (VDPDATA_PORT), A
    ; SET POINTER ARROWS
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; CHANGE LINE VAR
    LD A, $01
    LD (lineMode), A
    RET
@bonus:
    ; POINT TO "BONUS"
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, (BONUS_YPOS * $08) - 1
    OUT (VDPDATA_PORT), A
    ; SET POINTER ARROWS
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; CHANGE LINE VAR
    LD A, $02
    LD (lineMode), A
    RET
@speed:
    ; POINT TO "SPEED"
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, (SPEED_YPOS * $08) - 1
    OUT (VDPDATA_PORT), A
    ; SET POINTER ARROWS
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; CHANGE LINE VAR
    LD A, $03
    LD (lineMode), A
    RET
@style:
    ; POINT TO "STYLE"
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, (STYLE_YPOS * $08) - 1
    OUT (VDPDATA_PORT), A
    ; SET POINTER ARROWS
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; CHANGE LINE VAR
    LD A, $04
    LD (lineMode), A
    RET
@sndTest:
    ; POINT TO "SOUND TEST"
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, (SND_YPOS * $08) - 1
    OUT (VDPDATA_PORT), A
    ; SET POINTER ARROWS
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; CHANGE LINE VAR
    LD A, $05
    LD (lineMode), A
    RET


/*
    INFO: UPDATES SOUND ID NUMBER GFX FOR SOUND TEST
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
updateSndTestTilemap:
;   SET VDP ADDRESS
    LD HL, NAMETABLE + ($15 * $02) + (SND_YPOS * $40) | VRAMWRITE
    RST setVDPAddress
;   1ST DIGIT (LEFT -> RIGHT)
    LD A, (sndTestIndex)
    ADD A, SFX_STOP ; CONVERT TO $80 BASED
    AND A, $F0
    RRCA
    RRCA
    RRCA
    RRCA
    LD HL, @numTable
    RST addToHL
    OUT (VDPDATA_PORT), A   ; TILE ID FOR DIGIT
    LD A, $01
    OUT (VDPDATA_PORT), A   ; HIGH BYTE (UPPER $100)
;   2ND DIGIT (LEFT -> RIGHT)
    LD A, (sndTestIndex)
    ADD A, SFX_STOP ; CONVERT TO $80 BASED
    AND A, $0F
    LD HL, @numTable
    RST addToHL
    OUT (VDPDATA_PORT), A   ; TILE ID FOR DIGIT
    LD A, $01
    OUT (VDPDATA_PORT), A   ; HIGH BYTE (UPPER $100)
    RET

;   TILE LIST FOR NUMBER DIGITS
@numTable:
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $0B ; 0
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $0C ; 1
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $0D ; 2
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $0E ; 3
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $0F ; 4
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $10 ; 5
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $11 ; 6
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $12 ; 7
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $13 ; 8
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $14 ; 9
    .DB (HUDTEXT_VRAM / TILE_SIZE) + $0A ; A
    .DB $12 ; B
    .DB $09 ; C
    .DB $07 ; D
    .DB $04 ; E
    .DB $08 ; F