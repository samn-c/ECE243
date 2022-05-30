/* Program that converts a binary number to decimal */
           
           .text               		// executable code follows
           .global _start
_start:
            MOV    	R4, #N
            MOV    	R5, #Digits  	// R5 points to the decimal digits storage location
            LDR    	R4, [R4]     	// R4 holds N
            MOV    	R0, R4       	// parameter for DIVIDE goes in R0

			MOV		R1, #1000		// thousands divisor
            BL     	DIVIDE
            STRB   	R1, [R5, #3] 	// thousands digit is now in R1
			
			MOV		R1, #100		// hundreds divisor
            BL     	DIVIDE
            STRB   	R1, [R5, #2] 	// hundreds digit is now in R1
			
			MOV		R1, #10			// tens divisor
            BL     	DIVIDE
            STRB   	R1, [R5, #1] 	// tens digit is now in R1
			STRB    R0, [R5]        // ones digit is in R0
END:        B      	END

/* Subroutine to perform the integer division R0 / 10.
 * Returns: quotient in R1, and remainder in R0 */
DIVIDE:     MOV    	R2, #0
CONT:       CMP    	R0, R1          // modified for modular divisor
            BLT    	DIV_END
            SUB    	R0, R1          // modified for modular divisor
            ADD    	R2, #1
            B      	CONT
DIV_END:    MOV    	R1, R2     		// quotient in R1 (remainder in R0)
            MOV    	PC, LR

N:          .word  4276             // the decimal number to be converted
Digits:     .space 4          		// storage space for the decimal digits

            .end