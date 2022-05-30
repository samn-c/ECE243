			.text
			.global _start

_start:		LDR     R9, =0xFF20005C     // R9 for key interrupts
            LDR     R8, =0xFF200020     // R8 for hex
            MOV     R7, #0              // counter bit for display
			MOV		R10, #0				// wait register for buttons

LOOP:		MOV		R0, R7
			BL		DIVIDE				//separate the digits
			
			MOV     R5, #BIT_CODES
            ADD     R5, R0
            LDRB    R5, [R5]       
            MOV     R4, R5          	// save bit code

			MOV     R5, #BIT_CODES
            ADD     R5, R1
            LDRB    R5, [R5]
			LSL		R5, #8       
            ORR     R4, R5          	// save bit code

            STR     R4, [R8]        	// display the numbers

DELAY:		LDR		R3, =500000
SUBLOOP:	SUBS	R3, #1
			BNE		SUBLOOP

PRESS:		LDR     R6, [R9]            // read in from key interrupts
            CMP     R6, #0              // check for key press
			EORNE	R10, #1				// flip wait register
			
			CMP		R6, #0
			STRNE   R6, [R9]			// -- interrupts
			CMP		R10, #1				
			BEQ		PRESS

CONTINUE:	CMP		R7, #99				// add unless at max
			BGE		CLEAR
			ADD     R7, #1
			B		LOOP

CLEAR:		MOV		R7, #0				// reset to 0
			B 		LOOP

// Lab 1 Part 4
DIVIDE:     MOV    	R2, #0
CONT:       CMP    	R0, #10         	// modified for modular divisor
            BLT    	DIV_END
            SUB    	R0, #10        	 	// modified for modular divisor
            ADD    	R2, #1
            B      	CONT
DIV_END:    MOV    	R1, R2     			// tens in R1, ones in R0
			MOV		PC, LR

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111
            .byte   0b01100110, 0b01101101, 0b01111101, 0b00000111
            .byte   0b01111111, 0b01101111
            .skip   2      // pad with 2 bytes to maintain word alignment

			.end