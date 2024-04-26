#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

# Inherit Android Go Makefile
$(call inherit-product, vendor/extra/config/go.mk)

# Inherit priv Makefile
$(call inherit-product-if-exists, vendor/extra/priv/product.mk)

# Audio (Debugging)
PRODUCT_PACKAGES += \
    tinymix \
    tinyplay

# Boot animation
TARGET_BOOTANIMATION_HALF_RES := true

# Overlays
PRODUCT_PACKAGES += \
    FrameworksResOverlay \
    LineageUpdaterOverlay$(PRODUCT_VERSION_MAJOR) \
    RippleSystemUIOverlay \
    SimpleDeviceConfigOverlay

# RemovePackages
PRODUCT_PACKAGES += \
    RemovePackages

# Rootdir
PRODUCT_COPY_FILES += \
    $(LOCAL_PATH)/rootdir/bin/neofetch:$(TARGET_COPY_OUT_SYSTEM)/bin/neofetch

# Soong namespaces
PRODUCT_SOONG_NAMESPACES += \
    $(LOCAL_PATH)
