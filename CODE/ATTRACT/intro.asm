/*
-------------------------------------------------------
                INTRO MODE FOR PAC-MAN
-------------------------------------------------------
*/
sStateAttractTable@introMode:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   GENERAL INTRO MODE SETUP
    CALL generalIntroSetup00
;   LOAD TILES
    LD DE, BACKGROUND_ADDR | VRAMWRITE
    LD HL, introTileData
    CALL zx7_decompressVRAM
;   LOAD BG PALETTE TO RAM
    CALL cpyMazePalToRam
;   LOAD BACKGROUND (MAZE) PALETTE (JUST FOR POWER DOT)
    CALL waitForVblank  ; WAIT DUE TO CRAM UPDATE
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD BC, BG_CRAM_SIZE * $100 + VDPDATA_PORT
    LD HL, mazePalette
    OTIR
;   DISABLE SPRITES AT INDEX $25
    LD HL, SPRITE_TABLE + $25 | VRAMWRITE
    RST setVDPAddress
    LD A, $D0
    OUT (VDPDATA_PORT), A
;   DISPLAY "CHARACTER / NICKNAME"
    LD HL, NAMETABLE + ($07 * 2) + ($01 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introNicknameText
    LD B, $10
    CALL msIntroDisplayText
;   GENERAL INTRO MODE SETUP 2
    CALL generalIntroSetup01
@@draw:
;   POWER PELLET PALETTE CYCLING
    CALL drawPowDots
@@update:
;   GET JUST PRESSED INPUTS
    CALL getPressedInputs
;   CHECK IF BUTTON 1 WAS PRESSED
    LD A, (pressedButtons)
    BIT P1_BTN_1, A
    JR NZ, @@exit ; IF SO, EXIT BACK TO TITLE
;   CHECK IF STATE IS 15 OR GREATER
    LD A, (introSubState)
    CP A, $0F
    JR NC, +    ; IF SO, SKIP...
;   TIMER CHECK
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; END IF NOT 0
    JR @@@stateJump
+:
;   DRAW FUNCTION FOR STATES 15 AND ABOVE
    ; UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
    ; DISPLAY PAC-MAN
    CALL displayPacMan
    ; DISPLAY GHOSTS
    LD IX, blinky
    CALL ghostStateTable@draw@gotoExit
    LD IX, pinky
    CALL ghostStateTable@draw@gotoExit
    LD IX, inky
    CALL ghostStateTable@draw@gotoExit
    LD IX, clyde
    CALL ghostStateTable@draw@gotoExit
    ; CHECK IF WE NEED TO DRAW GHOST POINTS
    LD A, (ghostPointSprNum)
    OR A
    JR Z, @@@stateJump  ; IF NOT, SKIP
    ; DRAW POINTS (CONERT TO OFFSET)
    LD A, (ghostPointIndex)
    ADD A, A
    ; ADD OFFSET TO BASE TILE DEF. TABLE
    LD HL, ghostPointTileDefs
    RST addToHL
    ; DRAW GHOST POINTS
    LD IX, ghostPointXpos - 1
    CALL convPosToScreen
    LD A, $01       ; DRAW OVER PAC-MAN
    CALL display2HTileSprite
;   UPDATE FUNCTION TABLE
@@@stateJump:
;   CONVERT STATE INTO OFFSET
    LD A, (introSubState)
;   INCREMENT STATE (WON'T TAKE EFFECT TILL NEXT TIME)
    LD HL, introSubState
    INC (HL)
;   ADD OFFSET TO TABLE
    LD HL, introSubTable
    RST jumpTableExec
    RET


@@exit:
;   REMOVE FSM CALLER
    POP HL
;   DISABLE INTS (REALLY JUST VDP FRAME INTS)
    DI
;   RESET TO TITLE
    JP resetFromDemo


/*
-----------------------------------------
    ROUTINE TABLE FOR INTRODUCTION
-----------------------------------------
*/
introSubTable:
    .DW showBlinky
    .DW showShadowText
    .DW showBlinkyText
    .DW showPinky
    .DW showSpeedyText
    .DW showPinkyText
    .DW showInky
    .DW showBashfulText
    .DW showInkyText
    .DW showClyde
    .DW showPokeyText
    .DW showClydeText
    .DW showPointVals
    .DW showNamco
    .DW introActorSetup
    .DW runFromGhosts
    .DW ghostHeadStart
    .DW eatGhosts


/*
-----------------------------------------
                ROUTINES
-----------------------------------------
*/


;   SUB STATE 00
showBlinky:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY BLINKY
    LD HL, ghostNormalTileDefs@blinky + ($06 * $04)    ; RIGHT 0
    LD A, 17 + 4
    LD DE, (24 + 16) * $100 + 21
    JP display4TileSprite


;   SUB STATE 01
showShadowText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    LD HL, NAMETABLE + ($07 * 2) + ($03 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introShadowText
    LD B, 6
    JP msIntroDisplayText


;   SUB STATE 02
showBlinkyText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    LD HL, NAMETABLE + ($0F * 2) + ($03 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introBlinkyText
    LD B, 7
    JP msIntroDisplayText


;   SUB STATE 03
showPinky:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY PINKY
    LD HL, ghostNormalTileDefs@pinky + ($06 * $04)    ; RIGHT 0
    LD A, 17 + 8                        ; SPRITE NUMBER
    LD DE, (24 + 16) * $100 + 21 + 18   ; XY POSITION
    JP display4TileSprite


;   SUB STATE 04
showSpeedyText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    LD HL, NAMETABLE + ($07 * 2) + ($05 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introSpeedyText
    LD B, 6
    JP msIntroDisplayText


;   SUB STATE 05
showPinkyText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    LD HL, NAMETABLE + ($0F * 2) + ($05 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introPinkyText
    LD B, 6
    JP msIntroDisplayText


;   SUB STATE 06
showInky:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY INKY
    LD HL, ghostNormalTileDefs@inky + ($06 * $04)    ; RIGHT 0
    LD A, 17 + 12                       ; SPRITE NUMBER
    LD DE, (24 + 16) * $100 + 21 + 36   ; X/Y POSITION
    JP display4TileSprite


;   SUB STATE 07
showBashfulText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    LD HL, NAMETABLE + ($07 * 2) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introBashfulText
    LD B, 7
    JP msIntroDisplayText
   

;   SUB STATE 08
showInkyText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    LD HL, NAMETABLE + ($0F * 2) + ($07 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introInkyText
    LD B, 5
    JP msIntroDisplayText


;   SUB STATE 09
showClyde:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY CLYDE
    LD HL, ghostNormalTileDefs@clyde + ($06 * $04)    ; RIGHT 0
    LD A, 17 + 16
    LD DE, (24 + 16) * $100 + 21 + 54
    JP display4TileSprite


;   SUB STATE 0A
showPokeyText:
;   SET TIMER FOR .5 SECOND
    LD A, ATT01_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    ; ROW 0
    LD HL, NAMETABLE + ($07 * 2) + ($09 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introPokeyText@row0
    LD B, 5
    CALL msIntroDisplayText
    ; ROW 1
    EX DE, HL
    LD HL, NAMETABLE + ($07 * 2) + ($0A * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 1
    LD B, 5
    JP msIntroDisplayText


;   SUB STATE 0B
showClydeText:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    ; ROW 0
    LD HL, NAMETABLE + ($0F * 2) + ($09 * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introClydeText@row0
    LD B, 6
    CALL msIntroDisplayText
    ; ROW 1
    EX DE, HL
    LD HL, NAMETABLE + ($0F * 2) + ($0A * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 1
    LD B, 6
    JP msIntroDisplayText


;   SUB STATE 0C
showPointVals:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    ; ROW 0
    LD HL, NAMETABLE + ($09 * 2) + ($0F * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introPointsText@row0
    LD B, 7 * 2
    OTIR
    ; ROW 1
    EX DE, HL
    LD HL, NAMETABLE + ($09 * 2) + ($10 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 1
    LD B, 7 * 2
    OTIR
    ; ROW 2
    EX DE, HL
    LD HL, NAMETABLE + ($09 * 2) + ($11 * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 2
    LD B, 7 * 2
    OTIR
    RET


;   SUB STATE 0D
showNamco:
;   SET TIMER FOR 1 SECOND
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
;   DISPLAY TEXT
    ; ASSUME "NAMCO" WILL BE DISPLAYED
    LD HL, NAMETABLE + ($09 * 2) + ($15 * $40) | VRAMWRITE
    LD DE, introNamcoText
    LD B, $07
    ; CHECK IF GAME IS PLUS
    LD A, (plusBitFlags)
    BIT PLUS, A
    JR Z, +     ; IF NOT, SKIP
    ; ELSE, DISPLAY "@ BALLY MIDWAY 1980,1982"
    LD HL, NAMETABLE + ($03 * 2) + ($15 * $40) | VRAMWRITE
    LD DE, introBallyMidway
    LD B, $13
+:
    RST setVDPAddress
    EX DE, HL
    CALL msIntroDisplayText
    ; POW DOT 0
    LD HL, NAMETABLE + ($05 * 2) + ($0C * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, introPowDot@row0
    INC B       ; $01
    CALL introDisplayText
    ; POW DOT 1
    EX DE, HL
    LD HL, NAMETABLE + ($05 * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    EX DE, HL   ; ROW 1
    INC B       ; $01
    JP introDisplayText


;   SUB STATE 0E
introActorSetup:
;   RESET GHOST POINT STUFF
    LD A, $FF
    LD (ghostPointIndex), A
    XOR A
    LD (ghostPointSprNum), A
;   CLEAR SUB POSITIONS
    LD (pacman.subPixel), A
    LD (blinky.subPixel), A
    LD (pinky.subPixel), A
    LD (inky.subPixel), A
    LD (clyde.subPixel), A
;   CLEAR GHOST FLAGS
    LD (blinky + EDIBLE_FLAG), A
    LD (blinky + INVISIBLE_FLAG), A
    LD (pinky + EDIBLE_FLAG), A
    LD (pinky + INVISIBLE_FLAG), A
    LD (inky + EDIBLE_FLAG), A
    LD (inky + INVISIBLE_FLAG), A
    LD (clyde + EDIBLE_FLAG), A
    LD (clyde + INVISIBLE_FLAG), A
;   BLINKY ID
    LD (blinky.id), A
;   PAC-MAN SPRITE TABLE START
    INC A   ; $01
    LD (pacman.sprTableNum), A
;   DIRECTIONS (FACING LEFT)
    LD (pacman.currDir), A
    LD (pacman.nextDir), A
    LD (blinky.currDir), A
    LD (blinky.nextDir), A
    LD (pinky.currDir), A
    LD (pinky.nextDir), A
    LD (inky.currDir), A
    LD (inky.nextDir), A
    LD (clyde.currDir), A
    LD (clyde.nextDir), A
;   PINKY ID
    LD (pinky.id), A
;   INKY ID
    INC A   ; $02
    LD (inky.id), A
;   CLYDE ID
    INC A   ; $03
    LD (clyde.id), A
;   BLINKY SPR TABLE
    LD A, 05
    LD (blinky.sprTableNum), A
;   PINKY SPR TABLE
    LD A, 09
    LD (pinky.sprTableNum), A
;   INKY SPR TABLE
    LD A, 13
    LD (inky.sprTableNum), A
;   CLYDE SPR TABLE
    LD A, 17
    LD (clyde.sprTableNum), A
;   PAC-MAN POSITION
    LD HL, $9408    ; YX
    LD (pacman.xPos), HL
;   GHOST POSITIONS
    LD HL, $9400    ; YX
    LD (blinky.xPos), HL
    LD (pinky.xPos), HL
    LD (inky.xPos), HL
    LD (clyde.xPos), HL
;   GHOST POINTS
    LD (ghostPointXpos), HL
;   CLEAR FRUIT POS
    LD HL, $0000
    LD (fruitPos), HL
    RET


;   SUB STATE 0F
runFromGhosts:
;   UPDATE GHOST VISUAL COUNTERS
    CALL ghostVisCounterUpdate
;   STATE 15 CHECK (HAS PAC-MAN REACHED POWER DOT?)
    LD A, (pacman.xPos)
    CP A, $C8
    JR NZ, +    ; IF NOT, SKIP...
    ; REMOVE POWER DOT FROM SCREEN
    LD HL, NAMETABLE + ($05 * 2) + ($0C * $40) | VRAMWRITE
    RST setVDPAddress
    XOR A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    LD HL, NAMETABLE + ($05 * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    XOR A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    ; SET SCARED FLAGS FOR GHOSTS
    INC A   ; $01
    LD (blinky + EDIBLE_FLAG), A
    LD (pinky + EDIBLE_FLAG), A
    LD (inky + EDIBLE_FLAG), A
    LD (clyde + EDIBLE_FLAG), A
    ; SET SUPER STATE FOR PAC-MAN
    LD (pacPoweredUp), A
    ; TIMER "SET"
    LD (mainTimer0), A
    ; MAKE GHOSTS FACE RIGHT
    LD A, $03
    LD (blinky.currDir), A
    LD (blinky.nextDir), A
    LD (pinky.currDir), A
    LD (pinky.nextDir), A
    LD (inky.currDir), A
    LD (inky.nextDir), A
    LD (clyde.currDir), A
    LD (clyde.nextDir), A
    ; SET POWER DOT DELAY
    INC A
    LD (pacPelletTimer), A  ; HALF OF THE TIME SET IN ACTUAL GAME DUE TO SINGLE UPDATE HERE
    RET
+:
;   DECREMENT STATE (COUNTERACT INCREMENT IN UPDATE)
    LD HL, introSubState
    DEC (HL)
;   MOVE ALL ACTORS TOWARDS POWER DOT
    ; PAC-MAN
    LD DE, ATT_PAC_SPEED00  ; MOVES SLIGHTLY SLOWER THAN GHOSTS
    LD HL, (pacman.subPixel)
    ADD HL, DE
    LD (pacman.subPixel), HL
    ; CALCULATE TILE
    LD IX, pacman
    CALL updateCurrTile
    LD A, (pacman + CURR_X)
    ; CHECK IF PAC-MAN HAS REACHED WANTED TILE (BLINKY)
    CP A, $21
    RET C   ; IF NOT, END
    ; MOVE BLINKY
    LD DE, ATT_GHO_SPEED00
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
    ; CHECK IF PAC-MAN HAS REACHED WANTED TILE (PINKY)
    CP A, $23
    RET C   ; IF NOT, END
    ; MOVE PINKY
    LD HL, (pinky.subPixel)
    ADD HL, DE
    LD (pinky.subPixel), HL
    ; CHECK IF PAC-MAN HAS REACHED WANTED TILE (INKY)
    CP A, $25
    RET C   ; IF NOT, END
    ; MOVE INKY
    LD HL, (inky.subPixel)
    ADD HL, DE
    LD (inky.subPixel), HL
    ; CHECK IF PAC-MAN HAS REACHED WANTED TILE (CLYDE)   
    CP A, $27
    RET C   ; IF NOT, END
    ; MOVE CLYDE
    LD HL, (clyde.subPixel)
    ADD HL, DE
    LD (clyde.subPixel), HL
    RET


;   SUB STATE 10
ghostHeadStart:
;   UPDATE GHOST VISUAL COUNTERS
    CALL ghostVisCounterUpdate
;   STATE 16 CHECK (HAS PAC-MAN REACHED CENTER OF TILE WHERE POWER DOT WAS?)
    LD A, (pacman.xPos)
    CP A, $CC
    JR NZ, +    ; IF NOT, SKIP...
    ; MAKE PAC-MAN FACE RIGHT
    LD A, $03
    LD (pacman.currDir), A
    RET
+:
;   DECREMENT STATE (COUNTERACT INCREMENT IN UPDATE)
    LD HL, introSubState
    DEC (HL)
;   MOVE ALL ACTORS TOWARDS POWER DOT
    ; PAC-MAN
    LD HL, pacPelletTimer   ; CHECK IF MSB IS SET (IS $FF)
    DEC (HL)                ; DECREMENT TIMER
    JP P, +                 ; IF NOT SET, DON'T MOVE PAC-MAN
    INC (HL)    ; COUNTERACT NEXT DECREMENT
    ; MOVES SLIGHTLY SLOWER THAN GHOSTS
    LD DE, ATT_PAC_SPEED00
    LD HL, (pacman.subPixel)
    ADD HL, DE
    LD (pacman.subPixel), HL
+:
    ; BLINKY
    LD DE, ATT_GHO_SPEED01
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
    ; PINKY
    LD HL, (pinky.subPixel)
    ADD HL, DE
    LD (pinky.subPixel), HL
    ; INKY
    LD HL, (inky.subPixel)
    ADD HL, DE
    LD (inky.subPixel), HL
    ; CLYDE
    LD HL, (clyde.subPixel)
    ADD HL, DE
    LD (clyde.subPixel), HL
    RET


;   SUB STATE 11
eatGhosts:
;   DECREMENT STATE (COUNTERACT INCREMENT IN UPDATE)
    LD HL, introSubState
    DEC (HL)
;   IS TIMER RUNNING?
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF SO, END...
    INC (HL)    ; COUNTERACT DECREMENT IF AT 0
;   STATE 17 CHECK (HAS PAC-MAN ATE ALL GHOSTS?)
    LD A, (ghostPointIndex)
    CP A, $03
    JP Z, demoPrep  ; IF SO, PREPARE FOR DEMO
;   RESET GHOST POINT SPRITE NUMBER (NO COLLISION DETECTED YET)
    XOR A
    LD (ghostPointSprNum), A
;   COLLISION CHECK BETWEEN PAC-MAN AND GHOSTS
    CALL globalCollCheckTile
    CALL globalCollCheckPixel
    ; CHECK IF COLLISION OCCURED
    LD A, (ghostPointSprNum)
    OR A
    JR Z, + ; IF NOT, CONTINUE UPDATE
    ; RESET EAT SUBSTATE (DON'T NEED)
    XOR A
    LD (eatSubState), A
    ; GHOST IS NOW DEAD
    LD (IX + ALIVE_FLAG), A
    ; SET GHOST POINTS X POSITION
    LD A, (IX + X_WHOLE)
    LD (ghostPointXpos), A
    ; SET EAT TIMER
    LD A, ATT00_TIMER_LEN
    LD (mainTimer0), A
    ; INCREMENT POINT INDEX
    LD HL, ghostPointIndex
    INC (HL)
    RET
+:
;   UPDATE GHOST VISUAL COUNTERS
    CALL ghostVisCounterUpdate
;   MOVE ALL ACTORS
    ; PAC-MAN
    LD DE, ATT_PAC_SPEED01
    LD HL, (pacman.subPixel)
    ADD HL, DE
    LD (pacman.subPixel), HL
    ; BLINKY
    LD DE, ATT_GHO_SPEED01
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
    ; PINKY
    LD HL, (pinky.subPixel)
    ADD HL, DE
    LD (pinky.subPixel), HL
    ; INKY
    LD HL, (inky.subPixel)
    ADD HL, DE
    LD (inky.subPixel), HL
    ; CLYDE
    LD HL, (clyde.subPixel)
    ADD HL, DE
    LD (clyde.subPixel), HL
;   UPDATE CURRENT TILE FOR ALL ACTORS
    LD IX, pacman
    CALL updateCurrTile
    LD IX, blinky
    CALL updateCurrTile
    LD IX, pinky
    CALL updateCurrTile
    LD IX, inky
    CALL updateCurrTile
    LD IX, clyde
    JP updateCurrTile