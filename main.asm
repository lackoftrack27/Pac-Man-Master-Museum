;   SET INCLUDE DIRECTORY
.INCDIR "CODE"
;   INCLUDES
.INCLUDE "structs.inc"
.INCLUDE "constants.inc"
.INCLUDE "banking.inc"
.INCLUDE "ramLayout.inc"
/*
----------------------------------------------------------
                SDSC TAG AND SMS HEADER
----------------------------------------------------------
*/
.SDSCTAG 2.00, sdscName, sdscDesc, sdscAuth

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
                    JUMP TABLE EXECUTION
----------------------------------------------------------
    INFO: JUMPS TO AN ADDRESS GIVEN A TABLE ADDRESS AND OFFSET
    INPUT: HL - TABLE ADDRESS, A - OFFSET
    OUTPUT: NONE
    USES: HL, AF
*/
.ORG $0008
.SECTION "Jump Table Execution" FORCE
jumpTableExec:
    ADD A, A
    RST addToHL
    INC HL
    LD H, (HL)
    LD L, A
    JP (HL)
    .DSB $02, $00   ; FILL
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

;   UNUSED
.ORG $0028
    .DSB $08, $00

;   UNUSED
.ORG $0030
    .DSB $08, $00

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
;   CHECK IF VBLANK OCCURED
    IN A, (VDPCON_PORT)
    OR A
    JP P, lineIntHandler    ; IF NOT, HANDLE LINE INTERRUPT
;   SET VBLANK FLAG
    LD HL, vblankFlag
    INC (HL)
;   DO SOUND PROCESSING
    CALL sndProcess
@end:
;   RESTORE REGS
    EXX     ; BC', DE', HL' -> BC, DE, HL
    POP AF
;   ENABLE INTERRUPTS AND RETURN
    EI 
    RET
    ;.DSB $06, $00   ; FILL
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
;   CREATE SPECIAL PRIORITY TILE AT INDEX $BF
    LD HL, BACKGROUND_ADDR + ($BF * TILE_SIZE) | VRAMWRITE
    RST setVDPAddress
    ; WRITE 32 BYTES OF $FF ($0F INDEX)
    DEC C   ; VDP DATA PORT
    LD B, TILE_SIZE
    LD A, $FF
-:
    OUT (C), A
    DJNZ -
;   LOAD HUD TEXT TILES
    LD HL, hudTextTiles
    LD DE, HUDTEXT_ADDR | VRAMWRITE
    CALL zx7_decompressVRAM
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
    LD HL, vblankFlag
    BIT 0, (HL)
    JR Z, mainGameLoop      ; IF NOT, KEEP WAITING...
;   VBLANK HAS OCCURED
    LD (HL), $00            ; CLEAR VBLANK FLAG
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
    BIT RESET_BTN, A
    JR Z, +             ; IF NOT PRESSED, SKIP...
    CALL sndStopAll     ; STOP ALL SOUND
    RST boot            ; GO BACK TO BEGINNING OF PROGRAM
+:
;   CHECK IF START WAS PRESSED (MD CONTROLLER)
    LD A, (mdControlFlag)
    OR A
    CALL NZ, checkMDPause
;   CHECK PAUSE
    LD A, (pauseRequest)
    OR A
    JR NZ, pauseMode    ; IF PASUE BUTTON WAS PRESSED (AND HONORED), SWITCH TO PAUSE "MODE"
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
    RST addToHL
    RST getDataAtHL
    ; EXECUTE SUB STATE'S FUNCTION
    LD A, (subGameMode)
    RST jumpTableExec
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
;   SPRITE FLICKER CODE
    CALL sprOverflowCheck
    JR mainGameLoop
.ENDS

/*
----------------------------------------------------------
                    PAUSE "MODE"
----------------------------------------------------------
*/
.SECTION "Pause Mode and Related Functions" FORCE
pauseMode:
;   CHECK IF BIT 1 OF PAUSE REQUEST IS SET (IF BUTTON WAS PRESSED DURING PAUSE)
    BIT UNPAUSE_REQ, A
    JR NZ, @exit    ; IF SO, THEN EXIT
;   CHECK IF BIT 2 IS SET   (IF THIS MODE IS NOT NEW)
    BIT NEW_PAUSE, A
    JR NZ, @update  ; IF SO, SKIP TRANSITION CODE
@enter:
;   SET BIT 2 (MODE ISN'T NEW)
    OR A, $01 << NEW_PAUSE
    LD (pauseRequest), A
@update:
;   PREPARE VDP ADDRESS
    LD HL, NAMETABLE + XUP_TEXT | VRAMWRITE
    RST setVDPAddress
    LD BC, HUD_SIZE * $100 + VDPDATA_PORT    ; 10 TILES
;   INCREMENT "PAUSE" FLASH COUNTER
    LD HL, xUPCounter
    INC (HL)
;   CHECK IF BIT 4 OF FLASH COUNTER IS SET (CYCLES EVERY 16 FRAMES)
    BIT 4, (HL)
    JR NZ, +    ; IF SO, CLEAR 'PAUSE'
;   DISPLAY "PAUSE" TILES
    ; WRITE TO VDP
    LD HL, hudTileMaps@pause
    OTIR
    JP mainGameLoop
;   "PAUSE" WILL NOT BE DISPLAYED
+:
    XOR A   ; CLEAR "PAUSE" TILES
-:
    ; WRITE TO VDP
    OUT (VDPDATA_PORT), A
    DJNZ -
    JP mainGameLoop
@exit:
;   CLEAR VARIABLES
    XOR A
    LD (pauseRequest), A
;   EXIT
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
;   SAVE CONTROL 1 STATUS
    LD A, (controlPort1)
    PUSH AF
;   GET INPUTS (A, START)
    LD A, (IX + 0)  ; TIME WASTE
    IN A, CONTROLPORT1
    CPL
    LD (controlPort1), A
;   DEBOUNCE
    CALL getPressedInputs
;   RESTORE CONTROL 1 STATUS
    POP AF
    LD (controlPort1), A
;   SET TH TO LOW INPUT
    LD A, $01 << P1_TR_DIR | $01 << P1_TH_DIR | $01 << P2_TR_DIR | $01 << P2_TH_DIR
    OUT (IO_CONTROL), A
;   CHECK IF START IS PRESSED
    LD A, (pressedButtons)
    BIT P1_BTN_2, A    
    JP NZ, pauseVector   ; IF SO, GO TO PAUSE VECTOR
    RET
.ENDS
/*
----------------------------------------------------------
                LINE INTERRUPT HANDLER
----------------------------------------------------------
*/
.SECTION "LINE INTERRUPT HANDLER" FORCE
lineIntHandler:
;   NO LINE INT HANDLER FOR NOW...
;   GO BACK TO RETURN FROM INTURRUPT
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


/*
----------------------------------------------------------
        DATA FOR PAC-MAN (PLAYER) AND GENERAL ACTOR
----------------------------------------------------------
*/
.INCDIR "CODE/PACMAN"
.SECTION "Pac-Man (Player) Data" FORCE
    .INCLUDE "pacmanData.asm"
.ENDS

/*
----------------------------------------------------------
                    DATA FOR GHOSTS
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
.SECTION "Sound Data" FORCE
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
    .DB "A conversion of the arcade classics for the Sega Master System", 0
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
    .db $FF         ; VRAM NAME TABLE AT $3800...
    .db $82         ; FOR REG 02 (NAME TABLE BASE ADDR)
    ;----------------------
    .db $FF         ; VRAM COLOR TABLE BASE ADDR (NORMAL OPERATION)
    .db $83         ; FOR REG 03 (COLOR TABLE BASE ADDR)
    ;----------------------
    .db $FF         ; PATTERN GEN. TABLE BASE ADDR (NORMAL OPERATION)
    .db $84         ; FOR REG 04 (PATTERN GEN. TABLE BASE ADDR)
    ;----------------------
    ;.db $FF         ; SPRITE ATTR. TABLE AT $3F00...
    .DB ($3F << $01) | $C1
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
    $0E - IN MAZE TEXT
    $0F - SPRITE MASK (BLACK)
*/
;   MAZE BACKGROUND PALETTES
bgPalPac:
    .DB $00 $30 $00 $20 $20 $00 $3B $2B $00 $00 $16 $2B $2B $2B $03 $00
bgPalPlus:
    .DB $00 $29 $00 $14 $14 $00 $3B $2B $00 $00 $16 $2B $2B $2B $03 $00
bgPalMs00:
    .DB $00 $03 $2B $02 $02 $00 $3B $3F $00 $00 $2A $3F $3F $3F $03 $00
bgPalMs01:
    .DB $00 $3F $38 $2A $2A $00 $3B $0F $00 $00 $0A $0F $0F $0F $03 $00
bgPalMs02:
    .DB $00 $3F $1B $2A $2A $00 $3B $03 $00 $00 $02 $03 $03 $03 $03 $00
bgPalMs03:
    .DB $00 $1B $30 $06 $06 $00 $3B $3F $00 $00 $2A $3F $3F $3F $03 $00
bgPalMs04:
    .DB $00 $0F $3B $0A $0A $00 $3B $3C $00 $00 $28 $3C $3C $3C $03 $00
bgPalMs05:
    .DB $00 $3C $30 $28 $28 $00 $3B $3F $00 $00 $2A $3F $3F $3F $03 $00
bgPalMs06:
    .DB $00 $03 $3F $02 $02 $00 $3B $0C $00 $00 $08 $0C $0C $0C $03 $00
bgPalMs07:
    .DB $00 $1B $0C $06 $06 $00 $3B $1B $00 $00 $06 $1B $1B $1B $03 $00
bgPalMs08:
    .DB $00 $03 $30 $02 $02 $00 $3B $3F $00 $00 $2A $3F $3F $3F $03 $00


; SPRITE PALETTE ("SMOOTH")
sprPalData:
    .db $00     ; BLACK (TRANSPARENT)
    .db $0F     ; YELLOW (PAC-MAN)
    .db $0A     ; DARK YELLOW (PAC-MAN SHADING)
    .db $03     ; RED (BLINKY)
    .db $02     ; DARK RED (BLINKY SHADING)
    .db $3B     ; PINK (PINKY)
    .db $26     ; DARK PINK (PINKY SHADING)
    .db $3C     ; CYAN (INKY)
    .db $28     ; DARK CYAN (INKY SHADING)
    .db $0B     ; ORANGE (CLYDE)
    .db $06     ; DARK ORANGE (CLYDE SHADING)
    .db $3F     ; WHITE (SCARED GHOST)
    .db $2A     ; GREY (SCARED GHOST SHADING)
    .db $30     ; BLUE (SCARED GHOST)
    .db $20     ; DARK BLUE (SCARED GHOST SHADING)
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
    .DW $19AA $19AB $19AC $19AA $1900
    .DW $19AD $19AE $19AF $19B0 $19B1
@oneUP:
;   "1UP"
    .DW $19B6 $19B2 $19B3 $1900 $1900
@twoUP:
;   "2UP"
    .DW $19B7 $19B2 $19B3 $1900 $1900
@pause:
;   "PAUSE"
    .DW $19B3 $19B4 $19B2 $19AD $19B1
@lives:
;   PAC-MAN
    .DW $182C $1825 $183A $1834 ; LEFT HALF
@msLives:
;   MS. PAC-MAN
    .DW $1829 $182A $183F $1840 ; RIGHT HALF

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
                    COMMON TABLES
----------------------------------------------------------
*/
.SECTION "COMMON TABLES" FREE
/*
    COLOR TABLE FOR POWER DOT PALETTE CYCLING
*/
powDotPalTable:
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
    ghostPointsDefs (GSCORE_VRAM / TILE_SIZE)


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
    fruitSprDef (FRUIT_VRAM / TILE_SIZE)
    ; FRUIT 1
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $02
    ; FRUIT 2
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $04
    ; FRUIT 3
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $06
    ; FRUIT 4
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $08
    ; FRUIT 5
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $0A
    ; FRUIT 6
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $0C
    ; FRUIT 7
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $0E

msFruitTileDefsHUD:
    ; FRUIT 0
    fruitSprDef (FRUIT_VRAM / TILE_SIZE)
    ; FRUIT 1
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $02
    ; FRUIT 2
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $04
    ; FRUIT 3
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $06
    ; FRUIT 4
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $08
    ; FRUIT 5
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $0E  ; PEAR FOR HUD
    ; FRUIT 6
    fruitSprDef (FRUIT_VRAM / TILE_SIZE) + $0C



/*
    FRUIT POINT TILE INDEXES
*/
.MACRO fruitPointsDefs  ARGS, VAL
    .DB VAL, $00, VAL+$04, $00      ; 100
    .DB VAL+$01, $00, VAL+$04, $00  ; 300
    .DB VAL+$02, $00, VAL+$04, $00  ; 500
    .DB VAL+$03, $00, VAL+$04, $00  ; 700
    .DB VAL+$05, $00, VAL+$09, $00  ; 1000
    .DB VAL+$06, $00, VAL+$09, $00  ; 2000
    .DB VAL+$07, $00, VAL+$09, $00  ; 3000
    .DB VAL+$08, $00, VAL+$09, $00  ; 5000
.ENDM
fruitPointTileDefs:
    fruitPointsDefs (FSCORE_VRAM / TILE_SIZE)



.MACRO msFruitPointsDefs  ARGS, VAL
    .DB VAL, $00, VAL+$01, VAL+$09          ; 100
    .DB VAL+$02, $00, VAL+$01, VAL+$09      ; 200
    .DB VAL+$03, $00, VAL+$01, VAL+$09      ; 500
    .DB VAL+$04, $00, VAL+$01, VAL+$09      ; 700
    .DB VAL+$05, VAL+$0A, VAL+$06, VAL+$0B  ; 1000
    .DB VAL+$07, VAL+$0A, VAL+$06, VAL+$0B  ; 2000
    .DB VAL+$08, VAL+$0A, VAL+$06, VAL+$0B  ; 5000
.ENDM
msFruitPointTileDefs:
    msFruitPointsDefs   (FSCORE_VRAM / TILE_SIZE)



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
levelTableHard:
    .DB $01 $03 $04 $06 $07 $08 $09 $0a $0b $0c $0d $0e $0f $10 $11 $14 


/*
    [PAC-MAN AND MS. PAC-MAN LEVEL DIFFICULTY TABLE]
    EACH LINE REPRESENTS A LEVEL
    BYTE 0: SPEED PATTERN INDEX
    BYTE 1: UNUSED
    BYTE 2: GHOST DOT COUNT INDEX
    BYTE 3: BLINKY SPEED UP INDEX
    BYTE 4: POWER DOT TIME INDEX
    BYTE 5: DOT EXPIRE INDEX
*/
difficultyTable:
    .DB 03 01 01 00 02 00
    .DB 04 01 02 01 03 00
    .DB 04 01 03 02 04 01
    .DB 04 02 03 02 05 01
    .DB 05 00 03 02 06 02
    .DB 05 01 03 03 03 02
    .DB 05 02 03 03 06 02
    .DB 05 02 03 03 06 02
    .DB 05 00 03 04 07 02
    .DB 05 01 03 04 03 02
    .DB 05 02 03 04 06 02
    .DB 05 02 03 05 07 02
    .DB 05 00 03 05 07 02
    .DB 05 02 03 05 05 02
    .DB 05 01 03 06 07 02
    .DB 05 02 03 06 07 02
    .DB 05 02 03 06 08 02
    .DB 05 02 03 06 07 02
    .DB 05 02 03 07 08 02
    .DB 05 02 03 07 08 02
    .DB 06 02 03 07 08 02


/*
    [PAC-MAN PLUS LEVEL DIFFICULTY TABLE]
    EACH LINE REPRESENTS A LEVEL
    BYTE 0: SPEED PATTERN INDEX
    BYTE 1: FRUIT TIME INDEX
    BYTE 2: GHOST DOT COUNT INDEX
    BYTE 3: BLINKY SPEED UP INDEX
    BYTE 4: POWER DOT TIME INDEX
    BYTE 5: DOT EXPIRE INDEX
*/
@plus:
    .DB 05 02 02 01 04 00
    .DB 05 02 03 02 05 00
    .DB 05 03 03 03 06 01
    .DB 05 04 03 03 06 01
    .DB 05 05 03 04 06 02
    .DB 05 03 03 04 04 02
    .DB 05 05 03 05 06 02
    .DB 05 05 03 05 07 02
    .DB 05 06 03 05 07 02
    .DB 05 04 03 06 06 02
    .DB 05 06 03 06 07 02
    .DB 05 06 03 06 08 02
    .DB 05 06 03 06 08 02
    .DB 05 04 03 05 06 02
    .DB 05 06 03 06 08 02
    .DB 06 06 03 06 07 02
    .DB 06 06 03 07 08 02
    .DB 06 06 03 07 06 02
    .DB 06 07 03 07 08 02
    .DB 06 07 03 07 08 02
    .DB 06 08 03 07 08 02


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
.SECTION "MS. PAC-MAN TABLES" BANK 2 SLOT 2 FREE    ; PUT IN BANK 2, SLOT 2

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
    .DW bgPalPac    ; 09 [PLUS]

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
    .DB $01 $01 $01 $01 ; LVL 10 - 13
    .DB $08 $08 $08 $08 ; LVL 14 - 17
    .DB $09 $09 $09 $09 ; LVL 18 - 21

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
.DEFINE B_U     $FF00
.DEFINE B_R     $FFFF 
.DEFINE B_L     $0001
.DEFINE B_D     $0100
.DEFINE B_UR    $FEFF
.DEFINE B_DR    $00FF
.DEFINE B_UL    $FF01
.DEFINE B_DL    $0101
.DEFINE B_Z     $0000

fruitBounceFrames:
    ; UP:       U U U U U U U U U Z U Z Z D Z D
    ; UP_6:     U U U Z U U U Z U Z U Z Z D Z D
    .DW B_U, B_U, B_U, B_U, B_U, B_U, B_U, B_U, B_U, B_Z, B_U, B_Z, B_Z, B_D, B_Z, B_D
    ; RIGHT:    Z UR Z R Z UR Z R Z R Z R Z DR DR Z
    ; RIGHT_6:  Z UR Z R Z UR Z Z Z R Z R Z DR D Z
    .DW B_Z, B_UR, B_Z, B_R, B_Z, B_UR, B_Z, B_R, B_Z, B_R, B_Z, B_R, B_Z, B_DR, B_DR, B_Z
    ; LEFT:     Z Z UL Z L Z UL Z L Z L Z L Z DL DL
    ; LEFT_6:   Z Z UL Z L Z UL Z Z Z L Z L Z DL D
    .DW B_Z, B_Z, B_UL, B_Z, B_L, B_Z, B_UL, B_Z, B_L, B_Z, B_L, B_Z, B_L, B_Z, B_DL, B_DL
    ; DOWN:     Z D D D D D D D D D D D U U Z U
    ; DOWN_6:   Z D D D Z D D D Z D D D U U Z U
    .DW B_Z, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_D, B_U, B_U, B_Z, B_U
.ENDS




/*
----------------------------------------------------------
                    IN GAME HUD DATA
----------------------------------------------------------
*/
.INCDIR "ASSETS"
.SECTION "HUD GFX DATA" FREE
    hudTextTiles:
        .INCBIN "TILE_HUD.ZX7"
    mazeTextTiles:
        .INCBIN "TILE_MAZETXT.ZX7"
.ENDS


/*
----------------------------------------------------------
                ATTRACT MODE GFX DATA
----------------------------------------------------------
*/
.INCDIR "ASSETS/ATTRACT"
.SECTION "ATTRACT MODE GFX DATA" FREE
;   TITLE
    titleTileData:
        .INCBIN "TILE_TITLE.ZX7"
    titleTileMap:
        .INCBIN "MAP_TITLE.ZX7"
;   OPTIONS
    optionsTileData:
        .INCBIN "TILE_OPTIONS.ZX7"
;   TITLE/OPTIONS
    titleArrowData:
        .INCBIN "TILE_ARROW.ZX7"
    titlePal:
        .INCBIN "PAL_TITLE.BIN"
;   INTRO
    introTileData:
        .INCBIN "TILE_INTRO.ZX7"
;   MS INTRO
    msIntroTileData:
        .INCBIN "TILE_MSINTRO.ZX7"
;   MS MARQUEE
    msMarqueeTileData:
        .INCBIN "TILE_MARQUEE.ZX7"
.ENDS





;   BANK CHANGE
.BANK SMOOTH_BANK SLOT 2



/*
----------------------------------------------------------
                        MAZE DATA
----------------------------------------------------------
*/
.SECTION "MAZE DATA" FREE
;   MAZE 0
.INCDIR "ASSETS/MAZE0"
    mazeCollsionData:
        .INCBIN "COL_MAZE.ZX7"
    mazeTileMap:
        .INCBIN "MAP_MAZE.ZX7"
    maze0Tiles:
        .INCBIN "TILE_MAZE.ZX7"
    maze0EatenTable:
        .INCBIN "DOT_MAZE.ZX7"
    @powDots:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 1
.INCDIR "ASSETS/MAZE1"
    maze1ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze1TileMap:
        .INCBIN "MAP_MAZE.ZX7"
    maze1Tiles:
        .INCBIN "TILE_MAZE.ZX7"
    maze1DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze1PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 2
.INCDIR "ASSETS/MAZE2"
    maze2ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze2TileMap:
        .INCBIN "MAP_MAZE.ZX7"
    maze2Tiles:
        .INCBIN "TILE_MAZE.ZX7"
    maze2DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze2PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 3
.INCDIR "ASSETS/MAZE3"
    maze3ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze3TileMap:
        .INCBIN "MAP_MAZE.ZX7"
    maze3Tiles:
        .INCBIN "TILE_MAZE.ZX7"
    maze3DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze3PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
;   MAZE 4
.INCDIR "ASSETS/MAZE4"
    maze4ColData:
        .INCBIN "COL_MAZE.ZX7"
    maze4TileMap:
        .INCBIN "MAP_MAZE.ZX7"
    maze4Tiles:
        .INCBIN "TILE_MAZE.ZX7"
    maze4DotTable:
        .INCBIN "DOT_MAZE.ZX7"
    maze4PowTable:
        .INCBIN "PDOT_MAZE.ZX7"
.ENDS


/*
----------------------------------------------------------
                    ACTOR TILE DATA
----------------------------------------------------------
*/
.SECTION "ACTOR GFX DATA" FREE
    .INCDIR "ASSETS/GAMEPLAY/SMOOTH"
    pacmanTiles:
        .INCBIN "TILE_PAC.ZX7"
    @plus:
        .INCBIN "TILE_PAC_PLUS.ZX7"
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
    pacDeathTiles:
        .INCBIN "TILE_DEATH.ZX7"
    msPacTiles:
        .INCBIN "TILE_MSPAC.ZX7"
    msFruitTiles:
        .INCBIN "TILE_MSFRUIT.ZX7"
    msFruitPointTiles:
        .INCBIN "TILE_MSFPOINTS.ZX7"
.ENDS

/*
----------------------------------------------------------
                    CUTSCENE TILE DATA
----------------------------------------------------------
*/
.SECTION "CUTSCENE GFX DATA" FREE
    .INCDIR "ASSETS/CUTSCENE/SMOOTH"
    cutscenePacTiles:
        .INCBIN "TILE_PAC.ZX7"
    cutsceneGhostTiles:
        .INCBIN "TILE_GHOST.ZX7"
    @plus:
        .INCBIN "TILE_GHOST_PLUS.ZX7"
    msCutsceneTiles:
        .INCBIN "TILE_MSCUT.ZX7"
.ENDS



;   BANK CHANGE
.BANK ARCADE_BANK SLOT 2
.ORG $0000

/*
----------------------------------------------------------
                ACTOR TILE DATA [ARCADE]
----------------------------------------------------------
*/
.INCDIR "ASSETS/GAMEPLAY/ARCADE"
arcadeGFXData:
    @pacman:
        .INCBIN "TILE_PAC.ZX7"
    @pacmanPlus:
        .INCBIN "TILE_PAC_PLUS.ZX7"
    @ghosts:
        .INCBIN "TILE_GHOSTS.ZX7"
    @ghostsPlus:
        .INCBIN "TILE_GHOSTS_PLUS.ZX7"
    @pacDeath:
        .INCBIN "TILE_DEATH.ZX7"
    @fruit:
        .INCBIN "TILE_FRUIT.ZX7"
    @fruitPlus:
        .INCBIN "TILE_FRUIT_PLUS.ZX7"
    @msPacman:
        .INCBIN "TILE_MSPAC.ZX7"
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
.INCDIR "ASSETS/CUTSCENE/ARCADE"
    @cutscenePac:
        .INCBIN "TILE_PAC.ZX7"
    @cutsceneGhost:
        .INCBIN "TILE_GHOST.ZX7"
    @cutsceneGhostPlus:
        .INCBIN "TILE_GHOST_PLUS.ZX7"
    @cutsceneMs:
        .INCBIN "TILE_MSCUT.ZX7"





;   BANK CHANGE
.BANK RNG_BANK SLOT 2

/*
----------------------------------------------------------
        8KB OF ORIGINAL GAME DATA FOR RNG FUNCTION
----------------------------------------------------------
*/
.SECTION "ORIGINAL GAME DATA FOR RNG" FREE
    .INCDIR "ASSETS"
    rngDataOffset:
        .INCBIN "PAC_RNG.BIN"   ; 8KB
    @plus:
        .INCBIN "PLUS_RNG.BIN"  ; 8KB
.ENDS