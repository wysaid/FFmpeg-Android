DEST=`pwd`/build && rm -rf $DEST
FFMPEGDEST="$DEST/ffmpeg"
X264DEST="$DEST/x264"
FFMPEGSOURCE=`pwd`/ffmpeg
X264SOURCE=`pwd`/x264
TOOLCHAIN=/tmp/vplayer
SYSROOT=$TOOLCHAIN/sysroot/
export PATH=$TOOLCHAIN/bin:$PATH

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
  $ANDROID_NDK/build/tools/make-standalone-toolchain.sh --arch=$ARCH --platform=android-14 --install-dir=$TOOLCHAIN
}

setup_version() {
  local VERSION=$1
  local X264BUILD="$X264DEST/$VERSION"
  export FFMPEG_FLAGS=""
  case $VERSION in
    neon)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv7-a -mfpu=neon -mfloat-abi=softfp -mvectorize-with-neon-quad"
      export EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="ccache ${CROSSPREFIX}-gcc"
      ;;
    armv7)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv7-a -mfpu=vfpv3-d16 -mfloat-abi=softfp"
      export EXTRA_LDFLAGS="-Wl,--fix-cortex-a8"
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="ccache ${CROSSPREFIX}-gcc"
      ;;
    vfp)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv6 -mfpu=vfp -mfloat-abi=softfp"
      export EXTRA_LDFLAGS=""
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="ccache ${CROSSPREFIX}-gcc"
      ;;
    armv6)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv6"
      export EXTRA_LDFLAGS=""
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="ccache ${CROSSPREFIX}-gcc"
      ;;
    armv5)
      export ARCH="arm"
      export EXTRA_CFLAGS="-march=armv5"
      export EXTRA_LDFLAGS=""
      export LD=arm-linux-androideabi-ld
      export AR=arm-linux-androideabi-ar
      export CROSSPREFIX="${ARCH}-linux-androideabi"
      export CC="ccache ${CROSSPREFIX}-gcc"
      ;;
    mips)
      export ARCH="mips"
      export EXTRA_CFLAGS=""
      export EXTRA_LDFLAGS=""
      export LD=mipsel-linux-android-ld
      export AR=mipsel-linux-android-ar
      export CROSSPREFIX="mipsel-linux-android"
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
    echo "buiding x264 to $X264BUILD"
    ./configure \
      $X264_FLAGS \
      --host=arm-linux \
      --disable-cli \
      --enable-pic \
      --enable-shared \
      --cross-prefix=${CROSSPREFIX}-  \
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
    echo "buiding ffmpeg to $FFMPEGBUILD"
    ./configure \
      $FFMPEG_FLAGS \
      --target-os=linux \
      --arch="$ARCH" \
      --enable-cross-compile \
      --cross-prefix=${CROSSPREFIX}- \
      --sysroot=$SYSROOT \
      --enable-shared \
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
      --disable-everything \
      --disable-protocols  \
      --enable-protocol=file  \
      --enable-protocol=pipe  \
      --disable-parsers \
      --enable-parser=h264 \
      --enable-parser=aac \
      --disable-demuxers \
      --enable-demuxer=mp4 \
      --enable-demuxer=mov \
      --enable-demuxer=mp3 \
      --enable-demuxer=aac \
      --disable-decoders \
      --enable-decoder=aac \
      --enable-decoder=h264 \
      --enable-decoder=mp3 \
      --disable-muxers \
      --enable-muxer=mp4 \
      --disable-encoders \
      --enable-encoder=aac \
      --enable-encoder=libx264 \
      --enable-gpl \
      --enable-network \
      --enable-swscale  \
      --enable-hwaccels \
      --disable-avfilter \
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
  echo "$CC -lm -lz -shared --sysroot=$SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FFMPEG_EXTRA_LDFLAGS libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o libavformat/*.o libswresample/*.o libswscale/*.o compat/*.o libswresample/arm/*.o libavfilter/*.o -o $FFMPEGBUILD/libffmpeg.so"
  $CC -lm -lz -shared --sysroot=$SYSROOT -Wl,--no-undefined -Wl,-z,noexecstack $FFMPEG_EXTRA_LDFLAGS libavutil/*.o libavutil/arm/*.o libavcodec/*.o libavcodec/arm/*.o libavformat/*.o libswresample/*.o libswscale/*.o compat/*.o libswresample/arm/*.o libavfilter/*.o  -o $FFMPEGBUILD/libffmpeg.so

  cp $FFMPEGBUILD/libffmpeg.so $FFMPEGBUILD/libffmpeg-debug.so

  arm-linux-androideabi-strip --strip-unneeded $FFMPEGBUILD/libffmpeg.so

  popd
}

build_version() {
  local VERSION=$1
  setup_version $VERSION
  prepare_ndk
  build_x264 $VERSION
  build_ffmpeg $VERSION
}

#checkout_x264
checkout_ffmpeg

# build_x264 "neon"
# build_x264 "armv7"
# build_ffmpeg "armv7"

# build_version "x86"
build_version "armv7"
# for version in neon armv5 armv6 armv7 vfp mips x86 x86_64; do
#   build_version $version
# done

# for version in mips x86; do
#   build_version $version
# done