/*
------------------------------------------------
                STRUCTURES
------------------------------------------------
*/
;   PLAYER INFO
.STRUCT playerInfo
    score dsb 3
    dotCount db
    levelTablePtr dw
    level db
    lives db
    diedFlag db
    awarded1UPFlag db
    fruitStatus db
.ENDST


;   COLLISION TILE STRUCT
.STRUCT tilePos
    tileX db
    tileY db
    tileID db
.ENDST


;   ACTOR STRUCT (PAC-MAN AND GHOSTS)
.STRUCT actor
    ; SUBPIXEL VALUE USED TO REDUCE SPEEDS TO 3/4
    subPixel db
    ; PIXEL VALUE OF ON SCREEN POSITION (LOGICAL - 8px TILES)
    xPos db
    yPos db
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

; UNIQUE MAZE DATA FOR EACH PLAYER
.STRUCT mazePlayerInfo
    collMap dsb 810     ; NON-SCROLLING: 496 BYTES
    tileMap dsb 1886    ; NON-SCROLLING: 1536 BYTES
.ENDST