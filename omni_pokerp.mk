#
# Copyright (C) 2021 The Android Open Source Project
# Copyright (C) 2021 SebaUbuntu's TWRP device tree generator
#
# SPDX-License-Identifier: Apache-2.0
#
$(call inherit-product, build/target/product/embedded.mk)

# Inherit from our custom product configuration
$(call inherit-product, vendor/omni/config/common.mk)


# Device identifier. This must come after all inclusions
PRODUCT_DEVICE := pokerp
PRODUCT_NAME := omni_pokerp
PRODUCT_BRAND := motorola
PRODUCT_MODEL := moto e(6) plus
PRODUCT_MANUFACTURER := motorola

BUILD_FINGERPRINT := motorola/pokerp_64/pokerp:9/PTBS29.401-58-8/58-8:user/release-keys

PRODUCT_BUILD_PROP_OVERRIDES += \
    TARGET_DEVICE=pokerp \
    PRODUCT_NAME=pokerp_64 \
    PRIVATE_BUILD_DESC="full_p161bn-user 9 PTBS29.401-58-8 58-8 release-keys"

# Time Zone data for recovery
PRODUCT_COPY_FILES += \
    system/timezone/output_data/iana/tzdata:recovery/root/system/usr/share/zoneinfo/tzdata

# HACK: Set vendor patch level
PRODUCT_PROPERTY_OVERRIDES += \
    ro.vendor.build.security_patch=2099-12-31