# Copyright (C) 2013 The CyanogenMod Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#
# This file sets variables that control the way modules are built
# thorughout the system. It should not be used to conditionally
# disable makefiles (the proper mechanism to control what gets
# included in a build is to use PRODUCT_PACKAGES in a product
# definition file).
#

# set to allow building from common
BOARD_VENDOR := motorola-omap4

COMMON_FOLDER := device/motorola/omap4-common

TARGET_BOARD_OMAP_CPU := 4430
# inherit from omap4
-include hardware/ti/omap4/BoardConfigCommon.mk

# Camera
USE_CAMERA_STUB := false
TI_CAMERAHAL_USES_LEGACY_DOMX_DCC := true
#TI_CAMERAHAL_DEBUG_ENABLED := true
#TI_CAMERAHAL_VERBOSE_DEBUG_ENABLED := true

# Custom includes for kernel and frameworks
PRODUCT_VENDOR_KERNEL_HEADERS := $(COMMON_FOLDER)/kernel-headers
TARGET_SPECIFIC_HEADER_PATH += $(COMMON_FOLDER)/include

# QCOM SELinux policy
include device/qcom/sepolicy/sepolicy.mk

# inherit from the proprietary version
-include vendor/motorola/omap4-common/BoardConfigVendor.mk

# Kernel/Module Build
TARGET_KERNEL_SOURCE := kernel/motorola/omap4-common
TARGET_KERNEL_CONFIG := mapphone_mmi_defconfig
COMMON_KERNEL_CMDLINE := androidboot.hardware=mapphone_cdma androidboot.selinux=enforcing
TARGET_KERNEL_CROSS_COMPILE_PREFIX := arm-linux-androideabi-
TARGET_NEEDS_PLATFORM_TEXT_RELOCATIONS := true

WLAN_MODULES:
	make clean -C hardware/ti/wlan/mac80211/compat_wl12xx
	make -j8 -C hardware/ti/wlan/mac80211/compat_wl12xx KERNEL_DIR=$(KERNEL_OUT) KLIB=$(KERNEL_OUT) KLIB_BUILD=$(KERNEL_OUT) ARCH=arm CROSS_COMPILE="arm-linux-androideabi-"
	mv hardware/ti/wlan/mac80211/compat_wl12xx/compat/compat.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/net/mac80211/mac80211.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/net/wireless/cfg80211.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx_spi.ko $(KERNEL_MODULES_OUT)
	mv hardware/ti/wlan/mac80211/compat_wl12xx/drivers/net/wireless/wl12xx/wl12xx_sdio.ko $(KERNEL_MODULES_OUT)
	$(ANDROID_TOOLCHAIN)/arm-linux-androideabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/compat.ko
	$(ANDROID_TOOLCHAIN)/arm-linux-androideabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/mac80211.ko
	$(ANDROID_TOOLCHAIN)/arm-linux-androideabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/cfg80211.ko
	$(ANDROID_TOOLCHAIN)/arm-linux-androideabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/wl12xx.ko
	$(ANDROID_TOOLCHAIN)/arm-linux-androideabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/wl12xx_spi.ko
	$(ANDROID_TOOLCHAIN)/arm-linux-androideabi-strip --strip-unneeded $(KERNEL_MODULES_OUT)/wl12xx_sdio.ko

TARGET_KERNEL_MODULES += WLAN_MODULES

# External SGX Module
-include hardware/ti/omap4/pvr-km.mk

# Storage / Sharing
BOARD_VOLD_MAX_PARTITIONS := 32
BOARD_VOLD_EMMC_SHARES_DEV_MAJOR := true
TARGET_USE_CUSTOM_LUN_FILE_PATH := "/sys/devices/virtual/android_usb/android0/f_mass_storage/lun%d/file"
BOARD_MTP_DEVICE := "/dev/mtp"
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 734003200

# Connectivity - Wi-Fi
USES_TI_MAC80211 := true
ifdef USES_TI_MAC80211
WPA_SUPPLICANT_VERSION           := VER_0_8_X
BOARD_WPA_SUPPLICANT_DRIVER      := NL80211
BOARD_WPA_SUPPLICANT_PRIVATE_LIB := lib_driver_cmd_wl12xx
BOARD_HOSTAPD_DRIVER             := NL80211
BOARD_HOSTAPD_PRIVATE_LIB        := lib_driver_cmd_wl12xx
PRODUCT_WIRELESS_TOOLS           := true
BOARD_WLAN_DEVICE                := wl12xx_mac80211
BOARD_SOFTAP_DEVICE              := wl12xx_mac80211
WIFI_DRIVER_MODULE_PATH          := "/system/lib/modules/wl12xx_sdio.ko"
WIFI_DRIVER_MODULE_NAME          := "wl12xx_sdio"
WIFI_FIRMWARE_LOADER             := ""
BOARD_WIFI_SKIP_CAPABILITIES     := true
BOARD_GLOBAL_CFLAGS += -DUSES_TI_MAC80211
endif

# Audio
BOARD_USES_GENERIC_AUDIO := false
BOARD_USES_ALSA_AUDIO := true
BUILD_WITH_ALSA_UTILS := true
TARGET_PROVIDES_LIBAUDIO := true
BOARD_USE_MOTO_DOCK_HACK := true
BOARD_HAVE_PRE_KITKAT_AUDIO_BLOB := true
AUDIO_FEATURE_DEEP_BUFFER_RINGTONE := true

# Bluetooth
BOARD_HAVE_BLUETOOTH := true
BOARD_HAVE_BLUETOOTH_TI := true

# gps
BOARD_VENDOR_TI_GPS_HARDWARE := omap4
BOARD_GPS_LIBRARIES := libgps

# adb runs as user
ADDITIONAL_DEFAULT_PROPERTIES += ro.secure=1
ADDITIONAL_DEFAULT_PROPERTIES += ro.allow.mock.location=1

# Recovery
BOARD_CANT_BUILD_RECOVERY_FROM_BOOT_PATCH := true
TARGET_RECOVERY_FSTAB = $(COMMON_FOLDER)/root/recovery.fstab
RECOVERY_FSTAB_VERSION = 2
BOARD_HAS_LOCKED_BOOTLOADER := true
TARGET_NO_BOOTLOADER := true
TARGET_PREBUILT_RECOVERY_KERNEL := device/motorola/omap4-common/recovery-kernel
BOARD_HAS_NO_SELECT_BUTTON := true
BOARD_UMS_LUNFILE := "/sys/devices/virtual/android_usb/android0/f_mass_storage/lun%d/file"
BOARD_ALWAYS_INSECURE := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_SDCARD_INTERNAL := true
#BOARD_HAS_SDEXT := false
TARGET_RECOVERY_PRE_COMMAND := "echo 1 > /data/.recovery_mode; sync; \#"
TARGET_RECOVERY_PRE_COMMAND_CLEAR_REASON := true
TARGET_RECOVERY_PIXEL_FORMAT := "BGRA_8888"
DEVICE_RESOLUTION := 540x960
TW_MAX_BRIGHTNESS := 254
TARGET_USERIMAGES_USE_EXT4 := true

# Graphics
BOARD_EGL_CFG := device/motorola/omap4-common/prebuilt/etc/egl.cfg
TARGET_RUNNING_WITHOUT_SYNC_FRAMEWORK := true
TARGET_USES_OPENGLES_FOR_SCREEN_CAPTURE := true
BOARD_USE_TI_LIBION := true

# Number of supplementary service groups allowed by init
TARGET_NR_SVC_SUPP_GIDS := 28

# MOTOROLA
BOARD_USE_MOTOROLA_DEV_ALIAS := true
ifdef BOARD_USE_MOTOROLA_DEV_ALIAS
BOARD_GLOBAL_CFLAGS += -DBOARD_USE_MOTOROLA_DEV_ALIAS
endif

# Media / Radio
BOARD_GLOBAL_CFLAGS += -DQCOM_LEGACY_UIDS
BOARD_USE_TI_DOMX_LOW_SECURE_HEAP := true
BOARD_GLOBAL_CFLAGS += -DBOARD_USE_MOTOROLA_DOMX_ENHANCEMENTS
# Off currently

# OTA Packaging
TARGET_RELEASETOOLS_EXTENSIONS := device/motorola/omap4-common/releasetools

# Misc.
BOARD_USE_BATTERY_CHARGE_COUNTER := true
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_NEEDS_CUTILS_LOG := true
BOARD_HAS_MAPPHONE_SWITCH := true
USE_IPV6_ROUTE := true
BOARD_RIL_NO_CELLINFOLIST := true
BOARD_RIL_CLASS := ../../../device/motorola/omap4-common/ril
TARGET_IGNORE_RO_BOOT_SERIALNO := true

BOARD_HARDWARE_CLASS := $(OMAP4_NEXT_FOLDER)/cmhw/

# Override healthd HAL to use charge_counter for 1%
BOARD_HAL_STATIC_LIBRARIES := libhealthd.omap4
WITH_CM_CHARGER := false

BOARD_SEPOLICY_DIRS += \
    device/motorola/omap4-common/sepolicy
