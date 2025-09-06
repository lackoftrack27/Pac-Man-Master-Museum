/*
-------------------------------------------------------
                    NORMAL MODE
-------------------------------------------------------
*/
sStateGameplayTable@normalMode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JP Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
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
;   OFF
    LD A, $A0
    OUT (VDPCON_PORT), A
    LD A, $81
    OUT (VDPCON_PORT), A
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
;   ON
    LD A, $E0
    OUT (VDPCON_PORT), A
    LD A, $81
    OUT (VDPCON_PORT), A
@@update:
;   CHECK FOR ALL DOTS EATEN
    CALL allDotsEatenCheck
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