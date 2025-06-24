#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

for FFMPEG_NAME in $(echo ffmpeg-* | tr ' ' '\n'); do
    echo "### Checking $FFMPEG_NAME"
    if [[ -d "$FFMPEG_NAME" ]]; then
        if command -v 7z >/dev/null 2>&1; then
            7z a "${FFMPEG_NAME}.zip" "$FFMPEG_NAME"
            7z a "${FFMPEG_NAME}.7z" "$FFMPEG_NAME"
        fi
        tar -cJf "${FFMPEG_NAME}.tar.xz" "$FFMPEG_NAME"
    fi
done
