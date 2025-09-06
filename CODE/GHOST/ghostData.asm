/*
------------------------------------------------
                GHOST DATA
------------------------------------------------
*/


/*
    MACRO FOR NORMAL GHOST SPRITES
*/
.MACRO ghostSprDefNormal ARGS, VAL
;   UP 0
    .DB VAL+$06, VAL+$08, VAL+$07, VAL+$09
;   UP 1
    .DB VAL+$06, VAL+$0A, VAL+$07, VAL+$0B
;   LEFT 0
    .DB VAL+$04, VAL+$08, VAL+$05, VAL+$09
;   LEFT 1
    .DB VAL+$04, VAL+$0A, VAL+$05, VAL+$0B
;   DOWN 0
    .DB VAL+$02, VAL+$08, VAL+$03, VAL+$09
;   DOWN 1
    .DB VAL+$02, VAL+$0A, VAL+$03, VAL+$0B
;   RIGHT 0
    .DB VAL, VAL+$08, VAL+$01, VAL+$09
;   RIGHT 1
    .DB VAL, VAL+$0A, VAL+$01, VAL+$0B
.ENDM
/*
    MACRO FOR SCARED GHOST SPRITES
*/
.MACRO ghostSprDefScared    ARGS, VAL
;   BLUE 0
    .DB VAL, VAL+$08, VAL+$01, VAL+$09
;   BLUE 1
    .DB VAL+$02, VAL+$0A, VAL+$03, VAL+$0B
;   WHITE 0
    .DB VAL+$04, VAL+$0C, VAL+$05, VAL+$0D
;   WHITE 1
    .DB VAL+$06, VAL+$0E, VAL+$07, VAL+$0F
.ENDM
/*
    MACRO FOR GHOST EYES SPRITES
*/
.MACRO ghostSprDefEyes ARGS, VAL
;   UP
    .DB VAL+$06, VAL+$07
;   LEFT
    .DB VAL+$04, VAL+$05
;   DOWN
    .DB VAL+$02, VAL+$03
;   RIGHT
    .DB VAL, VAL+$01
.ENDM

/*
    MACRO FOR NORMAL OTTO GHOST SPRITES
*/
.MACRO ottoGhostSNSprDef ARGS, VAL
;   UP 0
    .DB VAL+$0B, VAL+$1A, VAL+$0C, VAL+$1B
;   UP 1
    .DB VAL+$0D, VAL+$1C, VAL+$0E, VAL+$1D
;   LEFT 0
    .DB VAL+$08, VAL+$17, VAL+$09, VAL+$18
;   LEFT 1
    .DB VAL+$0A, VAL+$19, VAL+$09, VAL+$16
;   DOWN 0
    .DB VAL+$04, VAL+$13, VAL+$05, VAL+$14
;   DOWN 1
    .DB VAL+$06, VAL+$15, VAL+$07, VAL+$16
;   RIGHT 0
    .DB VAL, VAL+$0F, VAL+$01, VAL+$10
;   RIGHT 1
    .DB VAL+$02, VAL+$11, VAL+$03, VAL+$12
.ENDM
/*
    MACRO FOR SCARED OTTO GHOST SPRITES
*/
.MACRO ottoGhostScaredSNSprDef    ARGS, VAL
;   BLUE 0
    .DB VAL+$78, VAL+$80, VAL+$79, VAL+$81
;   BLUE 1
    .DB VAL+$7A, VAL+$80, VAL+$7B, VAL+$81
;   WHITE 0
    .DB VAL+$7C, VAL+$82, VAL+$7D, VAL+$83
;   WHITE 1
    .DB VAL+$7E, VAL+$82, VAL+$7F, VAL+$83
.ENDM


/*
    GHOST TILE DEFINITIONS
*/
ghostNormalTileDefs:
@blinky:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE          ; BLINKY
@pinky:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $0C    ; PINKY
@inky:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $18    ; INKY
@clyde:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $24    ; CLYDE
ghostScaredTileDefs:
    ghostSprDefScared (SPRITE_ADDR + SCARED_VRAM) / TILE_SIZE
ghostEyesTileDefs:
    ghostSprDefEyes (SPRITE_ADDR + EYES_VRAM) / TILE_SIZE


/*
    OTTO GHOST TILE DEFINITIONS
*/
ottoGhostSNTileDefs:
@blinky:
    ottoGhostSNSprDef (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE
@pinky:
    ottoGhostSNSprDef (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $1E
@inky:
    ottoGhostSNSprDef (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $3C
@clyde:
    ottoGhostSNSprDef (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $5A
ottoGhostScaredSNTileDefs:
    ottoGhostScaredSNSprDef (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE







