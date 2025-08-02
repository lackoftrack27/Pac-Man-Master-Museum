/*
-------------------------------------------------------
                    NORMAL MODE
-------------------------------------------------------
*/
sStateGameplayTable@normalMode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   CLEAR SUPER PAC-MAN SPRITE AREA (WHEN COMING FROM SUPER MODE)
    LD A, $02
    LD (pacSprControl), A
;   MAKE MAZE VISIBLE (IF NEEDED)
    ; CHECK IF INVISIBLE FLAG IS SET
    LD HL, plusBitFlags
    BIT INVISIBLE_MAZE, (HL)
    JR Z, @@draw    ; IF NOT, SKIP
    ; CLEAR FLAG
    RES INVISIBLE_MAZE, (HL)
    ; RESTORE COLORS
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    LD HL, mazePalette
    LD BC, BGPAL_PDOT0 * $100 + VDPDATA_PORT    ; DO UP TO, BUT NOT INCLUDING, 1ST POW DOT COLOR
    OTIR
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   CHECK FOR ALL DOTS EATEN
    ; CHECK IF GAME IS MS. PAC
    LD L, $F4   ; AMOUNT FOR PAC-MAN
    LD A, (plusBitFlags)
    BIT MS_PAC, A
    JR Z, +    ; IF NOT, SKIP
    ; GET DOT COUNT FOR CURRENT LEVEL
    LD HL, msMazeDotCounts
    CALL getMazeIndex
+:
    ; CHECK IF DOTS EATEN IS MATCHES AMOUNT FOR MAZE
    LD A, (currPlayerInfo.dotCount)
    CP A, L
    JR NZ, +    ; IF THERE ARE ANY DOTS, SKIP...
    ; ELSE, SET MODE TO FIRST LEVEL COMPLETE STATE
    LD HL, $01 * $100 + GAMEPLAY_COMP00
    LD (subGameMode), HL
    RET
+:
;   GENERAL GAMEPLAY UPDATE (SHARED WITH SUPER/EAT MODE)
    CALL generalGameplayUpdate
    CALL generalGameplayUpdate
;   INACTIVITY CHECK / GHOST RELEASE
    CALL dotExpireUpdate
;   GHOST IN HOME UPDATE (ONLY IN NORMAL/SUPER MODE)
    CALL ghostHomeUpdate
;   UPDATE GHOST VISUAL COUNTERS (ONLY IN NORMAL/SUPER MODE)
    CALL ghostVisCounterUpdate
;   SCATTER/CHASE TIMER CHECK (ONLY IN NORMAL MODE)
    CALL scatterChaseCheck
;   DO GHOST FLASH (ONLY IN SUPER MODE)
    CALL ghostFlashUpdate
;   UPDATE POWER DOT PALETTE CYCLE
    CALL powDotCyclingUpdate
;   UPDATE GHOST SOUNDS
    CALL processGhostSFX
;   CHECK FRUIT/FRUIT POINTS
    CALL fruitUpdate
;   PROCESS CHANNEL 2 SFX (DONE IN SOUND DRIVER IN OG)
    JP processChan2SFX
;   END OF UPDATE...