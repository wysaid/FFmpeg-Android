#!/bin/bash

# 简化的 x264 构建脚本
set -e

WORKSPACE_ROOT=$(cd "$(dirname "$0")" && pwd)
BUILD_ROOT="$WORKSPACE_ROOT/build"
X264_SOURCE="$WORKSPACE_ROOT/x264"

echo "构建 x264 for Android..."
echo "工作空间: $WORKSPACE_ROOT"
echo "构建目录: $BUILD_ROOT"
echo "x264源码: $X264_SOURCE"

# Android NDK 设置
export ANDROID_NDK="/usr/lib/android-sdk/ndk/26.3.11579264"
export TOOLCHAIN="$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64"

# 架构列表
ARCHITECTURES=("armeabi-v7a" "arm64-v8a" "x86_64")

for arch in "${ARCHITECTURES[@]}"; do
    echo "========================================="
    echo "构建 x264 for $arch"
    echo "========================================="
    
    # 设置架构特定变量
    case "$arch" in
        "arm64-v8a")
            ARCH_CC="aarch64-linux-android21-clang"
            ARCH_CONFIG="--host=aarch64-linux-android"
            ARCH_CFLAGS="-march=armv8-a"
            ;;
        "armeabi-v7a") 
            ARCH_CC="armv7a-linux-androideabi21-clang"
            ARCH_CONFIG="--host=arm-linux-androideabi"
            ARCH_CFLAGS="-march=armv7-a -mfloat-abi=softfp -mfpu=neon"
            ;;
        "x86_64")
            ARCH_CC="x86_64-linux-android21-clang"
            ARCH_CONFIG="--host=x86_64-linux-android"
            ARCH_CFLAGS="-march=x86-64"
            ;;
    esac
    
    # 创建构建目录
    BUILD_DIR="$BUILD_ROOT/x264-build/$arch"
    INSTALL_DIR="$BUILD_ROOT/x264/$arch"
    
    mkdir -p "$BUILD_DIR"
    mkdir -p "$INSTALL_DIR"
    
    # 复制源码
    rm -rf "$BUILD_DIR"/*
    cp -r "$X264_SOURCE"/* "$BUILD_DIR/"
    
    cd "$BUILD_DIR"
    
    # 设置编译环境
    export CC="$TOOLCHAIN/bin/$ARCH_CC"
    export CFLAGS="-fPIC -Os -DANDROID -D_GNU_SOURCE -D_LARGEFILE_SOURCE -D_FILE_OFFSET_BITS=64 $ARCH_CFLAGS"
    export LDFLAGS=""
    
    # 配置 x264
    ./configure \
        --prefix="$INSTALL_DIR" \
        $ARCH_CONFIG \
        --enable-static \
        --disable-shared \
        --disable-cli \
        --enable-pic \
        --disable-asm \
        --extra-cflags="$CFLAGS" \
        --extra-ldflags="$LDFLAGS"
    
    # 编译安装
    make clean
    make -j$(nproc)
    make install
    
    echo "x264 $arch 构建完成"
done

echo "所有 x264 架构构建完成！"
