# FFmpeg-Android

Support building FFmpeg for Android with x264.

| FFmpeg | x264 | Android NDK | Tested Platform |
| ------ | ---- | ----------- | ------ |
| 4.4.4 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk22,ndk25,ndk26,ndk27,ndk28 | macOS/Ubuntu |
| 5.0 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk22,ndk26 | MacOS |
| 5.1 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk22,ndk26 | MacOS |
| 6.1.1 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk22,ndk26 | MacOS |

## Build

### Prepare

- Install git
- Install Android NDK (tested with ndk20、ndk21、ndk22、ndk26), __do not use `NDK23`!__
  - Tested with all NDK versions on `macOS with Intel chips` and `Ubuntu 20.04+`
  - Tested with `NDK26` on macOS with Apple chips
- Install yasm, nasm (via `brew install nasm yasm` or `apt install nasm yasm -y`...)

### Perform build

1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
    - Use `./build_android.sh --ffmpeg 3.4.8 --x264 5db6aa6cab1b146e07b60cc1736a01f21da01154` to build the specific version
3. `$ cd jni && $NDK/ndk-build`
4. The `libffmpeg.so` is in the folder `libs`
