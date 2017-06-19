#!/usr/bin/env bash
export NDK=/Users/luoye/Library/Android/sdk/ndk-bundle
export PREFIX=`pwd`/build
export SONAME=libbzffmpeg.so

echo NDK-Dir=${NDK}
echo PREFIX=${PREFIX}


root_dir=`pwd`

cd $root_dir/build_script/x264

./build_android_all.sh


cd $root_dir/build_script/ffmpeg

./build_android_all.sh