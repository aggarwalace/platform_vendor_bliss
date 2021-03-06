#
#	Copyright (C) 2015 BlissRoms Project
# 
# 	Licensed under the Attribution-NonCommercial-ShareAlike 4.0 International 
# 	(the "License") you may not use this file except in compliance with the License.
# 	You may obtain a copy of the License at
# 
# 		http://creativecommons.org/licenses/by-nc-sa/4.0/legalcode
# 
# 	Unless required by applicable law or agreed to in writing, software
# 	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.com.google.clientidbase=android-google \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false \
    ro.opa.eligible_device=true

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1

# Thank you, please drive thru!
PRODUCT_PROPERTY_OVERRIDES += persist.sys.dun.override=0

 # Bootanimation support
ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))
# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/bliss/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef

$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

ifeq ($(TARGET_BOOTANIMATION_HALF_RES),true)
PRODUCT_BOOTANIMATION := vendor/bliss/prebuilt/common/bootanimation/halfres/$(TARGET_BOOTANIMATION_NAME).zip
else
PRODUCT_BOOTANIMATION := vendor/bliss/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip
endif

PRODUCT_COPY_FILES += \
    $(PRODUCT_BOOTANIMATION):system/media/bootanimation.zip
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/bliss/prebuilt/common/bin/sysinit:system/bin/sysinit \
    vendor/bliss/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/bliss/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# Init file
PRODUCT_COPY_FILES += \
    vendor/bliss/prebuilt/common/etc/init.bliss.rc:root/init.bliss.rc

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/bliss/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/bliss/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# World APN list
PRODUCT_COPY_FILES += \
    vendor/bliss/prebuilt/common/etc/apns-conf.xml:system/etc/apns-conf.xml

# Selective SPN list for operator number who has the problem.
PRODUCT_COPY_FILES += \
    vendor/bliss/prebuilt/common/etc/selective-spn-conf.xml:system/etc/selective-spn-conf.xml

PRODUCT_PACKAGE_OVERLAYS += \
    vendor/bliss/overlay/common

# Proprietary libs for BlissOTA and keyboard swyping
ifneq ($(filter arm64,$(TARGET_ARCH)),)
PRODUCT_COPY_FILES += \
    vendor/bliss/prebuilt/common/lib/libjni_latinime.so:system/lib/libjni_latinime.so \
    vendor/bliss/prebuilt/common/lib/libbypass.so:system/lib/libbypass.so
else
PRODUCT_COPY_FILES += \
    vendor/bliss/prebuilt/common/lib64/libjni_latinime.so:system/lib64/libjni_latinime.so \
    vendor/bliss/prebuilt/common/lib64/libbypass.so:system/lib64/libbypass.so
endif

# by default, do not update the recovery with system updates
PRODUCT_PROPERTY_OVERRIDES += persist.sys.recovery_update=false

ifneq ($(TARGET_BUILD_VARIANT),eng)
# Enable ADB authentication
ADDITIONAL_DEFAULT_PROPERTIES += ro.adb.secure=1
endif

# Squisher Location
SQUISHER_SCRIPT := vendor/bliss/tools/squisher

# Compile libhwui in performance mode
HWUI_COMPILE_FOR_PERF := true

# Bliss Packages
-include vendor/bliss/config/bliss_packages.mk

# Bliss OTA System
-include vendor/bliss/config/bliss_ota.mk

# Bliss Versioning System
-include vendor/bliss/config/versions.mk

$(call inherit-product-if-exists, vendor/bliss/prebuilt/common/app/Android.mk)
$(call inherit-product-if-exists, vendor/bliss/prebuilt/common/privapp/Android.mk)
$(call inherit-product-if-exists, vendor/extra/product.mk)
