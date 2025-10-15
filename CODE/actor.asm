/*
----------------------------------------------
            GENERAL ACTOR FUNCTIONS
----------------------------------------------
*/

/*
    INFO: RESETS COMMON ACTOR VARS
    INPUT: IX: ACTOR BASE ADDRESS
    OUTPUT: NONE
    USES: IX, AF
*/
actorReset:
;   CLEAR OFFSCREEN FLAG
    XOR A
    LD (IX + OFFSCREEN_FLAG), A
;   NEW STATE
    INC A
    LD (IX + NEW_STATE_FLAG), A
;   SUBTRACT $08 FROM Y POS IF JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, +
    ADD A, A    ; 4 -> 8
    NEG         ; 8 ->-8
    ADD A, (IX + Y_WHOLE)
    LD (IX + Y_WHOLE), A
    ; ADD $68 TO X POS
    LD L, (IX + X_WHOLE)
    LD H, (IX + X_WHOLE + 1)
    LD DE, $0068
    ADD HL, DE
    LD (IX + X_WHOLE), L
    LD (IX + X_WHOLE + 1), H
+:
;   UPDATE COLLISION, CENTERS, ETC
    CALL actorUpdate
;   COPY CURRENT TILE TO NEXT TILE
    LD A, (IX + CURR_X)
    LD (IX + NEXT_X), A
    LD A, (IX + CURR_Y)
    LD (IX + NEXT_Y), A
    LD A, (IX + CURR_ID)
    LD (IX + NEXT_ID), A
    RET




/*
    INFO: SETS THE NEXT TILE IN THE ACTOR'S NEXT DIRECTION
    INPUT: IX: ACTOR BASE ADDRESS
    OUTPUT: NONE
    USES: IX, AF, DE, HL
*/
setNextTile:
    LD HL, dirVectors
;   USE DIRECTION AS OFFSET INTO TABLE
    LD A, (IX + NEXT_DIR)
    ADD A, A    ; DOUBLE DIRECTION
    addToHL_M
;   ADD Y
    LD A, (IX + NEXT_Y)
    ADD A, (HL)
    LD (IX + NEXT_Y), A
    LD D, A
;   ADD X
    INC HL
    LD A, (IX + NEXT_X)
    ADD A, (HL)
    LD (IX + NEXT_X), A
    LD E, A
;   GET ID
    CALL getTileID
    LD (IX + NEXT_ID), A
    RET


/*
    INFO: CONVERTS ROW AND COLUMN TILE TO A POINTER FOR THE RAM TILEMAP
    INPUT:  HL: ROW|COL [YX]
    OUTPUT: HL: RAM PTR
    USES:   AF, DE, HL
*/
rowColToRamPtr:
;   MULTIPLY ROW BY DIFFERENT AMOUNT DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @nonScroll
;   MOVE COLUMN TO A
    LD A, L
;   MULTIPLY ROW BY 41 (TILES PER ROW)
    LD L, H
    LD H, $00
    multBy41
;   ADD X AND Y (COLUMN + ROW * 41)
    addToHL_M
;   MULTIPLY BY 2 (TILES ARE 2 BYTES EACH)
    ADD HL, HL
;   ADD BASE PTR
    LD DE, mazeGroup1.tileMap
    ADD HL, DE
    RET
@nonScroll:
;   MOVE COLUMN TO A
    LD A, L
;   MULTIPLY ROW BY 32 (TILES PER ROW)
    LD L, H
    LD H, $00
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
;   ADD X AND Y (COLUMN + ROW * 32)
    addToHL_M
;   MULTIPLY BY 2 (TILES ARE 2 BYTES EACH)
    ADD HL, HL
;   ADD BASE PTR
    LD DE, mazeGroup1.tileMap
    ADD HL, DE
    RET



/*
    INFO: CONVERTS ROW AND COLUMN TILE TO A POINTER FOR THE VRAM TILEMAP 
    INPUT:  HL: ROW|COL [YX]
    OUTPUT: HL: VRAM PTR
    USES:   AF, DE, HL
*/
rowColToVramPtr:
;   STORE COLUMN IN DE
    LD D, $00
    LD E, L
;   DIFFERENT PROCESS FOR NON SCROLL GAMES
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @nonScroll
;   RAM ROW PROCESS
    XOR A
    LD L, H
    INC L   ; APPLY 1 ROW OFFSET (TOP ROW ON SCREEN IS RESERVED FOR HUD)
    LD H, A
    ; MULTIPLY BY YTILE 64 (EACH ROW IS 64 BYTES [32 TILES * 2])
    SRL H
    RR L
    RRA
    SRL H
    RR L
    RRA
    LD H, L     ; RESULT IN HL
    LD L, A
;   RAM COL PROCESS
    ; ADJUST TO SCREEN VIEW
    LD A, (jrScrollReal)
    SRA A           ; SIGNED DIVIDE BY 8
    SRA A
    SRA A
    NEG
    ADD A, E        ; RAM COL -= XSCROLL_TILE
    AND A, $1F  ; LIMIT TO 0 - 31 (VALID COLUMN RANGE)
    ; ADD LEFT MOST TILE
    LD E, A
    LD A, (jrLeftMostTile)
    NEG
    ADD A, E
    AND A, $1F  ; LIMIT TO 0 - 31 (VALID COLUMN RANGE)
    ADD A, A    ; MULTIPLY XTILE BY 2  (2 BYTES PER TILE)
    LD E, A     ; STORE IN E
;   ADD X AND Y TOGETHER
    ADD HL, DE
;   ADD BASE PTR
    RET
@nonScroll:
;   MULTIPLY ROW BY 32 (TILES PER ROW)
    LD L, H
    LD H, $00
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
;   ADD X AND Y (COLUMN + ROW * 32)
    ADD HL, DE
;   MULTIPLY BY 2 (TILES ARE 2 BYTES EACH)
    ADD HL, HL
;   ADD BASE PTR [NAMETABLE == $0000]
    RET



/*
    INFO: CHECKS IF AN ACTOR IS OFFSCREEN (FOR JR.PAC)
    INPUT: IX - ACTOR'S PTR, B - 'PROCESS REVERSE FLAG' FLAG
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
actorOffScreenCheck:
;   SAVE OFFSCREEN FLAG IN C, THEN CLEAR IT
    LD C, (IX + OFFSCREEN_FLAG)
    LD (IX + OFFSCREEN_FLAG), $00
;   SCALE WORLD POS TO 3/4
    LD L, (IX + X_WHOLE)    ; POS -> INDEX
    LD H, (IX + X_WHOLE + 1)
    ADD HL, HL
    LD A, H     ; ADD HIGH BYTES
    ADD A, hibyte(jrScaleTable)
    LD H, A
    LD A, (HL)  ; GET VALUE
    INC HL
    LD H, (HL)
    LD L, A
;   STORE CAMERA POS IN DE
    LD D, $00
    LD A, (jrCameraPos)
    ;DEC A
    ;JP P, +
    ;INC A
;+:
    LD E, A
;   CHECK IF ACTOR IS BEFORE LEFTSIDE OF SCREEN (LESS THAN CAMERA)
    SBC HL, DE
    ADD HL, DE
    JR C, +     ; OBJ_POS < CAM_POS
;   CHECK IF ACTOR IS AFTER RIGHTSIDE OF SCREEN (GREATER THAN [CAMERA + SCREEN WIDTH])
    ;LD A, (jrCameraPos)
    ;LD E, A
    INC D       ; ADD SCREEN WIDTH
    INC HL      ; PREVENT ACTOR FROM BEING SEEN WRAPPING OVER TO LEFT SIDE
    INC HL
    SBC HL, DE
    RET C
+:
;   SET OFFSCREEN FLAG
    LD A, $01
    LD (IX + OFFSCREEN_FLAG), A
;   EXIT HERE IF B == 1 (FRUIT)
    DEC B
    RET Z
;   SET REVERSE FLAG ONLY IF PREVIOUS != CURRENT OFFSCREEN FLAG
    XOR A, C
    OR A, (IX + REVE_FLAG)
    LD (IX + REVE_FLAG), A
    RET

/*
    CANNOT AFFECT HL!!! OR B???
    INFO: CONVERTS LOGICAL POSITION TO SCREEN POSITION
    INPUT: IX
    OUTPUT: DE
    USES: IX, IYH, AF, C, DE
*/
convPosToScreen:
;   CONVERT POSITIONS DIFFERENTLY DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, @nonScroll
    ; CHANGE BANK FOR SCALE TABLE
    LD A, JR_TABLES_BANK
    LD (MAPPER_SLOT2), A
;   CONVERSION FROM 8px TILES TO 6px TILES (X)
    LD A, (jrCameraPos)
    LD C, A
        ; POS -> INDEX
    LD E, (IX + X_WHOLE)
    LD D, (IX + X_WHOLE + 1)
    SLA E
    RL D
        ; ADD HIGH BYTES
    LD A, D
    ADD A, hibyte(jrScaleTable)
    LD D, A
        ; GET VALUE
    LD A, (DE)
    ; WORLD POS -> SCREEN POS (lobyte(actorXPos) - cameraPos)
    SUB A, C
    LD D, A
;   CONVERSION FROM 8px TILES TO 6px TILES (Y)
    LD A, (IX + Y_WHOLE)
    LD IYH, A   ; IYH = Y
    SRL A
    SRL A
    LD C, A     ; C = Y / 4
    LD A, IYH
    SUB A, C    ; A = IYH - C
    SUB A, $02
    LD E, A
    ; REVERT BANK
    LD A, DEFAULT_BANK
    LD (MAPPER_SLOT2), A
    RET
@nonScroll:
;   CONVERSION FROM 8px TILES TO 6px TILES (X)
    LD A, (IX + X_WHOLE)    
    LD IYH, A   ; IYH = X
    SRL A
    SRL A
    LD C, A     ; C = X / 4
    LD A, IYH
    SUB A, C
    LD D, A     ; D = IYH - C
    LD A, $BE   ; X = $BE - X
    SUB A, D
    LD D, A
;   CONVERSION FROM 8px TILES TO 6px TILES (Y)
    LD A, (IX + Y_WHOLE)
    LD IYH, A   ; IYH = Y
    SRL A
    SRL A
    LD C, A     ; C = Y / 4
    LD A, IYH
    SUB A, C    ; A = IYH - C
    SUB A, $0C  ; Y = Y - $0C
    LD E, A
    RET


/*
    INFO: CHECKS IF AN ACTOR IS ABOUT TO WARP
    INPUT: IX
    OUTPUT: CARRY FLAG
    USES: IX, AF
*/
actorWarpCheck:
    LD A, (IX + NEXT_X)
    CP A, $1D
    JP NZ, +
    LD (IX + NEXT_X), $3D
    JP @endTrue
+:
    CP A, $3E
    JP NZ, +
    LD (IX + NEXT_X), $1E
    JP @endTrue
+:
    CP A, $21
    JP C, @endTrue
    CP A, $3B
    JP NC, @endTrue
    OR A    ; CLEAR CARRY
    RET
@endTrue:
    SCF     ; SET CARRY
    RET



/*
    INFO: UPDATES ACTOR'S CURRENT TILE USING X/Y PIXEL POS
    INPUT: IX
    OUTPUT: NONE
    USES: IX, AF
*/
updateCurrTile:
;   CURRENT Y
    LD A, (IX + Y_WHOLE)
    RRCA
    RRCA
    RRCA
    AND A, $1F  ; REMOVE UNWANTED CARRIES
    ADD A, $20  ; 21
    LD (IX + CURR_Y), A
;   CURRENT X
    LD A, (IX + X_WHOLE + 1)    ; HIGH BYTE CAN ONLY BE 0 OR 1
    RRCA        ; PUT INTO CARRY
    LD A, (IX + X_WHOLE)
    RRA
    RRCA
    RRCA
    AND A, $3F  ; REMOVE UNWANTED CARRIES
    ADD A, $1E
    LD (IX + CURR_X), A
    RET



/*
    INFO: UPDATES AN ACTOR'S COLLSION TILES
    INPUT: IX - ACTOR BASE ADDRESS
    OUTPUT: NONE
    USES: IX, AF, HL, DE, BC
*/
actorUpdate:
;   RESET HIGH BYTES IF GAME IS NON SCROLLING
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, +
    LD (IX + X_WHOLE + 1), $00
    LD (IX + Y_WHOLE + 1), $00
+:
;   UPDATE CURRENT TILE (COPY OF ROUTINE, DONE TO REMOVE CALL OVERHEAD)
    ; CURRENT Y
    LD A, (IX + Y_WHOLE)
    RRCA
    RRCA
    RRCA
    AND A, $1F
    ADD A, $20  ; 21
    LD (IX + CURR_Y), A
    ; CURRENT X
    LD A, (IX + X_WHOLE + 1)    ; HIGH BYTE CAN ONLY BE 0 OR 1
    RRCA        ; PUT INTO CARRY
    LD A, (IX + X_WHOLE)
    RRA
    RRCA
    RRCA
    AND A, $3F  ; REMOVE UNWANTED CARRIES
    ADD A, $1E
    LD (IX + CURR_X), A
/*
---------------------------------------------
        COLLISION TILE UPDATE 
---------------------------------------------
*/

/*
    INFO: UPDATES AN ACTOR'S COLLISION TILES FROM A COLLSION MAP
    INPUTS: IX - Actor's Base Address
    OUTPUT: NONE
    USES: AF, IX, DE, BC, HL
*/
updateCollTiles:
;   TILE X/Y VALUES
    LD E, (IX + CURR_X) ; STORE CURRENT X TILE IN E
    LD A, (IX + CURR_Y) ; STORE CURRENT Y TILE IN A
    ; CALCULATE OFF-BY-1 VARIANTS FOR OTHER DIRECTIONS
    LD B, E     ; B = X
    LD C, E     ; C = X + 1
    LD D, E     ; D = X - 1
    INC C
    DEC D
    ; Y
    LD E, A     ; E = Y
    LD H, A     ; H = Y + 1
    LD L, A     ; L = Y - 1
    INC H
    DEC L
;   X/Y VALUES
    ; UP
    LD (IX + UP_X), B ; 0
    LD (IX + UP_Y), L ; -1
    ; LEFT
    LD (IX + LEFT_X), C ; +1
    LD (IX + LEFT_Y), E ; 0
    ; DOWN
    LD (IX + DOWN_X), B ; 0
    LD (IX + DOWN_Y), H ; +1
    ; RIGHT
    LD (IX + RIGHT_X), D ; -1
    LD (IX + RIGHT_Y), E ; 0
;   GET ID VALUES FROM COLLSION MAP
    LD A, (IX + UP_Y)
    SUB A, $21
    LD L, A
    ; MULTIPLY BY EITHER 16 (PAC/MS.) OR 29 (JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, +
    LD H, $00
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    JP @addX
+:
    multBy29
@addX:
    ; CHECK IF X TILE IS EVEN OR ODD
    LD A, (IX + UP_X)
    SUB A, $1E
    LD E, A ; EVEN OR ODD FLAG
    RRA     ; DIVIDE X BY 2. (NIBBLE FORMAT)
    ; ADD X OFFSET TO POINTER
    addToHL_M
    ; ADD TO INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeGroup1.collMap
    ADD HL, BC
    ; PREPARE VARS
    LD D, $F0       ; UPPER NIBBLE EXTRACTOR
    LD BC, $000F    ; INITIAL ADDRESS OFFSET
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, +
    LD BC, $001C
+:
    ; CHECK EVEN/ODD FLAG
    BIT 0, E
    JR NZ, @odd ; DO ODD PROCESSING IF BIT IS SET
@even:
;   UP
    LD A, (HL)
    AND A, D    ; AND WITH $F0
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
    LD (IX + UP_ID), A
;   POINT TO LEFT
    ADD HL, BC  ; ADD $0F
;   LEFT
    LD A, $0F    
    AND A, (HL) ; AND WITH $0F
    ;LD (IX + LEFT_ID), A
    LD (IX + RIGHT_ID), A
;   POINT TO CURRENT
    INC HL
;   CURRENT
    LD A, (HL)
    AND A, D    ; AND WITH $F0
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
    LD (IX + CURR_ID), A
;   RIGHT
    LD A, $0F
    AND A, (HL) ; AND WITH $0F
    ;LD (IX + RIGHT_ID), A
    LD (IX + LEFT_ID), A
;   POINT TO DOWN
    INC C
    ADD HL, BC  ; ADD $10
;   DOWN
    LD A, (HL)
    AND A, D    ; AND WITH $F0
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
    LD (IX + DOWN_ID), A
    RET
@odd:
;   UP
    LD A, $0F
    AND A, (HL) ; AND WITH $0F
    LD (IX + UP_ID), A
;   POINT TO LEFT
    INC C
    ADD HL, BC  ; ADD $10
;   LEFT
    LD A, (HL)
    AND A, D    ; AND WITH $F0
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
    ;LD (IX + LEFT_ID), A
    LD (IX + RIGHT_ID), A 
;   CURRENT
    LD A, (HL)
    AND A, $0F
    LD (IX + CURR_ID), A
;   POINT TO RIGHT
    INC HL
;   RIGHT
    LD A, (HL)
    AND A, D    ; AND WITH $F0
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
    ;LD (IX + RIGHT_ID), A
    LD (IX + LEFT_ID), A  
;   POINT TO DOWN
    DEC C
    ADD HL, BC  ; ADD $0F
;   DOWN
    LD A, (HL)
    AND A, $0F    ; AND WITH $0F
    LD (IX + DOWN_ID), A
    RET


/*
    INFO: RETURNS TILE ID GIVEN TILE X/Y
    INPUT: DE - TILE Y/X
    OUTPUT: A - TILE IDX
    USES: HL, BC, DE
*/
getTileID:
    PUSH DE
;   GET ID VALUES FROM COLLSION MAP
    LD A, D
    SUB A, $21
    LD L, A
    ; MULTIPLY BY EITHER 16 (PAC/MS.) OR 29 (JR)
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, +
    LD H, $00
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    JP @addX
+:
    multBy29
@addX:
    POP DE
    ; CHECK IF X TILE IS EVEN OR ODD
    LD A, E
    SUB A, $1E
    LD E, A ; EVEN OR ODD FLAG
    RRA     ; DIVIDE X BY 2. (NIBBLE FORMAT)
    ; ADD X OFFSET TO POINTER
    addToHL_M
    ; ADD TO INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeGroup1.collMap
    ADD HL, BC
    LD A, (HL)
    ; CHECK EVEN/ODD FLAG
    BIT 0, E
    JP NZ, @odd ; DO ODD PROCESSING IF BIT IS SET
@even:
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
@odd:
    AND A, $0F
    RET
