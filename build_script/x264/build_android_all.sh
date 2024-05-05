#!/usr/bin/env bash

if [[ -z "$1" ]]; then
    echo "Invalid argument!"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

X264_DIR=$1

echo "THIS_DIR=$THIS_DIR"

cd $X264_DIR
git clean -fdx

# Build arm v6 v7a
bash $THIS_DIR/build_android_arm.sh "$X264_DIR" || exit 1

# Build arm64 v8a
bash $THIS_DIR/build_android_arm64-v8a.sh "$X264_DIR" || exit 1

# Build x86
bash $THIS_DIR/build_android_x86.sh "$X264_DIR" || exit 1

# Build x86_64
bash $THIS_DIR/build_android_x86_64.sh "$X264_DIR" || exit 1
