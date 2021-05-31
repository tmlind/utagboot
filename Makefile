# Using "noinitrd" does not seem to work here, use bogus initrd instead
def_cmd=initrd=0x8000000,128K console=ttyO2,115200 fbcon=rotate:1 \
rootwait ro

utags: clean droid4_kexecboot

droid4_kexecboot:
	echo "Generating droid4-kexecboot utags file.."
	./utagboot.sh --filename=utags-droid4-kexecboot-mmcblk1p13.bin \
	--dtname=p2a_maserati \
	--cmdline="$(def_cmd) root=/dev/mmcblk1p13 init=/sbin/preinit.sh"
	hexdump -C utags-droid4-kexecboot-mmcblk1p13.bin

clean:
	rm -f utags*.bin
