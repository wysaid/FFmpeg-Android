#!/bin/bash

# 编译器包装器 - 过滤掉有问题的编译器标志

# 获取原始编译器路径
REAL_CC="/usr/lib/android-sdk/ndk/26.3.11579264/toolchains/llvm/prebuilt/linux-x86_64/bin/armv7a-linux-androideabi21-clang"

# 过滤掉有问题的标志
FILTERED_ARGS=()
for arg in "$@"; do
    if [[ "$arg" != "-mfp16-format=ieee" && "$arg" != "-mfpu=neon-fp16" ]]; then
        FILTERED_ARGS+=("$arg")
    fi
done

# 调用真实的编译器
exec "$REAL_CC" "${FILTERED_ARGS[@]}"
