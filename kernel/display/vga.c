#include "vga.h"
#include "../utils/port.h"

enum vga_color {
  VGA_COLOR_BLACK = 0,
  VGA_COLOR_BLUE = 1,
  VGA_COLOR_GREEN = 2,
  VGA_COLOR_CYAN = 3,
  VGA_COLOR_RED = 4,
  VGA_COLOR_MAGENTA = 5,
  VGA_COLOR_BROWN = 6,
  VGA_COLOR_LIGHT_GREY = 7,
  VGA_COLOR_DARK_GREY = 8,
  VGA_COLOR_LIGHT_BLUE = 9,
  VGA_COLOR_LIGHT_GREEN = 10,
  VGA_COLOR_LIGHT_CYAN = 11,
  VGA_COLOR_LIGHT_RED = 12,
  VGA_COLOR_LIGHT_MAGENTA = 13,
  VGA_COLOR_LIGHT_BROWN = 14,
  VGA_COLOR_WHITE = 15,
};

static inline char vga_entry_color(enum vga_color fg, enum vga_color bg) {
  return fg | bg << 4;
}

static inline int get_row(int offset) { return offset / (2 * MAX_COLS); }

static inline int get_offset(int col, int row) {
  return 2 * (row * MAX_COLS + col);
}

static inline void copy(char* src, char* dest, int nbytes) {
  for (int idx = 0; idx < nbytes; idx++)
    *(dest + idx) = *(src + idx);
}

void set_cursor(int offset) {
  offset /= 2;
  outb(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);
  outb(VGA_DATA_REGISTER, (unsigned char)(offset >> 8));
  outb(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);
  outb(VGA_DATA_REGISTER, (unsigned char)(offset & 0xff));
}

int get_cursor() {
  outb(VGA_CTRL_REGISTER, VGA_OFFSET_HIGH);
  int offset = inb(VGA_DATA_REGISTER) << 8;
  outb(VGA_CTRL_REGISTER, VGA_OFFSET_LOW);
  offset += inb(VGA_DATA_REGISTER);
  return offset * 2;
}

void put_char(char character, int offset) {
  unsigned char* vidmem = (unsigned char*)VIDEO_ADDRESS;
  vidmem[offset] = character;
  vidmem[offset + 1] = vga_entry_color(VGA_COLOR_LIGHT_GREY, VGA_COLOR_BLACK);
}

int scroll(int offset) {
  copy((char*)(get_offset(0, 1) + VIDEO_ADDRESS),
       (char*)(get_offset(0, 0) + VIDEO_ADDRESS),
       MAX_COLS * (MAX_ROWS - 1) * 2);

  for (int col = 0; col < MAX_COLS; col++) {
    put_char(' ', get_offset(col, MAX_ROWS - 1));
  }

  return offset - 2 * MAX_COLS;
}

void print_string(char* string) {
  int offset = get_cursor();
  int i = 0;
  while (string[i] != 0) {
    if (offset >= MAX_ROWS * MAX_COLS * 2) {
      offset = scroll(offset);
    }

    if (string[i] == '\n')
      offset = get_offset(0, get_row(offset) + 1);
    else {
      put_char(string[i], offset);
      offset += 2;
    }
    i++;
  }
  set_cursor(offset);
}

void clear() {
  for (int i = 0; i < MAX_COLS * MAX_ROWS; ++i) {
    put_char(' ', i * 2);
  }
  set_cursor(get_offset(0, 0));
}
