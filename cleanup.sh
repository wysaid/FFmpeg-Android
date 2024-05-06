#!/usr/bin/env bash

set -e
THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)
cd $THIS_DIR
echo "Cleaning up the build environment..."

git clean -fdx
git clean -ffdx build_script

if [[ -d ffmpeg ]]; then
    cd ffmpeg
    git clean -ffdx
    cd ..
fi

if [[ -d x264 ]]; then
    cd x264
    git clean -ffdx
    cd ..
fi
