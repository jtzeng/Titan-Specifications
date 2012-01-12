; This is the basic MonitorOS for Titan.
; When assembled and the binary entered into Titan's memory, MonitorOS will show '>' prompt at the serial terminal.
; Bytes can be loaded into memory by typing a two byte address in hex, then a space, then the byte to be dumped.
;
; The below example shows 0xFE being entered into the address 0x0F07.
;
; > 0F07 FE
; >
;
; The following example shows the address 0x0F8A being read
;
; > 0F8A/FF
; >
;
; As you can see 0x0F8A contains the byte 0xFF
;
;
; This file is the MonitorOS for Marc Cleave's Titan Processor
; Copyright (C) 2011 Marc Cleave, bootnecklad@gmail.com
;
; This program is free software; you can redistribute it and/or modify
; it under the terms of the GNU General Public License as published by
; the Free Software Foundation; either version 2 of the License, or
; (at your option) any later version.
;
; This program is distributed in the hope that it will be useful,
; but WITHOUT ANY WARRANTY; without even the implied warranty of
; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
; GNU General Public License for more details.
; 
; You should have received a copy of the GNU General Public License
; along with this program; if not, write to the Free Software
; Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
;


BEGIN:
   LDC R2,0X01 ; NEEDED TO DECREMENT THINGS
   LDC R1,0X05 ; NUMBER OF BYTES TO GET FROM SERIAL PORT FIRST(FOUR BYTES OF ADDR AND 'COMMAND')
   LDC R5,0X30 ; VALUE TO TURN ASCII INTO BINARY VALUES
   LDC R0,0X0A ; ASCII VALUE OF LINE FEED
   STM R0,SERIAL_PORT_OUT ; OUTPUTS LINE FEED
   LDC R0,0X0D ; ASCII VALUE OF CARRIAGE RETURN
   STM R0,SERIAL_PORT_OUT ; OUTPUTS CARRIAGE RETURN
   LDC R0,0X3E ; ASCII Value of '>'
   STM R0,SERIAL_PORT_OUT ; OUTPUTS '>'

GET_INPUT_ADDR:
   LDM R0,SERIAL_PORT_IN
   TST R0
   JPZ GET_INPUT_ADDR
   PSH R0
   SUB R1,R2
   JPZ PARSE_INPUT_ADDR
   JMP GET_INPUT_ADDR

GET_INPUT_BYTE:
   LDC R1,0X02 ; number of bytes to be fetched from serial port
   LDM R0,SERIAL_PORT_IN
   TST R0 ; test to see if byte contains anything (if not, nothing was fetched)
   JPZ GET_INPUT_BYTE ; try again
   PSH R0
   SUB R1,R2 ; decrements counter
   JPZ STORE_BYTE
   JMP GET_INPUT_BYTE
   
STORE_BYTE:
   JSR MAKE_BYTE_OUTPUT
   STI R0,0X000 ; INDEXED STORE, USES R1 AND R2 FOR BASE ADDRESS
   JMP BEGIN

PARSE_INPUT_ADDR:
   LDC R1,0X2F ; ASCII VALUE FOR '/'
   XOR R1,R0 ; CHECKS IF LAST INPUT CHARACTER WAS A '/'
   JPZ CHECK_SPACE
   JMP READ_MEM
   LDC R1,0X20 ; ASCII VALUE FOR ' '
   XOR R1,R0 ; CHECKS IF LAST INPUT CHARACTER WAS ' '
   JPZ GET_INPUT_BYTE
   JMP BEGIN ; IF WRONG CHARACTER THEN STARTS AGAIN, USER MADE A DERP :<

READ_MEM:
   JSR MAKE_ADDR_LOW ; CREATES LOW BYTE OF ADDRESS FROM ASCII
   JSR MAKE_ADDR_HIGH ; CREATES HIGH BYTE OF ADDRESS FROM ASCII 
   JSR SWAP_ADDR ; SWAPS THE BYTES ROUND TO PREPARE FOR INDEXED LDM(THIS ISNT NEEDED, BUT XOR SWAPS ARE COOL)
   JSR LOAD_BYTE ; LOADS BYTE FROM MEMORY
   JSR MAKE_BYTE_OUTPUT ; TAKES DATA BYTE AND CONVERTS INTO TWO ASCII VALUES TO OUTPUT(IN HEX)
   STM R0,SERIAL_PORT_OUT ; OUPUTS HIGH NYBBLE ASCII VALUE
   STM R1,SERIAL_PORT_OUT ; OUTPUTS LOW NYBBLE ASCII VALUE
   JMP BEGIN

MAKE_BYTE:
   POP R1
   SUB R1,R5 ; TURNS ASCII INTO BINARY VALUE
   POP R0
   SUB R0,R5 ; TURNS ASCII INTO BINARY VALUE
   ADD R0,R0
   ADD R0,R0
   ADD R0,R0 ; SHIFTED R0 LEFT FOUR TIMES
   ADD R0,R1 ; CREATED BYTE TO OUTPUT TO MEMORY, IN R0
   RTN
   
MAKE_ADDR_LOW:
   POP R1 ; GETS RID OF ASCII SPACE OR /
   POP R1 ; LOW NYBBLE OF LOW BYTE OF ADDRESS
   SUB R1,R5 ; TURNS ASCII INTO BINARY VALUE
   POP R2 ; HIGH NYBBLE OF LOW BYTE OF ADDRESS
   SUB R2,R5 ; TURNS ASCII INTO BINARY VALUE
   ADD R2,R2
   ADD R2,R2
   ADD R2,R2
   ADD R2,R2 ; SHIFTED R2 LEFT FOUR TIMES
   ADD R1,R2 ; CREATED LOW BYTE OF ADDRESS, IN R1
   RTN

MAKE_ADDR_HIGH:
   POP R2 ; LOW NYBBLE OF HIGH BYTE OF ADDRESS
   SUB R2,R5 ; TURNS ASCII INTO BINARY VALUE
   POP R3 ; HIGH NYBBLE OF HIGH BYTE OF ADDRESS
   ADD R3,R3
   ADD R3,R3
   ADD R3,R3 ; SHIFTED R3 LEFT FOUR TIMES
   ADD R3,R3 ; HIGH BYTE OF HIGH ADDRESS READY
   ADD R2,R3 ; HIGH BYTE OF HIGH ADDRESS IN R2
   RTN

SWAP_ADDR:
   XOR R1,R2
   XOR R2,R1
   XOR R1,R2 ; SETS UP ADDRESS BYTES FOR INDEXED STORE
   RTN

LOAD_BYTE:
   LDI R0,0X00 ; INDEXED LOAD, USES R1 AND R2 FOR BASE ADDRESS
   RTN

MAKE_BYTE_OUT
   ; needs to seperate two nybbles, then shift the high nybble RIGHT four times, add 0x30 to each new byte (creates ASCII value)