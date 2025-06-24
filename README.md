# FFmpeg-Android

Support building FFmpeg for Android with x264.

| FFmpeg | x264 | Android NDK | Tested Platform |
| ------ | ---- | ----------- | ------ |
| 3.4.8 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk22,ndk25,ndk26,ndk27,ndk28 | macOS/Ubuntu |
| 4.4.4 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk22,ndk25,ndk26,ndk27,ndk28 | macOS/Ubuntu |
| 5.0 | 31e19f92f00c7003fa115047ce50978bc98c3a0d | ndk25,ndk26,ndk27,ndk28 | macOS/Ubuntu |

> For newer versions of FFmpeg, the configure script parameters have changed and require separate adaptation.

## Build

### Prepare

- Install git
- Install Android NDK (tested with ndk22, ndk25, ndk26, ndk27, ndk28), __do not use `NDK23`!__
  - Tested with all NDK versions on `macOS` and `Ubuntu 20.04+`
- Install yasm, nasm (via `brew install nasm yasm` or `apt install nasm yasm -y`...)

### Perform build

1. `$ export NDK=/path/to/your/android-ndk`
2. `$ ./build_android.sh`
    - Use `./build_android.sh --ffmpeg 4.4.4 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d` to build the specific version
3. `$ cd jni && $NDK/ndk-build`
4. The `libffmpeg.so` is in the folder `libs`

### 经过测试的编译版本

```bash
# 编译 ffmpeg 3.4.8
./build_android.sh --ffmpeg 3.4.8 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d
# 编译 ffmpeg 3.4.8 + 16kb page size
./build_android.sh --ffmpeg 3.4.8 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d --16kb
```

```bash
# 编译 ffmpeg 4.4.4
./build_android.sh --ffmpeg 4.4.4 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d
# 编译 ffmpeg 4.4.4 + 16kb page size
./build_android.sh --ffmpeg 4.4.4 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d --16kb
```

```bash
# 编译 ffmpeg 5.0
./build_android.sh --ffmpeg 5.0 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d
# 编译 ffmpeg 5.0 + 16kb page size
./build_android.sh --ffmpeg 5.0 --x264 31e19f92f00c7003fa115047ce50978bc98c3a0d --16kb
```