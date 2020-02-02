#!/bin/bash

cd $1
echo "param = $1"
pwd

git clean -fd

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/arm

if [[ ! -d "${NDK_STANDALONE_TOOLCHAIN}" ]]; then
  echo "NDK_STANDALONE_TOOLCHAIN=$NDK_STANDALONE_TOOLCHAIN"
  echo "Invalid NDK_STANDALONE_TOOLCHAIN."
  exit 1
fi

export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-

temp_prefix=${PREFIX}/x264/arm
rm -rf $temp_prefix
mkdir -p $temp_prefix

echo ./configure \
  --prefix=${temp_prefix} \
  --enable-static \
  --enable-pic \
  --host=arm-linux \
  --cross-prefix=$CROSS_PREFIX \
  --sysroot=$SYSROOT

./configure \
  --prefix=${temp_prefix} \
  --enable-static \
  --enable-pic \
  --host=arm-linux \
  --cross-prefix=$CROSS_PREFIX \
  --sysroot=$SYSROOT

make clean
make -j$(getconf _NPROCESSORS_ONLN)
make install

echo "### Android ARM builds finished"
