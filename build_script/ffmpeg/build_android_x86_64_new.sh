#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <FFMPEG_SOURCE_DIR> <BUILD_ROOT> [CLEAR_BUILD]"
    exit 1
fi

FFMPEG_SOURCE_DIR=$1
BUILD_ROOT=$2
CLEAR_BUILD=${3:-false}
ARCH=x86_64

echo "Building FFmpeg for $ARCH"
echo "Source: $FFMPEG_SOURCE_DIR"
echo "Build root: $BUILD_ROOT"
echo "Clear build: $CLEAR_BUILD"

if [[ -z "$ANDROID_NDK" ]]; then
    echo "ANDROID_NDK environment variable not set"
    exit 1
fi

# 创建架构特定的构建目录
BUILD_DIR="$BUILD_ROOT/ffmpeg-build/$ARCH"
INSTALL_DIR="$BUILD_ROOT/ffmpeg/$ARCH"
X264_PREFIX="$BUILD_ROOT/x264/$ARCH"

echo "Build directory: $BUILD_DIR"
echo "Install directory: $INSTALL_DIR"
echo "x264 prefix: $X264_PREFIX"

# 确保x264已经构建
if [[ ! -f "$X264_PREFIX/lib/libx264.a" ]]; then
    echo "Error: x264 for $ARCH not found. Please build x264 first."
    exit 1
fi

# 创建目录
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

# 检查是否已经配置过，如果需要清理或者从未配置过，则重新配置
CONFIGURE_DONE=false
if [[ -f "$BUILD_DIR/config.mak" && -f "$BUILD_DIR/Makefile" ]]; then
    echo "Configuration already exists for $ARCH"
    CONFIGURE_DONE=true
fi

# 如果需要清理或从未配置过，则重新设置
if [[ "$CLEAR_BUILD" == "true" || "$CONFIGURE_DONE" == "false" ]]; then
    if [[ "$CLEAR_BUILD" == "true" ]]; then
        echo "Clearing build directory for $ARCH..."
        rm -rf "$BUILD_DIR"
        mkdir -p "$BUILD_DIR"
    fi

    # 复制源码到构建目录
    echo "Copying source files..."
    cp -r "$FFMPEG_SOURCE_DIR"/* "$BUILD_DIR/"
    CONFIGURE_DONE=false
fi

# 进入构建目录
cd "$BUILD_DIR"

# 设置目标架构和API级别
export TARGET_ARCH=x86_64
export TARGET_ARCH_ABI=x86_64
export MIN_SDK_VERSION=21
export NDK_TOOLCHAIN_VERSION=clang

# 设置工具链路径
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export SYSROOT=$TOOLCHAIN/sysroot

# 设置编译器
export CC=$TOOLCHAIN/bin/x86_64-linux-android${MIN_SDK_VERSION}-clang
export CXX=$TOOLCHAIN/bin/x86_64-linux-android${MIN_SDK_VERSION}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=true # 使用无害的true命令替代strip，避免汇编文件的重定位符号问题
export NM=$TOOLCHAIN/bin/llvm-nm

# 设置交叉编译前缀
export CROSS_PREFIX=$TOOLCHAIN/bin/llvm-

# 设置编译选项，确保PIC兼容，特别针对x86_64汇编
export CFLAGS="-fPIC -DANDROID -D__ANDROID_API__=${MIN_SDK_VERSION} -D_POSIX_C_SOURCE=200112L -D_GNU_SOURCE"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-z,notext"
# 为汇编代码添加PIC标志
export ASFLAGS="-fPIC"

# 创建 pthread_atfork stub
cat >pthread_stub.c <<'EOF'
#include <errno.h>

int pthread_atfork(void (*prepare)(void), void (*parent)(void), void (*child)(void)) {
    return ENOSYS;
}
EOF

# 编译 pthread_atfork stub
$CC -c pthread_stub.c -o pthread_stub.o
$AR rcs libpthread_stub.a pthread_stub.o

# x264路径
export PKG_CONFIG_PATH=${X264_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH

# 设置环境变量来避免自动检测有问题的特性
export ac_cv_func_pthread_atfork=no
export ac_cv_func_pthread_cancel=no

# 只有在需要时才重新配置
if [[ "$CONFIGURE_DONE" == "false" ]]; then
    echo "Configuring FFmpeg for $ARCH..."
    ./configure \
        --target-os=android \
        --arch=x86_64 \
        --cpu=x86-64 \
        --prefix="$INSTALL_DIR" \
        --enable-cross-compile \
        --cc=$CC \
        --cxx=$CXX \
        --ar=$AR \
        --ranlib=$RANLIB \
        --strip=$STRIP \
        --nm=$NM \
        --sysroot=$SYSROOT \
        --extra-cflags="$CFLAGS -I${X264_PREFIX}/include" \
        --extra-ldflags="$LDFLAGS -L${X264_PREFIX}/lib -L$BUILD_DIR" \
        --extra-libs="-lx264 -lpthread_stub" \
        --as="$CC" \
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
        --enable-asm \
        --enable-inline-asm \
        --enable-optimizations \
        --disable-runtime-cpudetect
else
    echo "Using existing configuration for $ARCH"
fi

echo "Building FFmpeg for $ARCH..."
# 不使用 make clean，允许增量构建
make -j$(nproc)
make install

echo "FFmpeg $ARCH build completed successfully"
echo "Libraries installed to: $INSTALL_DIR"
