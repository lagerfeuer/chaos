all: build

build:
	$(MAKE) -C kernel/

clean:
	$(MAKE) -C kernel/ clean

qemu: $(BIN)
	qemu-system-i386 -kernel out/chaos.bin

qemu-grub: all
	qemu-system-i386 -cdrom chaos.iso

.PHONY: build clean qemu qemu-grub
