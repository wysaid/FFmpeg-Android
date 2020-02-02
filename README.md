# FFmpeg-Android

tested-version:
	- ffmpeg tag: n3.0.7 (c63e58756699d07b5bc69799db388600d3e634bf)
	- x264: 90a61ec76424778c050524f682a33f115024be96


# Build

0. Install git, Android ndk
1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
3. `$ cd jni && $NDK/ndk-build`
3. libffmpeg.so will be built to `libs`

