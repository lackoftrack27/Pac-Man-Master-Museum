/*
--------------------------------------------
    HELPER FUNCTIONS FOR ALL SUBSTATES
--------------------------------------------
*/


/*
    INFO: COMMON INITIALIZATION FOR CUTSCENES
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, E, HL
*/
commonCutsceneInit:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   RESET SUB STATE
    LD (cutsceneSubState), A
;   RESET 1UP FLASH
    LD (xUPCounter), A
;   TURN OFF SCREEN
    CALL turnOffScreen
;   CLEAR MAZE AREA OF TILEMAP
    LD E, 24
    LD HL, NAMETABLE + ($02 * $02) | VRAMWRITE
--:
    RST setVDPAddress
    LD BC, 42 * $100 + VDPDATA_PORT ; 21 TILES PER ROW
    XOR A
-:
    OUT (VDPDATA_PORT), A
    DJNZ -
    LD A, $40
    RST addToHL
    DEC E
    JR NZ, --
;   CLEAR SPRITE TABLE
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
-:
    OUT (C), E
    DJNZ -
    RET


/*
    INFO: PREPARE TO SWITCH BACK TO GAMEPLAY STATE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
switchToGameplay:
;   STOP MUSIC
    CALL sndStopAll
;   SWITCH FIRST READY MODE OF GAMEPLAY
    LD HL, GAMEPLAY_READY01 * $100 + M_STATE_GAMEPLAY
    LD (mainGameMode), HL
    LD A, $01
    LD (isNewState), A
;   DO GENERAL GAMEPLAY RESET
    JP generalResetFunc    


/*
--------------------------------------------
    HELPER FUNCTIONS FOR PAC-MAN SUBSTATES
--------------------------------------------
*/
pacCutsceneInit:
;   COMMON CUTSCENE SETUP
    CALL commonCutsceneInit
;   SETUP GFX POINTER
    LD HL, pacCutsceneGfxTable@smooth   ; ASSUME SMOOTH
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    JR Z, + ; IF SO, SKIP
    LD HL, pacCutsceneGfxTable@arcade   ; ELSE, DO ARCADE
    LD A, ARCADE_BANK
    LD (MAPPER_SLOT2), A
+:
    LD A, (plusBitFlags)
    BIT PLUS, A     ; CHECK FOR PLUS
    JR Z, +         ; IF NOT, SKIP
    INC HL          ; ELSE, ADD 4
    INC HL
    INC HL
    INC HL
+:
;   LOAD GFX DATA
    PUSH HL
    RST getDataAtHL
    ; GHOST CUTSCENE
    LD DE, SPRITE_ADDR + GHOST_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    POP HL
    INC HL
    INC HL
    RST getDataAtHL
    ; BIG PAC-MAN
    LD DE, SPRITE_ADDR + PAC_CUT_VRAM | VRAMWRITE
    CALL zx7_decompressVRAM
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
;   PLAY MUSIC
    LD A, MUS_COFFEE
    CALL sndPlayMusic
;   SETUP ACTORS (PAC-MAN AND BLINKY)
    ; SET PAC-MAN'S CURRENT X TILE
    LD A, $1F       ; ($08 >> $03) + $1E
    LD (pacman + CURR_X), A
    ; SET PAC-MAN'S X AND Y POSITION
    LD HL, $9408    ; YX
    LD (pacman.xPos), HL
    XOR A
    LD (pacman.subPixel), A
    ; SET SPRITE TABLE NUM TO 0
    LD (pacman.sprTableNum), A
    ; CLEAR BLINKY SUBPIXEL
    LD (blinky.subPixel), A
    ; CLEAR GHOST VISUAL COUNTERS
    LD (flashCounter), A
    LD (frameCounter), A
    ; CLEAR SCARED FLAG
    LD (blinky + EDIBLE_FLAG), A
    ; CLEAR INVISIBLE FLAG
    LD (blinky + INVISIBLE_FLAG), A
    ; PAC-MAN FACING LEFT
    INC A   ; $01
    LD (pacman.currDir), A
    LD (pacman.nextDir), A
    ; BLINKY FACING LEFT
    LD (blinky.currDir), A
    LD (blinky.nextDir), A
    ; SET SPRITE TABLE NUM
    LD A, 09
    LD (blinky.sprTableNum), A
    ADD A, A
    LD (pinky.sprTableNum), A   ; WAS $09, NOW $12
    ;LD (inky.sprTableNum), A   ; WAS $0D
    ;LD (clyde.sprTableNum), A   ; WAS $11
    ; SET BLINKY'S CURRENT X TILE
    LD A, $1E       ; ($00 >> $03) + $1E
    LD (blinky + CURR_X), A
    ; SET X AND Y POSITION
    LD HL, $9400
    LD (blinky.xPos), HL
    ; RESET STATE
    LD A, GHOST_SCATTER
    LD (blinky.state), A
;   TURN ON SCREEN
    CALL waitForVblank
    JP turnOnScreen


;   USED FOR CUTSCENE 1
pacCutSetSpritePal0:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
;   PALETTE SETUP
    LD HL, $001A | CRAMWRITE
    RST setVDPAddress
    LD A, $05       ; VERY DARK YELLOW FOR PAC-MAN'S SHADING (REPLACES DARK ORANGE)
    OUT (VDPDATA_PORT), A
    RET

;   USED FOR CUTSCENE 1
pacCutResSpritePal0:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
;   RESTORE PALETTE
    LD HL, $001A | CRAMWRITE
    RST setVDPAddress
    LD A, $06       ; DARK ORANGE
    OUT (VDPDATA_PORT), A
    RET


;   USED FOR CUTSCENES 2 AND 3
pacCutSetSpritePal:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
    ; PALETTE SETUP
    LD HL, $0015 | CRAMWRITE
    RST setVDPAddress
    LD A, $2B       ; TAN FOR BLINKY'S SKIN (REPLACES PINK)
    OUT (VDPDATA_PORT), A
    LD A, $16       ; DARK TAN FOR BLINKY'S SKIN SHADING (REPLACES DARK PINK)
    OUT (VDPDATA_PORT), A
    RET

;   USED FOR CUTSCENES 2 AND 3
pacCutResSpritePal:
;   CHECK IF ARCADE STYLE IS ON
    LD A, (plusBitFlags)
    BIT STYLE_0, A
    RET NZ  ; IF SO, EXIT
;   RESTORE PALETTE
    LD HL, $0015 | CRAMWRITE
    RST setVDPAddress
    LD A, $3B       ; PINK
    OUT (VDPDATA_PORT), A
    LD A, $26       ; DARK PINK
    OUT (VDPDATA_PORT), A
    RET



/*
--------------------------------------------------------
        CUTSCENE ANIMATION FUNCS FOR MS. PAC
--------------------------------------------------------
*/

;   6 INDEPENDENT SUB PROGRAMS RUNNING IN PARALLEL

;   COMMANDS:
;           $F0 - "LOOP":       X, Y
;           $F1 - "SET POS":    X, Y
;           $F2 - "SETN":       VAL (DB)
;           $F3 - "SET CHAR":   VAL (DW)
;           $F5 - "PLAY SOUND": VAL (DB) (NOT IMPLEMENTED)
;           $F6 - "PAUSE":
;           $F7 - "CLR TEXT":
;           $F8 - "CLR NUM":     
;           $FF - "END":


.DEFINE cutFuncList     workArea + $20      ; 12 BYTES
.DEFINE cutFuncTimers   workArea + $2C      ; 6 BYTES
.DEFINE cutFuncChars    workArea + $32      ; 12 BYTES
.DEFINE cutFuncTempPos  workArea + $3E      ; 12 BYTES
.DEFINE cutFuncPos      workArea + $4A      ; 12 BYTES
.DEFINE cutFuncDoneFlags    workArea + $56  ; 6 BYTES
.DEFINE cutFuncCharOffset   workArea + $5C  ; 6 BYTES



;   HL: PROG TABLE FOR CUTSCENE
msCutSetup:
;   COPY PROG PTRS TO RAM
    LD DE, cutFuncList
    LD BC, $000C
    LDIR
;   MEMSET ALL OTHER CUTSCENE VARS TO 0
    LD HL, cutFuncTimers
    LD (HL), $00
    LD DE, cutFuncTimers + 1
    LD BC, 66
    LDIR
;   COMMON CUTSCENE SETUP
    CALL commonCutsceneInit
;   TURN ON SCREEN
    CALL waitForVblank
    JP turnOnScreen


msCutDisplayAct:
;   DISPLAY TEXT @ [9, 7]
    LD HL, NAMETABLE + ($09 * $02) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; HL: ACT TEXT PTR
    LD BC, $08 * $100 + VDPDATA_PORT
    LD A, B     ; HIGH BYTE
-:
    OUTI
    OUT (C), A
    JR NZ, -
    ; HL NOW POINTS TO ACT NUMBER TILE ID
;   DISPLAY NUMBER IN ACT SIGN
    LD DE, $4043
    LD A, $18
    JP display1TileSprite


;   $00, $04, $08, $0C, $10, $14
;   $18 - ACT NUMBER
/*
    COMMON DRAW AND UPDATE FUNCTION
*/
msSceneCommonDrawUpdate:
;   DRAW 1UP
    CALL draw1UP    ; !!!
;   DO CUTSCENE DRAW
    ; SETUP
    LD IYL, $06                     ; COUNTER
    LD IX, cutFuncChars + $0A       ; START AT LAST CHAR
    LD DE, cutFuncCharOffset + $05  ; START AT LAST OFFSET
    LD BC, cutFuncPos + $0B         ; START AT LAST Y
-:
    ; GET CHARACTER ARRAY PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
    ; GET OFFSET WITHIN ARRAY
    LD A, (DE)
    SRA A
    DEC DE      ; POINT TO NEXT OFFSET
    PUSH DE     ; SAVE OFFSET PTR
    ; ADD OFFSET TO ARRAY PTR
    RST addToHL
    ; CONVERT DATA INTO OFFSET FOR GLOBAL CUTSCENE CHARACTER ARRAY, THEN ADD OFFSET
    ADD A, A
    ADD A, A
    LD HL, msSceneCharTable
    RST addToHL ; HL NOW POINTS TO CORRECT SPRITE
    ; CONVERT POSITION FROM LOGICAL TO REAL
    DEC BC      ; POINT TO NEXT POS
    DEC BC
    PUSH BC     ; SAVE POS PTR
    PUSH IX     ; SAVE CHAR ARR PTR
    LD IXH, B   ; COPY POS PTR TO IX
    LD IXL, C
    CALL convPosToScreen    ; DE NOW HAS X/Y
    POP IX      ; RESTORE CHAR ARR PTR
    ; CALCULATE SPRITE TABLE NUM ((COUNTER - 1) * 4)
    LD A, IYL
    DEC A
    ADD A, A
    ADD A, A
    ; DISPLAY SPRITE
    CALL display4TileSprite
    ; PREPARE FOR NEXT LOOP
    POP BC  ; RESTORE POS PTR
    POP DE  ; RESTORE OFFSET PTR
    DEC IX  ; POINT TO NEXT CHAR PTR
    DEC IX
    DEC IYL ; KEEP LOOPING UNTIL COUNTER IS 0
    JR NZ, -
;   FALL THROUGH



/*
    CUTSCENE PROCESSING FUNCTION
*/
cutAniProcess:
;   SETUP
    LD B, $06   ; COUNTER
    LD IX, cutFuncList + $0A    ; POINT TO LAST FUNC
@loop:
;   GET SUB PROG PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
;   GET BYTE
    LD A, (HL)
;   CHECK FOR COMMAND
    CP A, $F0
    JR Z, @cmdLoop
    CP A, $F1
    JP Z, @cmdSetPos
    CP A, $F2
    JP Z, @cmdSetN
    CP A, $F3
    JP Z, @cmdSetChar
    CP A, $F5
    JP Z, @cmdPlaySnd
    CP A, $F6
    JP Z, @cmdPause
    CP A, $F7
    JP Z, @cmdClrText
    CP A, $F8
    JP Z, @cmdClrNum
    JP @cmdStop

/*
    COMMAND - "LOOP": X, Y
    $F0
*/
@cmdLoop:
;   SAVE PROG PTR
    PUSH HL
;   PROCESS X MOVEMENT
    ; GET FIRST BYTE (X)
    INC HL
    LD C, (HL)
    ; GET CORRECT ADDRESS FOR TEMP POS
    LD HL, cutFuncTempPos - 2
    CALL ptrDeref
    ; CALCULATE MOVEMENT
    LD A, C
    ADD A, L
    CALL cutFuncCalcMovement
    DEC DE
    LD (DE), A
    ; STORE MOVEMENT
    LD HL, cutFuncPos - 2
    CALL ptrDeref
    LD A, L
    ADD A, C
    DEC DE
    LD (DE), A
    ; RESTORE PROG PTR
    POP HL
    PUSH HL
;   PROCESS Y MOVEMENT
    ; GET SECOND BYTE (Y)
    INC HL
    INC HL
    LD C, (HL)
    ; GET CORRECT ADDRESS FOR TEMP POS
    LD HL, cutFuncTempPos - 2
    CALL ptrDeref
    ; CALCULATE MOVEMENT
    LD A, C
    ADD A, H
    CALL cutFuncCalcMovement
    LD (DE), A
    ; STORE MOVEMENT
    LD HL, cutFuncPos - 2
    CALL ptrDeref
    LD A, H
    ADD A, C
    LD (DE), A
;   PROCESS CHARACTER ARRAY
    ; GET CORRECT OFFSET 
    LD HL, cutFuncCharOffset - 1
    LD A, B
    RST addToHL
    PUSH HL     ; SAVE FOR LATER
    ; INCREMENT OFFSET AND STORE IN C
    INC A
    LD C, A
-:
    ; GET CHARACTER ARRAY FOR SUB PROG
    LD HL, cutFuncChars - 2
    CALL ptrDeref
    LD A, C     ; GET BACK COUNTER
    SRA A       ; DIVIDE BY 2 (WHY?)
    RST addToHL
    CP A, $FF
    JR NZ, +    ; SKIP, IF NOT $FF (END OF ARRAY)
    LD C, $00   ; RESET OFFSET
    JR -        ; LOOP
+:
    POP HL      ; GET BACK OFFSET PTR
    LD (HL), C  ; SAVE NEW OFFSET
    POP HL      ; RESTORE PROG PTR
;   PROCESS COLOR (NOT NEEDED)
;   TIMER CHECK
    LD HL, cutFuncTimers - 1
    LD A, B
    RST addToHL
    DEC A
    LD (HL), A
    LD DE, $0000
    JP NZ, cmdCleanUp01
    LD E, $03
    JP cmdCleanUp01


/*
    COMMAND - "SET POS": X, Y
    $F1
*/
@cmdSetPos:
    EX DE, HL   ; DE: PROG PTR // HL: N/A
    LD HL, cutFuncPos - 2
    EX DE, HL   ; DE: FUNC POS // HL: PROG PTR
    PUSH DE     ; SAVE FUNC POS PTR
;   GET X AND Y DATA FROM PROGRAM
    INC HL
    LD E, (HL)  ; X
    INC HL
    LD D, (HL)  ; Y
    ; DE: YX
    JR cmdCleanUp

/*
    COMMAND - "SETN": VAL (DB)
    $F2
*/
@cmdSetN:
;   GET BYTE FROM PROGRAM
    INC HL
    LD C, (HL)
;   GET CORRECT ADDRESS FOR TIMER
    LD HL, cutFuncTimers - 1
    LD A, B
    RST addToHL
;   STORE TIMER VALUE
    LD (HL), C
;   FINISH
    LD DE, $0002    ; ADVANCE PROG PTR BY 2 BYTES
    JR cmdCleanUp01

/*
    COMMAND - "SET CHAR": VAL (DW)
    $F3
*/
@cmdSetChar:
;   CLEAR SPRITE ARRAY OFFSET
    EX DE, HL   ; DE: PROG PTR // HL: N/A
    LD HL, cutFuncCharOffset - 1
    LD A, B
    RST addToHL
    LD (HL), $00
;   GET NEW CHAR ARRAY PTR
    EX DE, HL   ; DE: N/A // HL: PROG PTR
    LD DE, cutFuncChars - 2
    PUSH DE
    INC HL
    LD E, (HL)
    INC HL
    LD D, (HL)
    JR cmdCleanUp 


/*
    COMMAND - "PLAY SOUND"
    $F5
*/
@cmdPlaySnd:
;   DO NOTHING
    LD DE, $0002    ; ADVANCE BY 2 BYTES
    JR cmdCleanUp01 


/*
    COMMAND - "PAUSE"
    $F6
*/
@cmdPause:
;   GET CORRECT ADDRESS FOR TIMER
    LD HL, cutFuncTimers - 1
    LD A, B
    RST addToHL
;   DECREMENT TIMER
    DEC A
    LD (HL), A
;   FINISH
    LD DE, $0000        ; ADVANCE PROG PTR BY 0 BYTES...
    JR NZ, cmdCleanUp01 ; IF TIMER VALUE ISN'T 0
    LD E, $01           ; ELSE, ADVANCE BY 1 BYTE
    JR cmdCleanUp01


/*
    COMMAND - "CLEAR TEXT"
    $F7
*/
@cmdClrText:
;   CLEAR TEXT (ACT NAME) ON SCREEN
    LD HL, NAMETABLE + ($09 * $02) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    LD C, $10
    XOR A
-:
    OUT (VDPDATA_PORT), A
    DEC C
    JR NZ, -
;   FINISH
    LD DE, $0001    ; ADVANCE PROG PTR BY 1 BYTE
    JR cmdCleanUp01

/*
    COMMAND - "CLEAR NUM"
    $F8
*/
@cmdClrNum:
;   CLEAR ACT NUMBER ON SCREEN
    LD HL, SPRITE_TABLE + $18 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   FINISH
    LD DE, $0001    ; ADVANCE PROG PTR BY 1 BYTE
    JR cmdCleanUp01

/*
    COMMAND - "STOP"
    $FF
*/
@cmdStop:
;   GET CORRECT ADDRESS FOR DONE FLAG
    LD HL, cutFuncDoneFlags - 1
    LD A, B
    RST addToHL
;   SET FLAG
    LD (HL), $01
;   CHECK IF ALL FLAGS ARE SET
    LD HL, cutFuncDoneFlags
    LD A, (HL)
    INC HL
    AND A, (HL)
    INC HL
    AND A, (HL)
    INC HL
    AND A, (HL)
    INC HL
    AND A, (HL)
    INC HL
    AND A, (HL)
;   FINISH
    LD DE, $0000        ; ADVANCE BY 0 BYTES...
    JR Z, cmdCleanUp01  ; IF ANY FLAG ISN'T SET (PROG NOT DONE)
;   WAIT 30 FRAMES
    LD B, 30
-:
    HALT
    DJNZ -
;   SWITCH TO GAMEPLAY
    JP switchToGameplay

/*
    ADDITIONAL CLEAN UP FOR COMMANDS $F1, $F3
*/
cmdCleanUp:
    POP HL      ; HL: ADDRESS USED BY COMMAND
    PUSH DE     ; DE: DATA RETRIEVED BY COMMAND 
    CALL ptrDeref
    EX DE, HL   ; DE: DATA AT HL // HL: CORRECT ADDRESS FOR COMMAND
    POP DE      ; DE: DATA RETRIEVED BY COMMAND
;   STORE DATA RETRIEVED BY COMMAND AT CORRECT ADDRESS
    LD (HL), D
    DEC HL
    LD (HL), E
;   FINISH
    LD DE, $0003    ; ADVANCE PROG PTR BY 3 BYTES
;   FALL THROUGH


/*
    CLEAN UP FOR ALL COMMANDS
*/
cmdCleanUp01:
;   GET PROG PTR
    LD L, (IX + 0)
    LD H, (IX + 1)
;   ADD BYTE ADVANCEMENT
    ADD HL, DE
;   SAVE
    LD (IX + 0), L
    LD (IX + 1), H
;   POINT TO NEXT PROG
    DEC IX
    DEC IX
;   CHECK IF ALL PROGS HAVE BEEN EXECUTED
    DEC B
    JP NZ, cutAniProcess@loop   ; IF NOT, KEEP LOOPING
    RET



/*
    POINTER DEREFERENCE (RST $18)
*/
ptrDeref:
    LD A, B
    ADD A, A
    RST addToHL
    LD E, (HL)
    INC HL
    LD D, (HL)
    EX DE, HL   ; DE: (HL + 2B) // HL: DATA AT (HL + 2B)
    RET


/*
    MOVEMENT ADJUSTER / CALCULATOR
*/
cutFuncCalcMovement:
    LD C, A
    SRA C
    SRA C
    SRA C
    SRA C
    AND A, A
    JP P, +
    OR A, $F0
    INC C
    RET
+:
    AND A, $0F
    RET