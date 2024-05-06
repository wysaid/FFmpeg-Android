#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Invalid argument!"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)
FFMPEG_DIR=$1

echo "THIS_DIR=$THIS_DIR"

cd $FFMPEG_DIR

set -e
set -x

# Build arm64 v8a
bash $THIS_DIR/build_android_arm64_v8a.sh "$FFMPEG_DIR"

# Build armv7a
bash $THIS_DIR/build_android_armeabi_v7a.sh "$FFMPEG_DIR"

# Build x86_64
bash $THIS_DIR/build_android_x86_64.sh "$FFMPEG_DIR"

# Build x86
bash $THIS_DIR/build_android_x86.sh "$FFMPEG_DIR"
