/* This files provides address values that exist in the system */
#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>

// Begin part2.s for Lab 5

volatile int pixel_buffer_start; // global variable
void pixelPlacer(int baseAddress, int x, int y, short int colour);
void clearScreen();
void drawLine(int x1, int y1, int x2, short int colour);
void waitForVSync();

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    waitForVSync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clearScreen(); // pixel_buffer_start points to the pixel buffer
    
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clearScreen(); // pixel_buffer_start points to the pixel buffer

    int yc = 0; //current y position value
    int yp = 0; //previous y position value
    int ypp = 0;
    int dy = 1; //change in y value
    // int count = 0; //delay

    while (1) {
        drawLine(100, ypp, 220, 0x0000); //draw over previous line
        drawLine(100, yc, 220, WHITE); //draw new line

        //change y if at bounds
        if (yc == 0) {
            dy = 1;
        }
        else if (yc == 239) {
            dy = -1;
        }

        ypp = yp;
        yp = yc;
        yc += dy;
        
        //wait for drawing to complete
        waitForVSync();
        //swap buffers
        pixel_buffer_start = *(pixel_ctrl_ptr+1);
    }

}

//places pixel
void pixelPlacer(int baseAddress, int x, int y, short int colour) {
    *(short int *)(baseAddress + (y << 10) + (x << 1)) = colour;
}

//clears entire screen
void clearScreen() {
    int i, j;
    for (i = 0; i < RESOLUTION_X; i++) {
        for (j = 0; j < RESOLUTION_Y; j++) {
            pixelPlacer(pixel_buffer_start, i, j, 0x0000);
        }
    }
}

//draws straight line
void drawLine(int x1, int y, int x2, short int colour) {
    int i;
    for (i = x1; i <= x2; i++) {
        pixelPlacer(pixel_buffer_start, i, y, colour);
    }
}

// buffer swap
void waitForVSync() {
    volatile int * pixel_ctrl_ptr = (int *) PIXEL_BUF_CTRL_BASE;

    volatile int status;

    *pixel_ctrl_ptr = 1;

    status = *(pixel_ctrl_ptr + 3);
    while ((status & 0x01) != 0x0) {
        status = *(pixel_ctrl_ptr + 3);
    }
}