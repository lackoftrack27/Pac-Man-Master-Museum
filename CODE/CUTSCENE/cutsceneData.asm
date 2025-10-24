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


/*
----------------------------------------------
        CUTSCENE MODE DATA FOR JR.PAC-MAN
----------------------------------------------
*/
;   $05 - $0A
jrSceneJrTileTbl:
@jrPacSN: ; HALF, OPEN, HALF, CLOSED
;   JR. PAC-MAN [SMOOTH]
    .DW jrSNTileTbl@right + $08     ; RIGHT HALF
    .DW jrSNTileTbl@right + $00     ; RIGHT OPEN
    .DW jrSNTileTbl@right + $10     ; RIGHT CLOSED
    .DW jrSNTileTbl@left + $00      ; LEFT HALF
    .DW jrSNTileTbl@left + $18      ; LEFT OPEN
    .DW jrSNTileTbl@left + $08      ; LEFT CLOSED
@jrPacAN:
;   JR. PAC-MAN [ARCADE]
    .DW jrANTileTbl@right + $08     ; RIGHT HALF
    .DW jrANTileTbl@right + $00     ; RIGHT OPEN
    .DW jrANTileTbl@right + $10     ; RIGHT CLOSED
    .DW jrANTileTbl@left + $00      ; LEFT HALF
    .DW jrANTileTbl@left + $18      ; LEFT OPEN
    .DW jrANTileTbl@left + $08      ; LEFT CLOSED



.MACRO jrSceneDefs ARGS, VAL
    ;   JR. UNIQUE
    .DB VAL+$0D, VAL+$1B, VAL+$0E, VAL+$1C              ; HEART 0       [31]
    ;   GFX FROM MS.PAC
    .DB VAL+$02, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; STORK HEAD    [32]
    .DB VAL+$03, BLANK_TILE, VAL+$04, BLANK_TILE        ; STORK FLAP 0  [33]
    .DB VAL+$05, VAL+$0B, VAL+$06, VAL+$0C              ; STORK FLAP 1  [34]
    .DB VAL+$07, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; STORK SACK    [35]
    .DB VAL+$08, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; BABY PAC      [36]
    ;   JR. UNIQUE
    .DB VAL+$0F, VAL+$1D, VAL+$10, BLANK_TILE           ; HEART 1       [37]
    .DB VAL+$11, VAL+$1E, VAL+$12, BLANK_TILE           ; HEART 2       [38]
    .DB VAL+$13, VAL+$1F, BLANK_TILE, BLANK_TILE        ; HEART 3       [39]
    .DB VAL+$15, VAL+$20, VAL+$16, VAL+$21              ; GROWING JR 0  [3A]
    .DB VAL+$17, VAL+$22, VAL+$18, VAL+$23              ; GROWING JR 1  [3B]
    .DB VAL+$19, VAL+$24, VAL+$1A, VAL+$25              ; GROWING JR 2  [3C]
    .DB VAL+$26, VAL+$34, VAL+$27, VAL+$35              ; GROWING JR 3  [3D]

    .DB VAL+$28, VAL+$36, VAL+$29, VAL+$37              ; YUM-YUM RIGHT 0   [3E]
    .DB VAL+$2A, VAL+$38, VAL+$2B, VAL+$39              ; YUM-YUM RIGHT 1   [3F]
    .DB VAL+$2C, VAL+$36, VAL+$2D, VAL+$37              ; YUM-YUM LEFT 0    [40]
    .DB VAL+$2E, VAL+$38, VAL+$2F, VAL+$39              ; YUM-YUM LEFT 1    [41]
    .DB VAL+$30, VAL+$36, VAL+$31, VAL+$37              ; YUM-YUM UP 0      [42]
    .DB VAL+$32, VAL+$38, VAL+$33, VAL+$39              ; YUM-YUM UP 1      [43]

    .DB VAL+$3A, VAL+$45, BLANK_TILE, BLANK_TILE        ; BALLOON TOP 0     [44]
    .DB VAL+$3B, VAL+$46, BLANK_TILE, VAL+$47           ; BALLOON TOP 1     [45]
    .DB VAL+$3C, VAL+$48, VAL+$3D, BLANK_TILE           ; BALLOON TOP 2     [46]
    .DB VAL+$3E, BLANK_TILE, VAL+$3F, BLANK_TILE        ; BALLOON BTM 0     [47]
    .DB VAL+$40, BLANK_TILE, VAL+$41, BLANK_TILE        ; BALLOON BTM 1     [48]
    .DB VAL+$42, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; BALLOON BTM 2     [49]

    .DB VAL+$43, VAL+$49, VAL+$44, VAL+$4A              ; BALLOON TOP 0  H  [4A]
    .DB VAL+$4B, VAL+$54, VAL+$4C, BLANK_TILE           ; BALLOON TOP 1  H  [4B]
    .DB VAL+$4D, VAL+$55, VAL+$4E, BLANK_TILE           ; BALLOON TOP 2  H  [4C]
    .DB VAL+$4F, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; BALLOON BTM 0  H  [4D]
    .DB VAL+$50, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; BALLOON BTM 1  H  [4E]
    .DB VAL+$51, BLANK_TILE, BLANK_TILE, BLANK_TILE     ; BALLOON BTM 2  H  [4F]

    .DB VAL+$52, VAL+$56, VAL+$53, VAL+$57              ; BLINKY SCARED  0  [50]
    .DB VAL+$52, VAL+$58, VAL+$53, VAL+$59              ; BLINKY SCARED  1  [51]
    .DB VAL+$5A, VAL+$66, VAL+$5B, VAL+$67              ; YUM-YUM SCARED 0  [52]
    .DB VAL+$5C, VAL+$68, VAL+$5D, VAL+$69              ; YUM-YUM SCARED 1  [53]

    .DB VAL+$5E, VAL+$6A, VAL+$5F, VAL+$6B              ; BLINKY SCARED [PLUS]  0   [54]
    .DB VAL+$60, VAL+$6C, VAL+$61, VAL+$6D              ; BLINKY SCARED [PLUS]  1   [55]
    .DB VAL+$62, VAL+$6E, VAL+$63, VAL+$6F              ; YUM-YUM SCARED [PLUS] 0   [56]
    .DB VAL+$64, VAL+$70, VAL+$65, VAL+$71              ; YUM-YUM SCARED [PLUS] 1   [57]
.ENDM

;   --------------
;   TILE LISTS FOR CUTSCENE SPRITES
;   --------------
;   $21 - $FE
jrSceneCharTable:
    .DSB $04, BLANK_TILE    ; EMPTY SPRITE          [00]
    jrSceneDefs         (SPRITE_ADDR + JR_CUT_VRAM) / TILE_SIZE




;   --------------
;   SPRITE LISTS FOR SCENE CHARACTERS (REFERENCES PREVIOUS TABLE)
;   --------------
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
    .DB $00 $00 $00 $00 $00 $00 $00 $00 $39 $38 $37 $31 $37 $38 $39 $FF
@storkHead:
    .DB $32 $FF
@storkBody:
    .DB $33 $33 $33 $33 $34 $34 $34 $34 $FF
@storkSack:
    .DB $35 $FF
@babyPac:
    .DB $36 $FF
@growingJr0:
    .DB $3A $FF
@growingJr1:
    .DB $3B $FF
@growingJr2:
    .DB $3C $FF
@growingJr3:
    .DB $3D $FF
@yumyumUp:
    .DB $42 $42 $42 $43 $43 $43 $FF
@yumyumLeft:
    .DB $40 $40 $40 $41 $41 $41 $FF
@yumyumRight:
    .DB $3E $3E $3E $3F $3F $3F $FF
@balloonTop:
    .DB $44 $44 $44 $44 $44 $44 $44 $44 $44 $44 $45 $45 $45 $45 $45 $46 $46 $46
    .DB $4C $4C $4C $4B $4B $4B $4B $4B $4A $4A $4A $4A $4A $4A $4A $4A $4A $4A
    .DB $4B $4B $4B $4B $4B $4C $4C $4C $46 $46 $46 $45 $45 $45 $45 $45 $FF
@balloonBtm:
    .DB $47 $47 $47 $47 $47 $47 $47 $47 $47 $47 $48 $48 $48 $48 $48 $49 $49 $49
    .DB $4F $4F $4F $4E $4E $4E $4E $4E $4D $4D $4D $4D $4D $4D $4D $4D $4D $4D
    .DB $4E $4E $4E $4E $4E $4F $4F $4F $49 $49 $49 $48 $48 $48 $48 $48 $FF
@balloonTopStatic:
    .DB $44 $FF
@balloonBtmStatic:
    .DB $47 $FF
@balloonTopFast:
    .DB $45 $45 $45 $45 $45 $46 $46 $46
    .DB $4C $4C $4C $4B $4B $4B $4B $4B
    .DB $4C $4C $4C $46 $46 $46 $FF
@balloonBtmFast:
    .DB $48 $48 $48 $48 $48 $49 $49 $49
    .DB $4F $4F $4F $4E $4E $4E $4E $4E
    .DB $4F $4F $4F $49 $49 $49 $FF
@blinkyScared:
    .DB $50 $50 $50 $51 $51 $51 $FF
@yumyumScared:
    .DB $52 $52 $52 $53 $53 $53 $FF




/*
----------------------------------------------
            CUTSCENE COMMAND DATA
----------------------------------------------
*/
;   CUTSCENE DATA MACROS
.MACRO MOVE ARGS xSpd ySpd  ; TOP NIBBLE: SIGNED PIXEL, LOW NIBBLE: SUB-PIXEL
    .DB $F0, xSpd, ySpd
.ENDM
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
.MACRO CLEARTEXT    ; MS
    .DB $F7
.ENDM
.MACRO BLANKING     ; JR
    .DB $F7, $01
.ENDM
.MACRO CLEARNUM     ; MS
    .DB $F8
.ENDM
.MACRO CUT_NOP      ; JR
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
.MACRO SETOVERRIDE ARGS val
    .DB $FD, val
.ENDM
.MACRO SETHIGHX ARGS, val
    .DB $FE, val
.ENDM
.MACRO SETIDX ARGS, val
    .DB $FE, val
.ENDM
.MACRO CUTEND
    .DB $FF
.ENDM


;   MS PAC-MAN SCENE 0 POINTERS
msScene0ProgTable:
    .DW msScene0Prog0
    .DW msScene0Prog1
    .DW msScene0Prog2
    .DW msScene0Prog3
    .DW msScene0Prog4
    .DW msScene0Prog5
    .DW cutsceneEnd
    .DW cutsceneEnd
    ; OTTO
ottoScene0ProgTable:
    .DW ottoScene0Prog0
    .DW msScene0Prog1
    .DW ottoScene0Prog2
    .DW msScene0Prog3
    .DW msScene0Prog4
    .DW msScene0Prog5
    .DW cutsceneEnd
    .DW cutsceneEnd


;   MS PAC-MAN SCENE 1 POINTERS
msScene1ProgTable:
    .DW msScene1Prog0
    .DW msScene1Prog1
    .DW msScene1Prog2
    .DW msScene1Prog3
    .DW msScene1Prog4
    .DW msScene1Prog5
    .DW cutsceneEnd
    .DW cutsceneEnd


;   MS PAC-MAN SCENE 2 POINTERS
msScene2ProgTable:
    .DW msScene2Prog0
    .DW msScene2Prog1
    .DW msScene2Prog2
    .DW msScene2Prog3
    .DW msScene2Prog4
    .DW msScene2Prog5
    .DW cutsceneEnd
    .DW cutsceneEnd


;   JR PAC-MAN ATTRACT MODE POINTERS
jrAttractProgTable:
    .DW jrAttractProg0
    .DW jrAttractProg2
    .DW jrAttractProg1
    .DW jrAttractProg3
    .DW jrAttractProg4
    .DW jrAttractProg5
    .DW jrAttractProg6
    .DW cutsceneEnd


;   JR PAC-MAN SCENE 0 POINTERS
jrScene0ProgTable:
    .DW jrScene0Prog0
    .DW jrScene0Prog1
    .DW jrScene0Prog2
    .DW jrScene0Prog3
    .DW cutsceneEnd
    .DW cutsceneEnd
    .DW cutsceneEnd
    .DW cutsceneEnd


;   JR PAC-MAN SCENE 1 POINTERS
jrScene1ProgTable:
    .DW jrScene1Prog0
    .DW jrScene1Prog1
    .DW jrScene1Prog2
    .DW jrScene1Prog3
    .DW jrScene1Prog4
    .DW jrScene1Prog5
    .DW cutsceneEnd
    .DW cutsceneEnd


;   JR PAC-MAN SCENE 2 POINTERS
jrScene2ProgTable:
    .DW jrScene2Prog0
    .DW jrScene2Prog1
    .DW jrScene2Prog2
    .DW jrScene2Prog3
    .DW jrScene2Prog4
    .DW jrScene2Prog5
    .DW jrScene2Prog6
    .DW cutsceneEnd