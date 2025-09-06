/*
------------------------------------------------
            STATE TRANSITION ROUTINES
------------------------------------------------
*/
pacGameTrans_normal:
;   PAC-MAN IS IN NORMAL STATE
    LD A, PAC_NORMAL
    JP +
pacGameTrans_super:
;   PAC-MAN IS IN SUPER STATE
    LD A, PAC_SUPER
    JP +
pacGameTrans_dead:
;   PAC-MAN IS IN DEAD STATE
    LD A, PAC_DEAD
+
    ; SET STATE
    LD (pacman.state), A
;   PAC-MAN IS IN NEW STATE (SET FLAG)
    LD A, $01
    LD (pacman.newStateFlag), A
    RET