#!/bin/bash

cd $1
echo "param = $1"
pwd

git clean -fdx

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/arm64
export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/aarch64-linux-android-

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--arch=aarch64 \
--cc=${CROSS_PREFIX}gcc \
--cross-prefix=$CROSS_PREFIX \
--nm=${CROSS_PREFIX}nm \
--extra-cflags="-I${PREFIX}/x264/arm64-v8a/include" \
--extra-ldflags="-L${PREFIX}/x264/arm64-v8a/lib" "

MODULES="\
--enable-gpl \
--enable-libx264"

TEMP_PREFIX=${PREFIX}/ffmpeg/arm64-v8a
# rm -rf $TEMP_PREFIX
export PATH=$NDK_STANDALONE_TOOLCHAIN/bin:$PATH/

git clean -fdx

echo ./configure \
    --target-os=linux \
    --prefix=${TEMP_PREFIX} \
    ${GENERAL} \
    --sysroot=$SYSROOT \
    --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -fstack-protector -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" \
    --extra-ldflags="-Wl,-rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -nostdlib -lc -lm -ldl -llog" \
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
    --disable-ffserver \
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
    --disable-filters

./configure \
    --target-os=linux \
    --prefix=${TEMP_PREFIX} \
    ${GENERAL} \
    --sysroot=$SYSROOT \
    --extra-cflags="-DANDROID -O3 -fPIC -ffunction-sections -funwind-tables -fstack-protector  -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" \
    --extra-ldflags="-Wl,-rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -nostdlib -lc -lm -ldl -llog -fPIC" \
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
    --disable-ffserver \
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
    --enable-yasm

make clean
make -j$(getconf _NPROCESSORS_ONLN)
make install

echo "Android arm64-v8a builds finished"
