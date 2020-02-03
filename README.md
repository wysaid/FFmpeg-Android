# FFmpeg-Android

tested-version:
  - ffmpeg tag: n2.8.6 (af21d609a0ddeeddad4fdefecb19fd4e13744f80)
  - x264: 90a61ec76424778c050524f682a33f115024be96


# Build

0. Install git, Android ndk
1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
3. `$ cd jni && $NDK/ndk-build`
3. libffmpeg.so will be built to `libs`

