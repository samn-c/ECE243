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

// Begin part1.s for Lab 5

volatile int pixel_buffer_start; // global variable
void pixelPlacer(int baseAddress, int x, int y, short int colour);
void clearScreen();
void drawLine(int x1, int y1, int x2, int y2, short int colour);

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *) 0xFF203020;
    
    volatile int status = *(pixel_ctrl_ptr + 3); // status register of DmA

    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;

    clearScreen();
    drawLine(0, 0, 150, 150, 0x001F);   // this line is blue
    drawLine(150, 150, 319, 0, 0x07E0); // this line is green
    drawLine(0, 239, 319, 239, 0xF800); // this line is red
    drawLine(319, 0, 0, 239, 0xF81F);   // this line is a pink color
}

// code not shown for clear_screen() and draw_line() subroutines

//places a pixel at a given address with the specific colour
void pixelPlacer(int baseAddress, int x, int y, short int colour) {
    *(short int *)(baseAddress + (y << 10) + (x << 1)) = colour;
}

//clears every pixel to be black
void clearScreen() {
    int i,j;
    for (i = 0; i < RESOLUTION_X; i++) {
        for (j = 0; j < RESOLUTION_Y; j++) {
            pixelPlacer(pixel_buffer_start, i, j, 0x0000);
        }
    }
}

void drawLine(int x1, int y1, int x2, int y2, short int colour) {
    int dx = x1 > x2 ? -1 : 1; //direction of change in x
    int dy = y1 > y2 ? -1 : 1; //direction of change in y
    float slope = ABS((y2 - y1) / (x2 - x1)); //slope value to determine which algorithm to use
    
    // for error calcuations
    int error;
    int delY = ABS(y2 - y1); 
    int delX = ABS(x2 - x1);
    
    //Depending on slope, choose algorithm
    if (slope > 1) {
        //slope is steep, use y as independent variable of algorithm
        error = -delY / 2;
        int i, j;
        for (i = x1, j = y1; j != (y2 + dy); j+= dy) {
            pixelPlacer(pixel_buffer_start, i, j, colour);

            error += delX;

            if (error >= 0) {
                i += dx;
                error -= delY;
            }
        }
    }
    else if (slope == 1) {
        //regular slope, no algorithm required
        int i, j;
        for (i = x1, j = y1; (i != (x2 + dx)) && (j != (y2 + dy)); i += dx, j += dy) {
            pixelPlacer(pixel_buffer_start, i, j, colour);
        }
    }
    else if (slope < 1) {
        //slope is gentle, use x as independent variable of algorithm
        error = -delX / 2;

        int i, j;
        for (i = x1, j = y1; i != (x2 + dx); i += dx) {
            pixelPlacer(pixel_buffer_start, i, j, colour);

            error += delY;

            if (error >= 0) {
                j += dy;
                error -= delX;
            }
        }
    }
}
