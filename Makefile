OUT := out

ASM := nasm
ASM_SRC := $(shell find * -type f -name "*.s")
ASM_BIN := $(patsubst %.s, $(OUT)/%.bin, $(ASM_SRC))

all: build

build: $(OUT) $(ASM_BIN)

$(OUT):
	mkdir -p $(OUT)

$(OUT)/%.bin: %.s
	$(ASM) -f bin $< -o $@

qemu:
	qemu-system-x86_64 -fda out/boot.bin

clean:
	rm -rf out

.PHONY: build qemu clean
