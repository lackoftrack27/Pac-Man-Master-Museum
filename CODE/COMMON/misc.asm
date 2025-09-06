/*
------------------------------------------------
            UNSORTED FUNCTIONS
------------------------------------------------
*/

/*
    INFO: SPRITE FLICKER PROCESSING
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
/*
sprOverflowCheck:
;   OBJECT FLICKER UPDATER
;   BITS 0 - 4: OBJECT FLICKER BITS (0 - BLINKY, 1 - PINKY, 2 - INKY, 3 - CLYDE, 4 - FRUIT)
;   BITS 5 - 7: FLICKER MODE (5 - 4 CYCLE, 1 DROP, 6 - 5 CYCLE, 1 DROP, 7 - 5 CYCLE, 2 DROP)
    ; CHECK IF FLICKER IS HAPPENING
    LD HL, sprFlickerControl
    LD A, $E0
    AND A, (HL)
    JR Z, ++        ; IF NOT, SKIP
    LD BC, $1F20    ; ISOLATOR AND LIMITER FOR 5 CYCLE FLICKER
    BIT 5, (HL)     ; CHECK IF ONLY 4 OBJECTS ARE BEING FLICKERED
    JR Z, +         ; IF NOT, SKIP
    LD BC, $0F10    ; ISOLATOR AND LIMITER FOR 4 CYCLE FLICKER
+:
    LD A, B     ; ISOLATE FLICKER BITS
    AND A, (HL)
    RLCA        ; ROTATE LEFT
    CP A, C     ; CHECK IF OVERFLOW OCCURED
    JR C, +     ; IF NOT, SKIP
    INC A       ; CARRY AND KEEP WANTED BITS
    AND A, B
+:
    LD B, A     ; COPY NEW FLICKER BITS INTO B
    LD A, (HL)  ; REMOVE OLD FLICKER BITS
    AND A, $E0
    OR A, B     ; OR TOGETHER AND SAVE
    LD (HL), A
++:
;   SETUP Y POSITION ARRAY
    ; MEMSET ARRAY TO $FF (GHOSTS WITH INVISIBLE FLAG WILL HAVE THIS POSITION)
    LD A, $FF
    LD HL, workArea + $69
    LD (HL), A
    LD DE, workArea + $68
    LD BC, $05
    LDDR
    ; PAC-MAN Y
    LD A, (pacman + Y_WHOLE)
    LD (HL), A
    ; BLINKY Y
    INC HL
    LD IX, blinky + INVISIBLE_FLAG + (_sizeof_ghost * 3 - $7F)  ; IX MATH DONE TO KEEP WITHIN 7 BIT RANGE
    BIT 0, (IX - (_sizeof_ghost * 3 - $7F))
    JR NZ, +
    LD A, (blinky + Y_WHOLE)
    LD (HL), A
+:
    ; PINKY Y
    INC HL
    BIT 0, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost)
    JR NZ, +
    LD A, (pinky + Y_WHOLE)
    LD (HL), A
+:
    ; INKY Y
    INC HL
    BIT 0, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost + _sizeof_ghost)
    JR NZ, +
    LD A, (inky + Y_WHOLE)
    LD (HL), A
+:
    ; CLYDE Y
    INC HL
    BIT 0, (IX - (_sizeof_ghost * 3 - $7F) + _sizeof_ghost + _sizeof_ghost + _sizeof_ghost)
    JR NZ, +
    LD A, (clyde + Y_WHOLE)
    LD (HL), A
+:
    ; FRUIT Y
    INC HL
    LD A, (fruitYPos)
    LD (HL), A
;   SETUP LOOP
    INC DE                  ; Y POSITION PTR
    LD IXH, $00             ; MAX OVERLAP
    LD C, $06               ; OUTER LOOP COUNTER [I]
--:
;   OUTER LOOP
    LD IXL, $00             ; LOCAL COUNT
    LD HL, workArea + $64   ; Y POSITION PTR INNER LOOP
    LD B, $06               ; INNER LOOP COUNTER [J]
-:
;   INNER LOOP
    ; CHECK IF I == J
    LD A, C
    CP A, B
    JR Z, ++    ; IF SO, SKIP INNER LOOP INTERATION
    ; COMPARE Y POSITIONS
    LD A, (DE)  ; GET Y[I]
    SUB A, (HL) ; COMPARE TO Y[J]
    JR NC, +    ; IF RESULT WASN'T NEGATIVE, SKIP
    NEG         ; ELSE, TURN RESULT POSITIVE
+:
    CP A, $10   ; CHECK IF DIFFERENCE IS 16 PIXELS OR MORE
    JR NC, ++   ; IF SO, SKIP
    INC IXL     ; ELSE, INCREMENT LOCAL COUNT
++:
    ; PREPARE FOR NEXT INNER LOOP
    INC HL      ; INCREMENT INNER LOOP Y PTR
    DJNZ -      ; INNER LOOP COUNTER CHECK
;   CHECK IF LOCAL COUNT > MAX OVERLAP
    LD A, IXL
    CP A, IXH
    JR C, +     ; IF NOT, SKIP
    LD IXH, A   ; ELSE, MAX OVERLAP == LOCAL COUNT
+:
;   PREPARE FOR NEXT OUTER LOOP
    INC DE      ; INCREMENT OUTER LOOP Y PTR
    DEC C       ; OUTER LOOP COUNTER CHECK
    JR NZ, --
;   SET OVERFLOW FLAG
    LD HL, sprFlickerControl
    LD A, IXH       ; CHECK IF MAX OVERLAP == 5 (6 SPRITES ARE IN SAME AREA)
    CP A, $05
    JR NZ, +        ; IF NOT, SKIP
    BIT 7, (HL)     ; END IF BIT 7 ALREADY SET
    RET NZ
    LD (HL), $85    ; BIT 7 SET (CYCLE BY 5, TWO DROP)
    RET
+:
    LD A, IXL       ; LAST LOCAL COUNT (FRUIT)
    BIT 2, A        ; CHECK IF FRUIT OVERLAP == 4
    JR Z, +         ; IF NOT, SKIP
    BIT 6, (HL)     ; END IF BIT 6 ALREADY SET
    RET NZ
    LD (HL), $41    ; BIT 6 SET (CYCLE BY 5, ONE DROP) !!! HAS SIDE EFFECT OF DROPPING OUT GHOST THAT DOESN'T NEED TO BE !!!
    RET
+:
    LD A, IXH       ; CHECK IF MAX OVERLAP == 4
    BIT 2, A
    JR Z, +         ; IF NOT, SKIP
    BIT 5, (HL)     ; END IF BIT 5 ALREADY SET
    RET NZ
    LD (HL), $21    ; BIT 5 SET (CYCLE BY 4, ONE DROP)
    RET
+:
    LD (HL), $00    ; CLEAR FLAGS
    RET
*/



/*
    INFO: ADD TASK TO LIST (USED ONLY FOR PATHFINDING)
    INPUT: A - TASK ID
    OUTPUT: NONE
    USES: AF, HL
*/
addTask:
;   STORE TASK ID, INCREMENT TASK LIST POINTER
    LD HL, (taskListEnd)
    LD (HL), A
    INC HL
    LD (taskListEnd), HL
    RET


/*
    INFO: DETERMINE WHAT BG PALETTE TO USE BASED ON GAME AND CURRENT LEVEL
    INPUT: NONE
    OUTPUT: HL - BG PALETTE PTR
    USES: AF, HL
*/
getbgPalPtr:
;   CHECK IF GAME IS MS.PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @msSection   ; IF SO, SKIP
;   CHECK IF GAME IS JR.PAC
    BIT JR_PAC, A
    JR NZ, @jrSection   ; IF SO, SKIP
;   ----------------------------------------
    LD HL, bgPalPac     ; ASSUME GAME IS PAC-MAN
;   CHECK IF GAME IS PLUS (PAC-MAN)
    BIT PLUS, A
    RET Z               ; IF NOT, END
    LD HL, bgPalPlus    ; ELSE, LOAD PAL DATA FOR PLUS
    RET
;   ----------------------------------------
@msSection:
;   CHECK IF GAME IS PLUS
    LD HL, msLevelPalTable      ; ASSUME GAME IS NORMAL
    BIT PLUS, A
    JR Z, +                     ; IF NOT, SKIP
    LD HL, msLevelPalTable@plus ; LOAD TABLE FOR PLUS VERSION
+:
;   CHECK IF LEVEL IS GREATER THAN 21
    LD A, (currPlayerInfo.level)
    CP A, $15
    JR NC, +    ; IF SO, REDUCE
@@msGetPal:
;   GET PALETTE FOR CURRENT LEVEL
    RST addToHL
    ; GET DATA AND DOUBLE IT
    ADD A, A
    ; ADD TO PALETTE TABLE
    LD HL, msPalTable
    RST addToHL
    ; GET PALETTE
    JP getDataAtHL
;   LEVEL REDUCTION
+:
    SUB A, $15  ; SUBTRACT 21
-:
    SUB A, $10  ; SUBTRACT 10 UNTIL NEGATIVE
    JR NC, -
    ADD A, $15  ; ADD BACK 21
    JR @@msGetPal
;   ----------------------------------------
@jrSection:
;   CHECK IF GAME IS PLUS
    LD HL, jrLevelPalTable      ; ASSUME GAME IS NORMAL
    BIT PLUS, A
    JR Z, +                     ; IF NOT, SKIP
    LD HL, jrLevelPalTable@plus ; LOAD TABLE FOR PLUS VERSION
+:
;   CHECK IF LEVEL IS GREATER THAN 21
    LD A, (currPlayerInfo.level)
    CP A, $15
    JR NC, +    ; IF SO, REDUCE
@@jrGetPal:
;   GET PALETTE FOR CURRENT LEVEL
    RST addToHL
    ; GET DATA AND DOUBLE IT
    ADD A, A
    ; ADD TO PALETTE TABLE
    LD HL, jrPalTable
    RST addToHL
    ; GET PALETTE
    JP getDataAtHL
;   LEVEL REDUCTION
+:
    SUB A, $15  ; SUBTRACT 21
-:
    SUB A, $10  ; SUBTRACT 10 UNTIL NEGATIVE
    JR NC, -
    ADD A, $15  ; ADD BACK 21
    JR @@jrGetPal



/*
    INFO: WRITE MAZE PALETTE TO RAM BUFFER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE
*/
cpyMazePalToRam:
;   LOAD BG PALETTE TO RAM
    CALL getbgPalPtr
    LD DE, mazePalette
    LD BC, BG_CRAM_SIZE
    LDIR
;   MODIFY IF STYLE IS "ARCADE"
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    RET Z     ; IF NOT, END
    XOR A
    LD (mazePalette + BGPAL_SHADE0), A  ; SHADE 0 BECOMES BLACK
    LD A, (mazePalette + BGPAL_WALLS)   ; SHADE 1 BECOMES WALL COLOR
    LD (mazePalette + BGPAL_SHADE1), A
    LD A, (mazePalette + BGPAL_PDOT1)   ; PDOT0 BECOMES PDOT1,2,3
    LD (mazePalette + BGPAL_PDOT0), A
    RET


/*
    INFO: CLEAR SPRITE AREAS USED BY PAC-MAN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, B, DE, HL
*/

/*
pacSprCmdProcess:
;   PROCESS COMMAND
    LD B, A ; SAVE INTO B
    ; CLEAR SPRITE COMMAND
    XOR A
    LD (pacSprControl), A
    ; ASSUME COMMAND IS 1
    LD A, $15
    ; CHECK IF COMMAND IS 1
    DEC B
    JR Z, +     ; IF SO, SKIP
    ; COMMAND IS 2, SO CLEAR SUPER AREA
    LD A, $01
+:
;   MOVE SPRITE AREA TO OFFSCREEN
    ; SET VDP ADDRESS
    OUT (VDPCON_PORT), A   ; LOW BYTE
    LD A, hibyte(SPRITE_TABLE) | hibyte(VRAMWRITE)
    OUT (VDPCON_PORT), A   ; HIGH BYTE
    ; SET Y POSITION TO $F8
    LD A, $F7
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    RET
*/


setupTilePtrs:
;   PLAYER TILE DEFINITION TABLE SETUP
    LD HL, playerTileTblList
    LD A, (plusBitFlags)
    AND A, $1F
    ADD A, A
    LD E, A
    LD D, $00
    ADD HL, DE
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    LD (playerTileTblPtr), HL
;   DEATH TILE DEFINITION TABLE SETUP
    LD HL, deathTileTblList
    LD A, (plusBitFlags)
    AND A, $1E
    LD E, A
    LD D, $00
    ADD HL, DE
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    LD (deathTileTblPtr), HL
    RET
    