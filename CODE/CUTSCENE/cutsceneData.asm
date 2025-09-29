/*
----------------------------------------------
        CUTSCENE MODE DATA FOR PAC-MAN
----------------------------------------------
*/

;   GFX DATA PTRS FOR PAC-MAN
pacCutsceneGfxTable:
@smooth:
    .DW cutsceneGhostTiles
    .DW cutscenePacTiles
@smoothPlus:
    .DW cutsceneGhostTiles@plus
    .DW cutscenePacTiles
@arcade:
    .DW arcadeGFXData@cutsceneGhost
    .DW arcadeGFXData@cutscenePac
@arcadePlus
    .DW arcadeGFXData@cutsceneGhostPlus
    .DW arcadeGFXData@cutscenePac

;   --------------
;   GFX TILE LISTS
;   --------------

.MACRO pacCutGhostDefs   ARGS, VAL
    ghostBrokenTileDefs:
    .db VAL+$06, VAL+$12, VAL+$07, VAL+$13
    @observe:
    .db VAL+$08, VAL+$12, VAL+$09, VAL+$13
    ghostStitchedTileDefs:
    .db VAL, VAL+$0A, VAL+$01, VAL+$0B
    .db VAL, VAL+$0C, VAL+$01, VAL+$0D
    ghostNakedTileDefs:
    .db VAL+$02, VAL+$0E, VAL+$03, VAL+$0F
    .db VAL+$04, VAL+$10, VAL+$05, VAL+$11
    ghostClothTileDefs:
    .db VAL+$14, VAL+$15
    .db VAL+$16, VAL+$17
.ENDM

.DEFINE SCENE2_STUMP0           ((SPRITE_ADDR + GHOST_CUT_VRAM) / TILE_SIZE) + $18
.DEFINE SCENE2_STUMP1           SCENE2_STUMP0 + $01
.DEFINE SCENE2_STUMP2           SCENE2_STUMP1 + $01
.DEFINE SCENE2_STUMP3           SCENE2_STUMP2 + $01
.DEFINE SCENE2_STUMP4           SCENE2_STUMP3 + $01
.DEFINE SCENE2_STUMP5           SCENE2_STUMP4 + $01


pacCutGhostDefs         (SPRITE_ADDR + GHOST_CUT_VRAM) / TILE_SIZE


/*
----------------------------------------------
        CUTSCENE MODE DATA FOR MS.PAC-MAN
----------------------------------------------
*/

;   --------------
;   MACROS FOR TILE LISTS
;   --------------
.MACRO msSceneTitleDefs ARGS, VAL
    msScene0Title:
    .DB VAL+$20, VAL+$21, VAL+$22, VAL+$23, VAL+$24, VAL+$25, VAL+$26, VAL+$27
    msScene0Num:
    .DB VAL+$33
    msScene1Title:
    .DB VAL+$20, VAL+$21, VAL+$28, VAL+$29, VAL+$2A, VAL+$2B, VAL+$2C, VAL+$2D
    msScene1Num:
    .DB VAL+$34
    msScene2Title:
    .DB VAL+$2E, VAL+$2F, VAL+$30, VAL+$31, VAL+$32, BLANK_TILE, BLANK_TILE, BLANK_TILE
    msScene2Num:
    .DB VAL+$35
.ENDM


.MACRO msSceneGhostDefs ARGS, VAL
    .DB VAL, VAL+$08, VAL+$01, VAL+$09      ; RIGHT 0
    .DB VAL, VAL+$0A, VAL+$01, VAL+$0B      ; RIGHT 1
    .DB VAL+$04, VAL+$08, VAL+$05, VAL+$09  ; LEFT 0
    .DB VAL+$04, VAL+$0A, VAL+$05, VAL+$0B  ; LEFT 1
.ENDM

.MACRO jrSceneGhostDefs ARGS, VAL
    .DB VAL+$06, VAL+$08, VAL+$07, VAL+$09  ; UP 0
    .DB VAL+$06, VAL+$0A, VAL+$07, VAL+$0B  ; UP 1
    .DB VAL+$04, VAL+$08, VAL+$05, VAL+$09  ; LEFT 0
    .DB VAL+$04, VAL+$0A, VAL+$05, VAL+$0B  ; LEFT 1
    .DB VAL+$02, VAL+$08, VAL+$03, VAL+$09  ; DOWN 0
    .DB VAL+$02, VAL+$0A, VAL+$03, VAL+$0B  ; DOWN 1
    .DB VAL, VAL+$08, VAL+$01, VAL+$09      ; RIGHT 0
    .DB VAL, VAL+$0A, VAL+$01, VAL+$0B      ; RIGHT 1
.ENDM


.MACRO msSceneOttoGhostDefs ARGS, VAL
    .DB VAL, VAL+$0F, VAL+$01, VAL+$10      ; RIGHT 0
    .DB VAL+$02, VAL+$11, VAL+$03, VAL+$12  ; RIGHT 1
    .DB VAL+$08, VAL+$17, VAL+$09, VAL+$18  ; LEFT 0
    .DB VAL+$0A, VAL+$19, VAL+$09, VAL+$16  ; LEFT 1
.ENDM

.MACRO msSceneDefs ARGS, VAL
    .DB VAL+$0D, VAL+$16, VAL+$0E, VAL+$17  ; ACT SIGN CLACKER H 0  [19]
    .DB VAL+$0F, BLANK_TILE, BLANK_TILE, BLANK_TILE              ; ACT SIGN CLACKER H 1  [1A]
    .DB VAL+$13, VAL+$1B, VAL+$14, VAL+$1C  ; ACT SIGN CLACKER M 0  [1B]
    .DB VAL+$15, BLANK_TILE, BLANK_TILE, BLANK_TILE              ; ACT SIGN CLACKER M 1  [1C]
    .DB BLANK_TILE, VAL+$1D, BLANK_TILE, VAL+$1E          ; ACT SIGN CLACKER L 0  [1D]
    .DB BLANK_TILE, VAL+$1F, BLANK_TILE, BLANK_TILE              ; ACT SIGN CLACKER L 1  [1E]
    .DB VAL+$10, VAL+$18, VAL+$11, VAL+$19  ; ACT SIGN 0            [1F]
    .DB VAL+$12, VAL+$1A, BLANK_TILE, BLANK_TILE          ; ACT SIGN 1            [20]
    .DB VAL, VAL+$09, VAL+$01, VAL+$0A  ; HEART                 [21]
    .DB VAL+$02, BLANK_TILE, BLANK_TILE, BLANK_TILE              ; STORK HEAD            [22]
    .DB VAL+$03, BLANK_TILE, VAL+$04, BLANK_TILE          ; STORK FLAP 0          [23]
    .DB VAL+$05, VAL+$0B, VAL+$06, VAL+$0C  ; STORK FLAP 1          [24]
    .DB VAL+$07, BLANK_TILE, BLANK_TILE, BLANK_TILE              ; STORK SACK            [25]
    .DB VAL+$08, BLANK_TILE, BLANK_TILE, BLANK_TILE              ; JR PAC                [26]
.ENDM


;   --------------
;   SCENE TITLE AND NUMBER TILE LISTS
;   --------------
;   ALL HIGH BYTES ARE $08
msSceneTitleDefs        (SPRITE_ADDR + MS_CUT_VRAM) / TILE_SIZE


;   $01 - $0C
msSceneSubTileTbl:
@pacSN:
;   PAC-MAN [SMOOTH]
    .DW pacSNTileTbl@titlePtr       ; RIGHT HALF
    .DW pacSNTileTbl@titlePtr + $08 ; RIGHT OPEN
    .DW pacSNTileTbl@titlePtr       ; RIGHT HALF
    .DW pacSNTileTbl@titlePtr + $18 ; RIGHT CLOSED
    .DW pacSNTileTbl@left + $08     ; LEFT HALF
    .DW pacSNTileTbl@left + $10     ; LEFT OPEN
    .DW pacSNTileTbl@left + $08     ; LEFT HALF
    .DW pacSNTileTbl@left           ; LEFT CLOSED
    .DW pacSNTileTbl@up             ; UP HALF
    .DW pacSNTileTbl@up + $08       ; UP OPEN
    .DW pacSNTileTbl@up             ; UP HALF
    .DW pacSNTileTbl@up + $18       ; UP CLOSED
@annaSN:
;   ANNA [SMOOTH]
    .DW annaSNTileTbl@right + $18   ; RIGHT HALF 1
    .DW annaSNTileTbl@right + $10   ; RIGHT CLOSED
    .DW annaSNTileTbl@right + $08   ; RIGHT HALF 0
    .DW annaSNTileTbl@right         ; RIGHT OPEN
    .DW annaSNTileTbl@left          ; LEFT HALF 1
    .DW annaSNTileTbl@left + $08    ; LEFT CLOSED
    .DW annaSNTileTbl@left + $10    ; LEFT HALF 0
    .DW annaSNTileTbl@left + $18    ; LEFT OPEN
    .DW annaSNTileTbl@up + $18      ; UP HALF 1
    .DW annaSNTileTbl@up + $10      ; UP CLOSED
    .DW annaSNTileTbl@up + $08      ; UP HALF 0
    .DW annaSNTileTbl@up            ; UP OPEN
@pacAN:
;   PAC-MAN [ARCADE]
    .DW pacANTileTbl@titlePtr       ; RIGHT HALF
    .DW pacANTileTbl@titlePtr + $08 ; RIGHT OPEN
    .DW pacANTileTbl@titlePtr       ; RIGHT HALF
    .DW pacANTileTbl@titlePtr + $18 ; RIGHT CLOSED
    .DW pacANTileTbl@left + $08     ; LEFT HALF
    .DW pacANTileTbl@left + $10     ; LEFT OPEN
    .DW pacANTileTbl@left + $08     ; LEFT HALF
    .DW pacANTileTbl@left           ; LEFT CLOSED
    .DW pacANTileTbl@up             ; UP HALF
    .DW pacANTileTbl@up + $08       ; UP OPEN
    .DW pacANTileTbl@up             ; UP HALF
    .DW pacANTileTbl@up + $18       ; UP CLOSED
@annaAN:
;   ANNA [ARCADE]
    .DW annaANTileTbl@right + $18   ; RIGHT HALF 1
    .DW annaANTileTbl@right + $10   ; RIGHT CLOSED
    .DW annaANTileTbl@right + $08   ; RIGHT HALF 0
    .DW annaANTileTbl@right         ; RIGHT OPEN
    .DW annaANTileTbl@left          ; LEFT HALF 1
    .DW annaANTileTbl@left + $08    ; LEFT CLOSED
    .DW annaANTileTbl@left + $10    ; LEFT HALF 0
    .DW annaANTileTbl@left + $18    ; LEFT OPEN
    .DW annaANTileTbl@up + $18      ; UP HALF 1
    .DW annaANTileTbl@up + $10      ; UP CLOSED
    .DW annaANTileTbl@up + $08      ; UP HALF 0
    .DW annaANTileTbl@up            ; UP OPEN


;   $0D - $18
msSceneMainTileTbl:
@msSN:
;   MS.PAC-MAN [SMOOTH]
    .DW msSNTileTbl@hudPtr          ; RIGHT HALF
    .DW msSNTileTbl@titlePtr        ; RIGHT OPEN
    .DW msSNTileTbl@hudPtr          ; RIGHT HALF
    .DW msSNTileTbl@hudPtr + $08    ; RIGHT CLOSED
    .DW msSNTileTbl@left            ; LEFT HALF
    .DW msSNTileTbl@left + $18      ; LEFT OPEN
    .DW msSNTileTbl@left            ; LEFT HALF
    .DW msSNTileTbl@left + $08      ; LEFT CLOSED
    .DW msSNTileTbl@up + $08        ; UP HALF
    .DW msSNTileTbl@up              ; UP OPEN
    .DW msSNTileTbl@up + $08        ; UP HALF
    .DW msSNTileTbl@up + $10        ; UP CLOSED
@ottoSN:
;   OTTO [SMOOTH]
    .DW ottoSNTileTbl@titlePtr + $18; RIGHT HALF 1
    .DW ottoSNTileTbl@titlePtr + $10; RIGHT CLOSED
    .DW ottoSNTileTbl@titlePtr + $08; RIGHT HALF 0
    .DW ottoSNTileTbl@titlePtr      ; RIGHT OPEN
    .DW ottoSNTileTbl@left          ; LEFT HALF 1
    .DW ottoSNTileTbl@left + $08    ; LEFT CLOSED
    .DW ottoSNTileTbl@left + $10    ; LEFT HALF 0
    .DW ottoSNTileTbl@left + $18    ; LEFT OPEN
    .DW ottoSNTileTbl@up + $18      ; UP HALF 1
    .DW ottoSNTileTbl@up + $10      ; UP CLOSED
    .DW ottoSNTileTbl@up + $08      ; UP HALF 0
    .DW ottoSNTileTbl@up            ; UP OPEN
@msAN:
;   MS.PAC-MAN [ARCADE]
    .DW msANTileTbl@hudPtr          ; RIGHT HALF
    .DW msANTileTbl@titlePtr        ; RIGHT OPEN
    .DW msANTileTbl@hudPtr          ; RIGHT HALF
    .DW msANTileTbl@hudPtr + $08    ; RIGHT CLOSED
    .DW msANTileTbl@left            ; LEFT HALF
    .DW msANTileTbl@left + $18      ; LEFT OPEN
    .DW msANTileTbl@left            ; LEFT HALF
    .DW msANTileTbl@left + $08      ; LEFT CLOSED
    .DW msANTileTbl@up + $08        ; UP HALF
    .DW msANTileTbl@up              ; UP OPEN
    .DW msANTileTbl@up + $08        ; UP HALF
    .DW msANTileTbl@up + $10        ; UP CLOSED
@ottoAN:
;   OTTO [ARCADE]
    .DW ottoANTileTbl@titlePtr + $18; RIGHT HALF 1
    .DW ottoANTileTbl@titlePtr + $10; RIGHT CLOSED
    .DW ottoANTileTbl@titlePtr + $08; RIGHT HALF 0
    .DW ottoANTileTbl@titlePtr      ; RIGHT OPEN
    .DW ottoANTileTbl@left          ; LEFT HALF 1
    .DW ottoANTileTbl@left + $08    ; LEFT CLOSED
    .DW ottoANTileTbl@left + $10    ; LEFT HALF 0
    .DW ottoANTileTbl@left + $18    ; LEFT OPEN
    .DW ottoANTileTbl@up + $18      ; UP HALF 1
    .DW ottoANTileTbl@up + $10      ; UP CLOSED
    .DW ottoANTileTbl@up + $08      ; UP HALF 0
    .DW ottoANTileTbl@up            ; UP OPEN


;   GHOSTS $19 - $20
msSceneGhostTileTbl:
    ; PINKY & INKY
    msSceneGhostDefs    (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $0C
    msSceneGhostDefs    (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $18
    ; BLINKY & CLYDE (JR)
    jrSceneGhostDefs    (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $00
    jrSceneGhostDefs    (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $24
@otto:
    ; PINKY & INKY (OTTO)
    msSceneOttoGhostDefs    (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $1E
    msSceneOttoGhostDefs    (SPRITE_ADDR + GHOST_VRAM) / TILE_SIZE + $3C






;   --------------
;   TILE LISTS FOR CUTSCENE SPRITES
;   --------------
;   $21 - $FE
msSceneCharTable:
    .DSB $04, BLANK_TILE    ; EMPTY SPRITE          [00]
    msSceneDefs         (SPRITE_ADDR + MS_CUT_VRAM) / TILE_SIZE

    

;   --------------
;   SPRITE LISTS FOR SCENE CHARACTERS (REFERENCES PREVIOUS TABLE)
;   --------------
msSceneCharacters:
@emptySpr:
    .DB $00 $FF
;   --------
@pacRight:
    .DB $01 $01 $02 $02 $03 $03 $04 $04 $FF
@pacLeft:
    .DB $05 $05 $06 $06 $07 $07 $08 $08 $FF
@pacUp:
    .DB $09 $09 $0A $0A $0B $0B $0C $0C $FF
;   --------
@msPacRight:
    .DB $0D $0D $0E $0E $0F $0F $10 $10 $FF
@msPacLeft:
    .DB $11 $11 $12 $12 $13 $13 $14 $14 $FF
@msPacUp:
    .DB $15 $15 $16 $16 $17 $17 $18 $18 $FF
;   --------
@pinkyRight:
    .DB $19 $19 $1A $1A $19 $19 $FF
@pinkyLeft:
    .DB $1B $1B $1C $1C $1B $1B $FF
@inkyRight:
    .DB $1D $1D $1E $1E $1D $1D $FF
@inkyLeft:
    .DB $1F $1F $20 $20 $1F $1F $FF
;   --------
@actClacker0:   ; $21
    .DB $21 $21 $21 $23 $23 $23 $25 $25 $25 $FF
@actClacker1:
    .DB $22 $22 $22 $24 $24 $24 $26 $26 $26 $FF
@actSign0:
    .DB $27 $FF
@actSign1:
    .DB $28 $FF
@heart:
    .DB $29 $FF
@storkHead:
    .DB $2A $FF
@storkBody:
    .DB $2B $2B $2B $2B $2C $2C $2C $2C $FF
@storkSack:
    .DB $2D $FF
@jrPac:
    .DB $2E $FF


/*
    $8671: ; EMPTY SPRITE

    $8614: ; PAC-MAN FACING RIGHT
    $861D: ; PAC-MAN FACING LEFT
    $8626: ; PAC-MAN FACING UP
    $862F: ; PAC-MAN FACING UP (FLIPPED HORIZONTAL???) [NOT USED!!!]

    $8638: ; MS. PAC FACING RIGHT
    $8641: ; MS. PAC FACING LEFT
    $864A: ; MS. PAC FACING UP
    $8653: ; MS. PAC FACING DOWN [NOT USED!!!]

    $865C: ; PINKY FACING RIGHT
    $8663: ; PINKY FACING LEFT
    $866A: ; PINKY FACING UP [NOT USED!!!]

    $865C: ; INKY FACING RIGHT
    $8663: ; INKY FACING LEFT
    $866A: ; INKY FACING UP [NOT USED!!!]

    $8675: ; ACT SIGN CLACKER HALF 1
    $867F: ; ACT SIGN CLACKER HALF 2

    $8689: ; ACT SIGN HALF 1
    $868B: ; ACT SIGN HALF 2

    $8673: ; HEART

    $868D: ; STORK
    $868F: ; STORK FLAPPING
    $8698: ; STORK SACK
    $869A: ; JR PAC
*/

;   CUTSCENE DATA MACROS
.MACRO LOOP ARGS xPos yPos
    .DB $F0, xPos, yPos
.ENDM
.MACRO SETPOS ARGS xPos yPos
    .DB $F1, xPos, yPos
.ENDM
.MACRO SETN ARGS val
    .DB $F2, val
.ENDM
.MACRO SETCHAR ARGS charWord
    .DB $F3
    .DW charWord
.ENDM
.MACRO SETBGPRI ARGS val
    .DB $F4, val
.ENDM
.MACRO PLAYSND ARGS val
    .DB $F5, val
.ENDM
.MACRO PAUSE
    .DB $F6
.ENDM
.MACRO CLEARTEXT
    .DB $F7
.ENDM
.MACRO CLEARNUM
    .DB $F8
.ENDM
.MACRO SETBGPAL ARGS val
    .DB $F9, val
.ENDM
.MACRO CLRPOWDOT ARGS val
    .DB $FA, val
.ENDM
.MACRO SETJRVAR ARGS val
    .DB $FB, val
.ENDM
.MACRO DECPTR ARGS val
    .DB $FC, val
.ENDM
.MACRO CUTEND
    .DB $FF
.ENDM

;   DATA FOR CUTSCENE 0
msScene0ProgTable:
    .DW msScene0Prog0
    .DW msScene0Prog1
    .DW msScene0Prog2
    .DW msScene0Prog3
    .DW msScene0Prog4
    .DW msScene0Prog5

ottoScene0ProgTable:
    .DW ottoScene0Prog0
    .DW msScene0Prog1
    .DW ottoScene0Prog2
    .DW msScene0Prog3
    .DW msScene0Prog4
    .DW msScene0Prog5


msScene0Prog0:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker0
    SETN    $01
    LOOP    $00 $00
    SETPOS  $BD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
;   DO PAC-MAN
    SETPOS  $FF $54
    SETCHAR msSceneCharacters@pacRight
    SETN    $7F
    LOOP    $F0 $00
    SETN    $7F
    LOOP    $F0 $00
    SETPOS  $00 $7F
    SETCHAR msSceneCharacters@pacLeft
    SETN    $75
    LOOP    $10 $00
    SETN    $04
    LOOP    $10 $F0
    SETCHAR msSceneCharacters@pacUp
    SETN    $30
    LOOP    $00 $F0
    SETCHAR msSceneCharacters@pacLeft
    SETN    $10
    LOOP    $00 $00
    CUTEND


msScene0Prog1:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker1
    SETN    $01
    LOOP    $00 $00
    SETPOS  $A7 $52     ; $AD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
;   DO INKY
    SETPOS  $FF $54
    SETCHAR msSceneCharacters@inkyRight
    SETN    $2F
    PAUSE
    SETN    $70
    LOOP    $EF $00
    SETN    $74
    LOOP    $EC $00
    SETPOS  $00 $7F
    SETCHAR msSceneCharacters@inkyLeft
    SETN    $1C
    PAUSE
    SETN    $58
    LOOP    $16 $00
    PLAYSND $10             ; IGNORED
    SETN    $06
    LOOP    $F8 $F8
    SETN    $06
    LOOP    $F8 $08
    SETN    $06
    LOOP    $F8 $F8
    SETN    $06
    LOOP    $F8 $08
    SETPOS  $00 $00
;   DO HEART
    SETCHAR msSceneCharacters@heart
    SETN    $01
    LOOP    $00 $00
    SETPOS  $7F $3A
    SETN    $40
    LOOP    $00 $00
    CUTEND


msScene0Prog2:
;   DO MS. PAC-MAN
    SETN    $5A
    PAUSE
    SETPOS  $00 $A4
    SETCHAR msSceneCharacters@msPacLeft
    SETN    $7F
    LOOP    $10 $00
    SETN    $7F
    LOOP    $10 $00
    SETPOS  $FF $7F
    SETCHAR msSceneCharacters@msPacRight
    SETN    $76
    LOOP    $F0 $00
    SETN    $04
    LOOP    $F0 $F0
    SETCHAR msSceneCharacters@msPacUp
    SETN    $30
    LOOP    $00 $F0
    SETCHAR msSceneCharacters@msPacRight
    SETN    $10
    LOOP    $00 $00
    CUTEND



msScene0Prog3:
;   DO PINKY
    SETN    $5F
    PAUSE
    SETPOS  $01 $A4
    SETCHAR msSceneCharacters@pinkyLeft
    SETN    $2F
    PAUSE
    SETN    $70
    LOOP    $11 $00
    SETN    $74
    LOOP    $14 $00
    SETPOS  $FF $7F
    SETCHAR msSceneCharacters@pinkyRight
    SETN    $1C
    PAUSE
    SETN    $58
    LOOP    $EA $00
    SETN    $06
    LOOP    $08 $F8
    SETN    $06
    LOOP    $08 $08
    SETN    $06
    LOOP    $08 $F8
    SETN    $06
    LOOP    $08 $08
    SETCHAR msSceneCharacters@emptySpr
    SETN    $10
    LOOP    $00 $00
    CUTEND



msScene0Prog4:
msScene1Prog4:
;   DO ACT SIGN
    SETCHAR msSceneCharacters@actSign0
    SETN    $01
    LOOP    $00 $00
    SETPOS  $BD $62
    SETN    $5A
    PAUSE
    SETPOS  $00 $00
    CUTEND


msScene0Prog5:
msScene1Prog5:
msScene2Prog5:
;   DO ACT SIGN
    SETCHAR msSceneCharacters@actSign1
    SETN    $01
    LOOP    $00 $00
    SETPOS  $A7 $62     ; $AD $62
    SETN    $39
    PAUSE
;   CLEAR ACT NAME & NUMBER
    CLEARTEXT
    SETN    $1E
    PAUSE
    CLEARNUM
    SETPOS  $00 $00
    CUTEND




ottoScene0Prog0:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker0
    SETN    $01
    LOOP    $00 $00
    SETPOS  $BD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
;   DO MS.PAC-MAN (OTTO)
    SETPOS  $FF $54
    SETCHAR msSceneCharacters@msPacRight
    SETN    $7F
    LOOP    $F0 $00
    SETN    $7F
    LOOP    $F0 $00
    SETPOS  $00 $7F
    SETCHAR msSceneCharacters@msPacLeft
    SETN    $75
    LOOP    $10 $00
    SETN    $04
    LOOP    $10 $F0
    SETCHAR msSceneCharacters@msPacUp
    SETN    $30
    LOOP    $00 $F0
    SETCHAR msSceneCharacters@msPacLeft
    SETN    $10
    LOOP    $00 $00
    CUTEND


ottoScene0Prog2:
;   DO PAC-MAN (ANNA)
    SETN    $5A
    PAUSE
    SETPOS  $00 $A4
    SETCHAR msSceneCharacters@pacLeft
    SETN    $7F
    LOOP    $10 $00
    SETN    $7F
    LOOP    $10 $00
    SETPOS  $FF $7F
    SETCHAR msSceneCharacters@pacRight
    SETN    $76
    LOOP    $F0 $00
    SETN    $04
    LOOP    $F0 $F0
    SETCHAR msSceneCharacters@pacUp
    SETN    $30
    LOOP    $00 $F0
    SETCHAR msSceneCharacters@pacRight
    SETN    $10
    LOOP    $00 $00
    CUTEND



;   DATA FOR CUTSCENE 1
msScene1ProgTable:
    .DW msScene1Prog0
    .DW msScene1Prog1
    .DW msScene1Prog2
    .DW msScene1Prog3
    .DW msScene1Prog4
    .DW msScene1Prog5


msScene1Prog0:
;   WAIT
    SETN    $5A
    PAUSE
;   DO PAC-MAN
    SETPOS  $FF $34
    SETCHAR msSceneCharacters@pacRight
    SETN    $7F
    PAUSE
    SETN    $24
    PAUSE
    SETN    $68
    LOOP    $D8 $00
    SETN    $7F
    PAUSE
    SETN    $18
    PAUSE
;   DO MS. PAC-MAN
    SETPOS  $00 $94
    SETCHAR msSceneCharacters@msPacLeft
    SETN    $68
    LOOP    $28 $00
    SETN    $7F
    PAUSE
;   DO PAC-MAN
    SETPOS  $FC $7F
    SETCHAR msSceneCharacters@pacRight
    SETN    $18
    PAUSE
    SETN    $68
    LOOP    $D8 $00
    SETN    $7F
    PAUSE
    SETN    $18
    PAUSE
;   DO MS. PAC-MAN
    SETPOS  $00 $54
    SETCHAR msSceneCharacters@msPacLeft
    SETN    $20
    LOOP    $70 $00
;   DO PAC-MAN
    SETPOS  $FF $B4
    SETCHAR msSceneCharacters@pacRight
    SETN    $10
    PAUSE
    SETN    $24
    LOOP    $90 $00
    CUTEND


msScene1Prog1:
;   WAIT
    SETN    $63
    PAUSE
;   DO MS. PAC-MAN
    SETPOS  $FF $34
    SETCHAR msSceneCharacters@msPacRight
    SETN    $24
    PAUSE
    SETN    $7F
    PAUSE
    SETN    $18
    PAUSE
    SETN    $57
    LOOP    $D0 $00
    SETN    $7F
    PAUSE
    SETN    $28
    PAUSE
;   DO PAC-MAN
    SETPOS  $00 $94
    SETCHAR msSceneCharacters@pacLeft
    SETN    $58
    LOOP    $30 $00
    SETN    $7F
    PAUSE
    SETN    $24
    PAUSE
;   DO MS. PAC-MAN
    SETPOS  $FF $7F
    SETCHAR msSceneCharacters@msPacRight
    SETN    $58
    LOOP    $D0 $00
    SETN    $7F
    PAUSE
    SETN    $20
    PAUSE
;   PAC-MAN
    SETPOS  $00 $54
    SETCHAR msSceneCharacters@pacLeft
    SETN    $20
    LOOP    $70 $00
;   MS. PAC-MAN
    SETPOS  $FF $B4
    SETCHAR msSceneCharacters@msPacRight
    SETN    $10
    PAUSE
    SETN    $24
    LOOP    $90 $00
    SETN    $7F
    PAUSE
    CUTEND


msScene1Prog2:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker0
    SETN    $01
    LOOP    $00 $00
    SETPOS  $BD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
    SETPOS    $00 $00
    CUTEND


msScene1Prog3:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker1
    SETN    $01
    LOOP    $00 $00
    SETPOS  $A7 $52     ; $AD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
    SETPOS    $00 $00
    CUTEND



;   DATA FOR CUTSCENE 2
msScene2ProgTable:
    .DW msScene2Prog0
    .DW msScene2Prog1
    .DW msScene2Prog2
    .DW msScene2Prog3
    .DW msScene2Prog4
    .DW msScene2Prog5


msScene2Prog1:
;   DO STORK HEAD
    SETN    $5A
    PAUSE
    SETPOS  $00 $60
    SETCHAR msSceneCharacters@storkHead
    SETN    $7F
    LOOP    $0A $00
    SETN    $7F
    LOOP    $10 $00
    SETN    $30
    LOOP    $10 $00
    CUTEND



msScene2Prog0:
;   DO STORK BODY
    SETN    $6A
    PAUSE
    SETPOS  $00 $60
    SETCHAR msSceneCharacters@storkBody
    SETN    $6F
    LOOP    $0A $00
    SETN    $7F
    LOOP    $10 $00
    SETN    $3A
    LOOP    $10 $00
    CUTEND



msScene2Prog2:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker0
    SETN    $01
    LOOP    $00 $00
    SETPOS  $BD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
    SETPOS  $00 $00
;   DO MS. PAC-MAN
    SETCHAR msSceneCharacters@msPacRight
    SETN    $01
    LOOP    $00 $00
    SETPOS  $C0 $C0
    SETN    $30
    PAUSE
    CUTEND



msScene2Prog3:
;   DO ACT SIGN CLACKER
    SETPOS  $00 $00
    SETCHAR msSceneCharacters@actClacker1
    SETN    $01
    LOOP    $00 $00
    SETPOS  $A7 $52     ; $AD $52
    SETN    $28
    PAUSE
    SETN    $16
    LOOP    $00 $00
    SETN    $16
    PAUSE
    SETPOS  $00 $00
;   DO PAC-MAN
    SETCHAR msSceneCharacters@pacRight
    SETN    $01
    LOOP    $00 $00
    SETPOS  $D0 $C0
    SETN    $30
    PAUSE
    CUTEND



msScene2Prog4:
;   DO ACT SIGN
    SETCHAR msSceneCharacters@actSign0
    SETN    $01
    LOOP    $00 $00
    SETPOS  $BD $62
    SETN    $5A
    PAUSE
;   DO BABY SACK
    SETPOS  $05 $64     ; $05 $60 65
    SETCHAR msSceneCharacters@storkSack
    SETN    $7F
    LOOP    $0A $00
    SETN    $7F
    LOOP    $06 $0C
    SETN    $06
    LOOP    $06 $F0
    SETN    $0C
    LOOP    $03 $09
    SETN    $05
    LOOP    $05 $F6
    SETN    $0A
    LOOP    $04 $03
;   DO JR. PAC
    SETCHAR msSceneCharacters@jrPac
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    CUTEND


/*
----------------------------------------------
        CUTSCENE MODE DATA FOR JR.PAC-MAN
----------------------------------------------
*/


.MACRO jrSceneDefs ARGS, VAL
    .DB VAL+$00, VAL+$17, VAL+$01, VAL+$18              ; HEART 0
    .DB VAL+$02, VAL+$19, VAL+$03, BLANK_TILE           ; HEART 1
    .DB VAL+$04, VAL+$1A, VAL+$05, BLANK_TILE           ; HEART 2
    .DB VAL+$06, VAL+$1B, BLANK_TILE, BLANK_TILE        ; HEART 3
    .DB VAL+$08, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; STORK HEAD
    .DB VAL+$09, BLANK_TILE, VAL+$0A, BLANK_TILE        ; STORK FLAP 0
    .DB VAL+$0B, VAL+$1C, VAL+$0C, VAL+$1D              ; STORK FLAP 1
    .DB VAL+$0D, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; STORK SACK
    .DB VAL+$0E, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; JR PAC
    .DB VAL+$15, VAL+$22, VAL+$16, VAL+$23              ; GROWING JR 0
    .DB VAL+$13, VAL+$21, VAL+$14, BLANK_TILE           ; GROWING JR 1
    .DB VAL+$11, VAL+$20, VAL+$12, VAL+$1F              ; GROWING JR 2
    .DB VAL+$0F, VAL+$1E, VAL+$10, VAL+$1F              ; GROWING JR 3
.ENDM

;   --------------
;   TILE LISTS FOR CUTSCENE SPRITES
;   --------------
;   $21 - $FE
jrSceneCharTable:
    .DSB $04, BLANK_TILE    ; EMPTY SPRITE          [00]
    jrSceneDefs         (SPRITE_ADDR + JR_CUT_VRAM) / TILE_SIZE




jrSceneCharacters:
@emptySpr:
    .DB $00 $FF
;   --------
@pacRight:      ; OPEN, HALF, CLOSED, HALF
    .DB $02 $02 $01 $01 $04 $04 $03 $03 $FF
@pacStatic:
    .DB $01 $FF
;   --------
@jrPacRight:    ; HALF, OPEN, HALF, CLOSED
    .DB $05 $05 $06 $06 $05 $05 $07 $07 $FF
@jrPacLeft:
    .DB $08 $08 $09 $09 $08 $08 $0A $0A $FF
;   --------
@msPacRight:    ; CLOSED, HALF, OPEN, HALF
    .DB $10 $10 $0D $0D $0E $0E $0F $0F $FF
@msPacLeft:
    .DB $14 $14 $11 $11 $12 $12 $13 $13 $FF
@msPacStatic:
    .DB $0D $FF
;   --------
@pinkyRight:
    .DB $19 $19 $19 $1A $1A $1A $FF
@pinkyLeft:
    .DB $1B $1B $1B $1C $1C $1C $FF
@inkyRight:
    .DB $1D $1D $1D $1E $1E $1E $FF
@inkyLeft:
    .DB $1F $1F $1F $20 $20 $20 $FF
@blinkyUp:
    .DB $21 $21 $21 $22 $22 $22 $FF
@blinkyLeft:
    .DB $23 $23 $23 $24 $24 $24 $FF
@blinkyDown:
    .DB $25 $25 $25 $26 $26 $26 $FF
@blinkyRight:
    .DB $27 $27 $27 $28 $28 $28 $FF
@clydeUp:
    .DB $29 $29 $29 $2A $2A $2A $FF
@clydeLeft:
    .DB $2B $2B $2B $2C $2C $2C $FF
@clydeDown:
    .DB $2D $2D $2D $2E $2E $2E $FF
@clydeRight:
    .DB $2F $2F $2F $30 $30 $30 $FF
;   --------
@heart:
    .DB $00 $00 $00 $00 $00 $00 $00 $00 $34 $33 $32 $31 $32 $33 $34 $FF
@storkHead:
    .DB $35 $FF
@storkBody:
    .DB $36 $36 $36 $36 $37 $37 $37 $37 $FF
@storkSack:
    .DB $38 $FF
@babyPac:
    .DB $39 $FF
@growingJr0:
    .DB $3A $FF
@growingJr1:
    .DB $3B $FF
@growingJr2:
    .DB $3C $FF
@growingJr3:
    .DB $3D $FF




;   DATA FOR ATTRACT MODE
jrAttractProgTable:
    .DW jrAttractProg0
    .DW jrAttractProg1
    .DW jrAttractProg2
    .DW jrAttractProg3
    .DW jrAttractProg4
    .DW jrAttractProg5


jrAttractProg0:
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@storkSack
    SETN    $01
    LOOP    $00 $00
    SETN    $A0
    PAUSE
    SETN    $80
    PAUSE
    SETPOS  $14 $28
    SETN    $FF
    LOOP    $08 $00
    SETN    $60
    LOOP    $08 $00
    SETBGPRI    $00
    SETN    $F8
    LOOP    $08 $0B
    PLAYSND $10
    SETN    $0A
    LOOP    $08 $F5
    SETN    $0A
    LOOP    $08 $0B
    PLAYSND $10
    SETN    $06
    LOOP    $08 $F5
    SETN    $06
    LOOP    $08 $0B
    PLAYSND $10
    SETN    $30
    PAUSE
    SETN    $03
    LOOP    $F0 $F0
    SETN    $03
    LOOP    $10 $10
    SETN    $03
    LOOP    $10 $10
    SETN    $03
    LOOP    $F0 $10
    SETCHAR jrSceneCharacters@growingJr0
    SETN    $01
    LOOP    $00 $00
    SETBGPRI    $01
    SETN    $0B
    PAUSE
    SETCHAR jrSceneCharacters@growingJr1
    SETN    $01
    LOOP    $00 $00
    SETN    $0B
    PAUSE
    SETCHAR jrSceneCharacters@growingJr2
    SETN    $01
    LOOP    $00 $00
    SETN    $0B
    PAUSE
    SETCHAR jrSceneCharacters@growingJr3
    SETN    $01
    LOOP    $00 $00
    SETN    $FF
    PAUSE
    CUTEND



jrAttractProg1:
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@storkHead
    SETN    $01
    LOOP    $00 $00
    SETN    $A0
    PAUSE
    SETN    $80
    PAUSE
    SETPOS  $10 $28
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    SETN    $A0
    LOOP    $08 $00
    SETPOS  $00 $00
    CUTEND



jrAttractProg2:
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@storkBody
    SETN    $01
    LOOP    $00 $00
    SETN    $A0
    PAUSE
    SETN    $80
    PAUSE
    SETPOS  $00 $28
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    SETN    $A0
    LOOP    $08 $00
    SETPOS  $00 $00
    CUTEND


jrAttractProg3:
    SETJRVAR    $00
    SETBGPRI    $01
    ; BLINKY
    SETPOS  $00 $E0
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $48
    LOOP    $0A $00
    SETN    $20
    LOOP    $0A $04
    SETN    $40
    LOOP    $0A $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@blinkyRight
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@blinkyRight
    SETN    $40
    LOOP    $F6 $00
    SETN    $20
    LOOP    $F6 $FC
    SETN    $48
    LOOP    $F6 $00
    ; PINKY
    SETPOS  $00 $E0
    SETCHAR jrSceneCharacters@pinkyLeft
    SETN    $48
    LOOP    $0A $00
    SETN    $20
    LOOP    $0A $04
    SETN    $40
    LOOP    $0A $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@pinkyRight
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@pinkyLeft
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@pinkyRight
    SETN    $40
    LOOP    $F6 $00
    SETN    $20
    LOOP    $F6 $FC
    SETN    $48
    LOOP    $F6 $00
    ; INKY
    SETPOS  $00 $E0
    SETCHAR jrSceneCharacters@inkyLeft
    SETN    $48
    LOOP    $0A $00
    SETN    $20
    LOOP    $0A $04
    SETN    $40
    LOOP    $0A $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@inkyRight
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@inkyLeft
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@inkyRight
    SETN    $40
    LOOP    $F6 $00
    SETN    $20
    LOOP    $F6 $FC
    SETN    $48
    LOOP    $F6 $00
    ; "TIM"
    SETJRVAR    $01
    SETPOS  $00 $E0
    SETCHAR jrSceneCharacters@clydeLeft
    SETN    $48
    LOOP    $0A $00
    SETN    $20
    LOOP    $0A $04
    SETN    $40
    LOOP    $0A $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@clydeRight
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@clydeLeft
    SETN    $01
    LOOP    $00 $00
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@clydeUp
    SETN    $01
    LOOP    $00 $00
    SETN    $E0
    PAUSE
    SETN    $F0
    PAUSE
    ; MS.PAC-MAN
    ;SETCHAR jrSceneCharacters@msPacStatic
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $28
    LOOP    $70 $F7 ; BLANK
    SETCHAR jrSceneCharacters@msPacStatic
    SETN    $01
    LOOP    $00 $00
    SETN    $FF
    PAUSE
    SETCHAR jrSceneCharacters@msPacRight
    SETN    $26
    PAUSE
    SETN    $86
    LOOP    $00 $00
    SETN    $30
    PAUSE
    CUTEND


jrAttractProg4:
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    SETPOS  $00 $00
    ;SETCHAR jrSceneCharacters@babyPac
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $C0
    PAUSE
    SETN    $FF
    PAUSE
    SETN    $FF
    LOOP    $10 $00 ; BLANK
    SETN    $74
    LOOP    $10 $00 ; BLANK
    SETBGPAL    $01
    SETN    $3C
    LOOP    $10 $00 ; BLANK
    CUTEND



jrAttractProg5:
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    SETPOS  $00 $00
    ;SETCHAR jrSceneCharacters@pacStatic
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00 ; BLANK
    SETPOS  $00 $D2
    SETN    $98
    LOOP    $10 $00 ; BLANK
    SETN    $FF
    LOOP    $10 $00 ; BLANK
    SETCHAR jrSceneCharacters@pacStatic
    SETN    $01
    LOOP    $00 $00
    SETN    $FF
    PAUSE
    SETN    $FF
    PAUSE
    SETN    $80
    PAUSE
    SETCHAR jrSceneCharacters@pacRight
    SETN    $17
    PAUSE
    SETN    $86
    LOOP    $00 $00
    CUTEND












