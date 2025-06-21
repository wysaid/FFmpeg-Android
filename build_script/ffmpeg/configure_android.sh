#!/bin/bash

# Android specific configure wrapper for FFmpeg
# 用于避免configure脚本自动检测有问题的特性

echo "Configuring FFmpeg with Android-specific settings..."

# 添加环境变量来阻止problematic检测
export ac_cv_func_pthread_atfork=no
export ac_cv_func_pthread_cancel=no
export LDFLAGS="$LDFLAGS -Wl,--allow-multiple-definition"

# 运行原始的configure脚本
exec "$@"
