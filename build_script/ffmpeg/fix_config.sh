#!/bin/bash

# 修复FFmpeg configure后生成的config文件，移除problematic选项

echo "Fixing FFmpeg configuration files for Android..."

if [ -f ffbuild/config.mak ]; then
    echo "Fixing ffbuild/config.mak..."
    # 移除-mfp16-format=ieee参数（仅GCC支持，Clang不支持）
    sed -i 's/-mfp16-format=ieee//g' ffbuild/config.mak
    # 移除其他可能有问题的参数
    sed -i 's/-mfpu=neon-fp16//g' ffbuild/config.mak
    sed -i 's/-mcpu=cortex-a8//g' ffbuild/config.mak
    # 移除可能导致链接问题的选项
    sed -i 's/HAVE_PTHREAD_ATFORK=yes/HAVE_PTHREAD_ATFORK=no/g' ffbuild/config.mak
    sed -i 's/HAVE_ATOMICS=yes/HAVE_ATOMICS=no/g' ffbuild/config.mak
    echo "config.mak fixed"
fi

if [ -f config.h ]; then
    echo "Fixing config.h..."
    # 确保pthread_atfork被禁用（Android不支持）
    sed -i 's/#define HAVE_PTHREAD_ATFORK 1/#define HAVE_PTHREAD_ATFORK 0/g' config.h
    # 禁用一些可能有问题的pthread功能
    sed -i 's/#define HAVE_PTHREAD_CANCEL 1/#define HAVE_PTHREAD_CANCEL 0/g' config.h
    # 确保使用正确的线程模型
    sed -i 's/#define HAVE_PTHREADS 1/#define HAVE_PTHREADS 0/g' config.h
    sed -i 's/#define HAVE_W32THREADS 0/#define HAVE_W32THREADS 0/g' config.h
    sed -i 's/#define HAVE_OS2THREADS 0/#define HAVE_OS2THREADS 0/g' config.h
    # 禁用原子操作可能引起的问题
    sed -i 's/#define HAVE_ATOMICS 1/#define HAVE_ATOMICS 0/g' config.h
    sed -i 's/#define HAVE_ATOMIC_CAS_PTR 1/#define HAVE_ATOMIC_CAS_PTR 0/g' config.h
    echo "config.h fixed"
fi

echo "Configuration files have been fixed for Android compatibility"
