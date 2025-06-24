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
if ! bash $THIS_DIR/build_android_arm64_v8a.sh "$FFMPEG_DIR"; then
    echo "Failed to build arm64 v8a"
    exit 1
fi

# Build armv7a
if ! bash $THIS_DIR/build_android_armeabi_v7a.sh "$FFMPEG_DIR"; then
    echo "Failed to build armv7a"
    exit 1
fi

# Build x86_64
if ! bash $THIS_DIR/build_android_x86_64.sh "$FFMPEG_DIR"; then
    echo "Failed to build x86_64"
    exit 1
fi

# Build x86
if ! bash $THIS_DIR/build_android_x86.sh "$FFMPEG_DIR"; then
    echo "Failed to build x86"
    exit 1
fi
