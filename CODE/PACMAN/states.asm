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
    JP Z, @@@update      ; IF NOT, SKIP TRANSITION 
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
    actorSpdPatternUpdate
    RET NC
    INC HL
    INC HL
    INC (HL)
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
    UPDATE - "CHECK IF IN DEMO"
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
    INC HL
+:
    LD A, (HL)
    AND A, $07  ; MODULUS BY 8
    CP A, $04   ; CHECK IF AT CENTER PIXEL
    JP NZ, @@@@prepareVector ; IF NOT, SKIP...
;   CHECK IF PAC-MAN IS ABOUT TO TELEPORT
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    CALL Z, actorWarpCheck
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
    UPDATE - TUNNEL CHECK
------------------------------------------------ 
*/
@@@@tunnelCheck:
;   SKIP IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, @@@@getCollision
;   CHECK IF IN TUNNEL
    LD A, (pacman + CURR_X)
    CP A, $21
    JR C, +     ; LESS THAN
    CP A, $3B
    JR C, @@@@getCollision  ; IF NOT, PROCEED WITH NORMAL UPDATE
+:
;   CHECK IF PLAYER MOVED LEFT
    LD A, (pacman.nextDir)
    CP A, DIR_LEFT
    JR Z, @@@@prepareAxis
;   CHECK IF PLAYER MOVED RIGHT
    CP A, DIR_RIGHT
    JR Z, @@@@prepareAxis
    JP @@@@prepareVector
/*
------------------------------------------------
    UPDATE - MAZE COLLISION
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
    addToHL_M
    LD A, (HL)
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
    addToHL_M
    LD A, (HL)
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
@@@@prepareAxis:    ; $1940
;   SET DIRECTION TO WANTED DIRECTION
    LD A, (pacman.nextDir)
    LD (pacman.currDir), A
@@@@prepareVector:  ; $1950
;   GET MOVEMENT BYTES FROM TABLE
    LD A, (pacman.currDir)
    LD B, A     ; SAVE DIRECTION
/*
------------------------------------------------
    UPDATE - APPLY MAIN AXIS MOVEMENT TO PAC-MAN
------------------------------------------------
*/ 
    OR A
    JP NZ, +
    LD HL, (pacman + Y_WHOLE)   ; 62 (14 + 48) [UP]
    DEC HL
    LD (pacman + Y_WHOLE), HL
    JP @@@@perAxisUpdate
+:
    DEC A
    JP NZ, +
    LD HL, (pacman + X_WHOLE)   ; 76 [LEFT]
    INC HL
    LD (pacman + X_WHOLE), HL
    JP @@@@perAxisUpdate
+:
    DEC A
    JP NZ, +
    LD HL, (pacman + Y_WHOLE)   ; 90 [DOWN]
    INC HL
    LD (pacman + Y_WHOLE), HL
    JP @@@@perAxisUpdate
+:
    LD HL, (pacman + X_WHOLE)   ; 80 [RIGHT]
    DEC HL
    LD (pacman + X_WHOLE), HL
/*
------------------------------------------------
    UPDATE - APPLY PERPENDICULAR AXIS MOVEMENT TO PAC-MAN
------------------------------------------------
*/
@@@@perAxisUpdate:
;   ASSUME PAC-MAN'S PERPENDICULAR AXIS IS X
    LD HL, pacman.xPos
    BIT $00, B
    JR Z, +     ; IF SO, SKIP...
;   ELSE, THE PER. AXIS IS Y
    INC HL
    INC HL
+:
    LD A, (HL)
;   CHECK IF PAC-MAN IS AT CENTER OF TILE (IN PER. AXIS)
    AND A, $07
    CP A, $04
    JR Z, @@@@updateCenters  ; IF SO, SKIP...
;   APPLY CORNERING TO POSITION
    ; BC = POSITION
    LD C, (HL)
    INC HL
    LD B, (HL)
    ; ASSUME BEFORE CENTER, SO INCREMENT POSITION
    INC BC
    JP C, +    ; IF ASSUMPTION WAS CORRECT, SKIP
    ; ELSE, DECREMENT POSITION
    DEC BC
    DEC BC
+:
    ; STORE NEW POSITION
    LD (HL), B
    DEC HL
    LD (HL), C
/*
------------------------------------------------
    UPDATE - UPDATE TILES, PTRS, ETC
------------------------------------------------
*/
@@@@updateCenters:
;   UPDATE ACTOR'S COLLISION TILES, CENTERS, ETC...
    CALL actorUpdate
;   UPDATE CENTERS, TILEMAP PTRS, QUADRANT, ETC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, @@@@jrPtrUpdate
;   --------------
;   CONVERT COLLISION-SPACE TILE COORDS TO SCREEN-SPACE PIXEL COORDS (NON SCROLLING)
;   --------------
    ; TILE Y CENTER POINT
    LD A, (pacman + CURR_Y)
    SUB A, $21          ; COLLISION Y INDEX STARTS AT $21...
    CALL multiplyBy6
    ADD A, MIDTILE_Y    ; ADD 3 PIXELS (TILE Y MID POINT)
    LD (pacTileYCenter), A
    ; TILE X CENTER POINT
    LD A, (pacman + CURR_X)
    LD B, A
    LD A, $3D           ; COLLISION X INDEX STARTS AT $1E AND INCREASES GOING LEFT
    SUB A, B            ; REVERSE ORDER AND CORRECT INDEX BY DOING ((X_START + X_LENGTH - 1) - X_TILE)
    CALL multiplyBy6
    ADD A, MIDTILE_X + $04  ; ADD MID POINT OFFSET, AND MAZE STARTS 4 PIXELS FROM LEFT EDGE
    LD (pacTileXCenter), A
;   --------------
;   VRAM NAMETABLE POINTER UPDATE (NON SCROLLING)
;   --------------
    ; GET X TILE (DIVIDE BY 8)
    RRCA
    RRCA
    RRCA
    AND A, $1F
    ; MULTIPLY BY 2 (TILES ARE 2 BYTES)
    ADD A, A
    ; STORE IN BC
    LD B, $00
    LD C, A
    ; GET Y TILE (DIVIDE BY 8)
    LD A, (pacTileYCenter)
    RRCA
    RRCA
    RRCA
    AND A, $1F
    ; STORE IN HL
    LD H, $00
    LD L, A
    ; MULTIPLY BY 64 (EACH ROW IS 64 BYTES [32 TILES * 2])
    XOR A
    SRL H
    RR L
    RRA
    SRL H
    RR L
    RRA
    LD H, L
    LD L, A
    ; ADD X AND Y TOGETHER
    ADD HL, BC
    ; STORE POINTER
    LD (tileMapPointer), HL
    ; ADD BASE RAM PTR
    LD DE, mazeGroup1.tileMap
    ADD HL, DE
    LD (tileMapRamPtr), HL
    ; UPDATE QUADRANT
    JP @@@@quadCalc
@@@@jrPtrUpdate:
;   --------------
;   CONVERT COLLISION-SPACE TILE COORDS TO SCREEN-SPACE PIXEL COORDS (SCROLLING)
;   --------------
    ; TILE Y CENTER POINT
    LD A, (pacman + CURR_Y)
    SUB A, $21              ; COLLISION Y INDEX STARTS AT $21...
    CALL multiplyBy6
    ADD A, $03 + $02    ; MID POINT + MAZE OFFSET
    LD (pacTileYCenter), A
    ; TILE X CENTER POINT
    LD A, (pacman + CURR_X)
    LD B, A
    LD A, $57           ; COLLISION X INDEX STARTS AT $1E AND INCREASES GOING LEFT
    SUB A, B            ; REVERSE ORDER AND CORRECT INDEX BY DOING ((X_START + X_LENGTH - 1) - X_TILE)
    LD L, A
    LD H, $00
    CALL multBy6_16
    LD DE, $03 - $0A    ; MID POINT - MAZE OFFSET
    ADD HL, DE
    LD A, L
    LD (pacTileXCenter), A
;   --------------
;   RAM NAMETABLE POINTER UPDATE (SCROLLING)
;   --------------
    ; GET X TILE (DIVIDE BY 8)
    RR H    ; MSB WILL BE SET AFTER DUE TO 'ADD HL, DE'. IT'S REMOVED DUE TO LATER BIT SHIFTS
    LD A, L
    RRA
    RRCA
    RRCA
    AND A, $3F
    LD B, A     ; STORE IN B (RAM_COL)
    PUSH AF     ; SAVE RAM_COL FOR LATER
    ; GET Y TILE (DIVIDE BY 8)
    LD A, (pacTileYCenter)
    ; DIVIDE BY 8
    RRCA
    RRCA
    RRCA
    AND A, $1F
    LD L, A     ; STORE IN L (RAM_ROW)
    PUSH HL     ; SAVE RAM_ROW FOR LATER
    ; MULTIPLY BY 41 (TILES PER ROW)
    multBy41
    ; ADD X AND Y
    LD C, B
    LD B, $00
    ADD HL, BC
    ; MULTIPLY BY 2 (TILES ARE 2 BYTES EACH)
    ADD HL, HL
    ; STORE
    LD DE, mazeGroup1.tileMap
    ADD HL, DE
    LD (tileMapRamPtr), HL
;   --------------
;   VRAM NAMETABLE POINTER UPDATE (SCROLLING)
;   --------------
    ; RAM_ROW PROCESS
    POP HL  ; GET RAM_ROW (L)
    INC L   ; APPLY 1 ROW OFFSET (TOP ROW ON SCREEN IS RESERVED FOR HUD)
    ; MULTIPLY BY YTILE 64 (EACH ROW IS 64 BYTES [32 TILES * 2])
    XOR A
    SRL H
    RR L
    RRA
    SRL H
    RR L
    RRA
    LD H, L     ; RESULT IN HL
    LD L, A
    ; RAM_COL PROCESS
    POP DE  ; GET RAM_COL (D)
    LD E, D ; MOVE TO E
    LD D, $00
    ; ADJUST TO SCREEN VIEW
    LD A, (jrScrollReal)
    SRA A           ; SIGNED DIVIDE BY 8
    SRA A
    SRA A
    NEG
    ADD A, E        ; RAM_COL -= XSCROLL_TILE
    AND A, $1F  ; LIMIT TO 0 - 31 (VALID COLUMN RANGE)
    ; ADD LEFT MOST TILE
    LD E, A
    LD A, (jrLeftMostTile)
    NEG
    ADD A, E
    AND A, $1F  ; LIMIT TO 0 - 31 (VALID COLUMN RANGE)
    ADD A, A    ; MULTIPLY XTILE BY 2  (2 BYTES PER TILE)
    LD E, A     ; STORE IN E
    ; ADD X AND Y TOGETHER
    ADD HL, DE
    ; STORE VRAM POINTER
    LD (tileMapPointer), HL
@@@@quadCalc:
;   --------------
;   TILE QUADRANT DERTERMINATION
;   --------------
;   |----|----|
;   |  0 |  2 |
;   |    |    |
;   |____|____|
;   |    |    |
;   |  1 |  3 |
;   |    |    |
;   |----|----|
    ; GET FLIP BITS FROM RAM TILEMAP
    LD HL, (tileMapRamPtr)
    INC HL
    LD A, (HL)  ; GET HORIZONTAL/VERTICAL FLIP BITS
    ; REG SETUP (B = XOR MASK, C = QX, D = $04, E = FLIP BITS)
    LD E, A
    LD D, $04
    ; QX's XOR MASK
    AND A, $02  ; XOR MASK = (FLIP & $02) << $01
    ADD A, A
    LD B, A
    ; QX = ((POS ^ XOR_MASK) & $04) >> $02
    LD A, (pacTileXCenter)
    XOR A, B
    AND A, D
    RRCA
    LD C, A     ; C = QX << $01
    ; QY's XOR MASK
    LD A, E     ; XOR MASK = (FLIP & $04)
    AND A, D
    LD B, A
    ; QY = ((POS ^ XOR_MASK) & $04) >> $02
    LD A, (pacTileYCenter)
    XOR A, B
    AND A, D
    RRCA
    RRCA
    ; QUAD = QY | (QX << $01)
    OR A, C
    ; STORE RESULT
    LD (tileQuadrant), A
@@@exit:
;   NO EXIT
@@@end:
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
    JP Z, @@@update     ; IF NOT, SKIP TRANSITION
@@@enter:
;   STATE IS NO LONGER NEW
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
;   INCREMENT FRAME POSITION
    LD HL, mainTimer1
    INC (HL)
;   UPDATE ACTOR'S DATA IN SPRITE TABLE
    RET





/*
------------------------------------------------
            STATE DRAW ROUTINES
------------------------------------------------
*/




/*
------------------------------------------------
NORMAL, SUPER, DEAD MODE DRAW [TILE STREAMING]
------------------------------------------------
*/
pacStateTable@draw@normalMode:
pacStateTable@draw@superMode:
pacStateTable@draw@deadMode:
displayPacMan:
;   CONVERT POSITION
    LD IX, pacman
    CALL convPosToScreen
;   ADJUST JR'S POSITION (SPRITES ARE NOT CENTERED IN A 12x12 CELL)
    ; UP:   +1,+1 : 0 (0101) 52
    ; LEFT: +1,-1 : 1 (00FF) 60
    ; DOWN: +1,-1 : 2 (00FF) 60
    ; RIGHT:-1,-1 : 3 (FEFF) 68
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, @displaySpr
    ; SUBTRACT 2 IF GOING UP/DOWN AND DYING
    LD A, (pacman.currDir)
    CPL         ; 11, 10, 01, 00
    LD B, A
    LD A, (pacman.state)
    RRA         ; 01 - DEATH
    AND A, B    ; 01, 00, 01, 00    
    JP Z, +
    DEC D
    DEC D
+:
    ; MODIFY X
    INC D
    LD A, B
    CPL
    CP A, $03
    JP C, +
    DEC D
    DEC D
+:
    ; MODIFY Y
    INC E
    OR A
    JP Z, @displaySpr
    DEC E
    DEC E
@displaySpr:
;   DISPLAY SPRITE
    LD A, $01               ; FIXED SPRITE ID
    LD HL, playerTileList   ; FIXED TILE LIST
    JP display4TileSprite

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
    LD A, $01
;   DISPLAY SPRITE
    JP display9TileSprite     ; 9 TILE SPRITE