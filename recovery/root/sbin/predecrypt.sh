#!/sbin/sh

relink()
{
	fname=$(basename "$1")
	target="/sbin/$fname"
	sed 's|/system/bin/linker64|///////sbin/linker64|' "$1" > "$target"
	chmod 755 $target
}

finish()
{
	umount /v
	umount /s
	rmdir /v
	rmdir /s
	setprop crypto.ready 1
	exit 0
}

suffix=$(getprop ro.boot.slot_suffix)
if [ -z "$suffix" ]; then
	suf=$(getprop ro.boot.slot)
	suffix="_$suf"
fi
venpath="/dev/block/bootdevice/by-name/vendor$suffix"
mkdir /v
mount -t ext4 -o ro "$venpath" /v
syspath="/dev/block/bootdevice/by-name/system$suffix"
mkdir /s
mount -t ext4 -o ro "$syspath" /s

is_fastboot_twrp=$(getprop ro.boot.fastboot)
if [ ! -z "$is_fastboot_twrp" ]; then
    osver=$(getprop ro.build.version.release_orig)
    patchlevel=$(getprop ro.build.version.security_patch_orig)
    setprop ro.build.version.release "$osver"
    setprop ro.build.version.security_patch "$patchlevel"
    setprop ro.vendor.build.security_patch "2019-10-01"
    finish
fi

build_prop_path="/s/build.prop"
if [ -f /s/system/build.prop ]; then
	build_prop_path="/s/system/build.prop"
fi

vendor_prop_path="/v/build.prop"
if [ -f "$build_prop_path" ]; then
	# TODO: It may be better to try to read these from the boot image than from /system
	osver=$(grep -i 'ro.build.version.release' "$build_prop_path"  | cut -f2 -d'=')
	patchlevel=$(grep -i 'ro.build.version.security_patch' "$build_prop_path"  | cut -f2 -d'=')
	vendorlevel=$(grep -i 'ro.vendor.build.security_patch' "$vendor_prop_path"  | cut -f2 -d'=')
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	setprop ro.vendor.build.security_patch "$vendorlevel"
else
	# Be sure to increase the PLATFORM_VERSION in build/core/version_defaults.mk to override Google's anti-rollback features to something rather insane
	osver=$(getprop ro.build.version.release_orig)
	patchlevel=$(getprop ro.build.version.security_patch_orig)
	setprop ro.build.version.release "$osver"
	setprop ro.build.version.security_patch "$patchlevel"
	setprop ro.vendor.build.security_patch "2021-08-01"
fi
finish

mkdir -p /vendor/lib64/hw/

cp /s/system/lib64/android.hidl.base@1.0.so /sbin/
cp /s/system/lib64/libion.so /sbin/
cp /s/system/lib64/libicuuc.so /sbin/
cp /s/system/lib64/libxml2.so /sbin/

relink /v/bin/teei_daemon

cp /v/lib64/libimsg_log.so /vendor/lib64/
cp /v/lib64/libkeymaster3device.so /vendor/lib64/
cp /v/lib64/libmtee.so /vendor/lib64/
cp /v/lib64/libtee_interface.so /vendor/lib64/
cp /v/lib64/libTeeCA.so /vendor/lib64/
cp /v/lib64/libthha.so /vendor/lib64/
cp /v/lib64/vendor.microtrust.hardware.capi@2.0.so /vendor/lib64/
cp /v/lib64/vendor.mediatek.hardware.keymaster_attestation@1.0.so /vendor/lib64/
cp /v/lib64/vendor.mediatek.hardware.keymaster_attestation@1.1.so /vendor/lib64/
#cp /v/lib64/libkeymasterdeviceutils.so /vendor/lib64/
#cp /v/lib64/libkeymasterprovision.so /vendor/lib64/
#cp /v/lib64/libkeymasterutils.so /vendor/lib64/
#cp /v/lib64/libqtikeymaster4.so /vendor/lib64/
cp /v/lib64/hw/keystore.mt6765.so /vendor/lib64/hw/
cp /v/lib64/hw/vendor.mediatek.hardware.keymaster_attestation@1.1-impl.so /vendor/lib64/hw/
cp /v/lib64/hw/android.hardware.gatekeeper@1.0-impl /vendor/lib64/hw/
#cp /v/lib64/hw/android.hardware.keymaster@3.0-impl /vendor/lib64/hw/

cp /v/manifest.xml /vendor/etc/vintf
cp /v/compatibility_matrix.xml /vendor/etc/vintf

relink /v/bin/hw/vendor.microtrust.hardware.capi@2-service
relink /v/bin/hw/android.hardware.gatekeeper@1.0-service
relink /v/bin/hw/android.hardware.keymaster@3.0-service
relink /v/bin/hw/vendor.mediatek.hardware.keymaster_attestation@1.1-service