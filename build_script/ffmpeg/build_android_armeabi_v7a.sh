#!/bin/bash
git reset --hard
git clean -f -d
git checkout `cat ../ffmpeg-version`
git log --pretty=format:%H -1 > ../ffmpeg-version

PLATFORM=$NDK/platforms/android-14/arch-arm/
PREBUILT=$NDK/toolchains/arm-linux-androideabi-4.9/prebuilt/darwin-x86_64

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--arch=arm \
--cc=$PREBUILT/bin/arm-linux-androideabi-gcc \
--cross-prefix=$PREBUILT/bin/arm-linux-androideabi- \
--nm=$PREBUILT/bin/arm-linux-androideabi-nm \
--extra-cflags="-I${PREFIX}/x264/android/arm/include" \
--extra-ldflags="-L${PREFIX}/x264/android/arm/lib" "


MODULES="\
--enable-gpl \
--enable-libx264"

TEMP_PREFIX=${PREFIX}/ffmpeg/android/armeabi-v7a
rm -rf $TEMP_PREFIX
export PATH=$PREBUILT/bin/:$PATH/

rm compat/strtod.o
rm compat/strtod.d

function build_ARMv7
{
  ./configure \
  --target-os=linux \
  --prefix=${TEMP_PREFIX} \
  ${GENERAL} \
  --sysroot=$PLATFORM \
  --extra-cflags="-DANDROID -fPIC -ffunction-sections -funwind-tables -fstack-protector -march=armv7-a -mfloat-abi=softfp -mfpu=vfpv3-d16 -fomit-frame-pointer -fstrict-aliasing -funswitch-loops -finline-limit=300" \
  --extra-ldflags="-Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
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
    -rpath-link=${PLATFORM}usr/lib \
    -L${PLATFORM}usr/lib \
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
    ${PREFIX}/x264/android/arm/lib/libx264.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $PREBUILT/lib/gcc/arm-linux-androideabi/4.9.x/libgcc.a

    cp $TEMP_PREFIX/${SONAME} $TEMP_PREFIX/libffmpeg-debug.so
    arm-linux-androideabi-strip --strip-unneeded $TEMP_PREFIX/${SONAME}

    echo SO-Dir=${TEMP_PREFIX}/${SONAME}
}

build_ARMv7
echo Android ARMv7-a builds finished
