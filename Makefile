export PATH := $(HOME)/opt/cross/bin:$(PATH)

HOST ?= i686-elf
HOSTARCH ?= i386

ASM?=$(HOST)-as
CC?=$(HOST)-gcc
CXX?=$(HOST)-g++

CFLAGS?=-O2 -g
CXXFLAGS?=

PREFIX:=/usr
EXEC_PREFIX:=$(PREFIX)
BOOTDIR:=/boot
LIBDIR:=$(EXEC_PREFIX)/lib
INCLUDEDIR:=$(PREFIX)/include

SYSROOT:=$(shell pwd)/sysroot

all: build

build: build-iso

build-iso: install
	mkdir -p isodir/boot/grub
	cp sysroot/boot/chaos.kernel isodir/boot/chaos.kernel
	cp grub.cfg isodir/boot/grub/grub.cfg
	grub-mkrescue -o chaos.iso isodir

install: install-headers install-libc install-kernel

install-headers:
	$(MAKE) HOST=$(HOST) \
		HOSTARCH=$(HOSTARCH) \
		PREFIX=$(PREFIX) \
		DESTDIR=$(SYSROOT) \
		-C libc/ install-headers
	$(MAKE) HOST=$(HOST) \
		HOSTARCH=$(HOSTARCH) \
		PREFIX=$(PREFIX) \
		DESTDIR=$(SYSROOT) \
		-C kernel/ install-headers

install-kernel:
	$(MAKE) HOST=$(HOST) \
		HOSTARCH=$(HOSTARCH) \
		PREFIX=$(PREFIX) \
		DESTDIR=$(SYSROOT) \
		BOOTDIR=/boot \
		CC="$(HOST)-gcc --sysroot=$(SYSROOT) -isystem=$(INCLUDEDIR)" \
		-C kernel/ install

install-libc:
	$(MAKE) HOST=$(HOST) \
		HOSTARCH=$(HOSTARCH) \
		PREFIX=$(PREFIX) \
		DESTDIR=$(SYSROOT) \
		CC="$(HOST)-gcc --sysroot=$(SYSROOT) -isystem=$(INCLUDEDIR)" \
		-C libc/ install

clean:
	$(MAKE) -C kernel/ clean
	$(MAKE) -C libc/ clean
	rm -rf sysroot
	rm -rf isodir
	rm -rf chaos.iso

qemu: all
	qemu-system-$(HOSTARCH) -cdrom chaos.iso

.PHONY: all build build-iso build-kernel build-libc test clean qemu
