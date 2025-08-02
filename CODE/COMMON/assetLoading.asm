/*
------------------------------------------------
                ASSET FUNCTIONS
------------------------------------------------
*/


/*
    INFO: LOAD SPRITE TILES AND PALETTE DEPENDING ON PLUS AND STYLE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
loadTileAssets:
;   SET VDP ADDRESS FOR PALETTE WRITE
    LD HL, SPR_CRAM_SIZE | CRAMWRITE
    RST setVDPAddress
;   SMOOTH / ARCADE CONTROL PATH
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    JP NZ, @arcade
@smooth:
;   LOAD SPRITE PALETTE FOR SMOOTH
    LD HL, sprPalData
    LD BC, SPR_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @@msLoadAssets    ; IF SO, SKIP
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; FRUIT POINTS
    LD HL, fruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; PAC DEATH
    LD HL, pacDeathTiles
    LD DE, SPRITE_ADDR + DEATH_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    
;   UNIQUE PAC-MAN TILE ASSETS
    ; PAC-MAN
    LD HL, pacmanTiles
    LD DE, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS
    LD HL, ghostTiles
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS
    LD HL, ghostPointTiles
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; FRUIT
    LD HL, fruitTiles
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
+:
;   UNIQUE PLUS TILE ASSETS
    ; PAC-MAN PLUS
    LD HL, pacmanTiles@plus
    LD DE, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS PLUS
    LD HL, ghostTiles@plus
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS PLUS
    LD HL, ghostPointTiles@plus
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; FRUIT PLUS
    LD HL, fruitTiles@plus
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
@@msLoadAssets:
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; FRUIT POINTS
    LD HL, msFruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; MS. PAC-MAN
    LD HL, msPacTiles
    LD DE, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; CUTSCENE DATA
    LD HL, msCutsceneTiles
    LD DE, SPRITE_ADDR + GHOST_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    ; IF PLUS, SKIP
    ; FRUIT
    LD HL, msFruitTiles
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS
    LD HL, ghostTiles
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS
    LD HL, ghostPointTiles
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; PAC-MAN (FOR CUTSCENES)
    LD HL, pacmanTiles
    LD DE, SPRITE_ADDR + MS_CUT_PAC_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
    ; -----------------------------
+:
    ; FRUIT PLUS
    LD HL, fruitTiles@plus
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM 
    ; GHOSTS PLUS
    LD HL, ghostTiles@plus
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS PLUS
    LD HL, ghostPointTiles@plus
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; PAC-MAN PLUS (FOR CUTSCENES)
    LD HL, pacmanTiles@plus
    LD DE, SPRITE_ADDR + MS_CUT_PAC_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
    ; -----------------------------
@arcade:
;   LOAD SPRITE PALETTE FOR ARCADE
    LD HL, sprPalData@arcade
    LD BC, SPR_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @@msLoadAssets    ; IF SO, SKIP
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    LD A, ARCADE_BANK
    LD (MAPPER_SLOT2), A
    ; -----------------------------
    ; FRUIT POINTS
    LD HL, arcadeGFXData@fruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; PAC DEATH
    LD HL, arcadeGFXData@pacDeath
    LD DE, SPRITE_ADDR + DEATH_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    
;   UNIQUE PAC-MAN TILE ASSETS
    ; PAC-MAN
    LD HL, arcadeGFXData@pacman
    LD DE, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS
    LD HL, arcadeGFXData@ghosts
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; FRUIT
    LD HL, arcadeGFXData@fruit
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS
    LD HL, arcadeGFXData@ghostPoints
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    JP @end
    ; -----------------------------
+:
;   UNIQUE PLUS TILE ASSETS
    ; PAC-MAN PLUS
    LD HL, arcadeGFXData@pacmanPlus
    LD DE, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS PLUS
    LD HL, arcadeGFXData@ghostsPlus
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; FRUIT PLUS
    LD HL, arcadeGFXData@fruitPlus
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS PLUS
    LD HL, arcadeGFXData@ghostPointsPlus
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    JR @end
    ; -----------------------------
@@msLoadAssets:
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    LD A, ARCADE_BANK
    LD (MAPPER_SLOT2), A
    ; -----------------------------
    ; FRUIT POINTS
    LD HL, arcadeGFXData@msFruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; MS. PAC-MAN
    LD HL, arcadeGFXData@msPacman
    LD DE, SPRITE_ADDR + PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; CUTSCENE DATA
    LD HL, arcadeGFXData@cutsceneMs
    LD DE, SPRITE_ADDR + GHOST_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    ; IF PLUS, SKIP
    ; FRUIT
    LD HL, arcadeGFXData@msFruit
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS
    LD HL, arcadeGFXData@ghosts
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; PAC-MAN (FOR CUTSCENES)
    LD HL, arcadeGFXData@pacman
    LD DE, SPRITE_ADDR + MS_CUT_PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS
    LD HL, arcadeGFXData@ghostPoints
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    JR @end
    ; -----------------------------
+:
    ; FRUIT PLUS
    LD HL, arcadeGFXData@fruitPlus
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS PLUS
    LD HL, arcadeGFXData@ghostsPlus
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; PAC-MAN PLUS (FOR CUTSCENES)
    LD HL, arcadeGFXData@pacmanPlus
    LD DE, SPRITE_ADDR + MS_CUT_PAC_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOST POINTS PLUS
    LD HL, arcadeGFXData@ghostPointsPlus
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
@end:
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
    RET
    ; -----------------------------






/*
    INFO: LOAD MAZE DATA
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL
*/
loadMaze:
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, +    ; IF SO, SKIP
;   LOAD PAC-MAN MAZE DATA
    ; LOAD MAZE TILES (LOAD EVERY TIME!)
    LD HL, maze0Tiles
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; LOAD MAZE TEXT TILES (LOAD EVERY TIME!)
    LD HL, maze0TextTiles
    LD DE, MAZETEXT_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; LOAD MAZE DOT TABLE (LOAD EVERY TIME!)
    LD HL, maze0EatenTable
    LD DE, mazeEatenDotTable
    CALL zx7_decompress
    ; LOAD POWER DOT TABLE (LOAD EVERY TIME!)
    LD HL, maze0EatenTable@powDots
    LD DE, mazePowDotTable
    CALL zx7_decompress
    ; CHECK IF PLAYER HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    RET NZ  ; IF SO, END
    ; LOAD MAZE TILEMAP DATA
    LD HL, mazeTileMap
    LD DE, NAMETABLE | VRAMWRITE
    CALL zx7_decompressVRAM
    ; LOAD MAZE COLLISION DATA
    LD HL, mazeCollsionData
    LD DE, mazeCollisionPtr
    JP zx7_decompress
+:
;   LOAD MS. PAC-MAN MAZE DATA
    ; LOAD MAZE TILES (LOAD EVERY TIME!)
    LD HL, msMazeTilesTable
    CALL getMazeIndex
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; LOAD MAZE TEXT TILES (LOAD EVERY TIME!)
    LD HL, msMazeTextTable
    CALL getMazeIndex
    LD DE, MAZETEXT_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; LOAD MAZE DOT TABLE (LOAD EVERY TIME!)
    LD HL, msMazeDotTable
    CALL getMazeIndex
    LD DE, mazeEatenDotTable
    CALL zx7_decompress
    ; LOAD POWER DOT TABLE (LOAD EVERY TIME!)
    LD HL, msMazePowTable
    CALL getMazeIndex
    LD DE, mazePowDotTable
    CALL zx7_decompress
    ; CHECK IF PLAYER HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    RET NZ  ; IF SO, END
    ; LOAD MAZE TILEMAP DATA
    LD HL, msMazeTilemapTable
    CALL getMazeIndex
    LD DE, NAMETABLE | VRAMWRITE
    CALL zx7_decompressVRAM
    ; LOAD MAZE COLLISION DATA
    LD HL, msMazeColTable
    CALL getMazeIndex
    LD DE, mazeCollisionPtr
    JP zx7_decompress