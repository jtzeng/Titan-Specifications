; Titan Microcode
; Copyright (C) 2012 Marc Cleave, bootnecklad@gmail.com
; Assume that all bits are L unless specified here
; [H] - Set bit high until turned L
; [L] - Set bit L
; [S] - Set bit on only for that microinstruction
; 
; Key:
; H - High
; L - Low
; R - Read
; W - Write
;
; eg IR1_L_R
;
; Instruction register 1 low nybble to read register
;
; The actual PROMs used are 65536*16...
;
; The microcode stored in the PROMs is arranged as 512words by 32bits so in hex
; (filled with all 1's and NEXT address pointing to the next address)
; would look like the following:

; ADDR  PROM0  PROM1  NEXT
; 00:   FFFF   FFFF   01
; 01:   FFFF   FFFF   02
; 02:   FFFF   FFFF   03
; ...
; FD:   FFFF   FFFF   FE
; FE:   FFFF   FFFF   FF
; FF:   FFFF   FFFF   00
;
; An important aspect of the microcode is the PROM that contains the next 
; address for the microinstructions, this is generated by the microassembler ..
;
; Every time the clock is incremented a new address is fetched from the
;'next microaddress PROM'.
;
; So effectively, evey clock pulse you execute a microcode instruction.
; This is because once a new address is fetched, then you have the
; output of the microcode PROMs. Its reasonably efficient.
;
; The first few microinstructions check for interrupts and deal with
; if needed, if not then they fetch a byte from the main memory and
; write it to the instruction register. The value in the instruction
; register is then used as a direct index to get the next address from
; the 'next microaddress prom'.
;
; Instruction execution continues from there, and when the instruction
; has finished executing then the sequencers last next microaddress will be 
; 00 and the whole process starts again

INSTRUCTION FETCH:
   0) MEM_OE[H], MEM_R[H], MEM_EN[H]
   1) W_IR0[S]

ADD,ADC,SUB,AND,LOR,XOR,NOT,SHR:
   0) INC_PC[S]  ; INCREMENTS PROGRAM COUNTER
   1) MEM_OE[H], MEM_R[H], MEM_EN[H]   ; ENABLES OPERAND TO BE READ FROM MEMORY
   2) W_IR1[S]   ; WRITES OPERAND TO OPERAND REGISTER
   3) IR1_H_R_REG[H], R_REG[H], MEM_OE[L], MEM_R[L], MEM_EN[L]   ; ROUTES H BYTE OF OPERAND TO READ REGISTER
   4) W_ALU_A[S]   ; WRITES A INPUT OF ALU
   5) IR1_L_R[H], IR1_H_R_REG[L], R_REG[L]   ; ROUTES L BYTE OF OPERAND TO READ REGISTER
   6) W_ALU_B[S]   ; WRITES B INPUT OF ALU
   7) ALU_DECODER[H], IR1_L_W_REG[H]   ; SELECTS ALU OPERATION, ROUTES LOW BYTE OF IR0 TO DECODER FOR ALU
   8) W_REG[S]   ; WRITES DESTINATION REGISTER

PUSH:
   0) IR0_L_R[H], R_REG[H], DB_STK_EN[H], STK_CLK[S]   ; ENABLES DATABUS INTO STACK, OUTPUTS SOURCE REGISTER, INCREMENTS STACK POINTER
   1) STK_WE[S]   ; WRITES TO THE STACK
   2) R_REG[L], INC_PC[S]

POP:
   0) IR0_L_W[H], STK_DB_EN[H]   ; ENABLES STACK TO DATABUS, PREPARES DESINATION REGISTER
   1) W_REG[S]   ; WRITES DESTINATION REGISTER
   2) INC_PC[S], DEC_STK[H]   ; STARTS PROCESS OF DECREMENTING THE STACK POINTER
   3) STK_CLK[S]   ; INVERT SP
   4) DEC_STK[L]
   5) STK_CLK[S]   ; INCREMENT SP
   6) DEC_STK[H]
   7) STK_CLK[S]   ; INVERT SP

MOV:
   0) INC_PC[S]
   1) MEM_OE[H], MEM_R[H], MEM_EN[H]   ; PREPARES FOR MEMORY READ
   2) W_IR1[S]   ; FETCHES OPERANDS
   3) IR1_H_R_REG[H], R_REG[H], IR1_L_W_REG[H], MEM_OE[L], MEM_R[L], MEM_EN[L]
   4) W_REG[S], INC_PC[S]

JMP:
   0) INC_PC[S]
   1) MEM_OE[H], MEM_R[H], MEM_EN[H]
   2) W_IR1[S]
   3) INC_PC[S], MEM_OE[L], MEM_R[L], MEM_EN[L]
   4) MEM_OE[H], MEM_R[H], MEM_EN[H]
   5) W_IR2[S]
   6) W_RE[H], OUT_IR2[H]
   7) W_REG[S]
   8) W_RF[H], OUT_IR2[L], OUT_IR1[H]
   9) W_REG[S]

JPZ,JPS,JPC:
   0) INC_PC[S]
   1) MEM_OE[H], MEM_R[H], MEM_EN[H]
   2) W_IR1[S]
   3) INC_PC[S], MEM_OE[L], MEM_R[L], MEM_EN[L]
   4) MEM_OE[H], MEM_R[H], MEM_EN[H]
   5) W_IR2[S]
   6) INC_PC[S]
   7) MC_RESET_EN[S]   ; IF THE FLAG IS SET OF THE INSTRUCTION THEN THE MICROCODE COUNTER IS RESET, INSTRUCTION DOESNT EXECUTE
   8) W_RE[H], OUT_IR2[H]
   9) W_REG[S]
   A) W_RF[H], OUT_IR2[L], OUT_IR1[H]
   B) W_REG[S]

JPI:
   0) INC_PC[S]
   1) MEM_OE[H], MEM_R[H], MEM_EN[H]
   2) W_IR1[S]
   3) INC_PC[S], MEM_OE[L], MEM_R[L], MEM_EN[L]
   4) MEM_OE[H], MEM_R[H], MEM_EN[H]
   5) W_IR2[S]
   6) IR_MEM_READ[H]
   7) MEM_OE[H], MEM_R[H], MEM_EN[H]
   8) W_IR1[S]
   9) INC_PC[S], MEM_OE[L], MEM_R[L], MEM_EN[L]
   A) MEM_OE[H], MEM_R[H], MEM_EN[H]
   B) W_IR2[S]
   C) W_RE[H], OUT_IR2[H]
   D) W_REG[S]
   E) W_RF[H], OUT_IR2[L], OUT_IR1[H]
   F) W_REG[S]

JSR:
   0) R_RE[H], R_REG[H], DB_STK_EN[H], STK_CLK[S]
   1) STK_WE[S]
   2) R_RF[H]
   3) STK_CLK[S]
   4) STK_WE[S]
   5) R_REG[L], DB_STK_EN[L]
   6) INC_PC[S]
   7) MEM_OE[H], MEM_R[H], MEM_EN[H]
   8) W_IR1[S]
   9) INC_PC[S], MEM_OE[L], MEM_R[L], MEM_EN[L]
   A) MEM_OE[H], MEM_R[H], MEM_EN[H]
   B) W_IR2[S]
   C) W_RE[H], OUT_IR2[H]
   D) W_REG[S]
   E) W_RF[H], OUT_IR2[L], OUT_IR1[H]
   F) W_REG[S]

RTN:
   0) R_RF[H], R_REG[H], STK_DB_EN[H], STK_OE[H]
   1) W_REG[S]
   2) R_REG[L], DECREMENT STACK_POINTER
   3) W_RF[H], STK_DB_EN[H]
   4) W_REG[S]
   5) R_REG OFF, INC_PC[S], DEC_STK[H]
   6) STK_CLK[S]
   7) DEC_STK[L]
   8) STK_CLK[S]
   9) DEC_STK[H]
   A) STK_CLK[S], INC_PC[S], 

JMI 0XZZZZ:
   0) INC_PC[S]
   1) MEM_OE[H], MEM_R[H], MEM_EN[H], W_RE[H]
   2) W_REG[S]
   3) INC_PC[S], W_RE[H], MEM_OE[L], MEM_R[L], MEM_EN[L]
   4) MEM_OE[H], MEM_R[H], MEM_EN[H]
   5) W_ALU_B[S]
   6) R_R1[H], R_REG[H]
   7) W_ALU_A[S]
   8) ALU_DECODER[H], W_RE[H]
   9) W_REG[S]
   A) MC_RESET_EN[S], CLR_ALU_B[S] ; IF THE FLAG IS SET, H BYTE OF PC NEEDS TO BE INCREMENT
   B) R_RF[H], R_REG[H]
   C) W_ALU_A[S]
   D) ALU_DECODER[H], W_RF[H]
   E) W_REG[S]

JMI [R1,R2]:
   0) 0X01->R_REG, 0XFF->W_REG
   1) W_REG
   2) 0X02->R_REG, 0XFE->W_REG
   3) W_REG

LDI 0XZZZZ:
   0) INC_PC[S]
   1) OUTPUT SIGNALS FOR MEMORY READ
   2) W IR1
   3) INC_PC[S]
   4) OUTPUT SIGNALS FOR MEMORY READ
   5) W ALU_B
   6) 0X01->R_REG
   7) W ALU_A, ADD TO ALU_DECODER
   8) W IR2, 0XD->MICROCODE_STEP   ; LOAD PREVIOUS STEP, THEN INCREMENT THEN STEP E WILL BE LOADED INTO MICROCODE REGISTERS
   9) NOT_MC_C TO LOAD MICROCODE_STEP, CLR ALU_B ; IF THE FLAG IS SET, H BYTE OF ADDRESS NEEDS TO BE INCREMENT
   A) OUTPUT IR0 TO DATABUS
   B) W ALU_A
   C) ADC TO ALU_DECODER
   D) W IR1
   E) ENABLE IR MEMORY READ SIGNAL, IR0_L->W_REG
   F) W_REG

STI 0XZZZZ:
   0) INC_PC[S]
   1) OUTPUT SIGNALS FOR MEMORY READ
   2) W IR1
   3) INC_PC[S]
   4) OUTPUT SIGNALS FOR MEMORY READ
   5) W ALU_B
   6) 0X01->R_REG
   7) W ALU_A, ADD TO ALU_DECODER
   8) W IR2, 0XD->MICROCODE_STEP   ; LOAD PREVIOUS STEP, THEN INCREMENT THEN STEP E WILL BE LOADED INTO MICROCODE REGISTERS
   9) NOT_MC_C TO LOAD MICROCODE_STEP, CLR ALU_B ; IF THE FLAG IS SET, H BYTE OF ADDRESS NEEDS TO BE INCREMENT
   A) OUTPUT IR0 TO DATABUS
   B) W ALU_A
   C) ADC TO ALU_DECODER
   D) W IR1
   E) ENABLE IR MEMORY W SIGNAL, IR0_L->R_REG
   F) W MEMORY

LDI [R1,R2]:
   0) 0X01->R_REG
   1) W IR1
   2) 0X02->R_REG
   3) W IR2
   4) ENABLE IR MEMORY READ SIGNAL, IR0_L->W_REG
   5) W_REG

STI [R1,R2]:
   0) 0X01->R_REG
   1) W IR1
   2) 0X02->R_REG
   3) W IR2
   4) ENABLE IR MEMORY W SIGNAL, IR0_L->R_REG
   5) W MEMORY

LDC:
   0) INC_PC[S]
   1) OUTPUT SIGNALS FOR MEMORY READ, IR0_L->W_REG
   2) W_REG

LDM:
   0) INC_PC[S]
   1) OUTPUT SIGNALS FOR MEMORY READ
   2) W IR1
   3) INC_PC[S]
   4) OUTPUT SIGNALS FOR MEMORY READ
   5) W IR2
   6) ENABLE IR MEMORY READ SIGNAL, IR0_L->W_REG
   7) W_REG

STM:
   0) INC_PC[S]
   1) OUTPUT SIGNALS FOR MEMORY READ
   2) W IR1
   3) INC_PC[S]
   4) OUTPUT SIGNALS FOR MEMORY READ
   5) W IR2
   6) ENABLE IR MEMORY W SIGNAL, IR0_L->R_REG
   7) W MEMORY