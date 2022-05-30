/* Subroutine to convert the digits from 0 to 9 to be shown on a HEX display.
 *    Parameters: R0 = the decimal value of the digit to be displayed
 *    Returns: R0 = bit patterm to be written to the HEX display
 */
            .text                       // executable code follows
            .global _start    

SEG7_CODE:  MOV     R1, #BIT_CODES  
            ADD     R1, R0         // index into the BIT_CODES "array"
            LDRB    R0, [R1]       // load the bit pattern (to be returned)
            MOV     PC, LR              

BIT_CODES:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

/* code for Part III (not shown) */
              
_start:     MOV	    SP, #0x20000	    // init SP
            MOV     R5, #0              // 1's sqnce final
            MOV     R6, #0              // 0's sqnce final
            MOV     R7, #0              // 10's sqnce final
            MOV     R1, #TEST_NUM       // load the data word ...

LOOP:       LDR     R2, [R1], #4        // into R2, post-increment
            CMP     R2, #0              // check if end of TEST_NUM
            BEQ     DISPLAY

            MOV     R3, R2              // R2 holds word for each loop, R3 for word manipulation
            MOV     R0, #0              // reset sqnce counter before using it again
            BL      ONES
            CMP     R5, R0          
            MOVLT   R5, R0              // replace with highest 1's sqnce
            
            MOV     R3, R2              // R2 holds word for each loop, R3 for word manipulation
            MOV     R0, #0              // reset sqnce counter before using it again
            BL      ZEROS           
            CMP     R6, R0
            MOVLT   R6, R0              // replace with highest 1's sqnce

            MOV     R3, R2              // R2 holds word for each loop, R3 for word manipulation
            MOV     R0, #0              // reset sqnce counter before using it again
            BL      OZS           
            CMP     R7, R0
            MOVLT   R7, R0              // replace with highest 1's sqnce
            
            B       LOOP

END:        B       END   

ONES:       CMP     R3, #0              // loop until the data contains no more 1's
            MOVEQ   PC, LR              // end of this word's sequence of 1's
            LSR     R4, R3, #1          // perform SHIFT, followed by AND
            AND     R3, R4              // R2 <- R2 AND R3
            ADD     R0, #1              // count the string length so far
            B       ONES  

ZEROS:      MOV     R9, #ONE
            LDR     R9, [R9]
            CMP     R3, R9              // if data contains no 0's,
            MOVEQ   PC, LR              // end
            EOR     R3, R3, R9          // R3 <- XOR of R3 with all 1's (Basically NOT)
            PUSH    {LR}                // store LR of this loop
            BL      ONES                // count 1's in the NOT of R3
            POP     {LR}                // pop back
            MOV     PC, LR              // return to main loop

OZS:        MOV     R9, #AAA
            LDR     R9, [R9]
            CMP     R3, #0              // if data contains no 1's,
            MOVEQ   PC, LR              // end

            EOR     R3, R3, R9          // compare to 1010...
            PUSH    {LR}                // count 1's
            BL      ONES
            POP     {LR}
            
            MOV     R8, R0              // store first count of 10's
            MOV     R0, #0              // reset R0 counter
            MOV		R9, #FIVE 			//////////////////////////////

            MOV     R3, R2              // reload original word
            EOR     R3, R3, R9          // compare to 0101...
            PUSH    {LR}                // count 1's
            BL      ONES
            POP     {LR}

            CMP     R0, R8              // compare the two counts of 10/01's
            MOVLT   R0, R8              // replace with R8 if greater
            MOV     PC, LR

ONE:        .word   0xffffffff
AAA:        .word   0xAAAAAAAA
FIVE:       .word   0x55555555

TEST_NUM:   .word   0xB41B0B8C
            .word   0xF71BEB8C
            .word   0xF71BFB8C
            .word	0xDEADBEEF
            .word	0x971B5B8C
            .word	0xFACEDEAF
            .word	0xBEADCAFE
            .word   0x00000001
            .word   0xAAAAAAAA
            .word	0xFFFFFFFF
            .word   0x0                          
//END OF PART 3
            
/* Display R5 on HEX1-0, R6 on HEX3-2 and R7 on HEX5-4 */
DISPLAY:    LDR     R8, =0xFF200020 // base address of HEX3-HEX0
            MOV     R0, R5          // display R5 on HEX1-0
            BL      DIVIDE          // ones digit will be in R0; tens digit in R1

            MOV     R9, R1          // save the tens digit
            BL      SEG7_CODE       
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retrieve tens digit, get bit code
            
            BL      SEG7_CODE       
            LSL     R0, #8          // shift the next digit by a byte
            ORR     R4, R0          // OR to stack the digits in R4
            
            MOV     R0, R6          // display R6 on HEX3-2
            BL      DIVIDE          // ones digit R0, tens digit R1

            MOV     R9, R1          // save tens digit
            BL      SEG7_CODE
            MOV     R10, R0         // save bit code
            MOV     R0, R9          // retreive tens digit, get bit code

            BL      SEG7_CODE
            LSL     R0, #8          // shift the next digit by a byte
            ORR     R10, R0         // OR to stack the digits in R10

            LSL     R10, #16        // shift R10 by 2 bytes
            ADD     R4, R10         // ADD to stack hex digits into R4
            STR     R4, [R8]        // display the numbers from R6 and R5
            
            LDR     R8, =0xFF200030 // base address of HEX5-HEX4

            MOV     R0, R7          // display R7 on HEX5-4
            BL      DIVIDE          // ones digit R0, tens digit R1

            MOV     R9, R1          // save tens digit
            BL      SEG7_CODE
            MOV     R4, R0          // save bit code
            MOV     R0, R9          // retreive tens digit, get bit code

            BL      SEG7_CODE
            LSL     R0, #8
            ORR     R4, R0

            STR     R4, [R8]        // display the number from R7

            BL      END

// Lab 1 Part 4
DIVIDE:     MOV    	R2, #0
CONT:       CMP    	R0, #10         // modified for modular divisor
            BLT    	DIV_END
            SUB    	R0, #10         // modified for modular divisor
            ADD    	R2, #1
            B      	CONT
DIV_END:    MOV    	R1, R2     		// quotient in R1 (remainder in R0)
            MOV    	PC, LR

            .end  