ARCHS = armv7 armv7s arm64
TARGET = iphone:clang:latest:7.0

THEOS_BUILD_DIR = Packages

TWEAK_NAME = DoubleTouchHome
DoubleTouchHome_FILES = Event.xm
DoubleTouchHome_LIBRARIES = activator
DoubleTouchHome_FRAMEWORKS = QuartzCore
DoubleTouchHome_PRIVATE_FRAMEWORKS = SpringBoardUIServices

include theos/makefiles/common.mk
include $(THEOS_MAKE_PATH)/tweak.mk

internal-stage::
	#PreferenceLoader plist
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp Preferences.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/DoubleTouchHome.plist$(ECHO_END)

after-install::
	install.exec "killall -HUP SpringBoard"
