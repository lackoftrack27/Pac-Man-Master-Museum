/*
----------------------------------------------
            GENERAL ACTOR FUNCTIONS
----------------------------------------------
*/



/*
    INFO: GIVEN A POINTER TO AN ACTOR'S SPEED PATTERN, UPDATES THE SPEED PATTERN (LEFT SHIFT BY 1)
    INPUT: HL - SPEED PATTERN POINTER
    OUTPUT - NONE
    USES: HL, DE, AF
*/
actorSpdPatternUpdate:
;   POINT TO LOW WORD OF SPEED PATTERN, THEN GET LOW BYTE
    INC HL
    INC HL
    LD E, (HL)
;   POINT TO HIGH BYTE AND GET IT
    INC HL
    LD D, (HL)
;   SWAP HL (SPEED POINTER) <-> DE (SPEED BIT PATTERN)
    EX DE, HL
;   LEFT SHIFT BIT PATTERN
    ADD HL, HL
    LD A, H         ; GET HIGH BYTE OF BIT PATTERN
    LD (DE), A      ; STORE
    DEC DE           ; POINT BACK TO LOW
    LD A, L         ; GET LOW BYTE OF BIT PATTERN
    LD (DE), A      ; STORE
;   SWAP BACK
    EX DE, HL
;   POINT TO HIGH WORD OF SPEED PATTERN, THEN GET LOW BYTE
    DEC HL
    DEC HL
    LD E, (HL)
;   POINT TO HIGH BYTE AND GET IT
    INC HL
    LD D, (HL)
;   SWAP HL (SPEED POINTER) <-> DE (SPEED BIT PATTERN)
    EX DE, HL
;   LEFT SHIFT BIT PATTERN (WITH CARRY FROM PREVIOUS SHIFT)
    ADC HL, HL
    LD A, H
    LD (DE), A
    DEC DE
    LD A, L
    LD (DE), A
;   REMOVE CALLER JUST IN CASE ACTOR WON'T MOVE, (UPDATE FUNCTION WILL END)
    POP HL
    RET NC      ; IF THERE IS NO CARRY, THE ACTOR UPDATE SHOULD JUST END. (HE CAN'T MOVE!!!)
;   ADD CALLER BACK TO THE STACK
    PUSH HL
;   SWAB BACK
    EX DE, HL
;   POINT TO LOW WORD OF SPEED PATTERN AND INCREMENT BYTE (ROTATE CARRY INTO LSB)
    INC HL
    INC HL
    INC (HL)
    RET



/*
    INFO: RESETS COMMON ACTOR VARS
    INPUT: IX: ACTOR BASE ADDRESS
    OUTPUT: NONE
    USES: IX, AF
*/
actorReset:
;   NEW STATE
    LD A, $01
    LD (IX + NEW_STATE_FLAG), A
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
    USES: IX, AF, HL
*/
setNextTile:
;   SET NEXT TILE TO NEXT TILE IN CURRENT DIRECTION
    LD A, (IX + NEXT_DIR)
    ; USE DIRECTION AS OFFSET INTO TABLE
    ADD A, A    ; DOUBLE DIRECTION
    LD HL, dirVectors
    RST addToHL
    ; ADD Y
    LD A, (IX + NEXT_Y)
    ADD A, (HL)
    LD (IX + NEXT_Y), A
    ; ADD X
    INC HL
    LD A, (IX + NEXT_X)
    ADD A, (HL)
    LD (IX + NEXT_X), A
    ; GET ID
    LD E, (IX + NEXT_X)
    LD D, (IX + NEXT_Y)
    CALL getTileID
    LD (IX + NEXT_ID), A
    RET


/*
    INFO: CONVERTS LOGICAL POSITION TO SCREEN POSITION
    INPUT: IX
    OUTPUT: DE
    USES: IX, IYH, AF, C, DE
*/
convPosToScreen:
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
    JR NZ, +
    LD (IX + NEXT_X), $3D
    JR @endTrue
+:
    CP A, $3E
    JR NZ, +
    LD (IX + NEXT_X), $1E
    JR @endTrue
+:
    CP A, $21
    JR C, @endTrue
    CP A, $3B
    JR NC, @endTrue
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
    AND A, $F8  ; DIVIDE BY 8
    RRCA
    RRCA
    RRCA
    ADD A, $20  ; 21
    LD (IX + CURR_Y), A
;   CURRENT X
    LD A, (IX + X_WHOLE)
    AND A, $F8  ; DIVIDE BY 8
    RRCA
    RRCA
    RRCA
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
/*
---------------------------------------------
            CURRENT TILE UPDATE
---------------------------------------------
*/
    CALL updateCurrTile

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
    LD H, $00
    LD A, (IX + UP_Y)
    SUB A, $21
    LD L, A
    ; MULTIPLY Y TILE BY 16 (COLLISION MAP IS 32 TILES HORIZONTAL, NIBBLE)
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ; CHECK IF X TILE IS EVEN OR ODD
    LD A, $3D
    LD C, (IX + UP_X)
    SUB A, C
    LD E, A ; EVEN OR ODD FLAG
    RRA     ; DIVIDE X BY 2. (NIBBLE FORMAT)
    ; ADD X OFFSET TO POINTER
    RST addToHL
    ; ADD TO INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeCollisionPtr
    ADD HL, BC
    ; PREPARE VARS
    LD D, $F0       ; UPPER NIBBLE EXTRACTOR
    LD BC, $000F    ; INITIAL ADDRESS OFFSET
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
    LD A, C     
    AND A, (HL) ; AND WITH $0F
    LD (IX + LEFT_ID), A
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
    LD A, C
    AND A, (HL) ; AND WITH $0F
    LD (IX + RIGHT_ID), A
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
;   END
    RET
@odd:
;   UP
    LD A, C
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
    LD (IX + LEFT_ID), A    
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
    LD (IX + RIGHT_ID), A
;   POINT TO DOWN
    DEC C
    ADD HL, BC  ; ADD $0F
;   DOWN
    LD A, (HL)
    AND A, C    ; AND WITH $0F
    LD (IX + DOWN_ID), A
;   END
    RET


/*
    INFO: RETURNS TILE ID GIVEN TILE X/Y
    INPUT: DE - TILE Y/X
    OUTPUT: A - TILE IDX
    USES: HL, BC, DE
*/
getTileID:
;   GET ID VALUES FROM COLLSION MAP
    LD H, $00
    LD A, D
    SUB A, $21
    LD L, A
    ; MULTIPLY Y TILE BY 16 (COLLISION MAP IS 32 TILES HORIZONTAL, NIBBLE)
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ; CHECK IF X TILE IS EVEN OR ODD
    LD A, E
    LD C, A
    LD A, $3D
    SUB A, C
    LD E, A ; EVEN OR ODD FLAG
    RRA     ; DIVIDE X BY 2. (NIBBLE FORMAT)
    ; ADD X OFFSET TO POINTER
    RST addToHL
    ; ADD TO INITIAL MAZE COLLISION ADDRESS
    LD BC, mazeCollisionPtr
    ADD HL, BC
    ; PREPARE VARS
    LD D, $F0       ; UPPER NIBBLE EXTRACTOR
    LD BC, $000F    ; INITIAL ADDRESS OFFSET
    ; CHECK EVEN/ODD FLAG
    BIT 0, E
    JR NZ, @odd ; DO ODD PROCESSING IF BIT IS SET
@even:
;   EVEN POS
    LD A, (HL)
    AND A, D    ; AND WITH $F0
    RRCA        ; SHIFT TO LOWER NIBBLE
    RRCA
    RRCA
    RRCA
    RET
@odd:
;   UP
    LD A, C
    AND A, (HL) ; AND WITH $0F
    RET





/*
EVEN:
    AND BYTE WITH $F0
    ADD $0F TO ADDRESS
    AND BYTE WITH $0F
    INC ADDRESS
    AND BYTE WITH $F0
    AND BYTE WITH $0F
    ADD $10 TO ADDRESS
    AND BYTE WITH $F0

                    *    *
    AND  ADD  AND  INC  AND  AND  ADD  AND
    $F0, $0F, $0F, $01, $F0, $0F, $10, $0F
ODD:
    AND BYTE WITH $0F
    ADD $10 TO ADDRESS
    AND BYTE WITH $F0
    AND BYTE WITH $0F
    INC ADDRESS
    AND BYTE WITH $F0
    ADD $0F TO ADDRESS
    AND BYTE WITH $0F

    AND  ADD  AND  AND  INC  AND  ADD  AND
    $0F, $10, $F0, $0F, $01, $F0, $0F, $0F
*/






/*
    ; UP
    LD A, (HL)
    LD (IX + UP_ID), A  ; 19
    ; POINT TO LEFT
    LD BC, $0031
    ADD HL, BC
    ; LEFT
    LD A, (HL)
    LD (IX + LEFT_ID), A
    ; POINT TO CURRENT
    INC HL
    ; CURRENT
    LD A, (HL)
    LD (IX + CURR_ID), A
    ; POINT TO RIGHT
    INC HL
    ; RIGHT
    LD A, (HL)
    LD (IX + RIGHT_ID), A
    ; POINT TO DOWN
    ADD HL, BC
    ; DOWN
    LD A, (HL)
    LD (IX + DOWN_ID), A
    RET
*/


