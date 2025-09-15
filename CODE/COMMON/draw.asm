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
;   UPDATE NEW COLUMN FOR SCROLLING (FLAG MUST BE SET && GAME MUST BE JR)
    LD HL, updateColFlag
    LD A, (enableScroll)
    AND A, (HL)
    CALL NZ, drawNewColumn
;   TURN MAZE INVISIBLE (FLAG MUST BE SET && PAC-MAN MUST BE POWERED UP)
    LD HL, pacPoweredUp
    LD A, (plusBitFlags)    ; INVISIBLE_MAZE
    RLCA    ; BIT 7 -> BIT 0
    AND A, (HL)
    JP Z, +
    ; SET VDP ADDRESS
    LD A, $01
    OUT (VDPCON_PORT), A
    LD A, hibyte(CRAMWRITE)
    OUT (VDPCON_PORT), A
    ; BLANK OUT PALETTE ENTRIES
    XOR A
    OUT (VDPDATA_PORT), A  ; WALLS
    OUT (VDPDATA_PORT), A  ; INSIDE
    OUT (VDPDATA_PORT), A  ; SHADE 0
    OUT (VDPDATA_PORT), A  ; SHADE 1
    OUT (VDPDATA_PORT), A  ; SHADE 2
    OUT (VDPDATA_PORT), A  ; GATE
    OUT (VDPDATA_PORT), A  ; DOT 0
+:
;   ADD LIFE (WHEN 1UP FLAG IS SET)
    LD A, (currPlayerInfo.awarded1UPFlag)
    DEC A
    CALL Z, addLifeOnScreen
;   DRAW SCORE AND HIGH SCORE
    CALL scoreTileMapDraw
;   DRAW 1UP (NOT IN ATTRACT MODE)
    CALL draw1UP
;   DRAW MAZE (WHEN FLAG IS SET)
    LD HL, tileBufferFlag
    BIT 0, (HL)
    CALL NZ, drawMaze
;   DRAW MAZE (JR, FRUIT)
    LD HL, fruitTileBufFlag
    BIT 0, (HL)
    CALL NZ, drawMazeFruitJr
;   DRAW ACTORS
    ; PAC-MAN
    CALL pacTileStreaming   ; STREAM PLAYER TILES
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
    LD A, (ghostPointSprNum)
    OR A
    CALL NZ, drawGhostPoints
;   POWER PELLET PALETTE CYCLING (DONE LAST TO HIDE CRAM DOTS)
    JP drawPowDots



/*
    INFO: UPDATES POWER DOT PALETTE FROM RAM
    INPUT: NONE
    OUTPUT: NONE
    USES: A, BC, HL
*/
drawPowDots:
;   PREPARE VDP
    LD A, BGPAL_PDOT0
    OUT (VDPCON_PORT), A
    LD A, hibyte(CRAMWRITE)
    OUT (VDPCON_PORT), A
    LD C, VDPDATA_PORT
;   SEND PALETTE TO VDP CRAM
    LD HL, powDotPalette
    OUTI
    OUTI
    OUTI
    OUTI
    RET



/*
    INFO: UPDATES MAZE IF TILE BUFFER ISN'T EMPTY
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawMaze:
;   LOOP PREP
    LD (HL), $00    ; CLEAR FLAG
    INC HL          ; tileBufferCount
    LD B, (HL)      ; LOAD COUNTER INTO B
    LD (HL), $00    ; CLEAR COUNTER
    LD DE, tileBuffer
    LD C, VDPCON_PORT
-:
    ; SET VRAM ADDRESS
    LD HL, (tileBufferAddress)
    LD A, (DE)      ; GET OFFSET
    ;RST addToHL     ; ADD TO VRAM ADDRESS
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    SET $06, H      ; VRAM WRITE OP
    OUT (C), L
    OUT (C), H
    DEC C
    INC DE          ; POINT TO TILE DATA
    ; WRITE DATA
    EX DE, HL       ; HL: TILE BUFFER ADDRESS (TILE DATA)
    OUTI            ; LOW BYTE
    OUTI            ; HIGH BYTE
    EX DE, HL       ; HL: VRAM ADDRESS
    INC B           ; COUNTERACT OUTI's DECREMENT
    INC B
    INC C
    ; CHECK COUNTER
    DJNZ -
    RET

drawMazeFruitJr:    
;   LOOP PREP FOR FRUIT TILE BUFFER
    LD (HL), $00    ; CLEAR FLAG
    INC HL          ; tileBufferCount
    LD B, (HL)      ; LOAD COUNTER INTO B
    LD (HL), $00    ; CLEAR COUNTER
    LD DE, fruitTileBuf
    LD C, VDPCON_PORT
-:
    ; SET VRAM ADDRESS
    LD HL, (fruitTileBufAddr)
    LD A, (DE)      ; GET OFFSET
    ;RST addToHL     ; ADD TO VRAM ADDRESS
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    SET $06, H      ; VRAM WRITE OP
    OUT (C), L
    OUT (C), H
    DEC C
    INC DE          ; POINT TO TILE DATA
    ; WRITE DATA
    EX DE, HL       ; HL: TILE BUFFER ADDRESS (TILE DATA)
    OUTI            ; LOW BYTE
    OUTI            ; HIGH BYTE
    EX DE, HL       ; HL: VRAM ADDRESS
    INC B           ; COUNTERACT OUTI's DECREMENT
    INC B
    INC C
    ; CHECK COUNTER
    DJNZ -
    RET



/*
    INFO: DRAWS FRUIT SOMEWHERE IN MAZE
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, DE, HL, IX
*/
drawInMazeFruit:
    LD IX, fruit
;   DON'T DISPLAY IF OFFSCREEN FLAG IS SET
    LD A, (fruit + OFFSCREEN_FLAG)
    OR A
    JP NZ, ghostSpriteFlicker@emptySprite
;   CONVERT FRUIT POSITION
    CALL convPosToScreen
;   DISPLAY EXPLOSION IF FRUIT IS EXPLODING (JR)
    LD A, (fruit + STATE)
    CP A, $06
    JP Z, @explosionJR
;   ASSUME FRUIT (NOT POINTS) WILL BE DISPLAYED
    LD HL, (fruitTileDefPtr)
;   CHECK IF THAT IS ACTUALLY TRUE
    LD A, (currPlayerInfo.fruitStatus)
    AND A, $01 << $01   ; 2 = POINTS
    JP Z, @execDraw
;   ELSE, DISPLAY FRUIT POINTS
    LD HL, (fruitPointTDefPtr)
@execDraw:
    LD A, (fruit.sprTableNum)
    JP display4TileSprite
@explosionJR:
    LD A, (fruitPathLen)
    AND A, $F0
    RRCA
    RRCA
    LD HL, fruitState6@explosionSprDefs
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    JP @execDraw
    


/*
    INFO: DRAWS GHOST POINTS
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, IX
*/
drawGhostPoints:
;   CONVERT INDEX INTO OFFSET
    LD A, (ghostPointIndex)
    ADD A, A
;   ADD OFFSET TO BASE TILE DEF. TABLE
    LD HL, ghostPointTileDefs
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
;   DRAW POINTS
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
    AND A, $01 << $05
    RET NZ  ; IF SO, EXIT
;   CHECK IF POWER DOT TIMER IS LESS THAN 128 * 2
    LD HL, (mainTimer1)
    LD DE, GHOST_FLASH_TIME
    SBC HL, DE  ; CARRY CLEARED
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



draw1UPDemo:
    LD C, VDPCON_PORT
;   PREPARE VDP ADDRESS
    LD HL, NAMETABLE + XUP_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, NAMETABLE + XUP_TEXT_JR | VRAMWRITE
+:
    OUT (C), L
    OUT (C), H
    DEC C
;   DRAW "1UP"
    LD HL, hudTileMaps@oneUP
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, hudTileMaps@jroneUP
+:
    LD A, $01
    OUTI
    OUT (VDPDATA_PORT), A
    OUTI
    OUT (VDPDATA_PORT), A
    OUTI
    OUT (VDPDATA_PORT), A
    RET

/*
    INFO: DRAWS "1UP" OR "2UP" DEPENDING ON CURRENT PLAYER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, HL
*/
draw1UP:
;   EXIT IF IN ATTRACT MODE
    LD A, (mainGameMode)
    OR A
    RET Z
;   PREPARE VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, NAMETABLE + XUP_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, NAMETABLE + XUP_TEXT_JR | VRAMWRITE
+:
    OUT (C), L
    OUT (C), H
    DEC C
;   INCREMENT, THEN CHECK IF BIT 4 IS SET
    LD HL, xUPCounter
    INC (HL)
    BIT 4, (HL)
    JP Z, @draw ; IF NOT, DRAW xUP
;   ELSE, CLEAR xUP
@clear:
    LD A, MASK_TILE
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    IN F, (C)
    RET
@draw:
    LD HL, hudTileMaps@oneUP
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, hudTileMaps@jroneUP
+:
;   CHECK IF PLAYER 2 IS PLAYING
    LD A, (playerType)
    AND A, $01 << CURR_PLAYER
    JP Z, + ; IF NOT, DISPLAY "1UP"
;   ELSE, DISPLAY "2UP"
    INC HL
    INC HL
    INC HL
+:
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    RET



/*
    INFO: DRAWS PLAYER SCORE (AND HIGH SCORE) FROM BUFFER
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
scoreTileMapDraw:
;   SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, NAMETABLE + NUM_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, NAMETABLE + NUM_TEXT_JR | VRAMWRITE
+:
    OUT (C), L
    OUT (C), H
    DEC C
;   6 TILE WRITE
    LD HL, scoreTileMapBuffer
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
;   DRAW HIGH SCORE TILEMAP IF BOTH MATCH
    ; COMPARE UPPER BYTES
    LD A, (currPlayerInfo.score + 2)
    LD B, A
    LD A, (highScore + 2)
    SUB A, B    
    RET NZ
    ; COMPARE LOWER WORDS
    LD HL, (highScore)
    LD DE, (currPlayerInfo.score)
    OR A
    SBC HL, DE
    RET NZ
;   SET VDP ADDRESS
    LD HL, NAMETABLE + HSNUM_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD HL, NAMETABLE + HSNUM_TEXT_JR | VRAMWRITE
+:
    INC C
    OUT (C), L
    OUT (C), H
    DEC C
;   6 TILE WRITE
    LD HL, scoreTileMapBuffer
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    RET



/*
    INFO: DRAWS BOTH "HIGH SCORE" AND "SCORE" TEXT ON LEVEL INIT.
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, HL
*/
drawScoresText:
;   SKIP IF GAME IS JR PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, @jrHi
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
    JP scoreTileMapInit
@jrHi:
    ; "HI "
    LD HL, NAMETABLE + HIGHSCORE_TEXT_JR | VRAMWRITE
    RST setVDPAddress
    LD HL, hudTileMaps@highScore
    LD BC, $04 * $100 + VDPDATA_PORT
    OTIR
;   FALL THROUGH



/*
    INFO: DRAWS BOTH HIGH SCORE AND PLAYER SCORE ON LEVEL INIT.
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, B, DE, HL
*/
;   SCORE TILEMAP INIT. ROUTINE
scoreTileMapInit:
;   DRAW SCORE
    LD HL, @drawHsDigits    ; RETURN ADDRESS
    PUSH HL
    LD B, $00
    LD DE, currPlayerInfo.score + 2
    LD HL, NAMETABLE + NUM_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, drawScoreOld
    LD HL, NAMETABLE + NUM_TEXT_JR | VRAMWRITE
    JP drawScoreOld
@drawHsDigits:
;   DRAW HIGH SCORE
    LD B, $01
    LD DE, highScore + 2
    LD HL, NAMETABLE + HSNUM_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, drawScoreOld
    LD HL, NAMETABLE + HSNUM_TEXT_JR | VRAMWRITE
;   FALL THROUGH


/*
    INFO: DRAWS SCORE NUMBER
    INPUT: DE - SCORE (BCD) ADDRESS, HL - VRAM ADDRESS TO WRITE TO
    OUTPUT: NONE
    USES: AF, BC, DE, HL, IX
*/
drawScoreOld:
;   PREPARE
    LD C, VDPDATA_PORT
    PUSH DE
    POP IX
;   CHECK IF SCORE IS 0
    XOR A
    OR A, (IX - 2)
    OR A, (IX - 1)
    OR A, (IX - 0)
    JP NZ, @prepare
    ; IF SO, CHECK IF SCORE BEING PRINTED IS HIGH SCORE
    DEC B
    RET Z   ; IF SO, DON'T PRINT ANYTHING
    ; WRITE 2 ZEROS
    LD A, $08
    RST addToHL
    RST setVDPAddress
    LD A, HUDZERO_INDEX   ; ZERO TILE
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
    JP Z, +     ; IF SO, SKIP
    ; DO LOW NIBBLE (DIGIT 4, 2, 0)
    LD A, $0F
+:
;   GET NIBBLE
    AND A, (HL)
;   CHECK IF DIGIT IS 0
    JP NZ, +    ; IF NOT, SKIP...
    BIT 0, D    ; CHECK IF FLAG IS 0
    JP NZ, ++   ; IF NOT, DRAW DIGIT
    ; WRITE BLANK MASKING TILE
    LD A, MASK_TILE
    OUT (VDPDATA_PORT), A
    LD A, $11
    OUT (VDPDATA_PORT), A
    JP @prepLoop
+:
    LD D, $01   ; SET FLAG IF DIGIT ISN'T 0
    BIT 0, B    ; CHECK IF DOING TOP NIBBLE
    JP NZ, ++   ; IF NOT, SKIP
;   SHIFT TOP NIBBLE TO LOW NIBBLE
    RRCA
    RRCA
    RRCA
    RRCA
++:
;   ADD ZERO DIGIT TILE INDEX
    ADD A, HUDZERO_INDEX
;   WRITE TO VDP
    OUT (VDPDATA_PORT), A
    OUT (C), E
@prepLoop:
;   PREPARE FOR NEXT LOOP
    BIT 0, B    ; CHECK IF DOING TOP NIBBLE
    JP Z, +     ; IF SO, SKIP
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
;   CHECK IF GAME IS MS.PAC
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR NZ, @msFruitHud
;   CHECK IF GAME IS JR.PAC
    BIT JR_PAC, A
    JR NZ, @jrFruitHud
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
@jrFruitHud:
    LD A, (currPlayerInfo.level)
    CP A, 7   ; CHECK IF LEVEL IS 7 OR GREATER
    JR C, +     ; IF NOT, SKIP...
    LD A, 6   ; ELSE, SET OFFSET TO 6
+:
    ADD A, $D5  ; INITIAL FRUIT SPRITE
;   SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, $003C | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
;   WRITE TILE
    OUT (VDPDATA_PORT), A
    LD A, $09
    OUT (VDPDATA_PORT), A
    RET

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
    LD HL, currPlayerInfo.lives
    LD A, (HL)
    ADD A, A
    ADD A, A
    LD B, A
    DEC (HL)    ; ALSO DECREMENT LIVES
;   REMOVE DIFFERENT AREA IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, @removeJrLife
;   ADD OFFSET TO BASE TABLE
    LD A, B
    LD HL, lifePositionTable
    RST addToHL
;   PREPARE VARS
    LD A, MASK_TILE     ; TILE ID
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
    RET
@removeJrLife:
;   SET VDP ADDRESS
    LD HL, $002E | VRAMWRITE
    LD A, (currPlayerInfo.lives)
    INC A
    LD B, A
    LD A, $05
    SUB A, B
    ADD A, A
    RST addToHL
    RST setVDPAddress
;   BLANK TILE
    XOR A
    OUT (VDPDATA_PORT), A
    RET



/*
    INFO: ADDS A LIFE TO THE SCREEN
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
addLifeOnScreen:
    ; SET FLAG TO 2
    LD A, $02
    LD (currPlayerInfo.awarded1UPFlag), A
;
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @addLifeJR
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
    LD DE, hudLifeTileDefs
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
@addLifeJR:
;   SET VDP ADDRESS
    LD HL, $002E | VRAMWRITE
    LD A, (currPlayerInfo.lives)
    LD B, A
    LD A, $05
    SUB A, B
    ADD A, A
    RST addToHL
    RST setVDPAddress
;   DRAW LIFE
    LD A, $DC
    OUT (VDPDATA_PORT), A
    LD A, $09
    OUT (VDPDATA_PORT), A
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
;
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR NZ, @jrLives
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
    JP -
@jrLives:
;   EXIT IF ON LAST LIFE (NOTHING SHOWN)
    LD A, (currPlayerInfo.lives)
    OR A
    RET Z
;   SET VDP ADDRESS
    LD HL, $002E | VRAMWRITE
    LD A, (currPlayerInfo.lives)
    LD B, A
    LD A, $05
    SUB A, B
    ADD A, A
    RST addToHL
    RST setVDPAddress
;   DRAW LIVES
    LD A, (currPlayerInfo.lives)
    LD B, A
-:
    LD A, $DC
    OUT (VDPDATA_PORT), A
    LD A, $09
    OUT (VDPDATA_PORT), A
    DJNZ -
    RET








/*
    INFO: DRAWS "READY!"
    INPUT: NONE
    OUTPUT: NONE
    USES: AF, BC, DE, HL
*/
drawReadyTilemap:
    LD DE, (($0C * $08) + $06 - $01) * $100 + (($0A * $08) + $02)   ; YX
;   SET POSITION DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD DE, (($0D * $08) + $01) * $100 + (($0E * $08) + $02)   ; YX
+:
;   SET VDP ADDRESS FOR Y VALUES
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, D
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   SET VDP ADDRESS FOR X AND INDEX VALUES
    LD HL, SPRITE_TABLE_XN + ($19 * $02) | VRAMWRITE
    RST setVDPAddress
    LD BC, (MAZETXT_INDEX + $0B) * $100 + VDPDATA_PORT  ; TILE ID AND VDP DATA PORT
    ; TILE 0
    LD A, E     ; X POSITION
    OUT (C), A
    OUT (C), B
    ; TILE 1
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
    ; TILE 2
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
    ; TILE 3
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
    ; TILE 4
    ADD A, $08
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
    LD DE, (($08 * $08) + $02 - $01) * $100 + (($08 * $08) + $06)   ; YX
;   SET POSITION DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD DE, (($09 * $08) - $03) * $100 + (($0C * $08) + $06)   ; YX
+:
;   SET VDP ADDRESS FOR Y VALUES
    LD HL, SPRITE_TABLE + $01 | VRAMWRITE
    RST setVDPAddress
    LD A, D
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   SET VDP ADDRESS FOR X AND INDEX VALUES
    LD HL, SPRITE_TABLE_XN + ($01 * $02) | VRAMWRITE
    RST setVDPAddress
    LD BC, $59 * $100 + VDPDATA_PORT  ; TILE ID AND VDP DATA PORT
    ; PLAYER
        ; TILE 0
    LD A, E     ; X POSITION
    OUT (C), A
    OUT (C), B
        ; TILE 1
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 2
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 3
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 4
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
    ; ONE / TWO
        ; SETUP TILE ID DEPENDING ON WHICH PLAYER IS PLAYING
    INC B
    LD A, (playerType)
    AND A, $01 << CURR_PLAYER
    JP Z, + ; IF PLAYER 1, ONLY INCREMENT BY 1 (POINT TO 'ONE')
    ; ELSE, ADD ADDITIONAL 3 (POINT TO 'TWO')
    INC B
    INC B
    INC B
+:
        ; TILE 5
    LD A, E
    ADD A, $08 * $05
    OUT (C), A
    OUT (C), B
        ; TILE 6
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 7
    ADD A, $08
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
    LD DE, (($0C * $08) + $06 - $01) * $100 + (($08 * $08) + $06)   ; YX
;   SET POSITION DEPENDING ON GAME
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP Z, +
    LD DE, (($0D * $08) + $01) * $100 + (($0C * $08) + $06)   ; YX
+:
;   SET VDP ADDRESS FOR Y VALUES
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, D
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   SET VDP ADDRESS FOR X AND INDEX VALUES
    LD HL, SPRITE_TABLE_XN + ($19 * $02) | VRAMWRITE
    RST setVDPAddress
    LD BC, (MAZETXT_INDEX + $10) * $100 + VDPDATA_PORT  ; TILE ID AND VDP DATA PORT
    ; GAME
        ; TILE 0
    LD A, E ; X POSITION
    OUT (C), A
    OUT (C), B
        ; TILE 1
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 2
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
    ; OVER
        ; TILE 3
    ADD A, $14
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 4
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
        ; TILE 5
    ADD A, $08
    INC B
    OUT (C), A
    OUT (C), B
    RET



/*
    JR PAC
*/

drawNewColumn:
;   RESET FLAG
    XOR A
    LD (updateColFlag), A
;   SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, (NAMETABLE + $40) | VRAMWRITE
    LD A, (jrColumnToUpdate)
    ADD A, A
        ; ADD COLUMN TO ADDRESS
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    OUT (C), L
    OUT (C), H
    DEC C
;   SET STARTING TILEMAP ADDRESS
    EX DE, HL		; HL: N/A, DE: VDP ADDR
    LD A, (jrOldScrollReal)
    LD B, A
    LD A, (jrScrollReal)
    SUB A, B
    OR A
    ;LD BC, ($17 * $03) * $100 + VDPDATA_PORT    ; SETUP LOOP FOR LATER
    LD B, 46
    LD A, (jrLeftMostTile) 
    JP P, +
    ADD A, $1F  ; POINT TO COLUMN ON OTHER SIDE OF VISIBLE SCREEN
+:
    ADD A, A
    LD HL, mazeGroup1.tileMap
    ;RST addToHL
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
;   --------------
;   DRAW COLUMN FROM TILEMAP
;   --------------
-:
.REPEAT 11  ; LOOPS TWICE
    ; WRITE TILEMAP DATA
    OUTI
    OUTI
    ; UPDATE VDP ADDRESS FOR NEXT ROW
    EX DE, HL		; HL: VDP ADDR, DE: TILEMAP ADDR
    LD A, $40
        ; ADD $40 TO ADDRESS
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
        ; WRITE TO VDP
    LD A, L     
    OUT (VDPCON_PORT), A    
    LD A, H
    OUT (VDPCON_PORT), A
    ;RST addToHL
    ;RST setVDPAddress
    ; UPDATE TILEMAP ADDRESS FOR NEXT ROW
    EX DE, HL		; HL: TILEMAP ADDR, DE: VDP ADDR
    LD A, $50
        ; ADD $50 TO ADDRESS
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    ;RST addToHL
.ENDR
    DEC B
    JP NZ, -
    ;DJNZ -
    ; WRITE TILEMAP DATA
    OUTI
    OUTI
    RET