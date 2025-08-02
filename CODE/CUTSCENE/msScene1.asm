/*
-------------------------------------------------------
                CUTSCENE 2 [MS. PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@msScene1:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CUTSCENE 2 SETUP FOR MS. PAC
    LD HL, msScene1ProgTable
    CALL msCutSetup
;   PLAY MUSIC
    LD A, MUS_INTER1_MS
    CALL sndPlayMusic
;   DISPLAY CUTSCENE'S ACT TITLE AND NUMBER
    LD DE, msScene1Title
    CALL msCutDisplayAct
@@draw:
;   DO COMMON DRAW AND UPDATE
    JP msSceneCommonDrawUpdate
@@update:
;   END