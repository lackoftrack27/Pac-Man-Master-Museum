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

;   REGISTER BITS
.DEFINE OP_BIT      $04     ; 0 - FREQUENCY, 1 - VOLUME
.DEFINE CHAN_BIT0   $05
.DEFINE CHAN_BIT1   $06
.DEFINE LATCH_BIT   $07

;   PSG CHANNEL BITS
.DEFINE CHAN0_BITS  $00
.DEFINE CHAN1_BITS  $01 << CHAN_BIT0
.DEFINE CHAN2_BITS  $01 << CHAN_BIT1
.DEFINE CHAN3_BITS  ($01 << CHAN_BIT0) | ($01 << CHAN_BIT1)
.DEFINE CHANALL_BITS    CHAN3_BITS
.DEFINE LATCH_VOL   ($01 << OP_BIT) | ($01 << LATCH_BIT)


;   PSG NOISE TYPES
.DEFINE NOISE_TONE0 $00
.DEFINE NOISE_TONE1 $01
.DEFINE NOISE_TONE2 $02
.DEFINE NOISE_PULSE $03

;   COUNTS
.DEFINE TRACK_COUNT $03
.DEFINE CHAN_COUNT  $04

;   STARTING COORDINATION FLAG ID
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
    CF_SETSWINGFLAG  DB  ; $ED
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
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IY
*/
sndProcess:
;   DON'T UPDATE WHEN IN ATTRACT MODE (EXCEPT FOR TITLE AND OPTIONS)
    LD HL, (mainGameMode)   ; L: MAIN, H: SUB
    LD A, L
    CP A, M_STATE_ATTRACT
    JP NZ, @swingCheck
    LD A, H
    CP A, ATTRACT_TITLE
    JP Z, @swingCheck
    CP A, ATTRACT_OPTIONS
    JP NZ, sndStopAll@write
@swingCheck:
;   SWING FLAG CHECK (JR CUTSCENE 3 ONLY)
    LD A, (jrSwingFlag)
    OR A
    JP Z, @updateTracks ; SKIP IF NOT SET
    ; DECREMENT AND KEEP WITHIN RANGE (1 - 7)
    LD HL, jrSwingCounter
    DEC (HL)
    JP NZ, +
    LD (HL), $07
+:
    ; DON'T DO SOUND PROCESSING IF COUNTER == 1
    LD A, (HL)
    DEC A
    RET Z
@updateTracks:
;   SET BANK
    LD A, SOUND_BANK
    LD (MAPPER_SLOT2), A
;   TRACK 0 UPDATE
    LD IY, chan0
    LD C, CHAN0_BITS
    BIT CHANCON_PLAYING, (IY + CHAN_CONTROL)
    CALL NZ, trackUpdate
;   TRACK 1 UPDATE
    LD IY, chan1
    LD C, CHAN1_BITS
    BIT CHANCON_PLAYING, (IY + CHAN_CONTROL)
    CALL NZ, trackUpdate
;   TRACK 2 UPDATE
    LD IY, chan2
    LD C, CHAN2_BITS
    BIT CHANCON_PLAYING, (IY + CHAN_CONTROL)
    CALL NZ, trackUpdate
;   RESTORE BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    RET




/*
------------------------------------------------
            TRACK UPDATE FUNCTION
------------------------------------------------
*/
trackUpdate:
;   LOAD TRACK POINTER
    LD E, (IY + POINTER_00)
    LD D, (IY + POINTER_01)
;   CHECK IF NOTE DURATION IS 0 AFTER DECREMENT
    DEC (IY + DUR_COUNTER)
    JP NZ, @noteGoing     ; IF NOT, A NOTE IS CURRENTLY PLAYING
/*
    ---------
    A NOTE IS NOT CURRENTLY PLAYING...
    ---------
*/
    RES CHANCON_NOATTACK, (IY + CHAN_CONTROL)  ; CLEAR NO-ATTACK BIT
;
;   GET NEXT BYTE
;
@getNextByte:
;   CLEAR REST BIT
    RES CHANCON_REST, (IY + CHAN_CONTROL)
@@readLoop:
;   GET NEXT BYTE
    LD A, (DE)
    INC DE
;   CHECK IF IT IS COORDINATION FLAG
    CP A, CF_START
    JP NC, processCF    ; PROCESS COORD. FLAG
;   CHECK IF LITERAL READ MODE IS ON
    BIT CHANCON_LITERAL, (IY + CHAN_CONTROL)
    JP NZ, readLiteral  ; IF SO, READ IT
;   CHECK IF IT IS DURATION
    OR A
    JP P, @updateDuration ; IF SO, PROCESS IT
;   SET TRACK FREQUENCY
    CALL setFreq
;   GET NEXT BYTE
    LD A, (DE)
;   CHECK IF IT IS DURATION
    OR A
    JP M, @rstDurationCounter   ; IF NOT, SKIP...
    INC DE
@updateDuration:
    CALL processDuration
@rstDurationCounter:
;   RESET DURATION COUNTER
    LD A, (IY + DURATION)
    LD (IY + DUR_COUNTER), A
;   RESET ENVELOPE INDEX ONLY IF NO ATTACK FLAG IS CLEAR
    BIT CHANCON_NOATTACK, (IY + CHAN_CONTROL)
    JP NZ, @noteOn
    LD (IY + ENVELOPE_IDX), $00
;
;   NOTE ON
;
@noteOn:
;   CHECK IF FREQUENCY IS INVALID
    BIT 7, (IY + FREQ_01)
    JP Z, +  ; IF SO, SKIP
;   SET REST BIT
    SET CHANCON_REST, (IY + CHAN_CONTROL)
    JP @updateEnvelope_noChk
+:
;
;   UPDATE FREQ
;
;   CHECK IF REST BIT IS SET
    BIT CHANCON_REST, (IY + CHAN_CONTROL)
    JP NZ, @updateEnvelope_noChk
;   GET FREQ
    LD L, (IY + FREQ_00)
    LD H, (IY + FREQ_01)
;   ADD DETUNE (SIGN EXTEND FIRST)
    LD A, (IY + DETUNE)
    OR A
    JP P, +
    DEC H
+:
    addToHL_M
;   BYTE 0 (LOW NIBBLE)
    LD A, L
    AND A, $0F  ; GET LOWER NIBBLE
    OR A, $01 << LATCH_BIT
    OR A, C     ; CHANNEL BITS
    OUT (PSG_PORT), A
;   BYTE 1 (HIGH NIBBLE)
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
;
;   UPDATE ENVELOPE (NO CHECK)
;
@updateEnvelope_noChk:
    LD B, (IY + VOLUME)
;   CHECK IF TRACK IS USING A ENVELOPE
    LD A, (IY + ENVELOPE)
    OR A
    JP Z, +    ; IF NOT, SKIP ENVELOPE UPDATE (BUT STILL WRITE VOLUME TO PSG)
;   GET ENVELOPE ADDRESS
    LD HL, psgIndexTable
    DEC A
    ADD A, A
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   ADD ENVELOPE POSITION TO BASE POINTER
    LD A, (IY + ENVELOPE_IDX)
    addToHL_M
;   CHECK IF VALUE IS $80 OR ABOVE
    BIT 7, (HL)
    JP M, @prepareNext  ; IF SO, SKIP (END OF ENVELOPE, MAINTAIN VOLUME)
    INC (IY + ENVELOPE_IDX)
;   ADD TRACK VOLUME TO ENVELOPE VOLUME
    LD A, B
    ADD A, (HL)
    LD B, A
+:
;
;   UPDATE VOLUME
;
;   CHECK IF REST BIT IS SET
    BIT CHANCON_REST, (IY + CHAN_CONTROL)
    JP NZ, @prepareNext   ; IF SO, END
;   CHECK IF NO-ATTACK BIT IS SET (ONLY NEEDED IF IMPLEMENTING NOTE TIMEOUT)
;   LIMIT VOLUME TO <= $0F
    LD A, B
    CP A, $10
    JP C, +
    LD B, $0F
+:
;   CHECK IF TRACK 02 IS BEING PROCESSED AND NOISE TYPE IS 0x03 ('PERIODIC')
    LD IXL, $00 ; FLAG TO RESTORE CHANNEL BITS
    LD A, (sndNoiseType)
    AND A, $0F  ; ISOLATE THE NOISE TYPE BITS
    OR A, C
    CP A, CHAN2_BITS | NOISE_PULSE
    JP NZ, +    ; IF NOT, SKIP
;   ELSE, WRITE VOLUME TO CHANNEL 3 INSTEAD
    LD C, CHAN3_BITS
    INC IXL     ; SET FLAG (CHANNEL BITS WILL BE RESTORED)
+:
;   WRITE VOLUME TO CHANNEL
    LD A, B
    OR A, C
    OR A, LATCH_VOL
    OUT (PSG_PORT), A
;   CHECK IF FLAG WAS SET
    DEC IXL
    JP NZ, @prepareNext  ; IF NOT, SKIP
;   ELSE, RESTORE CHANNEL BITS
    LD C, CHAN2_BITS
;   PREPARE FOR NEXT TRACK
    JP @prepareNext
/*
    ---------
    A NOTE IS CURRENTLY PLAYING...
    ---------
*/
@noteGoing:
;   CHECK IF TRACK IS USING A ENVELOPE
    LD A, (IY + ENVELOPE)
    OR A
    JP Z, @updateFreq   ; IF NOT, SKIP ENVELOPE UPDATE && VOLUME WRITE
;
;   UPDATE ENVELOPE
;
    LD B, (IY + VOLUME)
;   GET ENVELOPE ADDRESS
    LD HL, psgIndexTable
    DEC A
    ADD A, A
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   ADD ENVELOPE POSITION TO BASE POINTER
    LD A, (IY + ENVELOPE_IDX)
    addToHL_M
;   CHECK IF VALUE IS $80 OR ABOVE
    BIT 7, (HL)
    JP M, @updateFreq   ; IF SO, SKIP (END OF ENVELOPE, KEEP VOLUME)
    INC (IY + ENVELOPE_IDX)
;   ADD TRACK VOLUME TO ENVELOPE VOLUME
    LD A, B
    ADD A, (HL)
    LD B, A
+:
;
;   UPDATE VOLUME
;
;   CHECK IF REST BIT IS SET
    BIT CHANCON_REST, (IY + CHAN_CONTROL)
    JP NZ, @updateFreq   ; IF SO, END
;   CHECK IF NO-ATTACK BIT IS SET (ONLY NEEDED IF IMPLEMENTING NOTE TIMEOUT)
;   LIMIT VOLUME TO <= $0F
    LD A, B
    CP A, $10
    JP C, +
    LD B, $0F
+:
;   CHECK IF TRACK 02 IS BEING PROCESSED AND NOISE TYPE IS 0x03 ('PERIODIC')
    LD IXL, $00 ; FLAG TO RESTORE CHANNEL BITS
    LD A, (sndNoiseType)
    AND A, $0F  ; ISOLATE THE NOISE TYPE BITS
    OR A, C
    CP A, CHAN2_BITS | NOISE_PULSE
    JP NZ, +    ; IF NOT, SKIP
;   ELSE, WRITE VOLUME TO CHANNEL 3 INSTEAD
    LD C, CHAN3_BITS
    INC IXL     ; SET FLAG (CHANNEL BITS WILL BE RESTORED)
+:
;   WRITE VOLUME TO CHANNEL
    LD A, B
    OR A, C
    OR A, LATCH_VOL
    OUT (PSG_PORT), A
;   CHECK IF FLAG WAS SET
    DEC IXL
    JP NZ, @prepareNext  ; IF NOT, SKIP
;   ELSE, RESTORE CHANNEL BITS
    LD C, CHAN2_BITS
;
;   UPDATE FREQ
;
@updateFreq:
;   CHECK IF REST BIT IS SET
    BIT CHANCON_REST, (IY + CHAN_CONTROL)
    JP NZ, @prepareNext ; IF SO, SKIP FREQUENCY UPDATE
;   GET FREQ
    LD L, (IY + FREQ_00)
    LD H, (IY + FREQ_01)
;   ADD DETUNE (SIGN EXTEND FIRST)
    LD A, (IY + DETUNE)
    OR A
    JP P, +
    DEC H
+:
    addToHL_M
;   BYTE 0 (LOW NIBBLE)
    LD A, L
    AND A, $0F  ; GET LOWER NIBBLE
    OR A, $01 << LATCH_BIT
    OR A, C     ; CHANNEL BITS
    OUT (PSG_PORT), A
;   BYTE 1 (HIGH NIBBLE)
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
@prepareNext:
;   SAVE NEW TRACK POINTER
    LD (IY + POINTER_00), E
    LD (IY + POINTER_01), D
    RET


/*
------------------------------------------------
        FUNCTIONS USED BY TRACK UPDATE
------------------------------------------------
*/
setFreq:
;   CHECK IF NOTE IS REST
    SUB A, $81
    JP C, @restNote ; IF SO, PROCESS IT
;   ADD NOTE DISPLACEMENT
    ADD A, (IY + NOTE_DISPLACE)
    ; CLEAR HIGH BYTE AND SIGN BIT???
    ADD A, A
;   ADD TO FREQUENCY TABLE
    LD HL, sndFreqTable ; GET NOTE FREQ
    addToHL_M
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
    JP sndStopChannel@silenceChan


readLiteral:
;   WORD IS BIG ENDIAN!!!
    LD H, A     ; STORE 'LOW' BYTE IN H
    LD A, (DE)
    INC DE
    LD L, A     ; STORE 'HIGH' BYTE IN L
;   CHECK IF WORD IS 0
    OR A, H
    JP NZ, +    ; IF NOT, SET FREQUENCY
    ; SET REST BIT
    SET CHANCON_REST, (IY + CHAN_CONTROL)
    ; SILENCE CHANNEL
    CALL sndStopChannel@silenceChan
    ; SET INVALID FREQUENCY
    LD HL, $FFFF
+:
    ; NOTE TRANSPOSITION GETS ADDED HERE?
;   STORE FREQUENCY
    LD (IY + FREQ_00), L
    LD (IY + FREQ_01), H
;   GET NEXT BYTE (ALWAYS DURATION)
    LD A, $01   ; FIXED DURATION NUMBER
    JP trackUpdate@updateDuration


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



/*
------------------------------------------------
            COORDINATION FLAG PROCESS
------------------------------------------------
*/
processCF:
;   PUSH RETURN ADDRESS
    LD HL, cfTable@return
    PUSH HL
;   CONVERT FLAG INTO OFFSET
    SUB A, CF_START
    ADD A, A
;   ADD TO TABLE
    LD HL, cfTable
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   GET FUNCTION PTR AT ADDRESS
;   GET DATA FROM TRACK
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
    .DW @cfSetSwingFlag     ; $ED (SET SWING FLAG)
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
    JP trackUpdate@getNextByte@readLoop


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
;   ED - SET JR'S SWING FLAG (USED FOR CUTSCENE 3 ONLY)
@cfSetSwingFlag:
    LD A, $01
    LD (jrSwingFlag), A
    LD (jrSwingCounter), A
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
    CALL sndStopChannel@silenceChan
    ; PROCESS CH2 SOUND CONTROL
    LD A, (ch2SoundControl)
    OR A
    CALL NZ, processChan2SFX@soundEnded
    ; PROCESS CH2 SOUND CONTROL (JR)
    LD A, (ch2SndControlJR)
    OR A
    CALL NZ, processChan2SFXJR@soundEnded
    ; REMOVE CALLERS
    POP HL  ; CF RETURN CALLER
    ; TRACK PROCESS END
    JP trackUpdate@prepareNext
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
    ; SET TRACK POINTER TO GIVEN ADDRESS
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
    INFO: PLAYS A SFX GIVEN ITS ID AND TRACK TO PLAY ON
    INPUT:  A - SOUND NUMBER [81 -> XX] (80 IS CONSIDERED STOP)
            B -TRACK    [0 -> 3]
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IY
*/
sndPlaySFX:
;   SET BANK
    PUSH AF
    LD A, SOUND_BANK
    LD (MAPPER_SLOT2), A
    POP AF
;   SET TRACK POINTER
    LD IY, chan0
    ; CHECK IF TRACK NUMBER IS 0
    INC B
    DEC B
    JP Z, + ; IF SO, SKIP
    ; ELSE, CALCULATE ADDRESS FROM TRACK NUM
    LD DE, _sizeof_sndChannel
-:  
    ADD IY, DE
    DJNZ -
+:
    LD (IY + SND_ID), A
;   SET TRACK DATA
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
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   CHECK IF TRACK 2 IS SELECTED
    LD HL, chan2
    LD E, IYL
    LD D, IYH
    OR A
    SBC HL, DE
    RET NZ  ; IF NOT, EXIT
    ; CLEAR NOISE TYPE
    XOR A
    LD (sndNoiseType), A
    ; CLEAR BOTH TRACK 2 AND 3'S VOLUME
    LD C, CHAN2_BITS
    JP sndStopChannel@silenceChan




/*
    INFO: PLAYS MUSIC TRACK GIVEN ITS ID
    INPUT:  A - SOUND NUMBER [81 -> XX] (80 IS CONSIDERED STOP)
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IY
*/
sndPlayMusic:
;   SET BANK
    PUSH AF
    LD A, SOUND_BANK
    LD (MAPPER_SLOT2), A
    POP AF
;   SET TRACK POINTERS
    LD IY, chan0
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
    ; POINT TO POINTER OF TRACK
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
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
;   END
    XOR A
    LD (sndNoiseType), A
    RET





/*
    INFO: CLEARS TRACK'S PLAYING FLAG AND WRITES MAX ATTENUATION TO ITS CHANNEL
    INPUT: B - TRACK NUMBER
    OUTPUT: NONE
    USES: AF, BC, DE, IY
*/
sndStopChannel:
;   GET TRACK POINTER
    LD IY, chan0
    LD C, $00   ; CHANNEL BITS FOR CHANNEL 0
    LD A, B     ; MOVE TRACK NUMBER TO A
    ; CHECK IF TRACK NUMBER IS 0
    OR A
    JP Z, @postCalcChan ; IF SO, SKIP
    ; CALC ADDRESS FROM TRACK NUM
    LD DE, _sizeof_sndChannel
-:  
    ADD IY, DE  ; POINT TO NEXT TRACK
    LD A, C     ; PREPARE CHANNEL BITS
    ADD A, CHAN1_BITS
    LD C, A
    DJNZ -
@postCalcChan:
;   CLEAR PLAYING FLAG
    LD (IY + CHAN_CONTROL), $00
@silenceChan:
;   WRITE MAX ATTENUATION TO CHANNEL
    LD A, ~CHANALL_BITS
    OR A, C     ; OR WITH CHANNEL BITS
    OUT (PSG_PORT), A
;   CHECK IF TRACK 02 IS BEING PROCESSED
    LD A, C
    CP A, CHAN2_BITS
    RET NZ  ; IF NOT, EXIT
;   ELSE, CLEAR CHANNEL 3 VOLUME AS WELL
    LD A, ~CHANALL_BITS
    OR A, CHAN3_BITS
    OUT (PSG_PORT), A
    RET



/*
    INFO: RESETS ALL SOUND VARIABLES AND REGISTERS
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
sndInit:
;   CLEAR ALL SOUND VARIABLES
    XOR A
    LD HL, sndNoiseType
    LD (HL), A
    LD DE, sndNoiseType + 1
    LD BC, _sizeof_sndChannel * TRACK_COUNT + $03
    LDIR
;   FALL THROUGH


/*
    INFO: CLEARS PLAYING FLAGS FOR ALL TRACKS AND WRITES MAX ATTENUATION TO ALL CHANNELS
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, B, DE, HL
*/
sndStopAll:
;   CLEAR PLAYING FLAGS 
    XOR A
    LD B, TRACK_COUNT
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

