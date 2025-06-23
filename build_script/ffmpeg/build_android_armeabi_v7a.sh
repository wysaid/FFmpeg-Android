#!/bin/bash

set -e
set -x

cd $1
echo "param = $1"
pwd

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/arm
export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-

GENERAL="\
--enable-small \
--enable-cross-compile \
--arch=arm \
--cc=${CROSS_PREFIX}clang \
--cross-prefix=$CROSS_PREFIX \
--nm=${NDK_STANDALONE_TOOLCHAIN}/bin/llvm-nm \
--ar=${NDK_STANDALONE_TOOLCHAIN}/bin/llvm-ar \
--ranlib=${NDK_STANDALONE_TOOLCHAIN}/bin/llvm-ranlib \
--strip=${NDK_STANDALONE_TOOLCHAIN}/bin/llvm-strip \
--extra-cflags="-I${PREFIX}/x264/armeabi-v7a/include" \
--extra-ldflags="-L${PREFIX}/x264/armeabi-v7a/lib" "

MODULES="\
--enable-gpl \
--enable-libx264"

export PKG_CONFIG_PATH=${PREFIX}/x264/armeabi-v7a/lib/pkgconfig:$PKG_CONFIG_PATH
TEMP_PREFIX=${PREFIX}/ffmpeg/armeabi-v7a
BUILD_DIR=${TEMP_PREFIX}-build

if [[ -s "$TEMP_PREFIX/lib/libavcodec.a" ]]; then
    echo "### ffmpeg already built for Android ARMv7-a, skipping build"
    exit 0
fi

mkdir -p $BUILD_DIR
cd "$BUILD_DIR"

export PATH=$NDK_STANDALONE_TOOLCHAIN/bin:$PATH/

$1/configure \
    --target-os=linux \
    --prefix=${TEMP_PREFIX} \
    --tempprefix=${BUILD_DIR}/tmp \
    ${GENERAL} \
    --sysroot=$SYSROOT \
    --extra-cflags="-DANDROID -O3 -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -Wno-incompatible-function-pointer-types" \
    --extra-ldflags="-Wl,-rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -lc -lm -ldl -llog -fPIC" \
    --enable-zlib \
    --enable-static \
    --disable-shared \
    --disable-symver \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --disable-ffplay \
    --disable-ffmpeg \
    --disable-ffprobe \
    --disable-avdevice \
    --disable-bsfs \
    --disable-devices \
    --disable-protocols \
    --enable-zlib \
    --enable-protocol=file \
    --enable-protocol=pipe \
    --enable-protocol=concat \
    --disable-parsers \
    --enable-parser=h264 \
    --enable-parser=aac \
    --disable-demuxers \
    --enable-demuxer=mov \
    --enable-demuxer=mp3 \
    --enable-demuxer=aac \
    --enable-demuxer=mpegts \
    --enable-demuxer=image2 \
    --disable-decoders \
    --enable-decoder=aac \
    --enable-decoder=h264 \
    --enable-decoder=mp3 \
    --enable-decoder=png \
    --enable-decoder=mjpeg \
    --disable-muxers \
    --enable-muxer=mp4 \
    --enable-muxer=mov \
    --enable-muxer=mp3 \
    --enable-muxer=mpegts \
    --enable-muxer=image2 \
    --disable-encoders \
    --enable-encoder=aac \
    --enable-encoder=libx264 \
    --enable-encoder=png \
    --enable-encoder=mjpeg \
    --enable-gpl \
    --disable-network \
    --enable-hwaccels \
    --disable-avfilter \
    --enable-asm \
    --enable-version3 \
    ${MODULES} \
    --disable-doc \
    --enable-neon \
    --disable-filters \
    --enable-pic \
    --enable-yasm \
    --disable-armv5te \
    --disable-vulkan \
    --pkg-config-flags="--static"

make clean
make -j$(getconf _NPROCESSORS_ONLN)
make install

echo "Android ARMv7-a builds finished"
