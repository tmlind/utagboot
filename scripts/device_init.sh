#!/bin/sh

#
# kexec boot script for droid 4 to reboot the stock
# 3.0.8-g448a95f kernel into something more usable.
#

utagboot_base="/boot/utagboot"
stock_kernel="3.0.8-g448a95f"
mapphone="mapphone_CDMA"

conf_file="/boot/utagboot/utagboot.conf"
default_cmdline="console=tty0 console=ttyS2,115200 fbcon=rotate:1 rootwait \
debug earlyprintk earlycon"
default_dtb="${utagboot_base}/omap4-droid4-xt894.dtb"
default_vmlinuz="${utagboot_base}/vmlinuz"
default_initramfs=""

args=$1

init_system() {
	export path=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin
	mount -t proc none /proc
	mount -t sysfs none /sys

	kernel_version=$(uname -r)
	hardware=$(grep Hardware /proc/cpuinfo | cut -d' ' -f2)
	stock_kexec_modules="${utagboot_base}/lib/modules/${stock_kernel}/kernel/"

	if [ -f ${conf_file} ]; then
		source ${conf_file}
	fi

	if [ "${cmdline}" == "" ]; then
		current_root=$(mount | grep " on / " | cut -d' ' -f1)
		cmdline="${default_cmdline} root=${current_root}"
	fi

	if [ "${dtb}" == "" ]; then
		dtb="${default_dtb}"
	fi

	if [ "${vmlinuz}" == "" ]; then
		vmlinuz="${default_vmlinuz}"
	fi

	if [ "${initramfs}" == "" ]; then
		initramfs="${default_initramfs}"
	fi
}

load_modules() {
	if [ "${kernel_version}" == "${stock_kernel}" ] && \
		[ "${hardware}" == "${mapphone}" ]; then
		kexec_needed=1

		# Kexec booting at 300MHz rate can be flakey, force 1.2GHz
		echo 1200000 > /sys/devices/system/cpu/cpu0/cpufreq/scaling_min_freq

		# Ignore noisy stock kernel kexec..
		echo 3 > /proc/sysrq-trigger

		insmod ${stock_kexec_modules}/uart.ko
		insmod ${stock_kexec_modules}/arm_kexec.ko
		insmod ${stock_kexec_modules}/kexec.ko
	fi
}

check_file() {
	file="$1"

	if [ ! -f ${file} ]; then
		echo "Could not find ${file}"
		return 1
	fi
}

kexec_to_initramfs() {
	if [ "${args}" == "--force" ] || [ "${kexec_needed}" == "1" ]; then
		echo "Attempting kexec reboot.."
	else
		echo "No kexec reboot needed, use --force if needed"
		return 0
	fi

	read -t 3 -n 1 -p "Press x to skip kexec: " answer
	if [ "${answer}" == "x" ]; then
		return 0
	fi

	echo

	if [ ! -d ${utagboot_base} ]; then
		echo
		echo "Could not find ${utagboot_base} directory"
		return 1
	fi

	if ! check_file ${dtb}; then
		return 1
	fi
	if ! check_file ${vmlinuz}; then
		return 1
	fi

	echo "Trying to kexec to bootloader"
	echo "dtb: ${dtb}"
	echo "vmlinuz: ${vmlinuz}"
	echo "initramfs: ${initramfs}"
	echo "cmdline: ${cmdline}"

	if [ "${initramfs}" != "" ] && [ -f ${initramfs} ]; then
		initramfs="--ramdisk=${initramfs}"
	else
		initramfs=""
	fi

	kexec -d -l ${vmlinuz} --image-size=33554432 \
		--dtb=${dtb} \
		--command-line="${cmdline}" \
		${initramfs}
	sync
	kexec -e
}

init_system
load_modules
kexec_to_initramfs

echo "Trying to continue normal init.."
exec /sbin/init
