#!/usr/bin/env bash

set -e

cd "$(dirname "$0")/.."

./cleanup.sh

# Build ffmpeg 3.4.8
./build_android.sh --ffmpeg 3.4.8 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d
# Build ffmpeg 3.4.8 + 16kb page size
./build_android.sh --ffmpeg 3.4.8 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d --16kb

git clean -ffdx build/ffmpeg

# Build ffmpeg 4.4.4
./build_android.sh --ffmpeg 4.4.4 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d
# Build ffmpeg 4.4.4 + 16kb page size
./build_android.sh --ffmpeg 4.4.4 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d --16kb

git clean -ffdx build/ffmpeg

# Build ffmpeg 5.0
./build_android.sh --ffmpeg 5.0 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d
# Build ffmpeg 5.0 + 16kb page size
./build_android.sh --ffmpeg 5.0 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d --16kb

echo "All builds completed successfully."

./utils/packages.sh
