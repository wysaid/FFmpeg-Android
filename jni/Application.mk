# APP_ABI := all
# APP_ABI := x86
APP_ABI := armeabi-v7a arm64-v8a x86_64 x86

APP_PLATFORM := android-22

APP_OPTIM := release

ifeq ($(ENABLE_16KB_PAGE_SIZE),true)
APP_SUPPORT_FLEXIBLE_PAGE_SIZES := true
endif

