#!/usr/bin/env bash

set -e

if [[ -z "$1" ]]; then
    echo "Invalid argument! Usage: $0 <X264_SOURCE_DIR>"
    exit 1
fi

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

X264_SOURCE_DIR=$1
WORKSPACE_ROOT=$(cd "$THIS_DIR/../.." && pwd)
BUILD_ROOT="$WORKSPACE_ROOT/build"

echo "THIS_DIR=$THIS_DIR"
echo "X264_SOURCE_DIR=$X264_SOURCE_DIR"
echo "BUILD_ROOT=$BUILD_ROOT"

# 确保源码目录存在
if [[ ! -d "$X264_SOURCE_DIR" ]]; then
    echo "Error: X264 source directory does not exist: $X264_SOURCE_DIR"
    exit 1
fi

# 创建构建根目录
mkdir -p "$BUILD_ROOT"

# 定义要构建的架构列表
ARCHITECTURES=("armeabi-v7a" "arm64-v8a" "x86_64")

# 遍历每个架构进行构建
for arch in "${ARCHITECTURES[@]}"; do
    echo "========================================="
    echo "Building x264 for architecture: $arch"
    echo "========================================="
    
    # 检查是否已经构建过
    INSTALL_DIR="$BUILD_ROOT/x264/$arch"
    if [[ -f "$INSTALL_DIR/lib/libx264.a" && -f "$INSTALL_DIR/include/x264.h" ]]; then
        echo "x264 for $arch already built, skipping..."
        continue
    fi
    
    # 调用单架构构建脚本
    bash "$THIS_DIR/build_android_${arch}_new.sh" "$X264_SOURCE_DIR" "$BUILD_ROOT"
    
    echo "x264 $arch build completed successfully"
done

echo "========================================="
echo "All x264 architectures built successfully"
echo "========================================="
