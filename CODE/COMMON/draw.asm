/*
------------------------------------------------
            DRAW RELEATED FUNCTIONS
------------------------------------------------
*/


/*
    INFO: DRAW FUNCTION USED FOR GAMEPLAY MODES AND PAC-MAN CUTSCENES
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL, IX
*/
generalGamePlayDraw:
;   SPECIAL DRAW CHECK FOR SUPER
    LD A, (pacPoweredUp)
    OR A
    JR Z, +    ; IF NOT SUPER, SKIP
    ; CLEAR PAC-MAN SPRITE AREA
    LD A, $01
    LD (pacSprControl), A
    ; TURN MAZE INVISIBLE (PLUS)
    LD HL, plusBitFlags
    BIT INVISIBLE_MAZE, (HL)     ; CHECK IF MAZE IS INVISIBLE
    JR Z, +        ; IF NOT, SKIP
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD BC, BGPAL_PDOT0 * $100 + VDPDATA_PORT    ; DO UP TO, BUT NOT INCLUDING, 1ST POW DOT COLOR
-:
    OUT (C), A  ; A IS CLEARED BY setVDPAddress
    DJNZ -
+:
;   PAC-MAN SPRITE SPECIAL PROCESS
    CALL pacSprCmdProcess
;   ADD LIFE (WHEN 1UP FLAG IS SET)
    CALL addLifeOnScreen
;   DRAW SCORE AND HIGH SCORE
    CALL drawScores
;   DRAW 1UP
    CALL draw1UP
;   DRAW MAZE (WHEN THERE IS AN UPDATE)
    CALL drawMaze
;   POWER PELLET PALETTE CYCLING
    CALL drawPowDots
;   DRAW ACTORS
    ; PAC-MAN
    LD HL, pacStateTable@draw
    LD A, (pacman.state)
    RST jumpTableExec
    ; BLINKY
    LD IX, blinky
    LD HL, ghostStateTable@draw
    LD A, (blinky.state)
    RST jumpTableExec
    ; PINKY
    LD IX, pinky
    LD HL, ghostStateTable@draw
    LD A, (pinky.state)
    RST jumpTableExec
    ; INKY
    LD IX, inky
    LD HL, ghostStateTable@draw
    LD A, (inky.state)
    RST jumpTableExec
    ; CLYDE
    LD IX, clyde
    LD HL, ghostStateTable@draw
    LD A, (clyde.state)
    RST jumpTableExec
;   DRAW FRUIT OR FRUIT POINTS (IN MAZE)
    CALL drawInMazeFruit
;   DRAW GHOST POINTS (IF NEEDED)
    JP drawGhostPoints



/*
    INFO: UPDATES POWER DOT PALETTE FROM RAM
    INPUT: NONE
    OUTPUT: NONE
    USES: BC, HL
*/
drawPowDots:
;   PREPARE VDP
    LD HL, BGPAL_PDOT0 | CRAMWRITE
    RST setVDPAddress
;   SEND PALETTE TO VDP CRAM
    LD HL, powDotPalette    ; RAM OFFSET (HL)
    ; AMOUNT OF COLORS AND DATA PORT
    LD BC, $04 * $100 + VDPDATA_PORT
    OTIR
    RET



/*
    INFO: UPDATES MAZE IF TILE BUFFER ISN'T EMPTY
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawMaze:
;   CHECK IF FLAG IS SET
    LD HL, tileBufferFlag
    BIT 0, (HL)
    RET Z   ; IF NOT, EXIT
;   LOOP PREP
    LD (HL), $00    ; CLEAR FLAG
    INC HL          ; tileBufferCount
    LD B, (HL)      ; LOAD COUNTER INTO B
    LD (HL), $00    ; CLEAR COUNTER
    LD DE, tileBuffer
    LD C, VDPDATA_PORT
-:
    ; SET VRAM ADDRESS
    LD HL, (tileBufferAddress)
    LD A, (DE)      ; GET OFFSET
    RST addToHL     ; ADD TO VRAM ADDRESS
    SET $06, H      ; VRAM WRITE OP
    RST setVDPAddress
    INC DE          ; POINT TO TILE DATA
    ; WRITE DATA
    EX DE, HL       ; HL: TILE BUFFER ADDRESS
    OUTI            ; LOW BYTE
    OUTI            ; HIGH BYTE
    EX DE, HL       ; HL: VRAM ADDRESS
    INC B
    INC B
    ; CHECK COUNTER
    DJNZ -
    RET



/*
    INFO: DRAWS FRUIT IN THE CENTER OF MAZE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL
*/
drawInMazeFruit:
;   CONTINUE ONLY IF IN NORMAL MODE
    LD A, (subGameMode)
    CP A, GAMEPLAY_NORMAL
    RET NZ
;   CHECK IF FRUIT IS BEING DROPPED BY FLICKER CONTROL
    LD A, (sprFlickerControl)
    BIT 4, A
    JR NZ, @clearSprite ; IF SO, CLEAR FRUIT SPRITE
;   CHECK IF GAME IS MS. PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, msDrawMazeFruit ; IF SO, SKIP
;   CHECK IF LOW NIBBLE OF STATUS IS 0 (NO FRUIT ON SCREEN)
    LD A, (currPlayerInfo.fruitStatus)
    AND A, $0F
    JR Z, @clearSprite  ; IF SO, CLEAR FRUIT SPRITE
    ; ASSUME FRUIT WILL BE DISPLAYED (LOW NIBBLE == 1)
    LD HL, (fruitTileDefPtr)
    LD DE, 94 * $100 + 99
;   CHECK IF LOW NIBBLE OF STATUS IS 1 (FRUIT ON SCREEN)
    DEC A
    JR Z, @execDraw     ; IF SO, SKIP TO PREPARING DRAW
    ; IF NOT, DRAW POINTS INSTEAD (LOW NIBBLE == 2)
    LD HL, (fruitPointTDefPtr)
    LD D, 92    ; MOVE TO THE LEFT A BIT
@execDraw:
    LD A, 25
    JP display4TileSprite
@clearSprite:
    LD HL, SPRITE_TABLE + 25 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    RET
msDrawMazeFruit:
;   CHECK IF LOW NIBBLE OF STATUS IS 0 (NO FRUIT ON SCREEN)
    LD A, (currPlayerInfo.fruitStatus)
    AND A, $0F
    JR Z, drawInMazeFruit@clearSprite ; IF SO, CLEAR FRUIT SPRITE
    ; ASSUME FRUIT WILL BE DISPLAYED
    LD HL, (fruitTileDefPtr)
;   CHECK IF LOW NIBBLE OF STATUS IS 1 (FRUIT ON SCREEN)
    DEC A
    JR Z, +    ; IF IT ACTUALLY IS, SKIP TO PREPARING DRAW
    ; IF NOT, DISPLAY POINTS INSTEAD
    LD HL, (fruitPointTDefPtr)
+:
    LD IX, fruitPos - 1
    CALL convPosToScreen
    JR drawInMazeFruit@execDraw

    


/*
    INFO: DRAWS GHOST POINTS
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, IX
*/
drawGhostPoints:
;   ONLY CONTINUE IF EATING GHOST
    LD A, (ghostPointSprNum)
    OR A
    RET Z   ; IF NOT, EXIT
;   DRAW GHOST POINTS ON PAC-MAN
    ; CONVERT INDEX INTO OFFSET
    LD A, (ghostPointIndex)
    ADD A, A
    ; ADD OFFSET TO BASE TILE DEF. TABLE
    LD HL, ghostPointTileDefs
    RST addToHL
    ; DRAW POINTS
    LD IX, ghostPointXpos - 1
    CALL convPosToScreen
    LD A, $01           ; DISPLAY OVER PAC-MAN
    JP display2HTileSprite


/*
    INFO: UPDATES COUNTERS FOR GHOST ANIMATION
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, HL
*/
ghostVisCounterUpdate:
;   DON'T UPDATE IF IN EAT MODE (FREEZE GHOST ANIMATION)
    LD A, (ghostPointSprNum)
    OR A
    RET NZ
;   INCREMENT FRAME COUNTER
    LD HL, frameCounter
    INC (HL)
;   CHECK IF FLASH IS ENABLED (IF BIT 5 IS SET)
    LD HL, flashCounter
    BIT 5, (HL)
    RET Z   ; IF NOT, END
;   INCREMENT FLASH COUNTER
    INC (HL)
;   CHECK IF BITS 0-3 ARE SET  
    LD A, $0F
    AND A, (HL)
    CP A, $0F   ; 12.5 FOR PAL
    RET NZ      ; IF NOT, END
;   TOGGLE COLOR (BIT 4)
    LD A, $10
    XOR A, (HL)
;   CLEAR COUNTER (BITS 0-3)
    AND A, $F0
;   STORE
    LD (HL), A
    RET



/*
    INFO: DETERMINES WHEN GHOSTS START FLASHING
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL
*/
ghostFlashUpdate:
;   CHECK IF SUB GAME MODE IS SUPER 
    LD A, (pacPoweredUp)
    OR A
    RET Z   ; IF NOT, EXIT
;   CHECK IF BIT 5 IS SET (IS FLASHING ENABLED)
    LD A, (flashCounter)
    BIT 5, A
    RET NZ  ; IF NOT, SKIP...
;   CHECK IF POWER DOT TIMER IS LESS THAN 128 * 2
    LD HL, (mainTimer1)
    LD DE, GHOST_FLASH_TIME
    SBC HL, DE  ; CARRY CLEARED BY CP
    RET NC  ; IF NOT, SKIP...
;   SET BIT 5 OF FLASH VAR
    LD HL, flashCounter
    SET 5, (HL)
;   CLEAR ALL GHOST INVISIBLE FLAGS
    XOR A
    LD (blinky + INVISIBLE_FLAG), A
    LD (pinky + INVISIBLE_FLAG), A
    LD (inky + INVISIBLE_FLAG), A
    LD (clyde + INVISIBLE_FLAG), A
    RET



/*
    INFO: DRAWS "1UP" OR "2UP" DEPENDING ON CURRENT PLAYER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, HL
*/
draw1UP:
;   PREPARE VDP ADDRESS
    LD HL, NAMETABLE + XUP_TEXT | VRAMWRITE
    RST setVDPAddress
    LD BC, $0A * $100 + VDPDATA_PORT
;   PREP
    LD HL, xUPCounter
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT
    JR Z, @draw  ; IF SO, DRAW xUP
;   INCREMENT, THEN CHECK IF BIT 4 IS SET
    INC (HL)
    BIT 4, (HL)
    JR Z, @draw ; IF NOT, DRAW xUP
;   ELSE, CLEAR xUP
@clear:
    LD HL, $11BF
    SRL B
-:
    OUT (C), L
    OUT (C), H
    DJNZ -
    RET
@draw:
    LD HL, hudTileMaps@oneUP
;   CHECK IF PLAYER 2 IS PLAYING
    LD A, (playerType)
    BIT CURR_PLAYER, A
    JR Z, + ; IF NOT, DISPLAY "1UP"
;   ELSE, DISPLAY "2UP"
    LD A, B
    RST addToHL ; ADD $0A TO HL
+:
    OTIR
    RET


/*
    INFO: DRAWS BOTH "HIGH SCORE" AND "SCORE" TEXT
    INPUT: NONE
    OUTPUT: NONE
    USES: BC, HL
*/
drawScoresText:
;   DRAW "HIGH SCORE"
    ; "HIGH "
    LD HL, NAMETABLE + HIGHSCORE_TEXT_ROW0 | VRAMWRITE
    RST setVDPAddress
    LD HL, hudTileMaps@highScore
    LD BC, HUD_SIZE * $100 + VDPDATA_PORT
    OTIR
    ; " SCORE"
    LD HL, NAMETABLE + HIGHSCORE_TEXT_ROW1 | VRAMWRITE
    RST setVDPAddress
    LD HL, hudTileMaps@highScore + HUD_SIZE
    LD B, HUD_SIZE
    OTIR


/*
    INFO: DRAWS BOTH HIGH SCORE NUMBER AND PLAYER SCORE NUMBER
    INPUT: NONE
    OUTPUT: NONE
    USES: DE, HL
*/
drawScores:
;   PLAYER SCORE
    LD HL, NAMETABLE + NUM_TEXT | VRAMWRITE
    LD DE, currPlayerInfo.score + 2
    CALL drawScore
;   HIGH SCORE
    LD HL, NAMETABLE + HSNUM_TEXT | VRAMWRITE
    LD DE, highScore + 2
;   FALL THROUGH



/*
    INFO: DRAWS SCORE NUMBER
    INPUT: DE - SCORE (BCD) ADDRESS, HL - VRAM ADDRESS TO WRITE TO
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
drawScore:
;   PREPARE
    LD C, VDPDATA_PORT
    PUSH DE
    POP IX
;   CHECK IF SCORE IS 0
    XOR A
    OR A, (IX - 2)
    OR A, (IX - 1)
    OR A, (IX - 0)
    JR NZ, @prepare
    ; IF SO, CHECK IF SCORE BEING PRINTED IS HIGH SCORE
    LD HL, highScore + 2
    SBC HL, DE      ; CARRY CLEARED BY OR
    RET Z   ; IF SO, DON'T PRINT ANYTHING
    ; WRITE 2 ZEROS
    LD HL, NAMETABLE + NUM_TEXT + $08 | VRAMWRITE
    RST setVDPAddress
    LD A, $B5   ; ZERO TILE
    LD L, $11   ; HIGH BYTE OF TILE (UPPER 256, PRIORITY)
    OUT (VDPDATA_PORT), A
    OUT (C), L
    OUT (VDPDATA_PORT), A
    OUT (C), L
    RET
@prepare:
;   SET VDP ADDRESS
    RST setVDPAddress
;   LOAD VARS
    LD B, $06       ; COUNTER
    LD HL, $0011    ; LEADING ZERO FLAG AND HIGH BYTE OF TILE
    EX DE, HL       ; SWAP HL AND DE
-:
;   PREPARE NIBBLE EXTRACTOR
    ; ASSUME TOP NIBBLE (DIGIT 5, 3, 1)
    LD A, $F0
    BIT 0, B    ; CHECK IF ACTUALLY DOING TOP NIBBLE
    JR Z, +     ; IF SO, SKIP
    ; DO LOW NIBBLE (DIGIT 4, 2, 0)
    LD A, $0F
+:
;   GET NIBBLE
    AND A, (HL)
;   CHECK IF DIGIT IS 0
    JR NZ, +    ; IF NOT, SKIP...
    BIT 0, D    ; CHECK IF FLAG IS 0
    JR NZ, ++   ; IF NOT, DRAW DIGIT
    ; WRITE BLANK MASKING TILE
    LD A, $BF
    OUT (VDPDATA_PORT), A
    LD A, $11
    OUT (VDPDATA_PORT), A
    JR @prepLoop
+:
    LD D, $01   ; SET FLAG IF DIGIT ISN'T 0
    BIT 0, B    ; CHECK IF DOING TOP NIBBLE
    JR NZ, ++   ; IF NOT, SKIP
;   SHIFT TOP NIBBLE TO LOW NIBBLE
    RRCA
    RRCA
    RRCA
    RRCA
++:
;   ADD ZERO DIGIT TILE INDEX
    ADD A, $B5
;   WRITE TO VDP
    OUT (VDPDATA_PORT), A
    OUT (C), E
@prepLoop:
;   PREPARE FOR NEXT LOOP
    BIT 0, B    ; CHECK IF DOING TOP NIBBLE
    JR Z, +     ; IF SO, SKIP
    DEC HL      ; POINT TO NEXT PAIR OF DIGITS
+:
    DJNZ -      ; KEEP LOOPING UNTIL ALL DIGITS ARE WRITTEN
    RET


/*
    INFO: DRAWS FRUIT ON THE SIDE OF THE SCREEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IXH
*/
drawFruitHUD:
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT
    RET Z  ; IF SO, EXIT...
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @msFruitHud
;   SET OFFSET INTO FRUIT TABLE ADDRESS
    LD A, (currPlayerInfo.level)
    CP A, 19   ; CHECK IF LEVEL IS 19 OR GREATER
    JR C, @prepareAddress     ; IF NOT, SKIP...
    LD A, 19   ; ELSE, SET OFFSET TO 7
@prepareAddress:
;   SET FRUIT TABLE ADDRESS
    ADD A, A
    LD HL, fruitTable
    RST addToHL
    LD C, L ; BC: FRUIT TABLE ADDRESS
    LD B, H
;   SET COUNTER FOR AMOUNT OF FRUIT TO DRAW
    LD A, (currPlayerInfo.level)
    INC A
    CP A, $08   ; CHECK IF LEVEL IS 8 OR GREATER
    JR C, +     ; IF NOT, SET COUNTER
    LD A, $07   ; ELSE, SET COUNTER TO 7
+:
    LD IXH, A   ; LOOP COUNTER
@loop:
;   GET TILE DEF ADDRESS
    ; GET BYTE AT FRUIT TABLE ADDRESS
    LD A, (BC)  ; BYTE TELLS US WHICH FRUIT TO DISPLAY
    PUSH BC     ; SAVE FOR LATER
    LD HL, fruitTileDefs
    CALL @writeFruit
;   PREPARE FOR NEXT LOOP
    POP BC      ; RESTORE FRUIT TABLE ADDRESS
    DEC BC      ; DECREMENT FRUIT TABLE ADDRESS
    DEC BC
    RET Z       ; EXIT IF COUNTER IS 0
    JR @loop
@msFruitHud:
    LD A, (currPlayerInfo.level)
    CP A, 7   ; CHECK IF LEVEL IS 7 OR GREATER
    JR C, +     ; IF NOT, SKIP...
    LD A, 6   ; ELSE, SET OFFSET TO 6
+:
;   SET COUNTER
    LD IXH, A
    INC IXH
@msloop:
    LD IXL, A   ; SAVE FRUIT NUMBER
;   LOAD FRUIT TILE LIST TABLE
    LD HL, plusBitFlags
    BIT PLUS, (HL)
    LD HL, msFruitTileDefsHUD   ; NON PLUS
    JR Z, +
    LD HL, fruitTileDefs        ; PLUS
+:
;   WRITE FRUIT TO SCREEN
    CALL @writeFruit
    RET Z       ; EXIT IF COUNTER IS 0
;   PREPARE FOR NEXT LOOP
    DEC IXL     ; DECREMENT FRUIT NUMBER
    LD A, IXL
    JR @msloop

;   COMMON FUNCTION USED FOR ROUTINE ABOVE
@writeFruit:
    ; CONVERT TO OFFSET
    ADD A, A
    ADD A, A
    ; ADD TO FRUIT TILE DEFS
    RST addToHL
    EX DE, HL   ; DE: TILE DEF ADDRESS FOR FRUIT
;   FRUIT POSITION TABLE ADDRESS
    ; CONVERT LOOP COUNTER TO OFFSET
    LD A, IXH
    ADD A, A
    ADD A, A
    ; ADD TO POSITION TABLE FOR FRUIT
    LD HL, fruitPositionTable
    RST addToHL     ; HL: POSITION TABLE ADDRESS FOR FRUIT
;   PREP
    LD C, VDPCON_PORT
    LD A, $18   ; UPPER BYTE FOR TILE MAP (SPRITE PALETTE AND PRIORITY)
;   WRITE VRAM ADDRESS FOR TOP FRUIT TILES
    OUTI
    OUTI
;   WRITE TILE FOR TOP FRUIT TILES
    DEC C       ; DATA PORT
    EX DE, HL   ; HL NOW HOLDS TILE DEF ADDRESS
    ; WRITE WORD FOR TOP LEFT TILE
    OUTI
    OUT (C), A
    ; WRITE WORD FOR TOP RIGHT TILE
    INC HL
    OUTI
    OUT (C), A
    ; POINT TO BYTE FOR BOTTOM RIGHT TILE
    DEC HL
    DEC HL
;   WRITE VRAM ADDRESS FOR BOTTOM FRUIT TILES
    INC C       ; CONTROL PORT
    EX DE, HL   ; HL NOW HOLDS TILE POSITION ADDRESS
    OUTI
    OUTI
;   WRITE TILES FOR BOTTOM FRUIT TILES
    DEC C       ; DATA PORT
    EX DE, HL   ; HL NOW HOLDS TILE DEF ADDRESS
    ; WRITE WORD FOR BOTTOM RIGHT TILE
    OUTI
    OUT (C), A
    ; WRITE WORD FOR BOTTOM LEFT TILE
    INC HL
    OUTI
    OUT (C), A
;   DECREMENT COUNTER
    DEC IXH
    RET



/*
    INFO: REMOVES A LIFE FROM THE SCREEN
    ----------------------
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
removeLifeonScreen:
;   CONVERT LIFES INTO OFFSET
    LD A, (currPlayerInfo.lives)
    ADD A, A
    ADD A, A
;   ADD OFFSET TO BASE TABLE
    LD HL, lifePositionTable
    RST addToHL
;   PREPARE VARS
    LD A, $BF           ; TILE ID
    LD C, VDPCON_PORT   ; DATA PORT
;   WRITE VRAM ADDRESS FOR TOP TILES
    OUTI
    OUTI
;   WRITE TILE DATA FOR TOP TILES
    LD BC, $11 * $100 + VDPDATA_PORT    ; TILE ID/PRIORITY + PORT
    OUT (C), A  ; TILE ID
    OUT (C), B  ; FLAGS
    OUT (C), A  ; TILE ID
    OUT (C), B  ; FLAGS
;   WRITE VRAM ADDRESS FOR BOTTOM TILES
    INC C       ; CONTROL PORT  
    OUTI
    OUTI
;   WRITE TILE DATA FOR BOTTOM TILES
    LD BC, $11 * $100 + VDPDATA_PORT    ; TILE ID/PRIORITY + PORT
    OUT (C), A  ; TILE ID
    OUT (C), B  ; FLAGS
    OUT (C), A  ; TILE ID
    OUT (C), B  ; FLAGS
    INC C       ; CONTROL PORT
;   DECREMENT LIVES  
    LD HL, currPlayerInfo.lives
    DEC (HL)
    RET



/*
    INFO: ADDS A LIFE TO THE SCREEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
addLifeOnScreen:
;   CHECK IF AWARDED FLAG IS 1
    LD A, (currPlayerInfo.awarded1UPFlag)
    DEC A
    RET NZ   ; IF NOT, DON'T ADD LIFE
    ; SET FLAG TO 2
    LD A, $02
    LD (currPlayerInfo.awarded1UPFlag), A
;   PLAY SOUND
    LD A, SFX_BONUS
    LD B, $00       ; CHANNEL 0
    CALL sndPlaySFX
;   CONVERT LIFES INTO OFFSET
    LD A, (currPlayerInfo.lives)
    ADD A, A
    ADD A, A
;   ADD OFFSET TO BASE TABLE
    LD HL, lifePositionTable
    RST addToHL
;   PREPARE VARS
@loop:
    LD C, VDPCON_PORT
    LD DE, (lifeHudPtr)
;   WRITE VRAM ADDRESS
    OUTI
    OUTI
;   WRITE TILE DATA FOR TOP TILES
    DEC C       ; DATA PORT
    EX DE, HL
    OUTI
    OUTI
    OUTI
    OUTI
    EX DE, HL
;   WRITE VRAM ADDRESS FOR BOTTOM TILES
    INC C       ; CONTROL PORT
    OUTI
    OUTI
;   WRITE TILE DATA FOR BOTTOM TILES
    DEC C       ; DATA PORT
    EX DE, HL
    OUTI
    OUTI
    OUTI
    OUTI
    EX DE, HL
    ;INC C       ; CONTROL PORT
    RET


/*
    INFO: DRAWS THE AMOUNT OF LIVES THE PLAYER HAS TO THE SCREEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawLives:
;   CHECK IF IN DEMO
    LD A, (mainGameMode)
    CP A, M_STATE_ATTRACT
    RET Z  ; IF SO, EXIT...
;   CONVERT LIFES INTO OFFSET
    LD A, (currPlayerInfo.lives)
    ADD A, A
    ADD A, A
;   ADD OFFSET TO BASE TABLE
    LD HL, lifePositionTable
    RST addToHL
;   PREPARE VARS
    LD A, $FF
-:
    CP A, (HL)
    RET Z       ; IF SO, WE HAVE HIT TERMINATION BYTE. END...
;   DRAW LIFE ON SCREEN
    CALL addLifeOnScreen@loop
;   POINT TO NEXT LIVE
    LD DE, $FFF8    ; -8 
    ADD HL, DE
    JR -



/*
    INFO: DRAWS "READY!"
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawReadyTilemap:
;   SET VDP ADDRESS FOR Y VALUES
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, ($0C * $08) + $06 - $01
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   SET VDP ADDRESS FOR X AND INDEX VALUES
    LD HL, SPRITE_TABLE_XN + ($19 * $02) | VRAMWRITE
    RST setVDPAddress
    LD BC, MAZETXT_INDEX * $100 + VDPDATA_PORT  ; TILE ID AND VDP DATA PORT
    ; TILE 0
    LD A, ($0A * $08) + $02 ; X POSITION
    OUT (C), A
    OUT (C), B
    ; TILE 1
    LD A, ($0B * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
    ; TILE 2
    LD A, ($0C * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
    ; TILE 3
    LD A, ($0D * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
    ; TILE 4
    LD A, ($0E * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
    RET


/*
    INFO: DRAWS "PLAYER ONE" OR "PLAYER TWO"
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawPlayerTilemap:
;   SET VDP ADDRESS FOR Y VALUES
    LD HL, SPRITE_TABLE + $1E | VRAMWRITE
    RST setVDPAddress
    LD A, ($08 * $08) + $02 - $01
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   SET VDP ADDRESS FOR X AND INDEX VALUES
    LD HL, SPRITE_TABLE_XN + ($1E * $02) | VRAMWRITE
    RST setVDPAddress
    LD BC, (MAZETXT_INDEX + $05) * $100 + VDPDATA_PORT  ; TILE ID AND VDP DATA PORT
    ; PLAYER
        ; TILE 0
    LD A, ($08 * $08) + $06 ; X POSITION
    OUT (C), A
    OUT (C), B
        ; TILE 1
    LD A, ($09 * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 2
    LD A, ($0A * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 3
    LD A, ($0B * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 4
    LD A, ($0C * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
    ; ONE / TWO
        ; SETUP TILE ID DEPENDING ON WHICH PLAYER IS PLAYING
    INC B
    LD A, (playerType)
    BIT CURR_PLAYER, A
    JR Z, + ; IF PLAYER 1, ONLY INCREMENT BY 1 (POINT TO 'ONE')
    ; ELSE, ADD ADDITIONAL 3 (POINT TO 'TWO')
    INC B
    INC B
    INC B
+:
        ; TILE 5
    LD A, ($0D * $08) + $06 ; X POSITION
    OUT (C), A
    OUT (C), B
        ; TILE 6
    LD A, ($0E * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 7
    LD A, ($0F * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
    RET


/*
    INFO: DRAWS "GAME  OVER"
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawGameOverTilemap:
;   SET VDP ADDRESS FOR Y VALUES
    LD HL, SPRITE_TABLE + $26 | VRAMWRITE
    RST setVDPAddress
    LD A, ($0C * $08) + $06 - $01
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   SET VDP ADDRESS FOR X AND INDEX VALUES
    LD HL, SPRITE_TABLE_XN + ($26 * $02) | VRAMWRITE
    RST setVDPAddress
    LD BC, (MAZETXT_INDEX + $10) * $100 + VDPDATA_PORT  ; TILE ID AND VDP DATA PORT
    ; GAME
        ; TILE 0
    LD A, ($08 * $08) + $06 ; X POSITION
    OUT (C), A
    OUT (C), B
        ; TILE 1
    LD A, ($09 * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 2
    LD A, ($0A * $08) + $06
    INC B
    OUT (C), A
    OUT (C), B
    ; OVER
        ; TILE 3
    LD A, ($0D * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 4
    LD A, ($0E * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 5
    LD A, ($0F * $08) + $02
    INC B
    OUT (C), A
    OUT (C), B
    RET