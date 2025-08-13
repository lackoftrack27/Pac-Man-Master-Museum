/*
-------------------------------------------------------
                CUTSCENE 3 [PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@pacScene2:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   PAC-MAN CUTSCENE SETUP
    CALL pacCutsceneInit
;   SPECIFIC CUTSCENE INITIALIZTION
    ; PALETTE SETUP
    CALL pacCutSetSpritePal
    ; HIDE RIGHT-MOST PIXEL COLUMN OF BLINKY
    LD HL, blinky + X_WHOLE
    INC (HL)
@@draw:
;   DO COMMON DRAW
    CALL generalGamePlayDraw
@@update:
;   DO UPDATE FOR SPECIFIC CUTSCENE
    LD HL, scene2SubTable
    LD A, (cutsceneSubState)
    RST jumpTableExec
    RET


/*
---------------------------------------
        SUB STATE JUMP TABLE
---------------------------------------
*/
scene2SubTable:
    .DW scene2Update0
    .DW scene2Update1
    .DW scene2Update2
    .DW scene2Update3
    .DW scene2Update4
    .DW scene2Update5


/*
---------------------------------------
        SUB STATE FUNCTIONS
---------------------------------------
*/
scene2Update0:
;   CHECK IF PAC-MAN IS AT WANTED TILE
    LD A, (pacman + CURR_X)
    CP A, $25
    LD DE, CUT_PAC_SPEED00
    JP NZ, cutscenePacMove  ; IF NOT, MOVE HIM
    ; INCREMENT CUTSCENE STATE
    JP incCutState


scene2Update1:
;   DO SPECIAL DRAW FOR BLINKY
    LD HL, ghostStitchedTileDefs
    CALL specialDrawBlinky0
;   CHECK IF BLINKY IS AT WANTED POSITION (OFF SCREEN)
    LD A, (blinky.xPos)
    CP A, $FF
    JR Z, +
    CP A, $FE
    JR NZ, scene2ActorMovement00    ; IF NOT, MOVE
+:
;   MOVE HIM TWO PIXELS
    INC A
    INC A
    INC A   ; ADDITIONAL INCREMENT TO HIDE RIGHT-MOST PIXEL COLUMN
    LD (blinky.xPos), A
;   TURN BLINKY AROUND
    LD A, $03   ; GO RIGHT
    LD (blinky.currDir), A
    LD (blinky.nextDir), A
;   RESET FRAME COUNTER FOR NAKED GHOST
    XOR A
    LD (nakedFrameCounter), A
;   SET TIMER
    LD A, 60
    LD (mainTimer0), A
;   INCREMENT CUTSCENE STATE
    JP incCutState

scene2Update2:
;   WAIT FOR TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene2Update3:
;   REMOVE BLINKY FROM SCREEN (DONE TO AVOID PEAKING THROUGH FRUIT SPRITES)
    LD IX, blinky
    CALL ghostSpriteFlicker@emptySprite
;   CHECK IF BLINKY IS AT WANTED TILE
    LD A, (blinky + CURR_X)
    CP A, $3C
    JP Z, incCutState   ; IF SO, UPDATE STATE
;   ELSE, MOVE ACTORS
    JR scene2ActorMovement01


scene2Update4:
;   DO SPECIAL DRAW FOR BLINKY
    LD HL, ghostNakedTileDefs
    CALL specialDrawBlinky1
;   CHECK IF BLINKY IS AT WANTED TILE
    LD A, (blinky + CURR_X)
    CP A, $3D
    JR NZ, scene2ActorMovement01    ; IF NOT, MOVE HIM
;   SETUP TIMER FOR .5 SECONDS
    LD A, 30
    LD (mainTimer0), A
    JP incCutState


scene2Update5:
;   WAIT FOR TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ
;   RESTORE PALETTE
    CALL pacCutResSpritePal
;   PREPARE TO GO INTO GAMEPLAY
    JP switchToGameplay


/*
---------------------------------------
            HELPER FUNCTIONS
---------------------------------------
*/

scene2ActorMovement00:
;   CHECK IF PAC-MAN HAS MADE IT TO THE HIDDEN PART OF THE SCREEN
    LD A, (pacman + CURR_X)
    CP A, $3D
    JR Z, + ; IF SO, DON'T MOVE HIM
;   PAC-MAN
    LD DE, CUT_PAC_SPEED00  ; (GOING LEFT)
    CALL cutscenePacMove
+:
;   BLINKY
    LD DE, CUT_GHO_SPEED00  ; FAST SPEED (GOING LEFT)
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
    ; UPDATE CURR TILES
    LD IX, blinky
    CALL updateCurrTile
;   UPDATE GHOST VISUAL COUNTERS
    JP ghostVisCounterUpdate

scene2ActorMovement01:
;   UPDATE FRAME COUNTER FOR NAKED GHOST
    ; ISOLATE COUNTER BITS
    LD HL, nakedFrameCounter
    LD A, $07
    AND A, (HL)
    ; CHECK IF COUNTER IS 6
    CP A, $06
    JR NZ, +    ; IF NOT, SKIP
    LD A, $08
    XOR A, (HL) ; TOGGLE BIT 3
    AND A, $F8  ; CLEAR COUNTER
    LD (HL), A  
+:
    ; INCREMENT COUNTER
    INC (HL)
;   CHECK IF PAC-MAN HAS MADE IT TO THE HIDDEN PART OF THE SCREEN
    LD A, (pacman + CURR_X)
    CP A, $3D
    JR Z, + ; IF SO, DON'T MOVE HIM
;   PAC-MAN
    LD DE, CUT_PAC_SPEED00  ; (GOING LEFT)
    CALL cutscenePacMove
+:
;   BLINKY
    LD DE, CUT_GHO_SPEED03  ; FAST SPEED (GOING RIGHT)
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
    ; UPDATE CURR TILES
    LD IX, blinky
    CALL updateCurrTile
;   UPDATE GHOST VISUAL COUNTERS
    JP ghostVisCounterUpdate


specialDrawBlinky0:
;   ADD 4 IF GHOST FRAME COUNTER IS MULTIPLE OF 8 (THIS MAKES IT SO THEIR FEET MOVE EVERY 8 FRAMES)
    LD A, (frameCounter)
    AND A, $08
    RRCA
    ADD A, L
    LD L, A
;   DRAW GHOST
    LD IX, blinky
    JP displayGhostNormal@skipCalc

specialDrawBlinky1:
;   ADD 4 IF BIT 3 OF FRAME COUNTER IS SET
    LD A, (nakedFrameCounter)
    AND A, $F8
    RRCA
    ADD A, L
    LD L, A
    ; DRAW GHOST
    LD IX, blinky
    CALL displayGhostNormal@skipCalc
;   DRAW DRAGGING CLOTHES
    LD HL, ghostClothTileDefs
    ; ADD 2 IF BIT 3 OF FRAME COUNTER IS SET
    LD A, (nakedFrameCounter)
    AND A, $F8
    RRCA
    RRCA
    ADD A, L
    LD L, A
    ; SETUP SPRITE VARS
    CALL convPosToScreen
    ; ADJUST X
    LD A, D
    SUB A, $07
    LD D, A
    ; ADJUST Y
    LD A, E
    ADD A, $03
    LD E, A
    ; SPR NUM
    LD A, $05
    ; DRAW
    JP display2HTileSprite