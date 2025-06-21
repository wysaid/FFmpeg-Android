#!/bin/bash

set -e

if [[ -z "$ANDROID_NDK" ]]; then
    export ANDROID_NDK=$NDK
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

export PREFIX=$THIS_DIR/build
mkdir -p $PREFIX

echo "Testing x264 build for arm64-v8a..."
cd $THIS_DIR/x264
bash $THIS_DIR/build_script/x264/build_android_arm64-v8a_new.sh $THIS_DIR/x264
