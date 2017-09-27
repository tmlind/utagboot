# Using "noinitrd" does not seem to work here, use bogus initrd instead
def_cmd=initrd=0x8000000,128K console=ttyO2,115200 fbcon=rotate:1 \
rootwait ro init=/sbin/init
cmdline=$(def_cmd) root=/dev/mmcblk1p23
target=

install: utagboot
	fastboot flash utags utags.bin

uninstall:
	fastboot erase utags

utagboot: clean

	./utagboot.sh $(target)utags.bin "$(cmdline)"
	hexdump -C $(target)utags.bin

clean:
	rm -f $(target)utags*.bin
