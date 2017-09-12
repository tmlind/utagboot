install: utagboot
	fastboot flash utags utags.bin

uninstall:
	fastboot erase utags

utagboot: clean
	./utagboot.sh "$(cmdline)"
	hexdump -C utags.bin

clean:
	rm -f utags.bin
