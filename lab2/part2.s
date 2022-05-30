            .text               // executable code follows
            .global _start                  
_start:
            MOV     R5, #0          // 1's sqnce final
            MOV     R1, #TEST_NUM   // load the data word ...
LOOP:       LDR     R2, [R1], #4    // into R2, post-increment
            CMP     R2, #0          // check if end of TEST_NUM
            BEQ     END
            MOV     R0, #0          // reset 1's sqnce counter before using it again
            BL      ONES
            CMP     R5, R0          
            MOVLT   R5, R0          // replace with highest 1's sqnce
            
            B       LOOP
END:        B       END   

ONES:       CMP     R2, #0          // loop until the data contains no more 1's
            MOVEQ   PC, LR          // end of this word's sequence of 1's
            LSR     R3, R2, #1      // perform SHIFT, followed by AND
            AND     R2, R3          // R2 <- R2 AND R3
            ADD     R0, #1          // count the string length so far
            B       ONES            

TEST_NUM:   .word	0xB41B0B8C
            .word	0xF71BEB8C
            .word	0xF71BFB8C
            .word	0xDEADBEEF
            .word	0x971B5B8C
            .word	0x152B5B8D
            .word	0xFACEDEAF
            .word	0xBEADCAFE
            .word   0x103fe00f
            .word	0xFFFFFFFF
            .word   0x0 

            .end                           

            