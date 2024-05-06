#!/usr/bin/env bash

set -e

if [[ -z "$NDK" ]]; then
    echo "NDK variable not set, please do 'export NDK=/path/of/ndk-bundle'"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)
echo "THIS_DIR=$THIS_DIR"
cd $THIS_DIR

export FFMPEG_VERSION=4.4.4
export X264_VERSION=31e19f92f00c7003fa115047ce50978bc98c3a0d

while [[ $# -gt 0 ]]; do
    case $1 in
    -f | --ffmpeg)
        shift
        export FFMPEG_VERSION=$1
        ;;
    -x | --x264)
        shift
        export X264_VERSION=$1
        ;;
    *)
        echo "Unknown parameter passed: $1"
        exit 1
        ;;
    esac
    shift
done

export PREFIX=$(pwd)/build
export SONAME=libffmpeg.so

echo NDK=${NDK}
echo PREFIX=${PREFIX}

mkdir -p "$PREFIX"

if [[ ! -d "${THIS_DIR}/x264" ]]; then
    echo "cloning x264..."
    git clone https://github.com/mirror/x264.git --recursive

fi

if [[ ! -d "${THIS_DIR}/ffmpeg" ]]; then
    echo "cloning ffmpeg..."
    git clone https://github.com/FFmpeg/FFmpeg ffmpeg --recursive

fi

cd $THIS_DIR/x264
git stash
git checkout my_compile || git checkout -b my_compile $X264_VERSION
git reset --hard $X264_VERSION || (git fetch --all && git reset --hard $X264_VERSION)

cd $THIS_DIR/ffmpeg
git stash
if ! (git checkout ${FFMPEG_VERSION} || git checkout -b ${FFMPEG_VERSION} n${FFMPEG_VERSION}); then
    git fetch --all
    git checkout ${FFMPEG_VERSION} || git checkout -b ${FFMPEG_VERSION} n${FFMPEG_VERSION}
fi

if ! bash $THIS_DIR/build_script/setup_android_toolchain; then
    echo "setup android_toolchain failed"
    exit 1
fi
export NDK_TOOLCHAIN_DIR=$THIS_DIR/build_script/ndk-build-toolchain

cd $THIS_DIR
bash fix_ffmpeg.sh

echo "### build x264 start ###"

bash $THIS_DIR/build_script/x264/build_android_all.sh "$THIS_DIR/x264"
echo "### build x264 end ###"

echo "### build ffmpeg start ###"
bash $THIS_DIR/build_script/ffmpeg/build_android_all.sh "$THIS_DIR/ffmpeg"
echo "### build ffmpeg end ###"

echo "### gen ffmpeg.so ###"
cp -rf $PREFIX/ffmpeg/armeabi-v7a/include/* $THIS_DIR/jni/
cd $THIS_DIR/jni
$NDK/ndk-build -j$(getconf _NPROCESSORS_ONLN)
