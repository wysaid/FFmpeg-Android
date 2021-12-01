#!/usr/bin/env bash

THIS_DIR=$(
    cd $(dirname "$0")
    pwd
)

bash $THIS_DIR/build_android.sh --enable-gitee
