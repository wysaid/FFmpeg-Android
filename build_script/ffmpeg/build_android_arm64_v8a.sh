#!/bin/bash
git reset --hard
git clean -f -d
git checkout `cat ../ffmpeg-version`
git log --pretty=format:%H -1 > ../ffmpeg-version

#arm64 最小必须是android-21
PLATFORM=$NDK/platforms/android-21/arch-arm64/
PREBUILT=$NDK/toolchains/aarch64-linux-android-4.9/prebuilt/darwin-x86_64

GENERAL="\
--enable-small \
--enable-cross-compile \
--extra-libs="-lgcc" \
--arch=aarch64 \
--cc=$PREBUILT/bin/aarch64-linux-android-gcc \
--cross-prefix=$PREBUILT/bin/aarch64-linux-android- \
--nm=$PREBUILT/bin/aarch64-linux-android-nm \
--extra-cflags="-I${PREFIX}/x264/android/arm64/include" \
--extra-ldflags="-L${PREFIX}/x264/android/arm64/lib" "

MODULES="\
--enable-gpl \
--enable-libx264"

TEMP_PREFIX=${PREFIX}/ffmpeg/android/arm64-v8a
rm -rf $TEMP_PREFIX
export PATH=$PREBUILT/bin/:$PATH/

rm compat/strtod.o
rm compat/strtod.d

function build_arm64
{
  ./configure \
  --logfile=conflog.txt \
  --target-os=linux \
  --prefix=${TEMP_PREFIX} \
  ${GENERAL} \
  --sysroot=$PLATFORM \
  --extra-cflags="" \
  --extra-ldflags="-lx264 -Wl,-rpath-link=$PLATFORM/usr/lib -L$PLATFORM/usr/lib -nostdlib -lc -lm -ldl -llog" \
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
  ${MODULES}

  make clean
  make -j10
  make install

   aarch64-linux-android-ld \
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
    ${PREFIX}/x264/android/arm64/lib/libx264.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $PREBUILT/lib/gcc/aarch64-linux-android/4.9.x/libgcc.a

    cp $TEMP_PREFIX/${SONAME} $TEMP_PREFIX/libffmpeg-debug.so
    aarch64-linux-android-strip --strip-unneeded $TEMP_PREFIX/${SONAME}

    echo SO-Dir=${TEMP_PREFIX}/${SONAME}
}

build_arm64


echo Android ARM64 builds finished
