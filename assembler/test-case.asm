((.RAW #x00 #x01 #x02 #x03)
(.LABEL OVER-HERE)
(.BYTE RANDOM-LABEL #xAA)
(.WORD ANOTHER-LABEL #xBABE)
(.DATA WOAH-DATA #xFF #xFE #xFD #xFC)
(.ASCII A-STRING "HELLO WORLD")
(.ASCIZ B-STRING "GOODBYE")
(NO-OPERATION)
(HALT)
(ADD R0 R1)
(ADD-CARRY R2 R3)
(SUBTRACT R5 R6)
(AND R7 R8)
(IOR R9 RA)
(XOR RB RC)
(NOT RD)
(SHIFT-RIGHT RE)
(INCREMENT RF)
(DECREMENT R0)
(INTERRUPT #xBA)
(RETURN-INTERRUPT)
(PUSH-DATA R1)
(POP-DATA R2)
(PEEK-DATA R3)
(PUSH-RETURN R4)
(POP-RETURN R5)
(CLEAR R6)
(MOVE R7 R7)
(LOAD-CONSTANT #xFF R8)
(NO-OPERATION)
(JUMP OVER-HERE)
(NO-OPERATION)
(JUMP-INDIRECT #xFF00)
(JUMP-REGISTER R9 RA)
(JUMP-INDIRECT-REGISTER RB RC)
(JUMP-AUTOINCREMENT RD RE)
(JUMP-INDIRECT-AUTOINCREMENT RF R0)
(JUMP-OFFSET R1 R2 #x00FF)
(JUMP-INDIRECT-OFFSET R3 R4 #xFF00)
(JUMP-IF-ZERO #x00FF)
(JUMP-IF-SIGN #x00FF)
(JUMP-IF-CARRY #x00FF)
(JUMP-SUBROUTINE #x00FF)
(RETURN-SUBROUTINE)
(LOAD #xFF00 R5)
(LOAD-INDIRET WOAH-DATA R6)
(LOAD-REGISTER R7 R8 R9)
(LOAD-REGISTER-INDIRECT RA RB RC)
(LOAD-REGISTER-AUTOINCREMENT RD RE RF)
(LOAD-REGISTER-INDIRECT-AUTOINCREMENT R0 R1 R2)
(LOAD-OFFSET R3 R4 #x00FF R5)
(LOAD-INDIRECT-OFFSET R5 R6 #x00FF R7)
(STORE R8 #xFF00)
(STORE-INDIRET R9 #xFF00)
(STORE-REGISTER RA RB RC)
(STORE-REGISTER-INDIRECT RD RE RF)
(STORE-REGISTER-AUTOINCREMENT R0 R1 R2)
(STORE-REGISTER-INDIRECT-AUTOINCREMENT R3 R4 R5)
(STORE-OFFSET R6 R7 R8 #x00FF)
(STORE-INDIRECT-OFFSET R9 RA RB #xFF00))
