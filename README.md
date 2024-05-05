# FFmpeg-Android

Support building FFmpeg for Android with x264.

| FFmpeg | x264 | Android NDK | Tested |
| ------ | ---- | ----------- | ------ |
| 2.8.6 | 90a61ec76424778c050524f682a33f115024be96 | ndk20,ndk21,ndk22,ndk26 | Yes |
| 3.4.8 | 5db6aa6cab1b146e07b60cc1736a01f21da01154 | ndk20,ndk21,ndk22,ndk26 | Yes |
| 4.4.4 | 7ed753b10a61d0be95f683289dfb925b800b0676 | ndk26 | Yes |

## Build

### Prepare

- Install git
- Install Android NDK (tested with ndk20、ndk21、ndk22、ndk26), __do not use `NDK23`!__
  - Tested with `NDK26` on macOS with Apple chips
- Install yasm, nasm (via `brew install nasm yasm` or `apt install nasm yasm -y`...)

### Perform build

1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
    - Use `./build_android.sh --ffmpeg 3.4.8 --x264 5db6aa6cab1b146e07b60cc1736a01f21da01154` to build the specific version
3. `$ cd jni && $NDK/ndk-build`
4. The `libffmpeg.so` is in the folder `libs`
