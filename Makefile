export THEOS = /Users/huynguyen/Desktop/theos

ARCHS = arm64 arm64e

SDK_PATH = $(THEOS)/sdks/iPhoneOS16.4.sdk/
$(info ===> Setting SYSROOT to $(SDK_PATH)...)
SYSROOT = $(SDK_PATH)

# TARGET := iphone:clang:latest:16.4
INSTALL_TARGET_PROCESSES = SpringBoard

THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = mineland

$(TWEAK_NAME)_FILES = Tweak.xm
$(TWEAK_NAME)_CFLAGS = -fobjc-arc
$(TWEAK_NAME)_FRAMEWORKS = UIKit Foundation CoreGraphics
$(TWEAK_NAME)_PRIVATE_FRAMEWORKS = SpringBoard

include $(THEOS_MAKE_PATH)/tweak.mk
SUBPROJECTS += $(TWEAK_NAME)
include $(THEOS_MAKE_PATH)/aggregate.mk
