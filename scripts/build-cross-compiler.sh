#!/bin/bash

set -euo pipefail

export PREFIX="$HOME/opt/cross"
export TARGET=i686-elf
export PATH="$PREFIX/bin:$PATH"

export SOURCE_DIR="/tmp/crosscompiler"

mkdir -p "${SOURCE_DIR}"

function build_binutils {
  local -r VERSION="2.40"
  local -r URL="https://ftp.gnu.org/gnu/binutils/binutils-${VERSION}.tar.gz"
  local -r BUILD_DIR="${SOURCE_DIR}/build-binutils"

  if [[ ! -f "${PREFIX}/bin/${TARGET}-ar" ]]; then
    (
      cd "${SOURCE_DIR}"
      curl -O "${URL}"
      tar -xzf "$(basename "${URL}")"

      mkdir -p "${BUILD_DIR}"
      cd "${BUILD_DIR}"

      "../binutils-${VERSION}/configure" --target=$TARGET --prefix="$PREFIX" --with-sysroot --disable-nls --disable-werror
      make -j8
      make install
    )
  fi
}

function build_gdb {
  # TODO https://wiki.osdev.org/GCC_Cross-Compiler
  false
}

function build_gcc {
  local -r VERSION="12.2.0"
  local -r URL="https://ftp.gnu.org/gnu/gcc/gcc-${VERSION}/gcc-${VERSION}.tar.gz"
  local -r BUILD_DIR="${SOURCE_DIR}/build-gcc"

  if [[ ! -f "${PREFIX}/bin/${TARGET}-gcc" ]]; then
    (
      cd "${SOURCE_DIR}"
      curl -O "${URL}"
      tar -xzf "$(basename "${URL}")"

      mkdir -p "${BUILD_DIR}"
      cd "${BUILD_DIR}"

      "../gcc-${VERSION}/configure" --target=$TARGET --prefix="$PREFIX" --disable-nls --enable-languages=c,c++ --without-headers
      make -j8 all-gcc
      make -j8 all-target-libgcc
      make install-gcc
      make install-target-libgcc
    )
  fi
}

build_binutils
build_gcc
