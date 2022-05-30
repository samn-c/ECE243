            .text                       // executable code follows
            .global _start              
             
_start:     LDR     R9, =0xFF20005C     // R9 for key interrupts
            LDR     R8, =0xFF200020     // R8 for hex
            MOV		R1, #0				// reset value
            MOV     R0, #0              // counter bit for display

PRESS:      LDR     R7, [R9]            // read in from key interrupts
            CMP     R7, #0              // check for key press
            BEQ     PRESS

            CMP     R7, #8              // KEY 3
            BGE     BLANK

            CMP     R7, #4              // KEY 2
            BGE     SUBTRACT          

            CMP     R7, #2              // KEY 1
            BGE     ADDITTION

            CMP     R7, #1              // KEY 0
            BGE     ZERO       
            
BLANK:      STR     R7, [R9]            // clear interrupt
            STR     R1, [R8]            // clear hex
            MOV     R0, R1              // reset count to 0

WAIT:       LDR     R7, [R9]            // wait for next button
            CMP     R7, #0
            BEQ     WAIT
            STR     R7, [R9]            // clear interrupt before returning
            B       ZERO                // goes to zero to show zero again

SUBTRACT:   CMP     R0, #0              // check for 0 then subtract
            SUBGT   R0, #1
            B       CLEAR

ADDITTION:  CMP     R0, #9              // check for 9 then add
            ADDLT   R0, #1
            B       CLEAR

ZERO:       MOV     R0, R1              // clear count
            B       CLEAR

CLEAR:      STR     R7, [R9]            // clear interrupt

DISPLAY:    MOV     R5, #BIT_CODES
            ADD     R5, R0
            LDRB    R5, [R5]       
            MOV     R4, R5              // save bit code
            STR     R4, [R8]            // display the numbers
            B       PRESS

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111
            .byte   0b01100110, 0b01101101, 0b01111101, 0b00000111
            .byte   0b01111111, 0b01101111
            .skip   2                   // pad with 2 bytes to maintain word alignment

            .end