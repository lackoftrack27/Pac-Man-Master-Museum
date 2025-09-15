/*
--------------------------------------------
        TASK TABLE AND FUNCTIONS
--------------------------------------------
*/
taskListTable:
    .DW blinkyPF    ; 0
    .DW pinkyPF     ; 1
    .DW inkyPF      ; 2
    .DW clydePF     ; 3
    .DW pacmanDemoPF        ; 4
    .DW fruitPathFindingAI  ; 5


blinkyPF:
    LD IX, blinky
    JP ghostPathFindingAI
pinkyPF:
    LD IX, pinky
    JP ghostPathFindingAI
inkyPF:
    LD IX, inky
    JP ghostPathFindingAI
clydePF:
    LD IX, clyde
    JP ghostPathFindingAI



/*
--------------------------------------------
            GHOST TARGET TABLE
--------------------------------------------
*/
ghostTargetTable:
    .DW blinkyTarget    ; 0
    .DW pinkyTarget     ; 1
    .DW inkyTarget      ; 2
    .DW clydeTarget     ; 3



/*
--------------------------------------------
        GHOST PATHFINDING ALGORITHM
--------------------------------------------
*/
ghostPathFindingAI:
;   PREPARE FOR PATHFINDING
    CALL setupPathFinding
;   CHECK IF GHOST IS EDIBLE
    BIT 0, (IX + EDIBLE_FLAG)
    JP Z, ++     ; IF NOT, SKIP
;   CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    JP NZ, @scaredPathfind  ; IF SO, DO SCARED PATHFIND
;   ELSE, MAKE GHOST GO HOME
    LD HL, $2C2E
    ; CHANGE TARGET IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, $2B3B
+:
    LD (IX + TARGET_X), L
    LD (IX + TARGET_Y), H
    JP @normalPathFinding
++:
;   JUMP TO TARGET ALGORITHM BASED ON GHOST
    LD HL, ghostTargetTable
    LD A, (IX + ID)
    RST jumpTableExec
/*
--------------------------------------------
    SCATTER/CHASE/GO HOME PATHFINDING
--------------------------------------------
*/
@normalPathFinding:
    ; (workArea + 58): LOWEST
    ; (workArea + 60): ID ADDRESS 
    ; (workArea + 62): NEW DIRECTION
    ; (workArea + 63): COUNTER
;   SET LOWEST
    LD HL, $FFFF
    LD (lowestDist), HL
;   SET ID ADDRESS
    LD HL, PATHFIND_TILES_PTR + RIGHT_ID    ;LD HL, workArea + RIGHT_ID
    LD (idAddress), HL
;   SET NEW DIRECTION
    LD A, (IX + CURR_DIR)
    LD (newDir), A
;   SET COUNTER
    LD A, $03
    LD (counter), A
-:
;   CHECK IF TILE IS WALKABLE
    LD HL, (idAddress)
    LD A, (HL)
    AND A, $03      ; ONLY CARE ABOUT LOWEST 2 BITS
    DEC A           ; CHECK IF TILE IS WALL (IF ID WAS 1)
    JP Z, @prepareNextLoop  ; IF SO, SKIP...
;   CHECK IF TILE IS NOT IN REVERSE DIRECTION
    LD B, (IX + REVE_DIR)
    LD A, (counter)
    SUB A, B
    JP Z, @prepareNextLoop
;   CALCULATE DY (TARGET_Y - DIR_Y)
    DEC HL  ; POINT TO Y OF CURRENT TILE
    LD B, (HL)
    LD A, (IX + TARGET_Y)
    SUB A, B
    LD C, A     ; SAVE FOR LATER
;   CALCULATE DX (TARGET_X - DIR_X)
    DEC HL  ; POINT TO X OF CURRENT TILE
    LD B, (HL)
    LD A, (IX + TARGET_X)
    SUB A, B
;   GET SQUARE OF DX
    OR A
    JP P, +
    NEG
+:
    LD H, hibyte(squareTable)
    ADD A, A
    LD L, A
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    EX DE, HL   ; SAVE IN DE
;   GET SQUARE OF DY
    LD A, C     ; GET BACK DY
    OR A
    JP P, +
    NEG
+:
    LD H, hibyte(squareTable)
    ADD A, A
    LD L, A
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
;   ADD SQUARES
    ADD HL, DE
;   CHECK IF DISTANCE IS LOWER THAN CURRENT LOWEST
    LD DE, (lowestDist)  ; GET LOWEST INTO BC
    EX DE, HL
    OR A    ; CLEAR CARRY
    SBC HL, DE
    JP C, @prepareNextLoop      ; IF NOT, SKIP...
;   ELSE, DISTANCE IS NOW NEW LOWEST
    LD (lowestDist), DE
;   ALSO, SET NEW DIRECTION TO COUNTER
    LD A, (counter)
    LD (newDir), A
@prepareNextLoop:
;   ADD -3 TO ID_ADDRESS (POINT TO NEXT TILE)
    LD HL, (idAddress)
    DEC HL
    DEC HL
    DEC HL
    LD (idAddress), HL
;   INCREMENT COUNTER
    LD HL, counter
    DEC (HL)
    JP P, -     ; KEEP GOING IF NO OVERFLOW
;   SET NEW DIRECTION
    JP @setNewDirection
/*
--------------------------------------------
            SCARED PATHFINDING
--------------------------------------------
*/
@scaredPathfind:
    ; (workArea + 60): ID ADDRESS 
    ; (workArea + 62): NEW DIRECTION
;   GET RANDOM NUMBER (DETERMINISTIC)
    CALL randNumGen
@jrScatterJump:
;   LIMIT IT TO 0 - 3
    AND A, $03
;   CONVERT NUMBER FROM HOW DIRECTIONS ARE ORDERED IN THE OG GAME [0,1,2,3] -> [3,2,1,0]
    LD B, A
    LD A, $03
    SUB A, B
;   FIXED HIGH BYTE OF 0 FOR 16 BIT ADDITION
    LD D, $00
-:
;   SAVE DIRECTION
    LD (newDir), A
;   CHECK IF TILE IS IN REVERSE DIRECTION
    CP A, (IX + REVE_DIR)
    JP Z, @clockwiseChange  ; IF SO, CHANGE DIRECTION IN CLOCKWISE ORDER AND TRY AGAIN
;   CONVERT NUMBER INTO OFFSET
    LD B, A     ; MULTIPLY BY 3
    ADD A, A
    ADD A, B
    LD E, A
;   ADD OFFSET TO BASE ID ADDRESS
    LD HL, PATHFIND_TILES_PTR + UP_ID
    ADD HL, DE
;   CHECK IF TILE IS WALKABLE
    LD A, (HL)
    AND A, $03      ; ONLY CARE ABOUT LOWEST 2 BITS
    DEC A           ; CHECK IF TILE IS WALL (IF ID WAS 1)
    JP NZ, @setNewDirection ; IF NOT, STOP LOOP
;   ELSE, CHANGE DIRECTION IN CLOCKWISE ORDER AND TRY AGAIN
@clockwiseChange:
    LD A, (newDir)
    DEC A
    AND A, $03
    JP -
/*
--------------------------------------------
            CONFIRM NEW DIRECTION
--------------------------------------------
*/
;   GO HERE AFTER DIRECTION HAS BEEN DETERMINED
@setNewDirection:
    ; SET NEXT DIRECTION
    LD A, (newDir)
    LD (IX + NEXT_DIR), A
    RET






/*
--------------------------------------------
        BLINKY TARGET DETERMINATION
--------------------------------------------
*/
blinkyTarget:
;   CHECK IF IN CHASE
    LD A, (scatterChaseIndex)
    AND A, $01
    JP NZ, @chase  ; IF SO, SET TARGET TO BE PAC-MAN
;   IF NOT, HE MUST BE IN SCATTER...
    ; CHECK IF DIFF STATE ISN'T 0
    LD A, (difficultyState)
    OR A
    JP NZ, @chase   ; IF SO, SET TARGET TO CHASE
@scatter:
    ; BLINKY'S SCATTER TARGET IS UPPER RIGHT CORNER (PAC-MAN ONLY)
    LD HL, $1D22
    ; CHECK IF GAME IS PAC-MAN
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    JP Z, @@setScatter  ; IF SO, SKIP
    ; DO APPROPRIATE FUNCTION
    AND A, $01 << JR_PAC
    JP NZ, getRandTargetJr  ; JR.PAC'S RANDOM ALG (DOESN'T NEED TO RETURN HERE)
    CALL getRandCorner      ; MS.PAC'S RANDOM ALG
@@setScatter:
    LD (blinky + TARGET_X), HL
    RET
@chase:
    ; BLINKY'S CHASE TARGET IS PAC-MAN
    LD HL, (pacman + CURR_X) ; YX
    LD (blinky + TARGET_X), HL
    RET



/*
--------------------------------------------
        PINKY TARGET DETERMINATION
--------------------------------------------
*/
pinkyTarget:
;   CHECK IF IN CHASE
    LD A, (scatterChaseIndex)
    AND A, $01
    JP NZ, @chase  ; IF SO, PREPARE CHASE TARGET
@scatter:
    ; SET TARGET TO UPPER LEFT CORNER (PAC-MAN ONLY)
    LD HL, $1D39
    ; CHECK IF GAME IS PAC-MAN
    LD A, (plusBitFlags)
    AND A, ($01 << MS_PAC) | ($01 << JR_PAC)
    JP Z, @@setScatter  ; IF SO, SKIP
    ; DO APPROPRIATE FUNCTION
    AND A, $01 << JR_PAC
    JP NZ, getRandTargetJr  ; JR.PAC'S RANDOM ALG (DOESN'T NEED TO RETURN HERE)
    CALL getRandCorner      ; MS.PAC'S RANDOM ALG
@@setScatter:
    LD (pinky + TARGET_X), HL
    RET
@chase:
    ; GET PAC-MAN TILES INTO BC
    LD BC, (pacman + CURR_X)  ; YX
    ; SWAP REGS
    LD A, C     ; BC = YX
    LD C, B
    LD B, A     ; BC = XY
    ; USE PAC-MAN'S DIRECTION AS OFFSET INTO TABLE
    LD A, (pacman.currDir)
    ADD A, A
    LD HL, dirVectors
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    ; GET DIRECTION VECTOR AT CALCULATED OFFSET
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; MULTIPLY IT BY 4      (CARRY ERROR)
    ADD HL, HL
    ADD HL, HL
    ; ADD TO PAC-MAN'S TILES (CARRY ERROR)
    ADD HL, BC
    ; SWAP REGS
    LD A, L     ; HL = XY
    LD L, H
    LD H, A     ; HL = YX
    ; STORE
    LD (pinky + TARGET_X), HL
    RET



/*
--------------------------------------------
        INKY TARGET DETERMINATION
--------------------------------------------
*/
inkyTarget:
;   CHECK IF IN CHASE
    LD A, (scatterChaseIndex)
    AND A, $01
    JP NZ, @chase   ; IF SO, PREPARE CHASE TARGET
@scatter:
    ; SET TARGET TO BOTTOM RIGHT CORNER (PAC-MAN/MS.PAC-MAN)
    LD HL, $4020
    ; CHECK IF GAME IS PAC-MAN OR MS.PAC-MAN
    LD A, (plusBitFlags)
    CP A, $01 << JR_PAC
    JP C, @@setScatter  ; IF SO, SKIP
    ; DO APPROPRIATE FUNCTION
    AND A, $01 << JR_PAC
    JP NZ, getRandTargetJr  ; JR.PAC'S RANDOM ALG (DOESN'T NEED TO RETURN HERE)
    CALL getRandCorner      ; CRAZY OTTO RANDOM ALG
@@setScatter:
    LD (inky + TARGET_X), HL
    RET
@chase:
    ; GET PAC-MAN TILES INTO BC
    LD BC, (pacman + CURR_X) ; YX
    ; SWAP REGS
    LD A, C     ; BC = YX
    LD C, B
    LD B, A     ; BC = XY
    ; USE PAC-MAN'S DIRECTION AS OFFSET INTO TABLE
    LD A, (pacman.currDir)
    ADD A, A
    LD HL, dirVectors
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    ; GET DIRECTION VECTOR AT CALCULATED OFFSET
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; MULTIPLY IT BY 2      (CARRY ERROR)
    ADD HL, HL
    ; ADD TO PAC-MAN'S TILES (CARRY ERROR)
    ADD HL, BC

    LD BC, (blinky + NEXT_X)
    ; SUBTRACT BLINKY'S Y FROM PAC-MAN'S (Y * 2)
    LD A, L
    ADD A, A
    SUB A, B
    LD L, A
    ; SUBTRACT BLINKY'S X FROM PAC-MAN'S (X * 2)
    LD A, H
    ADD A, A
    SUB A, C
    LD H, A
    ; SWAP REGS
    LD A, L
    LD L, H
    LD H, A
    LD (inky + TARGET_X), HL ; YX
    RET



/*
--------------------------------------------
        CLYDE TARGET DETERMINATION
--------------------------------------------
*/
clydeTarget:
;   CHECK IF IN CHASE
    LD A, (scatterChaseIndex)
    AND A, $01
    JP NZ, @chase  ; IF SO, PREPARE CHASE TARGET
@scatter:
    ; SET TARGET TO BOTTOM LEFT CORNER (PAC-MAN/MS.PAC-MAN/JR.PAC-MAN)
    LD HL, $403B
    ; CHECK IF GAME IS CRAZY OTTO
    LD A, (plusBitFlags)
    AND A, $01 << OTTO
    CALL NZ, getRandCorner  ; CRAZY OTTO RANDOM ALG
@@setScatter:
    LD (clyde + TARGET_X), HL
    RET
@chase:
    ; CALCULATE DY (CLYDE_Y - PACMAN_Y)
    LD A, (pacman + CURR_Y)
    LD B, A
    LD A, (clyde + NEXT_Y)
    SUB A, B
    LD C, A     ; SAVE FOR LATER
    ; CALCULATE DX (CLYDE_X - PACMAN_X)
    LD A, (pacman + CURR_X)
    LD B, A
    LD A, (clyde + NEXT_X)
    SUB A, B
    ; GET SQUARE OF X
    OR A
    JP P, +
    NEG
+:
    LD H, hibyte(squareTable)
    ADD A, A
    LD L, A
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    EX DE, HL   ; SAVE FOR LATER
    ; GET SQUARE OF Y
    LD A, C     ; GET BACK DY
    OR A
    JP P, +
    NEG
+:
    LD H, hibyte(squareTable)
    ADD A, A
    LD L, A
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; ADD SQUARES
    ADD HL, DE
    ; CHECK IF PAC-MAN IS LESS THAN 8 TILES AWAY
    LD BC, $40
    OR A    ; CLEAR CARRY
    SBC HL, BC
    JP C, @scatter  ; IF SO, CLYDE WILL USE SCATTER TARGET
    ; ELSE, CLYDE WILL USE BLINKY'S CHASE TARGET (PAC-MAN)
    LD HL, (pacman + CURR_X)
    LD (clyde + TARGET_X), HL
    RET





/*
--------------------------------------------
    SETUP PATHFIND TILES IN WORKAREA
--------------------------------------------
*/
setupPathFinding:
;   COPY NEXT TILE TO CURRENT TILE IN WORKAREA
    LD L, (IX + NEXT_X)
    LD H, (IX + NEXT_Y)
    ;LD (workArea + CURR_X), HL
    LD (PATHFIND_TILES_PTR + CURR_X), HL
;   UPDATE SURROUNDING BUFFER TILES
    PUSH IX
    ;LD IX, workArea
    LD IX, PATHFIND_TILES_PTR
    CALL updateCollTiles
    POP IX
    RET 


/*
    INFO: SELECTS A RANDOM CORNER AS TARGET GIVEN THE CURRENT MAZE (MS.PAC-MAN ONLY)
    USES: AF, HL, R
*/
getRandCorner:
;   GET MAZE INDEX
    LD HL, mazeTargetTable
    CALL getMazeIndex
;   GET RANDOM NUMBER [0,2,4,6]
    LD A, R
    AND A, $06
;   GET CORNER FROM TABLE
    RST addToHL
    JP getDataAtHL




/*
    INFO: SELECTS A RANDOM DIRECTION (JR.PAC-MAN ONLY)
    USES: AF, H, R
*/
getRandTargetJr:
;   GET RANDOM NUMBER
;   & $3F, THEN % $07
    LD A, R
    AND A, $3F
    LD H, $07
-:
    SUB A, H
    JP NC, -
    ADD A, H
;   USE AS INITIAL DIRECTION IN EDIBLE PATHFINDING ALG
    JP ghostPathFindingAI@jrScatterJump