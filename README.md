The FFmpeg code used in VPlayer for Android
===========================================

1. 目前该脚本支持armv5 armv6 armv7 vfp 这些基本够用了,其它的稍后整理一下再push上来
2. ffmpeg 版本2.1.2 
3. NDK版本r14b
4. 库比较大建议download zip
5. build目录下是已经编译好的, 如果不能编译就先用着吧
6. 编译环境Mac 10.11.6

Build
-----

0. Install git, Android ndk
1. `$ export ANDROID_NDK=/path/to/your/android-ndk`
2. `$ ./FFmpeg-Android.sh`
3. libffmpeg.so will be built to `build/ffmpeg/{armv5,armv6,armv7,vfp}/`

