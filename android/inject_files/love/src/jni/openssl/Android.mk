LOCAL_PATH:= $(call my-dir)

#libcrypto
include $(CLEAR_VARS)

LOCAL_MODULE := libcrypto
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libcrypto.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include

include $(PREBUILT_STATIC_LIBRARY)

#libssl
include $(CLEAR_VARS)

LOCAL_MODULE := libssl
LOCAL_SRC_FILES := $(TARGET_ARCH_ABI)/libssl.a
LOCAL_EXPORT_C_INCLUDES := $(LOCAL_PATH)/include

include $(PREBUILT_STATIC_LIBRARY)