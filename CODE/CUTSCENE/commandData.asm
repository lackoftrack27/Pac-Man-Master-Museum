
cutsceneEnd:
    CUTEND

/*
--------------
    MS PAC-MAN SCENE 0 DATA
--------------
*/
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



/*
--------------
    MS PAC-MAN SCENE 1 DATA
--------------
*/
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
    ; $41A

    ; $42A - MOVE PAC
;   DO MS. PAC-MAN
    SETPOS  $FF $B4
    SETN    $10 + $18
    PAUSE
    SETCHAR msSceneCharacters@msPacRight
    ;SETN    $10
    ;PAUSE
    SETN    $24
    LOOP    $90 $00


    /*
;   DO PAC-MAN
    SETPOS  $FF $B4
    SETN    $0A
    PAUSE
    SETCHAR msSceneCharacters@pacRight
    ;SETN    $10
    ;PAUSE
    SETN    $24
    LOOP    $90 $00
    */
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
;   DO PAC-MAN
    SETPOS  $00 $54
    SETCHAR msSceneCharacters@pacLeft
    SETN    $20
    LOOP    $70 $00
    ; $42E


    ; $43E - MOVE MS.PAC
;   DO PAC-MAN
    SETPOS  $FF $B4
    ;SETN    $10
    ;PAUSE
    SETCHAR msSceneCharacters@pacRight
    ;SETN    $10
    ;PAUSE
    SETN    $24
    LOOP    $90 $00

    /*
;   MS. PAC-MAN
    SETPOS  $FF $B4
    SETN    $0A
    PAUSE
    SETCHAR msSceneCharacters@msPacRight
    ;SETN    $10
    ;PAUSE
    SETN    $24
    LOOP    $90 $00
    */
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



/*
--------------
    MS PAC-MAN SCENE 2 DATA
--------------
*/
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
--------------
    JR PAC-MAN ATTRACT MODE DATA
--------------
*/
;   STORK SACK CONTROL / GROWING JR CONTROL
jrAttractProg0:
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@storkSack
    SETN    $01
    LOOP    $00 $00
    SETN    $A0
    PAUSE
    SETN    $80
    PAUSE
    ;   MOVING ALONG WITH STORK
    ;SETPOS  $14 $28
    ;SETPOS  $0C $2B
    SETPOS  $1B $2B
    SETN    $FF
    LOOP    $08 $00
    SETN    $60
    LOOP    $08 $00
    SETBGPRI    $00
    ;   FALLING
    SETN    $F8
    LOOP    $07 $0B ; $08 $0B
    ;   BOUNCING ON IMPACT
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
    ;   IDLE ON GROUND
    PLAYSND $10
    SETN    $30
    PAUSE
    ;   SHAKE AROUND
    SETN    $03
    LOOP    $F0 $F0
    SETN    $03
    LOOP    $10 $10
    SETN    $03
    LOOP    $10 $10
    SETN    $03
    LOOP    $F0 $10
    ;   JR GROWING OUT OF SACK
    SETPOS  $4A $D2 ; $48 $DB
    SETCHAR jrSceneCharacters@growingJr3
    SETN    $01
    LOOP    $00 $00
    SETBGPRI    $01
    SETN    $0B
    PAUSE
    SETCHAR jrSceneCharacters@growingJr2
    SETN    $01
    LOOP    $00 $00
    SETN    $0B
    PAUSE
    SETCHAR jrSceneCharacters@growingJr1
    SETN    $01
    LOOP    $00 $00
    SETN    $0B
    PAUSE
    SETCHAR jrSceneCharacters@growingJr0
    SETN    $01
    LOOP    $00 $00
    SETN    $FF
    PAUSE
    CUTEND


;   STORK HEAD CONTROL
jrAttractProg1:
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@storkHead
    SETN    $01
    LOOP    $00 $00
    SETN    $A0
    PAUSE
    SETN    $80
    PAUSE
    ;SETPOS  $10 $28
    ;SETPOS  $0A $28
    SETPOS  $19 $28
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    ;SETN    $A0
    SETN    $5A
    LOOP    $08 $00
    ;SETPOS  $00 $00
    CUTEND



;   STORK BODY CONTROL
jrAttractProg2:
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@storkBody
    SETN    $01
    LOOP    $00 $00
    SETN    $A0
    PAUSE
    SETN    $80
    PAUSE
    ;SETPOS  $00 $28
    SETPOS  $0F $28
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    SETN    $FF
    LOOP    $08 $00
    ;SETN    $A0
    SETOVERRIDE $00
    SETN    $83
    LOOP    $08 $00
    ;SETPOS $00 $00
    CUTEND


;   GHOST CONTROL
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

    SETN    $F0
    PAUSE
    /*
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
    */
    CUTEND


;   CAMERA CONTROL
jrAttractProg4:
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
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


;   PAC-MAN CONTROL
jrAttractProg5:
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETPOS  $00 $00
    ;SETCHAR jrSceneCharacters@pacStatic
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00 ; BLANK
    SETPOS  $00 $D2
    SETN    $98
    LOOP    $10 $00 ; BLANK
    SETN    $FF
    LOOP    $10 $00 ; 
    ; SETPOS    $97 $D2
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
    ;PAUSE
    LOOP    $00 $00
    SETN    $86
    LOOP    $00 $00
    CUTEND


;   MS. PAC-MAN CONTROL
jrAttractProg6:
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00 ; BLANK
    SETPOS  $00 $D2
    SETN    $98
    LOOP    $10 $00 ; BLANK
    SETN    $FF
    LOOP    $10 $00 ; 

    SETN    $49
    PAUSE
    SETPOS    $80 $D2
    SETCHAR jrSceneCharacters@msPacStatic
    SETN    $01
    LOOP    $00 $00
    SETN    $FF
    PAUSE
    SETN    $FF
    PAUSE
    ;SETN    $80
    SETN    $33
    PAUSE
    SETCHAR jrSceneCharacters@msPacRight
    SETN    $17
    ;PAUSE
    LOOP    $00 $00
    SETN    $86
    LOOP    $00 $00
    CUTEND



/*
--------------
    JR PAC-MAN SCENE 0 DATA
--------------
*/

;   JR PAC-MAN CONTROL
jrScene0Prog0:
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $01
    LOOP    $00 $00     ; BLANK
    SETPOS  $2D $38
    ;SETPOS  $2D $38
    SETHIGHX    $01
    ;SETPOS  $80 $3C
    ;SETPOS  $F5 $38
    SETN    $20
    PAUSE
    SETN    $3C
    LOOP    $F8 $00
    SETN    $20
    LOOP    $F8 $00
    SETN    $0A
    LOOP    $00 $08
    SETN    $2C
    LOOP    $F8 $00
    SETN    $08
    LOOP    $F8 $08
    SETN    $10
    LOOP    $F8 $00
    SETN    $10
    LOOP    $00 $08
    SETCHAR jrSceneCharacters@jrPacLeft
    SETN    $30
    LOOP    $08 $08
    SETN    $20
    LOOP    $00 $00
    SETN    $50
    LOOP    $00 $08
    SETN    $20
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $38
    LOOP    $F8 $00
    SETN    $22
    LOOP    $F8 $FD
    SETN    $10
    LOOP    $F8 $00
    ;SETBGPRI        $00
    BLANKING
    SETN    $0C
    LOOP    $00 $08
    SETCHAR jrSceneCharacters@jrPacLeft
    SETN    $20
    LOOP    $08 $04
    SETN    $30
    LOOP    $08 $08
    SETN    $04
    LOOP    $00 $F0
    SETN    $04
    LOOP    $00 $10
    SETN    $04
    LOOP    $00 $F0
    SETN    $04
    LOOP    $00 $10
    SETN    $08
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $08
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@jrPacLeft
    SETN    $1E
    LOOP    $00 $F0
    SETN    $08
    LOOP    $10 $00
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $28
    LOOP    $F0 $00
    SETN    $0B
    LOOP    $F0 $F8
    SETBGPRI        $01
    SETN    $40
    LOOP    $F0 $00
    SETCHAR jrSceneCharacters@jrPacLeft
    SETN    $5C
    LOOP    $0C $F4
    SETN    $20
    LOOP    $10 $00
    SETN    $04
    LOOP    $10 $F0
    SETN    $19
    LOOP    $10 $00
    SETN    $05
    LOOP    $00 $F0
    SETN    $22
    LOOP    $10 $00
    ;SETPOS  $00 $00
    CUTEND


;   MS. PAC-MAN CONTROL
jrScene0Prog1:
    SETBGPRI        $01
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@msPacRight
    SETN    $01
    LOOP    $00 $00     ; BLANK
    ;SETPOS  $B8 $3C
    SETPOS  $2D $38
    SETHIGHX    $01
    ;SETPOS  $80 $3C
    ;SETPOS  $F5 $38
    SETN    $3C
    LOOP    $F8 $00
    SETN    $F0
    PAUSE
    SETN    $33
    PAUSE
    SETN    $20
    LOOP    $F8 $00
    SETN    $0A
    LOOP    $00 $08
    SETN    $2C
    LOOP    $F8 $00
    SETN    $0E
    LOOP    $00 $00
    SETN    $08
    LOOP    $F8 $08
    SETN    $A0
    LOOP    $F8 $00
    SETN    $18
    LOOP    $00 $10
    SETN    $18
    LOOP    $F0 $F0
    SETN    $07
    LOOP    $F0 $F0
    CLRPOWDOT       $00
    SETCHAR jrSceneCharacters@msPacLeft
    SETN    $40
    LOOP    $10 $0C
    SETN    $04
    LOOP    $00 $00
    SETN    $C0
    LOOP    $00 $00
    SETN    $54
    LOOP    $08 $F8
    SETN    $06
    LOOP    $08 $00
    SETN    $08
    LOOP    $08 $F8
    SETN    $30
    LOOP    $08 $00
    SETN    $0A
    LOOP    $00 $F8
    SETN    $48
    LOOP    $08 $00
    ;SETPOS  $00 $00
    CUTEND

;   YUM-YUM CONTROL
jrScene0Prog2:
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@yumyumRight
    SETN    $01
    LOOP    $00 $00     ; BLANK
    ;SETPOS  $B8 $ED
    SETPOS  $37 $ED
    SETHIGHX    $01
    ;SETPOS  $80 $ED
    ;SETPOS  $FF $ED
    SETN    $8F
    LOOP    $F8 $00
    SETCHAR jrSceneCharacters@yumyumUp
    SETN    $6C
    LOOP    $00 $F8
    SETN    $FF
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@yumyumRight
    SETN    $A6
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@yumyumScared
    SETN    $6B
    LOOP    $00 $08
    SETN    $8F
    LOOP    $08 $00
    ;SETPOS  $00 $00
    CUTEND

;   BLINKY CONTROL
jrScene0Prog3:
    SETPOS  $00 $00
    SETCHAR jrSceneCharacters@blinkyRight
    SETN    $01
    LOOP    $00 $00     ; BLANK
    ;SETPOS  $B8 $ED
    SETPOS  $37 $ED
    SETHIGHX    $01
    ;SETPOS  $80 $ED
    ;SETPOS  $FF $ED
    SETN    $F0
    PAUSE
    SETN    $90
    LOOP    $F8 $00
    SETN    $90
    LOOP    $F8 $00
    SETCHAR jrSceneCharacters@blinkyUp
    SETN    $20
    LOOP    $F8 $00
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $20
    LOOP    $F8 $00
    SETN    $4F
    LOOP    $0C $F4
    SETCHAR jrSceneCharacters@blinkyScared
    SETN    $40
    LOOP    $00 $03
    SETN    $80
    LOOP    $06 $06
    SETN    $FF
    LOOP    $06 $00
    ;SETPOS  $00 $00
    CUTEND    



/*
--------------
    JR PAC-MAN SCENE 1 DATA
--------------
*/

;   JR PAC-MAN CONTROL
jrScene1Prog0:
    ;SETCHAR jrSceneCharacters@jrPacRight
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00     ; BLANK
    SETPOS  $7F $D2
    SETPOS  $FF $CD
    SETN    $30
    LOOP    $40 $00     ; BLANK
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00     ; BLANK
    DECPTR  $01         ; BROKEN LOOP?
    ; ------
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $20
    PAUSE
    SETN    $18
    LOOP    $F0 $00
    SETN    $04
    LOOP    $F0 $10
    SETN    $40
    LOOP    $F0 $00
    SETN    $13
    LOOP    $00 $10
    SETCHAR jrSceneCharacters@jrPacLeft
    SETN    $20
    LOOP    $00 $00
    SETBGPAL        $00
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $60
    LOOP    $F0 $00
    SETN    $06
    LOOP    $00 $F0
    SETN    $08
    LOOP    $00 $10
    SETN    $06
    LOOP    $00 $F0
    SETN    $08
    LOOP    $00 $10
    SETN    $60
    LOOP    $F0 $00
    SETN    $20
    LOOP    $F6 $FC
    ;SETN    $08
    SETN    $10
    LOOP    $F0 $00
    SETN    $04
    LOOP    $00 $00
    SETJRVAR        $02
    SETN    $40
    PAUSE
    SETN    $50
    LOOP    $00 $00
    SETJRVAR        $03
    SETN    $C0
    PAUSE
    SETJRVAR        $FF
    SETBGPAL        $03
    ;SETPOS  $00 $00
    CUTEND


;   YUM-YUM CONTROL
jrScene1Prog1:
    SETJRVAR        $00
    SETCHAR jrSceneCharacters@emptySpr
    ;SETCHAR jrSceneCharacters@yumyumLeft
    SETN    $01
    LOOP    $00 $00     ; BLANK
    ;SETPOS  $7C $E1
    SETPOS  $72 $E1
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETCHAR jrSceneCharacters@yumyumLeft
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00
    DECPTR  $02
    ; ------
    SETN    $40
    PAUSE
    SETN    $50
    LOOP    $00 $00
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $FF
    ; ------
    ;SETPOS  $00 $00
    CUTEND


;   BALLOON TOP CONTROL
jrScene1Prog2:
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00     ; BLANK
    SETPOS  $7F $D0
    SETPOS  $FF $C0
    SETN    $30
    LOOP    $40 $00     ; BLANK
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00
    DECPTR  $01         ; BROKEN LOOP?
    ; ------
    SETCHAR jrSceneCharacters@balloonTopStatic
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@balloonTop
    SETN    $10
    LOOP    $F0 $00
    SETN    $08
    LOOP    $F0 $00
    SETN    $04
    LOOP    $F0 $10
    SETN    $40
    LOOP    $F0 $00
    SETN    $13
    LOOP    $00 $10
    SETN    $20
    LOOP    $00 $00
    SETN    $01
    PAUSE
    SETN    $60
    LOOP    $F0 $00
    SETN    $06
    LOOP    $00 $F0
    SETN    $08
    LOOP    $00 $10
    SETN    $06
    LOOP    $00 $F0
    SETN    $08
    LOOP    $00 $10
    SETN    $60
    LOOP    $F0 $00
    SETN    $20
    LOOP    $F6 $FC
    ;SETN    $08
    SETN    $10
    LOOP    $F0 $00
    SETN    $04
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@balloonTopFast
    SETN    $40
    LOOP    $00 $00
    SETN    $10
    LOOP    $F0 $00
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00
    DECPTR  $FF     ; BROKEN LOOP?
    ; ------
    ;SETPOS  $00 $00
    CUTEND


;   BLINKY CONTROL
jrScene1Prog3:
    ;SETCHAR jrSceneCharacters@blinkyLeft
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00     ; BLANK
    SETPOS  $5F $C0
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $01
    ; ------
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $01
    LOOP    $00 $00
    ; ------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $03
    ; ------
    SETN    $20
    LOOP    $04 $00
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00
    DECPTR  $FF     ; BROKEN LOOP?
    ; ------
    ;SETPOS  $00 $00
    CUTEND


;   CAMERA CONTROL
jrScene1Prog4:
    SETBGPRI        $01
    ;SETCHAR jrSceneCharacters@jrPacLeft
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00
    SETPOS  $00 $00 ; $C0 $00
    SETN    $30
    LOOP    $10 $00
    SETN    $80
    LOOP    $10 $00
    SETBGPAL        $01
    SETN    $34
    LOOP    $10 $00
    SETJRVAR        $01
    SETN    $E5 ; $D4
    LOOP    $F0 $00
    ;SETN    $D0 
    ;LOOP    $F0 $00
    CUTEND


;   BALLOON BOTTOM (STRING) CONTROL
jrScene1Prog5:
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    LOOP    $00 $00     ; BLANK
    SETPOS  $7F $D0
    SETPOS  $FF $D0
    SETN    $30
    LOOP    $40 $00     ; BLANK
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00
    DECPTR  $01     ; BROKEN LOOP?
    ; ------
    SETCHAR jrSceneCharacters@balloonBtmStatic  ;
    SETN    $20
    PAUSE
    SETCHAR jrSceneCharacters@balloonBtm
    SETN    $10
    LOOP    $F0 $00
    SETN    $08
    LOOP    $F0 $00
    SETN    $04
    LOOP    $F0 $10
    SETN    $40
    LOOP    $F0 $00
    SETN    $13
    LOOP    $00 $10
    SETN    $20
    LOOP    $00 $00
    SETN    $01
    PAUSE
    SETN    $60
    LOOP    $F0 $00
    SETN    $06
    LOOP    $00 $F0
    SETN    $08
    LOOP    $00 $10
    SETN    $06
    LOOP    $00 $F0
    SETN    $08
    LOOP    $00 $10
    SETN    $60
    LOOP    $F0 $00
    SETN    $20
    LOOP    $F6 $FC
    ;SETN    $08
    SETN    $10
    LOOP    $F0 $00
    SETN    $04
    LOOP    $00 $00
    SETCHAR jrSceneCharacters@balloonBtmFast
    SETN    $40
    LOOP    $00 $00
    SETN    $10
    LOOP    $F0 $00
    ; ------
    CUT_NOP
    SETN    $01
    LOOP    $00 $00
    DECPTR  $FF     ; BROKEN LOOP?
    ; ------
    ;SETPOS  $00 $00
    CUTEND



/*
--------------
    JR PAC-MAN SCENE 2 DATA
--------------
*/

;   JR.PAC-MAN CONTROL
jrScene2Prog0:
    SETJRVAR        $00
    ;SETCHAR jrSceneCharacters@jrPacRight
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $7F $E1
    ;SETPOS  $FD $E1
    SETPOS  $F1 $E1
    SETN    $1C
    MOVE    $40 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $01
    ; --------
    SETCHAR jrSceneCharacters@jrPacRight
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $02
    ; --------
    SETN    $06
    MOVE    $00 $F0
    SETN    $06
    MOVE    $00 $10
    SETN    $06
    MOVE    $00 $F0
    SETN    $06
    MOVE    $00 $10
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $03
    ; --------
    SETCHAR jrSceneCharacters@jrPacLeft
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $04
    ; --------
    SETCHAR jrSceneCharacters@jrPacRight
    SETN    $20
    MOVE    $F0 $00
    SETN    $14
    MOVE    $F0 $06
    ; --------
;   LEAVING FRAME
    CUT_NOP
    SETN    $01
    ;MOVE    $F0 $00 ; $82
    MOVE    $ED $00 ; $61
    DECPTR  $05
    ; --------
    SETN    $01
    PAUSE
    ; --------
;   GOING UP
    CUT_NOP
    SETN    $01
    MOVE    $00 $F0
    DECPTR  $06
    ; --------
    SETN    $01
    PAUSE
    SETN    $01
    PAUSE
    DECPTR  $07
    ; --------
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $FF
    ; --------
    ;SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    CUTEND


;   YUM-YUM CONTROL
jrScene2Prog1:
    SETCHAR jrSceneCharacters@emptySpr
    ;SETCHAR jrSceneCharacters@yumyumLeft
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $7F $E1
    ;SETPOS  $FF $E1
    SETPOS  $F3 $E1
    SETN    $17
    MOVE    $40 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $01
    ; --------
    SETCHAR jrSceneCharacters@yumyumLeft
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $02
    ; --------
    SETCHAR jrSceneCharacters@yumyumUp
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $03
    ; --------
    SETCHAR jrSceneCharacters@yumyumLeft
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $04
    ; --------
    SETCHAR jrSceneCharacters@yumyumRight
    SETN    $10
    MOVE    $F0 $00
    SETN    $14
    MOVE    $F0 $06
    ; --------
;   LEAVING FRAME
    CUT_NOP
    SETN    $01
    ;MOVE    $F0 $00
    MOVE    $ED $00
    DECPTR  $05
    ; --------
;   GOING UP
    SETCHAR jrSceneCharacters@yumyumUp
    SETN    $70
    MOVE    $00 $F0
    SETJRVAR        $06
    SETCHAR jrSceneCharacters@yumyumLeft
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $FF
    ; --------
    ;SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    CUTEND


;   TOP BALLOON CONTROL / HEART CONTROL
jrScene2Prog2:
    SETCHAR jrSceneCharacters@emptySpr
    ;SETCHAR jrSceneCharacters@balloonTopFast
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $7F $D1
    ;SETPOS  $FF $D1
    SETPOS  $F3 $D1
    SETN    $17
    MOVE    $40 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $01
    ; --------
    SETCHAR jrSceneCharacters@balloonTopFast
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $02
    ; --------
    SETN    $90
    MOVE    $00 $F0
    ;SETCHAR jrSceneCharacters@heart
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    MOVE    $00 $00 ; BLANK
    SETN    $30
    MOVE    $90 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $06
    ; --------
    SETCHAR jrSceneCharacters@heart
    ;SETPOS  $60 $60
    ;SETPOS  $54 $60
    SETPOS  $33 $60 ; TOP RIGHT

    SETN    $09
    PAUSE

    SETN    $40
    MOVE    $10 $00
    SETN    $40
    MOVE    $00 $10
    SETN    $40
    MOVE    $F0 $00
    SETN    $40
    MOVE    $00 $F0
    SETJRVAR        $07
    SETN    $FF
    MOVE    $00 $00
    SETN    $40
    MOVE    $00 $00
    ;SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    SETJRVAR        $FF
    CUTEND


;   GHOST CONTROL / HEART CONTROL
jrScene2Prog3:
    SETCHAR jrSceneCharacters@emptySpr
    ;SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $7F $C1
    ;SETPOS  $FF $C1
    SETPOS  $F3 $C1
    SETN    $10
    MOVE    $40 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $01
    ; --------
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $40
    MOVE    $00 $00
    SETN    $25
    MOVE    $20 $00
    SETJRVAR        $02
    SETCHAR jrSceneCharacters@blinkyDown
    SETN    $10
    MOVE    $00 $08
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $0F
    MOVE    $10 $00
    SETN    $30
    MOVE    $00 $00
    SETN    $10
    MOVE    $10 $00
    SETJRVAR        $03
    SETCHAR jrSceneCharacters@blinkyDown
    SETN    $20
    MOVE    $00 $10
    SETCHAR jrSceneCharacters@blinkyRight
    SETN    $06
    MOVE    $F0 $00
    SETN    $06
    MOVE    $10 $00
    SETJRVAR        $04
    SETN    $20
    PAUSE
    SETN    $10
    MOVE    $F0 $00
    SETCHAR jrSceneCharacters@blinkyLeft
    SETN    $01
    MOVE    $00 $00
    ;SETN    $30
    SETN    $38
    MOVE    $10 $00
    ;SETCHAR jrSceneCharacters@heart
    SETCHAR jrSceneCharacters@emptySpr
    ;SETN    $30
    SETN    $28
    MOVE    $90 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $06
    ; --------
    SETCHAR jrSceneCharacters@heart
    ;SETPOS  $60 $A0
    ;SETPOS  $54 $A0
    SETPOS  $33 $A0 ; BOTTOM RIGHT


    SETN    $10
    PAUSE


    SETN    $40
    MOVE    $00 $F0
    SETN    $40
    MOVE    $10 $00
    SETN    $40
    MOVE    $00 $10
    SETN    $40
    MOVE    $F0 $00
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $FF
    ; --------
    ;SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    CUTEND


;   CAMERA CONTROL / HEART CONTROL
jrScene2Prog4:
    SETBGPRI        $01
    SETHIGHX    $01
    SETPOS  $54 $00
    ;SETCHAR jrSceneCharacters@jrPacLeft
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $80 $00
    ;SETPOS  $FF $00
    SETN    $20
    PAUSE
    SETN    $68
    ;MOVE    $20 $00 ; BLANK
    PAUSE
    ;SETBGPAL        $00 ; SHOW BACKGROUND
    SETBGPAL        $FF
    SETJRVAR        $01
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $04
    ; --------
    SETN    $E0
    MOVE    $E8 $00 ; BLANK
    SETJRVAR        $05
    ;SETCHAR jrSceneCharacters@heart
    /*
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $06
    ; --------
    SETCHAR jrSceneCharacters@heart
    SETPOS  $A0 $A0
    SETN    $40
    MOVE    $F0 $00
    SETN    $40
    MOVE    $00 $F0
    SETN    $40
    MOVE    $10 $00
    SETN    $40
    MOVE    $00 $10
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $FF
    ; --------
    SETPOS  $00 $00
    */
    CUTEND


;   BTM BALLOON / MS.PAC-MAN / HEART
jrScene2Prog5:
    SETCHAR jrSceneCharacters@emptySpr
    ;SETCHAR jrSceneCharacters@balloonBtmFast
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $7F $E0
    ;SETPOS  $FF $E0
    SETPOS  $F3 $E0
    SETN    $17
    MOVE    $40 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $01
    ; --------
    SETCHAR jrSceneCharacters@balloonBtmFast
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $02
    ; --------
    SETN    $A0
    MOVE    $00 $F0
    SETN    $01
    MOVE    $00 $00 ; BLANK
    ;SETPOS  $FF $E9
    SETHIGHX    $01
    SETPOS  $C3 $E9
    SETCHAR jrSceneCharacters@msPacRight
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $04
    ; --------
    SETN    $20
    MOVE    $F0 $00
    SETCHAR jrSceneCharacters@msPacLeft
    SETN    $20
    MOVE    $10 $00
    ;SETCHAR jrSceneCharacters@heart
    SETCHAR jrSceneCharacters@emptySpr
    SETN    $30
    MOVE    $90 $00 ; BLANK
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $06
    ; --------
    SETCHAR jrSceneCharacters@heart
    SETHIGHX    $00
    ;SETPOS  $A0 $60
    ;SETPOS  $94 $60
    SETPOS  $73 $60 ; TOP LEFT


    SETN    $04
    PAUSE

    SETN    $40
    MOVE    $00 $10
    SETN    $40
    MOVE    $F0 $00
    SETN    $40
    MOVE    $00 $F0
    SETN    $40
    MOVE    $10 $00
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $FF
    ; --------
    ;SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    CUTEND


;   HEART CONTROL
jrScene2Prog6:
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00 ; BLANK
    DECPTR  $06
    ; --------
    SETCHAR jrSceneCharacters@heart
    ;SETPOS  $A0 $A0
    SETPOS  $73 $A0 ; BOTTOM LEFT
    SETN    $40
    MOVE    $F0 $00
    SETN    $40
    MOVE    $00 $F0
    SETN    $40
    MOVE    $10 $00
    SETN    $40
    MOVE    $00 $10
    ; --------
    CUT_NOP
    SETN    $01
    MOVE    $00 $00
    DECPTR  $FF
    ; --------
    ;SETPOS  $00 $00
    SETCHAR jrSceneCharacters@emptySpr
    CUTEND