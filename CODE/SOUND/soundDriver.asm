/*
------------------------------------------------
                SOUND DRIVER CODE
------------------------------------------------
*/

;   CHANNEL CONTROL BITS
.DEFINE CHANCON_REST        1
.DEFINE CHANCON_LITERAL     3
.DEFINE CHANCON_NOATTACK    4
.DEFINE CHANCON_PLAYING     7

;   PSG CHANNEL BITS
.DEFINE CHAN0_BITS  $00
.DEFINE CHAN1_BITS  $20
.DEFINE CHAN2_BITS  $40
.DEFINE CHAN3_BITS  $60
.DEFINE CHAN_COUNT  $04

.DEFINE CHANALL_BITS    $60

.DEFINE CF_START    $E0

;   COORDINATION FLAGS
.ENUM CF_START
    CF_PANNING  DB  ; $E0
    CF_DETUNE   DB  ; $E1
    CF_SETCOMM  DB  ; $E2
    CF_CALLRET  DB  ; $E3
    CF_FADEIN   DB  ; $E4
    CF_TEMPODIV DB  ; $E5
    CF_CHGFMVOL DB  ; $E6
    CF_HOLD     DB  ; $E7
    CF_TIMEOUT  DB  ; $E8
    CF_TRANSPOS DB  ; $E9
    CF_TEMPO    DB  ; $EA
    CF_TEMPODIV_ALL DB  ; $EB
    CF_CHGVOL   DB  ; $EC
    CF_CLRPUSH  DB  ; $ED
    CF_READLITERAL  DB  ; $EE
    CF_FMVOICE  DB  ; $EF
    CF_MODSETUP DB  ; $F0
    CF_MODON    DB  ; $F1
    CF_STOP     DB  ; $F2
    CF_SETNOISE DB  ; $F3
    CF_MODOFF   DB  ; $F4
    CF_PSGENV   DB  ; $F5
    CF_JUMP     DB  ; $F6
    CF_LOOP     DB  ; $F7
    CF_CALL     DB  ; $F8
.ENDE



/*
    INFO: MAIN SOUND UPDATE
    USES: IY, AF, BC, HL, DE
*/
sndProcess:
;   DON'T UPDATE WHEN PAUSED
    LD A, (pauseRequest)
    OR A
    JP NZ, sndStopAll@write
;   DON'T UPDATE WHEN IN ATTRACT MODE (EXCEPT FOR TITLE AND OPTIONS)
    LD HL, (mainGameMode)   ; L: MAIN, H: SUB
    LD A, L
    CP A, M_STATE_ATTRACT
    JP NZ, +
    LD A, H
    CP A, ATTRACT_TITLE
    JP Z, +
    CP A, ATTRACT_OPTIONS
    JP NZ, sndStopAll@write
+:
;   SETUP
    LD A, SND_BANK              ; SOUND BANK
    LD (MAPPER_SLOT2), A
    LD IY, chan0                ; CHANNEL POINTER
    LD BC, CHAN_COUNT * $100    ; LOOP COUNTER AND CHANNEL NUMBER
@loop:
;   PROCESS CHANNEL LOOP
    ; LOAD CHANNEL POINTER
    LD E, (IY + POINTER_00)
    LD D, (IY + POINTER_01)
    ; SAVE LOOP COUNTER AND CHANNEL NUMBER
    PUSH BC
    ; CHECK IF CHANNEL IS PLAYING
    BIT CHANCON_PLAYING, (IY + CHAN_CONTROL)
    JP Z, @prepareNext   ; IF NOT, PROCESS NEXT CHANNEL
    ; CHECK IF NOTE DURATION IS 0 AFTER DECREMENT
    DEC (IY + DUR_COUNTER)
    JP NZ, @@noteGoing     ; IF NOT, SKIP
    RES CHANCON_NOATTACK, (IY + CHAN_CONTROL)  ; CLEAR NO-ATTACK BIT
    CALL getNextByte    ; GET NEXT BYTE
    CALL noteOn         ; DO NOTE ON
    CALL updateEnvelope@noCheck     ; UPDATE ENVELOPE
    JP @prepareNext     ; PREPARE FOR NEXT CHANNEL
@@noteGoing:
    CALL updateEnvelope ; UPDATE ENVELOPE
    CALL updateFreq     ; UPDATE FREQUENCY
    ; FALL THROUGH
@prepareNext:
    ; GET BACK LOOP COUNTER AND CHANNEL NUM
    POP BC
    ; SAVE CHANNEL POINTER
    LD (IY + POINTER_00), E
    LD (IY + POINTER_01), D
    ; POINT TO NEXT CHANNEL
    LD DE, _sizeof_sndChannel
    ADD IY, DE
    ; SET CHANNEL BITS FOR NEXT CHANNEL
    LD A, CHAN1_BITS
    ADD A, C
    LD C, A
    ; LOOP AGAIN IF B ISN'T 0
    DJNZ sndProcess@loop
    ; RESTORE BANK
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
    RET


/*
------------------------------------------------
        FUNCTIONS USED BY MAIN UPDATE
------------------------------------------------
*/

getNextByte:
;   CLEAR REST BIT
    RES CHANCON_REST, (IY + CHAN_CONTROL)
@loop:
;   GET NEXT BYTE
    LD A, (DE)
    INC DE
;   CHECK IF IT IS COORDINATION FLAG
    CP A, CF_START
    JP C, +     ; IF NOT, END COORD. FLAG PROCESSING
    CALL processCF      ; PROCESS COORD. FLAG
    JP getNextByte@loop ; LOOP
+:
;   CHECK IF LITERAL READ MODE IS ON
    BIT CHANCON_LITERAL, (IY + CHAN_CONTROL)
    JP NZ, readLiteral  ; IF SO, READ IT
;   CHECK IF IT IS DURATION
    OR A
    JP P, + ; IF SO, PROCESS IT
;   SET CHANNEL FREQUENCY
    CALL setFreq
;   GET NEXT BYTE
    LD A, (DE)
;   CHECK IF IT IS DURATION
    OR A
    JP M, finishTrackUpdate ; IF NOT, SKIP...
    INC DE
+:
    CALL processDuration
    JP finishTrackUpdate

    
setFreq:
;   CHECK IF NOTE IS REST
    SUB A, $81
    JP C, @restNote ; IF SO, PROCESS IT
;   ADD NOTE DISPLACEMENT
    ADD A, (IY + NOTE_DISPLACE)
    ; CLEAR HIGH BYTE AND SIGN BIT???
    ADD A, A
;   ADD TO FREQUENCY TABLE
    LD HL, sndFreqTable
    ;RST addToHL     ; GET NOTE FREQ
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    ;
    LD A, (HL)
    LD (IY + FREQ_00), A
    INC HL
    LD A, (HL)
    LD (IY + FREQ_01), A
;   FINISH
    JP finishTrackUpdate
@restNote:
;   SET REST BIT
    SET CHANCON_REST, (IY + CHAN_CONTROL)
;   MAKE FREQ INVALID
    LD (IY + FREQ_00), $FF
    LD (IY + FREQ_01), $FF
    CALL finishTrackUpdate
;   SILENCE CHANNEL
    JP sndStopChannel@clrChan


readLiteral:
;   WORD IS BIG ENDIAN!!!
    LD H, A     ; STORE 'LOW' BYTE IN H
    LD A, (DE)
    INC DE
    LD L, A     ; STORE 'HIGH' BYTE IN L
;   CHECK IF WORD IS 0
    OR A, H
    JP Z, setFreq@restNote  ; IF SO, DO REST NOTE
    ; NOTE TRANSPOSITION GETS ADDED HERE?
;   STORE FREQUENCY
    LD (IY + FREQ_00), L
    LD (IY + FREQ_01), H
;   GET NEXT BYTE (ALWAYS DURATION)
    LD A, $01   ; FIXED DURATION NUMBER
    CALL processDuration
    JP finishTrackUpdate


noteOn:
;   CHECK IF FREQUENCY IS INVALID
    BIT 7, (IY + FREQ_01)
    JP NZ, setRest  ; IF SO, SKIP
updateFreq:
;   CHECK IF REST BIT IS SET
    BIT CHANCON_REST, (IY + CHAN_CONTROL)
    RET NZ   ; IF SO, END
;   GET FREQ
    LD L, (IY + FREQ_00)
    LD H, (IY + FREQ_01)
;   ADD DETUNE (SIGN EXTEND FIRST)
    LD A, (IY + DETUNE)
    OR A
    JP P, +
    DEC H
+:
    ;RST addToHL
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    ; BYTE 0 (LOW NIBBLE)
    LD A, L
    AND A, $0F  ; GET LOWER NIBBLE
    OR A, $80   ; LATCH
    OR A, C     ; CHANNEL
    OUT (PSG_PORT), A
    ; BYTE 1 (HIGH NIBBLE)
    ; RIGHT SHIFT HL BY 4
    LD A, L
    SRL H   ; HIGH BYTE ONLY CAN HAVE 2 BITS, SO ONLY DEAL WITH IT TWICE
    RRA
    SRL H
    RRA
    RRA
    RRA
    AND A, $3F  ; KEEP ONLY LOWER 6 BITS
    OUT (PSG_PORT), A
    RET
setRest:
;   SET REST BIT
    SET CHANCON_REST, (IY + CHAN_CONTROL)
    RET


updateEnvelope:
;   CHECK IF ENVELOPE IS 0
    LD A, (IY + ENVELOPE)
    OR A
    RET Z   ; IF SO, RETURN
@noCheck:
;   GET VOLUME
    LD B, (IY + VOLUME)
;   CHECK IF ENVELOPE IS 0
    LD A, (IY + ENVELOPE)
    OR A
    JP Z, setVolume    ; IF SO, SKIP ENVELOPE PROCESSING
;   GET ENVELOPE ADDRESS
    LD HL, psgIndexTable
    DEC A
    ADD A, A
    ;RST addToHL
    ;RST getDataAtHL
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   PUT ENVELOPE POSITION INTO HL
    LD A, (IY + ENVELOPE_IDX)
    ;RST addToHL
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    INC (IY + ENVELOPE_IDX)
    ; CHECK IF VALUE IS $80 OR ABOVE
    BIT 7, (HL)
    JP M, envelopeHold  ; IF SO, SKIP
    ; ADD CHANNEL VOLUME TO ENVELOPE VOLUME
    LD A, B
    ADD A, (HL)
    LD B, A
setVolume:
;   CHECK IF REST BIT IS SET
    BIT CHANCON_REST, (IY + CHAN_CONTROL)
    RET NZ   ; IF SO, END
;   CHECK IF NO-ATTACK BIT IS SET (ONLY NEEDED IF IMPLEMENTING NOTE TIMEOUT)

;   LIMIT VOLUME TO <= $0F
    LD A, B
    CP A, $10
    JP C, +
    LD B, $0F
+:
;   CHECK IF NOISE TYPE IS SET FOR TONE 2
    LD A, $01
    LD I, A
    LD A, (sndNoiseType)
    AND A, $03
    CP A, $03
    JP NZ, +    ; IF NOT, SKIP...
;   CHECK IF CURRENT CHANNEL IS CHANNEL 2
    LD A, C
    AND A, CHANALL_BITS
    CP A, CHAN2_BITS
    JP NZ, +    ; IF NOT, SKIP
;   ELSE, WRITE VOLUME TO CHANNEL 3 INSTEAD
    LD A, C
    ADD A, CHAN1_BITS
    LD C, A
    XOR A
    LD I, A
+:
    LD A, B
    OR A, C
    OR A, $90
    OUT (PSG_PORT), A
;   CHECK IF FLAG WAS SET
    LD A, I
    DEC A
    RET Z
;   ELSE, RESTORE CHANNEL BITS
    LD A, C
    SUB A, CHAN1_BITS
    LD C, A
    RET

envelopeHold:
    DEC (IY + ENVELOPE_IDX)
    RET

processDuration:
;   SET DURATION
    LD (IY + DURATION), A
;   SET COUNTER
    LD (IY + DUR_COUNTER), A
    RET

finishTrackUpdate:
;   RESET DURATION
    LD A, (IY + DURATION)
    LD (IY + DUR_COUNTER), A
;   RESET ENVELOPE INDEX ONLY IF NO ATTACK FLAG IS CLEAR
    BIT CHANCON_NOATTACK, (IY + CHAN_CONTROL)
    RET NZ
    LD (IY + ENVELOPE_IDX), $00
    RET


processCF:
    LD HL, cfTable@return
    PUSH HL
;   CONVERT FLAG INTO OFFSET
    SUB A, CF_START
    ADD A, A
;   ADD TO TABLE
    LD HL, cfTable
    ;RST addToHL
    ;RST getDataAtHL
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   GET FUNCTION PTR AT ADDRESS
;   GET DATA FROM CHANNEL
    LD A, (DE)
;   EXECUTE JUMP
    JP (HL)

cfTable:
    .DW @return             ; $E0 (AMS/FMS/PANNING)
    .DW @cfDetune           ; $E1 (DETUNE)
    .DW @return             ; $E2 (SET COMMUNICATION)
    .DW @return             ; $E3 (CALL RETURN)
    .DW @return             ; $E4 (FADE IN)
    .DW @return             ; $E5 (SET TEMPO DIVIDER SINGLE)
    .DW @return             ; $E6 (CHANGE FM VOL)
    .DW @return             ; $E7 (HOLD NOTE)
    .DW @return             ; $E8 (NOTE TIMEOUT)
    .DW @return             ; $E9 (CHANGE TRANSPOSITION)
    .DW @return             ; $EA (SET TEMPO)
    .DW @return             ; $EB (SET TEMPO DIVIDER ALL)
    .DW @cfChangePSGVol     ; $EC (CHANGE PSG VOL)
    .DW @return             ; $ED (CLEAR PUSH)
    .DW @cfReadLiteral      ; $EE (READ LITERAL MODE)
    .DW @return             ; $EF (SET FM VOICE)
    .DW @return             ; $F0 (MODULATION SETUP/ON)
    .DW @return             ; $F1 (MODULATION ON)
    .DW @cfStopTrack        ; $F2 (STOP TRACK)
    .DW @cfSetPSGNoise      ; $F3 (SET PSG NOISE)
    .DW @return             ; $F4 (MODULATION OFF)
    .DW @cfSetEnvelope      ; $F5 (SET PSG ENVELOPE)
    .DW @cfJumpTo           ; $F6 (JUMP TO)
    .DW @return             ; $F7 (LOOP SECTION)
    .DW @return             ; $F8 (CALL)

    
@return:
    INC DE
    RET


;   ---------------------------------------------
;   E1 - CHANGE DETUNE
@cfDetune:
    ; SET DETUNE
    LD (IY + DETUNE), A    
    RET
;   ---------------------------------------------
;   EC - VOLUME CHANGE
@cfChangePSGVol:
    ; SET VOLUME
    ADD A, (IY + VOLUME)
    LD (IY + VOLUME), A    
    RET
;   ---------------------------------------------
;   EE - REAL LITERAL MODE
@cfReadLiteral:
    ; CHECK IF BYTE IS 0
    OR A
    JP Z, + ; IF SO, SKIP
    ; SET LITERAL READ BIT
    SET CHANCON_LITERAL, (IY + CHAN_CONTROL)
    RET
+:
    ; CLEAR LITERAL READ BIT
    RES CHANCON_LITERAL, (IY + CHAN_CONTROL)
    RET
;   ---------------------------------------------
;   F2 - STOP
@cfStopTrack:
    ; CLEAR NO ATTACK BIT
    RES CHANCON_NOATTACK, (IY + CHAN_CONTROL)
    ; CLEAR PLAYING BIT
    RES CHANCON_PLAYING, (IY + CHAN_CONTROL)
    ; CLEAR SOUND ID
    LD (IY + SND_ID), $00
    ; SILENCE CHANNEL
    CALL sndStopChannel@postCalcNoClear
    ; PROCESS CH2 SOUND CONTROL
    LD A, (ch2SoundControl)
    OR A
    CALL NZ, processChan2SFX@soundEnded  ; IF SO, CALL
    ;
    LD A, (ch2SndControlJR)
    OR A
    CALL NZ, processChan2SFXJR@soundEnded
    ; REMOVE CALLERS
    POP HL  ; CF RETURN CALLER
    POP HL  ; CF PROCESS CALLER
    POP HL  ; GET DATA CALLER
    ; CHANNEL PROCESS END
    JP sndProcess@prepareNext
;   ---------------------------------------------
;   F3 - NOISE TYPE
@cfSetPSGNoise:
    ; SET NOISE TYPE
    LD (sndNoiseType), A
    ; SEND TO PSG
    OUT (PSG_PORT), A
    RET
;   ---------------------------------------------
;   F5 - SET PSG ENVELOPE
@cfSetEnvelope:
    LD (IY + ENVELOPE), A
    RET
;   ---------------------------------------------
;   F6 - JUMP TO ADDRESS
@cfJumpTo:
    ; SET CHANNEL POINTER TO GIVEN ADDRESS
    EX DE, HL
    LD E, (HL)
    INC HL
    LD D, (HL)
    DEC DE
    RET



/*
------------------------------------------------
                AUX FUNCTIONS
------------------------------------------------
*/


/*
    A: SOUND NUMBER [81 -> XX] (80 IS CONSIDERED STOP)
    B: CHANNEL      [0 -> 3]

    USED: AF, HL, DE, BC, IY
*/
sndPlaySFX:
;   SET BANK
    PUSH AF
    LD A, SND_BANK
    LD (MAPPER_SLOT2), A
    POP AF
;
    LD IY, chan0
;   CHECK IF CHANNEL NUMBER IS 0
    INC B
    DEC B
    JP Z, + ; IF SO, SKIP
;   ELSE, CALCULATE ADDRESS FROM CHANNEL NUM
    LD DE, _sizeof_sndChannel
-:  
    ADD IY, DE
    DJNZ -
+:
    LD (IY + SND_ID), A
;   SET POINTER
    ; CONVERT SOUND NUMBER TO TABLE OFFSET
    SUB A, $81
    ADD A, A
    ; ADD OFFSET TO BASE TABLE
    LD HL, sndIndexTable
    LD E, A
    LD D, $00
    ADD HL, DE
    ; LOAD ADDRESS AT OFFSET
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    PUSH HL
    ; LOAD ADDRESS AT OFFSET
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; SET POINTER AND START POINTER
    LD (IY + POINTER_00), L
    LD (IY + START_PTR_00), L
    LD (IY + POINTER_01), H
    LD (IY + START_PTR_01), H
    POP HL
    INC HL
    INC HL
;   SET NOTE DISPLACE
    LD A, (HL)
    INC HL
    LD (IY + NOTE_DISPLACE), A
;   SET VOLUME
    LD A, (HL)
    INC HL
    LD (IY + VOLUME), A
    LD (IY + START_VOLUME), A
;   SET ENVELOPE
    INC HL
    LD A, (HL)
    LD (IY + ENVELOPE), A
;   RESET DETUNE
    LD (IY + DETUNE), $00
;   RESET DURATIONS
    LD (IY + DURATION), $00
    LD (IY + DUR_COUNTER), $01
;   SET PLAYING FLAG, CLEAR REST, ATTACK
    LD (IY + CHAN_CONTROL), $01 << CHANCON_PLAYING
;   RESTORE BANK
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
;   CHECK IF CHANNEL 2 IS SELECTED
    LD HL, chan2
    LD E, IYL
    LD D, IYH
    OR A
    SBC HL, DE
    RET NZ  ; IF NOT, EXIT
    ; CLEAR NOISE TYPE
    XOR A
    LD (sndNoiseType), A
    ; CLEAR BOTH CHANNEL 2 AND 3'S VOLUME
    LD C, CHAN2_BITS
    JP sndStopChannel@clrChan



/*
    A: SOUND NUMBER [81 -> XX] (80 IS CONSIDERED STOP)

    USED: AF, HL, DE, BC, IY
*/
sndPlayMusic:
;   SET BANK
    PUSH AF
    LD A, SND_BANK
    LD (MAPPER_SLOT2), A
    POP AF
;
    LD IY, chan0
;   SET POINTER
    ; CONVERT SOUND NUMBER TO TABLE OFFSET
    SUB A, $81
    ADD A, A
    ; ADD OFFSET TO BASE TABLE
    LD HL, sndIndexTable
    RST addToHL
    ; LOAD ADDRESS AT OFFSET
    RST getDataAtHL
    ; POINT TO NUMBER OF CHANNELS BYTE
    INC HL
    INC HL
    INC HL
    LD B, (HL)  ; STORE IN B
    INC HL      ; (AT TEMPO MULT)
    INC HL      ; (AT TEMPO)
-:
    ; POINT TO POINTER OF CHANNEL
    INC HL
    PUSH HL ; SAVE
    ; LOAD ADDRESS AT OFFSET
    RST getDataAtHL
    ; SET POINTER AND START POINTER
    LD (IY + POINTER_00), L
    LD (IY + START_PTR_00), L
    LD (IY + POINTER_01), H
    LD (IY + START_PTR_01), H
    POP HL  ; RESTORE
    INC HL
    INC HL
;   SET NOTE DISPLACE
    LD A, (HL)
    INC HL
    LD (IY + NOTE_DISPLACE), A
;   SET VOLUME
    LD A, (HL)
    INC HL
    LD (IY + VOLUME), A
    LD (IY + START_VOLUME), A
;   SET ENVELOPE
    INC HL
    LD A, (HL)
    LD (IY + ENVELOPE), A
;   RESET DETUNE
    LD (IY + DETUNE), $00
;   RESET DURATIONS
    LD (IY + DURATION), $00
    LD (IY + DUR_COUNTER), $01
;   SET PLAYING FLAG
    LD (IY + CHAN_CONTROL), $01 << CHANCON_PLAYING
;   KEEP GOING FOR ALL CHANNELS USED
    LD DE, _sizeof_sndChannel
    ADD IY, DE
    DJNZ -
;   RESTORE BANK
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
;   END
    XOR A
    LD (sndNoiseType), A
    RET





/*
    B: CHANNEL
*/
sndStopChannel:
    LD IY, chan0
    LD C, $00   ; CHANNEL 0
    LD A, B     ; MOVE CHANNEL NUMBER TO A
;   CHECK IF CHANNEL NUMBER IS 0
    OR A
    JP Z, @postCalcChan ; IF SO, SKIP
;   CALC ADDRESS FROM CHANNEL NUM
    LD DE, _sizeof_sndChannel
-:  
    ADD IY, DE  ; POINT TO NEXT CHANNEL
    LD A, C     ; HAVE NEXT CHANNEL BITS
    ADD A, CHAN1_BITS
    LD C, A
    DJNZ -
@postCalcChan:
;   CLEAR PLAYING FLAG
    LD (IY + CHAN_CONTROL), $00
@postCalcNoClear:
@clrChan:
;   WRITE MAX ATTENUATION TO CHANNEL
    LD A, ~CHANALL_BITS
    OR A, C     ; OR WITH CHANNEL
    OUT (PSG_PORT), A
;   CHECK IF CHANNEL IS 02
    LD A, C
    CP A, CHAN2_BITS
    RET NZ  ; IF NOT, EXIT
;   ELSE, CLEAR CHANNEL 3 VOLUME AS WELL
    LD A, ~CHANALL_BITS
    OR A, CHAN3_BITS
    OUT (PSG_PORT), A
    RET

sndInit:
;   CLEAR ALL SOUND VARIABLES
    XOR A
    LD HL, sndNoiseType
    LD (HL), A
    LD DE, sndNoiseType + 1
    LD BC, _sizeof_sndChannel * 4 + 3
    LDIR
;   FALL THROUGH


/*
    NO ARGUMENTS
*/
sndStopAll:
    XOR A
;   CLEAR PLAYING FLAGS 
    LD B, CHAN_COUNT
    LD HL, chan0.chanControl
    LD DE, _sizeof_sndChannel
-:
    LD (HL), A
    ADD HL, DE
    DJNZ -
@write:
;   WRTIE MAX ATTENUATION TO ALL CHANNELS
    LD A, ~CHANALL_BITS
    LD B, CHAN_COUNT
-:
    OUT (PSG_PORT), A
    ADD A, CHAN1_BITS
    DJNZ -
    RET

