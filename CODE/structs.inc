/*
------------------------------------------------
                STRUCTURES
------------------------------------------------
*/
;   PLAYER INFO
.STRUCT playerInfo
    score dsb 3
    dotCount db
    jrDotCount dw
    levelTablePtr dw
    level db
    lives db
    diedFlag db
    awarded1UPFlag db
    fruitStatus db
.ENDST

;   HIGH SCORES IN SRAM
.STRUCT highScoresSRAM
    pacNormal dsb 3     ; 0
    pacNormalPlus dsb 3 ; 1
    msNormal dsb 3      ; 2
    msNormalPlus dsb 3  ; 3
    jrNormal dsb 3      ; 4
    jrNormalPlus dsb 3  ; 5
    sramSig dsb 4       
    testWrite dsb 2
    pacFast dsb 3       ; 8
    pacFastPlus dsb 3
    msFast dsb 3
    msFastPlus dsb 3
    jrFast dsb 3
    jrFastPlus dsb 3
.ENDST


;   COLLISION TILE STRUCT
.STRUCT tilePos
    tileX db
    tileY db
    tileID db
.ENDST


;   ACTOR STRUCT (PAC-MAN AND GHOSTS)
.STRUCT actor
    ; X SUBPIXEL VALUE (ONLY USED FOR PAC-MAN'S INTRO & CUTSCENES)
    subPixel db
    ; PIXEL VALUE OF ON SCREEN POSITION (LOGICAL - 8px TILES)
    xPos dw
    yPos dw
    ; DIRECTION OF ACTOR
    currDir db  ; 0 - UP, 1 - LEFT, 2 - DOWN, 3 - RIGHT
    ; NEXT DIRECTION ACTOR WILL TAKE
    nextDir db
    ; REVERSE OF CURRENT DIRECTION
    reveDir db
    ; ACTOR'S BASE SPRITE NUMBER IN SAT
    sprTableNum db
    ; FLAG TO KEEP TRACK OF ACTOR'S STATE STATUS
    newStateFlag db
    ; STATE ID
    state db
    ;
    offScreenFlag db
    ; COLLISION TILES OF ACTOR
    ; ORDER: UP, LEFT, DOWN, RIGHT, CURRENT, NEXT, TARGET
    collisionTiles INSTANCEOF tilePos 7
.ENDST



;   GHOST STRUCT
.STRUCT ghost
    ; ALL ACTOR VARS
    INSTANCEOF actor
    ; SPEED PATTERNS FOR GHOST
    spdPatternNormal dsb 4  ; SCATTER/CHASE
    spdPatternScared dsb 4  ; SCARED
    spdPatternSlow dsb 4    ; SCATTER/CHASE/SCARED ON SLOWDOWN TILE
    ; FLAG TO KEEP TRACK OF IF THE GHOST MUST REVERSE
    reverseFlag db
    ; GHOST DOT COUNTER (FOR HOME RELEASE)
    dotCounter db
    ; ALIVE FLAG (0 - DEAD, 1 - ALIVE)
    aliveFlag db
    ; FLAG TO KNOW WHEN THE GHOST SHOULD VISIBLY BE SCARED (HOLD LOOK BETWEEN STATES)
    visiblyScaredFlag db
    ; GHOST ID (0 - BLINKY, 1 - PINKY, 2 - INKY, 3 - CLYDE)
    id db
    ; PLUS
    invisible db
.ENDST



;   SOUND CHANNEL STRUCT
.STRUCT sndChannel
    vol  db
    note db
    duration db
    pointer dw
    chanControl db  ; BIT 1: REST, BIT 3: LITERAL READ MODE, BIT 4: NO ATTACK, BIT 7: PLAYING
    detune db       ; SIGNED
    noteDisplace db ; SIGNED
    durCounter db
    startPointer dw
    startVol db
    envelope db
    envelopeIndex db
    freq    dw
    sndID   db      ; ID CHANNEL IS CURRENTLY PLAYING (0 MEANS OFF)
.ENDST

; UNIQUE MAZE DATA FOR EACH PLAYER ($0AC4)
.STRUCT mazePlayerInfo
    collMap dsb 870     ; NON-SCROLLING: 496 BYTES
    tileMap dsb 1886    ; NON-SCROLLING: 1536 BYTES
.ENDST


.STRUCT msPacCutsceneControl
    ptrList     dsb $0E ; 7 POINTERS TO INDEPENDENT PROGRAMS
    timerList   dsb $07 ; TIMERS FOR EACH PROGRAM
    charList    dsb $0E ; POINTERS FOR EACH PROGRAM'S CHARACTER (OBJECT)
    tempPosList dsb $0E ; TEMP POSITIONS FOR EACH PROGRAM (fractional?)
    posList     dsb $0E ; POSITIONS FOR EACH PROGRAM (WHERE OBJECT IS DISPLAYED)
    doneList    dsb $07 ; FLAGS FOR EACH PROGRAM (SIGNIFIES WHEN PROGRAM IS DONE)
    charOffsetList  dsb $07 ; OFFSET INTO PROGRAM'S CHARACTER'S POINTER (WHICH SPRITE TO DISPLAY OF CHARACTER)
    highXList   dsb $07 ; HIGH BYTE OF X POSITION FOR EACH PROGRAM
.ENDST