/*
------------------------------------------
            MATH FUNCTIONS
------------------------------------------
*/






/*
multBy29:
;   HL * 29 (32 - 02 - 01)
    LD E, L
    LD D, H
    ADD HL, HL
    PUSH HL
    ADD HL, HL 
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    SBC HL, DE
    POP DE
    SBC HL, DE
    RET
*/

multBy6_16:
;   HL * 06 (04 + 02)
    ADD HL, HL
    LD E, L
    LD D, H
    ADD HL, HL
    ADD HL, DE
    RET


multBy41:
;   HL * 41 (32 + 08 + 01)
    LD E, L
    LD D, H
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    PUSH HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE
    POP DE
    ADD HL, DE
    RET

/*
    INFO: MULTIPLIES A UNSIGNED 8-BIT NUMBER BY 6
    INPUT: A - FACTOR
    OUTPUT: A - PRODUCT
    USES: AF, B
*/
multiplyBy6:
    ADD A, A
    LD B, A
    ADD A, A
    ADD A, B
    RET


/*
.MACRO addToHLSigned
    OR A
    JP P, +
    DEC H
+:
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    ;RET
.ENDM
*/


/*
    INFO: SQUARES AN 8-BIT NUMBER
    INPUT: A - FACTOR
    OUTPUT: HL - PRODUCT
    USES: AF, HL, DE
*/
/*
squareNumber:
;   CHECK IF NUMBER IS NEGATIVE
    OR A
    JP P, +     ; IF NOT, SKIP
    NEG         ; IF SO, TURN POSITIVE
+:
;   SET PRODUCTS TO THE SAME NUMBER
    LD H, A
    LD E, A
;   FALLTHROUGH TO NEXT ROUTINE
*/
/*
    INFO: MULTIPLIES TWO 8-BIT NUMBERS
    INPUT: H - FACTOR, E - FACTOR
    OUTPUT: HL - PRODUCT
    USES: F, HL, DE
*/
multiply8Bit:
;   INIT. LOOP
    LD D, $00   ; CLEAR D AND L
    LD L, D
    /*
.REPEAT 8       ; UNROLLED LOOP FOR SPEED (8 BITS)
    ADD HL, HL  ; ADVANCE BIT
    JR NC, +    ; IF 0, SKIP ADDITION
    ADD HL, DE  ; ELSE, ADD TO PRODUCT
+:
.ENDR
    RET
    */
    SLA H
    JR NC, +
    LD L, E
+
    ADD HL, HL
    JR NC, +
    ADD HL, DE
+:
    ADD HL, HL
    JR NC, +
    ADD HL, DE
+:
    ADD HL, HL
    JR NC, +
    ADD HL, DE
+:
    ADD HL, HL
    JR NC, +
    ADD HL, DE
+:
    ADD HL, HL
    JR NC, +
    ADD HL, DE
+:
    ADD HL, HL
    JR NC, +
    ADD HL, DE
+:
    ADD HL, HL
    RET NC
    ADD HL, DE
    RET


/*
    INFO: RANDOM NUMBER GENERATOR (ORIGINAL GAME'S ALGORITHM)
    INPUT: NONE
    OUTPUT: A - RANDOM NUMBER
    USES: AF, DE, HL
*/
randNumGen:
;   CALCULATE RNG INDEX
    ; GET RNG INDEX
    LD HL, (rngIndex)
    ; STORE INTO DE FOR LATER CALCULATION
    LD D, H
    LD E, L
    ; MULTIPLY INDEX BY 5 AND THEN ADD 1
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE
    INC HL
    ; LIMIT INDEX FROM $0000 - $2000
    LD A, H
    AND A, $1F
    LD H, A
    ; STORE INDEX
    LD (rngIndex), HL
;   DETERMINE DATA OFFSET
    LD DE, rngDataOffset    ; ASSUME PAC-MAN (NON PLUS) GAME DATA
    LD A, (plusBitFlags)    ; CHECK IF NON PLUS GAME IS BEING PLAYED
    AND A, $01 << PLUS
    JR Z, +                 ; IF SO, SKIP
    SET 5, D                ; ELSE, ADD $2000 TO POINT TO PLUS GAME DATA
+:
    ADD HL, DE              ; ADD OFFSET TO INDEX
;   GET VALUE FROM ORIGINAL GAME'S DATA
    ; SET BANK
    LD A, RNG_BANK
    LD (MAPPER_SLOT2), A
    ; GET VALUE AT "RANDOM" INDEX
    LD E, (HL)
    ; RESTORE BANK
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
    ; RETURN VALUE
    LD A, E
    RET