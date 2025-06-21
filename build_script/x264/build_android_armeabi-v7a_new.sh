#!/bin/bash

set -e

if [[ -z "$1" || -z "$2" ]]; then
    echo "Usage: $0 <X264_SOURCE_DIR> <BUILD_ROOT> [CLEAR_BUILD]"
    exit 1
fi

X264_SOURCE_DIR=$1
BUILD_ROOT=$2
CLEAR_BUILD=${3:-false}
ARCH=armeabi-v7a

echo "Building x264 for $ARCH"
echo "Source: $X264_SOURCE_DIR"
echo "Build root: $BUILD_ROOT"
echo "Clear build: $CLEAR_BUILD"

if [[ -z "$ANDROID_NDK" ]]; then
    echo "ANDROID_NDK environment variable not set"
    exit 1
fi

# 创建架构特定的构建目录
BUILD_DIR="$BUILD_ROOT/x264-build/$ARCH"
INSTALL_DIR="$BUILD_ROOT/x264/$ARCH"

echo "Build directory: $BUILD_DIR"
echo "Install directory: $INSTALL_DIR"

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
    cp -r "$X264_SOURCE_DIR"/* "$BUILD_DIR/"
    CONFIGURE_DONE=false
fi

# 进入构建目录
cd "$BUILD_DIR"

# 设置目标架构和API级别
export TARGET_ARCH=arm
export TARGET_ARCH_ABI=armeabi-v7a
export MIN_SDK_VERSION=21
export NDK_TOOLCHAIN_VERSION=clang

# 设置工具链路径
export TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export SYSROOT=$TOOLCHAIN/sysroot

# 设置编译器
export CC=$TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_SDK_VERSION}-clang
export CXX=$TOOLCHAIN/bin/armv7a-linux-androideabi${MIN_SDK_VERSION}-clang++
export AR=$TOOLCHAIN/bin/llvm-ar
export RANLIB=$TOOLCHAIN/bin/llvm-ranlib
export STRIP=true # 使用无害的true命令替代strip，避免汇编文件的重定位符号问题
export NM=$TOOLCHAIN/bin/llvm-nm

# 设置交叉编译前缀
export CROSS_PREFIX=$TOOLCHAIN/bin/llvm-

# 设置编译选项，启用NEON
export CFLAGS="-fPIC -DANDROID -D__ANDROID_API__=${MIN_SDK_VERSION} -march=armv7-a -mfloat-abi=softfp -mfpu=neon -D_POSIX_C_SOURCE=200112L -D_GNU_SOURCE"
export CPPFLAGS="$CFLAGS"
export LDFLAGS=""

# 只有在需要时才重新配置
if [[ "$CONFIGURE_DONE" == "false" ]]; then
    echo "Configuring x264 for $ARCH..."
    ./configure \
        --prefix="$INSTALL_DIR" \
        --enable-static \
        --enable-pic \
        --disable-cli \
        --host=arm-linux-androideabi \
        --cross-prefix=$CROSS_PREFIX \
        --sysroot=$SYSROOT \
        --extra-cflags="$CFLAGS" \
        --extra-ldflags="$LDFLAGS"

    # 修复Android NDK兼容性问题
    sed -i 's/#define fseek fseeko//g' config.h
    sed -i 's/#define ftell ftello//g' config.h
else
    echo "Using existing configuration for $ARCH"
fi

echo "Building x264 for $ARCH..."
# 不使用 make clean，允许增量构建
make -j$(nproc)
make install

echo "x264 $ARCH build completed successfully"
echo "Libraries installed to: $INSTALL_DIR"
