The FFmpeg code used in VPlayer for Android
===========================================

1. 目前该脚本支持armv5 armv6 armv7 vfp 这些基本够用了,其它的稍后整理一下再push上来
2. ffmpeg 版本2.1.2 
3. NDK版本r14b
4. 库比较大建议download zip

Build
-----

0. Install git, Android ndk
1. `$ export ANDROID_NDK=/path/to/your/android-ndk`
2. `$ ./FFmpeg-Android.sh`
3. libffmpeg.so will be built to `build/ffmpeg/{neon,armv7,vfp,armv6}/`

