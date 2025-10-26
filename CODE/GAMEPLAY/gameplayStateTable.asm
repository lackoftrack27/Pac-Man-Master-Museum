/*
----------------------------------------------
    DEFINES FOR GAMEPLAY MODE (TEMP RAM)
----------------------------------------------
*/
;       PAC/MS.PAC
.DEFINE     playerSprBuffer     workArea + $00      ; $80 BYTES
;       JR.PAC
.DEFINE     mazeTextBuffer      workArea + $00      ; $2E BYTES




/*
----------------------------------------------
    SUB STATE TABLE FOR GAMEPLAY MODE
----------------------------------------------
*/
sStateGameplayTable:
    .dw @ready00Mode    ; 00
    .dw @ready01Mode    ; 01
    .dw @normalMode     ; 02
    .dw @dead00Mode     ; 03
    .dw @dead01Mode     ; 04
    .dw @dead02Mode     ; 05
    .dw @comp00Mode     ; 06
    .dw @comp01Mode     ; 07
    .dw @gameoverMode   ; 08





/*
----------------------------------------------
            GAMEPLAY MODE CODE
----------------------------------------------
*/

.INCLUDE "ready.asm"
.INCLUDE "normal.asm"
.INCLUDE "dead.asm"
.INCLUDE "lvlComplete.asm"
.INCLUDE "gameOver.asm"



/*
-------------------------------------------
    GAMEPLAY INITIALIZATION FUNCTION
-------------------------------------------
*/
gamePlayInit:
/*
----------------------------------------------------------
        FIRST TIME INITIALIZATION FOR GAMEPLAY MODE
----------------------------------------------------------
*/
;   TURN OFF DISPLAY
    CALL turnOffScreen
;   LOAD HUD TEXT TILES....
    LD A, bank(hudTextTiles)
    LD (MAPPER_SLOT2), A
    CALL loadHudTiles
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   CLEAR TILE BUFFER FLAG
    XOR A
    LD (tileBufferFlag), A      ; WHY IS THIS CLEARED HERE?
    LD (fruitTileBufFlag), A
;   MEMSET PLAYER INFO TO 0
    LD HL, currPlayerInfo
    LD DE, currPlayerInfo + 1
    LD BC, _sizeof_playerInfo - 1
    LD (HL), A
    LDIR
;   SET PLAYER TYPE AND LIVES
    ; CHECK IF IN DEMO MODE
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    LD A, (startingLives) ; ASSUME GAME ISN'T IN DEMO MODE (LIVES WOULD BE SET TO STARTING LIVES)
    JR Z, +    ; IF GAME IS NOT IN DEMO MODE, SKIP...
    ; IN DEMO MODE, SO IGNORE PLAYER MODE AND ONLY GIVE 1 LIFE
    XOR A
    LD (playerType), A
+:
    LD (currPlayerInfo.lives), A
;   SET DIFFICULTY TO NORMAL OR HARD
    ; USE DIFFERENT TABLE DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    LD A, (normalFlag)
    JR NZ, @jrDiffSetup
    ; PAC-MAN / MS.PAC-MAN
    LD HL, levelTableNormal
    OR A
    JR Z, +
    LD HL, levelTableHard
    LD (currPlayerInfo.levelTablePtr), HL
    JR @setupP2
@jrDiffSetup:
    ; JR.PAC-MAN
    LD HL, levelTableNormal@jrTbl
    OR A
    JR Z, +
    LD HL, levelTableHard@jrTbl
+:
    LD (currPlayerInfo.levelTablePtr), HL
@setupP2:
;   COPY INTO PLAYER BUFFER FOR PLAYER 2
    LD HL, currPlayerInfo
    LD DE, altPlayerInfo
    LD BC, _sizeof_playerInfo
    LDIR
    ; DECREMENT LIVES FOR PLAYER 2
    LD HL, altPlayerInfo.lives
    DEC (HL)
;   SETUP PLAYER TILE POINTERS
    CALL setupTilePtrs
;   UPLOAD TILES FOR LIFE HUD (IF GAME ISN'T JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, generalResetFunc
    ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, HUD_LIFE_VRAM | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
    ; GET CORRECT SET OF TILES
    LD HL, hudTileTblList
    LD A, (plusBitFlags)
    AND A, $1F
    ADD A, A
    LD E, A
    LD D, $00
    ADD HL, DE
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; WRITE TILES TO VRAM
    CALL pacTileStreaming@writeToVRAM
/*
----------------------------------------------------------
            RESET FUNCTION FOR GAMEPLAY MODE  
----------------------------------------------------------
*/
generalResetFunc:
;   TURN OFF SCREEN (AND VBLANK INTS)
    CALL turnOffScreen
    DI
;   RESET SOUND VARS
    CALL sndInit
;   LOAD MAZE TEXT SPRITES
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, +
    ; SET VDP ADDRESS
    LD HL, SPRITE_ADDR + MAZETXT_VRAM + ($0B * TILE_SIZE) | VRAMWRITE
    RST setVDPAddress
    ; WRITE TO VRAM
    LD HL, mazeTxtTileREADY ; "READY" & "GAME  OVER"
    LD A, bank(mazeTxtTileREADY)
    LD (MAPPER_SLOT2), A
    LD BC, VDPDATA_PORT ; 8 TILES
    OTIR
    LD B, 3 * TILE_SIZE ; 3 TILES
    OTIR
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    JR @loadSprites
+:
    LD A, bank(jrMazeTxtCommTiles)
    LD (MAPPER_SLOT2), A
    LD HL, jrMazeTxtCommTiles
    LD DE, SPRITE_ADDR + MAZETXT_VRAM + ($0B * TILE_SIZE) | VRAMWRITE
    CALL zx7_decompressVRAM
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
@loadSprites:
;   LOAD SPRITE TILES
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    CALL loadTileAssets
;   LOAD BG PALETTE TO RAM
    CALL cpyMazePalToRam
;   LOAD BACKGROUND (MAZE) PALETTE
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD BC, BG_CRAM_SIZE * $100 + VDPDATA_PORT
    LD HL, mazePalette
    OTIR
;   CLEAR SPRITE TABLE
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
-:
    OUT (C), L  ; L IS 0
    DJNZ -
;   LOAD MAZE DATA
    CALL loadMaze
;   SET POWER PELLET COLOR BUFFER 
    CALL powDotCyclingUpdate@refresh
;   SET SCROLL VARS (ONLY USED FOR JR.PAC)
    XOR A
    LD L, A
    LD H, A
    LD (jrScrollReal), HL
    LD (jrOldScrollReal), HL
    LD (jrColumnToUpdate), A
    LD (updateColFlag), A
    LD (jrCameraPos), A
    OUT (VDPCON_PORT), A
    LD A, $88
    OUT (VDPCON_PORT), A
;   WRITE TILEMAP DATA TO VRAM DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @drawTileMap_NoScroll ; IF GAME ISN'T JR. PAC, SKIP
    ; ENABLE SCROLL
    LD A, $01
    LD (enableScroll), A
    ; SET INITIAL SCROLL
    LD A, $28
    LD (jrCameraPos), A
;   WRITE TILEMAP DATA TO VRAM (JR. PAC)
    LD HL, NAMETABLE | VRAMWRITE
    RST setVDPAddress
    LD B, $20
-:
    XOR A
    OUT (VDPDATA_PORT), A
    INC A
    OUT (VDPDATA_PORT), A
    DJNZ -
    ; POINT TO LEFT MOST TILE OF MAZE
    LD HL, mazeGroup1.tileMap + $08
    ; LOOP SETUP
    LD D, $17
-:
    ; WRITE ROW
    LD BC, $40 * $100 + VDPDATA_PORT
    OTIR
    ; POINT TO NEXT ROW
    LD A, $09 * $02
    RST addToHL
    ; DO FOR WHOLE SCREEN
    DEC D
    JR NZ, -
    JR @prepareMazeText
@drawTileMap_NoScroll:
;   WRITE TILEMAP DATA TO VRAM (PAC-MAN / MS.PAC-MAN)
    LD HL, NAMETABLE | VRAMWRITE
    RST setVDPAddress
    LD HL, mazeGroup1.tileMap
    LD BC, NAMETABLE_SIZE
    CALL copyToVDP
@prepareMazeText:
;   PAC/MS.PAC DRAW MAZE TEXT AS SPRITES, JR DRAWS AS BG
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @saveTileMapJr
    ; SKIP IF GAMEMODE ISN'T 1ST READY STATE
    LD A, (subGameMode)
    CP A, GAMEPLAY_READY00
    JR NZ, @firstTimeChk
    ; WRITE "PLAYER ONE" TILES FOR PAC/MS.PAC
        ; SAVE SOME TILES IN RAM
    LD HL, SPRITE_ADDR + PAC_VRAM + $80
    RST setVDPAddress
    LD HL, playerSprBuffer
    LD BC, $80 * $100 + VDPDATA_PORT
    INIR
        ; SET VDP ADDRESS
    LD HL, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    RST setVDPAddress
        ; WRITE TO VRAM
    LD HL, mazeTxtTilePLAYER
    LD A, bank(mazeTxtTilePLAYER)
    LD (MAPPER_SLOT2), A
    LD BC, VDPDATA_PORT ; 8 TILES
    OTIR
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    JR @firstTimeChk
@saveTileMapJr:
;   SAVE TILEMAP AREA TO RAM FOR "PLAYER ONE/TWO" & "READY"
    LD C, VDPCON_PORT
    ; PLAYER ROW 0
    LD DE, NAMETABLE + ($0C * $02) + ($08 * $40)
    OUT (C), E
    OUT (C), D
    DEC C
    LD HL, mazeTextBuffer
    LD B, $12
    INIR
    ; PLAYER ROW 1
    INC C
    LD DE, NAMETABLE + ($0C * $02) + ($09 * $40)
    OUT (C), E
    OUT (C), D
    DEC C
    LD B, $12
    INIR
    ; READY
    INC C
    LD DE, NAMETABLE + ($0E * $02) + ($0D * $40)
    OUT (C), E
    OUT (C), D
    DEC C
    LD B, $0A
    INIR
@firstTimeChk:
;   RESET SOME VARS ONLY IF ON LEVEL FOR THE FIRST TIME
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JR NZ, firstTimeEnd
;   --- SETTING VARS ON FIRST TIME START ---
    ; RESET GHOSTS' DOT COUNTERS
    XOR A
    LD (blinky.dotCounter), A
    LD (pinky.dotCounter), A
    LD (inky.dotCounter), A
    LD (clyde.dotCounter), A
    ; RESET PLAYER DOT COUNT
    LD (currPlayerInfo.dotCount), A
    LD (currPlayerInfo.jrDotCount), A
    LD (currPlayerInfo.jrDotCount + 1), A
firstTimeEnd:
    XOR A
    LD H, A
    LD L, A
;   RESET GLOBAL GHOST VARS
    LD (scatterChaseIndex), A
    LD (frameCounter), A
    LD (flashCounter), A
    LD (difficultyState), A
    LD (ghostPointSprNum), A
;   INITIALIZE A BUNCH OF STUFF TO 0
    LD (rngIndex), HL       ; RNG INDEX
    LD (mainTimer2), HL     ; SCATTER/CHASE TIMER
    LD (mainTimer3), HL     ; FRUIT TIMER
    LD (powDotFrameCounter), A  ; POWER DOT FRAME COUNTER FOR PALETTE CYCLE
    LD (xUPCounter), A      ; 1UP / 2UP FLASH COUNTER
    LD (sprFlickerControl), A   ; SPRITE FLICKER FLAGS
    LD (eatSubState), A     ; EAT SUBSTATE
    LD (pacPoweredUp), A    ; SUPER FLAG
    LD (dotExpireCounter), A
    LD (globalDotCounter), A
    LD (drawHScoreFlag), A
;   ENABLE SPRITE CYCLING
    INC A
    LD (sprFlickerControl), A
;   SPEED PATTERN FOR GHOSTS IN HOME
    LD A, $55
    LD (inHomeSpdPatt), A
;   RESET GHOST SOUND CONTROL
    LD A, $FF
    LD (ghostSoundControl), A
;   RESET SCORE TILEMAP BUFFER
    CALL scoreTilemapRstBuffer
    CALL scoreTileMapUpdate
;   CALCULATE DIFFICULTY   
    ; CONVERT INDEX INTO OFFSET (MULTIPLY BY 6)
    LD HL, (currPlayerInfo.levelTablePtr)
    LD A, (HL)
    CALL multiplyBy6
    LD D, $00
    LD E, A
    ; ADD OFFSET TO BASE TABLE
    LD HL, plusBitFlags
    LD IX, difficultyTable@plus
    BIT PLUS, (HL)
    JR NZ, +
    LD IX, difficultyTable@jr
    BIT JR_PAC, (HL)
    JR NZ, +
    LD IX, difficultyTable
+:
    ADD IX, DE
    ; GET FIRST BYTE (SPEED PATTERN INDEX)
    LD A, (IX + 0)
    SUB A, $03
    ; CONVERT NUMBER INTO OFFSET (MULTIPLY BY 42)
    ADD A, A
    LD B, A     ; B: A * 2
    ADD A, A
    ADD A, A
    LD C, A     ; C: A * 8
    ADD A, A
    ADD A, A
    ADD A, B    ; A * 32 + A * 2 = A * 34
    ADD A, C    ; A * 34 + A * 8 = A * 42
    ; ADD OFFSET TO BASE TABLE
    LD HL, speedPatternTable
    RST addToHL
    OR A    ; CLEAR CARRY
    ; COPY PAC-MAN'S SPEED PATTERNS
    LD DE, spdPatternNormal
    LD BC, $08
    LDIR
    ; COPY BLINKY'S SPEED UP PATTERNS
    LD DE, spdPatternDiff1
    LD BC, $08
    LDIR
    ; COPY GHOST SPEED PATTERNS FOR BLINKY
    LD DE, blinky.spdPatternNormal
    LD BC, $0C
    LDIR
    ; COPY GHOST SPEED PATTERNS FOR PINKY
    LD DE, pinky.spdPatternNormal
    LD BC, $0C
    SBC HL, BC  ; RESET
    LDIR
    ; COPY GHOST SPEED PATTERNS FOR INKY
    LD DE, inky.spdPatternNormal
    LD BC, $0C
    SBC HL, BC  ; RESET
    LDIR
    ; COPY GHOST SPEED PATTERNS FOR CLYDE
    LD DE, clyde.spdPatternNormal
    LD BC, $0C
    SBC HL, BC  ; RESET
    LDIR
    ; SET SCATTER/CHASE POINTER
    LD (scatterChasePtr), HL
    ; GET SECOND BYTE (FRUIT POWER TIME INDEX) (PLUS ONLY)
    LD A, (IX + 1)
    ; CONVERT NUMBER INTO OFFSET (MULTIPLY BY 2)
    ADD A, A
    ; ADD OFFSET TO BASE TABLE
    LD HL, powDotTimeTable
    RST addToHL
    ; COPY POWER DOT TIME INTO RAM
    LD DE, plusFruitSuperTime
    LDI
    LDI
    ; GET THIRD BYTE (GHOST DOT COUNT INDEX)
    LD A, (IX + 2)
    ; CONVERT NUMBER TO OFFSET (MULTIPLY BY 3)
    LD B, A
    ADD A, A
    ADD A, B
    ; ADD OFFSET TO BASE TABLE
    LD HL, ghostDotCounterTable
    RST addToHL
    ; COPY PERSONAL DOT COUNTERS FOR (PINKY, INKY, CLYDE)
    LD DE, personalDotCounts
    LDI
    LDI
    LDI
    ; GET FORTH BYTE (BLINKY SPEED UP INDEX)
    LD A, (IX + 3)
    ; ADD OFFSET TO BASE TABLE
    LD HL, blinkySpeedUpTable
    RST addToHL
    ; COPY BYTE FOR BLINKY
    LD (speedUpDotCount), A
    ; GET FIFTH BYTE (POWER DOT TIME INDEX)
    LD A, (IX + 4)
    ; CONVERT NUMBER INTO OFFSET (MULTIPLY BY 2)
    ADD A, A
    ; ADD OFFSET TO BASE TABLE
    LD HL, powDotTimeTable
    RST addToHL
    ; COPY POWER DOT TIME INTO RAM
    LD DE, powDotTime
    LDI
    LDI
    ; GET SIXTH BYTE (DOT EXPIRE INDEX)
    LD A, (IX + 5)
    ; ADD OFFSET TO BASE TABLE
    LD HL, dotExpireTable
    RST addToHL
    ; COPY BYTE INTO RAM
    LD (dotExpireTime), A
;   SET DOT EXPIRE DURATION
    LD (mainTimer4), A
;   RESET ACTORS
    CALL pacmanReset
    CALL blinkyReset
    CALL pinkyReset     
    CALL inkyReset
    CALL clydeReset
    CALL fruitReset
;   DRAW STATIC HUD
    CALL drawScoresText ; HIGH SCORE AND SCORE TEXT
    CALL drawLives      ; LIVES
    CALL drawFruitHUD   ; FRUIT
;   TURN ON DISPLAY
    CALL waitForVblank
    EI
    JP turnOnScreen