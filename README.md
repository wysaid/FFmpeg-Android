# FFmpeg-Android

Support building FFmpeg for Android with x264. Updated for modern NDK versions.

| FFmpeg | x264 | Android NDK | Tested |
| ------ | ---- | ----------- | ------ |
| 6.1.1 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | NDK26+ | Yes |

## Build

### Prepare

- Install git  
- Install Android NDK (tested with NDK26+)
  - Tested on `Ubuntu 20.04+` and `Ubuntu 24.04`
- Install nasm, yasm (via `apt install nasm yasm -y`)

### Features

- **Optimized for modern NDK**: Uses the unified headers and clang toolchain
- **NEON acceleration**: Enabled for ARM architectures
- **Assembly optimization**: Enabled for all supported architectures  
- **x264 encoding**: Integrated x264 for H.264 video encoding
- **Minimal size**: Optimized build configuration for smaller binary size

### Supported Architectures

- `armeabi-v7a` (with NEON optimization)
- `arm64-v8a` (with NEON optimization)  
- `x86_64` (with ASM optimization)

### Perform build

1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
    - Use `./build_android.sh --ffmpeg 6.1.1 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d` to build specific versions
3. `$ cd jni && $NDK/ndk-build`
4. The `libffmpeg.so` is in the folder `libs`

### Build Output

The build will produce:
- Static libraries in `build/x264/<arch>/` and `build/ffmpeg/<arch>/`
- Final shared library `libffmpeg.so` in `libs/<arch>/`
