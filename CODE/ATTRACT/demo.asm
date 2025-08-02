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
;   USE GAMEPLAY ROUTINES FOR DEMO
    LD HL, sStateGameplayTable
    LD A, (subGameMode)
    JP jumpTableExec
+:
;   ELSE, EXIT BACK TO TITLE SCREEN
    LD (prevInput), A   ; INPUT IS NOW PREVIOUS INPUT
    ; TURN OFF LINE INTERRUPTS (AND V COUNTER)
    CALL turnOffLineInts
    ; REMOVE FSM CALLER
    POP HL
    ; DISABLE INTS (REALLY JUST VDP FRAME INTS)    
    DI
    ; GENERAL RESET
    JP resetFromDemo