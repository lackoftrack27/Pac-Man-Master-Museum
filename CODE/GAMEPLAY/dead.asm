/*
-------------------------------------------------------
                    DEAD 00 MODE
-------------------------------------------------------
*/
sStateGameplayTable@dead00Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   RESET GHOST POINT SPRITE NUM
    LD (ghostPointSprNum), A
;   SET TIMER
    LD A, DEAD00_TIMER_LEN
    LD (mainTimer0), A
;   TURN OFF GHOST FLASH
    LD HL, flashCounter
    RES 5, (HL)
;   STOP SOUNDS
    LD B, $01
    CALL sndStopChannel
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   CHECK FOR ALL DOTS EATEN (IN CASE OF DYING ON LAST DOT)
    CALL allDotsEatenCheck
;   GHOST VISUAL COUNTERS
    CALL ghostVisCounterUpdate
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   SET SUBSTATE TO DEAD01, SET NEW-STATE-FLAG
    LD HL, $01 * $100 + GAMEPLAY_DEAD01
    LD (subGameMode), HL
    RET



/*
-------------------------------------------------------
                    DEAD 01 MODE
-------------------------------------------------------
*/
sStateGameplayTable@dead01Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   CLEAR PAC-MAN SPRITE AREA
    LD A, $01
    LD (pacSprControl), A
    LD (pacman.sprTableNum), A  ; MOVE TO SUPER AREA
;   REMOVE ALL OTHER SPRITES BESIDES PAC-MAN
    LD (blinky + Y_WHOLE), A
    LD (pinky + Y_WHOLE), A
    LD (inky + Y_WHOLE), A
    LD (clyde + Y_WHOLE), A
;   FRUIT CHECK
    ; CHECK IF LOW NIBBLE IS 0
    LD A, (currPlayerInfo.fruitStatus)
    AND A, $0F
    JR Z, + ; IF SO, SKIP...
    ; ELSE, TOGGLE BIT 4 AND CLEAR LOWER NIBBLE
    LD A, (currPlayerInfo.fruitStatus)
    XOR A, $10
    AND A, $F0
    LD (currPlayerInfo.fruitStatus), A
+:
    LD (currPlayerInfo.fruitStatus), A
;   SET TIMER
    LD A, DEAD01_TIMER_LEN
    LD (mainTimer0), A
;   NOTIFY PAC-MAN
    CALL pacGameTrans_dead
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   UPDATE PAC-MAN
    LD HL, pacStateTable@update
    LD A, (pacman.state)
    RST jumpTableExec
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   SET SUBSTATE TO DEAD02, SET NEW-STATE-FLAG
    LD HL, $01 * $100 + GAMEPLAY_DEAD02
    LD (subGameMode), HL
    RET




/*
-------------------------------------------------------
                    DEAD 02 MODE
-------------------------------------------------------
*/
sStateGameplayTable@dead02Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   SET TIMER
    LD A, DEAD02_TIMER_LEN
    LD (mainTimer0), A
;   PLAY DEATH SOUND
    LD A, SFX_DEATH     ; ASSUME SFX FOR PAC-MAN
    LD B, A
    LD A, (plusBitFlags)    ; ISOLATE MS. PAC BIT
    AND A, $01 << MS_PAC
    ADD A, B            ; ADD TO MUSIC ID
    LD B, $01           ; CHANNEL 1
    CALL sndPlaySFX
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   UPDATE PAC-MAN
    LD HL, pacStateTable@update
    LD A, (pacman.state)
    RST jumpTableExec
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
;   DISABLE ALL SPRITES (WILL CHANGE AFTER FIRST READY)
    LD HL, SPRITE_TABLE | VRAMWRITE
    RST setVDPAddress
    LD A, SPR_DISABLE
    OUT (VDPDATA_PORT), A
;   CLEAR GLOBAL COUNTER
    XOR A
    LD (globalDotCounter), A
;   SET DEATH FLAG
    INC A
    LD (currPlayerInfo.diedFlag), A
;   CHECK IF THAT WAS LAST LIFE
    LD A, (currPlayerInfo.lives)
    OR A
    JR NZ, +    ; IF NOT, SKIP...
;   SWITCH TO GAME OVER
    LD HL, $01 * $100 + GAMEPLAY_GAMEOVER
    LD (subGameMode), HL
    RET
+:
;   CHECK IF TWO PLAYER MODE IS ENABLED
    LD HL, playerType
    BIT 0, (HL)
    JR Z, + ; IF NOT, SKIP...
@@@swapPlayers:
;   TOGGLE PLAYER BIT (BIT 1)
    LD A, $02
    XOR A, (HL)
    LD (HL), A
;   ELSE, TURN OFF SCREEN (AND VBLANK INTS)
    CALL turnOffScreen
;   SWAP PLAYER DATA
    ; X -> Z
    LD HL, currPlayerInfo
    LD DE, workArea
    LD BC, _sizeof_playerInfo
    LDIR
    ; Y -> X
    LD HL, altPlayerInfo
    LD DE, currPlayerInfo
    LD BC, _sizeof_playerInfo
    LDIR
    ; Z -> Y
    LD HL, workArea
    LD DE, altPlayerInfo
    LD BC, _sizeof_playerInfo
    LDIR
;   SWAP COLLISION MAPS
    ; X -> Z
    LD HL, mazeCollisionPtr
    LD DE, superBigBuffer
    LD BC, MAZE_COLMAP_SIZE
    LDIR
    ; Y -> X
    LD HL, collisionBuffer
    LD DE, mazeCollisionPtr
    LD BC, MAZE_COLMAP_SIZE
    LDIR
    ; Z -> Y
    LD HL, superBigBuffer
    LD DE, collisionBuffer
    LD BC, MAZE_COLMAP_SIZE
    LDIR
;   SWAP TILEMAPS
    ; X -> Z
    LD HL, NAMETABLE
    RST setVDPAddress
    LD HL, superBigBuffer
    LD BC, MAZE_TILEMAP_SIZE
    CALL copyFromVDP
    ; Y -> X
    LD HL, NAMETABLE | VRAMWRITE
    RST setVDPAddress
    LD HL, tileMapBuffer
    LD BC, MAZE_TILEMAP_SIZE
    CALL copyToVDP
    ; Z -> Y
    LD HL, superBigBuffer
    LD DE, tileMapBuffer
    LD BC, MAZE_TILEMAP_SIZE
    LDIR
+:
;   SWITCH TO SECOND READY MODE
    LD HL, $01 * $100 + GAMEPLAY_READY01
    LD (subGameMode), HL
;   GENERAL GAMEPLAY RESET
    JP generalResetFunc