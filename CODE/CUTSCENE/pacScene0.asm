/*
-------------------------------------------------------
                CUTSCENE 1 [PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@pacScene0:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   PAC-MAN CUTSCENE SETUP
    CALL pacCutsceneInit
;   SPECIFIC CUTSCENE INITIALIZTION
    CALL pacCutSetSpritePal0
@@draw:
;   DO COMMON DRAW
    CALL generalGamePlayDraw
@@update:
;   DO UPDATE FOR SPECIFIC CUTSCENE
    LD HL, scene0SubTable
    LD A, (cutsceneSubState)
    RST jumpTableExec
    RET


/*
---------------------------------------
        SUB STATE JUMP TABLE
---------------------------------------
*/
scene0SubTable:
    .DW scene0Update0
    .DW scene0Update1
    .DW scene0Update2
    .DW scene0Update3
    .DW scene0Update4
    .DW scene0Update5
    .DW scene0Update6


/*
---------------------------------------
        SUB STATE FUNCTIONS
---------------------------------------
*/
scene0Update0:
;   CHECK IF PAC-MAN IS ON SCREEN
    LD A, (pacman + CURR_X)
    CP A, $21
    LD DE, CUT_PAC_SPEED00
    JR NZ, cutscenePacMove  ; IF NOT, MOVE
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene0Update1:
;   CHECK IF PAC-MAN IS OFF SCREEN (LEFT SIDE)
    LD A, (pacman + CURR_X)
    CP A, $1E
    JR NZ, scene0ActorMovement01
;   CHANGE PAC-MAN'S POSITION
    ; Y
    LD A, (pacman.yPos)
    SUB A, $10
    LD (pacman.yPos), A
    ; X
    LD A, (pacman.xPos)
    ADD A, $08
    LD (pacman.xPos), A
;   SET PAC-MAN STATE
    LD A, PAC_BIG       ; MAKE HIM DISPLAY AS BIG PAC-MAN
    LD (pacman.state), A
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene0Update2:
;   CHECK IF BLINKY IS OFF SCREEN (LEFT SIDE)
    LD A, (blinky + CURR_X)
    CP A, $1E
    JR NZ, scene0ActorMovement01@justBlinky
;   MAKE BLINKY EDIBLE
    LD A, $01
    LD (blinky + EDIBLE_FLAG), A
;   SET TIMER FOR HALF SECOND
    LD A, 30
    LD (mainTimer0), A
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene0Update3:
;   WAIT FOR TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ
    ; SET TIMER FOR HALF SECOND (FOR LAST STATE)
    LD A, 30
    LD (mainTimer0), A
;   INCREMENT CUTSCENE STATE
    JP incCutState

scene0Update4:
;   CHECK IF BLINKY IS AROUND CENTER OF SCREEN
    LD A, (blinky + CURR_X)
    CP A, $2F
    JR NZ, scene0ActorMovement02
;   INCREMENT CUTSCENE STATE
    JP incCutState

scene0Update5:
;   CHECK IF BLIKNY IS OFF SCREEN (RIGHT SIDE)
    LD A, (blinky + CURR_X)
    CP A, $3D
    JR NZ, scene0ActorMovement03
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene0Update6:
;   MOVE PAC-MAN
    LD DE, CUT_PAC_SPEED01
;   CHECK IF PAC-MAN IS OFF SCREEN (RIGHT SIDE)
    LD A, (pacman + CURR_X)
    CP A, $1E
    JR NZ, cutscenePacMove
;   CHECK IF TIMER IS DONE
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT, END
;   LAZY TIMER WAIT
    LD B, $04
-:
    HALT
    DJNZ -
;   PALETTE RESTORE
    CALL pacCutResSpritePal0
;   ELSE, SWITCH BACK TO GAME
    JP switchToGameplay




/*
---------------------------------------
            HELPER FUNCTIONS
---------------------------------------
*/

cutscenePacMove:
;   PAC-MAN
    LD HL, (pacman.subPixel)
    ADD HL, DE
    LD (pacman.subPixel), HL
    ; UPDATE CURR TILES
    LD IX, pacman
    JP updateCurrTile


scene0ActorMovement01:
;   PAC-MAN
    LD DE, CUT_PAC_SPEED00  ; (GOING LEFT)
    CALL cutscenePacMove
@justBlinky:
;   BLINKY
    LD DE, CUT_GHO_SPEED00  ; FAST SPEED (GOING LEFT)
-:
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
    ; UPDATE CURR TILES
    LD IX, blinky
    CALL updateCurrTile
;   UPDATE GHOST VISUAL COUNTERS
    JP ghostVisCounterUpdate

scene0ActorMovement02:
    LD DE, CUT_GHO_SPEED01  ; SCARED SPEED (GOING RIGHT)
    JR -

scene0ActorMovement03:
;   PAC-MAN
    LD DE, CUT_PAC_SPEED01    ; (GOING RIGHT)
    CALL cutscenePacMove
;   BLINKY
    JR scene0ActorMovement02