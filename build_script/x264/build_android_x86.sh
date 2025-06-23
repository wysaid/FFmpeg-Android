#!/bin/bash

cd $1
echo "param = $1"
pwd

git clean -fd

set -e
set -x

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/x86

if [[ ! -d "${NDK_STANDALONE_TOOLCHAIN}" ]]; then
    echo "NDK_STANDALONE_TOOLCHAIN=$NDK_STANDALONE_TOOLCHAIN"
    echo "Invalid NDK_STANDALONE_TOOLCHAIN."
    exit 1
fi

if [[ -f "$NDK_STANDALONE_TOOLCHAIN/bin/llvm-strings" ]]; then
    export STRINGS="$NDK_STANDALONE_TOOLCHAIN/bin/llvm-strings"
fi

# Disable strip to avoid issues with symbols
export STRIP=true
export AR="$NDK_STANDALONE_TOOLCHAIN/bin/llvm-ar"
export RANLIB="$NDK_STANDALONE_TOOLCHAIN/bin/llvm-ranlib"
export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/i686-linux-android-

TEMP_PREFIX=${PREFIX}/x264/x86
BUILD_DIR=${TEMP_PREFIX}-build

if [[ -s "$TEMP_PREFIX/lib/libx264.a" ]]; then
    echo "### x264 already built for Android x86, skipping build"
    exit 0
fi

mkdir -p "$TEMP_PREFIX"
mkdir -p "$BUILD_DIR"

cd $BUILD_DIR

$1/configure \
    --prefix=${TEMP_PREFIX} \
    --extra-cflags="-fPIC -fpic -Wno-implicit-function-declaration" \
    --enable-static \
    --enable-pic \
    --disable-cli \
    --disable-asm \
    --host=i686-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT

make clean
make -j$(getconf _NPROCESSORS_ONLN)
make install

echo "### Android x86 builds finished"
