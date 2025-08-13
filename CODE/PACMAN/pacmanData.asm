/*
------------------------------------------------
                ACTOR DATA
------------------------------------------------
*/
        ;XXYY
dirVectors:
    .DW $00FF   ; UP
    .DW $0100   ; LEFT
    .DW $0001   ; DOWN
    .DW $FF00   ; RIGHT


/*
------------------------------------------------
                PAC-MAN DATA
------------------------------------------------
*/

/*
    MACRO AND LIST FOR PAC-MAN TILES [NORMAL / SUPER]
*/
.MACRO pacSprDefs   ARGS, VAL
;   UP
    .db VAL+$0C, VAL+$14, VAL+$0D, VAL+$15 ; HALF
    .db VAL+$05, VAL+$14, VAL+$06, VAL+$15 ; OPEN
    .db VAL+$0C, VAL+$14, VAL+$0D, VAL+$15 ; HALF
    .db VAL+$10, VAL+$14, VAL+$0D, VAL+$15 ; CLOSED
;   LEFT
    .db VAL+$0F, VAL+$19, VAL+$04, VAL+$13 ; CLOSED
    .db VAL+$0B, VAL+$19, VAL+$04, VAL+$13 ; HALF
    .db VAL+$03, VAL+$12, VAL+$04, VAL+$13 ; OPEN
    .db VAL+$0B, VAL+$19, VAL+$04, VAL+$13 ; HALF
;   DOWN
    .db VAL+$0E, VAL+$16, VAL+$0A, VAL+$17 ; CLOSED
    .db VAL+$09, VAL+$18, VAL+$0A, VAL+$17 ; HALF
    .db VAL+$01, BLANK_TILE, VAL+$02, BLANK_TILE         ; OPEN
    .db VAL+$09, VAL+$18, VAL+$0A, VAL+$17 ; HALF
;   RIGHT
    .db VAL+$07, VAL+$16, VAL+$08, VAL+$17 ; HALF
    .db VAL, VAL+$11, BLANK_TILE, BLANK_TILE             ; OPEN
    .db VAL+$07, VAL+$16, VAL+$08, VAL+$17 ; HALF
    .db VAL+$0E, VAL+$16, VAL+$0A, VAL+$17 ; CLOSED
.ENDM

pacSpriteTable:
    pacSprDefs  (SPRITE_ADDR + PAC_VRAM) / TILE_SIZE


/*
    MACRO AND LIST FOR PAC-MAN TILES [DEATH]
*/
.MACRO pacDeathSprDefs   ARGS, VAL
    .DB VAL, VAL+$15, VAL+$01, VAL+$16      ; FRAME 00
    .DB VAL+$02, VAL+$17, VAL+$03, VAL+$18  ; FRAME 01
    .DB VAL+$04, VAL+$19, VAL+$05, VAL+$1A  ; FRAME 02 
    .DB VAL+$06, VAL+$1B, VAL+$07, VAL+$1C  ; FRAME 03 
    .DB VAL+$08, VAL+$1D, VAL+$09, VAL+$1E  ; FRAME 04 
    .DB VAL+$0A, VAL+$1F, VAL+$0B, VAL+$20  ; FRAME 05 
    .DB VAL+$0C, VAL+$21, VAL+$0D, VAL+$22  ; FRAME 06 
    .DB VAL+$0E, VAL+$23, VAL+$0F, VAL+$24  ; FRAME 07
    .DB VAL+$10, VAL+$25, VAL+$11, VAL+$26  ; FRAME 08
    .DB VAL+$12, VAL+$27, BLANK_TILE, BLANK_TILE          ; FRAME 09
    .DB VAL+$13, VAL+$28, VAL+$14, VAL+$29  ; FRAME 0A 
    .DB BLANK_TILE, BLANK_TILE, BLANK_TILE, BLANK_TILE                  ; FRAME 0B
.ENDM

pacDeathTileDefs:
    pacDeathSprDefs (SPRITE_ADDR + DEATH_VRAM) / TILE_SIZE

;   FRAMES TIMES
pacmanDeathTimes:
    .DB $1E $08 $07 $08 $07 $08 $07 $08 $07 $08 $0F $55


/*
    MACRO AND LIST FOR PAC-MAN TILES [BIG - CUTSCENE 1]
*/
.MACRO pacBigSprDefs ARGS, VAL
@open:
    .DB VAL, VAL+$06, VAL+$0C, VAL+$01, VAL+$07, VAL+$0D, VAL+$02, BLANK_TILE, VAL+$0E
@half:
    .DB VAL, VAL+$06, VAL+$0C, VAL+$03, VAL+$08, VAL+$0F, VAL+$04, VAL+$09, VAL+$10
@closed:
    .DB VAL, VAL+$06, VAL+$0C, VAL+$03, VAL+$0A, VAL+$0F, VAL+$05, VAL+$0B, VAL+$11
.ENDM

pacBigTileDefs:
    pacBigSprDefs (SPRITE_ADDR + PAC_CUT_VRAM) / TILE_SIZE

pacBigSpriteTable:
;   00 - 03
    .DW pacBigTileDefs@half     ; 00
;   04 - 07
    .DW pacBigTileDefs@open     ; 02
;   08 - 0B
    .DW pacBigTileDefs@half     ; 04
;   0C - 0F
    .DW pacBigTileDefs@closed   ; 06


/*
    MACRO AND LIST FOR MS. PAC-MAN TILES [NORMAL / SUPER]
*/
.MACRO msPacSprDefs ARGS, VAL
;   UP
    .DB VAL+$06, VAL+$1C, VAL+$07, VAL+$1D  ; OPEN
    .DB VAL+$0D, VAL+$1C, VAL+$0E, VAL+$1D  ; HALF
    .DB VAL+$14, VAL+$1C, VAL+$15, VAL+$1D  ; CLOSED
    .DB VAL+$0D, VAL+$1C, VAL+$0E, VAL+$1D  ; HALF
;   LEFT
    .DB VAL+$0C, VAL+$22, VAL+$05, VAL+$1B  ; HALF
    .DB VAL+$13, VAL+$25, VAL+$05, VAL+$1B  ; CLOSED
    .DB VAL+$0C, VAL+$22, VAL+$05, VAL+$1B  ; HALF
    .DB VAL+$04, VAL+$1A, VAL+$05, VAL+$1B  ; OPEN
;   DOWN
    .DB VAL+$0A, VAL+$20, VAL+$0B, VAL+$21  ; HALF
    .DB VAL+$11, VAL+$24, VAL+$12, VAL+$1B  ; CLOSED
    .DB VAL+$0A, VAL+$20, VAL+$0B, VAL+$21  ; HALF
    .DB VAL+$02, VAL+$18, VAL+$03, VAL+$19  ; OPEN
;   RIGHT
    .DB VAL+$00, VAL+$16, VAL+$01, VAL+$17  ; OPEN
    .DB VAL+$08, VAL+$1E, VAL+$09, VAL+$1F  ; HALF
    .DB VAL+$0F, VAL+$1E, VAL+$10, VAL+$23  ; CLOSED
    .DB VAL+$08, VAL+$1E, VAL+$09, VAL+$1F  ; HALF
.ENDM

msPacSpriteTable:
    msPacSprDefs    (SPRITE_ADDR + PAC_VRAM) / TILE_SIZE


/*
    MACRO AND LIST FOR MS. PAC-MAN TILES [DEATH]
*/
.MACRO msPacDeathSprDefs    ARGS, VAL
    .DB VAL+$0A, VAL+$20, VAL+$0B, VAL+$21  ; DOWN HALF
    .DB VAL+$0C, VAL+$22, VAL+$05, VAL+$1B  ; LEFT HALF
    .DB VAL+$0D, VAL+$1C, VAL+$0E, VAL+$1D  ; UP HALF
    .DB VAL+$08, VAL+$1E, VAL+$09, VAL+$1F  ; RIGHT HALF
.ENDM

msPacDeathTileDefs:
    ; 3 LOOPS, BUT THIRD LOOP ENDS ON UP HALF
    msPacDeathSprDefs   (SPRITE_ADDR + PAC_VRAM) / TILE_SIZE