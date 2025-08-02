/*
------------------------------------------------
            TRANSITIONS FOR GHOSTS
------------------------------------------------
*/
ghostGameTrans_normal:
;   CHECK IF GHOST IS ALIVE
    BIT 0, (IX + ALIVE_FLAG)
    RET Z   ; IF NOT, END
;   CLEAR VISIBLY SCARED FLAG
    LD (IX + EDIBLE_FLAG), $00
    RET
    

ghostGameTrans_super:
;   SET REVERSE FLAG
    LD (IX + REVE_FLAG), $01
;   SET VISIBLY SCARED FLAG
    LD (IX + EDIBLE_FLAG), $01
    RET


ghostGameTrans_dotExpire:
;   CHECK IF GHOST IS IN REST MODE
    LD A, (IX + STATE)
    CP A, GHOST_REST
    RET NZ  ; IF NOT, END
;   SWITCH TO "GOTO EXIT" MODE
    LD (IX + STATE), GHOST_GOTOEXIT
    LD (IX + NEW_STATE_FLAG), $01
    RET