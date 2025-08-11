/*
            RAM VARIABLES
*/

;   STARTS AT $C000 [SIZE: $600]
.RAMSECTION "ram" SLOT 3
;   GENERAL GAME STUFF
    ; SPECIAL RESET KEY
    resetSig: dsb 4
    ; SPRITE FLICKER CONTROL
    sprFlickerControl: db
    ; MD CONTROLLER FLAG (FOR PAUSE ON START)
    mdControlFlag: db
    ; INTERRUPT REQUESTS
    vblankFlag: db
    pauseRequest: db
    ; CONTROL PORTS
    controlPort1: db
    controlPort2: db
    prevInput: db   ; USED IN MENUS AND MD PAUSE
    pressedButtons: db
;   MAIN GAME STATE MACHINE
    mainGameMode: db
    subGameMode: db
    isNewState: db
;   GAME TIMERS
    mainTimer0: dw  ; GENERIC TIMER
    mainTimer1: dw  ; POWER DOT / ENERGIZER
    mainTimer2: dw  ; SCATTER/CHASE
    mainTimer3: dw  ; FRUIT
    mainTimer4: dw  ; DOT EXPIRE
;   DIPSWITCHES
    normalFlag: db      ; 0 - NORMAL, 1 - HARD
    bonusValue: dsb 3   ; 010000 OR 015000 OR 020000 OR FFFFFF (NO BONUS)
    startingLives: db   ; 1, 2, 3, 5
    speedUpFlag: db     ; 0 - OFF, 1 - ON
;   PAC PLUS
    ; BIT 0, 1: 0 - PAC-MAN, 1 - PLUS, 2 - MS.PAC-MAN, 3 - UNDEFINED
    ; BIT 7: TURN MAZE INVISIBLE
    plusBitFlags: db
    plusRNGValue: db
    plusFruitSuperTime: dw
;   GAMEPLAY MODE STUFF
    ; INFO FOR CURRENT PLAYER
    currPlayerInfo INSTANCEOF playerInfo
    ; INFO FOR PLAYER THAT IS CURRENTLY NOT PLAYING
    altPlayerInfo INSTANCEOF playerInfo
    ; COMMON/UNRELATED
    highScore: dsb 3
    mazeDoneCounter: db
    xUPCounter: db
    rngIndex: dw
    powDotTime: dw
    dotExpireTime: db
    dotExpireCounter: db
    ; BIT 0: 0 - PLAYER 1 MODE, 1 - PLAYER 2 MODE
    ; BIT 1: 0 - CURRENT PLAYER IS P1, 1 - CURRENT PLAYER IS P2
    playerType: db
;   FRUIT RELATED VARS
    fruitPos: dw    ; XY
    fruitTileDefPtr: dw
    fruitPointTDefPtr: dw
    fruitScoreVal: dw
    fruitPathLen: db
    fruitPathBounce: db
    fruitPathPtr: dw
;   GHOST POINTS RELATED VARS
    ghostPointXpos: db
    ghostPointYpos: db
    ghostPointSprNum: db
    ghostPointIndex: db
;   EAT STATE STUFF
    eatSubState: db
;   POWER DOT PALETTE CYCLING
    powDotFrameCounter: db
    powDotPalette: dsb 4    ; BUFFER 0, 1, 2, 3
;   GENERAL PLAYER VARS
    pacPoweredUp: db
    pacPelletTimer: db
    pacDeathTimer: db
    pacDeathTimePtr: dw
    spdPatternNormal: dsb 4
    spdPatternSuper: dsb 4
    spdPatternPtr: dw
    inputFlag: db
    pacSprControl: db   ; 0: NONE, 1: CLEAR NORMAL SPR AREA, 2: CLEAR SUPER SPR AREA
    ; VISUAL
    pacTileXCenter: db
    pacTileYCenter: db
    tileMapPointer: dw
    tileQuadrant: db    ; 0 - 3
    lifeHudPtr: dw
;   GLOBAL GHOST STUFF
    globalDotCounter: db
    frameCounter: db
    flashCounter: db
    scatterChaseIndex: db
    scatterChasePtr: dw
    personalDotCounts: dsb 3
    inHomeSpdPatt: db
    ; FOR BLINKY.....
    spdPatternDiff1: dsb 4
    spdPatternDiff0: dsb 4
    difficultyState: db
    speedUpDotCount: db
;   PAC-MAN
    pacman INSTANCEOF actor
;   GHOSTS
    blinky INSTANCEOF ghost
    pinky INSTANCEOF ghost
    inky INSTANCEOF ghost
    clyde INSTANCEOF ghost
;   TILE BUFFER FOR EATEN DOTS
    tileBufferFlag: db
    tileBufferCount: db
    tileBufferAddress: dw
    tileBuffer: dsb 12  ; [RELATIVE VRAM OFFSET:DB, TILE:DW] * 4
;   OPTIONS MENU VARS
    liveIndex: db
    diffIndex: db
    bonusIndex: db
    speedIndex: db
    styleIndex: db
;   PATHFIND TASK LIST
    ;taskListStart: dw
    taskListEnd: dw
    taskListArea: dsb 8
;   SOUND RELATED VARS
    ghostSoundControl: db   ; BITS 0-2: SIREN TYPE, BIT 3: FRIGHT, BIT 4: EYES, BIT 5: NEW SOUND
    sndNoiseType: db
    ch2SoundControl: db
    chan0 INSTANCEOF sndChannel
    chan1 INSTANCEOF sndChannel
    chan2 INSTANCEOF sndChannel
    chan3 INSTANCEOF sndChannel
.ENDS


;   STARTS AT $C600 [SIZE: $1960]
.RAMSECTION "mazeRam" SLOT 4
;   STATIC MAZE TABLES
    mazeEatenTbl: dsb $100        ; [BYTE ALIGNED]
    mazeMutatedTbl: dsb $100      ; [BYTE ALIGNED] JR. PAC
    mazeEatenMutatedTbl: dsb $200 ; JR. PAC
    mazePowTbl: dsb $40           ; [BYTE ALIGNED]
;   MAZE PALETTE DATA
    mazePalette: dsb $10
;   MAZE DATA GROUP FOR EACH PLAYER
    mazeGroup1 INSTANCEOF mazePlayerInfo
    mazeGroup2 INSTANCEOF mazePlayerInfo
.ENDS

;   STARTS AT $DF60 [SIZE: $A0]
.RAMSECTION "workArea" SLOT 5
;   TEMPORARY RAM FOR WHATEVER NEEDS IT
    workArea: dsb $A0
.ENDS