LOCAL_PATH := $(call my-dir)

BUILD_ROOT_DIR=$(LOCAL_PATH)/../build
FFMPEG_DIR=$(BUILD_ROOT_DIR)/ffmpeg/$(TARGET_ARCH_ABI)/lib
X264_DIR=$(BUILD_ROOT_DIR)/x264/$(TARGET_ARCH_ABI)/lib

#include $(call all-subdir-makefiles)

#static version of libavcodec
include $(CLEAR_VARS)
LOCAL_MODULE:= libavcodec_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/libavcodec.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libavformat
include $(CLEAR_VARS)
LOCAL_MODULE:= libavformat_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/libavformat.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libswscale
include $(CLEAR_VARS)
LOCAL_MODULE:= libswscale_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/libswscale.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libavutil
include $(CLEAR_VARS)
LOCAL_MODULE:= libavutil_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/libavutil.a
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
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/libswresample.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libpostproc
include $(CLEAR_VARS)
LOCAL_MODULE:= libpostproc_static
LOCAL_SRC_FILES:= $(FFMPEG_DIR)/libpostproc.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

#static version of libx264
include $(CLEAR_VARS)
LOCAL_MODULE:= libx264_static
LOCAL_SRC_FILES:= $(X264_DIR)/libx264.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)
include $(PREBUILT_STATIC_LIBRARY)

include $(CLEAR_VARS)

LOCAL_MODULE := ffmpeg

LOCAL_CFLAGS := -fPIC -O3 -DANDROID -D__ANDROID_API__=21
LOCAL_LDLIBS := -llog -lz -lm -ldl -lc

ifeq ($(TARGET_ARCH_ABI), x86_64)
LOCAL_LDLIBS := $(LOCAL_LDLIBS) -z notext
endif

ifeq ($(TARGET_ARCH_ABI), x86)
LOCAL_LDLIBS := $(LOCAL_LDLIBS) -z notext
endif

LOCAL_WHOLE_STATIC_LIBRARIES := libavformat_static \
						libavcodec_static \
						libavutil_static \
						libpostproc_static \
						libswscale_static \
						libswresample_static \
						libx264_static \
						
include $(BUILD_SHARED_LIBRARY)
