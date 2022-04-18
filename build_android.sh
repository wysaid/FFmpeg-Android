#!/usr/bin/env bash

if [[ -z "$NDK" ]]; then
    echo "NDK variable not set, please do 'export NDK=/path/of/ndk-bundle'"
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)
echo "THIS_DIR=$THIS_DIR"
cd $THIS_DIR

export PREFIX=$(pwd)/build
export SONAME=libffmpeg.so

echo NDK=${NDK}
echo PREFIX=${PREFIX}

rm -rf "$PREFIX"
mkdir -p "$PREFIX"

if [[ ! -d "${THIS_DIR}/x264" ]]; then
    echo "cloning x264..."
    git clone https://code.videolan.org/videolan/x264.git --recursive

fi

if [[ ! -d "${THIS_DIR}/ffmpeg" ]]; then
    echo "cloning ffmpeg..."
    git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg --recursive

fi

cd $THIS_DIR/x264
git checkout my_compile || git checkout -b my_compile 5db6aa6cab1b146e07b60cc1736a01f21da01154

cd $THIS_DIR/ffmpeg
# git checkout 2.8.6 || git checkout -b 2.8.6 n2.8.6
git checkout 3.4.8 || git checkout -b 3.4.8 n3.4.8

if ! bash $THIS_DIR/build_script/setup_android_toolchain; then
    echo "setup android_toolchain failed"
    exit 1
fi
export NDK_TOOLCHAIN_DIR=$THIS_DIR/build_script/ndk-build-toolchain

cd $THIS_DIR

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
