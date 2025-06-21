# FFmpeg Android 构建系统重构

## 改进内容

### 🎯 主要问题解决
1. **源码目录污染问题** - 不再在源码目录中生成临时文件
2. **增量编译支持** - 支持单独重新编译失败的架构，避免重复编译
3. **构建目录规范化** - 所有构建产物统一放在 `build/` 目录下
4. **错误隔离** - 一个架构构建失败不影响其他架构

### 📁 新的目录结构
```
build/
├── x264-build/          # x264 临时构建目录
│   ├── armeabi-v7a/     # ARM 32位构建目录
│   ├── arm64-v8a/       # ARM 64位构建目录
│   └── x86_64/          # x86_64构建目录
├── x264/                # x264 最终安装目录
│   ├── armeabi-v7a/
│   ├── arm64-v8a/
│   └── x86_64/
├── ffmpeg-build/        # FFmpeg 临时构建目录
│   ├── armeabi-v7a/
│   ├── arm64-v8a/
│   └── x86_64/
└── ffmpeg/              # FFmpeg 最终安装目录
    ├── armeabi-v7a/
    ├── arm64-v8a/
    └── x86_64/
```

### 🔧 脚本改进
1. **构建脚本重构**
   - `build_script/x264/build_android_all_new.sh` - 支持增量构建检测
   - `build_script/ffmpeg/build_android_all_new.sh` - 支持增量构建检测
   - 单架构脚本使用独立构建目录

2. **环境隔离**
   - 每个架构使用独立的源码副本
   - 编译器包装脚本和stub库在构建目录中动态生成
   - 避免不同架构间的交叉污染

3. **错误处理优化**
   - 解决了llvm-strip符号剥离问题（使用`STRIP=true`替代）
   - 保留了编译器包装脚本过滤有问题的编译标志
   - 保留了pthread_atfork stub实现

### ✅ 使用方法

#### 构建所有架构
```bash
export NDK=$ANDROID_NDK_ROOT
./build_android.sh
```

#### 构建单个架构（用于调试或增量构建）
```bash
# 只构建 x264 的某个架构
export NDK=$ANDROID_NDK_ROOT
export ANDROID_NDK=$NDK
bash build_script/x264/build_android_armeabi-v7a_new.sh ./x264 ./build

# 只构建 FFmpeg 的某个架构
bash build_script/ffmpeg/build_android_armeabi_v7a_new.sh ./ffmpeg ./build
```

### 🚀 优势
1. **增量构建** - 已构建的架构会被跳过，节省时间
2. **清洁环境** - 源码目录保持干净，便于版本控制
3. **并行构建** - 可以并行构建不同的架构
4. **错误隔离** - 单个架构失败不影响其他架构
5. **可重现构建** - 每次构建使用全新的环境

### 🔍 验证
x264 armeabi-v7a 架构已成功构建：
- 库文件：`build/x264/armeabi-v7a/lib/libx264.a` (2.1MB)
- 头文件：`build/x264/armeabi-v7a/include/`
- 配置文件：`build/x264/armeabi-v7a/lib/pkgconfig/`

### 📝 注意事项
1. 编译过程中的 `__ANDROID_API__` 宏重定义警告是无害的
2. 构建过程会自动检测已构建的架构并跳过
3. 如需强制重新构建，删除对应的 `build/*/架构名` 目录即可
