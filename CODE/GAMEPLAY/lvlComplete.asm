/*
-------------------------------------------------------
                LEVEL COMPLETE 00 MODE
-------------------------------------------------------
*/
sStateGameplayTable@comp00Mode:
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
    LD A, LVLC00_TIMER_LEN
    LD (mainTimer0), A
;   STOP SOUNDS ON CHANNEL 1
    LD B, $01
    CALL sndStopChannel
;   CLEAR INVISIBLE MAZE FLAG
    LD HL, plusBitFlags
    RES INVISIBLE_MAZE, (HL)
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
;   DECREMENT TIMER 0
    LD HL, mainTimer0
    DEC (HL)
    RET NZ  ; IF NOT 0, EXIT...
@@exit:
    ; SET SUBSTATE TO COMP01 AND NEW-STATE-FLAG
    LD HL, $01 * $100 + GAMEPLAY_COMP01
    LD (subGameMode), HL
    RET




/*
-------------------------------------------------------
                LEVEL COMPLETE 01 MODE
-------------------------------------------------------
*/
sStateGameplayTable@comp01Mode:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw    ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   RESET NEW STATE FLAG
    XOR A
    LD (isNewState), A
;   CLEAR FRUIT STATUS
    LD (currPlayerInfo.fruitStatus), A
;   REMOVE GHOSTS FROM SCREEN
    LD (blinky + Y_WHOLE), A
    LD (pinky + Y_WHOLE), A
    LD (inky + Y_WHOLE), A
    LD (clyde + Y_WHOLE), A
;   REMOVE FRUIT FROM SCREEN
    LD HL, SPRITE_TABLE + $19 | VRAMWRITE
    RST setVDPAddress
    LD A, $F7
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
    OUT (VDPDATA_PORT), A
;   TURN MAZE WHITE
    LD HL, BGPAL_WALLS | CRAMWRITE
    RST setVDPAddress
    CALL colorWallsWhite
;   SET PALETTE CHANGE COUNTER
    LD A, MAZE_FLASH_TIMER
    LD (mazeDoneCounter), A
@@draw:
;   GENERAL DRAW FOR GAMEPLAY
    CALL generalGamePlayDraw
@@update:
    ; BITS 0 - 3: TIMER COUNTER
    ; BIT 4: COLOR FLAG (0 - WHITE, 1 - REGULAR)
    ; BITS 5 - 7: FLASH COUNTER
;   PALETTE COUNTER CHECK
    ; DECREMENT TIMER COUNTER
    LD HL, mazeDoneCounter
    DEC (HL)
    LD A, $0F
    AND A, (HL) ; CHECK IF COUNTER IS 0
    RET NZ      ; IF NOT, END
    ; INCREMENT FLASH COUNTER
    LD A, $20
    ADD A, (HL)
    LD (HL), A
    JR C, @@exit    ; IF OVERFLOW OCCURED, THEN STOP FLASHING
    ; SET VDP ADDRESS FOR MAZE COLOR CHANGE
    LD HL, BGPAL_WALLS | CRAMWRITE
    RST setVDPAddress
    ; RESET TIMER COUNTER
    LD A, (mazeDoneCounter)
    OR A, MAZE_FLASH_TIMER
    ; TOGGLE MAZE COLOR FLAG
    XOR A, $10
    LD (mazeDoneCounter), A
    ; CHANGE COLORS DEPENDING ON FLAG
    BIT 4, A
    JR Z, colorWallsWhite   ; SET TO WHITE IF CLEAR
    ; RESTORE MAZE COLORS
    LD BC, BGPAL_SHADE2 * $100 + VDPDATA_PORT    ; UP TO, AND INCLUDING, MAZE SHADE 2
    LD A, (plusBitFlags)    ; ADD 1 TO B IF GAME IS MS.PAC (RESTORES GHOST GATE)
    AND A, $01 << MS_PAC
    RRCA
    ADD A, B
    LD B, A
    LD HL, mazePalette + BGPAL_WALLS    ; SKIP TRANSPARENT COLOR
    OTIR
    RET
@@exit:
;   SWITCH FIRST READY MODE
    LD HL, $01 * $100 + GAMEPLAY_READY01
    LD (subGameMode), HL
;   RESET DEATH STATUS
    XOR A
    LD (currPlayerInfo.diedFlag), A
;   INCREMENT LEVEL AND DIFFICULTY POINTER
    ; INCREMENT LEVEL (256 BUG!!!)
    LD HL, currPlayerInfo.level
    INC (HL)
    ; CHECK IF AT HIGHEST DIFFICULTY
    LD HL, (currPlayerInfo.levelTablePtr)
    LD A, (HL)
    CP A, $14   ; HIGHEST LEVEL
    JP Z, generalResetFunc  
    ; IF SO, DON'T INCREMENT POINTER
    ; ELSE, INCREMENT POINTER
    INC HL
    LD (currPlayerInfo.levelTablePtr), HL
;   CUTSCENE CHECK (2, 5, 9, 13, 17)
    LD B, $02   ; CUTSCENE SUBSTATE FOR SCENE 2
    ; GET CURRENT LEVEL
    LD A, (currPlayerInfo.level)
    CP A, $11   ; CHECK IF LEVEL IS 17  02
    JR Z, +
    CP A, $0D   ; CHECK IF LEVEL IS 13  02
    JR Z, +
    CP A, $09   ; CHECK IF LEVEL IS 9   02
    JR Z, +
    DEC B
    CP A, $05   ; CHECK IF LEVEL IS 5   01
    JR Z, +
    DEC B
    CP A, $02   ; CHECK IF LEVEL IS 2   00
    JR Z, +
;   DO GENERAL GAMEPLAY RESET
    JP generalResetFunc
+:
;   SETUP CUTSCENE STATE
    ; SET SUBSTATE
    LD A, (plusBitFlags)    ; ADD 4 IF GAME IS MS. PAC
    AND A, $01 << MS_PAC
    RLCA
    ADD A, B
    LD (subGameMode), A
    ; SWITCH TO CUTSCENE MODE
    LD A, M_STATE_CUTSCENE
    LD (mainGameMode), A
    RET




/*
    HELPER FUNCTION
*/
colorWallsWhite:
    LD A, $3F
    OUT (VDPDATA_PORT), A   ; WHITE WALLS
    XOR A
    OUT (VDPDATA_PORT), A   ; BLACK INSIDE
;   CHECK IF STYLE IS "ARCADE"
    LD A, (plusBitFlags)
    AND A, $01 << STYLE_0
    JR NZ, +    ; IF SO, SKIP
    LD A, $2A
    OUT (VDPDATA_PORT), A   ; SHADING
    OUT (VDPDATA_PORT), A   ; SHADING
    XOR A
    OUT (VDPDATA_PORT), A   ; SHADING
    OUT (VDPDATA_PORT), A   ; GHOST BARRIER
    RET
+:
    XOR A
    OUT (VDPDATA_PORT), A   ; SHADING (BLACK)
    LD A, $3F
    OUT (VDPDATA_PORT), A   ; SHADING (WHITE)
    XOR A
    OUT (VDPDATA_PORT), A   ; SHADING
    OUT (VDPDATA_PORT), A   ; GHOST BARRIER
    RET