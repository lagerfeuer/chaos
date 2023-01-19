# chaos

## Prerequisites

Build the GCC cross compiler by running:
```sh
./build-cross-compiler
```

Additionally, some packages are needed, here's a list for Arch Linux:
- grub
  - libisoburn (for `xorriso`)
  - mtools (for `mformat`)

## Run the OS

```sh
make qemu
# or
make qemu-grub
```
