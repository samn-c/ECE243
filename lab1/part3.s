/* Program that finds the largest number in a list of integers	*/
            
            .text                   // executable code follows
            .global _start                  
_start:                             
            MOV     R4, #RESULT     // R4 points to result location
            LDR     R0, [R4, #4]    // R0 holds the number of elements in the list
            MOV     R1, #NUMBERS    // R1 points to the start of the list
            BL      LARGE           
            STR     R0, [R4]        // R0 holds the subroutine return value

END:        B       END             

/* Subroutine to find the largest integer in a list
 * Parameters: R0 has the number of elements in the list
 *             R1 has the address of the start of the list
 *             R2 has current highest value
 *             R3 has next value
 * Returns: R0 returns the largest item in the list */
LARGE:      LDR     R2, [R1]        // store the current value pointed to by R1 in R2
LOOP:       SUBS    R0, #1          // counter for loop
            BEQ     DONE            // end subroutine if end of counter
			ADD     R1, #4          // move to next number's address
            LDR		R3, [R1]		// store the next value pointed to by R1 in R3
            CMP     R2, R3          // compare current and next number value
            BGE     LOOP            // if R2 is still higher, loop back
            MOV     R2, R3          // move new highest value into R2
            B       LOOP            // loop back
DONE:		MOV     R0, R2          // move highest value into R0
            MOV		PC, LR			// link to program counter

RESULT:     .word   0           
N:          .word   7           // number of entries in the list
NUMBERS:    .word   4, 5, 3, 6  // the data
            .word   1, 8, 2                 

            .end                            
