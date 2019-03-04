#!/bin/bash

DEST=`pwd`/build && rm -rf $DEST
FFMPEGDEST="$DEST/ffmpeg"
X264DEST="$DEST/x264"
FFMPEGSOURCE=`pwd`/ffmpeg
X264SOURCE=`pwd`/x264
TOOLCHAIN=`pwd`/tmp/vplayer
SYSROOT=$TOOLCHAIN/sysroot/
export PATH=$TOOLCHAIN/bin/:$PATH/
SONAME=libbzffmpeg.so

if [ -z $ANDROID_NDK ]; then
  ANDROID_NDK=$NDK
fi
if [ -z $ANDROID_NDK ]; then
  echo "ANDROID_NDK variable msut be set"
  exit 1
fi

CFLAGS="-O3 -Wall -mthumb -pipe -fpic -fasm \
-finline-limit=300 -ffast-math \
-fstrict-aliasing -Werror=strict-aliasing \
-fmodulo-sched -fmodulo-sched-allow-regmoves \
-Wno-psabi -Wa,--noexecstack \
-D__ARM_ARCH_5__ -D__ARM_ARCH_5E__ -D__ARM_ARCH_5T__ -D__ARM_ARCH_5TE__ \
-DANDROID -DNDEBUG"

checkout_ffmpeg() {
  if [ ! -d ffmpeg ]; then
    git clone git://source.ffmpeg.org/ffmpeg.git ffmpeg  
  fi

  pushd $FFMPEGSOURCE
    git reset --hard
    git clean -f -d
    git checkout `cat ../ffmpeg-version`
    git log --pretty=format:%H -1 > ../ffmpeg-version
  popd
}

checkout_x264() {
  if [ ! -d x264 ]; then
    git clone git://git.videolan.org/x264.git
  fi

  pushd $X264SOURCE
    git reset --hard
    git clean -f -d
    git checkout `cat ../x264-version`
    git log --pretty=format:%H -1 > ../x264-version
  popd
}

prepare_ndk() {
  $ANDROID_NDK/build/tools/make_standalone_toolchain.py --force --arch=$ARCH --api=21 --install-dir=$TOOLCHAIN
}

setup_version() {
  local VERSION=$1
  export X264BUILD="$X264DEST/$VERSION"
  export FFMPEG_FLAGS=""
  case $VERSION in
    neon)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad"
      export EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="${CROSSPREFIX}-gcc"
      ;;
    armv7)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp"
      export EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="${CROSSPREFIX}-gcc"
      ;;
    vfp)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=softfp"
      export EXTRA_LDFLAGS=""
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="${CROSSPREFIX}-gcc"
      ;;
    armv6)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv6"
      export EXTRA_LDFLAGS=""
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="${CROSSPREFIX}-gcc"
      ;;
    armv5)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv5"
      export EXTRA_LDFLAGS=""
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="${CROSSPREFIX}-gcc"
      export FFMPEG_FLAGS="--disable-asm"
      export X264_FLAGS="--disable-asm"
      ;;
    mips)
      export ARCH="mips"
      export EXTRA_CFLAGS=""
      export EXTRA_LDFLAGS=""
      export LD=mipsel-linux-android-ld
      export AR=mipsel-linux-android-ar
      export CROSSPREFIX="${TOOLCHAIN}/bin/mipsel-linux-android"
      export CC="ccache ${CROSSPREFIX}-gcc"
      export FFMPEG_FLAGS="--disable-asm"
      export X264_FLAGS="--disable-asm"
      # mipsel
      ;;
    x86)
      export ARCH="x86"
      export EXTRA_CFLAGS="-march=atom -std=c99 -O3 -Wall -fpic -pipe -msse3 -ffast-math -mfpmath=sse"
      export EXTRA_LDFLAGS="-lm -lz -Wl,--no-undefined -Wl,-z,noexecstack"
      export LD=i686-linux-android-ld
      export AR=i686-linux-android-ar
      export CROSSPREFIX="i686-linux-android"
      export CC="ccache ${CROSSPREFIX}-gcc"
      export FFMPEG_FLAGS="--disable-asm"
      export X264_FLAGS="--disable-asm"
      ;;
    arm64_v8a)
      export ARCH="arm64"
      export EXTRA_CFLAGS="-march=aarch64 -mfpu=vfpv3-d16 -mfloat-abi=softfp"
      export EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      export LD=aarch64-linux-androideabi-ld
      export AR=aarch64-linux-androideabi-ar
      export CROSSPREFIX="aarch64-linux-android"
      export CC="ccache aarch64-linux-android-gcc-4.9.x"
      ;;
    *)
      echo "$VERSION is not a supported architecture."
      exit 1;
      ;;
  esac

  export FFMPEG_EXTRA_CFLAGS="$EXTRA_CFLAGS"
  export FFMPEG_EXTRA_LDFLAGS="$EXTRA_LDFLAGS"
  export FFMPEG_FLAGS="$FFMPEG_FLAGS --enable-libx264"
  export FFMPEG_EXTRA_CFLAGS="$FFMPEG_EXTRA_CFLAGS -I${X264BUILD}/include"
  export FFMPEG_EXTRA_LDFLAGS="$FFMPEG_EXTRA_LDFLAGS -L${X264BUILD}/lib -lx264"
  export X264_EXTRA_CFLAGS="$EXTRA_CFLAGS"
  export X264_EXTRA_LDFLAGS="$EXTRA_CFLAGS"
}
build_x264() {
  local VERSION=$1
  pushd $X264SOURCE
    local X264BUILD="$X264DEST/$VERSION"
    mkdir -p $X264BUILD || exit 1
    echo "---------------------------"
    echo "buiding x264 to $X264BUILD"
    echo "patch=$PATH"
    echo "cross-prefix=${CROSSPREFIX}-"
    ./configure \
      $X264_FLAGS \
      --host=aarch64-linux \
      --disable-cli \
      --enable-pic \
      --enable-static \
      --cross-prefix=aarch64-linux-android- \
      --sysroot=$SYSROOT \
      --extra-cflags="$CFLAGS $X264_EXTRA_CFLAGS" \
      --extra-ldflags="$X264_EXTRA_LDFLAGS" \
      --prefix="$X264BUILD" \
      | tee $X264BUILD/configuration.txt
      cp config.* $X264BUILD
      [ $PIPESTATUS == 0 ] || exit 1
      make clean
      make -j10 || exit 1
      make install || exit 1
      rm $X264BUILD/config*
  popd
}

build_ffmpeg() {
  local VERSION=$1
  pushd $FFMPEGSOURCE
    git reset --hard
    git clean -f -d
#patch -p1 <../FFmpeg-VPlayer.patch
    [ $PIPESTATUS == 0 ] || exit 1

    local FFMPEGBUILD="$FFMPEGDEST/$VERSION"
    mkdir -p $FFMPEGBUILD || exit 1
    echo "---------------------------"
    echo "buiding ffmpeg to $FFMPEGBUILD"
    ./configure \
      $FFMPEG_FLAGS \
      --target-os=linux \
      --arch="$ARCH" \
      --enable-cross-compile \
      --cross-prefix=${CROSSPREFIX}- \
      --sysroot=$SYSROOT \
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
      --prefix="$FFMPEGBUILD" \
      --extra-cflags="$CFLAGS $FFMPEG_EXTRA_CFLAGS" \
      --extra-ldflags="$FFMPEG_EXTRA_LDFLAGS" \
      | tee $FFMPEGBUILD/configuration.txt
    cp config.* $FFMPEGBUILD
    [ $PIPESTATUS == 0 ] || exit 1

    make clean
    make -j10 || exit 1
#make install || exit 1
    make prefix=$FFMPEGBUILD install || exit 1
    rm $FFMPEGBUILD/config*
#cp $FFMPEGSOURCE/ffmpeg $FFMPEGBUILD/

    rm libavcodec/log2_tab.o
    rm libswresample/log2_tab.o
    rm libavformat/log2_tab.o
  # echo "$CC -lm -lz -shared --sysroot=$SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FFMPEG_EXTRA_LDFLAGS libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o libavformat/*.o libswresample/*.o libswscale/*.o compat/*.o libswresample/arm/*.o libavfilter/*.o -o $FFMPEGBUILD/libffmpeg.so"
  # $CC -lm -lz -shared --sysroot=$SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FFMPEG_EXTRA_LDFLAGS libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o libavformat/*.o libswresample/*.o libswscale/*.o compat/*.o libswresample/arm/*.o libavfilter/*.o  -o $FFMPEGBUILD/libbzmpeg.so

  # cp $FFMPEGBUILD/libbzmpeg.so $FFMPEGBUILD/libbzmpeg-debug.so

  # arm-linux-androideabi-strip --strip-unneeded $FFMPEGBUILD/libbzmpeg.so

    $LD \
    -rpath-link=${SYSROOT}usr/lib \
    -L${SYSROOT}usr/lib \
    -L$FFMPEGBUILD/lib \
    -soname ${SONAME} -shared -nostdlib -Bsymbolic --whole-archive --no-undefined -o \
    $FFMPEGBUILD/${SONAME} \
    libavcodec/libavcodec.a \
    libavfilter/libavfilter.a \
    libswresample/libswresample.a \
    libavformat/libavformat.a \
    libavutil/libavutil.a \
    libswscale/libswscale.a \
    libpostproc/libpostproc.a \
    $X264BUILD/lib/libx264.a \
    -lc -lm -lz -ldl -llog --dynamic-linker=/system/bin/linker \
    $TOOLCHAIN/lib/gcc/${CROSSPREFIX}/4.9.x/libgcc.a

    cp $FFMPEGBUILD/${SONAME} $FFMPEGBUILD/libffmpeg-debug.so
    arm-linux-androideabi-strip --strip-unneeded $FFMPEGBUILD/${SONAME}

    echo SO-Dir=${FFMPEGBUILD}/${SONAME}
  popd
}

build_version() {
  local VERSION=$1
  setup_version $VERSION
  prepare_ndk
  build_x264 $VERSION
  build_ffmpeg $VERSION
}

checkout_x264
checkout_ffmpeg

#build_version "armv7"
build_version "arm64_v8a"

# for version in armv5 armv6 armv7 vfp; do
#   build_version $version
# done

# for version in neon armv5 armv6 armv7 vfp mips x86; do
#   build_version $version
# done
