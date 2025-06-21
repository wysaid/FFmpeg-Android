#!/usr/bin/env bash

set -e

if [[ -z "$1" ]]; then
    echo "Invalid argument!"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

set -e

FFMPEG_DIR=$1

echo "THIS_DIR=$THIS_DIR"

cd $FFMPEG_DIR
git clean -fdx

# Build armeabi-v7a
bash $THIS_DIR/build_android_armeabi_v7a_new.sh "$FFMPEG_DIR"

# Build arm64-v8a
bash $THIS_DIR/build_android_arm64_v8a_new.sh "$FFMPEG_DIR"

# Build x86_64
bash $THIS_DIR/build_android_x86_64_new.sh "$FFMPEG_DIR"
