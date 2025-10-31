/*
----------------------------------------------
        DEFINES FOR ATTRACT MODE (TEMP RAM)
----------------------------------------------
*/
;       ALL
.DEFINE     lineMode            workArea
;       TITLE
.DEFINE     pacAniCounter       workArea + $01
.DEFINE     pacPos              workArea + $02  ; 2 BYTES
.DEFINE     pacBase             workArea + $04  ; 2 BYTES
;       OPTION
.DEFINE     sndTestIndex        workArea + $01
;       INTRO
.DEFINE     introSubState       workArea + $01
;       MS INTRO
.DEFINE     marqueePalBuffer    workArea + $10  ; 12 BYTES
;       DEMO
.DEFINE     gOverSpriteBuffer   workArea + $10  ; 12 BYTES


;   TITLE CONSTS
.DEFINE     P1_SPR_POS          72 * $100 + 85
.DEFINE     P2_SPR_POS          P1_SPR_POS + 16
.DEFINE     OP_SPR_POS          P2_SPR_POS + 16
;   OPTION CONSTS
.DEFINE     LIVES_YPOS          $03   
.DEFINE     DIFF_YPOS           $06
.DEFINE     BONUS_YPOS          $09
.DEFINE     SPEED_YPOS          $0C
.DEFINE     STYLE_YPOS          $0F
.DEFINE     SND_YPOS            $12
.DEFINE     HELP_YPOS           $15

/*
----------------------------------------------
    SUB STATE TABLE FOR ATTRACT MODE
----------------------------------------------
*/
sStateAttractTable:
    .dw @titleMode          ; 00
    .dw @demoInputCheck     ; 01 [READY 01]
    .dw @demoInputCheck     ; 02 [NORMAL]
    .dw @demoInputCheck     ; 03 [DEAD 00]
    .dw @demoInputCheck     ; 04 [DEAD 01]
    .dw @demoInputCheck     ; 05 [DEAD 02]
    .dw @optionsMode        ; 06
    .dw @introMode          ; 07
    .dw @demoInputCheck     ; 08 [GAME OVER]
    .DW @msIntroMode        ; 09
    .dw @introMode          ; 0A    CRAZY OTTO
    .DW @jrIntroMode

/*
----------------------------------------------
            ATTRACT MODE CODE
----------------------------------------------
*/
.INCLUDE "title.asm"
.INCLUDE "options.asm"
.INCLUDE "intro.asm"
.INCLUDE "msIntro.asm"
.INCLUDE "jrIntro.asm"
.INCLUDE "demo.asm"

.INCLUDE "functions.asm"    ; COMMON FUNCTIONS


.UNDEFINE   lineMode
.UNDEFINE   pacAniCounter, pacPos, pacBase
.UNDEFINE   sndTestIndex
.UNDEFINE   introSubState, marqueePalBuffer, gOverSpriteBuffer

