# Using "noinitrd" does not seem to work here, use bogus initrd instead
def_cmd=initrd=0x8000000,128K console=ttyO2,115200 fbcon=rotate:1 \
rootwait ro
cmdline=$(def_cmd) root=/dev/mmcblk1p23 init=/sbin/init
target=output/utagboot/

kexec_modules_url=http://muru.com/linux/d4/
kexec_modules_version=0.3
kexec_modules=ddroid4-mainline-kexec-$(kexec_modules_version).tar.xz
stock_kernel_modules=$(target)lib/modules/3.0.8-g448a95f/kernel/

install: utags
	fastboot flash utags utags.bin

uninstall:
	fastboot erase utags

utags: clean
	mkdir -p $(target)
	echo "Generating default utags.bin using /dev/mmcblk1p23.."
	scripts/utagboot.sh $(target)utags.bin "$(cmdline)"
	hexdump -C $(target)utags.bin

	#
	# NOTE: Custom utags.bin created, please verify it points to
	# correct init. That is now init=/boot/utagboot/init for
	# installable utagboot configuration.
	#

utagboot_utags: clean
	mkdir -p $(target)

	echo "Generating usable default utags-*.bin files.."
	scripts/utagboot.sh $(target)utags-mmcblk0p1.bin "$(def_cmd) \
	root=/dev/mmcblk0p1 init=/boot/utagboot/init"
	scripts/utagboot.sh $(target)utags-mmcblk0p2.bin "$(def_cmd) \
	root=/dev/mmcblk0p2 init=/boot/utagboot/init"
	scripts/utagboot.sh $(target)utags-mmcblk0p3.bin "$(def_cmd) \
	root=/dev/mmcblk0p3 init=/boot/utagboot/init"
	scripts/utagboot.sh $(target)utags-mmcblk0p4.bin "$(def_cmd) \
	root=/dev/mmcblk0p4 init=/boot/utagboot/init"
	scripts/utagboot.sh $(target)utags-mmcblk1p22.bin "$(def_cmd) \
	root=/dev/mmcblk1p22 init=/boot/utagboot/init"
	scripts/utagboot.sh $(target)utags-mmcblk1p23.bin "$(def_cmd) \
	root=/dev/mmcblk1p23 init=/boot/utagboot/init"
	scripts/utagboot.sh $(target)utags-mmcblk1p25.bin "$(def_cmd) \
	root=/dev/mmcblk1p25 init=/boot/utagboot/init"

download_files:
	mkdir -p download
	if [ ! -f download/$(kexec_modules) ]; then \
		curl $(kexec_modules_url)$(kexec_modules) \
		-o download/$(kexec_modules); \
		tar xf download/$(kexec_modules) -C download/; \
	fi

install_modules: download_files
	mkdir -p $(stock_kernel_modules)
	cp download/droid4-mainline-kexec-$(kexec_modules_version)/uart.ko \
	$(stock_kernel_modules)
	cp download/droid4-mainline-kexec-$(kexec_modules_version)/arm_kexec.ko \
	$(stock_kernel_modules)
	cp download/droid4-mainline-kexec-$(kexec_modules_version)/kexec.ko \
	$(stock_kernel_modules)

clean:
	rm -f $(target)utags*.bin
