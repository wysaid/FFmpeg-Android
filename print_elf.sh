#!/usr/bin/env bash

if [[ ! -d "$NDK" ]]; then
    echo "NDK directory not found: $NDK"
    exit 1
fi

READ_ELF=$(find "$NDK" -iname "*readelf*" | head -n 1)

if [[ ! -f "${READ_ELF}" ]]; then
    echo "readelf not found in NDK toolchain"
    exit 1
fi

cd $(dirname "$0")

find libs -type f -name "*.so" | while read -r file; do
    if [[ -f "$file" ]]; then
        echo "Processing $file"
        "${READ_ELF}" -l "$file" | grep "LOAD"
    else
        echo "File not found: $file"
    fi
done
