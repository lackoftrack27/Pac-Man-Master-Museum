;   SET INCLUDE DIRECTORY
.INCDIR "CODE"
;   INCLUDES
.INCLUDE "structs.inc"
.INCLUDE "constants.inc"
.INCLUDE "banking.inc"
.INCLUDE "ramLayout.inc"


/*
    INFO: GIVEN A POINTER TO AN ACTOR'S SPEED PATTERN, UPDATES THE SPEED PATTERN (LEFT SHIFT BY 1)
    INPUT: HL - SPEED PATTERN POINTER
    OUTPUT - NONE
    USES: HL, DE, AF
*/
.MACRO actorSpdPatternUpdate
;      0      1       2      3
;   LOW_HW HIGH_HW LOW_LW HIGH_LW
;   SPEED PATTERN MUST NOT CROSS $100 BOUNDARY DUE TO 8 BIT INC/DEC!!!
;   LOAD HIGH WORD INTO BC
    LD C, (HL)
    INC L           ; -> HIGH WORD HIGH BYTE
    LD B, (HL)
    INC L           ; -> LOW WORD LOW BYTE
;   LOAD LOW WORD INTO DE
    LD E, (HL)
    INC L           ; -> LOW WORD HIGH BYTE
    LD D, (HL)
;   LEFT SHIFT LOW WORD
    SLA E
    RL D
;   STORE LOW WORD
    LD (HL), D
    DEC L           ; -> LOW WORD LOW BYTE
    LD (HL), E
;   SHIFT HIGH WORD (CARRY)
    RL C
    RL B
;   STORE HIGH WORD
    DEC L           ; -> HIGH WORD HIGH BYTE
    LD (HL), B
    DEC L           ; -> HIGH WORD LOW BYTE
    LD (HL), C
.ENDM

.MACRO addToHL_M
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
.ENDM


.MACRO multBy29
    ; INPUT RANGE IS RELATIVELY SMALL, SO USE A LUT
    LD H, hibyte(mult29Table)
    LD A, L
    ADD A, A
    ADD A, lobyte(mult29Table)
    LD L, A
    LD A, (HL)
    INC L
    LD H, (HL)
    LD L, A
.ENDM

.MACRO multBy41
;   HL * 41 (32 + 08 + 01)
    LD E, L
    LD D, H
    ADD HL, HL
    ADD HL, HL
    ADD HL, HL
    PUSH HL
    ADD HL, HL
    ADD HL, HL
    ADD HL, DE
    POP DE
    ADD HL, DE
.ENDM
/*
----------------------------------------------------------
                SDSC TAG AND SMS HEADER
----------------------------------------------------------
*/
.SDSCTAG 2.10, sdscName, sdscDesc, sdscAuth

/*
----------------------------------------------------------
                        SET BANK
----------------------------------------------------------
*/
.BANK CODE_BANK SLOT 0

/*
----------------------------------------------------------
                        BOOT VECTOR
----------------------------------------------------------
*/
.ORG $0000
.SECTION "Boot Vector" FORCE
boot:
    DI                  ; DISABLE INTURRUPTS
    IM 1                ; INTURRUPT MODE 1
    LD SP, STACK_PTR    ; SETUP STACK POINTER
    JR main             ; GOTO MAIN PROGRAM
.ENDS



/*
----------------------------------------------------------
                    RESETS THE GAME
----------------------------------------------------------
    SELF-EXPLANATORY
*/
.ORG $0008
.SECTION "Reset Game" FORCE
resetGame:
    CALL sndStopAll     ; STOP ALL SOUND
    JP boot             ; GO TO BEGINNING OF ROM
    .DSB $02, $00       ; FILL
.ENDS


/*
----------------------------------------------------------
                    ADD A TO HL
----------------------------------------------------------
    GIVEN A VALUE IN BOTH A AND HL, THE VALUE IN A WILL BE ADDED TO HL
    INPUT: HL - VALUE, A - VALUE
    OUTPUT: HL - HL + A, A - (HL + A)
    USES: HL, A
*/
.ORG $0010
.SECTION "ADD A TO HL" FORCE
addToHL:
    ADD A, L
    LD L, A
    ADC A, H
    SUB A, L
    LD H, A
    LD A, (HL)
    RET
    .DSB $01, $00   ; FILL
.ENDS


/*
----------------------------------------------------------
                    GET DATA AT HL
----------------------------------------------------------
    GIVEN HL, HL WILL BE REPLACE WITH (HL)
    INPUT: HL - VALUE,
    OUTPUT: HL - (VALUE)
    USES: HL, A
*/
.ORG $0018
.SECTION "GET DATA AT HL" FORCE
getDataAtHL:
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    RET
    .DSB $03, $00   ; FILL
.ENDS


/*
----------------------------------------------------------
                SET VDP ADDRESS FUNCTION
----------------------------------------------------------
    GIVEN AN ADDRESS, SETS VDP ADDRESS TO IT
    INPUT: HL
    OUTPUT: NONE
    USES: A
*/
.ORG $0020
.SECTION "Set VDP Address Function" FORCE
setVDPAddress:
    LD A, L     ; LOW BYTE OF ADDRESS
    OUT (VDPCON_PORT), A    
    LD A, H     ;  OPERATION TYPE + HIGH BITS OF ADDRESS
    OUT (VDPCON_PORT), A
    RET
    .DSB $01, $00   ; FILL
.ENDS


/*
----------------------------------------------------------
                    JUMP TABLE EXECUTION
----------------------------------------------------------
    INFO: JUMPS TO AN ADDRESS GIVEN A TABLE ADDRESS AND OFFSET
    INPUT: HL - TABLE ADDRESS, A - OFFSET
    OUTPUT: NONE
    USES: HL, AF
*/
.ORG $0028
.SECTION "Jump Table Execution" FORCE
jumpTableExec:
    ADD A, A
    addToHL_M
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    JP (HL)
    .DSB $05, $00   ; FILL
.ENDS


/*
----------------------------------------------------------
                VDP VECTOR (VBLANK/HBLANK)
----------------------------------------------------------
*/
.ORG $0038
.SECTION "VDP Vector" FORCE
vdpIntHandler:
;   SAVE REGS (INDEX REGS DON'T NEED SAVING)
    PUSH AF
    EXX     ; BC, DE, HL -> BC', DE', HL'
;
    LD C, VDPCON_PORT
;   CHECK IF VBLANK OCCURED
    IN A, (VDPCON_PORT)
    OR A
    JP P, lineIntHandler    ; IF NOT, HANDLE LINE INTERRUPT
;   SET VBLANK FLAG
    LD (vblankFlag), A
;   SET SCROLL RELATED REGS IF GAME IS JR
    LD A, (enableScroll)
    OR A
    JP Z, @end
    ; SET LINE COUNTER
    LD HL, $8A07
    OUT (C), L
    OUT (C), H
    ; RESET H-SCROLL
    LD HL, $8800
    OUT (C), L
    OUT (C), H
    ; TURN ON H-BLANK INTS
    LD HL, $8034
    OUT (C), L
    OUT (C), H
@end:
;   RESTORE REGS
    EXX     ; BC', DE', HL' -> BC, DE, HL
    POP AF
;   ENABLE INTERRUPTS AND RETURN
    EI 
    RET
.ENDS

/*
----------------------------------------------------------
                    PAUSE VECTOR
----------------------------------------------------------
*/
.ORG $0066
.SECTION "pauseVector" FORCE
pauseVector:
;   SAVE REGS
    PUSH AF
;   CHECK IF STATE IS GAMEPLAY
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    JR NZ, @end ; IF NOT, DON'T DO ANYTHING
;   CHECK IF SUBSTATE IS ONE WHERE PLAYER IS IN CONTROL
    LD A, (subGameMode)
    CP A, GAMEPLAY_NORMAL
    JR C, @end  ; IF NOT, END
    CP A, GAMEPLAY_DEAD00
    JR NC, @end ; IF NOT, END
;   UPDATE PAUSE STATUS
    LD A, (pauseRequest)
    INC A
    LD (pauseRequest), A
@end:
;   RESTORE REGS
    POP AF
;   RETURN FROM NMI
    RETN
.ENDS



/*
----------------------------------------------------------
                    MAIN PROGRAM START
----------------------------------------------------------
*/
.SECTION "Main Init. and Loop" FORCE
main:
;   TURN OFF SCREEN (AND DISABLE VDP INTS)
    CALL turnOffScreen
;   WAIT FOR VBLANK
    CALL waitForVblank
;   CLEAR CRAM
    LD HL, $0000 | CRAMWRITE
    RST setVDPAddress
    ; WRITE ZEROS TO CRAM
    LD BC, CRAM_SIZE * $100 + VDPDATA_PORT
-:
    OUT (C), L  ; L IS $00
    DJNZ -
;   CLEAR VRAM
    LD HL, $0000 | VRAMWRITE
    RST setVDPAddress
    ; WRITE ZEROS TO VRAM
    LD BC, VRAM_SIZE    ; 16KB COUNTER
    XOR A               ; DATA VALUE
-:
    OUT (VDPDATA_PORT), A
    CPI         ; DECREMENTS BC
    JP PE, -    ; P/V IS CLEARED WHEN BC OVERFLOWS
;   INITIALIZE VDP REGISTERS
    LD HL, vdpInitData
    LD BC, _sizeof_vdpInitData * $100 + VDPCON_PORT
    OTIR
;   CREATE SPECIAL PRIORITY TILE AT INDEX $FF
    LD HL, BACKGROUND_ADDR + (MASK_TILE * TILE_SIZE) | VRAMWRITE
    RST setVDPAddress
    ; WRITE 32 BYTES OF $FF ($0F INDEX)
    LD B, TILE_SIZE
    LD A, $FF
-:
    OUT (VDPDATA_PORT), A
    DJNZ -
;   MAPPER INIT.
    LD DE, MAPPER_RAM
    LD HL, mapperInitValues
    LD BC, _sizeof_mapperInitValues
    LDIR
/*
----------------------------------------------------------
                    GAME INITIALIZATION
----------------------------------------------------------
*/
;   CHECK FOR MD CONTROLLER IN PORT 1
    LD HL, mdControlFlag
    LD (HL), $00    ; CLEAR FLAG (ASSUME NO MD CONTROLLER)
    ; SET TH TO LOW OUTPUT
    LD A, ~($01 << P1_TH_DIR | $01 << P2_TH_DIR) & $0F
    OUT (IO_CONTROL), A
    ; GET INPUTS (UP, LEFT, *DOWN, *RIGHT, A, START)
    LD A, (IX + 0)  ; TIME WASTE
    IN A, CONTROLPORT1
    CPL
    ; CHECK IF LEFT AND RIGHT ARE PRESSED
    AND A, $01 << P1_DIR_LEFT | $01 << P1_DIR_RIGHT
    ; SET TH TO LOW INPUT
    LD A, $01 << P1_TR_DIR | $01 << P1_TH_DIR | $01 << P2_TR_DIR | $01 << P2_TH_DIR
    OUT (IO_CONTROL), A
    JR Z, +         ; IF BOTH DIRECTIONS ARE NOT PRESSED, SKIP
    INC (HL)        ; ELSE, SET FLAG
+:
;   CHECK IF RAM MATCHES SECRET VARIABLE
    ; 1ST WORD
    LD DE, RESET_WORD_0
    LD HL, (resetSig)
    XOR A       ; CLEAR CARRY
    SBC HL, DE
    JR NZ, coldBoot         ; IF NO MATCH, ASSUME COLD BOOT
    ; 2ND WORD
    LD DE, RESET_WORD_1
    LD HL, (resetSig + 2)
    SBC HL, DE
    JR Z, resetFromGameOver ; IF MATCH, DON'T RESET OPTIONS AND HIGH SCORE
coldBoot:
;   WRITE RESET WORD
    LD HL, RESET_WORD_0
    LD (resetSig), HL
    LD HL, RESET_WORD_1
    LD (resetSig + 2), HL
;   OPTIONS (DEFAULT VALUES)
    LD A, $03           ; 3 LIVES
    LD (startingLives), A
    LD HL, $0000        ; BONUS AT 10K
    LD (bonusValue), HL
    LD A, $01
    LD (bonusValue + 2), A
    XOR A
    LD (normalFlag), A  ; NORMAL DIFFICULTY
    LD (speedUpFlag), A ; NO SPEED UP
;   SET OPTION IDS
    LD A, $02           ; 0 - 1UP, 1 - 2UP, 2 - 3UP, 3 - 5UP
    LD (liveIndex), A
    XOR A
    LD (diffIndex), A   ; 0 - NORMAL, 1 - HARD
    LD (bonusIndex), A  ; 0 - 10K, 1 - 15K, 2 - 20K, 3 - OFF
    LD (speedIndex), A  ; 0 - NORMAL, 1 - FAST
    LD (styleIndex), A  ; 0 - SMOOTH, 1 - ARCADE
;   RESET HIGH SCORE
    LD (highScore), A
    LD (highScore + 1), A
    LD (highScore + 2), A
;   PLUS
    LD (plusBitFlags), A
;   TASK
    LD HL, taskListArea
    LD (taskListEnd), HL
;   JR (POWER DOT SELECTOR FOR FRUIT IS ONLY RESET AT COLD BOOT)
    LD (fruitPathPtr + 1), A    ; POWER DOT SELECTOR [$4931]
resetFromGameOver:
;   CLEAR INVISIBLE MAZE FLAG (PLUS)
    LD HL, plusBitFlags
    LD A, ~($01 << INVISIBLE_MAZE)
    AND A, (HL)
    LD (HL), A
    XOR A
;   SET MENU VARS
    LD HL, prevInput            ; ALL BUTTONS ARE "PRESSED" FOR PREVIOUS INPUT
    LD (HL), $01 << P1_DIR_UP | $01 << P1_DIR_DOWN | $01 << P1_DIR_LEFT | $01 << P1_DIR_RIGHT | $01 << P1_BTN_1 | $01 << P1_BTN_2
    LD (pressedButtons), A      ; BUTTONS THAT JUST WERE PRESSED
    LD HL, prevInputMD            ; ALL BUTTONS ARE "PRESSED" FOR PREVIOUS INPUT
    LD (HL), $01 << P1_DIR_UP | $01 << P1_DIR_DOWN | $01 << P1_DIR_LEFT | $01 << P1_DIR_RIGHT | $01 << P1_BTN_1 | $01 << P1_BTN_2
    LD (pressedButtonsMD), A      ; BUTTONS THAT JUST WERE PRESSED
;   RESET PLAYER TYPE
    LD (playerType), A          ; 1 PLAYER MODE, PLAYER 1 IS PLAYING
;   RESET SCORE
    LD (currPlayerInfo.score + 2), A
    LD (currPlayerInfo.score + 1), A
    LD (currPlayerInfo.score), A
resetFromDemo:
;   RESET VBLANK AND PAUSE FLAGS
    XOR A
    LD (sprFlickerControl), A
    LD (vblankFlag), A
    LD (pauseRequest), A
    LD (plusRNGValue), A
    LD (jrScrollReal), A
    LD (enableScroll), A
;   RESET SOUND VARS
    CALL sndInit
;   SET MAIN STATE TO ATTRACT MODE, SET SUB TO TITLE
    LD HL, ATTRACT_TITLE * $100 + M_STATE_ATTRACT
    LD (mainGameMode), HL
;   NEW STATE
    LD A, $01
    LD (isNewState), A
;   ENABLE INTERRUPTS
    IN A, (VDPCON_PORT)
    EI


/*
----------------------------------------------------------
                    MAIN GAME LOOP
----------------------------------------------------------
*/
mainGameLoop:
;   WAIT FOR VBLANK
    HALT
    ; CHECK IF VBLANK FLAG IS SET
    LD A, (vblankFlag)
    OR A
    JP P, mainGameLoop      ; IF NOT, KEEP WAITING...
;   VBLANK HAS OCCURED, CLEAR FLAG
    XOR A
    LD (vblankFlag), A
;   GET INPUT
    ; PLAYER 1 / SOME OF PLAYER 2
    IN A, CONTROLPORT1
    CPL         ; INVERT SO 1 = PRESSED, 0 = NO PRESS
    LD (controlPort1), A
    ; REST OF PLAYER 2
    IN A, CONTROLPORT2
    CPL
    LD (controlPort2), A
;   CHECK FOR RESET
    AND A, $01 << RESET_BTN
    JP NZ, resetGame    ; IF SO, RESET THE GAME
;   CHECK IF START WAS PRESSED (MD CONTROLLER)
    LD A, (mdControlFlag)
    OR A
    CALL NZ, checkMDPause
;   CHECK PAUSE
    LD A, (pauseRequest)
    OR A
    JP NZ, pauseMode    ; IF PASUE BUTTON WAS PRESSED (AND HONORED), SWITCH TO PAUSE "MODE"
;   UPDATE RNG VALUE (USED IN PLUS)
    ; RNG = RNG * 5 + 1
    LD HL, plusRNGValue
    LD A, (HL)
    ADD A, A
    ADD A, A
    ADD A, (HL)
    INC A
    LD (HL), A
;   MAIN STATE MACHINE
    ; GET MAIN STATE'S TABLE
    LD HL, mStateTable
    LD A, (mainGameMode)
    ADD A, A
        ; USE MODE AS INDEX
    addToHL_M
        ; GET SUB STATE TABLE
    LD A, (HL)
    INC HL
    LD H, (HL)
    LD L, A
    ; EXECUTE SUB STATE'S FUNCTION
    LD A, (subGameMode)
    RST jumpTableExec
;   UPDATE JR PAC SCROLL
    LD A, (enableScroll)
    OR A
    CALL NZ, updateJRScroll
;   TASK PROCESSING (RETURN FROM INT IN OG)
    ; CHECK IF TASK LIST IS EMPTY
    LD HL, (taskListEnd)
    LD DE, taskListArea
    OR A
    SBC HL, DE
    JR Z, +     ; IF SO, SKIP...
-:
    ; GET TASK ID, INCREMENT TASK START
    LD A, (DE)
    INC DE
    PUSH DE ; SAVE
    ; DO TASK
    LD HL, taskListTable
    RST jumpTableExec
    ; CHECK IF ALL TASKS ARE DONE
    POP DE  ; RESTORE
    OR A    ; CLEAR CARRY
    LD HL, (taskListEnd)
    SBC HL, DE
    JR NZ, -
    ; RESET TASK START PTR
    LD HL, taskListArea
    LD (taskListEnd), HL
+:
;   DO SOUND PROCESSING
    CALL sndProcess
;   SPRITE FLICKER CODE
    LD A, (sprFlickerControl)
    OR A
    JP Z, mainGameLoop
    LD A, (clyde.sprTableNum)
    LD B, A
    LD A, (fruit + Y_WHOLE)
    OR A
    JP Z, +
    LD A, (fruit.sprTableNum)
    LD B, A
    LD A, (clyde.sprTableNum)
    LD (fruit.sprTableNum), A
+:
    LD A, (inky.sprTableNum)
    LD (clyde.sprTableNum), A
    LD A, (pinky.sprTableNum)
    LD (inky.sprTableNum), A
    LD A, (blinky.sprTableNum)
    LD (pinky.sprTableNum), A
    LD A, B
    LD (blinky.sprTableNum), A
    JP mainGameLoop
.ENDS

/*
----------------------------------------------------------
                    PAUSE "MODE"
----------------------------------------------------------
*/
.SECTION "Pause Mode and Related Functions" FORCE
pauseMode:
;   PAUSE REQUEST PROCESSING
    LD A, (pauseRequest)
    ; CHECK IF BIT 1 OF PAUSE REQUEST IS SET (IF BUTTON WAS PRESSED DURING PAUSE)
    BIT UNPAUSE_REQ, A
    JR NZ, @exit    ; IF SO, THEN EXIT
    ; CHECK IF BIT 2 IS SET   (IF THIS MODE IS NOT NEW)
    BIT NEW_PAUSE, A
    JR NZ, @update  ; IF SO, SKIP TRANSITION CODE
@enter:
    ; SET BIT 2 (MODE ISN'T NEW)
    OR A, $01 << NEW_PAUSE
    LD (pauseRequest), A
@update:
;   DO SOUND PROCESSING
    CALL sndProcess
;   UPDATE 'PAUSE' TILEMAP AREA
    ; PREPARE VDP ADDRESS
    LD HL, NAMETABLE + XUP_TEXT | VRAMWRITE
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JR Z, +
    LD HL, NAMETABLE + XUP_TEXT_JR | VRAMWRITE
+:
    LD C, VDPCON_PORT
    OUT (C), L
    OUT (C), H
    DEC C
    ; INCREMENT "PAUSE" FLASH COUNTER
    LD HL, xUPCounter
    INC (HL)
    ; CHECK IF BIT 4 OF FLASH COUNTER IS SET (CYCLES EVERY 16 FRAMES)
    BIT 4, (HL)
    JR NZ, @@clrPause   ; IF SO, CLEAR 'PAUSE'
    ; DISPLAY "PAUSE" TILES (5 TILES)
    LD HL, hudTileMaps@pause
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    IN F, (C)
    OUTI
    JP mainGameLoop
@@clrPause:
    LD A, MASK_TILE
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    ; DRAW PLAYER'S SCORE IF GAME IS JR.PAC
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    CALL NZ, scoreTileMapDraw
    JP mainGameLoop
@exit:
;   CLEAR VARIABLES
    XOR A
    LD (pauseRequest), A
;   BLANK THE PAUSE TILES THAT OVERLAP THE SCORE IN JR.
    LD A, (plusBitFlags)
    AND A, $01 << JR_PAC
    JP NZ, mainGameLoop
    ; SET VDP ADDRESS
    LD C, VDPCON_PORT
    LD HL, NAMETABLE + XUP_TEXT + $06 | VRAMWRITE
    OUT (C), L
    OUT (C), H
    DEC C
    ; BLANK OUT TILES
    XOR A
    OUT (VDPDATA_PORT), A
    IN F, (C)
    OUT (VDPDATA_PORT), A
    JP mainGameLoop

/*
    FOR DETECTING START BUTTON PRESS ON MD CONTROLLER
*/
checkMDPause:
;   CHECK IF STATE IS GAMEPLAY
    LD A, (mainGameMode)
    CP A, M_STATE_GAMEPLAY
    RET NZ  ; IF NOT, DON'T DO ANYTHING
;   SET TH TO LOW OUTPUT
    LD A, ~($01 << P1_TH_DIR | $01 << P2_TH_DIR) & $0F
    OUT (IO_CONTROL), A
;   GET INPUTS (A, START)
    LD A, (IX + 0)  ; TIME WASTE
    IN A, CONTROLPORT1
    CPL
    LD (controlPort1MD), A
;   SET TH TO LOW INPUT
    LD A, $01 << P1_TR_DIR | $01 << P1_TH_DIR | $01 << P2_TR_DIR | $01 << P2_TH_DIR
    OUT (IO_CONTROL), A
;   DEBOUNCE
    CALL getPressedInputsMD
;   CHECK IF 'START' IS PRESSED
    LD A, (pressedButtonsMD)
    BIT P1_BTN_2, A
    RET Z   ; RETURN IF IT WASN'T
    ; CHECK IF 'A' IS PRESSED
    LD A, (controlPort1MD)
    AND A, $01 << P1_BTN_1
    JP Z, pauseVector   ; IF NOT, ONLY 'START' WAS PRESSED. PAUSE THE GAME
    ; CHECK IF 'B' AND 'C' ARE PRESSED
    LD A, (controlPort1)
    CP A, ($01 << P1_BTN_1) | ($01 << P1_BTN_2)
    RET NZ               ; IF NOT, EXIT
    ; RESET GAME
    JP resetGame
.ENDS
/*
----------------------------------------------------------
                LINE INTERRUPT HANDLER
----------------------------------------------------------
*/
.SECTION "LINE INTERRUPT HANDLER" FORCE
lineIntHandler:
;   DON'T NEED TO SET SCROLL AGAIN UNTIL NEXT VBLANK
;   CLEAR V COUNTER
    LD HL, $8AFF
    OUT (C), L
    OUT (C), H
;   LINE INTS OFF
    LD HL, $8024
    OUT (C), L
    OUT (C), H
;   WRITE SCROLL TO VDP
    LD A, (jrScrollReal)
    OUT (VDPCON_PORT), A
    LD A, $88
    OUT (VDPCON_PORT), A
    JP vdpIntHandler@end
.ENDS

/*
----------------------------------------------------------
                    MAIN STATE TABLE
----------------------------------------------------------
*/
.SECTION "mainStateTable" FORCE
    mStateTable:
        .DW sStateAttractTable
        .DW sStateGameplayTable
        .DW sStateCutsceneTable
.ENDS


/*
----------------------------------------------------------
                ATTRACT SUB STATE CODE
----------------------------------------------------------
*/
.INCDIR "CODE/ATTRACT"
.SECTION "Attract Sub States" FORCE
    .INCLUDE "attractStateTable.asm"
.ENDS


/*
----------------------------------------------------------
                GAMEPLAY SUB STATE CODE
----------------------------------------------------------
*/
.INCDIR "CODE/GAMEPLAY"
.SECTION "Gameplay Sub States" FORCE
    .INCLUDE "gameplayStateTable.asm"
.ENDS

/*
----------------------------------------------------------
                CUTSCENE SUB STATE CODE
----------------------------------------------------------
*/
.INCDIR "CODE/CUTSCENE"
.SECTION "Cutscene Sub States" FORCE
    .INCLUDE "cutsceneStateTable.asm"
.ENDS

/*
----------------------------------------------------------
            COMMON FUNCTIONS USED BY GAME
----------------------------------------------------------
*/
.INCDIR "CODE/COMMON"
.SECTION "Common Game Functions" FORCE
    .INCLUDE "updates.asm"
    .INCLUDE "ghosts.asm"
    .INCLUDE "fruit.asm"
    .INCLUDE "collision.asm"
    .INCLUDE "draw.asm"
    .INCLUDE "sound.asm"
    .INCLUDE "plus.asm"
    .INCLUDE "mspac.asm"
    .INCLUDE "misc.asm"
    .INCLUDE "assetLoading.asm"
.ENDS

/*
----------------------------------------------------------
                GENERAL SPRITE FUNCTIONS
----------------------------------------------------------
*/
.INCDIR "CODE"
.SECTION "General Sprite Functions" FORCE
    .INCLUDE "sprite.asm"
.ENDS

/*
----------------------------------------------------------
                GENERAL ACTOR FUNCTIONS
----------------------------------------------------------
*/
.SECTION "General Actor Code" FORCE
    .INCLUDE "actor.asm"
.ENDS

/*
----------------------------------------------------------
            FUNCTIONS FOR PAC-MAN (PLAYER)
----------------------------------------------------------
*/
.INCDIR "CODE/PACMAN"
.SECTION "Pac-Man (Player) Code" FORCE
    .INCLUDE "pacman.asm"
.ENDS

/*
----------------------------------------------------------
                FUNCTIONS FOR GHOSTS
----------------------------------------------------------
*/
.INCDIR "CODE/GHOST"
.SECTION "Ghost Code" FORCE
    .INCLUDE "ghost.asm" 
.ENDS

/*
----------------------------------------------------------
                SMS HELPER FUNCTIONS
----------------------------------------------------------
*/
.INCDIR "CODE"
.SECTION "SMS-Related Helper Code" FORCE
    .INCLUDE "smsFunctions.asm"
.ENDS

/*
----------------------------------------------------------
                    MATH FUNCTIONS
----------------------------------------------------------
*/
.SECTION "Math Code" FORCE
    .INCLUDE "math.asm"
.ENDS


/*
----------------------------------------------------------
                DECOMPRESSION (ZX7)
----------------------------------------------------------
*/
.SECTION "Decompression Algorithm" FORCE
    .INCLUDE "decomp.asm"
.ENDS

/*
----------------------------------------------------------
                    SOUND DRIVER
----------------------------------------------------------
*/
.INCDIR "CODE/SOUND"
.SECTION "Sound Code" FORCE
    .INCLUDE "soundDriver.asm"
.ENDS


/*
----------------------------------------------------------
                ATTRACT SUB STATE DATA
----------------------------------------------------------
*/
.INCDIR "CODE/ATTRACT"
.SECTION "Attract Mode Data" FORCE
    .INCLUDE "attractData.asm"
.ENDS

/*
----------------------------------------------------------
                CUTSCENE SUB STATE DATA
----------------------------------------------------------
*/
.INCDIR "CODE/CUTSCENE"
.SECTION "Cutscene Mode Data" FORCE
    .INCLUDE "cutsceneData.asm"
.ENDS

.SECTION "CUTSCENE COMMAND DATA (MS/JR)" BANK CUTSCENE_DATA_BANK SLOT 2 FREE
    .INCLUDE "commandData.asm"
.ENDS


/*
----------------------------------------------------------
DATA FOR PAC-MAN (PLAYER) AND GENERAL ACTOR [BANK2 OR CODEBANK]
----------------------------------------------------------
*/
.INCDIR "CODE/PACMAN"
.SECTION "Pac-Man (Player) Data" FORCE
    .INCLUDE "pacmanData.asm"
.ENDS

/*
----------------------------------------------------------
            DATA FOR GHOSTS [BANK2 OR CODEBANK]
----------------------------------------------------------
*/
.INCDIR "CODE/GHOST"
.SECTION "Ghost Data" FORCE
    .INCLUDE "ghostData.asm" 
.ENDS


/*
----------------------------------------------------------
                    SOUND DATA
----------------------------------------------------------
*/
.INCDIR "CODE/SOUND"
.SECTION "Sound Data" BANK SOUND_BANK SLOT 2 FREE
    .INCLUDE "soundData.asm"
.ENDS


/*
----------------------------------------------------------
                    SDSC HEADER TAGS
----------------------------------------------------------
*/
.SECTION "SDSC TAGS" FREE
sdscName:
    .DB "Pac-Man Master Museum", 0
sdscDesc:
    .DB "A conversion of arcade classics for the Sega Master System", 0
sdscAuth:
    .DB "LackofTrack", 0
.ENDS

/*
----------------------------------------------------------
                VDP AND MAPPER DATA
----------------------------------------------------------
*/
.SECTION "VDP AND MAPPER DATA" FREE
;   MAPPER INIT. DATA
mapperInitValues:
    .DB $00 $00 $01 $02

;   VDP REGISTER INITIALIZATION DATA
vdpInitData:
    .db $24         ; ENABLE MODE 4 AND HIDE LEFTMOST 8 PIXELS
    .db $80         ; FOR REG 00 (MODE CONTROL 1)
    ;----------------------
    .db $A0         ; ENABLE FRAME INTERRUPTS AND SET BIT 7...
    .db $81         ; FOR REG 01 (MODE CONTROL 2)
    ;----------------------
    .DB (hibyte(NAMETABLE) >> $02) | $01    ; VRAM NAME TABLE AT $0000...
    .db $82         ; FOR REG 02 (NAME TABLE BASE ADDR)
    ;----------------------
    .db $FF         ; VRAM COLOR TABLE BASE ADDR (NORMAL OPERATION)
    .db $83         ; FOR REG 03 (COLOR TABLE BASE ADDR)
    ;----------------------
    .db $FF         ; PATTERN GEN. TABLE BASE ADDR (NORMAL OPERATION)
    .db $84         ; FOR REG 04 (PATTERN GEN. TABLE BASE ADDR)
    ;----------------------
    .DB (hibyte(SPRITE_TABLE) << $01) | $01 ; SPRITE ATTR. TABLE AT $0600...
    .db $85         ; FOR REG 05 (SAT BASE ADDR)
    ;----------------------
    .db $FB         ; SPRITE PATTERN GENERATOR TABLE AT $0000 (256 SPRITE LIMIT)
    .db $86         ; FOR REG 06 (SPRITE PAT. GENERATOR TABLE BASE ADDR)
    ;----------------------
    .db $00         ; COLOR 0 FROM SPRITE PALETTE (BLACK)...
    .db $87         ; FOR REG 07 (OVERSCAN/BACKDROP COLOR)
    ;----------------------
    .db $00         ; NO X SCROLL...
    .db $88         ; FOR REG 08 (BACKGROUND X SCROLL)
    ;----------------------
    .db $00         ; NO Y SCROLL...
    .db $89         ; FOR REG 09 (BACKGROUND Y SCROLL)
    ;----------------------
    .db $FF         ; DISABLE LINE COUNTER...
    .db $8A         ; FOR REG 0A (LINE COUNTER)


/*
    BACKGROUND PALETTE LISTING
    $00 - TRANSPARENT (BLACK)
    $01 - MAZE 0 (WALLS)
    $02 - MAZE 1 (INSIDE)
    $03 - MAZE 2 (SHADING)
    $04 - MAZE 3 (SHADING)
    $05 - MAZE 4 (SHADING)
    $06 - MAZE 5 (GHOST GATE)
    $07 - DOT 0
    $08 - DOT 1
    $09 - DOT 2
    $0A - POWER DOT 0
    $0B - POWER DOT 1
    $0C - POWER DOT 2
    $0D - POWER DOT 3
    $0E - HUD TEXT (WHITE)
    $0F - SPRITE MASK (BLACK)
*/
;   MAZE BACKGROUND PALETTES
bgPalPac:
    .DB $00 $30 $00 $20 $20 $00 $3B $2B $00 $00 $16 $2B $2B $2B $3F $00
bgPalPlus:
    .DB $00 $29 $00 $14 $14 $00 $3B $2B $00 $00 $16 $2B $2B $2B $3F $00
;   ----
bgPalMs00:
    .DB $00 $03 $2B $02 $02 $00 $3B $3F $00 $00 $2A $3F $3F $3F $3F $00
bgPalMs01:
    .DB $00 $3F $38 $2A $2A $00 $3B $0F $00 $00 $0A $0F $0F $0F $3F $00
bgPalMs02:
    .DB $00 $3F $1B $2A $2A $00 $3B $03 $00 $00 $02 $03 $03 $03 $3F $00
bgPalMs03:
    .DB $00 $1B $30 $06 $06 $00 $3B $3F $00 $00 $2A $3F $3F $3F $3F $00
bgPalMs04:
    .DB $00 $0F $3B $0A $0A $00 $3B $3C $00 $00 $28 $3C $3C $3C $3F $00
bgPalMs05:  ; PLUS
    .DB $00 $3C $30 $28 $28 $00 $3B $3F $00 $00 $2A $3F $3F $3F $3F $00
bgPalMs06:  ; PLUS
    .DB $00 $2F $06 $1A $1A $00 $3B $0F $00 $00 $0A $0F $0F $0F $3F $00
bgPalMs07:  ; PLUS
    .DB $00 $3F $36 $2A $2A $00 $3B $0F $00 $00 $0A $0F $0F $0F $3F $00
bgPalMs08:  ; PLUS
    .DB $00 $06 $03 $01 $01 $00 $3B $3F $00 $00 $2A $3F $3F $3F $3F $00
bgPalMs09:  ; PLUS
    .DB $00 $06 $3F $01 $01 $00 $3B $36 $00 $00 $21 $36 $36 $36 $3F $00
    ;   ----
bgPalJr00:
    .DB $00 $0B $30 $06 $06 $00 $00 $2B $0A $05 $16 $2B $2B $2B $0F $00
bgPalJr01:
    .DB $00 $39 $06 $24 $24 $00 $00 $0F $0A $05 $0A $0F $0F $0F $0F $00
bgPalJr02:
    .DB $00 $0B $39 $06 $06 $00 $00 $0F $0A $05 $0A $0F $0F $0F $0F $00
bgPalJr03:
    .DB $00 $0F $04 $0A $0A $00 $00 $3F $0A $05 $2A $3F $3F $3F $0F $00
bgPalJr04:
    .DB $00 $3C $30 $28 $28 $00 $00 $3F $0A $05 $2A $3F $3F $3F $0F $00
bgPalJr05:  ; PLUS
    .DB $00 $3B $06 $26 $26 $00 $00 $2B $0A $05 $16 $2B $2B $2B $0F $00
bgPalJr06:  ; PLUS
    .DB $00 $3C $0A $28 $28 $00 $00 $3F $0A $05 $2A $3F $3F $3F $0F $00
bgPalJr07:  ; PLUS
    .DB $00 $0F $05 $0A $0A $00 $00 $3B $0A $05 $26 $3B $3B $3B $0F $00
bgPalJr08:  ; PLUS
    .DB $00 $03 $30 $02 $02 $00 $00 $3F $0A $05 $2A $3F $3F $3F $0F $00
bgPalJr09:  ; PLUS
    .DB $00 $0B $03 $06 $06 $00 $00 $0F $0A $05 $0A $0F $0F $0F $0F $00

;   JR CUTSCENE PALETTES
bgPalJrFD:
    .DB $00 $04 $05 $15 $02 $0C $0A $0B $30 $2A $0F $3F $3F $3F $3F $00
bgPalJrFE:
    .DB $00 $04 $05 $15 $02 $0C $0A $0B $01 $0F $2A $3F $3F $3F $3F $00

; SPRITE PALETTE ("SMOOTH")
sprPalData:
    .db $00     ; BLACK (TRANSPARENT)
    .db $0F     ; YELLOW (PAC-MAN)
    .db $0A     ; DARK YELLOW (SHADING)
    .db $03     ; RED (BLINKY)
    .db $02     ; DARK RED (SHADING)
    .db $3B     ; PINK (PINKY)
    .db $26     ; DARK PINK (SHADING)
    .db $3C     ; CYAN (INKY)
    .db $28     ; DARK CYAN (SHADING)
    .db $0B     ; ORANGE (CLYDE)
    .db $06     ; DARK ORANGE (SHADING)
    .db $3F     ; WHITE (SCARED GHOST)
    .db $2A     ; GREY (SHADING)
    .db $30     ; BLUE (SCARED GHOST)
    .db $20     ; DARK BLUE (SHADING)
    .db $0C     ; GREEN (FRUIT)

; SPRITE PALETTE ("ARCADE")
@arcade:
    .db $00 $0F $2F $03 $38 $3B $2B $3C $39 $0B $06 $3F $28 $30 $36 $0C
.ENDS



/*
----------------------------------------------------------
                        TILEMAPS
----------------------------------------------------------
*/
.SECTION "VARIOUS TILEMAPS" FREE
/*
    HUD TILEMAPS
*/
hudTileMaps:
@highScore:
;   "HIGH "
;   "SCORE"
    .DW $11EA, $11EB, $11EC, $11EA, $1100 | MASK_TILE
    .DW $11ED, $11EE, $11EF, $11F0, $11F1
@oneUP:
;   "1UP"
    .DB $F6 $F2 $F3
@twoUP:
;   "2UP"
    .DB $F7 $F2 $F3
@pause:
;   "PAUSE"
    .DB $F3 $F4 $F2 $ED $F1
@jroneUP:
;   "1UP"
    .DB $F6 $F3 MASK_TILE
@jrtwoUP:
;   "2UP"
    .DB $F7 $F3 MASK_TILE
@jrPlayerOne:
    .DW $01C0 $01C1 $01C2 $01C3 $01C4 $01C5 $01CB $01CC $01CD
    .DW $01C6 $01C7 $01C8 $01C9 $01CA       $01CE $01CF $01D0
@jrPlayerTwo:
    .DW $01C0 $01C1 $01C2 $01C3 $01C4 $01C5 $01D1 $01D2 $01CD
    .DW $01C6 $01C7 $01C8 $01C9 $01CA       $01D3 $01D4 $01D5
@jrReady:
    .DW $00F5 $00F6 $00F7 $00F8 $00F9
@jrGameover:
    .DW $00FA $00FB $00FC       $00FD $00FE $00FF

hudLifeTileDefs:
    .DW $19DC $19DE $19DD $19DF

/*
    TABLE FOR POSITIONS OF LIVES IN HUD
*/
lifePositionTable:
;   TERMINATION WORDS FOR TABLE
    .DW $FFFF
    .DW $FFFF
;   LIFE 1
    ; TOP
    .DW NAMETABLE + (29 * 2) + (21 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (29 * 2) + (22 * 64) | VRAMWRITE
;   LIFE 2
    ; TOP
    .DW NAMETABLE + (27 * 2) + (21 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (27 * 2) + (22 * 64) | VRAMWRITE
;   LIFE 3
    ; TOP
    .DW NAMETABLE + (25 * 2) + (21 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (25 * 2) + (22 * 64) | VRAMWRITE
;   LIFE 4
    ; TOP
    .DW NAMETABLE + (29 * 2) + (19 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (29 * 2) + (20 * 64) | VRAMWRITE
;   LIFE 5
    ; TOP
    .DW NAMETABLE + (27 * 2) + (19 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (27 * 2) + (20 * 64) | VRAMWRITE


/*
    TABLE FOR POSITIONS OF FRUIT IN HUD
*/
fruitPositionTable:
;   TERMINATION WORDS FOR TABLE
    .DW $FFFF
    .DW $FFFF
;   FRUIT 01
    ; TOP
    .DW NAMETABLE + (29 * 2) + (15 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (29 * 2) + (16 * 64) | VRAMWRITE
;   FRUIT 02
    ; TOP
    .DW NAMETABLE + (27 * 2) + (15 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (27 * 2) + (16 * 64) | VRAMWRITE
;   FRUIT 03
    ; TOP
    .DW NAMETABLE + (25 * 2) + (15 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (25 * 2) + (16 * 64) | VRAMWRITE
;   FRUIT 04
    ; TOP
    .DW NAMETABLE + (29 * 2) + (13 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (29 * 2) + (14 * 64) | VRAMWRITE
;   FRUIT 05
    ; TOP
    .DW NAMETABLE + (27 * 2) + (13 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (27 * 2) + (14 * 64) | VRAMWRITE
;   FRUIT 06
    ; TOP
    .DW NAMETABLE + (25 * 2) + (13 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (25 * 2) + (14 * 64) | VRAMWRITE
;   FRUIT 07
    ; TOP
    .DW NAMETABLE + (29 * 2) + (11 * 64) | VRAMWRITE
    ; BOTTOM
    .DW NAMETABLE + (29 * 2) + (12 * 64) | VRAMWRITE
.ENDS


/*
----------------------------------------------------------
                SQUARED VALUES TABLE
----------------------------------------------------------
*/
.SECTION "SQUARED VALUES TABLE" FORCE ORG $7E00
squareTable:
    .DW $0000 $0001 $0004 $0009 $0010 $0019 $0024 $0031 $0040 $0051 $0064 $0079 $0090 $00A9 $00C4 $00E1 
    .DW $0100 $0121 $0144 $0169 $0190 $01B9 $01E4 $0211 $0240 $0271 $02A4 $02D9 $0310 $0349 $0384 $03C1 
    .DW $0400 $0441 $0484 $04C9 $0510 $0559 $05A4 $05F1 $0640 $0691 $06E4 $0739 $0790 $07E9 $0844 $08A1 
    .DW $0900 $0961 $09C4 $0A29 $0A90 $0AF9 $0B64 $0BD1 $0C40 $0CB1 $0D24 $0D99 $0E10 $0E89 $0F04 $0F81 
    .DW $1000 $1081 $1104 $1189 $1210 $1299 $1324 $13B1 $1440 $14D1 $1564 $15F9 $1690 $1729 $17C4 $1861 
    .DW $1900 $19A1 $1A44 $1AE9 $1B90 $1C39 $1CE4 $1D91 $1E40 $1EF1 $1FA4 $2059 $2110 $21C9 $2284 $2341 
    .DW $2400 $24C1 $2584 $2649 $2710 $27D9 $28A4 $2971 $2A40 $2B11 $2BE4 $2CB9 $2D90 $2E69 $2F44 $3021 
    .DW $3100 $31E1 $32C4 $33A9 $3490 $3579 $3664 $3751 $3840 $3931 $3A24 $3B19 $3C10 $3D09 $3E04 $3F01
.ENDS
/*
----------------------------------------------------------
                COLOR CALCULATION TABLES
----------------------------------------------------------
*/
;   $E0
.SECTION "COLOR TABLES FOR POWER DOTS" FORCE ORG $7F00
colorDecTable:  ; $00
    .DB $00 $00 $01 $02 $00 $00 $01 $02
    .DB $04 $04 $05 $06 $08 $08 $09 $0A
    .DB $00 $00 $01 $02 $00 $00 $01 $02
    .DB $04 $04 $05 $06 $08 $08 $09 $0A
    .DB $10 $10 $11 $12 $10 $10 $11 $12
    .DB $14 $14 $15 $16 $18 $18 $19 $1A
    .DB $20 $20 $21 $22 $20 $20 $21 $22
    .DB $24 $24 $25 $26 $28 $28 $29 $2A
@decBy2:        ; $40
    .DB $00 $00 $00 $01 $00 $00 $00 $01
    .DB $00 $00 $00 $01 $04 $04 $04 $05
    .DB $00 $00 $00 $01 $00 $00 $00 $01
    .DB $00 $00 $00 $01 $04 $04 $04 $05 
    .DB $00 $00 $00 $01 $00 $00 $00 $01 
    .DB $00 $00 $00 $01 $04 $04 $04 $05 
    .DB $10 $10 $10 $11 $10 $10 $10 $11 
    .DB $10 $10 $10 $11 $14 $14 $14 $15
/*
    COLOR TABLE FOR POWER DOT PALETTE CYCLING
*/
powDotPalTable: ; $80
    .DB $02 $01 $00 $00
    .DB $03 $02 $01 $00
    .DB $03 $03 $02 $01
    .DB $03 $03 $03 $02
    .DB $03 $03 $03 $03
    .DB $03 $03 $03 $02
    .DB $03 $03 $02 $01
    .DB $03 $02 $01 $00
    .DB $02 $01 $00 $00


/*
    MULT TABLE FOR X * 29 (FOR JR.PAC)
*/
mult29Table:
    .DW $0000 $001D $003A $0057 $0074 $0091 $00AE $00CB $00E8 $0105 $0122 $013F $015C $0179 $0196 $01B3 
    .DW $01D0 $01ED $020A $0227 $0244 $0261 $027E $029B $02B8 $02D5 $02F2 $030F $032C $0349 ;$0366 $0383 
.ENDS

/*
----------------------------------------------------------
                    COMMON TABLES
----------------------------------------------------------
*/

.SECTION "COMMON TABLES" FREE
/*
    PLAYER ANIMATION TABLES
*/
normAniTbl: ; $A4
    .DB $00 $00 $08 $08 $10 $10 $18 $18 $00 $00 $08 $08 $10 $10 $18 $18
slowAniTbl: ; $B4
    .DB $00 $00 $00 $00 $08 $08 $08 $08 $10 $10 $10 $10 $18 $18 $18 $18

/*
    GHOST POINTS TILE INDEXES
*/
.MACRO ghostPointsDefs   ARGS VAL
    .DB VAL, VAL+$05        ; 200
    .DB VAL+$01, VAL+$05    ; 400
    .DB VAL+$02, VAL+$05    ; 800
    .DB VAL+$03, VAL+$06    ; 1600
    .DB VAL+$04, VAL+$07    ; 3200
.ENDM
ghostPointTileDefs:
    ghostPointsDefs (SPRITE_ADDR + GSCORE_VRAM) / TILE_SIZE


/*
    GHOST POINTS SCORE TABLE
*/
ghostScoreTable:
    .DW $0200   ; 200
    .DW $0400   ; 400
    .DW $0800   ; 800
    .DW $1600   ; 1600
    .DW $3200   ; 3200


/*
    FRUIT AND SCORE INDEX (PAC-MAN ONLY)
*/
fruitTable:
    .DB $00 $00
    .DB $01 $01
    .DB $02 $02
    .DB $02 $02
    .DB $04 $03
    .DB $04 $03
    .DB $05 $04
    .DB $05 $04
    .DB $06 $05
    .DB $06 $05
    .DB $03 $06
    .DB $03 $06
    .DB $07 $07
    .DB $07 $07
    .DB $07 $07
    .DB $07 $07
    .DB $07 $07
    .DB $07 $07
    .DB $07 $07
    .DB $07 $07


/*
    FRUIT TILE INDEXES
*/
.MACRO fruitSprDef  ARGS VAL
    .DB VAL, VAL+$10, VAL+$01, VAL+$11
.ENDM
fruitTileDefs:
    ; FRUIT 0
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE
    ; FRUIT 1
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $02
    ; FRUIT 2
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $04
    ; FRUIT 3
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $06
    ; FRUIT 4
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $08
    ; FRUIT 5
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $0A
    ; FRUIT 6
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $0C
    ; FRUIT 7
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $0E

msFruitTileDefsHUD:
    ; FRUIT 0
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE
    ; FRUIT 1
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $02
    ; FRUIT 2
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $04
    ; FRUIT 3
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $06
    ; FRUIT 4
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $08
    ; FRUIT 5
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $0E  ; PEAR FOR HUD
    ; FRUIT 6
    fruitSprDef (SPRITE_ADDR + FRUIT_VRAM) / TILE_SIZE + $0C



/*
    FRUIT POINT TILE INDEXES
*/
.MACRO fruitPointsDefs  ARGS, VAL
    .DB VAL, BLANK_TILE, VAL+$04, BLANK_TILE      ; 100
    .DB VAL+$01, BLANK_TILE, VAL+$04, BLANK_TILE  ; 300
    .DB VAL+$02, BLANK_TILE, VAL+$04, BLANK_TILE  ; 500
    .DB VAL+$03, BLANK_TILE, VAL+$04, BLANK_TILE  ; 700
    .DB VAL+$05, BLANK_TILE, VAL+$09, BLANK_TILE  ; 1000
    .DB VAL+$06, BLANK_TILE, VAL+$09, BLANK_TILE  ; 2000
    .DB VAL+$07, BLANK_TILE, VAL+$09, BLANK_TILE  ; 3000
    .DB VAL+$08, BLANK_TILE, VAL+$09, BLANK_TILE  ; 5000
.ENDM
fruitPointTileDefs:
    fruitPointsDefs     (SPRITE_ADDR + FSCORE_VRAM) / TILE_SIZE



.MACRO msFruitPointsDefs  ARGS, VAL
    .DB VAL, BLANK_TILE, VAL+$01, VAL+$09          ; 100
    .DB VAL+$02, BLANK_TILE, VAL+$01, VAL+$09      ; 200
    .DB VAL+$03, BLANK_TILE, VAL+$01, VAL+$09      ; 500
    .DB VAL+$04, BLANK_TILE, VAL+$01, VAL+$09      ; 700
    .DB VAL+$05, VAL+$0A, VAL+$06, VAL+$0B  ; 1000
    .DB VAL+$07, VAL+$0A, VAL+$06, VAL+$0B  ; 2000
    .DB VAL+$08, VAL+$0A, VAL+$06, VAL+$0B  ; 5000
.ENDM
msFruitPointTileDefs:
    msFruitPointsDefs   (SPRITE_ADDR + FSCORE_VRAM) / TILE_SIZE


/*
    EXPLOSION SPRITE TILE DEFINITION
*/
explosionSprDefs:
    .DB $C0 $CC $C1 $CD ; 0
    .DB $C2 $CE $C3 $CF ; 1
    .DB $C4 $D0 $C5 $D1 ; 2
    .DB $C6 $D2 $C7 $D3 ; 3
    .DB $C0 $CC $C1 $CD ; 0
    .DB $C8 $D4 $C9 $D5 ; 4
    .DB $C4 $D0 $C5 $D1 ; 2
    .DB $CA $D6 $CB $D7 ; 5
    .DB $C0 $CC $C1 $CD ; 0
    .DB $C2 $CE $C3 $CF ; 1
    .DB $C4 $D0 $C5 $D1 ; 2
    .DB $CA $D6 $CB $D7 ; 5
    .DB $C0 $CC $C1 $CD ; 0
    .DB $C2 $CE $C3 $CF ; 1
    .DB $C4 $D0 $C5 $D1 ; 2
    .DB $C6 $D2 $C7 $D3 ; 3



/*
    FRUIT SCORE TABLE (BCD)
*/
fruitScoreTable:
    .DW $0100
    .DW $0300
    .DW $0500
    .DW $0700
    .DW $1000
    .DW $2000
    .DW $3000
    .DW $5000

msFruitScoreTable:
    .DW $0100
    .DW $0200
    .DW $0500
    .DW $0700
    .DW $1000
    .DW $2000
    .DW $5000


/*
    LEVEL TABLES FOR DIFFICULTY MODES
*/
levelTableNormal:
    .DB $00 $01 $02 $03 $04 $05 $06 $07 $08 $09 $0a $0b $0c $0d $0e $0f $10 $11 $12 $13 $14
@jrTbl:
    .DB $01 $03 $04 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $14
levelTableHard:
    .DB $01 $03 $04 $06 $07 $08 $09 $0a $0b $0c $0d $0e $0f $10 $11 $14
@jrTbl:
    .DB $02 $04 $06 $07 $08 $09 $0A $0B $0C $0D $0E $0F $10 $11 $14 $0F $10 $11 $12 $13 $14


/*
    [LEVEL DIFFICULTY TABLE]
    EACH LINE REPRESENTS A LEVEL
    BYTE 0: SPEED PATTERN INDEX
    BYTE 1: FRUIT TIME INDEX (ONLY IN PLUS MODE)
    BYTE 2: GHOST DOT COUNT INDEX
    BYTE 3: BLINKY SPEED UP INDEX
    BYTE 4: POWER DOT TIME INDEX
    BYTE 5: DOT EXPIRE INDEX
*/
difficultyTable:
    .DB $03 $01 $01 $00 $02 $00
    .DB $04 $01 $02 $01 $03 $00
    .DB $04 $01 $03 $02 $04 $01
    .DB $04 $02 $03 $02 $05 $01
    .DB $05 $00 $03 $02 $06 $02
    .DB $05 $01 $03 $03 $03 $02
    .DB $05 $02 $03 $03 $06 $02
    .DB $05 $02 $03 $03 $06 $02
    .DB $05 $00 $03 $04 $07 $02
    .DB $05 $01 $03 $04 $03 $02
    .DB $05 $02 $03 $04 $06 $02
    .DB $05 $02 $03 $05 $07 $02
    .DB $05 $00 $03 $05 $07 $02
    .DB $05 $02 $03 $05 $05 $02
    .DB $05 $01 $03 $06 $07 $02
    .DB $05 $02 $03 $06 $07 $02
    .DB $05 $02 $03 $06 $08 $02
    .DB $05 $02 $03 $06 $07 $02
    .DB $05 $02 $03 $07 $08 $02
    .DB $05 $02 $03 $07 $08 $02
    .DB $06 $02 $03 $07 $08 $02
;   JR.PAC-MAN LEVEL DIFFICULTY TABLE
@jr:
    .DB $03 $01 $01 $00 $02 $00
    .DB $04 $01 $02 $01 $02 $00 ; DIFF
    .DB $04 $01 $03 $02 $04 $01 
    .DB $04 $02 $03 $02 $05 $01 
    .DB $05 $00 $03 $02 $06 $02 
    .DB $05 $01 $03 $03 $03 $02 
    .DB $05 $02 $03 $03 $06 $02 
    .DB $05 $02 $03 $03 $06 $02 
    .DB $05 $00 $03 $04 $07 $02 
    .DB $05 $01 $03 $04 $07 $02 ; DIFF
    .DB $05 $02 $03 $04 $06 $02 
    .DB $05 $02 $03 $05 $07 $02 
    .DB $05 $00 $03 $05 $07 $02 
    .DB $05 $02 $03 $05 $06 $02 ; DIFF 
    .DB $05 $01 $03 $06 $07 $02 
    .DB $05 $02 $03 $06 $07 $02 
    .DB $05 $02 $03 $06 $08 $02 
    .DB $05 $02 $03 $06 $07 $02 
    .DB $05 $02 $03 $07 $08 $02 
    .DB $05 $02 $03 $07 $08 $02 
    .DB $06 $02 $03 $07 $08 $02
@plus:
    .DB $05 $02 $02 $01 $04 $00
    .DB $05 $02 $03 $02 $05 $00
    .DB $05 $03 $03 $03 $06 $01
    .DB $05 $04 $03 $03 $06 $01
    .DB $05 $05 $03 $04 $06 $02
    .DB $05 $03 $03 $04 $04 $02
    .DB $05 $05 $03 $05 $06 $02
    .DB $05 $05 $03 $05 $07 $02
    .DB $05 $06 $03 $05 $07 $02
    .DB $05 $04 $03 $06 $06 $02
    .DB $05 $06 $03 $06 $07 $02
    .DB $05 $06 $03 $06 $08 $02
    .DB $05 $06 $03 $06 $08 $02
    .DB $05 $04 $03 $05 $06 $02
    .DB $05 $06 $03 $06 $08 $02
    .DB $06 $06 $03 $06 $07 $02
    .DB $06 $06 $03 $07 $08 $02
    .DB $06 $06 $03 $07 $06 $02
    .DB $06 $07 $03 $07 $08 $02
    .DB $06 $07 $03 $07 $08 $02
    .DB $06 $08 $03 $07 $08 $02



;   BYTE 0 OF DIFFICULTY TABLE
;   DETERMINES HOW FAST ACTORS MOVE
;   AND HOW LONG POWER DOT TIME LASTS
;   SPEED PATTERNS (EACH ENTRY IS 42 BYTES)
speedPatternTable:
;   ENTRY 3
    .DW $5555 $5555 ; PAC-MAN NORMAL
    .DW $6AD5 $6AD5 ; PAC-MAN SUPER
    .DW $6AAA $D555 ; BLINKY SPEED UP 2
    .DW $5555 $5555 ; BLINKY SPEED UP 1
    .DW $2AAA $5555 ; GHOST NORMAL
    .DW $2492 $2492 ; GHOST SCARED
    .DW $2222 $2222 ; GHOST TUNNEL
    ; SCATTER/CHASE TIMES
    .DW $01A4 $0654 $07F8 $0CA8 $0DD4 $1284 $13B0
;   ENTRY 4
    .DW $6AD5 $6AD5 
    .DW $5AD6 $B5AD 
    .DW $5AD6 $B5AD 
    .DW $6AD5 $6AD5
    .DW $6AAA $D555 
    .DW $2492 $4925 
    .DW $2448 $9122
    ; SCATTER/CHASE TIMES
    .DW $01A4 $0654 $07F8 $0CA8 $0DD4 $FFFE $FFFF
;   ENTRY 5
    .DW $6D6D $6D6D 
    .DW $6D6D $6D6D 
    .DW $6DB6 $DB6D 
    .DW $6D6D $6D6D
    .DW $5AD6 $B5AD 
    .DW $2525 $2525 
    .DW $2492 $2492
    ; SCATTER/CHASE TIMES
    .DW $012C $05DC $0708 $0BB8 $0CE4 $FFFE $FFFF
;   ENTRY 6
    .DW $6AD5 $6AD5 
    .DW $6AD5 $6AD5 
    .DW $6DB6 $DB6D 
    .DW $6D6D $6D6D
    .DW $5AD6 $B5AD 
    .DW $2448 $9122 
    .DW $2492 $2492
    ; SCATTER/CHASE TIMES
    .DW $012C $05DC $0708 $0BB8 $0CE4 $FFFE $FFFF


;   BYTE 1 OF DIFFICULTY TABLE
;   DETERMINES HOW MANY DOTS IT TAKES FOR A GHOST TO LEAVE HOME WHEN GLOBAL FLAG IS DISABLED
;   THE FLAG IS DISABLED UPON THE FIRST TIME A LEVEL STARTS
;   BTYE 0 - PINKY'S COUNT, BYTE 1 - INKY'S COUNT, BYTE 2 - CLYDE'S COUNT
ghostDotCounterTable:
    .DB $14 $1e $46     ; UNUSED
    .DB $00 $1e $3c   
    .DB $00 $00 $32   
    .DB $00 $00 $00


;   DETERMINES HOW MANY DOTS IT TAKES FOR A GHOST TO LEAVE HOME WHEN GLOBAL FLAG IS ENABLED
;   THE FLAG IS ENABLED WHEN PAC-MAN DIES
;   FLAG RESETS WHEN ALL GHOSTS HAVE LEFT OR WHEN A LEVEL IS COMPLETED
;   BTYE 0 - PINKY'S COUNT, BYTE 1 - INKY'S COUNT, BYTE 2 - CLYDE'S COUNT
globalDotCounterTable:
    .DB 07 17 32


;   BYTE 3 OF DIFFICULTY TABLE
;   DETERMINES HOW MANY DOTS IT TAKES FOR BLINKY TO GO FASTER AND ALWAYS TARGET PAC-MAN
;   "CRUISE ELROY" MODE
blinkySpeedUpTable:
    .DB $14
    .DB $1E
    .DB $28
    .DB $32
    .DB $3C
    .DB $50
    .DB $64
    .DB $78
    .DB $8C


;   BYTE 4 OF DIFFICULTY TABLE
;   DETERMINES HOW LONG A POWER DOT LASTS
powDotTimeTable:
    .DW 960         ; UNUSED
    .DW 840         ; UNUSED
    .DW 720         ; 6 SECONDS
    .DW 600         ; 5 SECONDS
    .DW 480         ; 4 SECONDS
    .DW 360         ; 3 SECONDS
    .DW 240         ; 2 SECONDS
    .DW 120         ; 1 SECOND
    .DW 1           ; 1 FRAME


;   BYTE 5 OF DIFFICULTY TABLE
;   DETERMINES HOW LONG IT TAKES A GHOST TO LEAVE HOME IF PAC-MAN DOESN'T EAT
dotExpireTable:
    .DB 240     ; 4 SECONDS
    .DB 240     ; 4 SECONDS
    .DB 180     ; 3.5 SECONDS
.ENDS


/*
----------------------------------------------------------
                    MS. PAC-MAN TABLES
----------------------------------------------------------
*/
.SECTION "MS. PAC-MAN TABLES" FREE

; MS. PAC-MAN PALETTE TABLE
msPalTable:
    .DW bgPalMs00   ; 00
    .DW bgPalMs01   ; 01
    .DW bgPalMs02   ; 02
    .DW bgPalMs03   ; 03
    .DW bgPalMs04   ; 04
    .DW bgPalMs05   ; 05 [PLUS]
    .DW bgPalMs06   ; 06 [PLUS]
    .DW bgPalMs07   ; 07 [PLUS]
    .DW bgPalMs08   ; 08 [PLUS]
    .DW bgPalMs09   ; 09 [PLUS]

; LEVEL PALETTE TABLE (REFERENCES PREVIOUS TABLE)
msLevelPalTable:
    .DB $00 $00         ; LVL 01 - 02
    .DB $01 $01 $01     ; LVL 03 - 05
    .DB $02 $02 $02 $02 ; LVL 06 - 09
    .DB $03 $03 $03 $03 ; LVL 10 - 13
    .DB $04 $04 $04 $04 ; LVL 14 - 17
    .DB $00 $00 $00 $00 ; LVL 18 - 21
@plus:
    .DB $05 $05         ; LVL 01 - 02
    .DB $06 $06 $06     ; LVL 03 - 05
    .DB $07 $07 $07 $07 ; LVL 06 - 09
    .DB $08 $08 $08 $08 ; LVL 10 - 13
    .DB $09 $09 $09 $09 ; LVL 14 - 17
    .DB $05 $05 $05 $05 ; LVL 18 - 21

; MAZE COLLISION TABLE
msMazeColTable:
    .DW maze1ColData
    .DW maze2ColData
    .DW maze3ColData
    .DW maze4ColData
; MAZE TILE MAP TABLE
msMazeTilemapTable:
    .DW maze1TileMap
    .DW maze2TileMap
    .DW maze3TileMap
    .DW maze4TileMap
; MAZE TILES TABLE
msMazeTilesTable:
    .DW maze1Tiles
    .DW maze2Tiles
    .DW maze3Tiles
    .DW maze4Tiles
; MAZE DOT TABLE
msMazeDotTable:
    .DW maze1DotTable
    .DW maze2DotTable
    .DW maze3DotTable
    .DW maze4DotTable
; MAZE PDOT TABLE
msMazePowTable:
    .DW maze1PowTable
    .DW maze2PowTable
    .DW maze3PowTable
    .DW maze4PowTable
; MAZE DOT COUNTS
msMazeDotCounts:
    .DW $00E0
    .DW $00F4
    .DW $00F2
    .DW $00EE


; MAZE TARGET TABLE (FOR GHOST SCATTER)
mazeTargetTable:
    .DW @maze0Targets   ; 0
    .DW @maze1Targets   ; 2
    .DW @maze2Targets   ; 4
    .DW @maze3Targets   ; 6

@maze0Targets:
@maze1Targets:
    .DW $1D22 $1D39
    .DW $4020 $403B
@maze2Targets:
    .DW $402D $1D22
    .DW $1D39 $4020
@maze3Targets:
    .DW $1D22 $4020
    .DW $1D39 $403B

; MAZE 1 FRUIT ENTRIES
maze1EntryPaths:
    ; PATH 0
.DW maze1FruitMoves0    ; PTR TO MOVES
.DB $13                 ; COUNT
.DW $940C               ; Y/X START
    ; PATH 1
.DW maze1FruitMoves1    ; PTR TO MOVES
.DB $22                 ; COUNT
.DW $94F4               ; Y/X START
    ; PATH 2
.DW maze1FruitMoves2    ; PTR TO MOVES
.DB $27                 ; COUNT
.DW $4CF4               ; Y/X START
    ; PATH 3
.DW maze1FruitMoves3    ; PTR TO MOVES
.DB $1C                 ; COUNT
.DW $4C0C               ; Y/X START
maze1FruitMoves0:
    .DB $80 $AA $AA $BF $AA
maze1FruitMoves1:
    .DB $80 $0A $54 $55 $55 $55 $FF $5F $55
maze1FruitMoves2:
    .DB $EA $FF $57 $55 $F5 $57 $FF $15 $40 $55
maze1FruitMoves3:
    .DB $EA $AF $02 $EA $FF $FF $AA
; MAZE 1 FRUIT EXITS
maze1ExitPaths:
    ; PATH 0
.DW maze1FruitMoves4    ; PTR TO MOVES
.DB $14                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 1
.DW maze1FruitMoves5    ; PTR TO MOVES
.DB $17                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 2
.DW maze1FruitMoves6    ; PTR TO MOVES
.DB $1A                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 3
.DW maze1FruitMoves7    ; PTR TO MOVES
.DB $1D                 ; COUNT
;.DW $0000               ; Y/X START
maze1FruitMoves4:
    .DB $55 $40 $55 $55 $BF
maze1FruitMoves5:
    .DB $AA $80 $AA $AA $BF $AA
maze1FruitMoves6:
    .DB $AA $80 $AA $02 $80 $AA $AA
maze1FruitMoves7:
    .DB $55 $00 $00 $00 $55 $55 $FD $AA

; MAZE 2 FRUIT ENTRIES
maze2EntryPaths:
    ; PATH 0
.DW maze2FruitMoves0    ; PTR TO MOVES
.DB $13                 ; COUNT
.DW $C40C               ; Y/X START
    ; PATH 1
.DW maze2FruitMoves1    ; PTR TO MOVES
.DB $1E                 ; COUNT
.DW $C4F4               ; Y/X START
    ; PATH 2
.DW maze2FruitMoves2    ; PTR TO MOVES
.DB $26                 ; COUNT
.DW $14F4               ; Y/X START
    ; PATH 3
.DW maze2FruitMoves3    ; PTR TO MOVES
.DB $1D                 ; COUNT
.DW $140C               ; Y/X START
maze2FruitMoves0:
    .DB $02 $AA $AA $80 $2A
maze2FruitMoves1:
    .DB $02 $40 $55 $7F $55 $15 $50 $05
maze2FruitMoves2:
    .DB $EA $FF $57 $55 $F5 $FF $57 $7F $55 $05
maze2FruitMoves3:
    .DB $EA $FF $FF $FF $EA $AF $AA $02
; MAZE 2 FRUIT EXITS
maze2ExitPaths:
    ; PATH 0
.DW maze2FruitMoves4    ; PTR TO MOVES
.DB $12                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 1
.DW maze2FruitMoves5    ; PTR TO MOVES
.DB $1D                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 2
.DW maze2FruitMoves6    ; PTR TO MOVES
.DB $21                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 3
.DW maze2FruitMoves7    ; PTR TO MOVES
.DB $2C                 ; COUNT
;.DW $0000               ; Y/X START
maze2FruitMoves4:
    .DB $55 $7F $55 $D5 $FF
maze2FruitMoves5:
    .DB $AA $BF $AA $2A $A0 $EA $FF $FF
maze2FruitMoves6:
    .DB $AA $2A $A0 $02 $00 $00 $A0 $AA $02
maze2FruitMoves7:
    .DB $55 $15 $A0 $2A $00 $54 $05 $00 $00 $55 $FD

; MAZE 3 FRUIT ENTRIES
maze3EntryPaths:
    ; PATH 0
.DW maze3FruitMoves0    ; PTR TO MOVES
.DB $15                 ; COUNT
.DW $540C               ; Y/X START
    ; PATH 1
.DW maze3FruitMoves1    ; PTR TO MOVES
.DB $1E                 ; COUNT
.DW $54F4               ; Y/X START
    ; PATH 2
.DW maze3FruitMoves2    ; PTR TO MOVES
.DB $1E                 ; COUNT
.DW $54F4               ; Y/X START
    ; PATH 3
.DW maze3FruitMoves3    ; PTR TO MOVES
.DB $15                 ; COUNT
.DW $540C               ; Y/X START
maze3FruitMoves0:
    .DB $EA $FF $AB $FA $AA $AA
maze3FruitMoves1:
maze3FruitMoves2:
    .DB $EA $FF $57 $55 $55 $D5 $57 $55
maze3FruitMoves3:
    .DB $AA $AA $BF $FA $BF $AA
; MAZE 3 FRUIT EXITS
maze3ExitPaths:
    ; PATH 0
.DW maze3FruitMoves4    ; PTR TO MOVES
.DB $22                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 1
.DW maze3FruitMoves5    ; PTR TO MOVES
.DB $25                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 2
.DW maze3FruitMoves5    ; PTR TO MOVES
.DB $25                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 3
.DW maze3FruitMoves7    ; PTR TO MOVES
.DB $28                 ; COUNT
;.DW $0000               ; Y/X START
maze3FruitMoves4:
    .DB $05 $00 $00 $54 $05 $54 $7F $F5 $0B
maze3FruitMoves5
    .DB $0A $00 $00 $A8 $0A $A8 $BF $FA $AB $AA
maze3FruitMoves6:
    .DB $AA $82 $AA $00 $A0 $AA ; UNUSED
maze3FruitMoves7:
    .DB $55 $41 $55 $00 $A0 $02 $40 $F5 $57 $BF

; MAZE 4 FRUIT ENTRIES
maze4EntryPaths:
    ; PATH 0
.DW maze4FruitMoves0    ; PTR TO MOVES
.DB $14                 ; COUNT
.DW $8C0C               ; Y/X START
    ; PATH 1
.DW maze4FruitMoves1    ; PTR TO MOVES
.DB $1D                 ; COUNT
.DW $8CF4               ; Y/X START
    ; PATH 2
.DW maze4FruitMoves2    ; PTR TO MOVES
.DB $2A                 ; COUNT
.DW $74F4               ; Y/X START
    ; PATH 3
.DW maze4FruitMoves3    ; PTR TO MOVES
.DB $15                 ; COUNT
.DW $740C               ; Y/X START
maze4FruitMoves0:
    .DB $80 $AA $BE $FA $AA
maze4FruitMoves1:
    .DB $00 $50 $FD $55 $F5 $D5 $57 $55
maze4FruitMoves2:
    .DB $EA $FF $57 $D5 $5F $FD $15 $50 $01 $50 $55
maze4FruitMoves3:
    .DB $EA $AF $FE $2A $A8 $AA
; MAZE 4 FRUIT EXITS
maze4ExitPaths:
    ; PATH 0
.DW maze4FruitMoves4    ; PTR TO MOVES
.DB $15                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 1
.DW maze4FruitMoves5    ; PTR TO MOVES
.DB $18                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 2
.DW maze4FruitMoves6    ; PTR TO MOVES
.DB $19                 ; COUNT
.DW $0000               ; Y/X START
    ; PATH 3
.DW maze4FruitMoves7    ; PTR TO MOVES
.DB $1C                 ; COUNT
;.DW $0000               ; Y/X START
maze4FruitMoves4:
    .DB $55 $50 $41 $55 $FD $AA
maze4FruitMoves5:
    .DB $AA $A0 $82 $AA $FE $AA
maze4FruitMoves6:
    .DB $AA $AF $02 $2A $A0 $AA $AA
maze4FruitMoves7:
    .DB $55 $5F $01 $00 $50 $55 $BF

msMazeFruitEntries:
    .DW maze1EntryPaths
    .DW maze2EntryPaths
    .DW maze3EntryPaths
    .DW maze4EntryPaths
msMazeFruitExits:
    .DW maze1ExitPaths
    .DW maze2ExitPaths
    .DW maze3ExitPaths
    .DW maze4ExitPaths
msMazeGhostPath:
    .DB $FA $FF $55 $55 $01 $80 $AA $02


;               $YYXX
.DEFINE B_U     $FF00   ; MOVE UP
.DEFINE B_R     $00FF   ; MOVE RIGHT
.DEFINE B_L     $0001   ; MOVE LEFT
.DEFINE B_D     $0100   ; MOVE DOWN
.DEFINE B_UR    $FFFF   ; MOVE UP-RIGHT
.DEFINE B_DR    $01FF   ; MOVE DOWN-RIGHT
.DEFINE B_UL    $FF01   ; MOVE UP-LEFT
.DEFINE B_DL    $0101   ; MOVE DOWN-LEFT
.DEFINE B_Z     $0000   ; NO MOVEMENT

fruitBounceFrames:
    .DW B_U, B_U, B_U, B_U, B_U, B_U, B_U, B_U, B_U, B_Z, B_U, B_Z, B_Z, B_D, B_Z, B_D
    .DW B_Z, B_UR, B_Z, B_R, B_Z, B_UR, B_Z, B_R, B_Z, B_R, B_Z, B_R, B_Z, B_DR, B_DR, B_Z
    .DW B_Z, B_Z, B_UL, B_Z, B_L, B_Z, B_UL, B_Z, B_L, B_Z, B_L, B_Z, B_L, B_Z, B_DL, B_DL
    .DW B_Z, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_U, B_U, B_Z, B_U
.ENDS

/*
----------------------------------------------------------
                    JR. PAC-MAN TABLES
----------------------------------------------------------
*/
.SECTION "JR. PAC-MAN TABLES" FREE
; JR.PAC-MAN PALETTE TABLE
jrPalTable:
    .DW bgPalJr00   ; 00
    .DW bgPalJr01   ; 01
    .DW bgPalJr02   ; 02
    .DW bgPalJr03   ; 03
    .DW bgPalJr04   ; 04
    .DW bgPalJr05   ; 05 [PLUS]
    .DW bgPalJr06   ; 06 [PLUS]
    .DW bgPalJr07   ; 07 [PLUS]
    .DW bgPalJr08   ; 08 [PLUS]
    .DW bgPalJr09   ; 09 [PLUS]

; LEVEL PALETTE TABLE (REFERENCES PREVIOUS TABLE)
jrLevelPalTable:
    .DB $00 $01         ; LVL 01 - 02
    .DB $02 $03 $04     ; LVL 03 - 05
    .DB $01 $00 $03 $02 ; LVL 06 - 09
    .DB $01 $04 $03 $00 ; LVL 10 - 13
    .DB $01 $02 $03 $04 ; LVL 14 - 17
    .DB $01 $00 $03 $02 ; LVL 18 - 21
@plus:
    .DB $05 $06         ; LVL 01 - 02
    .DB $07 $08 $09     ; LVL 03 - 05
    .DB $06 $05 $08 $07 ; LVL 06 - 09
    .DB $06 $09 $08 $05 ; LVL 10 - 13
    .DB $06 $07 $08 $09 ; LVL 14 - 17
    .DB $06 $05 $08 $07 ; LVL 18 - 21

; 1, 0, 3, 2, 5, 4, 6
; MAZE COLLISION TABLE
jrMazeColTable:
    .DW maze6ColData
    .DW maze5ColData
    .DW maze8ColData
    .DW maze7ColData
    .DW maze10ColData
    .DW maze9ColData
    .DW maze11ColData
; MAZE TILE MAP TABLE
jrMazeTilemapTable:
    .DW maze6TileMap
    .DW maze5TileMap
    .DW maze8TileMap
    .DW maze7TileMap
    .DW maze10TileMap
    .DW maze9TileMap
    .DW maze11TileMap
; MAZE TILES TABLE
jrMazeTilesTable:
    .DW maze6Tiles
    .DW maze5Tiles
    .DW maze8Tiles
    .DW maze7Tiles
    .DW maze10Tiles
    .DW maze9Tiles
    .DW maze11Tiles
; MAZE DOT TABLE
jrMazeDotTable:
    .DW maze6DotTable
    .DW maze5DotTable
    .DW maze8DotTable
    .DW maze7DotTable
    .DW maze10DotTable
    .DW maze9DotTable
    .DW maze11DotTable
; MAZE PDOT TABLE
jrMazePowTable:
    .DW maze6PowTable
    .DW maze5PowTable
    .DW maze8PowTable
    .DW maze7PowTable
    .DW maze10PowTable
    .DW maze9PowTable
    .DW maze11PowTable
; MAZE MDOT TABLE 0 [NORMAL -> MUTATED]
jrMazeMDotTable:
    .DW maze6MDotTable
    .DW maze5MDotTable
    .DW maze8MDotTable
    .DW maze7MDotTable
    .DW maze10MDotTable
    .DW maze9MDotTable
    .DW maze11MDotTable
; MAZE MDOT TABLE 1 [MUTATED -> EATEN]
jrMazeMEatTable:
    .DW maze6MEatTable
    .DW maze5MEatTable
    .DW maze8MEatTable
    .DW maze7MEatTable
    .DW maze10MEatTable
    .DW maze9MEatTable
    .DW maze11MEatTable
; MAZE MDOT TABLE 2 [MUTATED -> NORMAL]
jrMazeMRstTable:
    .DW maze6MRstTable
    .DW maze5MRstTable
    .DW maze8MRstTable
    .DW maze7MRstTable
    .DW maze10MRstTable
    .DW maze9MRstTable
    .DW maze11MRstTable

; DOT COUNT TABLE
jrMazeDotCounts:
    .DW $0224
    .DW $022A
    .DW $0214
    .DW $0214
    .DW $0204
    .DW $0216
    .DW $0220

; MAZE POWER DOT TARGETS
jrMazePDotTargets:
    .DW @jrMaze0
    .DW @jrMaze1
    .DW @jrMaze2
    .DW @jrMaze3
    .DW @jrMaze4
    .DW @jrMaze5
    .DW @jrMaze6

@jrMaze0:   ; 2ND LEVEL
    .DW $2721
    .DW $3B21
    .DW $2E30
    .DW $2E45
    .DW $2754
    .DW $3B54
@jrMaze1:   ; 1ST LEVEL
    .DW $2521
    .DW $3A21
    .DW $2E30
    .DW $2E45
    .DW $2554
    .DW $3A54
@jrMaze2:   ; 4TH LEVEL
    .DW $2521
    .DW $3D21
    .DW $2E2D
    .DW $2E48
    .DW $2554
    .DW $3D54
@jrMaze3:   ; 3RD LEVEL
    .DW $2521
    .DW $3B21
    .DW $2830
    .DW $2845
    .DW $2554
    .DW $3B54
@jrMaze4:   ; 6TH LEVEL
    .DW $3727
    .DW $282A
    .DW $284B
    .DW $374E
    .DW $3727
    .DW $282A
@jrMaze5:   ; 5TH LEVEL
    .DW $2524
    .DW $3A2A
    .DW $2E30
    .DW $2E45
    .DW $3A4B
    .DW $2551
@jrMaze6:   ; 7TH LEVEL
    .DW $2827
    .DW $3727
    .DW $284E
    .DW $374E
    .DW $2827
    .DW $3727
.ENDS


/*
    SCROLL TABLES
*/
.SECTION "JR.PAC SCROLL TABLES" BANK JR_TABLES_BANK SLOT 2 FORCE ORG $3900
    /*
    SCROLL VALUE -> LEFT MOST TILE: y = -(x >> 3) + 4
    $00 - $07: $04
    $08 - $0F: $03
    $10 - $17: $02
    $18 - $1F: $01
    $20 - $27: $00
    $28 - $2F: $FF

    $FF - $F8: $05
    $F7 - $F0: $06
    $EF - $E8: $07
    $E7 - $E0: $08
    $DF - $D8: $09
    */
jrLeftTileTable:
;   H: $39, $100
    .DB $04, $04, $04, $04, $04, $04, $04, $04, $03, $03, $03, $03, $03, $03, $03, $03
    .DB $02, $02, $02, $02, $02, $02, $02, $02, $01, $01, $01, $01, $01, $01, $01, $01
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF
    .DB $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FE, $FD, $FD, $FD, $FD, $FD, $FD, $FD, $FD
    .DB $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FC, $FB, $FB, $FB, $FB, $FB, $FB, $FB, $FB
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0E, $0D, $0D, $0D, $0D, $0D, $0D, $0D, $0D
    .DB $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0C, $0B, $0B, $0B, $0B, $0B, $0B, $0B, $0B
    .DB $0A, $0A, $0A, $0A, $0A, $0A, $0A, $0A, $09, $09, $09, $09, $09, $09, $09, $09
    .DB $08, $08, $08, $08, $08, $08, $08, $08, $07, $07, $07, $07, $07, $07, $07, $07
    .DB $06, $06, $06, $06, $06, $06, $06, $06, $05, $05, $05, $05, $05, $05, $05, $05


    ; VAL = (328 + 12) - (X - X/4)
    ; $00 - $70 = $01 HIBYTE
jrScaleTable:
;   H: $3A, $400
    .DW $0154, $0153, $0152, $0151, $0151, $0150, $014F, $014E, $014E, $014D, $014C, $014B, $014B, $014A, $0149, $0148
    .DW $0148, $0147, $0146, $0145, $0145, $0144, $0143, $0142, $0142, $0141, $0140, $013F, $013F, $013E, $013D, $013C
    .DW $013C, $013B, $013A, $0139, $0139, $0138, $0137, $0136, $0136, $0135, $0134, $0133, $0133, $0132, $0131, $0130
    .DW $0130, $012F, $012E, $012D, $012D, $012C, $012B, $012A, $012A, $0129, $0128, $0127, $0127, $0126, $0125, $0124
    .DW $0124, $0123, $0122, $0121, $0121, $0120, $011F, $011E, $011E, $011D, $011C, $011B, $011B, $011A, $0119, $0118
    .DW $0118, $0117, $0116, $0115, $0115, $0114, $0113, $0112, $0112, $0111, $0110, $010F, $010F, $010E, $010D, $010C
    .DW $010C, $010B, $010A, $0109, $0109, $0108, $0107, $0106, $0106, $0105, $0104, $0103, $0103, $0102, $0101, $0100
    .DW $0100, $00FF, $00FE, $00FD, $00FD, $00FC, $00FB, $00FA, $00FA, $00F9, $00F8, $00F7, $00F7, $00F6, $00F5, $00F4
;   H: $3B
    .DW $00F4, $00F3, $00F2, $00F1, $00F1, $00F0, $00EF, $00EE, $00EE, $00ED, $00EC, $00EB, $00EB, $00EA, $00E9, $00E8
    .DW $00E8, $00E7, $00E6, $00E5, $00E5, $00E4, $00E3, $00E2, $00E2, $00E1, $00E0, $00DF, $00DF, $00DE, $00DD, $00DC
    .DW $00DC, $00DB, $00DA, $00D9, $00D9, $00D8, $00D7, $00D6, $00D6, $00D5, $00D4, $00D3, $00D3, $00D2, $00D1, $00D0
    .DW $00D0, $00CF, $00CE, $00CD, $00CD, $00CC, $00CB, $00CA, $00CA, $00C9, $00C8, $00C7, $00C7, $00C6, $00C5, $00C4
    .DW $00C4, $00C3, $00C2, $00C1, $00C1, $00C0, $00BF, $00BE, $00BE, $00BD, $00BC, $00BB, $00BB, $00BA, $00B9, $00B8
    .DW $00B8, $00B7, $00B6, $00B5, $00B5, $00B4, $00B3, $00B2, $00B2, $00B1, $00B0, $00AF, $00AF, $00AE, $00AD, $00AC
    .DW $00AC, $00AB, $00AA, $00A9, $00A9, $00A8, $00A7, $00A6, $00A6, $00A5, $00A4, $00A3, $00A3, $00A2, $00A1, $00A0
    .DW $00A0, $009F, $009E, $009D, $009D, $009C, $009B, $009A, $009A, $0099, $0098, $0097, $0097, $0096, $0095, $0094
;   H: $3C
    .DW $0094, $0093, $0092, $0091, $0091, $0090, $008F, $008E, $008E, $008D, $008C, $008B, $008B, $008A, $0089, $0088
    .DW $0088, $0087, $0086, $0085, $0085, $0084, $0083, $0082, $0082, $0081, $0080, $007F, $007F, $007E, $007D, $007C
    .DW $007C, $007B, $007A, $0079, $0079, $0078, $0077, $0076, $0076, $0075, $0074, $0073, $0073, $0072, $0071, $0070
    .DW $0070, $006F, $006E, $006D, $006D, $006C, $006B, $006A, $006A, $0069, $0068, $0067, $0067, $0066, $0065, $0064
    .DW $0064, $0063, $0062, $0061, $0061, $0060, $005F, $005E, $005E, $005D, $005C, $005B, $005B, $005A, $0059, $0058
    .DW $0058, $0057, $0056, $0055, $0055, $0054, $0053, $0052, $0052, $0051, $0050, $004F, $004F, $004E, $004D, $004C
    .DW $004C, $004B, $004A, $0049, $0049, $0048, $0047, $0046, $0046, $0045, $0044, $0043, $0043, $0042, $0041, $0040
    .DW $0040, $003F, $003E, $003D, $003D, $003C, $003B, $003A, $003A, $0039, $0038, $0037, $0037, $0036, $0035, $0034
;   H: $3D
    .DW $0034, $0033, $0032, $0031, $0031, $0030, $002F, $002E, $002E, $002D, $002C, $002B, $002B, $002A, $0029, $0028
    .DW $0028, $0027, $0026, $0025, $0025, $0024, $0023, $0022, $0022, $0021, $0020, $001F, $001F, $001E, $001D, $001C
    .DW $001C, $001B, $001A, $0019, $0019, $0018, $0017, $0016, $0016, $0015, $0014, $0013, $0013, $0012, $0011, $0010
    .DW $0010, $000F, $000E, $000D, $000D, $000C, $000B, $000A, $000A, $0009, $0008, $0007, $0007, $0006, $0005, $0004
    .DW $0004, $0003, $0002, $0001, $0001, $0000, $FFFF, $FFFE, $FFFE, $FFFD, $FFFC, $FFFB, $FFFB, $FFFA, $FFF9, $FFF8
    .DW $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .DW $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000
    .DW $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000, $0000


    ; USES VALUE RETRIEVED IN jrScaleTable AS INDEX
jrRealScrollTable:
;   H: $3E, $147
    .DB $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
    .DB $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
    .DB $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
    .DB $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
    .DB $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28, $28
    .DB $28, $27, $26, $25, $24, $23, $22, $21, $20, $1F, $1E, $1D, $1C, $1B, $1A, $19
    .DB $18, $17, $16, $15, $14, $13, $12, $11, $10, $0F, $0E, $0D, $0C, $0B, $0A, $09
    .DB $08, $07, $06, $05, $04, $03, $02, $01, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00, $00
    .DB $00, $FF, $FE, $FD, $FC, $FB, $FA, $F9, $F8, $F7, $F6, $F5, $F4, $F3, $F2, $F1
    .DB $F0, $EF, $EE, $ED, $EC, $EB, $EA, $E9, $E8, $E7, $E6, $E5, $E4, $E3, $E2, $E1
    .DB $E0, $DF, $DE, $DD, $DC, $DB, $DA, $D9, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
;   H: $3F
    .DB $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
    .DB $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
    .DB $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
    .DB $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
    .DB $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
    .DB $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8, $D8
.ENDS



/*
----------------------------------------------------------
                    IN GAME HUD DATA
----------------------------------------------------------
*/
.INCDIR "ASSETS"
.SECTION "HUD GFX DATA" BANK ACTOR2_GFX_BANK SLOT 2 FREE
    hudTextTiles:
        .INCBIN "TILE_HUD.ZX7"
    jrHudTextTiles:
        .INCBIN "TILE_HUD_JR.ZX7"
    jrHudIconTilesSmo:
        .INCBIN "TILE_ICONS_JR_SMO.ZX7"
    jrHudIconTilesArc:
        .INCBIN "TILE_ICONS_JR_ARC.ZX7"
    jrMazeTxtCommTiles:
        .INCBIN "TILE_MAZETXT_JR.ZX7"
.ENDS


/*
----------------------------------------------------------
                ATTRACT MODE GFX DATA
----------------------------------------------------------
*/
.INCDIR "ASSETS/ATTRACT"
.SECTION "ATTRACT MODE GFX DATA" BANK SOUND_BANK SLOT 2 FREE
;   TITLE
    titleTileData:
        .INCBIN "TILE_TITLE.ZX7"
    titleTileMap:
        .INCBIN "MAP_TITLE.ZX7"
;   TITLE/OPTIONS
    titleArrowData:
        .INCBIN "TILE_ARROW.ZX7"
    titlePal:
        .INCBIN "PAL_TITLE.BIN"
;   OPTIONS
    optionsTileData:
        .INCBIN "TILE_OPTIONS.ZX7"
;   INTRO
    introTileData:
        .INCBIN "TILE_INTRO.ZX7"
    @otto:
        .INCBIN "TILE_OTTOINTRO.ZX7"
;   MS INTRO
    msIntroTileData:
        .INCBIN "TILE_MSINTRO.ZX7"
;   MS MARQUEE
    msMarqueeTileData:
        .INCBIN "TILE_MARQUEE.ZX7"
.ENDS



/*
----------------------------------------------------------
                    MAZE TILEMAP DATA
----------------------------------------------------------
*/
.SECTION "MAZE TILEMAP DATA" BANK MAZE_TILEMAP_BANK SLOT 2 FREE
;   MAZE 0
.INCDIR "ASSETS/MAZE0"
    maze0TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 1
.INCDIR "ASSETS/MAZE1"
    maze1TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 2
.INCDIR "ASSETS/MAZE2"
    maze2TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 3
.INCDIR "ASSETS/MAZE3"
    maze3TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 4
.INCDIR "ASSETS/MAZE4"
    maze4TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 5
.INCDIR "ASSETS/JRMAZE0"
    maze5TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 6
.INCDIR "ASSETS/JRMAZE1"
    maze6TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 7
.INCDIR "ASSETS/JRMAZE2"
    maze7TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 8
.INCDIR "ASSETS/JRMAZE3"
    maze8TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 9
.INCDIR "ASSETS/JRMAZE4"
    maze9TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 10
.INCDIR "ASSETS/JRMAZE5"
    maze10TileMap:
        .INCBIN "MAP_MAZE.ZX7"
;   MAZE 11
.INCDIR "ASSETS/JRMAZE6"
    maze11TileMap:
        .INCBIN "MAP_MAZE.ZX7"
.ENDS

/*
----------------------------------------------------------
                    MAZE TILE DATA
----------------------------------------------------------
*/
.SECTION "MAZE TILE DATA" BANK MAZE_GFX_BANK SLOT 2 FREE
;   MAZE 0
.INCDIR "ASSETS/MAZE0"
    maze0Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 1
.INCDIR "ASSETS/MAZE1"
    maze1Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 2
.INCDIR "ASSETS/MAZE2"
    maze2Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 3
.INCDIR "ASSETS/MAZE3"
    maze3Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 4
.INCDIR "ASSETS/MAZE4"
    maze4Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 5
.INCDIR "ASSETS/JRMAZE0"
    maze5Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 6
.INCDIR "ASSETS/JRMAZE1"
    maze6Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 7
.INCDIR "ASSETS/JRMAZE2"
    maze7Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 8
.INCDIR "ASSETS/JRMAZE3"
    maze8Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 9
.INCDIR "ASSETS/JRMAZE4"
    maze9Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 10
.INCDIR "ASSETS/JRMAZE5"
    maze10Tiles:
        .INCBIN "TILE_MAZE.ZX7"
;   MAZE 11
.INCDIR "ASSETS/JRMAZE6"
    maze11Tiles:
        .INCBIN "TILE_MAZE.ZX7"
.ENDS

/*
----------------------------------------------------------
                    MAZE OTHER DATA
----------------------------------------------------------
*/
.SECTION "MAZE DATA (OTHER THAN TILEMAP && GFX)" BANK MAZE_OTHER_BANK SLOT 2 FREE
;   MAZE 0
.INCDIR "ASSETS/MAZE0"
    mazeCollsionData:
        .INCBIN "COL_MAZE.ZX7"
    maze0EatenTable:
        .INCBIN "DOT_MAZE.ZX7"
    @powDots:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 1
.INCDIR "ASSETS/MAZE1"
    maze1ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze1DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze1PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 2
.INCDIR "ASSETS/MAZE2"
    maze2ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze2DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze2PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 3
.INCDIR "ASSETS/MAZE3"
    maze3ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze3DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze3PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 4
.INCDIR "ASSETS/MAZE4"
    maze4ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze4DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze4PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 5
.INCDIR "ASSETS/JRMAZE0"
    maze5ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze5DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze5PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze5MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze5MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze5MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
;   MAZE 6
.INCDIR "ASSETS/JRMAZE1"
    maze6ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze6DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze6PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze6MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze6MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze6MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
;   MAZE 7
.INCDIR "ASSETS/JRMAZE2"
    maze7ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze7DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze7PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze7MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze7MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze7MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
;   MAZE 8
.INCDIR "ASSETS/JRMAZE3"
    maze8ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze8DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze8PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze8MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze8MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze8MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
;   MAZE 9
.INCDIR "ASSETS/JRMAZE4"
    maze9ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze9DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze9PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze9MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze9MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze9MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
;   MAZE 10
.INCDIR "ASSETS/JRMAZE5"
    maze10ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze10DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze10PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze10MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze10MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze10MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
;   MAZE 11
.INCDIR "ASSETS/JRMAZE6"
    maze11ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze11DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze11PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
    maze11MDotTable:
        .INCBIN "MDOT0_MAZE.ZX7"
    maze11MEatTable:
        .INCBIN "MDOT1_MAZE.ZX7"
    maze11MRstTable:
        .INCBIN "MDOT2_MAZE.ZX7"
.ENDS

/*
----------------------------------------------------------
                ACTOR/OBJECT TILE DATA
----------------------------------------------------------
*/
.SECTION "ACTOR GFX DATA [PART 1]" BANK ACTOR_GFX_BANK SLOT 2 FREE
;   SMOOTH
.INCDIR "ASSETS/GAMEPLAY/SMOOTH"
    ghostTiles:
        .INCBIN "TILE_GHOSTS.ZX7"
    @plus:
        .INCBIN "TILE_GHOSTS_PLUS.ZX7"
    ghostPointTiles:
        .INCBIN "TILE_GPOINTS.ZX7"
    @plus:
        .INCBIN "TILE_GPOINTS_PLUS.ZX7"
    fruitTiles:
        .INCBIN "TILE_FRUIT.ZX7"
    @plus:
        .INCBIN "TILE_FRUIT_PLUS.ZX7"
    fruitPointTiles:
        .INCBIN "TILE_FPOINTS.ZX7"
    msFruitTiles:
        .INCBIN "TILE_MSFRUIT.ZX7"
    msFruitPointTiles:
        .INCBIN "TILE_MSFPOINTS.ZX7"
    ottoGhostTiles:
        .INCBIN "TILE_OTTOGHOSTS.ZX7"
    @plus:
        .INCBIN "TILE_OTTOGHOSTS_PLUS.ZX7"
    jrExplosionTiles:
        .INCBIN "TILE_EXPLODE.ZX7"
    ; CUTSCENE STUFF
.INCDIR "ASSETS/CUTSCENE/SMOOTH"
    cutscenePacTiles:
        .INCBIN "TILE_PAC.ZX7"
    cutsceneGhostTiles:
        .INCBIN "TILE_GHOST.ZX7"
    @plus:
        .INCBIN "TILE_GHOST_PLUS.ZX7"
    msCutsceneTiles:
        .INCBIN "TILE_MSCUT.ZX7"
    jrCutsceneTiles:
        .INCBIN "TILE_JRCUT.ZX7"
;   ARCADE
.INCDIR "ASSETS/GAMEPLAY/ARCADE"
arcadeGFXData:
    @ghosts:
        .INCBIN "TILE_GHOSTS.ZX7"
    @ghostsPlus:
        .INCBIN "TILE_GHOSTS_PLUS.ZX7"
    @fruit:
        .INCBIN "TILE_FRUIT.ZX7"
    @fruitPlus:
        .INCBIN "TILE_FRUIT_PLUS.ZX7"
    @msFruit:
        .INCBIN "TILE_MSFRUIT.ZX7"
    @fruitPoints:
        .INCBIN "TILE_FPOINTS.ZX7"
    @msFruitPoints:
        .INCBIN "TILE_MSFPOINTS.ZX7"
    @ghostPoints:
        .INCBIN "TILE_GPOINTS.ZX7"
    @ghostPointsPlus:
        .INCBIN "TILE_GPOINTS_PLUS.ZX7"
    @ottoGhosts:
        .INCBIN "TILE_OTTOGHOSTS.ZX7"
    @ottoGhostsPlus:
        .INCBIN "TILE_OTTOGHOSTS_PLUS.ZX7"
    @explosion:
        .INCBIN "TILE_EXPLODE.ZX7"
    ; CUTSCENE STUFF
.INCDIR "ASSETS/CUTSCENE/ARCADE"
    @cutscenePac:
        .INCBIN "TILE_PAC.ZX7"
    @cutsceneGhost:
        .INCBIN "TILE_GHOST.ZX7"
    @cutsceneGhostPlus:
        .INCBIN "TILE_GHOST_PLUS.ZX7"
    @cutsceneMs:
        .INCBIN "TILE_MSCUT.ZX7"
.ENDS

.SECTION "ACTOR GFX DATA [PART 2]" BANK ACTOR3_GFX_BANK SLOT 2 FREE
    @cutsceneJr:
        .INCBIN "TILE_JRCUT.ZX7"
.INCDIR "ASSETS/GAMEPLAY/ARCADE"
    @jrFruit:
        .INCBIN "TILE_JRFRUIT.ZX7"
    @jrFruitPlus:
        .INCBIN "TILE_JRFRUIT_PLUS.ZX7"
;   SMOOTH
.INCDIR "ASSETS/GAMEPLAY/SMOOTH"
    jrFruitTiles:
        .INCBIN "TILE_JRFRUIT.ZX7"
.ENDS

/*
----------------------------------------------------------
                JR CUTSCENE BG DATA
----------------------------------------------------------
*/
.SECTION "JR CUTSCENE BG TILE DATA [PART 1]" BANK MAZE_GFX_BANK SLOT 2 FREE
    .INCDIR "ASSETS/CUTSCENE"
    jrAttractTiles:
        .INCBIN "TILE_JRINTRO.ZX7"
    jrCut0Tiles:
        .INCBIN "TILE_JRCUT0.ZX7"
.ENDS

.SECTION "JR CUTSCENE BG TILE DATA [PART 2]" BANK ACTOR3_GFX_BANK SLOT 2 FREE
    .INCDIR "ASSETS/CUTSCENE"
    jrCut1Tiles:
        .INCBIN "TILE_JRCUT1.ZX7"
    jrCut2Tiles:
        .INCBIN "TILE_JRCUT2.ZX7"
.ENDS

.SECTION "JR CUTSCENE BG TILEMAP DATA" BANK MAZE_TILEMAP_BANK SLOT 2 FREE
    .INCDIR "ASSETS/CUTSCENE"
    jrAttractTilemap:
        .INCBIN "MAP_JRINTRO.ZX7"
    jrCut0Tilemap:
        .INCBIN "MAP_JRCUT0.ZX7"
    jrCut1Tilemap:
        .INCBIN "MAP_JRCUT1.ZX7"
    jrCut2Tilemap:
        .INCBIN "MAP_JRCUT2.ZX7"
.ENDS

/*
----------------------------------------------------------
            ORIGINAL GAME DATA FOR RNG FUNCTION
----------------------------------------------------------
*/
.SECTION "ORIGINAL GAME DATA FOR RNG [PAC/MS.PAC]" BANK RNG_PAC_BANK SLOT 2 FREE
    .INCDIR "ASSETS"
    rngDataOffset:
        .INCBIN "PAC_RNG.BIN"   ; 8KB
        .INCBIN "PLUS_RNG.BIN"  ; 8KB
.ENDS

.SECTION "ORIGINAL GAME DATA FOR RNG [JR.PAC]" BANK RNG_JR_BANK SLOT 2 FREE
    .INCDIR "ASSETS"
        .INCBIN "JR_RNG.BIN"    ; 8KB
        .INCBIN "PLUS_RNG.BIN"  ; 8KB
.ENDS



/*
----------------------------------------------------------
        UNCOMPRESSED TILE DATA FOR PLAYER ACTORS
----------------------------------------------------------
*/
.BANK UNCOMP_BANK SLOT 2
.ORG $0000

;   EMPTY TILE
pacTileS07:
pacDTileS0F:
annaTileS13:
ottoTileS23:
pacTileA07:
pacDTileA0F:
annaTileA14:
ottoTileA24:
jrDTileA07:
    .DSB $20, $00


.INCDIR "ASSETS/GAMEPLAY/SMOOTH"
.INCLUDE "TILE_PAC.INC"
.INCLUDE "TILE_DEATH.INC"
.INCLUDE "TILE_MSPAC.INC"
.INCLUDE "TILE_JR.INC"
;   JR DEATH
.INCLUDE "TILE_OTTO.INC"
.INCLUDE "TILE_ANNA.INC"

.INCDIR "ASSETS/GAMEPLAY/ARCADE"
.INCLUDE "TILE_PAC.INC"
.INCLUDE "TILE_DEATH.INC"
.INCLUDE "TILE_MSPAC.INC"
.INCLUDE "TILE_JR.INC"
.INCLUDE "TILE_JRDEATH.INC"
.INCLUDE "TILE_OTTO.INC"
.INCLUDE "TILE_ANNA.INC"

;   MAZE TEXT?
.INCDIR "ASSETS"
.INCLUDE "TILE_MAZETXT.INC"