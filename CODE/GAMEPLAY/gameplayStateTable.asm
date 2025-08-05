
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
;   CLEAR TILE BUFFER FLAG
    XOR A
    LD (tileBufferFlag), A  ; WHY IS THIS CLEARED HERE?
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
    LD HL, levelTableNormal
    LD A, (normalFlag)
    OR A
    JR Z, +
    LD HL, levelTableHard
+:
    LD (currPlayerInfo.levelTablePtr), HL
;   COPY INTO PLAYER BUFFER FOR PLAYER 2
    LD HL, currPlayerInfo
    LD DE, altPlayerInfo
    LD BC, _sizeof_playerInfo
    LDIR
    ; DECREMENT LIVES FOR PLAYER 2
    LD HL, altPlayerInfo.lives
    DEC (HL)
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, +    ; IF SO, SKIP
    LD HL, hudTileMaps@lives
    LD (lifeHudPtr), HL
;   LOAD MAZE COLLISION DATA FOR PLAYER 2 (PAC-MAN)
    LD HL, mazeCollsionData
    LD DE, collisionBuffer
    CALL zx7_decompress
;   LOAD MAZE TILEMAP DATA FOR PLAYER 2 (PAC-MAN)
    LD HL, mazeTileMap
    LD DE, tileMapBuffer
    CALL zx7_decompress
    JR generalResetFunc
+:
    LD HL, hudTileMaps@msLives
    LD (lifeHudPtr), HL
;   LOAD MAZE COLLISION DATA FOR PLAYER 2 (MAZE 1)
    LD HL, maze1ColData
    LD DE, collisionBuffer
    CALL zx7_decompress
;   LOAD MAZE TILEMAP DATA FOR PLAYER 2 (MAZE 1)
    LD HL, maze1TileMap
    LD DE, tileMapBuffer
    CALL zx7_decompress
/*
----------------------------------------------------------
            RESET FUNCTION FOR GAMEPLAY MODE  
----------------------------------------------------------
*/
generalResetFunc:
;   TURN OFF SCREEN (AND VBLANK INTS)
    CALL turnOffScreen
;   RESET SOUND VARS
    CALL sndInit
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
;   LOAD MAZE TEXT SPRITES
    LD HL, mazeTextTiles
    LD DE, MAZETXT_INDEX * TILE_SIZE | VRAMWRITE
    CALL zx7_decompressVRAM
;   SET POWER PELLET COLOR BUFFER 
    CALL powDotCyclingUpdate@refresh
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
    LD (fruitPos), HL       ; FRUIT POSITION
    LD (powDotFrameCounter), A  ; POWER DOT FRAME COUNTER FOR PALETTE CYCLE
    LD (xUPCounter), A      ; 1UP / 2UP FLASH COUNTER
    LD (sprFlickerControl), A   ; SPRITE FLICKER FLAGS
    LD (eatSubState), A     ; EAT SUBSTATE
    LD (pacPoweredUp), A    ; SUPER FLAG
;   SPEED PATTERN FOR GHOSTS IN HOME
    LD A, $55
    LD (inHomeSpdPatt), A
;   RESET GHOST SOUND CONTROL
    LD A, $FF
    LD (ghostSoundControl), A
;   CALCULATE DIFFICULTY   
    ; CONVERT INDEX INTO OFFSET (MULTIPLY BY 6)
    LD HL, (currPlayerInfo.levelTablePtr)
    LD E, (HL)
    LD H, $06
    CALL multiply8Bit
    EX DE, HL
    ; ADD OFFSET TO BASE TABLE
    LD IX, difficultyTable
    LD HL, plusBitFlags
    BIT PLUS, (HL)
    JR Z, +
    LD IX, difficultyTable@plus
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
;   DRAW STATIC HUD
    ; HIGH SCORE AND SCORE TEXT
    CALL drawScoresText
    ; LIVES
    CALL drawLives
    ; FRUIT
    CALL drawFruitHUD
;   TURN ON DISPLAY
    CALL waitForVblank
    JP turnOnScreen