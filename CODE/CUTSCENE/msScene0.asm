/*
-------------------------------------------------------
                CUTSCENE 1 [MS. PAC-MAN]
-------------------------------------------------------
*/
sStateCutsceneTable@msScene0:
@@checkState:
    LD A, (isNewState)  ; CHECK TO SEE IF THIS IS A NEW STATE
    OR A
    JR Z, @@draw        ; IF NOT, SKIP TRANSITION CODE
@@enter:
;   CUTSCENE 1 SETUP FOR MS. PAC
    LD HL, msScene0ProgTable
    CALL msCutSetup
;   PLAY MUSIC
    LD A, MUS_INTER0_MS
    CALL sndPlayMusic
;   DISPLAY CUTSCENE'S ACT TITLE AND NUMBER
    LD DE, msScene0Title
    CALL msCutDisplayAct
@@draw:
;   DO COMMON DRAW AND UPDATE
    JP msSceneCommonDrawUpdate
@@update:
;   END

