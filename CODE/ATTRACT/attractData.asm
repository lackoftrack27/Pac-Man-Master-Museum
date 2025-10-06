/*
----------------------------------------------
        ATTRACT MODE DATA [TITLE SCREEN]
----------------------------------------------
*/
;   SPRITE INDEX
titleArrowTable:
    .DB $01 + (SPRITE_ADDR / TILE_SIZE), $02 + (SPRITE_ADDR / TILE_SIZE)


titleCharTblSmooth:
;   PAC-MAN SMOOTH [00] 00
    .DW pacSNTileTbl@titlePtr        ; HALF
    .DW pacSNTileTbl@titlePtr + $08  ; OPEN
    .DW pacSNTileTbl@titlePtr        ; HALF
    .DW pacSNTileTbl@titlePtr + $18  ; CLOSED
;   MS.PAC-MAN SMOOTH [08] 02
    .DW msSNTileTbl@titlePtr + $08  ; HALF
    .DW msSNTileTbl@titlePtr        ; OPEN
    .DW msSNTileTbl@titlePtr + $08  ; HALF
    .DW msSNTileTbl@titlePtr + $10  ; CLOSED
;   JR.PAC-MAN SMOOTH [10] 04
    .DW jrSNTileTbl@titlePtr + $08  ; HALF
    .DW jrSNTileTbl@titlePtr        ; OPEN
    .DW jrSNTileTbl@titlePtr + $08  ; HALF
    .DW jrSNTileTbl@titlePtr + $10  ; CLOSED
;   CRAZY OTTO SMOOTH [18] 0A
    .DW ottoSNTileTbl@titlePtr + $10    ; CLOSED
    .DW ottoSNTileTbl@titlePtr + $08    ; HALF 0
    .DW ottoSNTileTbl@titlePtr          ; OPEN
    .DW ottoSNTileTbl@titlePtr + $18    ; HALF 1

titleCharTblArcade:
;   PAC-MAN ARCADE [00] 00
    .DW pacANTileTbl@titlePtr        ; HALF
    .DW pacANTileTbl@titlePtr + $08  ; OPEN
    .DW pacANTileTbl@titlePtr        ; HALF
    .DW pacANTileTbl@titlePtr + $18  ; CLOSED
;   MS.PAC-MAN ARCADE [08] 02
    .DW msANTileTbl@titlePtr + $08  ; HALF
    .DW msANTileTbl@titlePtr        ; OPEN
    .DW msANTileTbl@titlePtr + $08  ; HALF
    .DW msANTileTbl@titlePtr + $10  ; CLOSED
;   JR.PAC-MAN ARCADE [10] 04
    .DW jrANTileTbl@titlePtr + $08  ; HALF
    .DW jrANTileTbl@titlePtr        ; OPEN
    .DW jrANTileTbl@titlePtr + $08  ; HALF
    .DW jrANTileTbl@titlePtr + $10  ; CLOSED
;   CRAZY OTTO ARCADE [18] 0A
    .DW ottoANTileTbl@titlePtr + $10    ; CLOSED
    .DW ottoANTileTbl@titlePtr + $08    ; HALF 0
    .DW ottoANTileTbl@titlePtr          ; OPEN
    .DW ottoANTileTbl@titlePtr + $18    ; HALF 1

/*
----------------------------------------------
        ATTRACT MODE DATA [OPTIONS]
----------------------------------------------
*/
;   ALL UPPER BYTES ARE $01 (UPPER 256 TILES)

;   TILE LISTS FOR OPTIONS TEXT
optionLivesText:
    .DB $01 $02 $03 $04 $05 $00 $00 $00 $00 $00
optionDiffText:
    .DB $07 $02 $08 $08 $02 $09 $0A $01 $0B $0C
optionBonusText:
    .DB $12 $0E $0D $0A $05 $00 $00 $00 $00 $00
optionSpeedText:
    .DB $05 $16 $04 $04 $07 $00 $00 $00 $00 $00
optionStyleText:
    .DB $05 $0B $0C $01 $04 $00 $00 $00 $00 $00
optionSndText:
    .DB $05 $0E $0A $0D $07 $00 $0B $04 $05 $0B
optionHelpText:
    .DB $00 $16 $0F $04 $05 $05 $00 $12 $0A $0B $0B $0E $0D $00 $13 $00 $0B $0E $00 $04 $18 $02 $0B


;   TILE LISTS FOR OPTION VALUES
optionTileMaps:
@lives:
    .DB $00 $00 $13 $00 $00 $00 ; 1
    .DB $00 $00 $19 $00 $00 $00 ; 2
    .DB $00 $00 $06 $00 $00 $00 ; 3
    .DB $00 $00 $1A $00 $00 $00 ; 5
@diff:
    .DB $0D $0E $0F $10 $11 $01 ; NORMAL
    .DB $00 $17 $11 $0F $07 $00 ; HARD
@bonus:
    .DB $00 $13 $14 $15 $00 $00 ; 10K
    .DB $00 $13 $1A $15 $00 $00 ; 15K
    .DB $00 $19 $14 $15 $00 $00 ; 20K
    .DB $00 $0E $08 $08 $00 $00 ; OFF
@speed:
    .DB $0D $0E $0F $10 $11 $01 ; NORMAL
    .DB $00 $08 $11 $05 $0B $00 ; FAST
@style:
    .DB $05 $10 $0E $0E $0B $17 ; SMOOTH
    .DB $11 $0F $09 $11 $07 $04 ; ARCADE

/*
----------------------------------------------
            ATTRACT MODE DATA [PAC-MAN]
----------------------------------------------
*/
;   ALL UPPER BYTES ARE $09 (UPPER 256 TILES)

;   CHARACTER / NICKNAME        @ [07, 01]      16
introNicknameText:
    .DB $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10

;   -SHADOW                     @ [07, 03]      7
introShadowText:
    .DB $11 $12 $13 $14 $15 $16 $00

;   "BLINKY"                    @ [15, 03]      7
introBlinkyText:
    .DB $17 $18 $19 $1A $1B $1C $1D

;   -SPEEDY                     @ [07, 05]      6
introSpeedyText:
    .DB $1E $1F $20 $21 $22 $23

;   "PINKY"                     @ [15, 05]      7
introPinkyText:
    .DB $24 $25 $26 $27 $28 $29 $00

;   -BASHFUL                    @ [07, 07]      7
introBashfulText:
    .DB $2A $2B $2C $2D $2E $2F $30

;   "INKY"                      @ [15, 07]      6
introInkyText:
    .DB $31 $32 $33 $34 $35 $00 

;   -POKEY                      @ [07, 09]      5
introPokeyText:
@row0:
    .DB $00 $36 $37 $38 $39
@row1:
    .DB $3F $40 $41 $42 $43

;   "CLYDE"                     @ [15, 09]      7
introClydeText:
@row0:
    .DB $3A $3B $3C $3D $3E $39 $00
@row1:
    .DB $44 $45 $46 $47 $48 $49 $00

;   POINTS                      @ [09, 15]      7
introPointsText:
@row0:
    .DW $0900 $0900 $094C $094D $094E $094F $0950
@row1:
    .DW $0151 $0900 $0952 $0953 $0954 $0955 $0956
@row2:
    .DW $0157 $0158 $0959 $095A $095B $095C $095D

;   NAMCO                       @ [09, $15]     7
introNamcoText:
    .DB $5E $5F $60 $61 $62 $63 $64


;   @ BALLY MIDWAY 1980,1982    @ [03, $15]     19
introBallyMidway:
    .DB $65 $66 $67 $68 $69 $6A $6B $6C $6D $6E $6F $00 $70 $71 $72 $73 $74 $75 $76


;   POWER DOT                   @ [05, $0C]     1 (BG PAL)
introPowDot:
@row0:
    .DB $4A
@row1:
    .DB $4B

;
;   CRAZY OTTO (SUBSET OF PAC-MAN'S ATTRACT)
;

;   -MAD DOG                    @ [07, 03]      7
introMadDogText:
    .DB $78 $79 $7A $7B $7C $7D $7E

;   "PLATO"                     @ [15, 03]      7
introPlatoText:
    .DB $7F $80 $81 $82 $83 $84 $00

;   -KILLER                     @ [07, 05]      6
introKillerText:
    .DB $85 $86 $87 $88 $89 $8A

;   "DARWIN"                    @ [15, 05]      7
introDarwinText:
    .DB $8B $8C $8D $8E $8F $90 $91

;   -BRUTE                      @ [07, 07]      7
introBruteText:
    .DB $92 $93 $94 $95 $96 $00 $00

;   "FREUD"                     @ [15, 07]      6
introFreudText:
    .DB $97 $98 $99 $9A $9B $9C     

;   -SAM                        @ [07, 09]      5
introSamText:
@row0:
    .DB $00 $9D $9E $9F $00
@row1:
    .DB $A7 $A8 $A9 $AA $00

;   "NEWTON"                    @ [15, 09]      7
introNewtonText:
@row0:
    .DB $A0 $A1 $A2 $A3 $A4 $A5 $A6
@row1:
    .DB $AB $AC $AD $AE $AF $B0 $B1

;   GENCOMP                     @ [09, $15]     7
introGencompText:
    .DB $B2 $B3 $B4 $B5 $B6 $B7 $B8

/*
----------------------------------------------
        ATTRACT MODE DATA [MS. PAC-MAN]
----------------------------------------------
*/
;   INITIAL PALLETE FOR MARQUEE
marqueePalStart:
    .DB $3F $03 $03 $03 $03 $03 $03 $03 $03 $03 $15 $2A


;   ALL UPPER BYTES ARE $09 (UPPER 256 TILES, SPRITE PAL)

;   "MS PAC-MAN"                @ [$09, $03]    $0A
msIntroPacTextOrg:
    .DB $01 $02 $03 $04 $05 $06 $07 $08 $09 $0A

;   "MS PAC-PLUS"               @ [$09, $03]    $0B
msIntroPacTextOrgPlus:
    .DB $01 $02 $03 $04 $05 $06 $68 $69 $6A $6B $6C

;   WITH                        @ [$09, $07]    $04
msIntroWithText:
    .DB $0B $0C $0D $0E

;   BLINKY                      @ [$0B, $09]    $06
msIntroBlinkyText:
@row0:
    .DB $0F $10 $11 $12 $13 $14
@row1:
    .DB $15 $16 $17 $18 $19 $1A

;   PINKY                       @ [$0B, $09]    $06
msIntroPinkyText:
@row0:
    .DB $1B $1C $1D $1E $1F $00
@row1:
    .DB $20 $21 $22 $23 $24 $00

;   INKY                        @ [$0B, $09]    $06
msIntroInkyText:
@row0:
    .DB $00 $25 $26 $27 $00 $00
@row1:
    .DB $00 $28 $29 $2A $00 $00

;   SUE                         @ [$0B, $09]    $06
msIntroSueText:
@row0:
    .DB $00 $2B $2C $2D $00 $00
@row1:
    .DB $00 $2E $2F $30 $00 $00

;   STARRING                    @ [$09, $07]    $07
msIntroStarText:
    .DB $31 $32 $33 $34 $35 $36 $37

;   MS. PAC-MAN                 @ [$09, $09]    $08
msIntroPacTextYel:
@row0:
    .DB $38 $39 $3A $3B $3C $3A $3D $3E
@row1:
    .DB $3F $40 $41 $42 $43 $44 $45 $46

;   LOGO                        @ [$06, $12]    $04
msIntroMidLogo:
@row0:
    .DB $00 $47 $48 $49
@row1:
    .DB $00 $4A $4B $4C


;   @ MIDWAY MFG CO             @ [$0A, $13]    $0C
msIntroCpy:
    .DB $54 $55 $56 $57 $58 $59 $5A $5B $5C $5D $5E $5F


msIntroMidLogo@row2:
    .DB $4D $4E $4F $50
msIntroMidLogo@row3:
    .DB $51 $52 $53 $00



;   1980/1981                   @ [$0C, $15]    $08
msIntroYear:
    .DB $60 $61 $62 $63 $64 $65 $66 $67


;   MARQUEE USES BACKGROUND PALETTE

;   MARQUEE                     @ [$07, $06]    $0E
msIntroMarquee:
    .DB $6E $6F $70 $71 $72 $73 $74 $75 $76 $77 $6F $70 $71 $78
    .DB $79 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $7B
    .DB $7C $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $7D
    .DB $7E $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $7F
    .DB $80 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $00 $81
    .DB $82 $83 $84 $85 $86 $87 $88 $89 $8A $8B $83 $84 $85 $8C


/*
----------------------------------------------
        ATTRACT MODE DATA [JR. PAC-MAN]
----------------------------------------------
*/

jrIntroBlinkyTxt:   ; 21, 13        9
    .DB $C0 $C1 $C2 $C3 $C4 $C5 $C6 $C7 $C8

jrIntroPinkyTxt:    ; 24, 13        5
    .DB $CA $CB $CC $CD $CE

jrIntroInkyTxt:     ; 25, 13        3
    .DB $CF $D0 $D1

jrIntroTimTxt:      ; 25, 13        2
    .DB $D2 $D3