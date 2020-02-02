#!/usr/bin/env bash

THIS_DIR=`cd $(dirname "$0"); pwd`
echo "THIS_DIR=$THIS_DIR"
cd ${THIS_DIR}

FFMPEG_DIR=`cd ${THIS_DIR}/../../ffmpeg; pwd`

cd $FFMPEG_DIR
git clean -fdx

bash $THIS_DIR/build_android_armeabi_v7a.sh

# Build arm64 v8a
bash $THIS_DIR/build_android_arm64_v8a.sh

# Build x86
# bash $THIS_DIR/build_android_x86.sh

# Build x86_64
# cd $FFMPEG_DIR
# bash $THIS_DIR/build_android_x86_64.sh

# Build mips
# cd $FFMPEG_DIR
# bash $THIS_DIR/build_android_mips.sh

# Build mips64   //may fail
# cd $FFMPEG_DIR
# bash $THIS_DIR/build_android_mips64.sh
