# APP_ABI := all
# APP_ABI := x86
APP_ABI := armeabi-v7a arm64-v8a x86_64 x86
APP_PLATFORM := android-22
# system - 使用默认最小的C++运行库，这样生成的应用体积小，内存占用小，但部分功能将无法支持
# stlport_static - 使用STLport作为静态库，这项是Android开发网极力推荐的
# stlport_shared - STLport 作为动态库，这个可能产生兼容性和部分低版本的Android固件，目前不推荐使用。
# gnustl_static - 使用 GNU libstdc++ 作为静态库
# 使用STLport作为静态库，这项是Android开发网极力推荐的
#APP_STL := stlport_static
# APP_STL := c++_static
# APP_CPPFLAGS := -frtti -std=c++11
APP_OPTIM := release


