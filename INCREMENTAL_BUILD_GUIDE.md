# 增量构建系统使用说明

## 概述

经过重构的 FFmpeg+X264 Android 构建系统现在支持增量构建，允许从上次构建状态继续，避免不必要的重复工作。

## 主要特性

### 1. 增量构建支持
- **默认行为**: 重复执行 `build_android.sh` 会检查已存在的配置和构建状态
- **跳过重复工作**: 如果 `configure` 已经完成，直接执行 `make` 和 `make install`
- **继续中断构建**: 如果构建被中断，下次执行会从中断点继续

### 2. 清理构建选项
- **--clear 标志**: 只有明确传入 `--clear` 时才会清理构建目录
- **选择性清理**: 只清理必要的临时文件，保留可重用的配置

## 使用方法

### 正常增量构建
```bash
# 首次构建或继续上次构建
./build_android.sh

# 指定版本的增量构建
./build_android.sh -f 6.1.1 -x 31e19f92f00c7003fa115047ce50978bc98c3a0d
```

### 清理重新构建
```bash
# 清理所有构建缓存后重新构建
./build_android.sh --clear

# 清理构建并指定版本
./build_android.sh --clear -f 6.1.1 -x 31e19f92f00c7003fa115047ce50978bc98c3a0d
```

### 查看帮助
```bash
./build_android.sh --help
# 或传入无效参数查看用法
./build_android.sh --invalid
```

## 构建状态检测

### X264 构建状态
系统检查以下文件来确定 X264 是否已构建：
- `build/x264/{arch}/lib/libx264.a`
- `build/x264/{arch}/include/x264.h`

### FFmpeg 构建状态
系统检查以下文件来确定 FFmpeg 是否已构建：
- `build/ffmpeg/{arch}/lib/libavcodec.a`
- `build/ffmpeg/{arch}/include/libavcodec/avcodec.h`

### 配置状态
系统检查以下文件来确定是否已配置：
- `build/{x264|ffmpeg}-build/{arch}/config.mak`
- `build/{x264|ffmpeg}-build/{arch}/Makefile`

## 构建流程

### 首次构建
1. 克隆 x264 和 ffmpeg 源码（如果不存在）
2. 检出指定版本
3. 为每个架构创建独立的构建目录
4. 复制源码到构建目录
5. 运行 configure
6. 执行 make 和 make install

### 增量构建
1. 检查源码版本（如有变化则更新）
2. 检查已存在的构建状态
3. 跳过已完成的架构构建
4. 对于部分完成的构建：
   - 如果已配置，直接执行 make
   - 如果未配置，执行完整配置流程
5. 执行 make 和 make install

### 清理构建
1. 删除整个 `build/` 目录（主脚本级别）
2. 或删除特定架构的构建目录（子脚本级别）
3. 重新执行完整构建流程

## 目录结构

```
build/
├── x264/
│   ├── armeabi-v7a/          # x264 安装目录
│   ├── arm64-v8a/
│   └── x86_64/
├── x264-build/
│   ├── armeabi-v7a/          # x264 构建目录
│   ├── arm64-v8a/
│   └── x86_64/
├── ffmpeg/
│   ├── armeabi-v7a/          # ffmpeg 安装目录
│   ├── arm64-v8a/
│   └── x86_64/
└── ffmpeg-build/
    ├── armeabi-v7a/          # ffmpeg 构建目录
    ├── arm64-v8a/
    └── x86_64/
```

## 优势

### 开发效率
- **节省时间**: 避免重复的 configure 和已完成的编译
- **快速迭代**: 修改后快速重新构建
- **中断恢复**: 构建中断后可以继续，不需要从头开始

### 资源节约
- **磁盘空间**: 不重复复制和构建已完成的部分
- **CPU 使用**: 只编译需要更新的文件
- **网络带宽**: 不重复下载和克隆

### 错误隔离
- **架构独立**: 一个架构的构建失败不影响其他架构
- **组件独立**: x264 和 ffmpeg 的构建相互独立
- **状态保持**: 构建状态持久化，便于问题诊断

## 注意事项

### 何时使用 --clear
- 构建环境发生变化（NDK 版本、工具链等）
- 源码版本发生重大变化
- 遇到奇怪的构建错误
- 需要完全干净的构建环境

### 潜在问题
- **依赖变化**: 如果依赖库版本变化，可能需要清理构建
- **配置选项**: 如果需要修改 configure 选项，需要清理对应组件
- **工具链更新**: NDK 或工具链更新后建议清理构建

## 故障排除

### 构建失败但状态检测显示已完成
```bash
# 清理重新构建
./build_android.sh --clear
```

### 部分架构构建失败
```bash
# 删除对应架构的构建目录
rm -rf build/x264-build/arm64-v8a build/x264/arm64-v8a
rm -rf build/ffmpeg-build/arm64-v8a build/ffmpeg/arm64-v8a

# 重新构建
./build_android.sh
```

### configure 选项需要修改
```bash
# 删除对应的构建目录以强制重新配置
rm -rf build/ffmpeg-build/

# 重新构建（会重新配置但保留 x264）
./build_android.sh
```
