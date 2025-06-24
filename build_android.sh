#!/usr/bin/env bash

set -e
set -x

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

export FFMPEG_VERSION=3.4.8
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
    --16kb | --enable-16kb-page-size)
        export ENABLE_16KB_PAGE_SIZE=true
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
LAST_X264_COMMIT=$(git rev-parse HEAD | tr -d '\n')
git checkout my_compile || git checkout -b my_compile $X264_VERSION
git reset --hard $X264_VERSION || (git fetch --all && git reset --hard $X264_VERSION)
if [[ "$LAST_X264_COMMIT" != "$(git rev-parse HEAD | tr -d '\n')" ]]; then
    echo "x264 version changed to $X264_VERSION"
    git clean -ffdx build/x264
else
    echo "x264 version is already $X264_VERSION"
fi

cd $THIS_DIR/ffmpeg
git stash
LAST_FFMPEG_COMMIT=$(git rev-parse HEAD | tr -d '\n')
if ! (git checkout ${FFMPEG_VERSION} || git checkout -b ${FFMPEG_VERSION} n${FFMPEG_VERSION}); then
    git fetch --all
    git checkout ${FFMPEG_VERSION} || git checkout -b ${FFMPEG_VERSION} n${FFMPEG_VERSION}
fi
if [[ "$LAST_FFMPEG_COMMIT" != "$(git rev-parse HEAD | tr -d '\n')" ]]; then
    echo "ffmpeg version changed to $FFMPEG_VERSION"
    git clean -ffdx build/ffmpeg
else
    echo "ffmpeg version is already $FFMPEG_VERSION"
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

cd $THIS_DIR

export INSTALL_DIR=$THIS_DIR/ffmpeg-$FFMPEG_VERSION
if [[ "$ENABLE_16KB_PAGE_SIZE" == "true" ]]; then
    INSTALL_DIR+="-16kb"
fi

if [[ -d "$INSTALL_DIR" ]]; then
    rm -rf "$INSTALL_DIR"
fi

set +x

mkdir -p $INSTALL_DIR/include
echo "### copy include files ###"
cp -rf "$THIS_DIR"/jni/lib* $INSTALL_DIR/include/.

ALL_ARCHS=(armeabi-v7a arm64-v8a x86 x86_64)
for ARCH in "${ALL_ARCHS[@]}"; do
    # Copy the config.h
    CONFIG_FILE="$THIS_DIR/build/ffmpeg/${ARCH}-build/config.h"
    if [[ -f "$CONFIG_FILE" ]]; then
        echo "Copying $CONFIG_FILE libraries..."
        cp -rf "${CONFIG_FILE}" $INSTALL_DIR/include/config.${ARCH}.h
    else
        echo "Warning: $CONFIG_FILE does not exist, skipping."
    fi
done

echo "### copy libs ###"
mkdir -p $INSTALL_DIR/libs
cp -rf $THIS_DIR/libs/* $INSTALL_DIR/libs/.

find $INSTALL_DIR/libs/ -iname "libffmpeg.so"

echo "Done! "
