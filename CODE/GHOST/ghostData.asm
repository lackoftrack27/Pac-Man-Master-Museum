/*
------------------------------------------------
                GHOST DATA
------------------------------------------------
*/


/*
    TILE DEFS FOR NORMAL GHOST SPRITES
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
ghostNormalTileDefs:
@blinky:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE          ; BLINKY
@pinky:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $0C    ; PINKY
@inky:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $18    ; INKY
@clyde:
    ghostSprDefNormal (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $24    ; CLYDE



/*
    TILE DEFS FOR SCARED GHOST SPRITES
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
ghostScaredTileDefs:
    ghostSprDefScared (SPRITE_ADDR + SCARED_VRAM) / TILE_SIZE



/*
    TILE DEFS FOR GHOST EYES SPRITES
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
ghostEyesTileDefs:
    ghostSprDefEyes (SPRITE_ADDR + EYES_VRAM) / TILE_SIZE