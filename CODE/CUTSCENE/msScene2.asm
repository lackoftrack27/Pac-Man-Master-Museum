/*
-------------------------------------------------------
                CUTSCENE 3 [MS. PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@msScene2:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CUTSCENE 3 SETUP FOR MS. PAC
    LD HL, msScene2ProgTable
    CALL msCutSetup
;   PLAY MUSIC
    LD A, MUS_INTER2_MS
    CALL sndPlayMusic
;   DISPLAY CUTSCENE'S ACT TITLE AND NUMBER
    LD DE, msScene2Title
    CALL msCutDisplayAct
@@draw:
;   DO COMMON DRAW AND UPDATE
    JP msSceneCommonDrawUpdate
@@update:
;   END