#!/bin/bash

cd $1
echo "param = $1"
pwd

git clean -fdx

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/x86_64
export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/x86_64-linux-android-

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--arch=x86_64 \
--cc=${CROSS_PREFIX}gcc \
--cross-prefix=$CROSS_PREFIX \
--nm=${CROSS_PREFIX}nm \
--extra-cflags="-I${PREFIX}/x264/x86_64/include" \
--extra-ldflags="-L${PREFIX}/x264/x86_64/lib" "

MODULES="\
--enable-gpl \
--enable-libx264"

TEMP_PREFIX=${PREFIX}/ffmpeg/x86_64
rm -rf $TEMP_PREFIX
export PATH=$NDK_STANDALONE_TOOLCHAIN/bin:$PATH/

git clean -fdx

echo ./configure \
    --target-os=linux \
    --prefix=${TEMP_PREFIX} \
    ${GENERAL} \
    --sysroot=$SYSROOT \
    --extra-cflags="-DANDROID -fPIC -fpic -O3 -ffunction-sections -funwind-tables -fstack-protector  -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300 -fasm -Wno-psabi -fno-short-enums -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel" \
    --extra-ldflags="-Wl,-rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -nostdlib -lc -lm -ldl -llog -fPIC -fpic -fPIE" \
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
    --enable-yasm \
    --disable-linux-perf

./configure \
    --target-os=linux \
    --prefix=${TEMP_PREFIX} \
    ${GENERAL} \
    --sysroot=$SYSROOT \
    --extra-cflags="-DANDROID -fPIC -fpic -O3 -ffunction-sections -funwind-tables -fstack-protector  -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300 -fasm -Wno-psabi -fno-short-enums -march=x86-64 -msse4.2 -mpopcnt -m64 -mtune=intel" \
    --extra-ldflags="-Wl,-rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -nostdlib -lc -lm -ldl -llog -fPIC -fpic -fPIE" \
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
    --enable-yasm \
    --disable-linux-perf

make clean
make -j$(getconf _NPROCESSORS_ONLN)
make install

echo "Android x86_64 builds finished"
