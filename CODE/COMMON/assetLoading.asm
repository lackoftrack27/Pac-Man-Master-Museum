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
;   ------------------------------------
;           SMOOTH STYLE ASSETS
;   ------------------------------------
@smooth:
;   LOAD SPRITE PALETTE FOR SMOOTH
    LD HL, sprPalData
    LD BC, SPR_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   COMMON ASSETS AMONG GAMES
    ; GHOST && GHOST POINTS
    LD HL, ghostTiles
    LD DE, ghostPointTiles
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, ghostTiles@plus
    LD DE, ghostPointTiles@plus
+:
    PUSH DE
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    POP HL
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
;   GAME DETERMINATION
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS_PAC
    JR C, @@msLoadAssets
    RRCA    ; JR_PAC
    JR C, @@jrLoadAssets
;   ------------
;   PAC-MAN SPECIFIC ASSETS
;   ------------
    ; FRUIT POINTS
    LD HL, fruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; FRUIT
    LD HL, fruitTiles
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, fruitTiles@plus
+:
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
;   ------------
;   MS.PAC-MAN SPECIFIC ASSETS
;   ------------
@@msLoadAssets:
    ; FRUIT POINTS
    LD HL, msFruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; FRUIT
    LD HL, msFruitTiles
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, fruitTiles@plus
+:
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; OTTO GHOSTS (CRAZY OTTO)
    LD A, (plusBitFlags)
    BIT OTTO, A
    RET Z
    LD HL, ottoGhostTiles
    RRCA
    JR NC, +
    LD HL, ottoGhostTiles@plus
+:
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
;   ------------
;   JR.PAC-MAN SPECIFIC ASSETS
;   ------------
@@jrLoadAssets:
    ; FRUIT POINTS
    LD HL, msFruitPointTiles
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; EXPLOSION
    LD HL, jrExplosionTiles
    LD DE, JR_EXPLODE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; HUD ICONS
    LD A, bank(jrHudIconTilesSmo)
    LD (MAPPER_SLOT2), A
    LD HL, jrHudIconTilesSmo
    LD DE, JR_HUD_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
        ; PLUS
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, jrHudIconFruitPlus
    LD DE, JR_HUD_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
+:
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    ; FRUIT
    LD HL, jrFruitTiles
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, jrFruitTiles
+:
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    LD A, bank(jrFruitTiles)
    LD (MAPPER_SLOT2), A
    CALL zx7_decompressVRAM
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    RET
;   ------------------------------------
;           ARCADE STYLE ASSETS
;   ------------------------------------
@arcade:
;   LOAD SPRITE PALETTE FOR ARCADE
    LD HL, sprPalData@arcade
    LD BC, SPR_CRAM_SIZE * $100 + VDPDATA_PORT
    OTIR
;   COMMON ASSETS AMONG GAMES
    ; GHOST && GHOST POINTS
    LD HL, arcadeGFXData@ghosts
    LD DE, arcadeGFXData@ghostPoints
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, arcadeGFXData@ghostsPlus
    LD DE, arcadeGFXData@ghostPointsPlus
+:
    PUSH DE
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    POP HL
    LD DE, SPRITE_ADDR + GSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
;   GAME DETERMINATION
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS_PAC
    JR C, @@msLoadAssets
    RRCA    ; JR_PAC
    JR C, @@jrLoadAssets
;   ------------
;   PAC-MAN SPECIFIC ASSETS
;   ------------
    ; FRUIT POINTS
    LD HL, arcadeGFXData@fruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; FRUIT
    LD HL, arcadeGFXData@fruit
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, arcadeGFXData@fruitPlus
+:
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
;   ------------
;   MS.PAC-MAN SPECIFIC ASSETS
;   ------------
@@msLoadAssets:
    ; FRUIT POINTS
    LD HL, arcadeGFXData@msFruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; FRUIT
    LD HL, arcadeGFXData@msFruit
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, arcadeGFXData@fruitPlus
+:
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; OTTO GHOSTS (CRAZY OTTO)
    LD A, (plusBitFlags)
    BIT OTTO, A
    RET Z
    LD HL, arcadeGFXData@ottoGhosts
    RRCA
    JR NC, +
    LD HL, arcadeGFXData@ottoGhostsPlus
+:
    LD DE, SPRITE_ADDR + GHOST_VRAM | VRAMWRITE
    JP zx7_decompressVRAM
;   ------------
;   JR.PAC-MAN SPECIFIC ASSETS
;   ------------
@@jrLoadAssets:
    ; FRUIT POINTS
    LD HL, arcadeGFXData@msFruitPoints
    LD DE, SPRITE_ADDR + FSCORE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; EXPLOSION
    LD HL, arcadeGFXData@explosion
    LD DE, JR_EXPLODE_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    ; HUD ICONS
    LD A, bank(jrHudIconTilesArc)
    LD (MAPPER_SLOT2), A
    LD HL, jrHudIconTilesArc
    LD DE, JR_HUD_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
        ; PLUS
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, jrHudIconFruitPlus
    LD DE, JR_HUD_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
+:
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    ; FRUIT
    LD HL, arcadeGFXData@jrFruit
    LD A, (plusBitFlags)
    RRCA
    JR NC, +
    LD HL, arcadeGFXData@jrFruitPlus
+:
    LD DE, SPRITE_ADDR + FRUIT_VRAM | VRAMWRITE
    LD A, bank(arcadeGFXData@jrFruit)
    LD (MAPPER_SLOT2), A
    CALL zx7_decompressVRAM
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
;   LOAD THE CORRECT MAZE DATA FOR THE CURRENT GAME
    LD A, (plusBitFlags)
    RRCA    ; PLUS
    RRCA    ; MS_PAC
    JP C, @msMazes
    RRCA    ; JR_PAC
    JP C, @jrMazes
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
    JR @revertBank
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
    JR NZ, @revertBank    ; IF SO, END
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


/*
    INFO: LOAD HUD TILES
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL
*/
loadHudTiles:
;   LOAD HUD TEXT TILES
    LD DE, (BACKGROUND_ADDR + HUDTEXT_VRAM) | VRAMWRITE
    LD HL, hudTextTiles     ; ASSUME PAC-MAN / MS.PAC-MAN HUD
    ; SKIP IF GAME ISN'T JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, zx7_decompressVRAM
    ; USE JR'S HUD TILES INSTEAD
    LD HL, jrHudTextTiles
    JP zx7_decompressVRAM

