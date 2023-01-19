#ifndef VGA_H
#define VGA_H

#define VGA_CTRL_REGISTER 0x3D4
#define VGA_DATA_REGISTER 0x3D5
#define VGA_OFFSET_LOW 0x0F
#define VGA_OFFSET_HIGH 0x0E

#define VIDEO_ADDRESS 0xB8000

#define MAX_ROWS 25
#define MAX_COLS 80

void print_string(char* string);
void clear();

#endif
