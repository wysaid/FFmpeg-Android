#!/usr/bin/env bash
set -e
set -x

cd $(dirname $0)

if [[ -f ffmpeg/libavcodec/aaccoder.c ]]; then
    # Check if `#undef B0` already exists, if so, exit directly
    if grep -q '#undef B0' ffmpeg/libavcodec/aaccoder.c; then
        echo "Already patched, skipping."
        exit 0
    fi

    cp ffmpeg/libavcodec/aaccoder.c ffmpeg/libavcodec/aaccoder.c.bak

    # Find the last `#include` statement
    last_include_line=$(grep -n '#include' ffmpeg/libavcodec/aaccoder.c | tail -n 1 | cut -d: -f1)
    # Copy the first $last_include_line lines
    head -n $last_include_line ffmpeg/libavcodec/aaccoder.c.bak >ffmpeg/libavcodec/aaccoder.c
    # Add multiple lines after the last `#include` statement

    echo "#ifdef B0" >>ffmpeg/libavcodec/aaccoder.c
    echo "#undef B0" >>ffmpeg/libavcodec/aaccoder.c
    echo "#endif" >>ffmpeg/libavcodec/aaccoder.c
    echo "#ifdef B1" >>ffmpeg/libavcodec/aaccoder.c
    echo "#undef B1" >>ffmpeg/libavcodec/aaccoder.c
    echo "#endif" >>ffmpeg/libavcodec/aaccoder.c

    # Append the rest of the backup file to the end
    tail -n +$((last_include_line + 1)) ffmpeg/libavcodec/aaccoder.c.bak >>ffmpeg/libavcodec/aaccoder.c

    cd ffmpeg/libavcodec
    export GIT_PAGER=cat
    git diff aaccoder.c
    echo "Patched ffmpeg/libavcodec/aaccoder.c successfully."
else
    echo "ffmpeg/libavcodec/aaccoder.c not found, skipping patch."
    exit 1
fi
