/*
--------------------------------------------
    HELPER FUNCTIONS FOR ALL SUBSTATES
--------------------------------------------
*/


/*
    INFO: COMMON INITIALIZATION FOR CUTSCENES
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, E, HL
*/
commonCutsceneInit:
;   TURN OFF SCREEN
    CALL turnOffScreen
;   RESET SOME VARS
    XOR A
    LD (isNewState), A
    LD (cutsceneSubState), A
    LD (xUPCounter), A
    LD (pacPoweredUp), A
    LD (sprFlickerControl), A
    LD HL, $0000
    LD (mainTimer0), HL
    LD (mainTimer1), HL
;   CLEAR SPRITE TABLE
    LD B, L
    LD C, VDPDATA_PORT
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
-:
    OUT (C), L  ; L IS $00
    DJNZ -
;   CLEAR MAZE AREA OF TILEMAP (PAC/MS.PAC)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    RET NZ
    LD DE, ($01 * $100) + 24
    LD HL, NAMETABLE + ($02 * $02) | VRAMWRITE
--:
    RST setVDPAddress
    LD B, 21 ; 21 TILES PER ROW
    XOR A
-:
    OUT (VDPDATA_PORT), A
    OUT (C), D      ; UPPER $100
    DJNZ -
    LD A, $40
    RST addToHL
    DEC E
    JR NZ, --
    RET


/*
    INFO: PREPARE TO SWITCH BACK TO GAMEPLAY STATE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
switchToGameplay:
;   STOP MUSIC
    CALL sndStopAll
;   SWITCH FIRST READY MODE OF GAMEPLAY
    LD HL, GAMEPLAY_READY01 * $100 + M_STATE_GAMEPLAY
    LD (mainGameMode), HL
    LD A, $01
    LD (isNewState), A
;   DO GENERAL GAMEPLAY RESET
    JP generalResetFunc    


/*
--------------------------------------------
    HELPER FUNCTIONS FOR PAC-MAN SUBSTATES
--------------------------------------------
*/
pacCutsceneInit:
;   COMMON CUTSCENE SETUP
    CALL commonCutsceneInit
;   LOAD GFX DATA
    LD HL, cutsceneGhostTiles
    LD DE, cutscenePacTiles
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JR Z, +
    LD HL, arcadeGFXData@cutsceneGhost
    LD DE, arcadeGFXData@cutscenePac
+:
    ; GHOST SPRITES
    PUSH DE
    LD DE, SPRITE_ADDR + GHOST_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; GIANT PAC-MAN
    POP HL
    LD DE, SPRITE_ADDR + PAC_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; IF GAME IS PLUS MODE, OVERWRITE GHOST EYES
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    ; COPY TILES TO BUFFER
    LD HL, PACCUT_GHOST_PLUS * TILE_SIZE
    RST setVDPAddress
    LD HL, plusGhostSprBuffer
    LD BC, $02 * TILE_SIZE * $100 + VDPDATA_PORT
    INIR
    ; WRITE TO CORRECT VRAM ADDRESS
    LD HL, SPRITE_ADDR + GHOST_CUT_VRAM | VRAMWRITE
    RST setVDPAddress
    LD HL, plusGhostSprBuffer
    LD B, $02 * TILE_SIZE
    OTIR
+:
;   PLAY MUSIC
    LD A, MUS_COFFEE
    CALL sndPlayMusic
;   SETUP ACTORS (PAC-MAN AND BLINKY)
    ; SET PAC-MAN'S CURRENT X TILE
    LD A, $1F       ; ($08 >> $03) + $1E
    LD (pacman + CURR_X), A
    ; SET PAC-MAN'S X AND Y POSITION
    LD HL, $0008    ; YX
    LD (pacman.xPos), HL
    LD HL, $0094
    LD (pacman.yPos), HL
    ; CLEAR SUBPIXELS
    XOR A
    LD (pacman + SUBPIXEL), A
    LD (blinky + SUBPIXEL), A
    ; CLEAR GHOST VISUAL COUNTERS
    LD (flashCounter), A
    LD (frameCounter), A
    ; CLEAR BLINKY'S FLAGS
    LD (blinky + EDIBLE_FLAG), A
    LD (blinky + INVISIBLE_FLAG), A
    LD (blinky + OFFSCREEN_FLAG), A
    ; PAC-MAN FACING LEFT
    INC A   ; $01
    LD (pacman.currDir), A
    LD (pacman.nextDir), A
    ; BLINKY FACING LEFT
    LD (blinky.currDir), A
    LD (blinky.nextDir), A
    ; SET BLINKY SPRITE TABLE NUM
    LD A, $0A
    LD (blinky.sprTableNum), A
    ADD A, A
    LD (pinky.sprTableNum), A   ; WAS $0A, NOW $14
    LD (inky.sprTableNum), A    ; WAS $0D, NOW $14
    LD (clyde.sprTableNum), A   ; WAS $11, NOW $14
    LD (fruit.sprTableNum), A
    ; SET BLINKY'S CURRENT X TILE
    LD A, $1E       ; ($00 >> $03) + $1E
    LD (blinky + CURR_X), A
    ; SET X AND Y POSITION
    LD HL, $0000
    LD (blinky.xPos), HL
    LD HL, $0094
    LD (blinky.yPos), HL
    ; RESET STATE
    LD A, GHOST_SCATTER
    LD (blinky.state), A
;   SPRITE LIMIT AT $0E
    LD HL, (SPRITE_TABLE | VRAMWRITE) + $0E
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   TURN ON SCREEN
    CALL waitForVblank
    JP turnOnScreen


;   USED FOR CUTSCENE 1
pacCutSetSpritePal0:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
;   PALETTE SETUP
    LD HL, $001A | CRAMWRITE
    RST setVDPAddress
    LD A, $05       ; VERY DARK YELLOW FOR PAC-MAN'S SHADING (REPLACES DARK ORANGE)
    OUT (VDPDATA_PORT), A
    RET

;   USED FOR CUTSCENE 1
pacCutResSpritePal0:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
;   RESTORE PALETTE
    LD HL, $001A | CRAMWRITE
    RST setVDPAddress
    LD A, $06       ; DARK ORANGE
    OUT (VDPDATA_PORT), A
    RET


;   USED FOR CUTSCENES 2 AND 3
pacCutSetSpritePal:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
    ; PALETTE SETUP
    LD HL, $0015 | CRAMWRITE
    RST setVDPAddress
    LD A, $2B       ; TAN FOR BLINKY'S SKIN (REPLACES PINK)
    OUT (VDPDATA_PORT), A
    LD A, $16       ; DARK TAN FOR BLINKY'S SKIN SHADING (REPLACES DARK PINK)
    OUT (VDPDATA_PORT), A
    RET

;   USED FOR CUTSCENES 2 AND 3
pacCutResSpritePal:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
;   RESTORE PALETTE
    LD HL, $0015 | CRAMWRITE
    RST setVDPAddress
    LD A, $3B       ; PINK
    OUT (VDPDATA_PORT), A
    LD A, $26       ; DARK PINK
    OUT (VDPDATA_PORT), A
    RET



/*
--------------------------------------------------------
        CUTSCENE ANIMATION FUNCS FOR MS. PAC
--------------------------------------------------------
*/
;   COMMANDS:
;           $F0 - "LOOP":       X, Y
;           $F1 - "SET POS":    X, Y
;           $F2 - "SETN":       VAL (DB)
;           $F3 - "SET CHAR":   VAL (DW)
;           $F4 - "SET BG PRIORITY": VAL (DB) (NOT IMPLEMENTED)
;           $F5 - "PLAY SOUND": VAL (DB) (NOT IMPLEMENTED)
;           $F6 - "PAUSE":
;           $F7 - "CLR TEXT":
;           $F8 - "CLR NUM":  
;           $F9 - "SET BG PALETTE": VAL (DB)
;           $FA - "CLEAR POWER DOT": VAL (DB)
;           $FB - "SET JR VAR": VAL (DB)
;           $FC - "DECREMENT PTR": VAL (DB)
;           $FD - "SET OVERRIDE OFFSCREEN FLAG": VAL (DB)
;           $FE - "SET X MSB": VAL (DB)   
;           $FF - "END":

commandJumpTable:
    JP cutAniProcess@cmdLoop
    JP cutAniProcess@cmdSetPos
    JP cutAniProcess@cmdSetN
    JP cutAniProcess@cmdSetChar
    JP cutAniProcess@cmdSetBGPri        ; JR
    JP cutAniProcess@cmdPlaySnd
    JP cutAniProcess@cmdPause
    JP cutAniProcess@cmdClrText
    JP cutAniProcess@cmdClrNum
    JP cutAniProcess@cmdSetBGPal        ; JR
    JP cutAniProcess@cmdClrPowDot       ; JR
    JP cutAniProcess@cmdSetJrVar        ; JR
    JP cutAniProcess@cmdDecPtr          ; JR
    JP cutAniProcess@cmdSetOverrideFlag ; JR
    JP cutAniProcess@cmdSetHighXPos     ; JR
    JP cutAniProcess@cmdStop


cutsceneSubPrgSetup:
    PUSH HL ; SAVE FOR AFTER MEMSET
;   MEMSET CUTSCENE CONTROL VARS TO $00
    LD HL, cutsceneControl
    LD (HL), $00
    LD DE, cutsceneControl + 1
    LD BC, _sizeof_cutsceneControl - 1
    LDIR
;   INIT. CHARACTERS TO EMPTY SPRITE
    LD HL, cutsceneControl.charList
    LD (HL), lobyte(jrSceneCharacters@emptySpr)
    INC HL
    LD (HL), hibyte(jrSceneCharacters@emptySpr)
    DEC HL
    LD DE, cutsceneControl.charList + $02
    LD BC, _sizeof_cutsceneControl.charList - $02
    LDIR
;   COPY PROG PTRS TO RAM
    POP HL  ; CUTSCENE'S PROGRAM TABLE
    LD DE, cutsceneControl.ptrList
    LD BC, _sizeof_cutsceneControl.ptrList
    LDIR
    RET

cutsceneTilePtrSetup:
;   MAIN CHARACTER TILE PTR
    LD HL, msSceneMainTileTbl@msSN  ; MS.PAC-MAN [SMOOTH]
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    JR Z, +
    LD HL, msSceneMainTileTbl@msAN  ; MS.PAC-MAN [ARCADE]
+:
    BIT OTTO, A
    JR Z, +
    LD A, $18
    RST addToHL ; POINT TO OTTO
+:
    LD (msCut_MainTileTblPtr), HL
;   SUB CHARACTER TILE PTR
    LD HL, msSceneSubTileTbl@pacSN ; PAC-MAN [SMOOTH]
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    JR Z, +
    LD HL, msSceneSubTileTbl@pacAN ; PAC-MAN [ARCADE]
+:
    BIT OTTO, A
    JR Z, +
    LD A, $18
    RST addToHL ; POINT TO ANNA
+:
    LD (msCut_SubTileTblPtr), HL
;   JR TILE PTR
    LD HL, jrSceneJrTileTbl@jrPacSN ; JR.PAC-MAN [SMOOTH]
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    JR Z, +
    LD HL, jrSceneJrTileTbl@jrPacAN ; JR.PAC-MAN [ARCADE]
+:
    LD (jrCut_JrTileTblPtr), HL
;   GHOST TILE PTR
    LD HL, msSceneGhostTileTbl      ; NORMAL GHOSTS
    LD A, (plusBitFlags)
    BIT OTTO, A
    JR Z, +
    LD HL, msSceneGhostTileTbl@otto ; OTTO GHOSTS
+:
    LD (msCut_GhostTileTblPtr), HL
    RET


;   HL: PROG TABLE FOR CUTSCENE
msCutSetup:
;   CUTSCENE SUBPROGRAM SETUP
    CALL cutsceneSubPrgSetup
;   COMMON CUTSCENE SETUP
    CALL commonCutsceneInit
;   TILE POINTER SETUP
    CALL cutsceneTilePtrSetup
;   LOAD TILE DATA FOR CUTSCENES
    LD DE, babyOttoTileS
    LD HL, msCutsceneTiles
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JR Z, +
    LD DE, babyOttoTileA
    LD HL, arcadeGFXData@cutsceneMs
+:
    PUSH DE
    LD DE, SPRITE_ADDR + MS_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    POP HL
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    JR Z, @wait
    LD DE, $1A40 | VRAMWRITE
    LD BC, $20 * $100 + VDPCON_PORT
    OUT (C), E
    OUT (C), D
    DEC C
    LD A, UNCOMP_BANK
    LD (MAPPER_SLOT2), A
    OTIR
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
@wait:
;   TURN ON SCREEN
    CALL waitForVblank
    JP turnOnScreen


msCutDisplayAct:
;   DISPLAY TEXT @ [9, 7]
    LD HL, NAMETABLE + ($09 * $02) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; HL: ACT TEXT PTR
    LD BC, $08 * $100 + VDPDATA_PORT
    LD A, B     ; HIGH BYTE
-:
    OUTI
    OUT (C), A
    JR NZ, -
    ; HL NOW POINTS TO ACT NUMBER TILE ID
;   DISPLAY NUMBER IN ACT SIGN
    LD DE, $4043
    LD A, $18
    JP display1TileSprite


;   $00, $04, $08, $0C, $10, $14
;   $18 - ACT NUMBER
/*
    COMMON DRAW AND UPDATE FUNCTION
*/
msSceneCommonDrawUpdate:
;   DRAW 1UP
    CALL draw1UP
;   DO CUTSCENE DRAW
    ; SETUP
    LD IYL, PROG_AMOUNT - $01                                       ; COUNTER
    LD IX, cutsceneControl.charList + (PROG_AMOUNT-$02) * $02       ; START AT LAST CHAR
    LD DE, cutsceneControl.charOffsetList + (PROG_AMOUNT-$02)       ; START AT LAST OFFSET
    LD BC, cutsceneControl.posList + (PROG_AMOUNT-$02) * $02 + $01  ; START AT LAST Y       
-:
    ; GET CHARACTER ARRAY PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
    ; GET OFFSET WITHIN ARRAY
    LD A, (DE)
    SRA A
    DEC DE      ; POINT TO NEXT OFFSET
    PUSH DE     ; SAVE OFFSET PTR
    PUSH BC
    ; ADD OFFSET TO ARRAY PTR
    RST addToHL
    ; CHARACTER TYPE CHECK
    LD HL, msSceneCharTable
    OR A
    JR Z, @convPos  ; BYPASS IF 0
;   ------
;   CUTSCENE SPECIFIC GFX
;   ------
    CP A, $21
    JR C, +
    SUB A, $20
    ADD A, A
    ADD A, A
    RST addToHL
    JR @convPos
+:
;   ------
;   GHOST SPECIFIC GFX
;   ------
    CP A, $19
    JR C, +
        ; GET POINTER
    SUB A, $19
    ADD A, A
    ADD A, A
    LD HL, (msCut_GhostTileTblPtr)
    RST addToHL
    JR @convPos
+:
;   ------
;   MAIN CHARACTER GFX
;   ------
    CP A, $0D
    JR C, +
        ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0B20 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
        ; GET POINTER
    SUB A, $0D
    ADD A, A
    LD HL, (msCut_MainTileTblPtr)
    RST addToHL
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
        ; WRITE TILE DATA TO VRAM
    CALL pacTileStreaming@writeToVRAM
    LD HL, playerTileList
    JR @convPos
+:
;   ------
;   SUB CHARACTER GFX
;   ------
        ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0BA0 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
        ; GET POINTER
    DEC A
    ADD A, A
    LD HL, (msCut_SubTileTblPtr)
    RST addToHL
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
        ; WRITE TILE DATA TO VRAM
    CALL pacTileStreaming@writeToVRAM
    LD HL, playerTwoTileList
@convPos:
    POP BC
    ; CONVERT POSITION FROM LOGICAL TO REAL
    DEC BC      ; POINT TO NEXT POS
    DEC BC
    PUSH BC     ; SAVE POS PTR
    PUSH IX     ; SAVE CHAR ARR PTR
    LD IXH, B   ; COPY POS PTR TO IX
    LD IXL, C
    ; CONVERSION FROM 8px TILES TO 6px TILES (X)
    LD A, (IX + X_WHOLE)    
    LD IYH, A   ; IYH = X
    SRL A
    SRL A
    LD C, A     ; C = X / 4
    LD A, IYH
    SUB A, C
    LD D, A     ; D = IYH - C
    LD A, $BE   ; X = $BE - X
    SUB A, D
    LD D, A
    ; CONVERSION FROM 8px TILES TO 6px TILES (Y)
    LD A, (IX + X_WHOLE + $01)
    LD IYH, A   ; IYH = Y
    SRL A
    SRL A
    LD C, A     ; C = Y / 4
    LD A, IYH
    SUB A, C    ; A = IYH - C
    SUB A, $0C  ; Y = Y - $0C
    LD E, A
    POP IX      ; RESTORE CHAR ARR PTR
    ; CALCULATE SPRITE TABLE NUM ((COUNTER - 1) * 4)
    LD A, IYL
    DEC A
    ADD A, A
    ADD A, A
    ; DISPLAY SPRITE
    CALL display4TileSprite
    ; PREPARE FOR NEXT LOOP
    POP BC  ; RESTORE POS PTR
    POP DE  ; RESTORE OFFSET PTR
    DEC IX  ; POINT TO NEXT CHAR PTR
    DEC IX
    DEC IYL ; KEEP LOOPING UNTIL COUNTER IS 0
    JP NZ, -
;   FALL THROUGH



/*
    CUTSCENE PROCESSING FUNCTION
*/
cutAniProcess:
;   SETUP
    LD A, CUTSCENE_DATA_BANK
    LD (MAPPER_SLOT2), A
    LD B, PROG_AMOUNT
    LD IX, cutsceneControl.ptrList + (PROG_AMOUNT-1) * $02
@loop:
;   GET SUB PROG PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
;   GET BYTE
    LD A, (HL)
;   CHECK FOR COMMAND
    LD IY, commandJumpTable
    AND A, $0F
    LD C, A
    ADD A, A
    ADD A, C
    ADD A, IYL
    LD IYL, A
    ADC A, IYH
    SUB A, IYL
    LD IYH, A
    JP (IY)

/*
    COMMAND - "LOOP": X, Y
    $F0
*/
@cmdLoop:
;   SAVE PROG PTR
    PUSH HL
;   PROCESS X MOVEMENT
    ; GET FIRST BYTE (X)
    INC HL
    LD C, (HL)
    ; GET CORRECT ADDRESS FOR TEMP POS
    LD HL, cutsceneControl.tempPosList - $02
    CALL ptrDeref
    ; CALCULATE MOVEMENT
    LD A, C
    ADD A, L
    CALL cutFuncCalcMovement
    DEC DE
    LD (DE), A
    ; STORE MOVEMENT
    LD HL, cutsceneControl.posList - $02
    CALL ptrDeref
    LD A, L
    ADD A, C
    DEC DE
    LD (DE), A
        ; HIGH BYTE (JR)
    PUSH AF
    LD HL, cutsceneControl.highXList - $01
    LD A, B
    RST addToHL
    POP AF
    LD A, (HL)
    ADC A, $00
    BIT 7, C
    JP Z, +
    DEC A
+:
    LD (HL), A
    ; RESTORE PROG PTR
    POP HL
    PUSH HL
;   PROCESS Y MOVEMENT
    ; GET SECOND BYTE (Y)
    INC HL
    INC HL
    LD C, (HL)
    ; GET CORRECT ADDRESS FOR TEMP POS
    LD HL, cutsceneControl.tempPosList - $02
    CALL ptrDeref
    ; CALCULATE MOVEMENT
    LD A, C
    ADD A, H
    CALL cutFuncCalcMovement
    LD (DE), A
    ; STORE MOVEMENT
    LD HL, cutsceneControl.posList - $02
    CALL ptrDeref
    LD A, H
    ADD A, C
    LD (DE), A
;   PROCESS CHARACTER ARRAY
    ; GET CORRECT OFFSET 
    LD HL, cutsceneControl.charOffsetList - $01
    LD A, B
    RST addToHL
    PUSH HL     ; SAVE FOR LATER
    ; INCREMENT OFFSET AND STORE IN C
    INC A
    LD C, A
-:
    ; GET CHARACTER ARRAY FOR SUB PROG
    LD HL, cutsceneControl.charList - $02
    CALL ptrDeref
    LD A, C     ; GET BACK COUNTER
    SRA A       ; DIVIDE BY 2 (WHY?)
    RST addToHL
    CP A, $FF
    JR NZ, +    ; SKIP, IF NOT $FF (END OF ARRAY)
    LD C, $00   ; RESET OFFSET
    JR -        ; LOOP
+:
    POP HL      ; GET BACK OFFSET PTR
    LD (HL), C  ; SAVE NEW OFFSET
    POP HL      ; RESTORE PROG PTR
;   PROCESS COLOR (NOT NEEDED)
;   TIMER CHECK
    LD HL, cutsceneControl.timerList - $01
    LD A, B
    RST addToHL
    DEC A
    LD (HL), A
    LD DE, $0000
    JP NZ, cmdCleanUp01
    LD E, $03
    JP cmdCleanUp01


/*
    COMMAND - "SET POS": X, Y
    $F1
*/
@cmdSetPos:
    EX DE, HL   ; DE: PROG PTR // HL: N/A
    LD HL, cutsceneControl.posList - $02
    EX DE, HL   ; DE: FUNC POS // HL: PROG PTR
    PUSH DE     ; SAVE FUNC POS PTR
;   GET X AND Y DATA FROM PROGRAM
    INC HL
    LD E, (HL)  ; X
    INC HL
    LD D, (HL)  ; Y
    ; DE: YX
    JP cmdCleanUp

/*
    COMMAND - "SETN": VAL (DB)
    $F2
*/
@cmdSetN:
;   GET BYTE FROM PROGRAM
    INC HL
    LD C, (HL)
;   GET CORRECT ADDRESS FOR TIMER
    LD HL, cutsceneControl.timerList - $01
    LD A, B
    RST addToHL
;   STORE TIMER VALUE
    LD (HL), C
;   FINISH
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, jrCmdCleanUp
    LD DE, $0002    ; ADVANCE PROG PTR BY 2 BYTES
    JP cmdCleanUp01

/*
    COMMAND - "SET CHAR": VAL (DW)
    $F3
*/
@cmdSetChar:
;   CLEAR SPRITE ARRAY OFFSET
    EX DE, HL   ; DE: PROG PTR // HL: N/A
    LD HL, cutsceneControl.charOffsetList - $01
    LD A, B
    RST addToHL
    LD (HL), $00
;   GET NEW CHAR ARRAY PTR
    EX DE, HL   ; DE: N/A // HL: PROG PTR
    LD DE, cutsceneControl.charList - $02
    PUSH DE
    INC HL
    LD E, (HL)
    INC HL
    LD D, (HL)
    JP cmdCleanUp 


/*
    COMMAND - "PLAY SOUND"
    $F5
*/
@cmdPlaySnd:
;   DO NOTHING
    LD DE, $0002    ; ADVANCE BY 2 BYTES
    JP cmdCleanUp01 


/*
    COMMAND - "PAUSE"
    $F6
*/
@cmdPause:
;   GET CORRECT ADDRESS FOR TIMER
    LD HL, cutsceneControl.timerList - $01
    LD A, B
    RST addToHL
;   DECREMENT TIMER
    DEC A
    LD (HL), A
;   FINISH
    LD DE, $0000        ; ADVANCE PROG PTR BY 0 BYTES...
    JP NZ, cmdCleanUp01 ; IF TIMER VALUE ISN'T 0
    LD E, $01           ; ELSE, ADVANCE BY 1 BYTE
    JP cmdCleanUp01


/*
    COMMAND - "CLEAR TEXT"
    COMMAND - "REMOVE PRIORITY OF FENCE" FOR JR.PAC
    $F7
*/
@cmdClrText:
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @@cmdBlankTiles
;   CLEAR TEXT (ACT NAME) ON SCREEN
    LD HL, NAMETABLE + ($09 * $02) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    LD C, $10 >> $01    ; $08
    XOR A
-:
    OUT (VDPDATA_PORT), A   ; TILE ID: 0
    INC A
    OUT (VDPDATA_PORT), A   ; UPPER $100
    DEC A
    DEC C
    JR NZ, -
;   FINISH
    LD DE, $0001    ; ADVANCE PROG PTR BY 1 BYTE
    JP cmdCleanUp01
@@cmdBlankTiles:
;   REMOVE PRIORITY FROM FENCE IN CUTSCENE 1
    LD A, $01
    LD C, VDPCON_PORT
    ; ROW 0
    LD HL, NAMETABLE + (10 * $02) + (12 * $40) + $01 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
    OUT (VDPDATA_PORT), A   ; T 0
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 1
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 2
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 3
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 4
    ; ROW 1
    INC C
    LD HL, NAMETABLE + (10 * $02) + (13 * $40) + $01 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
    OUT (VDPDATA_PORT), A   ; T 0
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 1
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 2
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 3
    LD D, (IX + 0)
    IN F, (C)
    LD D, (IX + 0)
    OUT (VDPDATA_PORT), A   ; T 4
;   FINISH
    JP jrCmdCleanUp



/*
    COMMAND - "CLEAR NUM"
    COMMAND - "NO OPERATION" FOR JR.PAC
    $F8
*/
@cmdClrNum:
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @@cmdNop
;   CLEAR ACT NUMBER ON SCREEN
    LD HL, SPRITE_TABLE + $18 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   FINISH
    LD DE, $0001    ; ADVANCE PROG PTR BY 1 BYTE
    JP cmdCleanUp01
@@cmdNop:
;   GET PROG PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
;   ADD BYTE ADVANCEMENT
    INC HL
;   SAVE
    LD (IX + 0), L
    LD (IX + 1), H
    JP cutAniProcess@loop


/*
    COMMAND - "SET BACKGROUND PRIORTY OVER SPRITES" - NOT NEEDED
    $F4
*/
@cmdSetBGPri:
    JP jrCmdCleanUp


/*
    COMMAND - "SET BACKGROUND PALETTE?" - NOT NEEDED
    $F9
*/
@cmdSetBGPal:
    INC HL
    BIT 7, (HL)
    JP Z, jrCmdCleanUp
;   SET BACKGROUND PALETTE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD HL, bgPalJrFD
    LD C, $10
-:
    LD A, (HL)
    OUT (VDPDATA_PORT), A
    INC HL
    DEC C
    JP NZ, -
    JP jrCmdCleanUp


/*
    COMMAND - "CLEAR POWER DOT AND PLAY FRIGHT SFX" - JR.PAC'S INTERMISSION 1
    $FA
*/
@cmdClrPowDot:
;   CLEAR EATEN POWER DOT TILE
    LD HL, NAMETABLE + (22 * $02) + ($05 * $40) | VRAMWRITE
    RST setVDPAddress
    LD A, $02
    OUT (VDPDATA_PORT), A
;   FRIGHT SFX IS BAKED INTO MUSIC
    JP jrCmdCleanUp


/*
    COMMAND - "SET VAR (USED BY COMMAND $FC)"
    $FB
*/
@cmdSetJrVar:
    INC HL
    LD A, (HL)
    LD (jrCutsceneVarFB), A
    JP jrCmdCleanUp


/*
    COMMAND - "DECREMENT PROGRAM PTR BY 8 (DEPENDING ON VAR)?"
    $FC
*/
@cmdDecPtr:
    INC HL
    LD A, (jrCutsceneVarFB)
    SUB A, (HL)
    JP Z, jrCmdCleanUp
    LD L, (IX + 0)
    LD H, (IX + 1)
    OR A
    LD DE, $0008
    SBC HL, DE
    LD (IX + 0), L
    LD (IX + 1), H
    JP jrCmdCleanUp


/*
    COMMAND - "SET OVERRIDE FLAG FOR OFFSCREEN FLAG"
    $FD
    [NEW]
*/
@cmdSetOverrideFlag:
;   GET BYTE FROM PROGRAM
    INC HL
    LD C, (HL)
;   GET CORRECT ADDRESS FOR OVERRIDE FLAGS
    LD HL, jrCut_OverrideFlags - $01
    LD A, B
    RST addToHL
;   STORE FLAG VALUE
    LD (HL), C
    JP jrCmdCleanUp


/*
    COMMAND - "SET HIGH BYTE OF X POSITION"
    COMMAND - "SET SPRITE INDEX OF CHAR ARRAY"
    $FE
    [NEW]
*/
@cmdSetHighXPos:
;   GET BYTE FROM PROGRAM
    INC HL
    LD C, (HL)
    LD HL, cutsceneControl.highXList - $01
;   IF VALUE IS GREATER THAN 2, SET SPRITE INDEX
    LD A, C
    CP A, $02
    JR C, +
    LD HL, cutsceneControl.charOffsetList - $01
+:
;   GET CORRECT ADDRESS
    LD A, B
    RST addToHL
;   STORE VALUE
    LD (HL), C
    JP jrCmdCleanUp
    


/*
    COMMAND - "STOP"
    $FF
*/
@cmdStop:
;   GET CORRECT ADDRESS FOR DONE FLAG
    LD HL, cutsceneControl.doneList - $01
    LD A, B
    RST addToHL
;   SET FLAG
    LD (HL), $01
;   CHECK IF ALL FLAGS ARE SET
    LD HL, cutsceneControl.doneList
    LD A, (HL)
.REPEAT PROG_AMOUNT - $01
    INC HL
    AND A, (HL)
.ENDR
;   FINISH
    LD DE, $0000        ; ADVANCE BY 0 BYTES...
    JR Z, cmdCleanUp01  ; IF ANY FLAG ISN'T SET (PROG NOT DONE)
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   30 FRAME WAIT AREA
    ; CHECK IF TIMER HAS BEEN INITIALIZED
    LD A, (mainTimer1 + 1)
    OR A
    JP NZ, +    ; IF SO, SKIP
    ; INITIALIZE TIMER FOR 30 FRAMES
    LD HL, $01 * $100 + 30
    LD (mainTimer1), HL
+:
    ; DECREMENT TIMER
    LD HL, mainTimer1
    DEC (HL)
    RET NZ
    ; SWITCH TO NEW STATE WHEN TIMER EXPIRES
    LD A, (mainGameMode)
    OR A
    JP NZ, switchToGameplay
    ; ATTRACT MODE
    JP demoPrep


/*
    ADDITIONAL CLEAN UP FOR COMMANDS $F1, $F3
*/
cmdCleanUp:
    POP HL      ; HL: ADDRESS USED BY COMMAND
    PUSH DE     ; DE: DATA RETRIEVED BY COMMAND 
    CALL ptrDeref
    EX DE, HL   ; DE: DATA AT HL // HL: CORRECT ADDRESS FOR COMMAND
    POP DE      ; DE: DATA RETRIEVED BY COMMAND
;   STORE DATA RETRIEVED BY COMMAND AT CORRECT ADDRESS
    LD (HL), D
    DEC HL
    LD (HL), E
;   FINISH
    LD DE, $0003    ; ADVANCE PROG PTR BY 3 BYTES
;   FALL THROUGH


/*
    CLEAN UP FOR ALL COMMANDS
*/
cmdCleanUp01:
;   GET PROG PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
;   ADD BYTE ADVANCEMENT
    ADD HL, DE
;   SAVE
    LD (IX + 0), L
    LD (IX + 1), H
;   POINT TO NEXT PROG
    DEC IX
    DEC IX
;   CHECK IF ALL PROGS HAVE BEEN EXECUTED
    DEC B
    JP NZ, cutAniProcess@loop   ; IF NOT, KEEP LOOPING
    RET


/*
    CLEAN UP FOR COMMANDS: $F2, $F4, $F9, $FA, $FB, $FC
*/
jrCmdCleanUp:
    LD DE, $0002
;   GET PROG PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
;   ADD BYTE ADVANCEMENT
    ADD HL, DE
;   SAVE
    LD (IX + 0), L
    LD (IX + 1), H
    JP cutAniProcess@loop




/*
    POINTER DEREFERENCE (RST $18)
*/
ptrDeref:
    LD A, B
    ADD A, A
    RST addToHL
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL   ; DE: (HL + 2B) // HL: DATA AT (HL + 2B)
    RET


/*
    MOVEMENT ADJUSTER / CALCULATOR
    ***FRACTIONAL POSITION***
*/
cutFuncCalcMovement:
    LD C, A
    SRA C
    SRA C
    SRA C
    SRA C
    AND A, A
    JP P, +
    OR A, $F0
    INC C
    RET
+:
    AND A, $0F
    RET


/*
--------------------------------------------------------
        CUTSCENE ANIMATION FUNCS FOR JR.PAC
--------------------------------------------------------
*/

;   HL: PROG TABLE FOR CUTSCENE
jrCutSetup:
;   CUTSCENE SUBPROGRAM SETUP
    CALL cutsceneSubPrgSetup
;   COMMON CUTSCENE SETUP
    CALL commonCutsceneInit
;   DISABLE H-INTS
    CALL turnOffLineInts
;   DISABLE SPRITES AT INDEX $15
    LD HL, SPRITE_TABLE + $1C | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   INITIALIZE A BUNCH OF VARS
    XOR A
    LD L, A
    LD H, A
    ; ALL SCROLL VARS
    LD (jrScrollReal), HL
    LD (jrOldScrollReal), HL
    LD (jrColumnToUpdate), A
    LD (updateColFlag), A
    LD (jrCameraPos), A
    LD (enableScroll), A
    OUT (VDPCON_PORT), A
    LD A, $88
    OUT (VDPCON_PORT), A
    ; SPECIAL CUTSCENE VAR
    XOR A
    LD (jrCutsceneVarFB), A
    ; OFFSCREEN FLAGS
    LD (blinky + OFFSCREEN_FLAG), A
    LD (pinky + OFFSCREEN_FLAG), A
    LD (inky + OFFSCREEN_FLAG), A
    LD (clyde + OFFSCREEN_FLAG), A
    LD (pacman + OFFSCREEN_FLAG), A
    LD (fruit + OFFSCREEN_FLAG), A
    ; INIT. OVERRIDE FLAGS 
    LD HL, jrCut_OverrideFlags
    LD DE, jrCut_OverrideFlags + $01
    LD BC, PROG_AMOUNT - $02    ; ONLY 6 ACTORS/OFFSCREEN FLAGS
    LD (HL), $01
    LDIR
    ; INIT. OFFSCREEN FLAGS FOR CUTSCENES (COPY OF ACTOR FLAGS)
    LD HL, jrCutScreenFlagList
    LD DE, jrCutScreenFlagList + $01
    LD BC, PROG_AMOUNT - $01
    LD (HL), $00
    LDIR
;   TILE POINTER SETUP
    CALL cutsceneTilePtrSetup
;   LOAD GRAPHICS
    ; MS.PAC GFX (STORK, SACK, HEART)
    LD HL, msCutsceneTiles
        ; SMOOTH / ARCADE CONTROL PATH
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JR Z, +
    LD HL, arcadeGFXData@cutsceneMs
+:
    LD DE, SPRITE_ADDR + JR_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; JR. GFX
    LD HL, jrCutsceneTiles  ; ASSUME SMOOTH
    LD DE, SPRITE_ADDR + JR_CUT_VRAM + ($0D * $20) | VRAMWRITE
        ; SMOOTH / ARCADE CONTROL PATH
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JP Z, zx7_decompressVRAM
    LD HL, arcadeGFXData@cutsceneJr
    LD A, bank(arcadeGFXData@cutsceneJr)
    LD (MAPPER_SLOT2), A
    CALL zx7_decompressVRAM
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    RET



jrSceneCommonDrawUpdate:
;   DO CUTSCENE DRAW
    ; COPY OFFSCREEN FLAGS TO SEQUENTIAL ARRAY
    LD DE, jrCutScreenFlagList
    LD HL, jrCut_OverrideFlags
    LD A, (blinky + OFFSCREEN_FLAG)
    AND A, (HL)
    LD (DE), A
    INC DE
    INC HL
    LD A, (pinky + OFFSCREEN_FLAG)
    AND A, (HL)
    LD (DE), A
    INC DE
    INC HL
    LD A, (inky + OFFSCREEN_FLAG)
    AND A, (HL)
    LD (DE), A
    INC DE
    INC HL
    LD A, (clyde + OFFSCREEN_FLAG)
    AND A, (HL)
    LD (DE), A
    INC DE
    INC HL
    LD A, (pacman + OFFSCREEN_FLAG)
    AND A, (HL)
    LD (DE), A
    INC DE
    INC HL
    LD A, (fruit + OFFSCREEN_FLAG)
    AND A, (HL)
    LD (DE), A
    ; SETUP
    LD IYL, PROG_AMOUNT                         ; COUNTER
    LD IX, cutsceneControl.charList + (PROG_AMOUNT-1) * $02         ; START AT LAST CHAR
    LD DE, cutsceneControl.charOffsetList + (PROG_AMOUNT-1)         ; START AT LAST OFFSET
    LD BC, cutsceneControl.posList + (PROG_AMOUNT-1) * $02 + $01    ; START AT LAST Y
-:
    ; SKIP IF OFFSCREEN FLAG IS SET
    LD HL, jrCutScreenFlagList - $01
    LD A, IYL
    addToHL_M
    LD A, (HL)
    OR A
    JP Z, +
@clearObject:
    ; CLEAR OBJECT
    LD A, IYL
    DEC A
    ADD A, A
    ADD A, A
    OUT (VDPCON_PORT), A   ; LOW BYTE
    LD A, hibyte(SPRITE_TABLE) | hibyte(VRAMWRITE)
    OUT (VDPCON_PORT), A   ; HIGH BYTE
    LD A, $F0
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    DEC DE
    DEC BC
    DEC BC
    JP @nextLoop
+:
    ; GET CHARACTER ARRAY PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
    ; GET OFFSET WITHIN ARRAY
    LD A, (DE)
    SRA A
    DEC DE      ; POINT TO NEXT OFFSET
    PUSH DE     ; SAVE OFFSET PTR
    PUSH BC
    ; ADD OFFSET TO ARRAY PTR
    addToHL_M
    LD A, (HL)
    ; CHARACTER TYPE CHECK
    LD HL, jrSceneCharTable
    OR A
    JP Z, @convPos  ; BYPASS IF 0
;   ------
;   CUTSCENE SPECIFIC GFX
;   ------
    CP A, $31
    JR C, ++
        ; SCARED GHOST PLUS (ADD 4)
    CP A, $50
    JR C, +
    LD B, A
    LD A, (plusBitFlags)
    AND A, $01 << PLUS
    ADD A, A
    ADD A, A
    ADD A, B
+:
    SUB A, $30
    ADD A, A
    ADD A, A
    addToHL_M
    JP @convPos
++:
;   ------
;   GHOST SPECIFIC GFX
;   ------
    CP A, $19
    JR C, +
        ; GET POINTER
    SUB A, $19
    ADD A, A
    ADD A, A
    LD HL, (msCut_GhostTileTblPtr)
    addToHL_M
    JP @convPos
+:
;   ------
;   MAIN CHARACTER GFX [MS.PAC, OTTO]
;   ------
    CP A, $0D
    JR C, +
        ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0B20 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
        ; GET POINTER
    SUB A, $0D
    ADD A, A
    LD HL, (msCut_MainTileTblPtr)
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
        ; WRITE TILE DATA TO VRAM
    CALL pacTileStreaming@writeToVRAM
    LD HL, playerTileList
    JP @convPos
+:
;   ------
;   JR CHARACTER GFX
;   ------
    CP A, $05
    JR C, +
        ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0AA0 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
        ; GET POINTER
    SUB A, $05
    ADD A, A
    LD HL, (jrCut_JrTileTblPtr)
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
        ; WRITE TILE DATA TO VRAM
    CALL pacTileStreaming@writeToVRAM
    LD HL, jrTileList
    JP @convPos
+:
;   ------
;   SUB CHARACTER GFX [PAC-MAN, ANNA]
;   ------
        ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0BA0 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
        ; GET POINTER
    DEC A
    ADD A, A
    LD HL, (msCut_SubTileTblPtr)
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
        ; WRITE TILE DATA TO VRAM
    CALL pacTileStreaming@writeToVRAM
    LD HL, playerTwoTileList
@convPos:
    POP BC
    ; CONVERT POSITION FROM LOGICAL TO REAL
    DEC BC      ; POINT TO NEXT POS
    DEC BC
    PUSH BC     ; SAVE POS PTR
    PUSH IX     ; SAVE CHAR ARR PTR
    LD IXH, B   ; COPY POS PTR TO IX
    LD IXL, C
    ; CHANGE BANK FOR SCALE TABLE
    LD A, JR_TABLES_BANK
    LD (MAPPER_SLOT2), A
    ; CONVERSION FROM 8px TILES TO 6px TILES (X)
    LD A, (jrCameraPos)
    LD C, A
        ; POS -> INDEX
    LD E, (IX + X_WHOLE)
    PUSH HL
    LD HL, cutsceneControl.highXList - $01
    LD A, IYL
    addToHL_M
    LD D, (HL)
    POP HL
    SLA E
    RL D
        ; ADD HIGH BYTES
    LD A, D
    ADD A, hibyte(jrScaleTable)
    LD D, A
        ; GET VALUE
    LD A, (DE)
    ; WORLD POS -> SCREEN POS
    SUB A, C
    LD D, A
    ; CONVERSION FROM 8px TILES TO 6px TILES (Y)
    LD A, (IX + X_WHOLE + 1)
    LD IYH, A   ; IYH = Y
    SRL A
    SRL A
    LD C, A     ; C = Y / 4
    LD A, IYH
    SUB A, C    ; A = IYH - C
    SUB A, $06  ; $0c
    LD E, A
    ; REVERT BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    ; RESTORE CHAR ARR PTR
    POP IX
    ; CALCULATE SPRITE TABLE NUM ((COUNTER - 1) * 4)
    LD A, IYL
    DEC A
    ADD A, A
    ADD A, A
    ; DISPLAY SPRITE
    CALL display4TileSprite
    ; PREPARE FOR NEXT LOOP
    POP BC  ; RESTORE POS PTR
    POP DE  ; RESTORE OFFSET PTR
@nextLoop:
    DEC IX  ; POINT TO NEXT CHAR PTR
    DEC IX
    DEC IYL ; KEEP LOOPING UNTIL COUNTER IS 0
    JP NZ, -
;   SUB PROGRAM UPDATE
    CALL cutAniProcess
    ; EXIT IF CUTSCENE ENDED
    LD A, (isNewState)
    OR A
    RET NZ
;   SCROLL POSITION UPDATE
    LD HL, cutsceneControl.posList
    LD DE, cutsceneControl.highXList
    ; BLINKY
    LD C, (HL)  ; X LOW BYTE
    LD A, (DE)  ; X HIGH BYTE
    LD B, A
    LD (blinky + X_WHOLE), BC
    INC HL
    INC DE
    LD A, (HL)
    LD (blinky + Y_WHOLE), A
    INC HL
    ; PINKY
    LD C, (HL)  ; X LOW BYTE
    LD A, (DE)  ; X HIGH BYTE
    LD B, A
    LD (pinky + X_WHOLE), BC
    INC HL
    INC DE
    LD A, (HL)
    LD (pinky + Y_WHOLE), A
    INC HL
    ; INKY
    LD C, (HL)  ; X LOW BYTE
    LD A, (DE)  ; X HIGH BYTE
    LD B, A
    LD (inky + X_WHOLE), BC
    INC HL
    INC DE
    LD A, (HL)
    LD (inky + Y_WHOLE), A
    INC HL
    ; CLYDE
    LD C, (HL)  ; X LOW BYTE
    LD A, (DE)  ; X HIGH BYTE
    LD B, A
    LD (clyde + X_WHOLE), BC
    INC HL
    INC DE
    LD A, (HL)
    LD (clyde + Y_WHOLE), A
    INC HL
    ; PAC-MAN
    LD C, (HL)  ; X LOW BYTE
    LD A, (DE)  ; X HIGH BYTE
    LD B, A
    LD (pacman + X_WHOLE), BC
    INC HL
    INC DE
    LD A, (HL)
    LD (pacman + Y_WHOLE), A
    INC HL
    ; FRUIT
    LD C, (HL)  ; X LOW BYTE
    LD A, (DE)  ; X HIGH BYTE
    LD B, A
    LD (fruit + X_WHOLE), BC
    INC HL
    INC DE
    LD A, (HL)
    LD (fruit + Y_WHOLE), A
;   CALCULATE SCROLL VALUE
    ; CHANGE BANK FOR TABLES
    LD A, JR_TABLES_BANK
    LD (MAPPER_SLOT2), A
    ; NEW TO OLD
    LD A, (jrScrollReal)
    LD (jrOldScrollReal), A
    ; SCALE PAC-MAN'S POS TO 3/4 USING TABLE
        ; POS -> INDEX
    LD A, (pacman + X_WHOLE)
    LD L, A
    LD A, (pacman + X_WHOLE + 1)
    LD H, A
    ADD HL, HL
        ; ADD HIGH BYTES
    LD A, H
    ADD A, hibyte(jrScaleTable)
    LD H, A
        ; GET VALUE
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; SCROLL CALCULATION
        ; SKIP IF AT MAX LEFT SCROLL
    LD DE, $002C + $01
    OR A
    SBC HL, DE
    ADD HL, DE
    JP C, updateJRScroll@cutsceneJump
    EX DE, HL
    LD HL, $0154    ; FLIP X AXIS (MAX RIGHT POSITION)
    OR A
    SBC HL, DE
    EX DE, HL
        ; MAX SCROLL DETERMINATION
    LD HL, $00D8    ; ATTRACT, CUTSCENE 1,2
    LD A, (subGameMode)
    CP A, CUTSCENE_JRP02
    JP NZ, +
    LD HL, $0080    ; CUTSCENE 3
+:
    ADD HL, DE
    LD A, L
    RRC H
        ; CAP TO $28 (MAX LEFT SCROLL)
    JR NC, +
    CP A, $28
    JR C, +
    LD A, $28
+:
    LD (jrScrollReal), A
;   CALCULATE LEFT MOST TILE
    SRA A
    SRA A
    SRA A
    NEG
    ADD A, $04
    LD (jrLeftMostTile), A
    ; OVERBOUNDS CHECK FOR CUTSCENE 3
    INC A
    CP A, $0B   ; SCROLL MORE THAN $D8
    JP C, updateJRScroll@cutsceneJump
    XOR A       ; WILL BE ADDED TO $1F, SINCE SCROLLING RIGHT
    LD (jrLeftMostTile), A
;   UPDATE CAMERA POS, OFFSCREEN FLAGS, COLUMN, SCROLL FLAG
    JP updateJRScroll@cutsceneJump