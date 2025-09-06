/*
------------------------------------------------
            SOUND RELATED FUNCTIONS
------------------------------------------------
*/


/*
    INFO: CONTROLS GHOST SFX (CHANNEL 1)
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
processGhostSFX:
;   STORE ADDRESS OF SOUND CONTROL IN HL
    LD HL, ghostSoundControl
;   SKIP EYE CHECK IF GAME IS CRAZY OTTO
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    JP NZ, @frightCheck
;   CHECK IF ANY GHOST IS SHOWING EYES
    ; LOOP PREP
    LD B, $04       ; LOOP COUNTER
    LD IX, blinky
    LD DE, _sizeof_ghost
-:
    ; CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    JR Z, @eyeSFX   ; IF NOT, GHOST IS GOING HOME (SHOWING EYES)
    ; CHECK NEXT GHOST
    ADD IX, DE
    DJNZ -      ; IF NOT 0, LOOP
@frightCheck:
    LD B, $01   ; CHANNEL 1
;   CHECK IF SUPER
    LD A, (pacPoweredUp)
    OR A
    JR Z, @sirenCheck   ; IF NOT, SKIP
;   CHECK IF FRIGHT SOUND IS ALREADY PLAYING
    BIT 5, (HL)
    RET NZ  ; IF SO, END
    ; SET FRIGHT BIT
    LD (HL), 1 << 5
    ; PLAY FRIGHT SOUND EFFECT
    LD A, SFX_FRIGHT
    LD D, A
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    ADD A, D
    JP sndPlaySFX
@sirenCheck:
;   PREPARE SOUND ID AND SOUND CONTROL DETERMINATION
    LD DE, SFX_SIREN4 * $100 + $08 ; SOUND CONTROL TYPE TO 8
;   CHECK CURRENT DOT COUNT
    LD A, (currPlayerInfo.dotCount)
    ; CHECK IF LESS THAN 16
    CP A, $E4
    JR NC, @setSiren ; IF SO, SKIP...
    LD DE, SFX_SIREN3 * $100 + $06
    ; CHECK IF LESS THAN 32
    CP A, $D4
    JR NC, @setSiren ; IF SO, SKIP...
    LD DE, SFX_SIREN2 * $100 + $04
    ; CHECK IF LESS THAN 64
    CP A, $B4
    JR NC, @setSiren ; IF SO, SKIP...
    LD DE, SFX_SIREN1 * $100 + $02
    ; CHECK IF LESS THAN 128
    CP A, $74
    JR NC, @setSiren ; IF SO, SKIP...
    LD DE, SFX_SIREN0 * $100 + $00
@setSiren:
;   CHECK IF DETERMINED SOUND CONTROL MATCHES GHOST'S
    LD A, E
    CP A, (HL)
    RET Z   ; IF SO, END
;   SET NEW SOUND CONTROL TYPE
    LD (HL), A
;   ADD 1/2 DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    RRCA
    ADD A, D
    JP sndPlaySFX
@eyeSFX:
;   CHECK IF EYES SOUND IS ALREADY PLAYING
    BIT 6, (HL)
    RET NZ      ; IF SO, END
;   SET EYES BIT
    LD (HL), 1 << 6
;   PLAY EYES SOUND EFFECT
    LD A, SFX_EYES
    LD B, A
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    ADD A, B
    LD B, $01       ; CHANNEL 1
    JP sndPlaySFX




/*
    INFO: CONTROLS CHANNEL 2 SFX
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
processChan2SFX:
;   CHECK IF SOUND CONTROL BITS ARE EMPTY
    LD A, (ch2SoundControl)
    OR A
    RET Z   ; IF SO, END
;   FIND FIRST SET BIT (MSB TO LSB)
    LD C, A
    LD DE, $0780    ; BIT POSITION / BIT VALUE
-:
    LD A, E 
    AND A, C
    JR NZ, +
    SRL E
    DEC D
    JR -
+:
;   GET CORRESPONDING SOUND ID FROM BIT POSITION
    LD A, D
    LD HL, @data
    RST addToHL
;   ADDITIONAL STUFF
    ; SKIP +2/+4 FOR FRUIT AND BOUNCE SFX
    CP A, SFX_FRUIT
    JR Z, +
    CP A, SFX_BOUNCE
    JR Z, +
    ; ADD 2/4 DEPENDING ON GAME
    LD B, A
    LD A, (plusBitFlags)    ; ISOLATE MS. PAC BIT
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    ADD A, B                ; ADD TO MUSIC ID
+:
;   CHECK IF SOUND IS ALREADY PLAYING
    LD B, A
    LD A, (chan2 + SND_ID)
    CP A, B
    RET Z               ; IF SO, END
    ; ELSE, PLAY SFX
    LD A, B
    LD B, $02           ; CHANNEL 2
    JP sndPlaySFX
;   CALLED FROM SOUND DRIVER
@soundEnded:
;   CHECK IF SOUND CONTROL BITS ARE EMPTY
    LD A, (ch2SoundControl)
    OR A
    RET Z       ; IF SO, END
;   SAVE REGS
    PUSH BC
;   FIND FIRST SET BIT (MSB TO LSB)
    LD B, A
    LD C, $80   ; BIT VALUE
-:
    LD A, C
    AND A, B
    JR NZ, +
    SRL C
    JR -
+:
;   CLEAR BIT
    LD A, C
    CPL
    AND A, B
    LD (ch2SoundControl), A
;   CLEAN UP
    POP BC
    RET
@data:
    .DB SFX_DOT0 SFX_DOT1 SFX_FRUIT SFX_EATGHOST SFX_BOUNCE
