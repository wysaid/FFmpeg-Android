#!/usr/bin/env bash

set -e

if [[ -z "$1" ]]; then
    echo "Invalid argument! Usage: $0 <FFMPEG_SOURCE_DIR> [CLEAR_BUILD]"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

FFMPEG_SOURCE_DIR=$1
CLEAR_BUILD=${2:-false}
WORKSPACE_ROOT=$(cd "$THIS_DIR/../.." && pwd)
BUILD_ROOT="$WORKSPACE_ROOT/build"

echo "THIS_DIR=$THIS_DIR"
echo "FFMPEG_SOURCE_DIR=$FFMPEG_SOURCE_DIR"
echo "BUILD_ROOT=$BUILD_ROOT"
echo "CLEAR_BUILD=$CLEAR_BUILD"

# 确保源码目录存在
if [[ ! -d "$FFMPEG_SOURCE_DIR" ]]; then
    echo "Error: FFmpeg source directory does not exist: $FFMPEG_SOURCE_DIR"
    exit 1
fi

# 创建构建根目录
mkdir -p "$BUILD_ROOT"

# 定义要构建的架构列表
ARCHITECTURES=("armeabi-v7a" "arm64-v8a" "x86_64")

# 遍历每个架构进行构建
for arch in "${ARCHITECTURES[@]}"; do
    echo "========================================="
    echo "Building FFmpeg for architecture: $arch"
    echo "========================================="

    # 检查是否已经构建过
    INSTALL_DIR="$BUILD_ROOT/ffmpeg/$arch"
    if [[ -f "$INSTALL_DIR/lib/libavcodec.a" && -f "$INSTALL_DIR/include/libavcodec/avcodec.h" ]]; then
        echo "FFmpeg for $arch already built, skipping..."
        continue
    fi

    # 调用单架构构建脚本
    if [[ "$arch" == "armeabi-v7a" ]]; then
        bash "$THIS_DIR/build_android_armeabi_v7a_new.sh" "$FFMPEG_SOURCE_DIR" "$BUILD_ROOT" "$CLEAR_BUILD"
    elif [[ "$arch" == "arm64-v8a" ]]; then
        bash "$THIS_DIR/build_android_arm64_v8a_new.sh" "$FFMPEG_SOURCE_DIR" "$BUILD_ROOT" "$CLEAR_BUILD"
    elif [[ "$arch" == "x86_64" ]]; then
        bash "$THIS_DIR/build_android_x86_64_new.sh" "$FFMPEG_SOURCE_DIR" "$BUILD_ROOT" "$CLEAR_BUILD"
    fi

    echo "FFmpeg $arch build completed successfully"
done

echo "========================================="
echo "All FFmpeg architectures built successfully"
echo "========================================="
