#!/usr/bin/env bash
export NDK=/Users/luoye/Library/Android/sdk/ndk-bundle
export PREFIX=`pwd`/build
export SONAME=libbzffmpeg.so

echo NDK-Dir=${NDK}
echo PREFIX=${PREFIX}

cd x264

./build_android_all.sh


cd ../ffmpeg

./build_android_all.sh