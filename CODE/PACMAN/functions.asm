/*
------------------------------------------------
                PAC-MAN ROUTINES
------------------------------------------------
*/


/*
    INFO: CALCULATES NEXT DIRECTION PAC-MAN TAKES IN DEMO
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, HL, IX
*/
pacmanDemoPF:
;   SETUP PATHFINDING (COLLISION FOR NEXT TILES)
    LD IX, pacman
    CALL setupPathFinding
;   PATHFINDING ALG IN DEMO MODE: 
;   IF BLINKY'S EDIBLE, PAC-MAN WILL CHASE PINKY. ELSE, PAC-MAN WILL RUN AWAY FROM PINKY
; ---------------------------------
    LD BC, (pinky + NEXT_X)     ; YX
    ; CHECK IF BLINKY IS EDIBLE
    LD A, (blinky.visiblyScaredFlag)
    OR A
    JR NZ, +    ; IF SO, SKIP...
    LD HL, (pacman + CURR_X)    ; YX
    ; PAC-MAN Y TILE * 2 - PINKY Y TILE
    LD A, H
    ADD A, A
    SUB A, B
    LD B, A
    ; PAC-MAN X TILE * 2 - PINKY X TILE
    LD A, L
    ADD A, A
    SUB A, C
    LD C, A
+:
;   SET PACMAN'S TARGET TO BE PINKY OR TO GET AWAY FROM BLINKY
    LD (pacman + TARGET_X), BC ; YX
;   DO PATHFINDING
    JP ghostPathFindingAI@normalPathFinding


/*
    INFO: RESETS PAC-MAN RELATED VARS FOR LEVEL START
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL, IX
*/
pacmanReset:
;   PAC-MAN SPRITE TABLE NUMBER
    LD A, 21
    LD (pacman.sprTableNum), A
;   SET STATE
    LD A, PAC_NORMAL
    LD (pacman + STATE), A
;   SET POINTER FOR DEATH TIMES
    LD HL, pacmanDeathTimes
    LD (pacDeathTimePtr), HL
;   SET PAC-MAN'S X AND Y POSITION
    LD HL, $C480    ; YX
    LD (pacman.xPos), HL
    XOR A
    LD (pacman.subPixel), A
;   PELLET TIMER
    LD (pacPelletTimer), A
;   PAC-MAN FACING LEFT
    INC A   ; $01
    LD (pacman.currDir), A
    LD (pacman.nextDir), A
;   GENERAL ACTOR RESET
    LD IX, pacman
    CALL actorReset
;   SETUP PAC-MAN IN SAT
    JP displayPacMan


/*
0F - CLOSED
0E - CLOSED
0D - CLOSED
0C - CLOSED
0B - HALF
0A - HALF
09 - HALF
08 - HALF
07 - OPEN
06 - OPEN
05 - OPEN
04 - OPEN
03 - HALF
02 - HALF
01 - HALF
00 - HALF
*/