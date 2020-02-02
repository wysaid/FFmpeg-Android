#!/bin/bash

cd $1
echo "param = $1"
pwd

git clean -fdx

export NDK_STANDALONE_TOOLCHAIN=$NDK_TOOLCHAIN_DIR/arm
export SYSROOT=$NDK_STANDALONE_TOOLCHAIN/sysroot
export CROSS_PREFIX=$NDK_STANDALONE_TOOLCHAIN/bin/arm-linux-androideabi-

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--arch=arm \
--cc=${CROSS_PREFIX}gcc \
--cross-prefix=$CROSS_PREFIX \
--nm=${CROSS_PREFIX}nm \
--extra-cflags="-I${PREFIX}/x264/arm/include" \
--extra-ldflags="-L${PREFIX}/x264/arm/lib" "


MODULES="\
--enable-gpl \
--enable-libx264"

TEMP_PREFIX=${PREFIX}/ffmpeg/armeabi-v7a
rm -rf $TEMP_PREFIX
export PATH=$NDK_STANDALONE_TOOLCHAIN/bin:$PATH/

git clean -fdx

function build_ARMv7
{
  ./configure \
  --target-os=linux \
  --prefix=${TEMP_PREFIX} \
  ${GENERAL} \
  --sysroot=$SYSROOT \
  --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" \
  --extra-ldflags="-Wl,-rpath-link=$SYSROOT/usr/lib -L$SYSROOT/usr/lib -nostdlib -lc -lm -ldl -llog" \
  --enable-zlib \
  --enable-static \
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
  --disable-protocols  \
  --enable-zlib \
  --enable-protocol=file  \
  --enable-protocol=pipe  \
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
  --enable-network \
  --enable-swscale \
  --enable-hwaccels \
  --enable-avfilter \
  --enable-asm \
  --enable-version3 \
  ${MODULES} \
  --disable-doc \
  --enable-neon

  make clean
  make -j10
  make install

   arm-linux-androideabi-ld \
    -rpath-link=$SYSROOT/usr/lib \
    -L$SYSROOT/usr/lib \
    -L$TEMP_PREFIX/lib \
    -soname ${SONAME} -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $TEMP_PREFIX/${SONAME} \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
    libavformat/libavformat.a \
    libavutil/libavutil.a \
    libswscale/libswscale.a \
    libpostproc/libpostproc.a \
    ${PREFIX}/x264/arm/lib/libx264.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $NDK_STANDALONE_TOOLCHAIN/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a

    cp $TEMP_PREFIX/${SONAME} $TEMP_PREFIX/libffmpeg-debug.so
    arm-linux-androideabi-strip --strip-unneeded $TEMP_PREFIX/${SONAME}

    echo SO-Dir=${TEMP_PREFIX}/${SONAME}
}

build_ARMv7
echo "Android ARMv7-a builds finished"
