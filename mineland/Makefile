export THEOS = /Users/huynguyen/Desktop/theos
ARCHS = arm64 arm64e

SDK_PATH = $(THEOS)/sdks/iPhoneOS16.4.sdk/
$(info ===> Setting SYSROOT to $(SDK_PATH)...)
SYSROOT = $(SDK_PATH)

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = mineland

$(BUNDLE_NAME)_FILES = MLCRootListController.m
$(BUNDLE_NAME)_FRAMEWORKS = UIKit
$(BUNDLE_NAME)_PRIVATE_FRAMEWORKS = Preferences
$(BUNDLE_NAME)_INSTALL_PATH = /Library/PreferenceBundles
$(BUNDLE_NAME)_CFLAGS = -fobjc-arc

include $(THEOS_MAKE_PATH)/bundle.mk
