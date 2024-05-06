#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Invalid argument!"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

set -e
set -x

X264_DIR=$1

echo "THIS_DIR=$THIS_DIR"

cd $X264_DIR

# Build arm64 v8a
bash $THIS_DIR/build_android_arm64_v8a.sh "$X264_DIR"

# Build arm v7a
bash $THIS_DIR/build_android_armeabi_v7a.sh "$X264_DIR"

# Build x86_64
bash $THIS_DIR/build_android_x86_64.sh "$X264_DIR"

# Build x86
bash $THIS_DIR/build_android_x86.sh "$X264_DIR"
