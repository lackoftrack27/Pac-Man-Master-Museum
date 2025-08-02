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
ghostBrokenTileDefs:
    .DB $C6 $D2 $C7 $D3
@observe:
    .DB $C8 $D2 $C9 $D3


ghostStitchedTileDefs:
@frame0:
    .DB $C0 $CA $C1 $CB
@frame1:
    .DB $C0 $CC $C1 $CD


ghostNakedTileDefs:
@frame0:
    .DB $C2 $CE $C3 $CF
@frame1:
    .DB $C4 $D0 $C5 $D1


ghostClothTileDefs:
@frame0:
    .DB $D4 $D5 ; 2H SPRITE
@frame1:
    .DB $D6 $D7 ; 2H SPRITE


/*
----------------------------------------------
        CUTSCENE MODE DATA FOR MS.PAC-MAN
----------------------------------------------
*/

;   --------------
;   SCENE TITLE AND NUMBER TILE LISTS
;   --------------
;   ALL HIGH BYTES ARE $08
msScene0Title:
    .DB $E0 $E1 $E2 $E3 $E4 $E5 $E6 $E7
msScene0Num:
    .DB $F3

msScene1Title:
    .DB $E0 $E1 $E8 $E9 $EA $EB $EC $ED
msScene1Num:
    .DB $F4

msScene2Title:
    .DB $EE $EF $F0 $F1 $F2 $00 $00 $00
msScene2Num:
    .DB $F5


;   --------------
;   MACROS FOR TILE LISTS
;   --------------
.MACRO msScenePacDefs   ARGS, VAL
    .db VAL+$07, VAL+$16, VAL+$08, VAL+$17  ; RIGHT HALF    [01]
    .db VAL, VAL+$11, $00, $00              ; RIGHT OPEN    [02]
    .db VAL+$0E, VAL+$16, VAL+$0A, VAL+$17  ; RIGHT CLOSED  [03]
    .db VAL+$0B, VAL+$19, VAL+$04, VAL+$13  ; LEFT HALF     [04]
    .db VAL+$03, VAL+$12, VAL+$04, VAL+$13  ; LEFT OPEN     [05]
    .db VAL+$0F, VAL+$19, VAL+$04, VAL+$13  ; LEFT CLOSED   [06...]
    .db VAL+$0C, VAL+$14, VAL+$0D, VAL+$15  ; UP HALF       [06]
    .db VAL+$05, VAL+$14, VAL+$06, VAL+$15  ; UP OPEN       [07]
    .db VAL+$10, VAL+$14, VAL+$0D, VAL+$15  ; UP CLOSED     [09...]
.ENDM

.MACRO msSceneMsPacDefs ARGS, VAL
    .DB VAL+$08, VAL+$1E, VAL+$09, VAL+$1F  ; RIGHT HALF    [08]
    .DB VAL+$00, VAL+$16, VAL+$01, VAL+$17  ; RIGHT OPEN    [09]
    .DB VAL+$0F, VAL+$1E, VAL+$10, VAL+$23  ; RIGHT CLOSED  [0A]
    .DB VAL+$0C, VAL+$22, VAL+$05, VAL+$1B  ; LEFT HALF     [0B]
    .DB VAL+$04, VAL+$1A, VAL+$05, VAL+$1B  ; LEFT OPEN     [0C]
    .DB VAL+$13, VAL+$25, VAL+$05, VAL+$1B  ; LEFT CLOSED   [0D]
    .DB VAL+$0D, VAL+$1C, VAL+$0E, VAL+$1D  ; UP HALF       [0E]
    .DB VAL+$06, VAL+$1C, VAL+$07, VAL+$1D  ; UP OPEN       [0F]
    .DB VAL+$14, VAL+$1C, VAL+$15, VAL+$1D  ; UP CLOSED     [10]
.ENDM

.MACRO msSceneGhostDefs ARGS, VAL
    .DB VAL, VAL+$08, VAL+$01, VAL+$09      ; RIGHT 0       [11 / 15]
    .DB VAL, VAL+$0A, VAL+$01, VAL+$0B      ; RIGHT 1       [12 / 16]
    .DB VAL+$04, VAL+$08, VAL+$05, VAL+$09  ; LEFT 0        [13 / 17]
    .DB VAL+$04, VAL+$0A, VAL+$05, VAL+$0B  ; LEFT 1        [14 / 18]
.ENDM


;   --------------
;   TILE LISTS FOR CUTSCENE SPRITES
;   --------------
msSceneCharTable:
    .DB $00 $00 $00 $00 ; EMPTY SPRITE          [00]
    msScenePacDefs      (MS_CUT_PAC_VRAM / TILE_SIZE)
    msSceneMsPacDefs    (PAC_VRAM / TILE_SIZE)
    msSceneGhostDefs    (GHOST_VRAM / TILE_SIZE) + $0C
    msSceneGhostDefs    (GHOST_VRAM / TILE_SIZE) + $18
    .DB $CD $D6 $CE $D7 ; ACT SIGN CLACKER H 0  [19]
    .DB $CF $00 $00 $00 ; ACT SIGN CLACKER H 1  [1A]
    .DB $D3 $DB $D4 $DC ; ACT SIGN CLACKER M 0  [1B]
    .DB $D5 $00 $00 $00 ; ACT SIGN CLACKER M 1  [1C]
    .DB $00 $DD $00 $DE ; ACT SIGN CLACKER L 0  [1D]
    .DB $00 $DF $00 $00 ; ACT SIGN CLACKER L 1  [1E]
    .DB $D0 $D8 $D1 $D9 ; ACT SIGN 0            [1F]
    .DB $D2 $DA $00 $00 ; ACT SIGN 1            [20]
    .DB $C0 $C9 $C1 $CA ; HEART                 [21]
    .DB $C2 $00 $00 $00 ; STORK HEAD            [22]
    .DB $C3 $00 $C4 $00 ; STORK FLAP 0          [23]
    .DB $C5 $CB $C6 $CC ; STORK FLAP 1          [24]
    .DB $C7 $00 $00 $00 ; STORK SACK            [25]
    .DB $C8 $00 $00 $00 ; JR PAC                [26]
    


;   --------------
;   SPRITE LISTS FOR SCENE CHARACTERS (REFERENCES PREVIOUS TABLE)
;   --------------
msSceneCharacters:
@emptySpr:
    .DB $00 $FF
@pacRight:
    .DB $01 $01 $02 $02 $01 $01 $03 $03 $FF
@pacLeft:
    .DB $04 $04 $05 $05 $04 $04 $06 $06 $FF
@pacUp:
    .DB $07 $07 $08 $08 $07 $07 $09 $09 $FF
@msPacRight:
    .DB $0A $0A $0B $0B $0A $0A $0C $0C $FF
@msPacLeft:
    .DB $0D $0D $0E $0E $0D $0D $0F $0F $FF
@msPacUp:
    .DB $10 $10 $11 $11 $10 $10 $12 $12 $FF
@pinkyRight:
    .DB $13 $13 $14 $14 $13 $13 $FF
@pinkyLeft:
    .DB $15 $15 $16 $16 $15 $15 $FF
@inkyRight:
    .DB $17 $17 $18 $18 $17 $17 $FF
@inkyLeft:
    .DB $19 $19 $1A $1A $19 $19 $FF
@actClacker0:
    .DB $1B $1B $1B $1D $1D $1D $1F $1F $1F $FF
@actClacker1:
    .DB $1C $1C $1C $1E $1E $1E $20 $20 $20 $FF
@actSign0:
    .DB $21 $FF
@actSign1:
    .DB $22 $FF
@heart:
    .DB $23 $FF
@storkHead:
    .DB $24 $FF
@storkBody:
    .DB $25 $25 $25 $25 $26 $26 $26 $26 $FF
@storkSack:
    .DB $27 $FF
@jrPac:
    .DB $28 $FF


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
