; ----------------------------------------------
;         ATTRACT MODE DATA [TITLE SCREEN]
; ----------------------------------------------

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


; ----------------------------------------------
;         ATTRACT MODE DATA [OPTIONS]
; ----------------------------------------------

;   ALL UPPER BYTES ARE $01 (UPPER 256 TILES)

;   TILE LISTS FOR OPTIONS TEXT
optionLivesText:
    .DB $01, $02, $03, $04, $05, $00, $00, $00, $00, $00
optionDiffText:
    .DB $07, $02, $08, $08, $02, $09, $0A, $01, $0B, $0C
optionBonusText:
    .DB $12, $0E, $0D, $0A, $05, $00, $00, $00, $00, $00
optionGhostText:
    .DB $EC, $EA, $0E, $05, $0B, $00, $0D, $11, $10, $04, $05
optionSpeedText:
    .DB $05, $16, $04, $04, $07, $00, $00, $00, $00, $00
optionStyleText:
    .DB $05, $0B, $0C, $01, $04, $00, $00, $00, $00, $00
optionSndText:
    .DB $05, $0E, $0A, $0D, $07, $00, $0B, $04, $05, $0B
optionHelpText:
    .DB $00, $16, $0F, $04, $05, $05, $00, $12, $0A, $0B, $0B, $0E, $0D, $00, $13, $00, $0B, $0E, $00, $04, $18, $02, $0B


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
    .DB $00 $0E $08 $08 $00 $00 ; OFF (PAC/MS.PAC)
    .DB $00 $06 $14 $15 $00 $00 ; 30K (JR.PAC)
@ghostNames:
    .DB $00, $00, $0A, $05, $00, $00    ; US
    .DB $00, $00, $A5, $16, $00, $00    ; JP
    .DB $A5, $16, $00, $11, $01, $0B    ; JP ALT
    .DB $0A, $05, $00, $11, $01, $0B    ; US ALT
@speed:
    .DB $0D $0E $0F $10 $11 $01 ; NORMAL
    .DB $00 $08 $11 $05 $0B $00 ; FAST
@style:
    .DB $05 $10 $0E $0E $0B $17 ; SMOOTH
    .DB $11 $0F $09 $11 $07 $04 ; ARCADE


; ----------------------------------------------
;             ATTRACT MODE DATA [PAC-MAN]
; ----------------------------------------------

;   GHOST 0
introTextTable00:
    .dw introShadowText
    .dw introOikakeText
    .dw introUrchinText
    .dw introDummy0Text
    .dw introMadDogText

introTextTable01:
    .dw introBlinkyText
    .dw introAkabeiText
    .dw introMackyText
    .dw introDummy1Text
    .dw introPlatoText

;   GHOST 1
introTextTable02:
    .dw introSpeedyText
    .dw introMachibuseText
    .dw introRompText
    .dw introDummy2Text
    .dw introKillerText

introTextTable03:
    .dw introPinkyText
    .dw introPinkyJPText
    .dw introMickyText
    .dw introDummy3Text
    .dw introDarwinText

;   GHOST 2
introTextTable04:
    .dw introBashfulText
    .dw introKimagureText
    .dw introStylistText
    .dw introDummy4Text
    .dw introBruteText

introTextTable05:
    .dw introInkyText
    .dw introAosukeText
    .dw introMuckyText
    .dw introDummy5Text
    .dw introFreudText

;   GHOST 3
introTextTable06:
    .dw introPokeyText
    .dw introOtobokeText
    .dw introCrybabyText
    .dw introDummy6Text
    .dw introSamText

introTextTable07:
    .dw introPokeyText@row1
    .dw introOtobokeText@row1
    .dw introCrybabyText@row1
    .dw introDummy6Text@row1
    .dw introSamText@row1

introTextTable08:
    .dw introClydeText
    .dw introGuzutaText
    .dw introMockyText
    .dw introDummy7Text
    .dw introNewtonText

introTextTable09:
    .dw introClydeText@row1
    .dw introGuzutaText@row1
    .dw introMockyText@row1
    .dw introDummy7Text@row1
    .dw introNewtonText@row1


;   ALL UPPER BYTES ARE $09 (UPPER 256 TILES)

;   --------------------------------------
;               [COMMON]
;   --------------------------------------

;   CHARACTER / NICKNAME        @ [07, 01]      16
introNicknameText:
    .dw $08F8 $08F9 $08FA $08FB $08FC $08FD $08FE $08FF
    .dw $0900 $0901 $0902 $0903 $0904 $0905 $0906 $0907

;   POINTS                      @ [09, 15]      7
introPointsText:
@row0:
    .DW $0838 $0838 $090A $090B $090C $090D $090E
@row1:
    .DW $010F $0838 $0910 $0911 $0912 $0913 $0914
@row2:
    .DW $0115 $0116 $0917 $0918 $0919 $091A $091B

;   NAMCO                       @ [09, $15]     7
introNamcoText:
    .DB $2E $2F $30 $31 $32 $33 $34

;   @ BALLY MIDWAY 1980,1982    @ [03, $15]     19
introBallyMidway:
    .DB $1C $1D $1E $1F $20 $21 $22 $23 $24 $25 $26 $E9 $27 $28 $29 $2A $2B $2C $2D

;   POWER DOT                   @ [05, $0C]     1 (BG PAL)
introPowDot:
@row0:
    .DB $08
@row1:
    .DB $09

;   GENCOMP                     @ [09, $15]     7
introGencompText:
    .DB $35 $36 $37 $38 $39 $3A $3B


;   --------------------------------------
;           GHOST NAMES [US]
;   --------------------------------------

.FUNCTION xyToNameTbl_M(x, y) (NAMETABLE + ((y * $20 + x) * $02)) | VRAMWRITE


;   -SHADOW
introShadowText:
    .dw xyToNameTbl_M($07, $03)
    .db $06
    .DB $3C $3D $3E $3F $40 $41

;   "BLINKY"
introBlinkyText:
    .dw xyToNameTbl_M($0F, $03)
    .db $07
    .DB $42 $43 $44 $45 $46 $47 $48

;   -SPEEDY
introSpeedyText:
    .dw xyToNameTbl_M($07, $05)
    .db $06
    .DB $49 $4A $4B $4C $4D $4E

;   "PINKY"
introPinkyText:
    .dw xyToNameTbl_M($0F, $05)
    .db $06
    .DB $4F $50 $51 $52 $53 $54

;   -BASHFUL
introBashfulText:
    .dw xyToNameTbl_M($07, $07)
    .db $07
    .DB $55 $56 $57 $58 $59 $5A $5B

;   "INKY"
introInkyText:
    .dw xyToNameTbl_M($0F, $07)
    .db $05
    .DB $5C $5D $5E $5F $60 

;   -POKEY
introPokeyText:
    .dw xyToNameTbl_M($08, $09)
    .db $04
    .DB $61 $62 $63 $64
@row1:
    .dw xyToNameTbl_M($07, $0A)
    .db $05
    .DB $6A $6B $6C $6D $6E

;   "CLYDE"
introClydeText:
    .dw xyToNameTbl_M($0F, $09)
    .db $06
    .DB $65 $66 $67 $68 $69 $64
@row1:
    .dw xyToNameTbl_M($0F, $0A)
    .db $06
    .DB $6F $70 $71 $72 $73 $74

;   --------------------------------------
;           GHOST NAMES [JP]
;   --------------------------------------

introOikakeText:
    .dw xyToNameTbl_M($08, $03)
    .db $08
    .DB $75 $76 $77 $78 $79 $7A $7B $7C

introAkabeiText:
    .dw xyToNameTbl_M($0F, $03)
    .db $07
    .DB $7D $7E $7F $80 $81 $82 $48

introMachibuseText:
    .dw xyToNameTbl_M($08, $05)
    .db $09
    .DB $83 $84 $85 $51 $86 $87 $88 $89 $8A

introPinkyJPText:
    .dw xyToNameTbl_M($10, $05)
    .db $06
    .DB $8B $8C $8D $8E $8F $90

introKimagureText:
    .dw xyToNameTbl_M($08, $07)
    .db $08
    .DB $91 $92 $93 $94 $95 $96 $97 $98

introAosukeText:
    .dw xyToNameTbl_M($0F, $07)
    .db $07
    .DB $99 $9A $9B $9C $9D $9E $9F 

introOtobokeText:
    .dw xyToNameTbl_M($08, $09)
    .db $06
    .DB $A0 $A1 $A2 $A3 $A4 $A5
@row1:
    .dw xyToNameTbl_M($08, $0A)
    .db $08
    .DB $AB $AC $AD $AE $AF $B0 $B1 $B2

introGuzutaText:
    .dw xyToNameTbl_M($0F, $09)
    .db $07
    .DB $65 $A6 $A7 $A8 $A9 $A3 $AA
@row1:
    .dw xyToNameTbl_M($0F, $0A)
    .db $07
    .DB $B3 $B4 $B5 $B6 $B7 $B8 $B9

;   --------------------------------------
;           GHOST NAMES [JP ALT]
;   --------------------------------------

introUrchinText:
    .dw xyToNameTbl_M($08, $03)
    .db $09
    .DB $3C $3D $3E $3F $40 $41 $42 $43 $44

introMackyText:
    .dw xyToNameTbl_M($10, $03)
    .db $06
    .DB $45 $46 $47 $48 $49 $4A

introRompText:
    .dw xyToNameTbl_M($08, $05)
    .db $09
    .DB $4B $4C $4D $4E $4F $50 $4E $4F $51

introMickyText:
    .dw xyToNameTbl_M($10, $05)
    .db $06
    .DB $52 $53 $54 $55 $56 $57

introStylistText:
    .dw xyToNameTbl_M($08, $07)
    .db $09
    .DB $58 $59 $5A $5B $5C $5D $5E $5F $60

introMuckyText:
    .dw xyToNameTbl_M($10, $07)
    .db $06
    .DB $61 $62 $63 $64 $65 $66

introCrybabyText:
    .dw xyToNameTbl_M($08, $09)
    .db $06
    .DB $67 $68 $69 $67 $68 $6A
@row1:
    .dw xyToNameTbl_M($08, $0A)
    .db $09
    .DB $71 $72 $73 $74 $75 $76 $77 $78 $79

introMockyText:
    .dw xyToNameTbl_M($10, $09)
    .db $06
    .DB $6B $6C $6D $6E $6F $70
@row1:
    .dw xyToNameTbl_M($10, $0A)
    .db $06
    .DB $7A $7B $7C $7D $7E $7F
    

;   --------------------------------------
;           GHOST NAMES [US ALT]
;   --------------------------------------

introDummy0Text:
    .dw xyToNameTbl_M($07, $03)
    .db $08
    .DB $80 $81 $82 $83 $81 $82 $83 $42

introDummy1Text:
    .dw xyToNameTbl_M($0F, $03)
    .db $08
    .DB $84 $85 $86 $87 $88 $86 $89 $8A

introDummy2Text:
    .dw xyToNameTbl_M($07, $05)
    .db $08
    .DB $8B $8C $8D $8E $8C $8D $8E $4E

introDummy3Text:
    .dw xyToNameTbl_M($0F, $05)
    .db $08
    .DB $8F $90 $91 $92 $93 $91 $94 $95

introDummy4Text:
    .dw xyToNameTbl_M($07, $07)
    .db $08
    .DB $96 $97 $98 $99 $97 $98 $99 $5E

introDummy5Text:
    .dw xyToNameTbl_M($0F, $07)
    .db $08
    .DB $9A $9B $9C $9D $9E $9C $9F $A0

introDummy6Text:
    .dw xyToNameTbl_M($08, $09)
    .db $06
    .DB $A1 $A2 $A3 $A1 $A2 $A3
@row1:
    .dw xyToNameTbl_M($07, $0A)
    .db $08
    .DB $A7 $A8 $A9 $AA $A8 $A9 $AA $77
    
introDummy7Text:
    .dw xyToNameTbl_M($0F, $09)
    .db $08
    .DB $A4 $A5 $6F $A6 $A5 $6F $A6 $6A
@row1:
    .dw xyToNameTbl_M($0F, $0A)
    .db $08
    .DB $AB $AC $74 $AD $AE $74 $AF $B0


;   --------------------------------------
;           GHOST NAMES [OTTO]
;   --------------------------------------

;   -MAD DOG
introMadDogText:
    .dw xyToNameTbl_M($07, $03)
    .db $07
    .DB $3C $BA $BB $BC $BD $BE $BF

;   "PLATO"
introPlatoText:
    .dw xyToNameTbl_M($0F, $03)
    .db $06
    .DB $42 $C0 $C1 $C2 $C3 $C4

;   -KILLER
introKillerText:
    .dw xyToNameTbl_M($07, $05)
    .db $06
    .DB $49 $C5 $C6 $C7 $C8 $C9

;   "DARWIN"
introDarwinText:
    .dw xyToNameTbl_M($0F, $05)
    .db $07
    .DB $4F $CA $CB $CC $CD $CE $90

;   -BRUTE
introBruteText:
    .dw xyToNameTbl_M($07, $07)
    .db $05
    .DB $55 $CF $D0 $D1 $D2

;   "FREUD"
introFreudText:
    .dw xyToNameTbl_M($0F, $07)
    .db $06
    .DB $5C $D3 $D4 $D5 $D6 $D7

;   -SAM
introSamText:
    .dw xyToNameTbl_M($08, $09)
    .db $03
    .DB $D8 $D9 $DA
@row1:
    .dw xyToNameTbl_M($07, $0A)
    .db $04
    .DB $6A $E0 $E1 $E2

;   "NEWTON"
introNewtonText:
    .dw xyToNameTbl_M($0F, $09)
    .db $07
    .DB $65 $DB $DC $DD $DE $DF $AA
@row1:
    .dw xyToNameTbl_M($0F, $0A)
    .db $07
    .DB $6F $E3 $E4 $E5 $E6 $E7 $B9


; ----------------------------------------------
;         ATTRACT MODE DATA [MS. PAC-MAN]
; ----------------------------------------------

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



; ----------------------------------------------
;         ATTRACT MODE DATA [JR. PAC-MAN]
; ----------------------------------------------


jrIntroBlinkyTxt:   ; 21, 13        9
    .DB $9F $A0 $A1 $A2 $A3 $A4 $A5 $A6 $A7

jrIntroPinkyTxt:    ; 24, 13        5
    .DB $A8 $A9 $AA $AB $AC

jrIntroInkyTxt:     ; 25, 13        3
    .DB $AD $AE $AF

jrIntroTimTxt:      ; 25, 13        2
    .DB $B0 $B1