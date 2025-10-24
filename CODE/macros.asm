/*
-------------------------------------------------
                    MACROS
-------------------------------------------------
*/

/*
    [MATH]
    INFO: GIVEN A VALUE IN BOTH A AND HL, THE VALUE IN A WILL BE ADDED TO HL
    INPUT: HL - VALUE, A - VALUE
    OUTPUT: HL - HL + A, A - (HL + A)
    USES: HL, A
*/
.MACRO addToHL_M
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
.ENDM

/*
    [MATH]
    INFO: MULTIPLIES VALUE IN HL BY 29
    INPUT: HL - VALUE
    OUTPUT: HL - VALUE * 29
    USES: AF, HL
*/
.MACRO multBy29
    ; INPUT RANGE IS RELATIVELY SMALL, SO USE A LUT
    LD H, hibyte(mult29Table)
    LD A, L
    ADD A, A
    ADD A, lobyte(mult29Table)
    LD L, A
    LD A, (HL)
    INC L
    LD H, (HL)
    LD L, A
.ENDM

/*
    [MATH]
    INFO: MULTIPLIES VALUE IN HL BY 41
    INPUT: HL - VALUE
    OUTPUT: HL - VALUE * 41
    USES: AF, DE, HL
*/
.MACRO multBy41
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
.ENDM

/*
    [ACTOR]
    INFO: GIVEN A POINTER TO AN ACTOR'S SPEED PATTERN, UPDATES THE SPEED PATTERN (LEFT SHIFT BY 1)
    INPUT: HL - SPEED PATTERN POINTER
    OUTPUT - NONE
    USES: HL, DE, AF
*/
.MACRO actorSpdPatternUpdate
;      0      1       2      3
;   LOW_HW HIGH_HW LOW_LW HIGH_LW
;   SPEED PATTERN MUST NOT CROSS $100 BOUNDARY DUE TO 8 BIT INC/DEC!!!
;   LOAD HIGH WORD INTO BC
    LD C, (HL)
    INC L           ; -> HIGH WORD HIGH BYTE
    LD B, (HL)
    INC L           ; -> LOW WORD LOW BYTE
;   LOAD LOW WORD INTO DE
    LD E, (HL)
    INC L           ; -> LOW WORD HIGH BYTE
    LD D, (HL)
;   LEFT SHIFT LOW WORD
    SLA E
    RL D
;   STORE LOW WORD
    LD (HL), D
    DEC L           ; -> LOW WORD LOW BYTE
    LD (HL), E
;   SHIFT HIGH WORD (CARRY)
    RL C
    RL B
;   STORE HIGH WORD
    DEC L           ; -> HIGH WORD HIGH BYTE
    LD (HL), B
    DEC L           ; -> HIGH WORD LOW BYTE
    LD (HL), C
.ENDM