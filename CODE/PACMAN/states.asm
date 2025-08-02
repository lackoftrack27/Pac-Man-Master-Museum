/*
------------------------------------------------
            STATE UPDATE ROUTINES
------------------------------------------------
*/



/*
------------------------------------------------
            NORMAL MODE UPDATE
------------------------------------------------
*/
pacStateTable@update@normalMode:
;   CHECK STATE
    LD A, (pacman.newStateFlag)   ; CHECK THIS IS A NEW STATE
    OR A
    JR Z, @@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
    ; SET SPEED POINTER TO NORMAL
    LD HL, spdPatternNormal
@@@@setSpdPtr:
    LD (spdPatternPtr), HL
    ; STATE IS NO LONGER NEW
    XOR A
    LD (pacman.newStateFlag), A
@@@update:
/*
------------------------------------------------
    UPDATE - DOT COUNTER CHECK
------------------------------------------------
*/
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    JR NZ, +    ; IF SO, IGNORE SPEED UP FLAG
;   CHECK IF SPEED UP FLAG IS SET
    LD A, (speedUpFlag)
    OR A
    JR NZ, @@@@prepUpdate ; IF SO, PAC-MAN CAN MOVE EVERY UPDATE
+:
;   CHECK IF DOT DELAY TIMER IS $FF
    LD HL, pacPelletTimer
    BIT 7, (HL) ; MSB SET
    JR NZ, @@@@speedPatCheck    ; IF SO, CONTINUE WITH UPDATE
    DEC (HL)    ; DECREMENT TIMER
    RET         ; BUT, DON'T UPDATE
/*
------------------------------------------------
    UPDATE - SPEED PATTERN CHECK
------------------------------------------------
*/
@@@@speedPatCheck:
    LD HL, (spdPatternPtr)
    CALL actorSpdPatternUpdate
/*
------------------------------------------------
    UPDATE - PREPARATION
------------------------------------------------
*/
@@@@prepUpdate:
    LD IX, pacman   ; SET ACTOR POINTER
;   SAVE DOT COUNT FOR DOT EXPIRE COUNTER
    LD A, (currPlayerInfo.dotCount)
    LD (dotExpireCounter), A
/*
------------------------------------------------
    UPDATE - "CHECK IF IN DEMO" SECTION
------------------------------------------------ 
*/
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    JR Z, @@@@tunnelCheck  ; IF NOT, SKIP...
;   ------------------------------------------
;                   DEMO LOGIC
;   ------------------------------------------
;   CHECK IF PAC-MAN IS AT CENTER OF TILE
    ; SAVE CURRENT DIRECTION IN D
    LD A, (pacman.currDir)
    LD D, A     ; SAVE IN D
    ; ASSUME PAC-MAN'S AXIS IS X
    LD HL, pacman.xPos
    BIT 0, D
    JR NZ, +     ; IF SO, SKIP...
    ; ELSE, AXIS IS Y
    INC HL
+:
    LD A, (HL)
    AND A, $07  ; MODULUS BY 8
    CP A, $04   ; CHECK IF AT CENTER PIXEL
    JP NZ, @@@@prepareVector ; IF NOT, SKIP...
;   CHECK IF PAC-MAN IS ABOUT TO TELEPORT
    CALL actorWarpCheck
    JR C, +     ; IF SO, SKIP PATHFINDING
    LD A, $04
    CALL addTask
+:
;   SET NEXT TILE TO NEXT TILE IN CURRENT DIRECTION
    CALL setNextTile
;   SET CURRENT DIRECTION TO NEXT DIRECTION
    LD A, (pacman.nextDir)
    LD (pacman.currDir), A
;   SET REVERSE DIRECTION
    XOR A, $02
    LD (pacman.reveDir), A
    JR @@@@prepareVector


/*
------------------------------------------------
    UPDATE - TUNNEL CHECK SECTION
------------------------------------------------ 
*/
@@@@tunnelCheck:
;   CHECK IF IN TUNNEL
    LD A, (pacman + CURR_X)
    CP A, $21
    JR C, +     ; LESS THAN
    CP A, $3B
    JR C, @@@@getCollision
+:
;   CHECK IF PLAYER MOVED LEFT
    LD A, (pacman.nextDir)
    CP A, DIR_LEFT
    JR Z, @@@@prepareAxis
;   CHECK IF PLAYER MOVED RIGHT
    CP A, DIR_RIGHT
    JR Z, @@@@prepareAxis
    JR @@@@prepareVector
/*
------------------------------------------------
    UPDATE - MAZE COLLISION SECTION
------------------------------------------------ 
*/
@@@@getCollision:
;   SAVE CURRENT DIRECTION IN D
    LD A, (pacman.currDir)
    LD D, A
;   SAVE INPUT FLAG IN E
    LD A, (inputFlag)
    LD E, A
;   CALCULATE TILE ID OFFSET (BASED ON WANTED DIRECTION)
    LD A, (pacman.nextDir)
    LD L, A
    ADD A, A    ; MULTIPLY BY 3 (EACH TILE IS 3 BYTES)
    ADD A, L
;   ADD OFFSET TO FIRST TILE ID ADDRESS
    LD HL, pacman + UP_ID
    RST addToHL
;   HL = TILE ID PTR FOR WANTED DIRECTION, A = TILE ID
    AND A, $03     ; KEEP LOWER 2 BITS (PAC-MAN DOESN'T USE UPPER TWO BITS)
    DEC A   ; CHECK IF ID ISN'T 1 (WALL)
    JR NZ, @@@@prepareAxis ; IF SO, MOVE IN WANTED DIRECTION
;   ---------------------------------------------
;   CHECK IF INPUT WAS APPLIED (IS 1?)
    DEC E
    INC E
    JR Z, @@@@chkCenterOfTile   ; IF NOT, CHECK IF PAC-MAN IS AT CENTER OF TILE
/*
------------------------------------------------
    UPDATE - CHECK IF CURRENT DIRECTION IS VALID 
    (NEEDED IF PAC-MAN'S WANTED DIRECTION ISN'T)
------------------------------------------------
*/
@@@@chkCurrDirTile:
;   CHECK IF TILE IN CURRENT DIRECTION IS UNWALKABLE
    ; CONVERT DIRECTION TO OFFSET
    LD A, (pacman.currDir)
    LD L, A
    ADD A, A    ; MULTIPLY BY 3
    ADD A, L
    ; ADD OFFSET TO FIRST TILE ID ADDRESS
    LD HL, pacman + UP_ID ; SET BC TO FIRST TILE ID (10)
    RST addToHL
;   HL = TILE ID PTR FOR WANTED DIRECTION, A = TILE ID
    AND A, $03     ; KEEP LOWER 2 BITS (PAC-MAN DOESN'T USE UPPER TWO BITS)
    DEC A       ; CHECK IF 1 (WALL)
    JR NZ, @@@@prepareVector ; IF NOT, MOVE BUT IGNORE USER INPUT
;   ---------------------------------------------
@@@@chkCenterOfTile:
;   ASSUME PAC-MAN'S AXIS IS X
    LD HL, pacman.xPos
    BIT $00, D
    JR NZ, +     ; IF SO, SKIP...
;   ELSE, AXIS IS Y
    INC HL
+:
    LD A, (HL)
;   CHECK IF PAC-MAN IS AT CENTER OF TILE
    AND A, $07
    CP A, $04
    RET Z       ; IF SO, END
;   CHECK IF INPUT WAS APPLIED (IS 1?)
    DEC E
    JR Z, @@@@prepareVector ; IF SO, SKIP...
/*
------------------------------------------------
    UPDATE - PREPARE FOR MOVEMENT
------------------------------------------------
*/
@@@@prepareAxis:
;   SET DIRECTION TO WANTED DIRECTION
    LD A, (pacman.nextDir)
    LD (pacman.currDir), A
@@@@prepareVector:
;   SET WHICH AXIS TO APPLY MOVEMENT AND HOW
    ; CURRENT DIRECTION * 2
    LD A, (pacman.currDir)
    LD D, A     ; SAVE DIRECTION
    ADD A, A
    ; ADD TO TABLE
    LD HL, dirVectors
    RST addToHL
    ; HL NOW HAS ADDRESS OF WANTED VECTOR
/*
------------------------------------------------
    UPDATE - APPLY MAIN AXIS MOVEMENT TO PAC-MAN
------------------------------------------------
*/ 
@@@@chooseAxis:
;   ADD Y PART OF VECTOR TO POSITION
    LD A, (pacman.yPos)
    ADD A, (HL)
    LD (pacman.yPos), A
;   ADD X PART OF VECTOR TO POSITION
    INC HL
    LD A, (pacman.xPos)
    ADD A, (HL)
    LD (pacman.xPos), A
/*
------------------------------------------------
    UPDATE - APPLY PERPENDICULAR AXIS MOVEMENT TO PAC-MAN
------------------------------------------------
*/
;   ASSUME PAC-MAN'S PERPENDICULAR AXIS IS X
    LD HL, pacman.xPos
    BIT $00, D
    JR Z, +     ; IF SO, SKIP...
;   ELSE, THE PER. AXIS IS Y
    INC HL
+:
    LD A, (HL)
;   CHECK IF PAC-MAN IS AT CENTER OF TILE (IN PER. AXIS)
    AND A, $07
    CP A, $04
    JR Z, @@@@updateCenters  ; IF SO, SKIP...
    JR C, +     ; IF LESS THAN 3, SKIP...
;   IF AFTER CENTER, DECREMENT POSITION
    DEC (HL)
    JR @@@@updateCenters
+:
;   IF BEFORE CENTER, INCREMENT POSITION
    INC (HL)
/*
------------------------------------------------
    UPDATE - UPDATE TILES IF PAC-MAN VISIBLY MOVED
------------------------------------------------
*/
@@@@updateCenters:
;   UPDATE ACTOR'S COLLISION TILES, CENTERS, ETC...
    CALL actorUpdate
;   UPDATE VISUAL TILE CENTER
    ; TILE Y CENTER POINT
    LD A, (pacman + CURR_Y)
    SUB A, $21
    CALL multiplyBy6
    ADD A, MIDTILE_Y    ; ADD 3 PIXELS (TILE Y MID POINT)
    LD (pacTileYCenter), A
    ; TILE X CENTER POINT
    LD A, (pacman + CURR_X)
    LD B, A
    LD A, $3D
    SUB A, B
    CALL multiplyBy6
    ADD A, MIDTILE_X    ; ADD 2 PIXELS (TILE X MID POINT)
    LD (pacTileXCenter), A
;   VRAM NAMETABLE POINTER UPDATE
    ; LOAD BASE ADDRESS
    LD DE, NAMETABLE
    ; CALCULATE X TILE OFFSET
    ADD A, $04  ; X_OFFSET
    ; DIVIDE BY 8
    AND A, $F8
    RRCA
    RRCA
    RRCA
    ; MULTIPLY BY 2 (TILES ARE 2 BYTES)
    ADD A, A
    ; STORE IN BC
    LD B, $00
    LD C, A
    ; CALCULATE Y TILE OFFSET
    LD A, (pacTileYCenter)
    ; DIVIDE BY 8
    AND A, $F8
    RRCA
    RRCA
    RRCA
    ; STORE IN HL
    LD H, $00
    LD L, A
    ; MULTIPLY BY 64 (EACH ROW IS 64 BYTES [32 TILES * 2])
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    ; ADD X AND Y TOGETHER
    ADD HL, BC
    ; ADD TO NAMETABLE
    ADD HL, DE
    ; STORE POINTER
    LD (tileMapPointer), HL
;   TILE QUADRANT DERTERMINATION
;   |----|----|
;   |  0 |  2 |
;   |    |    |
;   |____|____|
;   |    |    |
;   |  1 |  3 |
;   |    |    |
;   |----|----|
    ; GET FLIP BITS FROM VRAM TILEMAP
    INC HL
    RST setVDPAddress
    ; REG SETUP (B: RESULT, C: X-CHANGE, D: Y-CHANGE, E: FLIP BITS)
    LD BC, $0002
    LD D, $01
    ; GET AND ISOLATE FLIP BITS
    IN A, (VDPDATA_PORT)    ; GET HORIZONTAL/VERTICAL FLIP BITS
    AND A, $06      ; KEEP ONLY THOSE BITS
    LD E, A         ; SAVE IN E
    JR Z, @@@@calcQuad ; IF BOTH BITS ARE CLEAR, PROCESS QUAD
    ; ASSUME VERTICAL FLIP
    INC B       ; ADD ONE TO QUAD
    LD D, $FF   ; SET Y-CHANGE TO -1
    BIT 1, E    ; CHECK IF HORIZONTAL BIT ISN'T SET
    JR Z, @@@@calcQuad  ; IF SO, ONLY VERTICAL BIT IS SET. PROCESS QUAD
    ; ASSUME HORIZONTAL FLIP
    INC B       ; ADD ONE TO QUAD
    LD C, $FE   ; SET X-CHANGE TO -2
    LD D, $01   ; SET Y-CHANGE TO 1
    BIT 2, E    ; CHECK IF VERTICAL BIT ISN'T SET
    JR Z, @@@@calcQuad   ; IF SO, ONLY HORIZONTAL BIT IS SET. PROCESS QUAD
    ; PREPARE FOR FLIP IN BOTH AXIS
    INC B       ; ADD ONE TO QUAD
    LD D, $FF   ; SET Y-CHANGE TO -1
@@@@calcQuad:
;   DO X
    LD A, (pacTileXCenter)
    ADD A, $04  ; ADD 4 (SCREEN OFFSET)
    AND A, $07  ; MODULUS BY 8
    CP A, $04   ; CHECK IF NUMBER IS 4 OR GREATER
    JR C, +     ; IF NOT, SKIP
    ; IF SO, ADD X-CHANGE
    LD A, B     ; ADD X-CHANGE TO RESULT
    ADD A, C    
    LD B, A     ; STORE BACK INTO RESULT
+:
;   DO Y
    LD A, (pacTileYCenter)
    AND A, $07  ; MODULUS BY 8
    CP A, $04   ; CHECK IF NUMBER IS 4 OR GREATER
    LD A, B     ; PUT RESULT IN A
    JR C, +     ; IF NOT, SKIP
    ; IF SO, ADD Y-CHANGE
    ADD A, D    ; ADD TO RESULT
+:
;   STORE RESULT
    LD (tileQuadrant), A
@@@exit:
;   NO EXIT
@@@end:
    ;RET
    JP mazeUpdate




/*
------------------------------------------------
            SUPER MODE UPDATE
------------------------------------------------
*/
pacStateTable@update@superMode:
;   CHECK STATE
    LD A, (pacman.newStateFlag)   ; CHECK THIS IS A NEW STATE
    OR A
    JP Z, pacStateTable@update@normalMode@@@update      ; IF NOT, SKIP TRANSITION 
@@@enter:
    ; SET SPEED POINTER TO NORMAL
    LD HL, spdPatternSuper
    ; GOTO NORMAL MODE'S UPDATE
    JP pacStateTable@update@normalMode@@@enter@setSpdPtr




/*
------------------------------------------------
                DEAD MODE UPDATE
------------------------------------------------
*/
pacStateTable@update@deadMode:
;   CHECK STATE
    LD A, (pacman.newStateFlag)   ; CHECK THIS IS A NEW STATE
    OR A
    JR Z, @@@update     ; IF NOT, SKIP TRANSITION
@@@enter:
    ; STATE IS NO LONGER NEW
    XOR A
    LD (pacman.newStateFlag), A
;   SET TIME FOR FIRST ANIMATION
    LD HL, (pacDeathTimePtr)
    LD A, (HL)
    LD (pacDeathTimer), A
@@@update:
;   DECREMENT, THEN CHECK IF TIMER IS 0
    LD HL, pacDeathTimer
    DEC (HL)
    RET NZ  ; IF NOT, END...
;   INCREMENT DEATH TIME POINTER
    LD HL, (pacDeathTimePtr)
    INC HL
    LD (pacDeathTimePtr), HL
;   SET TIME VALUE
    LD A, (HL)
    LD (pacDeathTimer), A
    RET





/*
------------------------------------------------
            STATE DRAW ROUTINES
------------------------------------------------
*/




/*
------------------------------------------------
            NORMAL AND SUPER MODE DRAW
------------------------------------------------
*/
pacStateTable@draw@normalMode:
pacStateTable@draw@superMode:
displayPacMan:
    LD A, (plusBitFlags)
    LD C, A
;   SAVE CURRENT DIRECTION IN B
    LD A, (pacman.currDir)
    LD B, A
;   DETERMINE FRAME THAT WILL BE DISPLAYED (CLOSED, HALF, OPEN)
    LD HL, pacman.xPos  ; ASSUME PAC-MAN IS MOVE ALONG X-AXIS
    BIT 0, B    ; CHECK IF PAC-MAN ACTUALLY IS
    JR NZ, +   ; IF SO, SKIP TO MODULUS
    INC HL      ; IF NOT, LOAD PAC-MAN'S Y POSITION
+:
    LD A, (HL)  ; GET POSITION
;   CALCULATE TABLE INDEX
    ; MODULUS POSITION BY 8, THEN DIVIDE BY 2
    AND A, $07
    RRA
    LD D, A     ; SAVE IN D
    ; MULTIPLY DIRECTION BY 4
    LD A, B
    ADD A, A
    ADD A, A
    ; ADD POSITION AND DIRECTION
    ADD A, D
    ; MULTIPLY BY 4 (EACH SPRITE IS 4 BYTES)
    ADD A, A
    ADD A, A
;   ADD TABLE INDEX TO BASE ADDRESS
    LD HL, pacSpriteTable
    BIT 1, C
    JR Z, +
    LD HL, msPacSpriteTable
+:
    RST addToHL
;   PREPARE X AND Y
    LD IX, pacman
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (pacman.sprTableNum)
;   DRAW SPRITE
    JP display4TileSprite


    

/*
------------------------------------------------
                DEAD MODE DRAW
------------------------------------------------
*/
pacStateTable@draw@deadMode:
    LD IX, pacman
;   GET FRAME BY FINDING DIFFERENCE
    LD HL, (pacDeathTimePtr)
    LD BC, pacmanDeathTimes
    OR A    ; CLEAR CARRY
    SBC HL, BC
    LD A, L
;   CHECK IF GAME IS MS. PAC
    LD HL, plusBitFlags
    BIT 1, (HL)
    JR NZ, msDeadDraw   ; IF SO, SKIP
;   PREPARE TO DRAW
    LD HL, pacDeathTileDefs
@deadDraw:
;   CONVERT NUMBER TO OFFSET
    ADD A, A
    ADD A, A
;   ADD OFFSET TO ADDRESS
    RST addToHL
;   LOAD X AND Y
    CALL convPosToScreen
;   LOAD SPRITE'S TABLE NUMBER
    LD A, (pacman.sprTableNum)
;   DRAW
    JP display4TileSprite    ; IF FLAG IS SET, DISPLAY AS 4 TILE SPRITE
msDeadDraw:
;   CHECK TO SEE IF ANIMATION IS DONE
    CP A, $0B
    RET Z       ; IF SO, END
;   PREPARE TO DRAW
    LD HL, msPacDeathTileDefs   ; LOAD DEATH TILE DEFINITIONS
;   CONVERT NUMBER TO OFFSET
    AND A, $03
    JR pacStateTable@draw@deadMode@deadDraw



/*
------------------------------------------------
    BIG MODE DRAW [PAC-MAN CUTSCENE 1 ONLY]
------------------------------------------------
*/
pacStateTable@draw@bigMode:
;   CALCULATE TABLE INDEX
    ; MODULUS POSITION BY 16
    LD A, (pacman.xPos)
    SUB A, $08  ; ADJUST
    AND A, $0F
    ; DIVIDE BY 4
    RRA
    SRL A
    ; MULTIPLY BY 2 (EACH ADDRESS IS 2 BYTES)
    ADD A, A
;   ADD TABLE INDEX TO BASE ADDRESS
    LD HL, pacBigSpriteTable
    RST addToHL
;   GET VALUE AT ADDRESS
    RST getDataAtHL
;   PREPARE X AND Y
    LD IX, pacman
    CALL convPosToScreen
;   GET SPRITE NUMBER
    LD A, (pacman.sprTableNum)
;   DISPLAY SPRITE
    JP display9TileSprite     ; 9 TILE SPRITE