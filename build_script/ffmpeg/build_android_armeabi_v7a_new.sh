#!/bin/bash

set -e

cd $1
echo "Building FFmpeg for armeabi-v7a, param = $1"
pwd

git clean -fdx

if [[ -z "$ANDROID_NDK" ]]; then
    echo "ANDROID_NDK environment variable not set"
    exit 1
fi

# 设置目标架构和API级别
export TARGET_ARCH=arm
export TARGET_ARCH_ABI=armeabi-v7a
export MIN_SDK_VERSION=21

# 设置工具链路径
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export SYSROOT=$TOOLCHAIN/sysroot

# 设置编译器
export CC=/data/work/FFmpeg-Android/build_script/ffmpeg/clang_wrapper.sh
export CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_SDK_VERSION}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export NM=$TOOLCHAIN/bin/llvm-nm

# 设置交叉编译前缀
export CROSS_PREFIX=$TOOLCHAIN/bin/arm-linux-androideabi-

# 优化编译选项，启用NEON，避免problematic检测
export CFLAGS="-Os -fPIC -DANDROID -D__ANDROID_API__=${MIN_SDK_VERSION} -march=armv7-a -mfloat-abi=softfp -mfpu=neon -ffast-math -fomit-frame-pointer -DHAVE_PTHREAD_CANCEL=0 -D_GNU_SOURCE"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-rpath-link=$SYSROOT/usr/lib/arm-linux-androideabi -L$SYSROOT/usr/lib/arm-linux-androideabi"

# x264路径
X264_PREFIX=${PREFIX}/x264/armeabi-v7a
export PKG_CONFIG_PATH=${X264_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH

TEMP_PREFIX=${PREFIX}/ffmpeg/armeabi-v7a
rm -rf $TEMP_PREFIX
mkdir -p $TEMP_PREFIX

echo "Configuring FFmpeg for armeabi-v7a..."

# 设置环境变量来避免自动检测有问题的特性
export ac_cv_func_pthread_atfork=no
export ac_cv_func_pthread_cancel=no

./configure \
    --target-os=android \
    --arch=arm \
    --cpu=armv7-a \
    --prefix=${TEMP_PREFIX} \
    --enable-cross-compile \
    --cc=$CC \
    --cxx=$CXX \
    --ar=$AR \
    --ranlib=$RANLIB \
    --strip=$STRIP \
    --nm=$NM \
    --sysroot=$SYSROOT \
    --extra-cflags="$CFLAGS -I${X264_PREFIX}/include" \
    --extra-ldflags="$LDFLAGS -L${X264_PREFIX}/lib -L/data/work/FFmpeg-Android/build_script/ffmpeg" \
    --extra-libs="-lx264 -lpthread_stub" \
    --pkg-config-flags="--static" \
    --disable-pthreads \
    --disable-w32threads \
    --disable-os2threads \
    --enable-gpl \
    --enable-version3 \
    --enable-libx264 \
    --enable-encoder=libx264 \
    --enable-encoder=aac \
    --enable-encoder=png \
    --enable-encoder=mjpeg \
    --enable-decoder=h264 \
    --enable-decoder=aac \
    --enable-decoder=mp3 \
    --enable-decoder=png \
    --enable-decoder=mjpeg \
    --enable-parser=h264 \
    --enable-parser=aac \
    --enable-demuxer=mov \
    --enable-demuxer=mp4 \
    --enable-demuxer=avi \
    --enable-demuxer=flv \
    --enable-demuxer=mpegts \
    --enable-muxer=mp4 \
    --enable-muxer=avi \
    --enable-muxer=flv \
    --enable-muxer=mpegts \
    --enable-protocol=file \
    --enable-protocol=http \
    --enable-protocol=https \
    --enable-protocol=tcp \
    --enable-protocol=udp \
    --enable-filter=scale \
    --enable-filter=crop \
    --enable-filter=rotate \
    --enable-small \
    --enable-static \
    --disable-shared \
    --disable-symver \
    --disable-doc \
    --disable-htmlpages \
    --disable-manpages \
    --disable-podpages \
    --disable-txtpages \
    --disable-debug \
    --disable-programs \
    --disable-ffmpeg \
    --disable-ffplay \
    --disable-ffprobe \
    --enable-neon \
    --enable-asm \
    --enable-inline-asm \
    --enable-optimizations \
    --disable-runtime-cpudetect

# 修复configure生成的配置文件
../build_script/ffmpeg/fix_config.sh

echo "Building FFmpeg for armeabi-v7a..."
make clean
make -j$(nproc)
make install

echo "FFmpeg armeabi-v7a build completed"
