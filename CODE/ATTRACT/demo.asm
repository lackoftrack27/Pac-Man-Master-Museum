/*
-------------------------------------------------------
                    DEMO MODE
-------------------------------------------------------
*/
sStateAttractTable@demoInputCheck:
;   CHECK IF PLAYER WANTS TO EXIT DEMO
    LD A, (controlPort1)
    BIT P1_BTN_1, A ; CHECK IF BUTTON 1 IS PRESSED
    JR NZ, +        ; IF SO, EXIT BACK TO TITLE
;   CYCLE 'GAME OVER' SPRITES TO PREVENT DROPPING (NOT USED IN JR.PAC)
    ; GET XN DATA INTO BUFFER
    LD HL, SPRITE_TABLE_XN + ($19 * $02)
    RST setVDPAddress
    LD HL, gOverSpriteBuffer
    LD BC, $0C * $100 + VDPDATA_PORT
    INIR
    ; RESET VDP ADDRESS FOR LATER
    LD HL, SPRITE_TABLE_XN + ($19 * $02) | VRAMWRITE
    RST setVDPAddress
    ; ROTATE CIRCULAR BUFFER TO RIGHT
    LD HL, gOverSpriteBuffer + $0A
    LD A, (HL)  ; BYTE $0A
    INC HL
    LD C, (HL)  ; BYTE $0B
    LD B, $0A
-:
    DEC HL
    DEC HL
    LD D, (HL)  ; BYTE $XX
    INC HL
    INC HL
    LD (HL), D  ; BYTE $XX+$02 == BYTE $XX
    DEC HL
    DJNZ -
    LD (HL), C  ; BYTE $01 == BYTE $0B
    DEC HL
    LD (HL), A  ; BYTE $00 == BYTE $0A
    ; WRITE BUFFER TO SPRITE TABLE
    LD BC, $0C * $100 + VDPDATA_PORT
    OTIR
;   ALWAYS DISPLAY "1UP"
    CALL draw1UPDemo
;   USE GAMEPLAY ROUTINES FOR DEMO
    LD HL, sStateGameplayTable
    LD A, (subGameMode)
    JP jumpTableExec
+:
;   ELSE, EXIT BACK TO TITLE SCREEN
    LD (prevInput), A   ; INPUT IS NOW PREVIOUS INPUT
    POP HL  ; REMOVE FSM CALLER   
    DI      ; DISABLE INTS (REALLY JUST VDP FRAME INTS)
    ; TURN OFF DISPLAY, BUT KEEP FRAME INTS
    CALL turnOffScreenVBlank
    ; GENERAL RESET
    JP resetFromDemo