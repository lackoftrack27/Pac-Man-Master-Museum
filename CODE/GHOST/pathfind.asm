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
    .DW pacmanPF    ; 4


blinkyPF:
    LD IX, blinky
    JR ghostPathFindingAI
pinkyPF:
    LD IX, pinky
    JR ghostPathFindingAI
inkyPF:
    LD IX, inky
    JR ghostPathFindingAI
clydePF:
    LD IX, clyde
    JR ghostPathFindingAI
pacmanPF:
    LD IX, pacman
    JP pacmanDemoPF



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
    JR Z, +     ; IF NOT, SKIP
    ; CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    JR NZ, @scaredPathfind  ; IF SO, DO SCARED PATHFIND
    ; ELSE, MAKE GHOST GO HOME
    LD HL, $2C2E
    LD (IX + TARGET_X), L
    LD (IX + TARGET_Y), H
    JP @normalPathFinding
+:
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
    ; SCATTER/CHASE/GOTO_HOME PATHFINDING
    ; (workArea + 58): LOWEST
    ; (workArea + 60): ID ADDRESS 
    ; (workArea + 62): NEW DIRECTION
    ; (workArea + 63): COUNTER
    ; SET LOWEST
    LD HL, $FFFF
    LD (lowestDist), HL
    ; SET ID ADDRESS
    LD HL, workArea + RIGHT_ID
    LD (idAddress), HL
    ; SET NEW DIRECTION
    LD A, (IX + CURR_DIR)
    LD (newDir), A
    ; SET COUNTER
    LD A, $03
    LD (counter), A
-:
    ; CHECK IF TILE IS WALKABLE
    LD HL, idAddress    ; GET ID
    RST getDataAtHL
    LD A, (HL)
    AND A, $03      ; ONLY CARE ABOUT LOWEST 2 BITS
    DEC A           ; CHECK IF TILE IS WALL (IF ID WAS 1)
    JR Z, @prepareNextLoop  ; IF SO, SKIP...
    ; CHECK IF TILE IS NOT IN REVERSE DIRECTION
    LD B, (IX + REVE_DIR)
    LD A, (counter)
    SUB A, B
    JR Z, @prepareNextLoop
    ; CALCULATE DY (TARGET_Y - DIR_Y)
    DEC HL  ; POINT TO Y OF CURRENT TILE
    LD B, (HL)
    LD A, (IX + TARGET_Y)
    SUB A, B
    LD C, A     ; SAVE FOR LATER
    ; CALCULATE DX (TARGET_X - DIR_X)
    DEC HL  ; POINT TO X OF CURRENT TILE
    LD B, (HL)
    LD A, (IX + TARGET_X)
    SUB A, B
    ; GET SQUARE OF DX
    CALL squareNumber
    PUSH HL     ; STORE FOR LATER
    ; GET SQUARE OF DY
    LD A, C     ; GET BACK DY
    CALL squareNumber
    ; ADD SQUARES
    POP BC      ; PUT X^2 INTO BC
    ADD HL, BC
    ; CHECK IF DISTANCE IS LOWER THAN CURRENT LOWEST
    LD DE, (lowestDist)  ; GET LOWEST INTO BC
    EX DE, HL
    OR A    ; CLEAR CARRY
    SBC HL, DE
    JR C, @prepareNextLoop      ; IF NOT, SKIP...
    ; ELSE, DISTANCE IS NOW NEW LOWEST
    LD (lowestDist), DE
    ; ALSO, SET NEW DIRECTION TO COUNTER
    LD A, (counter)
    LD (newDir), A
@prepareNextLoop:
    ; ADD -3 TO ID_ADDRESS (POINT TO NEXT TILE)
    LD HL, (idAddress)
    LD A, $FD
    DEC H
    RST addToHL
    LD (idAddress), HL
    ; INCREMENT COUNTER
    LD HL, counter
    DEC (HL)
    JP P, -     ; KEEP GOING IF NO OVERFLOW
;   SET NEW DIRECTION
    JR @setNewDirection
/*
--------------------------------------------
            SCARED PATHFINDING
--------------------------------------------
*/
@scaredPathfind:
    ; SCARED PATHFINDING
    ; (workArea + 60): ID ADDRESS 
    ; (workArea + 62): NEW DIRECTION
    ; GET RANDOM NUMBER
    CALL randNumGen
    ; LIMIT IT TO 0 - 3
    AND A, $03
    ; CONVERT NUMBER FROM HOW DIRECTIONS ARE ORDERED IN THE OG GAME [0,1,2,3] -> [3,2,1,0]
    LD B, A
    LD A, $03
    SUB A, B
-:
    ; SAVE DIRECTION
    LD (newDir), A
    ; CHECK IF TILE IS IN REVERSE DIRECTION
    CP A, (IX + REVE_DIR)
    JR Z, @clockwiseChange  ; IF SO, CHANGE DIRECTION IN CLOCKWISE ORDER AND TRY AGAIN
    ; CONVERT NUMBER INTO OFFSET
    LD B, A     ; MULTIPLY BY 3
    ADD A, A
    ADD A, B
    ; ADD OFFSET TO BASE ID ADDRESS
    LD HL, workArea + UP_ID
    RST addToHL
    ; CHECK IF TILE IS WALKABLE
    AND A, $03      ; ONLY CARE ABOUT LOWEST 2 BITS
    DEC A           ; CHECK IF TILE IS WALL (IF ID WAS 1)
    JR NZ, @setNewDirection ; IF NOT, STOP LOOP
    ; ELSE, CHANGE DIRECTION IN CLOCKWISE ORDER AND TRY AGAIN
@clockwiseChange:
    LD A, (newDir)
    DEC A
    AND A, $03
    JR -
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
    JR NZ, @chase  ; IF SO, SET TARGET TO BE PAC-MAN
;   IF NOT, HE MUST BE IN SCATTER...
    ; CHECK IF DIFF STATE ISN'T 0
    LD A, (difficultyState)
    OR A
    JR NZ, @chase   ; IF SO, SET TARGET TO CHASE
@scatter:
    ; BLINKY'S SCATTER TARGET IS UPPER RIGHT CORNER
    LD HL, $1D22
    ; CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    CALL NZ, getRandCorner  ; IF SO, MAKE TARGET A RANDOM CORNER
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
    JR NZ, @chase  ; IF SO, PREPARE CHASE TARGET
@scatter:
    ; SET TARGET TO UPPER LEFT CORNER
    LD HL, $1D39
    ; CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    CALL NZ, getRandCorner  ; IF SO, MAKE TARGET A RANDOM CORNER
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
    RST addToHL
    ; GET DIRECTION VECTOR AT CALCULATED OFFSET
    RST getDataAtHL
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
    JR NZ, @chase   ; IF SO, PREPARE CHASE TARGET
@scatter:
    ; SET TARGET TO BOTTOM RIGHT CORNER
    LD HL, $4020
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
    RST addToHL
    ; GET DIRECTION VECTOR AT CALCULATED OFFSET
    RST getDataAtHL
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
    JR NZ, @chase  ; IF SO, PREPARE CHASE TARGET
@scatter:
    ; SET TARGET TO BOTTOM LEFT CORNER
    LD HL, $403B
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
    CALL squareNumber
    PUSH HL     ; STORE X^2 FOR LATER
    ; GET SQUARE OF Y
    LD A, C     ; GET BACK DY
    CALL squareNumber
    ; ADD SQUARES
    POP BC      ; PUT X^2 INTO BC
    ADD HL, BC
    ; CHECK IF PAC-MAN IS LESS THAN 8 TILES AWAY
    LD BC, $40
    OR A    ; CLEAR CARRY
    SBC HL, BC
    JR C, @scatter  ; IF SO, CLYDE WILL USE SCATTER TARGET
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
    LD (workArea + CURR_X), HL
;   UPDATE SURROUNDING BUFFER TILES
    PUSH IX
    LD IX, workArea
    CALL updateCollTiles
    POP IX
    RET 


/*
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