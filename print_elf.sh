#!/usr/bin/env bash

if [[ ! -d "$NDK" ]]; then
    echo "NDK directory not found: $NDK"
    exit 1
fi

if [[ ! -f "$NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readelf" ]]; then
    echo "llvm-readelf not found in NDK toolchain"
    exit 1
fi

cd $(dirname "$0")

find libs -type f -name "*.so" | while read -r file; do
    if [[ -f "$file" ]]; then
        echo "Processing $file"
        $NDK/toolchains/llvm/prebuilt/darwin-x86_64/bin/llvm-readelf -l "$file" | grep "LOAD"
    else
        echo "File not found: $file"
    fi
done
