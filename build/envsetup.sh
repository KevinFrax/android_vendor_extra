#!/bin/bash
#
# Copyright (C) 2022 Giovanni Ricca
#
# SPDX-License-Identifier: Apache-2.0
#

if [[ "$1" = "-h" || "$1" = "--help" ]]; then
    cat <<'END'
Usage:
 . vendor/extra/build/envsetup.sh [ARG]
     -h/--help: Shows this screen
     -p/--apply-patches: Apply the patches inside vendor/extra/build/patches folder
END
    return 0
fi

# Setup android env
. build/envsetup.sh

# Defs
export VENDOR_EXTRA_PATH=$(gettop)/vendor/extra/
export VENDOR_PATCHES_PATH="$VENDOR_EXTRA_PATH"/build/patches

# Apply patches
if [[ "$1" = "-p" || "$1" = "--apply-patches" ]]; then
    . "$VENDOR_PATCHES_PATH"/apply-patches.sh
fi

# functions
los_ota_json() {
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        cat <<'END'
Usage:
 los_ota_json [DEVICE CODENAME]
END
        return 0
    fi

    # Check is $1 is empty
    if [ -z "$1" ]; then
        echo -e "\nPlease mention the device codename first"
        return 0
    fi

    # Defs
    DEVICE="$1"

    # Generate the OTA Json
    croot
    cd out/target/product/"$DEVICE"/ &> /dev/null
    "$VENDOR_EXTRA_PATH"/tools/los_ota_json.py
}

mka_build() {
    # Call for help
    if [[ "$1" = "-h" || "$1" = "--help" ]]; then
        cat <<'END'
Usage:
 mka_build [DEVICE CODENAME] [ARG]
     -d/--dirty: Avoids running 'mka installclean' before building
END
        return 0
    fi

    # Goofy ahh build env
    unset JAVAC

    # Check is $1 is empty
    if [[ -z "$1" || "$1" = "-d" || "$1" = "--dirty" ]]; then
        echo -e "\nPlease mention the device to build first"
        return 0
    fi

    # Defs
    DEVICE="$1"
    BUILD_TYPE="userdebug" # ToDo: Don't hardcode it
    if [[ "$2" = "-d" || "$2" = "--dirty" ]]; then
        echo -e "\nWarning: Building without cleaning up $DEVICE out dir\n"
        DIRTY_BUILD="no"
    else
        echo -e "\nWarning: Building with cleaned up $DEVICE out dir\n"
        DIRTY_BUILD="yes"
    fi

    sleep 3

    # Build
    croot # Make sure we are inside the source root dir
    lunch lineage_"$DEVICE"-"$BUILD_TYPE"
    if [ "$DIRTY_BUILD" = "yes" ]; then
        mka installclean
    fi
    mka bacon -j4

    # Upload build + extras
    cd out/target/product/"$DEVICE"/ &> /dev/null
    cp lineage-19*.zip ~/public_html/giovanni/"$DEVICE"/ &> /dev/null
    cp recovery.img ~/public_html/giovanni/"$DEVICE"/ &> /dev/null
    cp boot.img ~/public_html/giovanni/"$DEVICE"/ &> /dev/null
    cp obj/PACKAGING/target_files_intermediates/*/IMAGES/vendor_*.img ~/public_html/giovanni/"$DEVICE"/ &> /dev/null
    cp dtbo.img ~/public_html/giovanni/"$DEVICE"/ &> /dev/null

    # Output OTA JSON
    los_ota_json "$DEVICE"

    echo -e "\n\nDone!"
}
