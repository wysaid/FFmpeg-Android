#!/bin/bash

echo "=== 测试增量构建系统 ==="
echo ""

# 显示用法
echo "用法："
echo "  $0                    # 正常增量构建"
echo "  $0 --clear           # 清理后重新构建"
echo ""

# 检查参数
if [[ "$1" == "--clear" ]]; then
    echo "测试清理构建..."
    echo "bash build_android.sh --clear"
else
    echo "测试增量构建..."
    echo "bash build_android.sh"
fi

echo ""
echo "注意：这只是显示命令，请手动执行实际的构建测试"
echo ""

# 显示一些状态信息
echo "当前构建目录状态："
if [[ -d "build" ]]; then
    echo "build/ 目录存在"
    for arch in armeabi-v7a arm64-v8a x86_64; do
        if [[ -d "build/x264/$arch" ]]; then
            echo "  x264/$arch: 已构建"
        else
            echo "  x264/$arch: 未构建"
        fi
        if [[ -d "build/ffmpeg/$arch" ]]; then
            echo "  ffmpeg/$arch: 已构建"
        else
            echo "  ffmpeg/$arch: 未构建"
        fi
    done
else
    echo "build/ 目录不存在 - 这是首次构建"
fi

echo ""
echo "=== 测试完成 ==="
