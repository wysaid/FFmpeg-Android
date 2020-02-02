#!/usr/bin/env bash

THIS_DIR=$(
  cd $(dirname "$0")
  pwd
)
echo "THIS_DIR=$THIS_DIR"
cd ${THIS_DIR}

X264_DIR=$(
  cd ${THIS_DIR}/../../x264
  pwd
)

cd $X264_DIR
git clean -ffdx

# Build arm v6 v7a
bash $THIS_DIR/build_android_arm.sh

# Build arm64 v8a
bash $THIS_DIR/build_android_arm64-v8a.sh

# Build mips
# bash $THIS_DIR/build_android_mips.sh

# Build mips64
# bash $THIS_DIR/build_android_mips64.sh

# Build x86
# bash $THIS_DIR/build_android_x86.sh

# Build x86_64
# bash $THIS_DIR/build_android_x86_64.sh
