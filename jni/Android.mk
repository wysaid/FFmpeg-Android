LOCAL_PATH := $(call my-dir)

BUILD_ROOT_DIR=$(LOCAL_PATH)/../build
FFMPEG_DIR=$(BUILD_ROOT_DIR)/ffmpeg
X264_DIR=$(BUILD_ROOT_DIR)/x264

#include $(call all-subdir-makefiles)

#static version of libavcodec
include $(CLEAR_VARS)
LOCAL_MODULE:= libavcodec_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/$(TARGET_ARCH_ABI)/lib/libavcodec.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libavformat
include $(CLEAR_VARS)
LOCAL_MODULE:= libavformat_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/$(TARGET_ARCH_ABI)/lib/libavformat.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libswscale
include $(CLEAR_VARS)
LOCAL_MODULE:= libswscale_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/$(TARGET_ARCH_ABI)/lib/libswscale.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libavutil
include $(CLEAR_VARS)
LOCAL_MODULE:= libavutil_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/$(TARGET_ARCH_ABI)/lib/libavutil.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libavdevice
#include $(CLEAR_VARS)
#LOCAL_MODULE:= libavdevice_static
#LOCAL_SRC_FILES:= lib/libavdevice.a
#LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
#include $(PREBUILT_STATIC_LIBRARY)

#static version of libavfilter
#include $(CLEAR_VARS)
#LOCAL_MODULE:= libavfilter_static
#LOCAL_SRC_FILES:= lib/libavfilter.a
#LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
#include $(PREBUILT_STATIC_LIBRARY)

#static version of libswresample
include $(CLEAR_VARS)
LOCAL_MODULE:= libswresample_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/$(TARGET_ARCH_ABI)/lib/libswresample.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libpostproc
include $(CLEAR_VARS)
LOCAL_MODULE:= libpostproc_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/$(TARGET_ARCH_ABI)/lib/libpostproc.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libx264
include $(CLEAR_VARS)
LOCAL_MODULE:= libx264_static
LOCAL_SRC_FILES:= $(X264_DIR)/$(TARGET_ARCH_ABI)/lib/libx264.a
# LOCAL_CFLAGS := -march=armv7-a -mfloat-abi=softfp -mfpu=neon -O3 -ffast-math -funroll-loops
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := ffmpeg
LOCAL_SRC_FILES := decoder.c encoder.c
LOCAL_LDLIBS := -llog -lz -fPIC -fPIE -Wl,--no-warn-shared-textrel -Wl,-Bsymbolic
LOCAL_CFLAGS := -fPIC -mfloat-abi=softfp -mfpu=neon -O3 -ffast-math -funroll-loops
LOCAL_WHOLE_STATIC_LIBRARIES := libavformat_static \
						libavcodec_static \
						libavutil_static \
						libpostproc_static \
						libswscale_static \
						libswresample_static \
						libx264_static \
						
include $(BUILD_SHARED_LIBRARY)
