/*
-------------------------------------------------------
                CUTSCENE 2 [PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@pacScene1:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   PAC-MAN COMMON CUTSCENE SETUP
    CALL pacCutsceneInit
;   SPECIFIC CUTSCENE INITIALIZTION
    ; PALETTE SETUP
    CALL pacCutSetSpritePal
    ; SHOW STUMP THAT BLINKY WILL GET CAUGHT ON
    LD HL, NAMETABLE + ($0D * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    LD A, $D8           ; $D8: TILE INDEX || $08: SPRITE PALETTE
    OUT (VDPDATA_PORT), A
    LD A, $08
    OUT (VDPDATA_PORT), A
    ; SETUP TIMER
    LD A, 18
    LD (mainTimer0), A
@@draw:
;   DO COMMON DRAW
    CALL generalGamePlayDraw
@@update:
;   DO UPDATE FOR SPECIFIC CUTSCENE
    LD HL, scene1SubTable
    LD A, (cutsceneSubState)
    RST jumpTableExec
    RET



/*
---------------------------------------
        SUB STATE JUMP TABLE
---------------------------------------
*/
scene1SubTable:
    .DW scene1Update0
    .DW scene1Update1
    .DW scene1Update2
    .DW scene1Update3
    .DW scene1Update4
    .DW scene1Update5
    .DW scene1Update6
    .DW scene1Update7
    .DW scene1Update8
    .DW scene1Update9
    .DW scene1Update0A    



/*
---------------------------------------
        SUB STATE FUNCTIONS
---------------------------------------
*/
scene1Update0:
;   WAIT FOR TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update1:
;   CHECK IF PAC-MAN IS AROUND CENTER OF SCREEN
    LD A, (pacman + CURR_X)
    CP A, $2C
    LD DE, CUT_PAC_SPEED00
    JP NZ, cutscenePacMove  ; IF NOT, UPDATE
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update2:
;   CHECK IF BLINKY HAS MOVED A FEW PIXELS
    LD A, (blinky.xPos)
    CP A, $77
    JR Z, +
    CP A, $78
    JP NZ, scene0ActorMovement01      ; IF NOT, UPDATE
+:
;   INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update3:
;   CHECK IF BLINKY HAS MOVED A FEW PIXELS
    LD A, (blinky.xPos)
    CP A, $78
    JP NZ, actorMovement02    ; IF NOT, MOVE ACTORS
    ; CHANGE TO SMALL PIECE OF SKIN
    LD HL, NAMETABLE + ($0D * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, $D908    ; D9: TILE INDEX || 08: SPRITE PALETTE
    OUT (C), H
    OUT (C), L
    ; INCREMENT CUTSCENE STATE
    JP incCutState



scene1Update4:
;   CHECK IF BLINKY HAS MOVED A FEW PIXELS
    LD A, (blinky.xPos)
    CP A, $7B
    JP NZ, actorMovement02    ; IF NOT, MOVE ACTORS
    ; CHANGE TO MEDIUM PIECE OF SKIN
    LD HL, NAMETABLE + ($0D * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, $DA08    ; DA: TILE INDEX || 08: SPRITE PALETTE
    OUT (C), H
    OUT (C), L
    ; INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update5:
;   CHECK IF BLINKY HAS MOVED A FEW MORE PIXELS
    LD A, (blinky.xPos)
    CP A, $7E
    JR NZ, actorMovement02    ; IF NOT, SKIP
    ; CHANGE TO LARGE PIECE OF SKIN
    LD HL, NAMETABLE + ($0C * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    LD HL, $DB08    ; DB: TILE INDEX || 08: SPRITE PALETTE
    OUT (C), H
    OUT (C), L
    INC H           ; DC
    OUT (C), H
    OUT (C), L
    ; INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update6:
;   CHECK IF BLINKY HAS MOVED A FEW MORE PIXELS
    LD A, (blinky.xPos)
    CP A, $80
    JR NZ, actorMovement02    ; IF NOT, SKIP
    ; SET TIMER
    LD A, 90
    LD (mainTimer0), A
    ; INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update7:
;   DECREMENT TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, END
    ; INCREMENT CUTSCENE STATE
    JP incCutState


scene1Update8:
    ; MOVE BLINKY 2 PIXEL TO THE LEFT
    LD HL, blinky.xPos
    INC (HL)
    INC (HL)
    ; CHANGE TO RIPPED SKIN AROUND STUMP
    LD HL, NAMETABLE + ($0C * 2) + ($0D * $40) | VRAMWRITE
    RST setVDPAddress
    XOR A           ; CLEAR TILE
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    LD HL, $DD08    ; F3: TILE INDEX || 08: SPRITE PALETTE
    OUT (C), H
    OUT (C), L
    ; SET TIMER
    LD A, 60
    LD (mainTimer0), A
    ; DISABLE BLINKY DRAW FUNCTION
    LD HL, blinky + INVISIBLE_FLAG
    INC (HL)
    ; DISPLAY BROKEN BLINKY
    LD HL, ghostBrokenTileDefs
    JP displayBrokenBlinky


scene1Update9:
;   DECREMENT TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, END
    ; SET TIMER
    LD (HL), 120
    ; DISPLAY BROKEN BLINKY OBSERVING DAMAGE
    LD HL, ghostBrokenTileDefs@observe
    JP displayBrokenBlinky


scene1Update0A:
;   DECREMENT TIMER
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, END
;   RESTORE PALETTE
    CALL pacCutResSpritePal
;   SWITCH BACK TO GAME
    JP switchToGameplay



/*
---------------------------------------
            HELPER FUNCTIONS
---------------------------------------
*/
actorMovement00:
;   CHECK IF PAC-MAN HAS MADE IT TO THE HIDDEN PART OF THE SCREEN
    LD A, (pacman + CURR_X)
    CP A, $3D
    JP Z, ghostVisCounterUpdate ; IF SO, DON'T MOVE HIM
    ; PAC-MAN
    LD DE, CUT_PAC_SPEED00    ; (GOING LEFT)
    CALL cutscenePacMove
;   UPDATE GHOST VISUAL COUNTERS
    JP ghostVisCounterUpdate
actorMovement02:
;   BLINKY
    LD DE, CUT_GHO_SPEED02
    LD HL, (blinky.subPixel)
    ADD HL, DE
    LD (blinky.subPixel), HL
;   DO COMMON MOVEMENT
    JR actorMovement00



displayBrokenBlinky:
;   SETUP SPRITE VARS
    LD IX, blinky
    CALL convPosToScreen
    LD A, $05
;   DRAW SPRITE
    CALL display4TileSprite
;   FALLTHROUGH

incCutState:
;   SET CUTSCENE SUBSTATE
    LD HL, cutsceneSubState
    INC (HL)
    RET
