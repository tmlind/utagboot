# Using "noinitrd" does not seem to work here, use bogus initrd instead
def_cmd=initrd=0x8000000,128K console=ttyO2,115200 fbcon=rotate:1 \
rootwait ro

utags: clean xt894_16_kexecboot xt910_16_kexecboot xt912_16_kexecboot mz609_32_kexecboot mz617_32_kexecboot

xt894_16_kexecboot:
	echo "Generating droid4-kexecboot utags file.."
	./utagboot.sh \
	--filename=utags-xt894-16-mmcblk1p8-boots-mmcblk1p13-kexecboot.bin \
	--dtname=p2a_maserati \
	--cmdline="$(def_cmd) root=/dev/mmcblk1p13 init=/sbin/preinit.sh"
	hexdump -C utags-xt894-16-mmcblk1p8-boots-mmcblk1p13-kexecboot.bin

xt910_16_kexecboot:
	echo "Generating xt910-16-kexecboot utags file.."
	./utagboot.sh \
	--filename=utags-xt910-16-mmcblk1p8-boots-mmcblk1p13-kexecboot.bin \
	--dtname=XT910-16 \
	--cmdline="$(def_cmd) root=/dev/mmcblk1p13 init=/sbin/preinit.sh"
	hexdump -C utags-xt910-16-mmcblk1p8-boots-mmcblk1p13-kexecboot.bin

xt912_16_kexecboot:
	echo "Generating xt912-16-kexecboot utags file.."
	./utagboot.sh \
	--filename=utags-xt912-16-mmcblk1p8-boots-mmcblk1p13-kexecboot.bin \
	--dtname=XT912-16 \
	--cmdline="$(def_cmd) root=/dev/mmcblk1p13 init=/sbin/preinit.sh"
	hexdump -C utags-xt912-16-mmcblk1p8-boots-mmcblk1p13-kexecboot.bin

mz609_32_kexecboot:
	echo "Generating mz609-32-kexecboot utags file.."
	./utagboot.sh \
	--filename=utags-mz609-32-mmcblk1p6-boots-mmcblk1p18-kexecboot.bin \
	--dtname=MZ609-32 \
	--serialno=TA44300000 \
	--cmdline="$(def_cmd) root=/dev/mmcblk1p18 init=/sbin/preinit.sh"
	hexdump -C utags-mz609-32-mmcblk1p6-boots-mmcblk1p18-kexecboot.bin

mz617_32_kexecboot:
	echo "Generating mz617-32-kexecboot utags file.."
	./utagboot.sh \
	--filename=utags-mz617-32-mmcblk1p6-boots-mmcblk1p18-kexecboot.bin \
	--dtname=MZ617-32 \
	--serialno=TA44300000 \
	--cmdline="$(def_cmd) root=/dev/mmcblk1p18 init=/sbin/preinit.sh"
	hexdump -C utags-mz617-32-mmcblk1p6-boots-mmcblk1p18-kexecboot.bin

clean:
	rm -f utags*.bin
