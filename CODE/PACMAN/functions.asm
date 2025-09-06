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
    LD A, $01
    LD (pacman.sprTableNum), A
;   SET STATE
    LD A, PAC_NORMAL
    LD (pacman + STATE), A
;   SET POINTER FOR DEATH TIMES
    LD HL, pacmanDeathTimes
    LD (pacDeathTimePtr), HL
;   SET PAC-MAN'S X AND Y POSITION
    LD HL, $0080
    LD (pacman.xPos), HL
    LD HL, $00C4
    LD (pacman.yPos), HL
;   PELLET TIMER
    XOR A
    LD (pacPelletTimer), A
;   PAC-MAN FACING LEFT
    INC A   ; $01
    LD (pacman.currDir), A
    LD (pacman.nextDir), A
;   GENERAL ACTOR RESET
    LD IX, pacman
    JP actorReset




pacTileStreaming:
;   [182]
;   -----
    ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $0B20 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C   ; VDP DATA PORT
;   -----
    LD A, (pacman + STATE)
    CP A, PAC_DEAD
    JP Z, @deathStream
;   -----
    ; GET POSITION
    LD HL, normAniTbl
    LD A, (pacman.currDir)
    LD B, A
    LD DE, pacman.xPos
    RRCA
    JP C, +
    INC DE
    INC DE
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    ADD A, A
    ADD A, L
    LD L, A
+:
    LD A, (DE)
    AND A, $0F
    ADD A, L    ; HOPEFULLY NO OVERFLOW...
    LD L, A
    LD D, (HL)
    ; DIRECTION * 32
    LD A, B
    RRCA
    RRCA
    RRCA
    ; ADD ALL TO TABLE PTR
    ADD A, D
    LD E, A
    LD D, $00
    LD HL, (playerTileTblPtr)
    ADD HL, DE
    JP @writeToVRAM
@deathStream:
    LD HL, (pacDeathTimePtr)
    LD DE, pacmanDeathTimes
    OR A    ; CLEAR CARRY
    SBC HL, DE
    LD A, L
    ADD A, A
    ADD A, A
    ADD A, A
    LD E, A
    LD D, $00
    LD HL, (deathTileTblPtr)
    ADD HL, DE
@writeToVRAM:
    ; SET BANK
    LD A, UNCOMP_BANK
    LD (MAPPER_SLOT2), A
    ; TILE 0 [550]
    LD E, L     ; DE = TILE TABLE PTR
    LD D, H
    LD L, (HL)  ; GET POINTER
    INC DE
    LD A, (DE)
    LD H, A
    INC DE
.REPEAT $20     ; WRITE TILE DATA TO VRAM
    OUTI
.ENDR
    ; TILE 1 [550]
    LD L, E
    LD H, D
    LD L, (HL)
    INC DE
    LD A, (DE)
    LD H, A
    INC DE
.REPEAT $20
    OUTI
.ENDR
    ; TILE 2 [550]
    LD L, E
    LD H, D
    LD L, (HL)
    INC DE
    LD A, (DE)
    LD H, A
    INC DE
.REPEAT $20
    OUTI
.ENDR
    ; TILE 3 [544]
    LD L, E
    LD H, D
    LD L, (HL)
    INC DE
    LD A, (DE)
    LD H, A
.REPEAT $20
    OUTI
.ENDR
    ; SET BANK
    LD A, SMOOTH_BANK
    LD (MAPPER_SLOT2), A
    RET