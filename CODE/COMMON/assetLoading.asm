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
    BIT JR_PAC, A
    JP NZ, @@jrLoadAssets
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; FRUIT POINTS
    LD HL, fruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    
;   UNIQUE PAC-MAN TILE ASSETS
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
    LD A, (plusBitFlags)
    BIT OTTO, A
    RET Z
    ; OTTO GHOSTS
    LD HL, ottoGhostTiles
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
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
    LD A, (plusBitFlags)
    BIT OTTO, A
    RET Z
    ; OTTO GHOSTS PLUS
    LD HL, ottoGhostTiles@plus
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
    ; -----------------------------
@@jrLoadAssets:
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; -----------------------------
    ;LD A, ARCADE_BANK
    ;LD (MAPPER_SLOT2), A
    ; -----------------------------
    ; EXPLOSION TILES
    LD HL, jrExplosionTiles
    LD DE, (192 * 32) | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; HUD ICONS
    LD HL, jrHudIconTiles
    LD DE, $3AA0 | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    ; -----------------------------
    ; FRUIT POINTS
    LD HL, msFruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    ; IF PLUS, SKIP
    ; -----------------------------
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
    JP zx7_decompressVRAM
    ; -----------------------------
@arcade:
;   SET SLOT 2 BANK
    ;LD A, ARCADE_BANK
    ;LD (MAPPER_SLOT2), A
;   LOAD SPRITE PALETTE FOR ARCADE
    LD HL, sprPalData@arcade
    LD BC, SPR_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JP NZ, @@msLoadAssets    ; IF SO, SKIP
;   CHECK IF GAME IS JR.PAC
    BIT JR_PAC, A
    JP NZ, @@jrLoadAssets
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; -----------------------------
    ; FRUIT POINTS
    LD HL, arcadeGFXData@fruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    
;   UNIQUE PAC-MAN TILE ASSETS
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
    JP @end
    ; -----------------------------
@@msLoadAssets:
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; FRUIT POINTS
    LD HL, arcadeGFXData@msFruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
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
    ; GHOST POINTS
    LD HL, arcadeGFXData@ghostPoints
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    LD A, (plusBitFlags)
    BIT OTTO, A
    JP Z, @end
    ; OTTO GHOSTS
    LD HL, arcadeGFXData@ottoGhosts
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    JP @end
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
    ; GHOST POINTS PLUS
    LD HL, arcadeGFXData@ghostPointsPlus
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    LD A, (plusBitFlags)
    BIT OTTO, A
    JP Z, @end
    ; OTTO GHOSTS PLUS
    LD HL, arcadeGFXData@ottoGhostsPlus
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    JP @end
    ; -----------------------------
@@jrLoadAssets:
;   COMMON ASSETS (IN REGARDS TO NON PLUS / PLUS)
    ; EXPLOSION
    LD HL, jrExplosionTiles
    LD DE, (192 * 32) | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; HUD ICONS
    LD HL, jrHudIconTiles
    LD DE, $3AA0 | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; FRUIT POINTS
    LD HL, arcadeGFXData@msFruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
;   LOAD ASSETS DEPENDING ON GAME TYPE
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR NZ, +    ; IF PLUS, SKIP
    ; FRUIT
    LD HL, arcadeGFXData@jrFruit
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
    ; GHOSTS
    LD HL, arcadeGFXData@ghosts
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
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
    ; GHOST POINTS PLUS
    LD HL, arcadeGFXData@ghostPointsPlus
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; -----------------------------
@end:
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    RET






/*
    INFO: LOAD MAZE DATA
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL
*/
loadMaze:
;   SET BANK FOR MAZE OTHER DATA
    LD A, MAZE_OTHER_BANK
    LD (MAPPER_SLOT2), A
;   MAKE MUTATED DOT TILE OFFSET IMPOSSIBLE (FOR PAC & MS.PAC)
    LD A, $FF
    LD (mazeMutatedTbl), A
;   CHECK IF GAME IS MS.PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JP NZ, @msMazes     ; IF SO, SKIP
;   CHECK IF GAME IS JR.PAC
    BIT JR_PAC, A
    JP NZ, @jrMazes     ; IF SO, SKIP
;   LOAD PAC-MAN MAZE DATA
    ; LOAD MAZE DOT TABLE (LOAD EVERY TIME!)
    LD HL, maze0EatenTable
    LD DE, mazeEatenTbl
    CALL zx7_decompress
    ; LOAD POWER DOT TABLE (LOAD EVERY TIME!)
    LD HL, maze0EatenTable@powDots
    LD DE, mazePowTbl
    CALL zx7_decompress
    ; SET BANK FOR MAZE TILE DATA
    LD A, MAZE_GFX_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE TILES (LOAD EVERY TIME!)
    LD HL, maze0Tiles
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; CHECK IF PLAYER HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JP NZ, @revertBank  ; IF SO, END
    ; SET BANK FOR MAZE TILEMAP DATA
    LD A, MAZE_TILEMAP_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE TILEMAP DATA
    LD HL, maze0TileMap
    LD DE, mazeGroup1.tileMap
    CALL zx7_decompress
    ; SET BANK FOR MAZE OTHER DATA
    LD A, MAZE_OTHER_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE COLLISION DATA
    LD HL, mazeCollsionData
    LD DE, mazeGroup1.collMap
    CALL zx7_decompress
    JP @revertBank
@msMazes:
;   LOAD MS. PAC-MAN MAZE DATA
    ; LOAD MAZE DOT TABLE (LOAD EVERY TIME!)
    LD HL, msMazeDotTable
    CALL getMazeIndex
    LD DE, mazeEatenTbl
    CALL zx7_decompress
    ; LOAD POWER DOT TABLE (LOAD EVERY TIME!)
    LD HL, msMazePowTable
    CALL getMazeIndex
    LD DE, mazePowTbl
    CALL zx7_decompress
    ; SET BANK FOR MAZE TILE DATA
    LD A, MAZE_GFX_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE TILES (LOAD EVERY TIME!)
    LD HL, msMazeTilesTable
    CALL getMazeIndex
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; CHECK IF PLAYER HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JP NZ, @revertBank  ; IF SO, END
    ; SET BANK FOR MAZE TILEMAP DATA
    LD A, MAZE_TILEMAP_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE TILEMAP DATA
    LD HL, msMazeTilemapTable
    CALL getMazeIndex
    LD DE, mazeGroup1.tileMap
    CALL zx7_decompress
    ; SET BANK FOR MAZE OTHER DATA
    LD A, MAZE_OTHER_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE COLLISION DATA
    LD HL, msMazeColTable
    CALL getMazeIndex
    LD DE, mazeGroup1.collMap
    CALL zx7_decompress
    JP @revertBank
@jrMazes:
    ; LOAD MAZE DOT TABLE (LOAD EVERY TIME!)
    LD HL, jrMazeDotTable
    CALL jrGetMazeIndex
    LD DE, mazeEatenTbl
    CALL zx7_decompress
    ; LOAD POWER DOT TABLE (LOAD EVERY TIME!)
    LD HL, jrMazePowTable
    CALL jrGetMazeIndex
    LD DE, mazePowTbl
    CALL zx7_decompress
    ; LOAD FIRST MUTATED DOT TABLE (LOAD EVERY TIME!)
    LD HL, jrMazeMDotTable
    CALL jrGetMazeIndex
    LD DE, mazeMutatedTbl
    CALL zx7_decompress
    ; LOAD SECOND MUTATED DOT TABLE (LOAD EVERY TIME!)
    LD HL, jrMazeMEatTable
    CALL jrGetMazeIndex
    LD DE, mazeEatenMutatedTbl
    CALL zx7_decompress
    ; LOAD MUTATED DOT RESET TABLE (LOAD EVERY TIME!)
    LD HL, jrMazeMRstTable
    CALL jrGetMazeIndex
    LD DE, mazeRstMutatedTbl
    CALL zx7_decompress
    ; SET BANK FOR MAZE TILE DATA
    LD A, MAZE_GFX_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE TILES (LOAD EVERY TIME!)
    LD HL, jrMazeTilesTable
    CALL jrGetMazeIndex
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
    ; CHECK IF PLAYER HAS DIED
    LD A, (currPlayerInfo.diedFlag)
    OR A
    JP NZ, @revertBank    ; IF SO, END
    ; SET BANK FOR MAZE TILEMAP DATA
    LD A, MAZE_TILEMAP_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE TILEMAP DATA
    LD HL, jrMazeTilemapTable
    CALL jrGetMazeIndex
    LD DE, mazeGroup1.tileMap
    CALL zx7_decompress
    ; SET BANK FOR MAZE OTHER DATA
    LD A, MAZE_OTHER_BANK
    LD (MAPPER_SLOT2), A
    ; LOAD MAZE COLLISION DATA
    LD HL, jrMazeColTable
    CALL jrGetMazeIndex
    LD DE, mazeGroup1.collMap
    CALL zx7_decompress
@revertBank:
    ; REVERT BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    RET


loadHudTiles:
;   LOAD HUD TEXT TILES
    LD HL, hudTextTiles     ; ASSUME PAC-MAN / MS.PAC-MAN HUD
    ; SKIP IF GAME ISN'T JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, +
    LD HL, jrHudTextTiles   ; JR.PAC'S HUD TILES
+:
    LD DE, (BACKGROUND_ADDR + HUDTEXT_VRAM) | VRAMWRITE
    JP zx7_decompressVRAM

