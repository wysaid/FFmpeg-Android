#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <FFMPEG_SOURCE_DIR> <BUILD_ROOT>"
    exit 1
fi

FFMPEG_SOURCE_DIR=$1
BUILD_ROOT=$2
ARCH=arm64-v8a

echo "Building FFmpeg for $ARCH"
echo "Source: $FFMPEG_SOURCE_DIR"
echo "Build root: $BUILD_ROOT"

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

# 清理并创建构建目录
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"
mkdir -p "$INSTALL_DIR"

# 复制源码到构建目录
echo "Copying source files..."
cp -r "$FFMPEG_SOURCE_DIR"/* "$BUILD_DIR/"

# 进入构建目录
cd "$BUILD_DIR"

# 设置目标架构和API级别
export TARGET_ARCH=aarch64
export TARGET_ARCH_ABI=arm64-v8a
export MIN_SDK_VERSION=21

# 设置工具链路径
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export SYSROOT=$TOOLCHAIN/sysroot

# 创建pthread_atfork stub库
cat >pthread_atfork_stub.c <<'EOF'
// Stub implementation for pthread_atfork
int pthread_atfork(void (*prepare)(void), void (*parent)(void), void (*child)(void)) {
    return 0;
}
EOF

# 编译stub库
$TOOLCHAIN/bin/aarch64-linux-android${MIN_SDK_VERSION}-clang -c -o pthread_atfork_stub.o pthread_atfork_stub.c
$TOOLCHAIN/bin/llvm-ar rcs libpthread_stub.a pthread_atfork_stub.o

# 设置编译器
export CC=$TOOLCHAIN/bin/aarch64-linux-android${MIN_SDK_VERSION}-clang
export CXX=$TOOLCHAIN/bin/aarch64-linux-android${MIN_SDK_VERSION}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=$TOOLCHAIN/bin/llvm-strip
export NM=$TOOLCHAIN/bin/llvm-nm

# 设置交叉编译前缀
export CROSS_PREFIX=$TOOLCHAIN/bin/aarch64-linux-android-

# 优化编译选项，启用NEON，避免problematic检测
export CFLAGS="-Os -fPIC -DANDROID -D__ANDROID_API__=${MIN_SDK_VERSION} -march=armv8-a -ffast-math -fomit-frame-pointer -DHAVE_PTHREAD_CANCEL=0 -D_GNU_SOURCE"
export CPPFLAGS="$CFLAGS"
export LDFLAGS="-Wl,-rpath-link=$SYSROOT/usr/lib/aarch64-linux-android -L$SYSROOT/usr/lib/aarch64-linux-android"

# x264路径
export PKG_CONFIG_PATH=${X264_PREFIX}/lib/pkgconfig:$PKG_CONFIG_PATH

echo "Configuring FFmpeg for $ARCH..."

# 设置环境变量来避免自动检测有问题的特性
export ac_cv_func_pthread_atfork=no
export ac_cv_func_pthread_cancel=no
./configure \
    --target-os=android \
    --arch=aarch64 \
    --cpu=armv8-a \
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

echo "Building FFmpeg for $ARCH..."
make clean
make -j$(nproc)
make install

echo "FFmpeg $ARCH build completed successfully"
echo "Libraries installed to: $INSTALL_DIR"
