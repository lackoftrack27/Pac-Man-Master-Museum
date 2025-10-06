/*
-----------------------------------------------------------
                    MACROS AND ENUMS
-----------------------------------------------------------
*/
;   UNUSED, CHANNEL COUNT, TEMPO MULTIPLIER, TEMPO
.MACRO smpsHeader ARGS unused chan mult tempo
    .DW $0000               ; UNUSED
    .DB unused, chan, mult, tempo
.ENDM
;   ABSOLUTE ADDRESS OF CHANNEL DATA, NOTE OFFSET, INITIAL VOLUME, UNUSED, ENVELOPE
.MACRO smpsChanHeader ARGS loc offset vol unused env
    .DW loc
    .DB offset, vol, unused, env
.ENDM
;   CF
.MACRO smpsDetune ARGS data
    .DB $E1, data
.ENDM
.MACRO smpsChangeVol ARGS data
    .DB $EC, data
.ENDM
.MACRO smpsLiteralRead  ARGS data
    .DB $EE, data
.ENDM
.MACRO smpsStop
    .DB $F2
.ENDM
.MACRO smpsSetNoise ARGS data
    .DB $F3, data
.ENDM
.MACRO smpsPSGVoice ARGS data
    .DB $F5, data
.ENDM
.MACRO smpsJump ARGS loc
    .DB $F6
    .DW loc
.ENDM


.MACRO literalWord  ARGS litWord
    .DB hibyte(litWord), lobyte(litWord)
.ENDM


;   NOTE DEFS
.ENUM $80
    nRst    DB
    nC0     DB nCs0   DB nD0   DB nEb0  DB nE0   DB nF0   DB nFs0  DB nG0   DB nGs0  DB nA0    DB nBb0   DB nB0    DB
    nC1     DB nCs1   DB nD1   DB nEb1  DB nE1   DB nF1   DB nFs1  DB nG1   DB nGs1  DB nA1    DB nBb1   DB nB1    DB
    nC2     DB nCs2   DB nD2   DB nEb2  DB nE2   DB nF2   DB nFs2  DB nG2   DB nGs2  DB nA2    DB nBb2   DB nB2    DB
    nC3     DB nCs3   DB nD3   DB nEb3  DB nE3   DB nF3   DB nFs3  DB nG3   DB nGs3  DB nA3    DB nBb3   DB nB3    DB
    nC4     DB nCs4   DB nD4   DB nEb4  DB nE4   DB nF4   DB nFs4  DB nG4   DB nGs4  DB nA4    DB nBb4   DB nB4    DB
    nC5     DB nCs5   DB nD5   DB nEb5  DB nE5   DB nF5   DB nFs5  DB nG5   DB nGs5  DB nA5    DB nBb5   DB nB5    DB
    nC6     DB nCs6   DB nD6   DB nEb6  DB nE6   DB nF6   DB nFs6  DB nG6   DB nGs6  DB nA6    DB nBb6   DB nB6    DB
    nC7     DB nCs7   DB nD7   DB nEb7  DB nE7   DB nF7   DB nFs7  DB nG7   DB nGs7  DB nA7    DB nBb7   DB nB7    DB
.ENDE



/*
-----------------------------------------------------------
                    FREQUENCY TABLE
-----------------------------------------------------------
*/
sndFreqTable:
;         C     C#    D     Eb    E     F     F#    G     G#    A     Bb    B
    .dw $03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03FF,$03DC,$03A5,$0370; Octave 2 - (81 - 8C) 0
    .dw $033F,$0310,$02E4,$02BB,$0293,$026E,$024B,$022A,$020B,$01EE,$01D2,$01B8; Octave 3 - (8D - 98) 1
    .dw $019F,$0188,$0172,$015D,$014A,$0137,$0126,$0115,$0106,$00F7,$00E9,$00DC; Octave 4 - (99 - A4) 2
	.dw $00D0,$00C4,$00B9,$00AF,$00A5,$009C,$0093,$008B,$0083,$007B,$0075,$006E; Octave 5 - (A5 - B0) 3
	.dw $0068,$0062,$005D,$0057,$0052,$004E,$0049,$0045,$0041,$003E,$003A,$0037; Octave 6 - (B1 - BC) 4
    .dw $0034,$0031,$002E,$002C,$0029,$0027,$0025,$0023,$0021,$001F,$001D,$001C; Octave 7 - (BD - C8) 5
    .dw $001A,$0019,$0017,$0016,$0015,$0013,$0012,$0011,$0010,$000F,$000F,$000E; Octave 8 - (C9 - D4) 6
    .dw $000D,$000C,$000C,$000B,$000A,$000A,$0009,$0009,$0008,$0008,$0007,$0007; Octave 9 - (D5 - E0) 7
    .dw $0000								                                   ; Note (E1)



/*
-----------------------------------------------------------
                    SOUND INDEX TABLE
-----------------------------------------------------------
*/
sndIndexTable:
;   SFX
    ; ----
    .DW sfxDot0     ; 81        CH2 EFFECT 0
    .DW sfxDot1     ; 82        CH2 EFFECT 1
    .DW sfxMsDot    ; 83 (+2)   CH2 EFFECT 0
    .DW sfxMsDot    ; 84 (+2)   CH2 EFFECT 1
    .DW sfxJrDot    ; 85 (+4)   CH2 EFFECT 0
    .DW sfxJrBigDot ; 86 (+4)   CH2 EFFECT 1
    ; ----
    .DW sfxFruit    ; 87        CH2 EFFECT 2
    ; ----
    .DW sfxEatGhost ; 88        CH2 EFFECT 3
    .DW sfxDeath    ; 89
    .DW sfxMsEatGhost   ; 8A (+2)   CH2 EFFECT 3
    .DW sfxMsDeath  ; 8B (+2)
    .DW sfxJrEatGhost   ; 8C (+4)
    .DW sfxJrDeath      ; 8D (+4)
    ; ----
    .DW sfxBonus    ; 8E
    ; ----
    .DW sfxSiren0   ; 8F
    .DW sfxMsSiren0 ; 90 (+1)
    .DW sfxJrSiren0 ; 91 (+2)
    .DW sfxSiren1   ; 92
    .DW sfxMsSiren1 ; 93 (+1)
    .DW sfxJrSiren1 ; 94 (+2)
    .DW sfxSiren2   ; 95
    .DW sfxMsSiren2 ; 96 (+1)
    .DW sfxJrSiren2 ; 97 (+2)
    .DW sfxSiren3   ; 98
    .DW sfxMsSiren3 ; 99 (+1)
    .DW sfxJrSiren3 ; 9A (+2)
    .DW sfxSiren4   ; 9B
    .DW sfxMsSiren4 ; 9C (+1)
    .DW sfxJrSiren4 ; 9D (+2)
    .DW sfxFright   ; 9E
    .DW sfxEyes     ; 9F
    .DW sfxMsFright ; A0 (+2)
    .DW sfxMsEyes   ; A1 (+2)
    .DW sfxJrFright ; A2 (+2)
    .DW sfxJrEyes   ; A3 (+2)
    .DW sfxMsBounce ; A4        CH2 EFFECT 4
    .DW sfxCredit   ; A5
;   MUSIC
    .DW musStart    ; A6
    .DW musCoffee   ; A7
    .DW musMsStart  ; A8 (+2)
    .DW musMsInter0 ; A9
    .DW musMsInter1 ; AA
    .DW musMsInter2 ; AB
    .DW musJrStart  ; AC
    .DW musJrInter0 ; AD
    .DW musJrInter1 ; AE
    .DW musJrInter2 ; AF

/*
-----------------------------------------------------------
                        DEFINES
-----------------------------------------------------------
*/

.ENUM $80
    SFX_STOP        DB
;   SFX
    ; ----
    SFX_DOT0        DB
    SFX_DOT1        DB
    SFX_DOT_MS      DW
    SFX_DOT_JR      DB
    SFX_BIGDOT_JR   DB
    ; ----
    SFX_FRUIT       DB
    ; ----
    SFX_EATGHOST    DB
    SFX_DEATH       DB
    SFX_EATGHOST_MS DB
    SFX_DEATH_MS    DB
    SFX_EATGHOST_JR DB
    SFX_DEATH_JR    DB
    ; ----
    SFX_BONUS       DB  ; LOOP 10 TIMES
    ; ----
    SFX_SIREN0      DB  ; LOOP
    SFX_SIREN0_MS   DB  ; LOOP
    SFX_SIREN0_JR   DB  ; LOOP
    SFX_SIREN1      DB  ; LOOP
    SFX_SIREN1_MS   DB  ; LOOP
    SFX_SIREN1_JR   DB  ; LOOP
    SFX_SIREN2      DB  ; LOOP
    SFX_SIREN2_MS   DB  ; LOOP
    SFX_SIREN2_JR   DB  ; LOOP
    SFX_SIREN3      DB  ; LOOP
    SFX_SIREN3_MS   DB  ; LOOP
    SFX_SIREN3_JR   DB  ; LOOP
    SFX_SIREN4      DB  ; LOOP
    SFX_SIREN4_MS   DB  ; LOOP
    SFX_SIREN4_JR   DB  ; LOOP
    SFX_FRIGHT      DB  ; LOOP
    SFX_EYES        DB  ; LOOP
    SFX_FRIGHT_MS   DB  ; LOOP
    SFX_EYES_MS     DB  ; LOOP
    SFX_FRIGHT_JR   DB  ; LOOP
    SFX_EYES_JR     DB  ; LOOP
    SFX_BOUNCE      DB
    SFX_CREDIT      DB
;   MUSIC
    MUS_START       DB
    MUS_COFFEE      DB  ; LOOP
    MUS_START_MS    DB
    MUS_INTER0_MS   DB
    MUS_INTER1_MS   DB
    MUS_INTER2_MS   DB
    MUS_START_JR    DB
    MUS_INTER0_JR   DB
    MUS_INTER1_JR   DB
    MUS_INTER2_JR   DB
.ENDE
/*
-----------------------------------------------------------
                    PSG ENVELOPE TABLE
-----------------------------------------------------------
*/
psgIndexTable:
    .DW psgEnv01    ; DECREASE EVERY FRAME
    .DW psgEnv02    ; DECREASE EVERY 2 FRAMES
    .DW psgEnv03    ; DECREASE EVERY 4 FRAMES

psgEnv01:
    .DB $00 $01 $02 $02 $03 $03 $04 $05 $06 $07 $08 $09 $0A $0B $0D $0F $80
psgEnv02:
    .DB $00 $00 $01 $01 $02 $02 $02 $02 $03 $03 $03 $03 $04 $04 $05 $05 $06 $06 $07 $07 $08 $08 $09 $09 $0A $0A $0B $0B $0D $0D $0F $80
psgEnv03:
    .DB $00 $00 $00 $00 $01 $01 $01 $01 $02 $02 $02 $02 $02 $02 $02 $02 $03 $03 $03 $03 $03 $03 $03 $03 $04 $04 $04 $04 $05 $05 $05 $05 $80
/*
-----------------------------------------------------------
                    SOUND EFFECT DATA
-----------------------------------------------------------
*/

;   -----------
;   PAC-MAN / COMMON
;   -----------
sfxDot0:
    smpsChanHeader  sfxDot0 + 6,    $00 $00 $00 $00
    smpsSetNoise    $E3 ; PERIODIC NOISE
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $000E
    literalWord     $0011
    literalWord     $0014
    literalWord     $0019
    literalWord     $0021
    smpsStop

sfxDot1:
    smpsChanHeader  sfxDot1 + 6,    $00 $00 $00 $00
    smpsSetNoise    $E3 ; PERIODIC NOISE
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $002B
    literalWord     $001E
    literalWord     $0017
    literalWord     $0013
    literalWord     $0010
    smpsStop

sfxFruit:
    smpsChanHeader  sfxFruit + 6,   $00 $03 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $00D9
    literalWord     $00EF
    literalWord     $0109
    literalWord     $012A
    literalWord     $0155
    literalWord     $018E
    literalWord     $01DD
    literalWord     $0255
    literalWord     $031B
    literalWord     $0370  ; LOW FREQ LIMIT
    literalWord     $03DC  ; LOW FREQ LIMIT

    literalWord     $0370  ; LOW FREQ LIMIT
    literalWord     $031B
    literalWord     $0255
    literalWord     $01DD
    literalWord     $018E
    literalWord     $0155
    literalWord     $012A
    literalWord     $0109
    literalWord     $00EF
    literalWord     $00D9
    literalWord     $00C7
    literalWord     $00B8
    smpsStop

sfxEatGhost:
    smpsChanHeader  sfxEatGhost + 6, $00 $03 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $03A5  ; LOW FREQ LIMIT
    literalWord     $0370  ; LOW FREQ LIMIT
    literalWord     $031B
    literalWord     $0255
    literalWord     $01DD
    literalWord     $018E
    literalWord     $0155
    literalWord     $012A
    literalWord     $0109
    literalWord     $00EF
    literalWord     $00D9
    literalWord     $00C7
    literalWord     $00B8
    literalWord     $00AA
    literalWord     $009F
    literalWord     $0095
    literalWord     $008C
    literalWord     $0085
    literalWord     $007E
    literalWord     $0077
    literalWord     $0072
    literalWord     $006C
    literalWord     $0068
    literalWord     $0063
    literalWord     $005F
    literalWord     $005C
    literalWord     $0058
    literalWord     $0055
    literalWord     $0052
    literalWord     $0050
    literalWord     $004D
    smpsStop

sfxDeath:
    smpsChanHeader  sfxDeath + 6,   $00 $02 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $009A
    literalWord     $009F
    literalWord     $00A5
    literalWord     $00AA
    literalWord     $00B1

    literalWord     $00AA
    literalWord     $00A5
    literalWord     $009F
    literalWord     $009A
    literalWord     $0095
    literalWord     $0091
    smpsChangeVol   $01         ; DECREMENT EVERY OTHER REP

    literalWord     $00A5
    literalWord     $00AA
    literalWord     $00B1
    literalWord     $00B8
    literalWord     $00BF
    literalWord     $00C7

    literalWord     $00BF
    literalWord     $00B8
    literalWord     $00B1
    literalWord     $00AA
    literalWord     $00A5
    literalWord     $009F
    ;smpsChangeVol   $01         ; DECREMENT EVERY OTHER REP

    literalWord     $00B1
    literalWord     $00B8
    literalWord     $00BF
    literalWord     $00C7
    literalWord     $00D0
    literalWord     $00D9

    literalWord     $00D0
    literalWord     $00C7
    literalWord     $00BF
    literalWord     $00B8
    literalWord     $00B1
    literalWord     $00AA
    smpsChangeVol   $01         ; DECREMENT EVERY OTHER REP

    literalWord     $00BF
    literalWord     $00C7
    literalWord     $00D0
    literalWord     $00D9
    literalWord     $00E3
    literalWord     $00EF

    literalWord     $00E3
    literalWord     $00D9
    literalWord     $00D0
    literalWord     $00C7
    literalWord     $00BF
    literalWord     $00B8
    ;smpsChangeVol   $01         ; DECREMENT EVERY OTHER REP

    literalWord     $00D0
    literalWord     $00D9
    literalWord     $00E3
    literalWord     $00EF
    literalWord     $00FB
    literalWord     $0109

    literalWord     $00FB
    literalWord     $00EF
    literalWord     $00E3
    literalWord     $00D9
    literalWord     $00D0
    literalWord     $00C7
    ;smpsChangeVol   $01         ; DECREMENT EVERY OTHER REP

    literalWord     $00E3
    literalWord     $00EF
    literalWord     $00FB
    literalWord     $0109
    literalWord     $0119
    literalWord     $012A

    literalWord     $0119
    literalWord     $0109
    ;literalWord     $00FB
    ;literalWord     $00EF
    ;literalWord     $00E3
    ;literalWord     $00D9



    ; PART 2
    literalWord     $0255
    literalWord     $012A
    literalWord     $00C7
    literalWord     $0095
    literalWord     $0077
    literalWord     $0063
    literalWord     $0055
    literalWord     $004B
    literalWord     $0042
    literalWord     $003C
    literalWord     $0036
    literalWord     $0000   ; REST

    literalWord     $0255
    literalWord     $012A
    literalWord     $00C7
    literalWord     $0095
    literalWord     $0077
    literalWord     $0063
    literalWord     $0055
    literalWord     $004B
    literalWord     $0042
    literalWord     $003C
    literalWord     $0036

    smpsStop

sfxBonus:
    smpsChanHeader  sfxBonus + 6,   $00 $02 $00 $01
    smpsDetune      $02
    .DB nFs3, $0C
    .DB nFs3 nFs3 nFs3 nFs3 nFs3 nFs3 nFs3 nFs3 nFs3
    smpsStop

sfxSiren0:
    smpsChanHeader  sfxSiren0 + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0109
    literalWord     $00EF
    literalWord     $00D9
    literalWord     $00C7
    literalWord     $00B8
    literalWord     $00AA
    literalWord     $009F
    literalWord     $0095
    literalWord     $008C
    literalWord     $0085
    literalWord     $007E
    literalWord     $0077

    literalWord     $007E
    literalWord     $0085
    literalWord     $008C
    literalWord     $0095
    literalWord     $009F
    literalWord     $00AA
    literalWord     $00B8
    literalWord     $00C7
    literalWord     $00D9
    literalWord     $00EF
    literalWord     $0109
    literalWord     $012A
    smpsJump        sfxSiren0@data

sfxSiren1:
    smpsChanHeader  sfxSiren1 + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00D4
    literalWord     $00BF
    literalWord     $00AE
    literalWord     $009F
    literalWord     $0093
    literalWord     $0088
    literalWord     $007F
    literalWord     $0077
    literalWord     $0070
    literalWord     $006A
    literalWord     $0064
    
    literalWord     $006A
    literalWord     $0070
    literalWord     $0077
    literalWord     $007F
    literalWord     $0088
    literalWord     $0093
    literalWord     $009F
    literalWord     $00AE
    literalWord     $00BF
    literalWord     $00D4
    literalWord     $00EF
    smpsJump        sfxSiren1@data

sfxSiren2:
    smpsChanHeader  sfxSiren2 + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00B1
    literalWord     $009F
    literalWord     $0091
    literalWord     $0085
    literalWord     $007A
    literalWord     $0072
    literalWord     $006A
    literalWord     $0063
    literalWord     $005E
    literalWord     $0058
    
    literalWord     $005E
    literalWord     $0063
    literalWord     $006A
    literalWord     $0072
    literalWord     $007A
    literalWord     $0085
    literalWord     $0091
    literalWord     $009F
    literalWord     $00B1
    literalWord     $00C7
    smpsJump        sfxSiren2@data

sfxSiren3:
    smpsChanHeader  sfxSiren3 + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $008E
    literalWord     $0081
    literalWord     $0076
    literalWord     $006C
    literalWord     $0064
    literalWord     $005E
    literalWord     $0058
    literalWord     $0052
    literalWord     $004E
    
    literalWord     $0052
    literalWord     $0058
    literalWord     $005E
    literalWord     $0064
    literalWord     $006C
    literalWord     $0076
    literalWord     $0081
    literalWord     $008E
    literalWord     $009F
    smpsJump        sfxSiren3@data

sfxSiren4:
    smpsChanHeader  sfxSiren4 + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0077
    literalWord     $006C
    literalWord     $0063
    literalWord     $005C
    literalWord     $0055
    literalWord     $0050
    literalWord     $004B
    literalWord     $0046
    
    literalWord     $004B
    literalWord     $0050
    literalWord     $0055
    literalWord     $005C
    literalWord     $0063
    literalWord     $006C
    literalWord     $0077
    literalWord     $0085
    smpsJump        sfxSiren4@data

sfxFright:
    smpsChanHeader  sfxFright + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $018e
    literalWord     $00c7
    literalWord     $0085
    literalWord     $0063
    literalWord     $0050
    literalWord     $0042
    literalWord     $0039
    literalWord     $0032
    smpsJump        sfxFright@data

sfxEyes:
    smpsChanHeader  sfxEyes + 6,  $00 $05 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $002D
    literalWord     $0030
    literalWord     $0033
    literalWord     $0036
    literalWord     $003A
    literalWord     $003F
    literalWord     $0044
    literalWord     $004B
    literalWord     $0052
    literalWord     $005C
    literalWord     $0068
    literalWord     $0077
    literalWord     $008C
    literalWord     $00AA
    literalWord     $00D9
    literalWord     $012A
    smpsJump        sfxEyes@data


;   -----------
;   MS. PAC-MAN
;   -----------
sfxMsDot:
    smpsChanHeader  sfxMsDot + 6,  $00 $04 $00 $00

    smpsLiteralRead $01 ; LITERAL READ MODE ON
    literalWord     $0013
    literalWord     $0024
    literalWord     $0119
    literalWord     $001F
    literalWord     $007A
    literalWord     $001B
    literalWord     $004E
    smpsStop

sfxMsBounce:
    smpsChanHeader  sfxMsBounce + 6,  $00 $01 $00 $00
    smpsSetNoise    $E3 ; PERIODIC NOISE
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $0255
    literalWord     $018E
    literalWord     $012A
    literalWord     $00EF
    literalWord     $00C7
    smpsStop

sfxMsEatGhost:
    smpsChanHeader  sfxMsEatGhost + 6,  $00 $03 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $03FF  ; LOW FREQ LIMIT
    literalWord     $0255
    literalWord     $018E
    literalWord     $012A
    literalWord     $00EF
    literalWord     $00C7
    literalWord     $00AA
    literalWord     $0095
    literalWord     $0085

    literalWord     $0109
    literalWord     $00D9
    literalWord     $00B8
    literalWord     $009F
    literalWord     $008C
    literalWord     $007E
    literalWord     $0072
    literalWord     $0068
    literalWord     $005F
    literalWord     $0058

    literalWord     $0095
    literalWord     $0085
    literalWord     $0077
    literalWord     $006C
    literalWord     $0063
    literalWord     $005C
    literalWord     $0055
    literalWord     $0050
    literalWord     $004B
    literalWord     $0046
    smpsStop

sfxMsDeath:
    smpsChanHeader  sfxMsDeath + 6,  $00 $02 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $00B1
    literalWord     $00B8
    literalWord     $00BF
    literalWord     $00C7
    literalWord     $00D0
    literalWord     $00D9
    literalWord     $00E3
    literalWord     $00EF
    literalWord     $00FB
    literalWord     $0109
    literalWord     $0119
    literalWord     $012A
    literalWord     $013E
    literalWord     $0155
    literalWord     $016F
    literalWord     $018E
    literalWord     $01B2
    smpsChangeVol   $03

    literalWord     $00D0
    literalWord     $00D9
    literalWord     $00E3
    literalWord     $00EF
    literalWord     $00FB
    literalWord     $0109
    literalWord     $0119
    literalWord     $012A
    literalWord     $013E
    literalWord     $0155
    literalWord     $016F
    literalWord     $018E
    literalWord     $01B2
    literalWord     $01DD
    literalWord     $0212
    literalWord     $0255
    literalWord     $02AA
    literalWord     $031B
    smpsChangeVol   $03

    literalWord     $00FB
    literalWord     $0109
    literalWord     $0119
    literalWord     $012A
    literalWord     $013E
    literalWord     $0155
    literalWord     $016F
    literalWord     $018E
    literalWord     $01B2
    literalWord     $01DD
    literalWord     $0212
    literalWord     $0255
    literalWord     $02AA
    literalWord     $031B
    literalWord     $03BB
    literalWord     $03FF  ; LOW FREQ LIMIT

    smpsChangeVol   $05
    literalWord     $03FF  ; LOW FREQ LIMIT
    literalWord     $03FF  ; LOW FREQ LIMIT
    smpsChangeVol   $FE
    ;smpsChangeVol   $03

    literalWord     $013E
    literalWord     $0155
    literalWord     $016F
    literalWord     $018E
    literalWord     $01B2
    literalWord     $01DD
    literalWord     $0212
    literalWord     $0255
    literalWord     $02AA
    literalWord     $031B
    literalWord     $03BB
    literalWord     $03FF  ; LOW FREQ LIMIT

    smpsChangeVol   $04
    literalWord     $03FF  ; LOW FREQ LIMIT
    literalWord     $03FF  ; LOW FREQ LIMIT
    literalWord     $03FF  ; LOW FREQ LIMIT

    ;literalWord     $0000
    ;literalWord     $0026
    ;literalWord     $0026



    smpsStop

sfxMsSiren0:
    smpsChanHeader  sfxMsSiren0 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0155
    literalWord     $00B8
    literalWord     $007E
    literalWord     $005F
    literalWord     $004D
    literalWord     $0040
    literalWord     $0037
    literalWord     $0031
    smpsJump    sfxMsSiren0@data

sfxMsSiren1:
    smpsChanHeader  sfxMsSiren1 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0155
    literalWord     $00B8
    literalWord     $007E
    literalWord     $005F
    literalWord     $004D
    literalWord     $0040
    literalWord     $0037
    literalWord     $0031
    literalWord     $002B
    smpsJump    sfxMsSiren1@data

sfxMsSiren2:
    smpsChanHeader  sfxMsSiren2 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $012A
    literalWord     $00AA
    literalWord     $0077
    literalWord     $005C
    literalWord     $004B
    literalWord     $003F
    literalWord     $0036
    literalWord     $0030
    literalWord     $002B
    literalWord     $0026
    smpsJump    sfxMsSiren2@data

sfxMsSiren3:
    smpsChanHeader  sfxMsSiren3 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0109
    literalWord     $009F
    literalWord     $0072
    literalWord     $0058
    literalWord     $0048
    literalWord     $003D
    literalWord     $0035
    literalWord     $002F
    literalWord     $002A
    literalWord     $0026
    literalWord     $0023
    smpsJump    sfxMsSiren3@data

sfxMsSiren4:
    smpsChanHeader  sfxMsSiren4 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00EF
    literalWord     $0095
    literalWord     $006C
    literalWord     $0055
    literalWord     $0046
    literalWord     $003C
    literalWord     $0034
    literalWord     $002E
    literalWord     $0029
    literalWord     $0025
    literalWord     $0022
    literalWord     $001F
    smpsJump    sfxMsSiren4@data

sfxMsFright:
    smpsChanHeader  sfxMsFright + 6,  $00 $04 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $031b
    literalWord     $018e
    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072

    literalWord     $0255
    literalWord     $0155
    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f

    literalWord     $01dd
    literalWord     $012a
    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c

    literalWord     $018e
    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058

    literalWord     $0155
    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055

    literalWord     $012a
    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052

    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050

    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d

    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b

    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048

    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046

    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044

    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042

    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040

    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f

    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d

    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c

    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a

    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039

    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037

    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036

    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035

    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034

    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033

    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032

    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031

    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030

    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f

    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e

    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d

    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c

    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b

    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b

    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a

    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029

    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028

    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028

    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027

    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026

    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026

    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025

    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025

    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024

    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024

    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023

    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023

    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022

    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022

    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021

    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021

    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020

    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020

    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021
    literalWord     $001f

    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020
    literalWord     $001f

    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020
    literalWord     $001f

    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021
    literalWord     $001f
    literalWord     $001e

    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020
    literalWord     $001f
    literalWord     $001e

    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020
    literalWord     $001f
    literalWord     $001d

    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021
    literalWord     $001f
    literalWord     $001e
    literalWord     $001d

    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020
    literalWord     $001f
    literalWord     $001e
    literalWord     $001d

    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020
    literalWord     $001f
    literalWord     $001d
    literalWord     $001c

    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021
    literalWord     $001f
    literalWord     $001e
    literalWord     $001d
    literalWord     $001c

    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020
    literalWord     $001f
    literalWord     $001e
    literalWord     $001d
    literalWord     $001c
@data:
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020
    literalWord     $001f
    literalWord     $001d
    literalWord     $001c
    literalWord     $001b
    smpsJump    sfxMsFright@data

sfxMsEyes:
    smpsChanHeader  sfxMsEyes + 6,  $00 $06 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0043
    literalWord     $01c7
    literalWord     $003d
    literalWord     $0111
    literalWord     $0038
    literalWord     $00c3
    literalWord     $0034
    literalWord     $0098
    literalWord     $0030
    literalWord     $007c
    literalWord     $002d
    literalWord     $0069
    literalWord     $002a
    literalWord     $005b
    literalWord     $0028
    literalWord     $0050
    literalWord     $0026
    literalWord     $0048
    literalWord     $031b
    literalWord     $0041
    literalWord     $016f
    literalWord     $003b
    literalWord     $00ef
    literalWord     $0037
    literalWord     $00b1
    literalWord     $0033
    literalWord     $008c
    literalWord     $002f
    literalWord     $0074
    literalWord     $002c
    literalWord     $0063
    literalWord     $0029
    literalWord     $0057
    literalWord     $0027
    literalWord     $004d
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0045
    literalWord     $0231
    literalWord     $003f
    literalWord     $0134
    literalWord     $003a
    literalWord     $00d4
    literalWord     $0035
    literalWord     $00a2
    literalWord     $0031
    literalWord     $0083
    literalWord     $002e
    literalWord     $006e
    literalWord     $002b
    literalWord     $005f
    literalWord     $0028
    literalWord     $0053
    literalWord     $0026
    literalWord     $004a
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0043
    literalWord     $01b2
    literalWord     $003d
    literalWord     $0109
    literalWord     $0038
    literalWord     $00bf
    literalWord     $0034
    literalWord     $0095
    literalWord     $0030
    literalWord     $007a
    literalWord     $002d
    literalWord     $0068
    literalWord     $002a
    literalWord     $005a
    literalWord     $0028
    literalWord     $0050
    literalWord     $0025
    literalWord     $0047
    literalWord     $02de
    literalWord     $0040
    literalWord     $0162
    literalWord     $003b
    literalWord     $00e9
    literalWord     $0036
    literalWord     $00ae
    literalWord     $0032
    literalWord     $008a
    literalWord     $002f
    literalWord     $0073
    literalWord     $002c
    literalWord     $0062
    literalWord     $0029
    literalWord     $0056
    literalWord     $0027
    literalWord     $004c
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0045
    literalWord     $0212
    literalWord     $003e
    literalWord     $012a
    literalWord     $0039
    literalWord     $00d0
    literalWord     $0035
    literalWord     $009f
    literalWord     $0031
    literalWord     $0081
    literalWord     $002e
    literalWord     $006c
    literalWord     $002b
    literalWord     $005e
    literalWord     $0028
    literalWord     $0052
    literalWord     $0026
    literalWord     $0049
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0042
    smpsJump    sfxMsEyes@data

sfxCredit:
    smpsChanHeader  sfxCredit + 6,  $00 $00 $00 $00
    smpsSetNoise    $E3 ; PERIODIC NOISE
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $0016
    literalWord     $001B
    literalWord     $0023
    literalWord     $0032
    literalWord     $0055
    literalWord     $012A

    literalWord     $0055
    literalWord     $0032
    literalWord     $0023
    literalWord     $001B
    literalWord     $0016
    literalWord     $0013
    literalWord     $0010
    smpsStop


;   -----------
;   JR. PAC-MAN
;   -----------

sfxJrDot:
    smpsChanHeader  sfxJrDot + 6,  $00 $04 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
    literalWord     $0102
    literalWord     $00b8
    literalWord     $008e
    smpsStop

sfxJrBigDot:
    smpsChanHeader  sfxJrBigDot + 6,  $00 $04 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
    literalWord     $01f6
    literalWord     $031b
    literalWord     $01f6
    literalWord     $016f
    literalWord     $0121
    smpsStop

sfxJrEatGhost:
    smpsChanHeader  sfxJrEatGhost + 6,  $00 $03 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0255
    literalWord     $018e
    literalWord     $012a
    literalWord     $00ef
    literalWord     $00c7
    literalWord     $00aa
    literalWord     $0095

    literalWord     $00d9
    literalWord     $00b8
    literalWord     $009f
    literalWord     $008c
    literalWord     $007e
    literalWord     $0072
    literalWord     $0068
    literalWord     $005f
    literalWord     $0058
    smpsStop

sfxJrDeath:
    smpsChanHeader  sfxJrDeath + 6,  $00 $02 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    
    literalWord     $005c
    literalWord     $0063
    literalWord     $006c
    literalWord     $0077
    literalWord     $0085
    literalWord     $0095
    literalWord     $00aa
    literalWord     $00c7
    literalWord     $00ef
    literalWord     $012a
    literalWord     $018e
    literalWord     $0255
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0000
    literalWord     $0013

    smpsChangeVol   $03
    literalWord     $0068
    literalWord     $0072
    literalWord     $007e
    literalWord     $008c
    literalWord     $009f
    literalWord     $00b8
    literalWord     $00d9
    literalWord     $0109
    literalWord     $0155
    literalWord     $01dd
    literalWord     $031b
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0013
    literalWord     $0013
    literalWord     $0013
    literalWord     $0014

    smpsChangeVol   $02
    literalWord     $0077
    literalWord     $0085
    literalWord     $0095
    literalWord     $00aa
    literalWord     $00c7
    literalWord     $00ef
    literalWord     $012a
    literalWord     $018e
    literalWord     $0255
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0000
    literalWord     $0013
    literalWord     $0013
    literalWord     $0014
    literalWord     $0014
    literalWord     $0014

    smpsChangeVol   $02
    literalWord     $008c
    literalWord     $009f
    literalWord     $00b8
    literalWord     $00d9
    literalWord     $0109
    literalWord     $0155
    literalWord     $01dd
    literalWord     $031b
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0013
    literalWord     $0013
    literalWord     $0013
    literalWord     $0014
    literalWord     $0014
    literalWord     $0014
    literalWord     $0015

    smpsChangeVol   $02
    literalWord     $00aa
    literalWord     $00c7
    literalWord     $00ef
    literalWord     $012a
    literalWord     $018e
    literalWord     $0255
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0000
    literalWord     $0013
    literalWord     $0013
    literalWord     $0014
    literalWord     $0014
    literalWord     $0014
    literalWord     $0015
    literalWord     $0015
    literalWord     $0015
    smpsStop


sfxJrSiren0:
    smpsChanHeader  sfxJrSiren0 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00d3
    literalWord     $0292
    literalWord     $00c8
    literalWord     $0231
    literalWord     $00be
    literalWord     $01ea
    literalWord     $00b5
    literalWord     $01b2
    literalWord     $00ad
    literalWord     $0186
    literalWord     $00a5
    literalWord     $0162
    smpsJump    sfxJrSiren0@data


sfxJrSiren1:
    smpsChanHeader  sfxJrSiren1 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00c1
    literalWord     $01f6
    literalWord     $00b6
    literalWord     $01b2
    literalWord     $00ac
    literalWord     $017e
    literalWord     $00a3
    literalWord     $0155
    literalWord     $009b
    literalWord     $0134
    literalWord     $03FF   ; LOW FREQ LIMIT
    smpsJump    sfxJrSiren1@data


sfxJrSiren2:
    smpsChanHeader  sfxJrSiren2 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00b2
    literalWord     $0196
    literalWord     $00a7
    literalWord     $0162
    literalWord     $009d
    literalWord     $0139
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0119
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00ff
    smpsJump    sfxJrSiren2@data


sfxJrSiren3:
    smpsChanHeader  sfxJrSiren3 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $00a5
    literalWord     $0155
    literalWord     $009a
    literalWord     $012a
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0109
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00ef
    literalWord     $03bb
    smpsJump    sfxJrSiren3@data

sfxJrSiren4:
    smpsChanHeader  sfxJrSiren4 + 6,  $00 $07 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:
    literalWord     $0099
    literalWord     $0126
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $0102
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00e6
    literalWord     $032c
    literalWord     $00d0
    smpsJump    sfxJrSiren4@data

sfxJrFright:
    smpsChanHeader  sfxJrFright + 6,  $00 $04 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $031b
    literalWord     $018e
    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f

    literalWord     $0255
    literalWord     $0155
    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e

    literalWord     $01dd
    literalWord     $012a
    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077

    literalWord     $018e
    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072

    literalWord     $0155
    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c

    literalWord     $012a
    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068

    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063

    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f

    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c

    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058

    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055

    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052

    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050

    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d

    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b

    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048

    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046

    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044

    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042

    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040

    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f

    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d

    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c

    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a

    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039

    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037

    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036

    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035

    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034

    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033

    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032

    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031

    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030

    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f

    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e

    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d

    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c

    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b

    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b

    literalWord     $0039
    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a

    literalWord     $0037
    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029

    literalWord     $0036
    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028

    literalWord     $0035
    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028

    literalWord     $0034
    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027

    literalWord     $0033
    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026

    literalWord     $0032
    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026

    literalWord     $0031
    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025

    literalWord     $0030
    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025

    literalWord     $002f
    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024

    literalWord     $002e
    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024

    literalWord     $002d
    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023

    literalWord     $002c
    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023

    literalWord     $002b
    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022

    literalWord     $002b
    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022

    literalWord     $002a
    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021

    literalWord     $0029
    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021

    literalWord     $0028
    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020

    literalWord     $0028
    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020

    literalWord     $0027
    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021
    literalWord     $001f

    literalWord     $0026
    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020
    literalWord     $001f

    literalWord     $0026
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020
    literalWord     $001f

    literalWord     $0025
    literalWord     $0024
    literalWord     $0022
    literalWord     $0021
    literalWord     $001f
    literalWord     $001e

    literalWord     $0025
    literalWord     $0023
    literalWord     $0022
    literalWord     $0020
    literalWord     $001f
    literalWord     $001e
@data:
    literalWord     $0024
    literalWord     $0023
    literalWord     $0021
    literalWord     $0020
    literalWord     $001f
    literalWord     $001d
    smpsJump    sfxJrFright@data

sfxJrEyes:
    smpsChanHeader  sfxJrEyes + 6,  $00 $06 $00 $00
    smpsLiteralRead $01 ; LITERAL READ MODE ON
@data:

    literalWord     $00b6
    literalWord     $005d
    literalWord     $0186
    literalWord     $0080
    literalWord     $004d
    literalWord     $00cd
    literalWord     $0063
    literalWord     $0204
    literalWord     $008b
    literalWord     $0051
    literalWord     $00ec
    literalWord     $0069
    literalWord     $02fc
    literalWord     $0099
    literalWord     $0055
    literalWord     $0115
    literalWord     $0071
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00a9
    literalWord     $005a
    literalWord     $014f
    literalWord     $007a
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00bd
    literalWord     $005f
    literalWord     $01a8
    literalWord     $0084
    literalWord     $004e
    literalWord     $00d7
    literalWord     $0065
    literalWord     $0243
    literalWord     $0090
    literalWord     $0052
    literalWord     $00f8
    literalWord     $006c
    literalWord     $038d
    literalWord     $009e
    literalWord     $0056
    literalWord     $0126
    literalWord     $0074
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00af
    literalWord     $005b
    literalWord     $0168
    literalWord     $007d
    literalWord     $004b
    literalWord     $00c5
    literalWord     $0061
    literalWord     $01d2
    literalWord     $0087
    literalWord     $004f
    literalWord     $00e1
    literalWord     $0067
    literalWord     $0292
    literalWord     $0094
    literalWord     $0053
    literalWord     $0106
    literalWord     $006e
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00a3
    literalWord     $0058
    literalWord     $0139
    literalWord     $0077
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00b6
    literalWord     $005d
    literalWord     $0186
    literalWord     $0080
    literalWord     $004d
    literalWord     $00cd
    literalWord     $0063
    literalWord     $0204
    literalWord     $008b
    literalWord     $0051
    literalWord     $00ec
    literalWord     $0069
    literalWord     $02fc
    literalWord     $0099
    literalWord     $0055
    literalWord     $0115
    literalWord     $0071
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00a9
    literalWord     $005a
    literalWord     $014f
    literalWord     $007a
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00bd
    literalWord     $005f
    literalWord     $01a8
    literalWord     $0084
    literalWord     $004e
    literalWord     $00d7
    literalWord     $0065
    literalWord     $0243
    literalWord     $0090
    literalWord     $0052
    literalWord     $00f8
    literalWord     $006c
    literalWord     $038d
    literalWord     $009e
    literalWord     $0056
    literalWord     $0126
    literalWord     $0074
    literalWord     $03FF   ; LOW FREQ LIMIT
    literalWord     $00af
    literalWord     $005b
    literalWord     $0168
    literalWord     $007d
    literalWord     $004b
    literalWord     $00c5
    smpsJump    sfxJrEyes@data



/*
-----------------------------------------------------------
                        MUSIC DATA
-----------------------------------------------------------
*/
musStart:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musStart@ch0,   $00 $04 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musStart@ch1,   $00 $0A $00 $00
    ; CHANNEL 2 HEADER
    smpsChanHeader  musStart@ch2,   $00 $00 $00 $01
    ; CHANNEL 1 DATA
@ch1:
    smpsDetune      $FF
    ; CHANNEL 0 DATA
@ch0:
    .DB nC3, $04, nRst, nC4, nRst, nG3, nRst, nE3, nRst, nC4, nG3, nRst, $08, nE3, nRst
    .DB nCs3, $04, nRst, nCs4, nRst, nGs3, nRst, nF3, nRst, nCs4, nGs3, nRst, $08, nF3, nRst
    .DB nC3, $04, nRst, nC4, nRst, nG3, nRst, nE3, nRst, nC4, nG3, nRst, $08, nE3, nRst
    .DB nEb3, $04, nE3, nF3, nRst, nF3, nFs3, nG3, nRst, nG3, nGs3, nA3, nRst, nC4, $08
    smpsStop
    ; CHANNEL 2 DATA
@ch2:
    smpsSetNoise    $E3 ; PERIODIC NOISE
    .DB nC4, $10, nRst, $08
    .DB nG4, $08
    .DB nC4, $10, nRst, $08
    .DB nG4, $08
    .DB nCs4, $10, nRst, $08
    .DB nGs4, $08
    .DB nCs4, $10, nRst, $08
    .DB nGs4, $08
    .DB nC4, $10, nRst, $08
    .DB nG4, $08
    .DB nC4, $10, nRst, $08
    .DB nG4, $08
    .DB nG4, $10, nA4, nB4, nC5
    smpsStop
    



musCoffee:
    ; GLOBAL HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musCoffee@ch0,  $18 $04 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musCoffee@ch1,  $30 $06 $00 $00
    ; CHANNEL 2 HEADER
    smpsChanHeader  musCoffee@ch2,  $00 $00 $00 $01
;   CHANNEL 1 DATA
@ch1:
    smpsDetune      $FF
;   CHANNEL 0 DATA
@ch0:
    .DB nE0, $02, nF0, $08, nE0, $02, nF0, $08, nE0, $02, nF0, $08, nCs0, $02
    .DB nD0, $04, nC0, nF0, nRst, $02, nF0, $08, nGs0, $02, nA0, $10, nRst, $08
    .DB nE0, $02, nF0, $08, nE0, $02, nF0, $08, nE0, $02, nF0, $08, nCs0, $02
    .DB nD0, $04, nC0, nF0, nRst, $02, nF0, $08, nCs0, $02, nD0, $10, nRst, $08
    .DB nE0, $02, nF0, $08, nE0, $02, nF0, $08, nE0, $02, nF0, $08, nCs0, $02
    .DB nD0, $04, nC0, nF0, nRst, $02, nF0, $08, nG0, $02, nGs0, $08, nA0, $02, nBb0, $08, nRst, $02
    ;.DB nBb0, nB0, $08, nRst, $04, nA0, $02, nBb0, $08, nG0, $02, nGs0, $08, nF0, nRst, $02
    ;.DB nG0, $02, nGs0, $08, nRst, $04, nE0, $02, nF0, $10, nRst, $08
    .DB nBb0, nB0, $08, nB0, $04, nA0, $02, nBb0, $08, nG0, $02, nGs0, $08, nF0, nF0, $02
    .DB nG0, $02, nGs0, $08, nGs0, $04, nE0, $02, nF0, $10, nRst, $08
    smpsJump    musCoffee@ch0
@ch2:
    ; CHANNEL 2 DATA
    smpsSetNoise    $E3 ; PERIODIC NOISE
    .DB nF4, $08, nRst, $06, nF4, $04, nRst, $02, nF4, $08, nRst, $06, nF4, $04, nRst, $02, nF4, $08, nRst, $06, nF4, $04, nRst, $02
    .DB nA4, $04, nRst, $01, nBb4, $04, nRst, $01, nB4, $04, nRst, $01, nC5, $04, nRst, $01
    .DB nF4, $08, nRst, $06, nF4, $04, nRst, $02, nF4, $08, nRst, $06, nF4, $04, nRst, $02, nF4, $08, nRst, $06, nF4, $04, nRst, $02
    .DB nA4, $04, nRst, $01, nBb4, $04, nRst, $01, nB4, $04, nRst, $01, nC5, $04, nRst, $01
    .DB nF4, $08, nRst, $06, nF4, $04, nRst, $02, nF4, $08, nRst, $06, nF4, $04, nRst, $02, nF4, $08, nRst, $06, nF4, $04, nRst, $02
    .DB nA4, $04, nRst, $01, nBb4, $04, nRst, $01, nB4, $04, nRst, $01, nC5, $04, nRst, $01
    .DB nF5, $08, nRst, $02
    .DB nC5, $04, nRst, $01, nB4, $04, nRst, $01, nBb4, $04, nRst, $01, nGs4, $04, nRst, $01, nF4, $04, nRst, $01, nE4, $04, nRst, $01
    .DB nEb4, $08, nRst, $02, nE4, $08, nRst, $02, nF4, $08, nRst, $0C ; 8 + 4
    smpsJump    musCoffee@ch2

    

musMsStart:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musMsStart@ch0,   $00 $04 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musMsStart@ch1,   $00 $0A $00 $00
    ; CHANNEL 2 HEADER
    smpsChanHeader  musMsStart@ch2,   $00 $00 $00 $02
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
@ch0:
    ; CHANNEL 0 DATA
    .DB nB2, $04, nCs3, nEb3
    .DB nE3, $10, nGs3, nFs3, nA3
    .DB nGs3, $08, nA3, nB3, nGs3
    .DB nFs3, $10, nA3
    .DB nGs3, $08, nA3, nB3, nGs3
    .DB nA3, nB3, nCs4, nEb4
    .DB nE4, $10, nEb4, nE4
    smpsStop
@ch2:
    ; CHANNEL 2 DATA
    smpsSetNoise    $E3 ; PERIODIC NOISE
    .DB nRst, $0C
    .DB nE4, $10, nRst, nB3, nRst, nE4, nRst
    .DB nFs4, $08, nGs4, nA4, nFs4, nGs4, nFs4, nE4, nGs4, nFs4, nE4, nEb4, nFs4
    .DB nE4, $10, nB3, nE4
    smpsStop


musMsInter0:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musMsInter0@ch0,   $00 $05 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musMsInter0@ch1,   $00 $05 $00 $02
    ; CHANNEL 2 HEADER
    smpsChanHeader  musMsInter0@ch2,   $F4 $08 $00 $02
@ch0:
    ; CHANNEL 0 DATA
    .DB nG3, $08, nA3, nG3, nE3, nE3, nB2, nD3, nEb3, nE3, $20, nD3, $08, nE3, nD3, nB2
    .DB nG3, $08, nA3, nG3, nE3, nE3, nB2, nD3, nD3, nB2, $20, nRst, $08, nB3, nD4, nEb4
    .DB nEb4, $02, nE4, $08, nRst, $06, nEb4, $02, nE4, $08, nRst, $06, nD4, $04, nE4, nD4, nB3, nA3, $08, nG3, nA3, nG3, nA3, nB3, nB3, nA3, nG3, nE3
    .DB nD3, nE3, nD3, nB2, nD3, nB2, nA2, nG2, nE2, $40
    smpsStop
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
    .DB nRst, $08, nE2, nRst, nE2, $04, nRst, nE2, $10, nRst
    .DB nRst, $08, nE2, nRst, nE2, $04, nRst, nE2, $10, nRst
    .DB nRst, $08, nE2, nRst, nE2, $04, nRst, nE2, $10, nRst
    .DB nRst, $08, nB1, nRst, nB1, $04, nRst, nB1, $10, nRst
    smpsPSGVoice    $00
    .DB nE2, $20, nD2, nC2, nB1
    smpsPSGVoice    $01
    .DB nE2, $10, nG2, nA2, nB1, nD3, $08, nB2, nA2, nG2, nE2, $10
    smpsChangeVol   $FE
    .DB nD3, $01    ; GHOST BUMP
    smpsStop
@ch2:
    ; CHANNEL 2 DATA
    .DB nRst, $08, nE2, nRst, nE2, $04, nRst, nE2, $10, nRst
    .DB nRst, $08, nE2, nRst, nE2, $04, nRst, nE2, $10, nRst
    .DB nRst, $08, nE2, nRst, nE2, $04, nRst, nE2, $10, nRst
    .DB nRst, $08, nB1, nRst, nB1, $04, nRst, nB1, $10, nRst
    smpsPSGVoice    $00
    .DB nE2, $20, nD2, nC2, nB1
    smpsPSGVoice    $01
    .DB nE2, $10, nG2, nA2, nB1, nD3, $08, nB2, nA2, nG2, nE2, $10
    smpsStop



musMsInter1:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musMsInter1@ch0,   $18 $05 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musMsInter1@ch1,   $0C $05 $00 $02
    ; CHANNEL 2 HEADER
    smpsChanHeader  musMsInter1@ch2,   $00 $08 $00 $02
@ch0:
    ; CHANNEL 0 DATA
    .DB nFs1, $08, nFs1, nBb1, nB1, nC2, nCs2, nCs2, nB1, nCs2, nCs2, nBb1, nCs2, nEb2, nE2, nE2, nEb2
    .DB nE2, nE2, nBb2, nGs2, nFs2, nE2, nEb2, nE2, nE2, nBb1, nB1, $30
    .DB nFs1, $08, nFs1, nEb2, nE2, nF2, nFs2, nB1, nCs2, nD2, nEb2, nB1, nEb2, nB1, nFs1, nFs1, nEb1
    .DB nE1, nF1, nFs1, $20, nA1, nBb1, nBb1, $10
    .DB nE1, $08, nE1, nE2, nEb2, nBb1, nB1, nEb2, nCs2, nA1, nBb1, nCs2, nE2, nGs2, nFs2, nFs2, nE2
    .DB nCs2, nBb1, nGs1, $20, nFs1, nB1, $08, nCs2, nD2, nEb2, nGs1, nA1
    .DB nBb1, nCs2, nEb2, nE2, nF2, nFs2, nB1, nCs2, nD2, nEb2, nB1, nEb2, nB1, nFs1, $18
    .DB nF1, $08, nFs1, nGs1, $20, nG1, nGs1, nGs1, $10
    .DB nGs1, $08, nGs1, nE2, nEb2, nCs2, nB1, nB1, nCs2, nEb2, nEb2, nEb2, nCs2, nB1, nFs1, nFs1, nB0
    .DB nCs1, nGs1, nFs1, $20, nBb1, $08, nE2, nGs1, nBb1, nB1, nB1, nRst, nRst, nB1, nB1
    smpsStop
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
@ch2:
    ; CHANNEL 2 DATA
    .DB nRst, $10, nBb2, $08, nA2, nGs2, nG2, nG2, nFs2, nF2, $10, nE2, $08, nEb2, nD2, nCs2, nCs2, nC2
    .DB nB1, $10, nFs1, $20, $10, $08, nGs1, $04, nBb1, nB1, $10, nEb2, nFs1
    .DB nEb2, nB1, nEb2, nFs1, nEb2, nB1, nEb2, nFs1
    .DB nEb2, nEb2, nFs2, nD2, nF2, nCs2, nE2, nFs1
    .DB nE2, nCs2, nE2, nFs1, nE2, nCs2, nE2, nFs1
    .DB nE2, nE2, $20, nCs2, nEb2, $08, nE2, nF2, nFs2, nFs2, nEb2
    .DB nCs2, nFs1, nB1, $10, nEb2, nFs1, nEb2, nB1, nEb2, nFs1
    .DB nEb2, nE1, nE2, nEb2, nC2, nCs2, nBb1, nGs1
    .DB nFs1, nE1, nRst, nRst, nE2, nEb2, nRst, nRst
    .DB nE1, nRst, nE2, nRst, nE2, nB1, nFs1, nB0
    smpsStop


musMsInter2:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musMsInter2@ch0,   $00 $04 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musMsInter2@ch1,   $00 $0A $00 $00
    ; CHANNEL 2 HEADER
    smpsChanHeader  musMsInter2@ch2,   $00 $00 $00 $02
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
@ch0:
    ; CHANNEL 0 DATA
    .DB nEb3, $08, nD3, nEb3, nFs3, nFs3, nF3, nFs3, nFs3, nB2, nCs3, nD3, nEb3, nEb3, nD3, nEb3, nEb3
    .DB nGs3, nG3, nGs3, nBb3, nBb3, nEb4, nCs4, nCs4, nRst, nRst, nB3, nB3, nRst, nRst, nB3, nB3
    .DB nRst, nGs3, nGs3, nFs3, nB3
    smpsStop
@ch2:
    ; CHANNEL 2 DATA
    smpsSetNoise    $E3 ; PERIODIC NOISE
    .DB nEb4, $08, nRst, nRst, nFs4, nRst, nFs4, nF4, nE4, nEb4, nRst, nRst, nB3, nRst, nB3, nEb4, nFs4
    .DB nE4, nRst, nRst, nCs4, nRst, nRst, nE4, $10, nRst, nEb4, nRst, nEb4, 
    .DB nRst, $08, nE4, $10, nFs4, $08, nEb4
    smpsStop


musJrStart:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musJrStart@ch0,   $00 $04 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musJrStart@ch1,   $00 $0A $00 $00
    ; CHANNEL 2 HEADER
    smpsChanHeader  musJrStart@ch2,   $F4 $03 $00 $01
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
@ch0:
    ; CHANNEL 0 DATA
    .DB nRst, $30
    .DB nG3, $08, nFs3, nG3
    .DB nBb3, nBb3, nC4, nBb3, nBb3
    .DB nEb3, nD3, nEb3
    .DB nG3, nG3, nFs3, nG3, nG3
    .DB nBb3, nGs3, nF3
    .DB nD3, nD3, nC3, nD3, nD3
    .DB nEb3, $20
    smpsStop

    ;smpsStop
@ch2:
    ; CHANNEL 2 DATA
    .DB nBb2, $08, nRst, nC3
    .DB nRst, nD3, nRst
    .DB nEb3, nRst, nBb3
    .DB nRst, nC3, nRst
    .DB nG3, nRst, nGs2
    .DB nRst, nC3, nRst
    .DB nEb2, nRst, nEb3
    .DB nRst, nBb2, $10, nRst, $08
    .DB nRst, nBb2, $10, nRst, $08
    .DB nRst, nEb3, nD3
    .DB nEb3, nRst, nEb2
    .DB nRst
    smpsStop


musJrInter0:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musJrInter0@ch0,   $00 $05 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musJrInter0@ch1,   $00 $06 $00 $03
    ; CHANNEL 2 HEADER
    smpsChanHeader  musJrInter0@ch2,   $F4 $09 $00 $03
@ch0:
    ; CHANNEL 0 DATA
    .DB nF3, $08, nE3, nF3, $04, nRst, nF3, $10, 
    .DB nD4, $08, nC4, $10, nBb3, nRst, nRst, nRst
    .DB nD3, $08, nCs3, nD3, nEb3, nF3, nEb3, nD3, nC3
    .DB nD3, nCs3, nD3, nBb2, $10, nF2, $08, nBb2, nC3, nD3
    .DB nCs3, nD3, nEb3, nF3, nBb3, nA3, nG3, nF3
    .DB nEb3, nC3, nA2, nA2, $10, nRst, nF3, $08, nEb3, nC3
    .DB nA2, $10, nBb2, $08, nC3, nCs3, nD3, nEb3, nE3, nF3, $10
    .DB nRst, $08, nBb3, nRst, nA3, nF3, nD3, nBb2, nA2
    .DB nCs3, $08, nE3, nF3, nD3, $10, nD3, $08, nE3, nF3, nRst
    .DB nD3, nRst, nA3, nRst, nG3, nRst, nF3, nRst
    .DB nE3, nRst, nD4, nCs4, nD4, nA3
    .DB nA3, nGs3, nA3, nF3, nF3, nE3
    .DB nF3, nD3, nD3, nRst, nD3, nRst, nCs3, nD3
    .DB nE3, nF3, nG3, nBb3, nA3, nG3, $04, nRst, nG3, $08
    .DB nF3, nE3, nF3, $10, nRst, $08, nD3, nRst, 
    .DB nD4, nBb3, nG3, nE3, nE3, $04, nRst
    .DB nE3, $08, nG3, nBb3, $04, nRst, nBb3, $08, nA3, nGs3, nA3, $10
    .DB nRst, $08, nD3, nRst, nCs3, nD3, nE3, nF3, nG3
    .DB nBb3, nA3, nCs3, nD3, $10, nRst, nD4, $08
    smpsStop
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
    .DB nF2, $10, nRst, nF2, nRst, nBb2, $08, nRst, nF2
    .DB nRst, nG2, nRst, nA2, nRst, nBb2, nRst, nD3
    .DB nRst, nF2, nRst, nA2, nRst, nBb2, nRst, nD3
    .DB nRst, nF2, nRst, nD3, nRst, nBb2, nRst, nF3
    .DB nRst, nD3, nRst, nCs3, nRst, nC3, nRst, nF3
    .DB nRst, nF2, nRst, nEb3, nRst, nA2, nRst, nEb3
    .DB nRst, nF2, nRst, nA2, nRst, nBb2, nRst, nF3
    .DB nRst, nD3, nRst, nF3, nRst, nA2, nRst, nA3
    .DB nRst, nA2, nRst, nA3, nRst
    smpsPSGVoice $00
    .DB nD3, $10, nD3, $08, nE3, nF3
    smpsPSGVoice $01
    .DB nRst, nD3, nRst
    .DB nA2, nRst, nBb2, nRst, nB2, nRst, nCs3, nRst
    .DB nD3, nRst, nF3, nRst, nA2, nRst, nD3, nRst
    smpsChangeVol $FE
    .DB nF2, nRst, nA2, nRst, nD2, nRst
    .DB nF2, nRst, nE2, nRst, nCs3, nRst, nA2, nRst
    .DB nCs3, nRst, nD2, nRst, nA2, nRst, nF2, nRst
    .DB nD3, nRst, nG2, nRst, nE3, nRst, nA2, nRst
    .DB nCs3, nRst, nD2, nRst, nA2, nRst, nF2, nRst
    .DB nF3, nRst, nA2, nRst, nA3, nRst, nA2, nRst
    .DB nA3, nRst, nD3, nRst, nA2, nRst, nD2, 
    smpsStop
@ch2:
    ; CHANNEL 2 DATA
    .DB nF2, $10, nRst, nF2, nRst, nBb2, $08, nRst, nF2
    .DB nRst, nG2, nRst, nA2, nRst, nBb2, nRst, nD3
    .DB nRst, nF2, nRst, nA2, nRst, nBb2, nRst, nD3
    .DB nRst, nF2, nRst, nD3, nRst, nBb2, nRst, nF3
    .DB nRst, nD3, nRst, nCs3, nRst, nC3, nRst, nF3
    .DB nRst, nF2, nRst, nEb3, nRst, nA2, nRst, nEb3
    .DB nRst, nF2, nRst, nA2, nRst, nBb2, nRst, nF3
    .DB nRst, nD3, nRst, nF3, nRst, nA2, nRst, nA3
    .DB nRst, nA2, nRst, nA3, nRst
    smpsPSGVoice    $00
    .DB nD3, $10, nD3, $08, nE3, nF3
    smpsPSGVoice    $01
    .DB nRst, nD3, nRst
    .DB nA2, nRst, nBb2, nRst, nB2, ;nRst, ;nCs3, nRst
    ;.DB nD3, nRst, nF3, nRst, nA2, nRst, nD3, nRst


    smpsPSGVoice    $00
    smpsChangeVol   $FC
    smpsLiteralRead $01 ; LITERAL READ MODE ON

    literalWord     $031b
    literalWord     $018e
    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f

    literalWord     $0255
    literalWord     $0155
    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e

    literalWord     $01dd
    literalWord     $012a
    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077

    literalWord     $018e
    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072

    literalWord     $0155
    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c

    literalWord     $012a
    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068

    literalWord     $0109
    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063

    literalWord     $00ef
    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f

    literalWord     $00d9
    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c

    literalWord     $00c7
    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058

    literalWord     $00b8
    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055

    literalWord     $00aa
    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052

    literalWord     $009f
    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050

    literalWord     $0095
    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d

    literalWord     $008c
    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b

    literalWord     $0085
    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048

    literalWord     $007e
    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046

    literalWord     $0077
    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044

    literalWord     $0072
    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042

    literalWord     $006c
    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040

    literalWord     $0068
    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f

    literalWord     $0063
    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d

    literalWord     $005f
    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c

    literalWord     $005c
    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a

    literalWord     $0058
    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039

    literalWord     $0055
    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037

    literalWord     $0052
    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036

    literalWord     $0050
    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035

    literalWord     $004d
    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034

    literalWord     $004b
    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033

    literalWord     $0048
    literalWord     $0042
    literalWord     $003d
    literalWord     $0039
    literalWord     $0035
    literalWord     $0032

    literalWord     $0046
    literalWord     $0040
    literalWord     $003c
    literalWord     $0037
    literalWord     $0034
    literalWord     $0031

    literalWord     $0044
    literalWord     $003f
    literalWord     $003a
    literalWord     $0036
    literalWord     $0033
    literalWord     $0030

    literalWord     $0042
    literalWord     $003d
    literalWord     $0039


    smpsLiteralRead $00
    smpsPSGVoice    $01
    smpsChangeVol   $02
    ;smpsChangeVol $FE
    ;.DB nF2, nRst, nA2, nRst, nD2, nRst
    ;.DB nF2, nRst, nE2, nRst, nCs3, nRst, nA2, nRst
    ;.DB nRst, $08
    .DB nCs3, $08, nRst, nD2, nRst, nA2, nRst, nF2, nRst
    .DB nD3, nRst, nG2, nRst, nE3, nRst, nA2, nRst
    .DB nCs3, nRst, nD2, nRst, nA2, nRst, nF2, nRst
    .DB nF3, nRst, nA2, nRst, nA3, nRst, nA2, nRst
    .DB nA3, nRst, nD3, nRst, nA2, nRst, nD2,
    smpsStop


musJrInter1:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musJrInter1@ch0,   $00 $06 $00 $01
    ; CHANNEL 1 HEADER
    smpsChanHeader  musJrInter1@ch1,   $00 $06 $00 $00
    ; CHANNEL 2 HEADER
    smpsChanHeader  musJrInter1@ch2,   $F4 $09 $00 $00
@ch0:
    .DB nRst, $20, nRst, nRst, $10, nD4, $08, nD4, nCs4, nD4
    smpsPSGVoice $00
    .DB nF4, $10, nF4, $08, nD4, $10, nD4, $08
    smpsPSGVoice $01
    .DB nF3, $10, nF3, $08, nCs4, $10, nC4, $08, nBb3, $10, nRst, nRst, nF3
    .DB nD4, $08, nD4, nCs4, nD4
    smpsPSGVoice $00
    .DB nBb3, $10, nBb3, $08
    .DB nF4, $10, nF4, $08
    smpsPSGVoice $01
    .DB nEb4, $10, nD4, $08, nC4, $10, nD4, $08
    smpsPSGVoice $00
    .DB nEb4, $10, nEb4, $08, nRst, $10, nRst, $08
    smpsPSGVoice $01
    .DB nG4, nFs4, nG4, nEb4, nD4, nEb4
    smpsPSGVoice $00
    .DB nC4, $10, nC4, $08, nF4, $10, nF4, $08
    smpsPSGVoice $01
    .DB nD4, $10, nCs4, $08
    .DB nD4, $10, nEb4, $08, nF4, $10, nEb4, $08, nD4, $10, nC4, $08, nF3, $10, nD4, $08
    .DB nD4, nCs4, nD4
    smpsPSGVoice $00
    .DB nF4, $10, nF4, $08, nD4, $10
    .DB nD4, $08
    smpsPSGVoice $01
    .DB nE4, $10, nE4, $08, nE4, nD4, nE4
    smpsPSGVoice $00
    .DB nG4, $10, nG4, $08, nRst, $10, nG4, $08
    smpsPSGVoice $01
    .DB nF4, nE4, nD4, nA4, $10, nD4, $08, nCs4, nB3, nA3
    .DB nE4, $10, nF4, $08
    smpsPSGVoice $00
    .DB nD4, $10, nD4, nD4, nD4
    smpsStop
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
@ch2:
    ; CHANNEL 2 DATA
    .DB nRst, $20, nRst, nBb2, $10, nBb2, $08, nD3, $10, nD3, $08, nF3, $10
    smpsPSGVoice $01
    .DB nBb2, $08, nBb2, nA2, nBb2, nF2, $10
    smpsPSGVoice $00
    .DB nF2, $08, nG2, $10, nA2, $08, nBb2, $10, nF2, $08, nG2, $10, nA2, $08
    .DB nBb2, $10, nD3, $08, nF2, $10, nD3, $08, nBb2, $10, nD3, $08, nF2, $10, nD3, $08
    .DB nC3, $10, nEb3, $08, nF2, $10, nEb3, $08, nA2, $10, nEb3, $08, nF2, $10, nEb3, $08
    .DB nA2, $10, nEb3, $08, nF2, $10, nEb3, $08, nA2, $10, nEb3, $08, nF2, $10, nC3, $08
    .DB nBb2, $10, nD3, $08, nF2, $10, nD3, $08, nA2, $10, nF2, $08, nG2, $10, nA2, $08
    .DB nBb2, $10, nD3, $08, nF2, $10, nD3, $08, nBb2, $10, nD3, $08, nF2, $10, nD3, $08
    .DB nA2, $10, nCs3, $08, nE2, $10, nCs3, $08
    smpsPSGVoice $01
    .DB nA2, $10, nA2, $08
    smpsPSGVoice $00
    .DB nB2, $10, nCs3, $08, nD3, $10, nD3, nRst, $08, nD3
    //.DB nA2, $10, nA2, nRst, $08, nA2, nD3, $10, nA2, $08, nF2, $10, nA2, $08
    .DB nA2, $10, nA2, nA2, $08, nA2, nD3, $10, nA2, $08, nF2, $10, nA2, $08
    .DB nD2, $10
    smpsStop


musJrInter2:
    ; MAIN HEADER
    smpsHeader      $00 $03 $01 $00
    ; CHANNEL 0 HEADER
    smpsChanHeader  musJrInter2@ch0,   $00 $05 $00 $00
    ; CHANNEL 1 HEADER
    smpsChanHeader  musJrInter2@ch1,   $00 $06 $00 $02
    ; CHANNEL 2 HEADER
    smpsChanHeader  musJrInter2@ch2,   $F4 $09 $00 $02
@ch0:
    /*
    .DB nG4, $04, nFs4, $05, nG4, nRst, $04 ; 18
    .DB nD4, $05, nCs4, nD4, $04, nRst, $05 ; 19
    .DB nBb3, nA3, $04, nBb3, $05, nRst,    ; 19
    .DB nG3, $04, nFs3, $05, nG3, nRst, $04 ; 18
    .DB nD3, $05, nCs3, nD3, $02, nRst, nD3, $0A, nBb3, $04, nA3, $0A
    .DB nG3, $0A, nG3, $13, nRst, $09


    .DB nG4, $05, nFs4, $04, nG4, $05, nRst
    .DB nG4, $04, nFs4, $05, nG4, nRst, $04
    .DB nG4, $05, nFs4, nG4, $04, nD4, $0A, nRst, $04
    .DB nD4, $0A, nEb4, $04, nD4, $05, nEb4, nRst, $04
    .DB nG4, $05, nFs4, nG4, $04, nRst, $05
    .DB nD4, $1C, nBb3, $09, nC4, $05, nB3, nC4, $04, nRst, $05

    .DB nA3, $05, nGs3, $04, nA3, $05, nRst,

    .DB nEb4, $04, nD4, $05, nEb4, nFs3, $0E
    .DB nC4, $09, nBb3, $05, nA3, $04, nBb3, $05, nRst, 
    .DB nE3, $04, nD3, $05, nE3, nRst, $04
    .DB nFs3, $1C

    .DB nD3, $0A

    .DB nG4, $04, nFs4, $05, nG4, nRst, $04
    .DB nG4, $05, nFs4, nG4, $04, nRst, $05
    .DB nG4, nFs4, $04, nG4, $05,
    .DB nD4, $0E, nF4, $09, 
    .DB nEb4, $05, nD4, nEb4, $04, nRst, $05

    .DB nBb3, $05, nA3, $04, nBb3, $05, nRst
    .DB nEb4, $1C, nE4, $09, nF4,
    */
    /*
    .DB nE4, nF4, $05, nE4
    .DB nF4, nRst, nF3, nE3, nF3, nRst, nF4, nE4
    .DB nF4, nRst, nBb4, nA4, nBb4, nRst, nF3, nE3
    .DB nF3, $03, nRst, nF3, $09, nD4, $05, nC4, $09, nBb3, $11, nBb3, $09, nF3
    .DB nD4, $05, nCs4, nD4, $09, nBb3, $05, nA3, nBb3, $09, nD4, $05, nCs4
    .DB nD4, nF4, $09, nG4, $05, nF4, $09, nEb4, $05, nD4, nEb4, $09, nA3, $05
    .DB nG3, nA3, $09, nEb4, $11, nEb4, $09, nRst, nF3, $05, nE3, nF3, $09
    .DB nA3, $05, nGs3, nA3, $09, nG4, $05, nFs4, nG4, nA3, nA3, $09
    .DB nF4, $05, nRst, nF4, nG4, nF4, nRst, nF4, nG4
    .DB nF4, nRst, nF4, $09, nEb4, nD4, nC4, nD4, $05, nCs4
    .DB nD4, $09, nBb3, $05, nA3, nBb3, $09, nF4, $05, nE4, nF4, nD4
    .DB nD4, $09, nF4, nG4, $05, nFs4, nG4, nRst, nG4, nFs4
    .DB nG4, nBb4, $03, nRst, nBb4, $11, nBb4, $09, nG4, nF4, $05, nG4
    .DB nF4, $09, nD4, $05, nEb4, nD4, $09, nBb3, $05, nC4, nBb3, nF3
    .DB nF3, $09, nF4, nF3, $05, nE3, nF3, $03, nRst, nF3, $09, nD4, $05
    .DB nC4, $09, nBb3, $21, 
    */

    /*
    .DB nG4, $04, nFs4, $04, nG4, $04, nRst, $04, nD4, $04, nCs4, $04, nD4, $04,
    .DB nRst, $04, nBb3, $04, nA3, $04, nBb3, $04, nRst, $04, nG3, $04, nFs3, $04, nG3, $04,
    .DB nRst, $04, nD3, $04, nCs3, $04, nD3, $02, nRst, $02, nD3, $08, nBb3, $04, nA3, $08,
    .DB nG3, $10, nG3, $08, nRst, $08, nG4, $04, nFs4, $04, nG4, $04, nRst, $04, nG4, $04,
    .DB nFs4, $04, nG4, $04, nRst, $04, nG4, $04, nFs4, $04, nG4, $04, nD4, $08, nRst, $04,
    .DB nD4, $08, nEb4, $04, nD4, $04, nEb4, $04, nRst, $04, nG4, $04, nFs4, $04, nG4, $04,
    .DB nRst, $04, nD4, $10, nD4, $08, nBb3, $08, nC4, $04, nB3, $04, nC4, $04, nRst, $04,
    .DB nA3, $04, nGs3, $04, nA3, $04, nRst, $04, nEb4, $04, nD4, $04, nEb4, $04, nFs3, $08,
    .DB nFs3, $04, nC4, $08, nBb3, $04, nA3, $04, nBb3, $04, nRst, $04, nE3, $04, nD3, $04,
    .DB nE3, $04, nRst, $04, nFs3, $10, nFs3, $08, nD3, $08, nG4, $04, nFs4, $04, nG4, $04,
    .DB nRst, $04, nG4, $04, nFs4, $04, nG4, $04, nRst, $04, nG4, $04, nFs4, $04, nG4, $04,
    .DB nD4, $08, nD4, $04, nF4, $08, nEb4, $04, nD4, $04, nEb4, $04, nRst, $04, nBb3, $04,
    .DB nA3, $04, nBb3, $04, nRst, $04, nEb4, $10, nEb4, $08, nE4, $08, nF4, $04, nE4, $04,
    .DB nF4, $04, nRst, $04, nF3, $04, nE3, $04, nF3, $04, nRst, $04, nF4, $04, nE4, $04,
    .DB nF4, $04, nRst, $04, nBb4, $04, nA4, $04, nBb4, $04, nRst, $04, nF3, $04, nE3, $04,
    .DB nF3, $02, nRst, $02, nF3, $08, nD4, $04, nC4, $08, nBb3, $10, nBb3, $08, nF3, $08,
    .DB nD4, $04, nCs4, $04, nD4, $08, nBb3, $04, nA3, $04, nBb3, $08, nD4, $04, nCs4, $04,
    .DB nD4, $04, nF4, $08, nG4, $04, nF4, $08, nEb4, $04, nD4, $04, nEb4, $08, nA3, $04,
    .DB nG3, $04, nA3, $08, nEb4, $10, nEb4, $08, nRst, $08, nF3, $04, nE3, $04, nF3, $08,
    .DB nA3, $04, nGs3, $04, nA3, $08, nG4, $04, nFs4, $04, nG4, $04, nA3, $04, nA3, $08,
    .DB nF4, $04, nRst, $04, nF4, $04, nG4, $04, nF4, $04, nRst, $04, nF4, $04, nG4, $04,
    .DB nF4, $04, nRst, $04, nF4, $08, nEb4, $08, nD4, $08, nC4, $08, nD4, $04, nCs4, $04,
    .DB nD4, $08, nBb3, $04, nA3, $04, nBb3, $08, nF4, $04, nE4, $04, nF4, $04, nD4, $04,
    .DB nD4, $08, nF4, $08, nG4, $04, nFs4, $04, nG4, $04, nRst, $04, nG4, $04, nFs4, $04,
    .DB nG4, $04, nBb4, $02, nRst, $02, nBb4, $10, nBb4, $08, nG4, $08, nF4, $04, nG4, $04,
    .DB nF4, $08, nD4, $04, nEb4, $04, nD4, $08, nBb3, $04, nC4, $04, nBb3, $04, nF3, $04,
    .DB nF3, $08, nF4, $08, nF3, $04, nE3, $04, nF3, $02, nRst, $02, nF3, $08, nD4, $04,
    .DB nC4, $08, nBb3, $20,
    */


    .DB nG4, $04, nFs4, $05, nG4, $04, nRst, $05, 
    .DB nD4, $04, nCs4, $05, nD4, $04, nRst, $05, 
    .DB nBb3, $04, nA3, $05, nBb3, $04, nRst, $05, 
    .DB nG3, $04, nFs3, $05, nG3, $04, nRst, $05, 
    .DB nD3, $04, nCs3, $05, nD3, $02, nRst, $02, 
    .DB nD3, $09, nBb3, $05, nA3, $09, nG3, $12, 
    .DB nG3, $09, nRst, $09, nG4, $04, nFs4, $05, 
    .DB nG4, $04, nRst, $05, nG4, $04, nFs4, $05, 
    .DB nG4, $04, nRst, $05, nG4, $04, nFs4, $05, 
    .DB nG4, $04, nD4, $09, nRst, $05, nD4, $09, 
    .DB nEb4, $04, nD4, $05, nEb4, $04, nRst, $05, 
    .DB nG4, $04, nFs4, $05, nG4, $04, nRst, $05, 
    .DB nD4, $12, nD4, $09, nBb3, $09, nC4, $04, 
    .DB nB3, $05, nC4, $04, nRst, $05, nA3, $04, 
    .DB nGs3, $05, nA3, $04, nRst, $05, nEb4, $04, 
    .DB nD4, $05, nEb4, $04, nFs3, $09, nFs3, $05, 
    .DB nC4, $09, nBb3, $04, nA3, $05, nBb3, $04, 
    .DB nRst, $05, nE3, $04, nD3, $05, nE3, $04, 
    .DB nRst, $05, nFs3, $12, nFs3, $09, nD3, $09, 
    .DB nG4, $04, nFs4, $05, nG4, $04, nRst, $05, 
    .DB nG4, $04, nFs4, $05, nG4, $04, nRst, $05, 
    .DB nG4, $04, nFs4, $05, nG4, $04, nD4, $09, 
    .DB nD4, $05, nF4, $09, nEb4, $04, nD4, $05, 
    .DB nEb4, $04, nRst, $05, nBb3, $04, nA3, $05, 
    .DB nBb3, $04, nRst, $05, nEb4, $12, nEb4, $09, 
    .DB nE4, $09, nF4, $04, nE4, $05, nF4, $04, 
    .DB nRst, $05, nF3, $04, nE3, $05, nF3, $04, 
    .DB nRst, $05, nF4, $04, nE4, $05, nF4, $04, 
    .DB nRst, $05, nBb4, $04, nA4, $05, nBb4, $04, 
    .DB nRst, $05, nF3, $04, nE3, $05, nF3, $02, 
    .DB nRst, $02, nF3, $09, nD4, $05, nC4, $09, 
    .DB nBb3, $12, nBb3, $09, nF3, $09, nD4, $04, 
    .DB nCs4, $05, nD4, $09, nBb3, $04, nA3, $05, 
    .DB nBb3, $09, nD4, $04, nCs4, $05, nD4, $04, 
    .DB nF4, $09, nG4, $05, nF4, $09, nEb4, $04, 
    .DB nD4, $05, nEb4, $09, nA3, $04, nG3, $05, 
    .DB nA3, $09, nEb4, $12, nEb4, $09, nRst, $09, 
    .DB nF3, $04, nE3, $05, nF3, $09, nA3, $04, 
    .DB nGs3, $05, nA3, $09, nG4, $04, nFs4, $05, 
    .DB nG4, $04, nA3, $05, nA3, $09, nF4, $04, 
    .DB nRst, $05, nF4, $04, nG4, $05, nF4, $04, 
    .DB nRst, $05, nF4, $04, nG4, $05, nF4, $04, 
    .DB nRst, $05, nF4, $09, nEb4, $09, nD4, $09, 
    .DB nC4, $09, nD4, $04, nCs4, $05, nD4, $09, 
    .DB nBb3, $04, nA3, $05, nBb3, $09, nF4, $04, 
    .DB nE4, $05, nF4, $04, nD4, $05, nD4, $09, 
    .DB nF4, $09, nG4, $04, nFs4, $05, nG4, $04, 
    .DB nRst, $05, nG4, $04, nFs4, $05, nG4, $04, 
    .DB nBb4, $02, nRst, $03, nBb4, $12, nBb4, $09, 
    .DB nG4, $09, nF4, $04, nG4, $05, nF4, $09, 
    .DB nD4, $04, nEb4, $05, nD4, $09, nBb3, $04, 
    .DB nC4, $05, nBb3, $04, nF3, $05, nF3, $09, 
    .DB nF4, $09, nF3, $04, nE3, $05, nF3, $02, 
    .DB nRst, $02, nF3, $09, nD4, $05, nC4, $09, 
    .DB nBb3, $24
    smpsStop
@ch1:
    ; CHANNEL 1 DATA
    smpsDetune      $FF
@ch2:
    /*
    .DB nG3, $08, nRst, $08, nD3, $08, nRst, $08, nBb2, $08, nRst, $08, nG2, $08,
    .DB nRst, $08, nD2, $08, nRst, $08, nD2, $08, nRst, $08, nG2, $08, nBb2, $08, nD2, $08,
    .DB nBb2, $08, nG2, $08, nD3, $08, nD2, $08, nD3, $08, nG2, $08, nD3, $08, nD2, $08,
    .DB nD3, $08, nA2, $08, nC3, $08, nD2, $08, nC3, $08, nG2, $08, nBb2, $08, nD2, $08,
    .DB nD3, $08, nA2, $08, nD3, $08, nD2, $08, nD3, $08, nFs2, $08, nC3, $08, nD2, $08,
    .DB nA2, $08, nG2, $08, nD3, $08, nC2, $08, nBb2, $08, nD2, $08, nD3, $08, nD2, $08,
    .DB nD3, $08, nG2, $08, nD3, $08, nD2, $08, nD3, $08, nG2, $08, nD3, $08, nD2, $08,
    .DB nD3, $08, nEb2, $08, nBb2, $08, nRst, $08, 
    .DB nBb2, $08, nEb2, $08, nBb2, $08, nRst, $08, 
    .DB nBb2, $08, nBb2, $08, nD3, $08, nF2, $08, nBb2, $08, nD2, $08, 
    .DB nF2, $08, nRst, $08, nBb2, $08, nF2, $08, nF3, $08, nF2, $08,
    .DB nF3, $08, nBb1, $08, nBb2, $08, nBb2, $08,
    .DB nBb3, $04, nRst, $04, nBb3, $08, nD4, $08, nF3, $08, nD4, $08,
    .DB nBb3, $08, nD4, $08, nF3, $08, nD4, $08, nA3, $08, nEb4, $08, nF3, $08, nEb4, $08,
    .DB nA3, $08, nEb4, $08, nF3, $08, nEb4, $08, nA3, $08, nEb4, $08, nF3, $08, nEb4, $08,
    .DB nA3, $08, nEb4, $08, nF3, $08, nA3, $08, nBb3, $08, nD4, $08, nF3, $08, nD4, $08,
    .DB nA3, $08, nF3, $08, nG3, $08, nA3, $08, nBb3, $08, nD4, $08, nF3, $08, nD4, $08,
    .DB nBb3, $08, nD4, $08, nF3, $08, nD4, $08, nEb3, $08, nBb3, $08, 
    .DB nRst, $08, nBb3, $08, nEb3, $08, nBb3, $08, nG3, $08, nE3, $08,
    .DB nF3, $08, nD4, $08, nBb3, $08, nD4, $08, nF3, $08, nD4, $08, nBb3, $08, nD4, $08,
    .DB nF3, $08, nRst, $08, nF2, $08, nRst, $08, nBb2, $20
    */

    .DB nG3, $09, nRst, $09, nD3, $09, nRst, $09, 
    .DB nBb2, $09, nRst, $09, nG2, $09, nRst, $09, 
    .DB nD2, $09, nRst, $09, nD2, $09, nRst, $09, 
    .DB nG2, $09, nBb2, $09, nD2, $09, nBb2, $09, 
    .DB nG2, $09, nD3, $09, nD2, $09, nD3, $09, 
    .DB nG2, $09, nD3, $09, nD2, $09, nD3, $09, 
    .DB nA2, $09, nC3, $09, nD2, $09, nC3, $09, 
    .DB nG2, $09, nBb2, $09, nD2, $09, nD3, $09, 
    .DB nA2, $09, nD3, $09, nD2, $09, nD3, $09, 
    .DB nFs2, $09, nC3, $09, nD2, $09, nA2, $09, 
    .DB nG2, $09, nD3, $09, nC2, $09, nBb2, $09, 
    .DB nD2, $09, nD3, $09, nD2, $09, nD3, $09, 
    .DB nG2, $09, nD3, $09, nD2, $09, nD3, $09, 
    .DB nG2, $09, nD3, $09, nD2, $09, nD3, $09, 
    .DB nEb2, $09, nBb2, $09, nRst, $09, nBb2, $09, 
    .DB nEb2, $09, nBb2, $09, nRst, $09, nBb2, $09, 
    .DB nBb2, $09, nD3, $09, nF2, $09, nBb2, $09, 
    .DB nD2, $09, nF2, $09, nRst, $09, nBb2, $09, 
    .DB nF2, $09, nF3, $09, nF2, $09, nF3, $09, 
    .DB nBb1, $09, nBb2, $09, nBb2, $09, nBb3, $04, 
    .DB nRst, $05, nBb3, $09, nD4, $09, nF3, $09, 
    .DB nD4, $09, nBb3, $09, nD4, $09, nF3, $09, 
    .DB nD4, $09, nA3, $09, nEb4, $09, nF3, $09, 
    .DB nEb4, $09, nA3, $09, nEb4, $09, nF3, $09, 
    .DB nEb4, $09, nA3, $09, nEb4, $09, nF3, $09, 
    .DB nEb4, $09, nA3, $09, nEb4, $09, nF3, $09, 
    .DB nA3, $09, nBb3, $09, nD4, $09, nF3, $09, 
    .DB nD4, $09, nA3, $09, nF3, $09, nG3, $09, 
    .DB nA3, $09, nBb3, $09, nD4, $09, nF3, $09, 
    .DB nD4, $09, nBb3, $09, nD4, $09, nF3, $09, 
    .DB nD4, $09, nEb3, $09, nBb3, $09, nRst, $09, 
    .DB nBb3, $09, nEb3, $09, nBb3, $09, nG3, $09, 
    .DB nE3, $09, nF3, $09, nD4, $09, nBb3, $09, 
    .DB nD4, $09, nF3, $09, nD4, $09, nBb3, $09, 
    .DB nD4, $09, nF3, $09, nRst, $09, nF2, $09, 
    .DB nRst, $09, nBb2, $24
    smpsStop


