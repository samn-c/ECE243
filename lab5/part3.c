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
#define BOX_LEN 3
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <time.h>

// Begin part3.c code for Lab 7

volatile int pixel_buffer_start; // global variable
void pixelPlacer(int baseAddress, int x, int y, short int colour);
void clearScreen();
void drawLine(int x1, int y1, int x2, int y2, short int colour);
void drawBox(int boxArray[NUM_BOXES][5]);
void waitForVSync();

int main(void) {
    //BOX CREATION
    srand(time(0));

    int colours[10] = {WHITE, YELLOW, RED, GREEN, BLUE, CYAN, MAGENTA, GREY, PINK, ORANGE};

    int boxes[NUM_BOXES][5];
    int i;
    for (i = 0; i < NUM_BOXES; i++) {
        boxes[i][0] = rand() % (317 + 1 - 0) + 0; // x
        boxes[i][1] = rand() % (237 + 1 - 0) + 0; // y
        int colourI = (rand() % (9 + 1 - 1) + 1);
        boxes[i][2] = colours[colourI]; // colour
        boxes[i][3] = rand() % 2 * 2 - 1; // dx
        boxes[i][4] = rand() % 2 * 2 - 1; // dy
    }

    //for clearing positions
    int ppBoxes[NUM_BOXES][5];
    
    for (i = 0; i < NUM_BOXES; i++) {
        ppBoxes[i][0] = boxes[i][0];
        ppBoxes[i][1] = boxes[i][1];
        ppBoxes[i][2] = 0;
        ppBoxes[i][3] = 0;
        ppBoxes[i][4] = 0;
    }

    //for clearing positions
    int prevBoxes[NUM_BOXES][5];
    
    for (i = 0; i < NUM_BOXES; i++) {
        prevBoxes[i][0] = boxes[i][0];
        prevBoxes[i][1] = boxes[i][1];
        prevBoxes[i][2] = 0;
        prevBoxes[i][3] = 0;
        prevBoxes[i][4] = 0;
    }

    //BUFFER CREATION
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;

    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = 0xC8000000; // first store the address in the back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    waitForVSync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clearScreen(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = 0xC0000000;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clearScreen(); // pixel_buffer_start points to the pixel buffer
    
    while (1) {
        /* Erase any boxes and lines that were drawn in the last iteration */
        drawBox(ppBoxes);

        // code for drawing the boxes and lines
        drawBox(boxes);
        
        //previous*2 box
        for (i = 0; i < NUM_BOXES; i++) {
            ppBoxes[i][0] = prevBoxes[i][0];
            ppBoxes[i][1] = prevBoxes[i][1];
            ppBoxes[i][2] = 0;
            ppBoxes[i][3] = 0;
            ppBoxes[i][4] = 0;
        }

        //previous box
        for (i = 0; i < NUM_BOXES; i++) {
            prevBoxes[i][0] = boxes[i][0];
            prevBoxes[i][1] = boxes[i][1];
            prevBoxes[i][2] = 0;
            prevBoxes[i][3] = 0;
            prevBoxes[i][4] = 0;
        }

        // code for updating the locations of boxes
        for (i = 0; i < NUM_BOXES; i++) {
            boxes[i][0] += boxes[i][3];
            boxes[i][1] += boxes[i][4];

            if (boxes[i][0] == 0 || boxes[i][0] == 317) {
                boxes[i][3] *= -1;
            }

            if (boxes[i][1] == 0 || boxes[i][1] == 237) {
                boxes[i][4] *= -1;
            }
        }

        waitForVSync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
}

// code for subroutines (not shown)
void pixelPlacer(int baseAddress, int x, int y, short int colour) {
    *(short int *)(baseAddress + (y << 10) + (x << 1)) = colour;
}

void clearScreen() {
    int i, j;
    for (i = 0; i < RESOLUTION_X; i++) {
        for (j = 0; j < RESOLUTION_Y; j++) {
            pixelPlacer(pixel_buffer_start, i, j, 0x0000);
        }
    }
}

void drawLine(int x1, int y1, int x2, int y2, short int colour) {
	//draws line using algorithm depending on steepness
    int isSteep = (ABS(y2 - y1) > ABS(x2 - x1)) ? TRUE : FALSE;
	
	if (isSteep) {
        int temp;
        
        temp = x1;
        x1 = y1;
        y1 = temp;

        temp = x2;
        x2 = y2;
        y2 = temp;
	}
	if (x1 > x2) {
        int temp; 

        temp = x1;
        x1 = x2;
        x2 = temp;

        temp = y1;
        y1 = y2;
        y2 = temp;
	}
	
	int delX = x2 - x1;
	int delY = ABS(y2 - y1);
	int error = -(delX / 2);
	
	int dy = (y1 < y2) ? 1: -1;
	
    int i, j;
	for (i = x1, j = y1; i < x2; i++) {
		if (isSteep == TRUE) {
			pixelPlacer(pixel_buffer_start, j, i, colour);
        }
		else {
			pixelPlacer(pixel_buffer_start, i, j, colour);
        }
		
		error += delY;
		
		if (error > 0) {
			j += dy;
			error -= delX;
		}
	}
}

void waitForVSync() {
    volatile int * pixel_ctrl_ptr = (int *)PIXEL_BUF_CTRL_BASE;

    volatile int status;
    
    //begin sync
    *pixel_ctrl_ptr = 1;

    status = *(pixel_ctrl_ptr + 3);
    while ((status & 0x01) != 0x0) {
        status = *(pixel_ctrl_ptr + 3);
    }
}

void drawBox(int boxArray[NUM_BOXES][5]) {
    int i, j, k;
    for (i = 0; i < NUM_BOXES; i++) {
        //draw box
        for (j = 0; j < 3; j++) {
            for (k = 0; k < 3; k++) {
                pixelPlacer(pixel_buffer_start, boxArray[i][0] + j, boxArray[i][1] + k, boxArray[i][2]);
            }
        }

        //draw line
        if (i == (NUM_BOXES - 1)) {
            drawLine(boxArray[i][0], boxArray[i][1], boxArray[0][0], boxArray[0][1], boxArray[i][2]);
        }
        else {
            drawLine(boxArray[i][0], boxArray[i][1], boxArray[i+1][0], boxArray[i+1][1], boxArray[i][2]);
        }
    }
}