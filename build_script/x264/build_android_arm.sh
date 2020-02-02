#!/bin/bash

cd $1;

git clean -fd

export SYSROOT=$NDK/ndk-build-toolchain/sysroot
export CROSS_PREFIX=$NDK/ndk-build-toolchain/bin/arm-linux-androideabi-

temp_prefix=${PREFIX}/x264/android/arm
rm -rf $temp_prefix

function build_one
{
  ./configure \
  --prefix=${temp_prefix} \
  --enable-static \
  --enable-pic \
  --host=arm-linux \
  --cross-prefix=$CROSS_PREFIX \
  --sysroot=$SYSROOT

  make clean
  make -j10
  make install
}

build_one

echo Android ARM builds finished
