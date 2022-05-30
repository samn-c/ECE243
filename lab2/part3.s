            .text                       // executable code follows
            .global _start                  
_start:
            MOV	    SP, #0x20000	    // init SP
            MOV     R5, #0              // 1's sqnce final
            MOV     R6, #0              // 0's sqnce final
            MOV     R7, #0              // 10's sqnce final
            MOV     R1, #TEST_NUM       // load the data word ...

LOOP:       LDR     R2, [R1], #4        // into R2, post-increment
            CMP     R2, #0              // check if end of TEST_NUM
            BEQ     END

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

            .end                           

            