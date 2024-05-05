# FFmpeg-Android

1. tested-version 1:
    - ffmpeg tag: n2.8.6 (af21d609a0ddeeddad4fdefecb19fd4e13744f80)
    - x264: 90a61ec76424778c050524f682a33f115024be96

2. tested-version 2 (Default):
    - ffmpeg tag: n3.4.8
    - x264: 5db6aa6cab1b146e07b60cc1736a01f21da01154

## Build

### Prepare

- Install git
- Install Android NDK (tested with ndk20、ndk21、ndk22), __do not use NDK23 by now__
- Install yasm, nasm (via `brew install nasm yasm` or `apt install nasm yasm -y`...)

### Perform build

1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
3. `$ cd jni && $NDK/ndk-build`
4. The `libffmpeg.so` is in the folder `libs`
