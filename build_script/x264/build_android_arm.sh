#!/bin/bash

cd $1
echo "param = $1"
pwd

git clean -fd

set -e

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/arm

if [[ ! -d "${NDK_STANDALONE_TOOLCHAIN}" ]]; then
    echo "NDK_STANDALONE_TOOLCHAIN=$NDK_STANDALONE_TOOLCHAIN"
    echo "Invalid NDK_STANDALONE_TOOLCHAIN."
    exit 1
fi

export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-

TEMP_PREFIX=${PREFIX}/x264/armeabi-v7a
# rm -rf $TEMP_PREFIX
mkdir -p $TEMP_PREFIX

echo ./configure \
    --prefix=${TEMP_PREFIX} \
    --enable-static \
    --enable-pic \
    --host=arm-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT

./configure \
    --prefix=${TEMP_PREFIX} \
    --enable-static \
    --enable-pic \
    --host=arm-linux \
    --cross-prefix=$CROSS_PREFIX \
    --sysroot=$SYSROOT

make clean
make -j$(getconf _NPROCESSORS_ONLN)
make install

echo "### Android ARM builds finished"
