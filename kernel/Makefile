export PATH := $(HOME)/opt/cross/bin:$(PATH)
OUT := ../out
TARGET := ../chaos.iso
BIN := $(OUT)/chaos.bin
$(shell mkdir -p $(OUT))

ASM := i686-elf-as
CC := i686-elf-gcc
CXX := i686-elf-g++

CFLAGS := -std=gnu99 -ffreestanding -O2 -Wall -Wextra
CXXFLAGS := -ffreestanding -O2 -Wall -Wextra -fno-exceptions -fno-rtti

ASM_SRC := $(shell find * -type f -name "*.s")
ASM_OBJ := $(patsubst %.s, $(OUT)/%.o, $(ASM_SRC))
CC_SRC := $(shell find * -type f -name "*.c")
CC_OBJ := $(patsubst %.c, $(OUT)/%.o, $(CC_SRC))
CXX_SRC := $(shell find * -type f -name "*.cpp")
CXX_OBJ := $(patsubst %.cpp, $(OUT)/%.o, $(CXX_SRC))

all: build

build: $(TARGET)

$(TARGET): $(BIN)
	mkdir -p /tmp/isodir/boot/grub
	cp $< /tmp/isodir/boot/$(basename BIN)
	cp ../grub.cfg /tmp/isodir/boot/grub/grub.cfg
	grub-mkrescue -o $@ /tmp/isodir

$(BIN): $(ASM_OBJ) $(CC_OBJ) $(CXX_OBJ)
	$(CC) -T linker.ld -o $@ -ffreestanding -O2 -nostdlib $^ -lgcc

$(OUT)/%.o: %.s
	$(ASM) $< -o $@

$(OUT)/%.o: %.c
	$(CC) $(CFLAGS) -c $< -o $@

$(OUT)/%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@

clean:
	rm -rf $(OUT) $(TARGET)

.PHONY: build clean
