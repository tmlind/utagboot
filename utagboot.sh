#!/bin/sh
#
# utagboot.sh - bootloader configuration script for droid 4 xt894
#

function append_hex_32() {
	file=$1
	number=$2

	if ! printf "0: %08x" $number | xxd -r >> $file; then
		echo "Could not write to $file"
		exit 1
	fi
}

function append_hex_8() {
	file=$1
	number=$2

	if ! printf "0: %02x" $number | xxd -r >> $file; then
		echo "Could not write to $file"
		exit 1
	fi
}

function append_ascii_utag() {
	file=$1
	type=$2
	string=$3

	len=$(echo -n $string | wc -c)
	if [ "$len" -gt 0 ]; then
		pad=$((8 - ($len % 8)))
	else
		pad=0
	fi

	append_hex_32 $file $type
	append_hex_32 $file $((($len + $pad) / 4))

	if [ "$len" -eq 0 ]; then
		return
	fi

	if ! echo -n "$string" >> $file; then
		echo "Could not write to $file"
		exit 1
	fi

	for i in $(seq 1 $pad); do
		append_hex_8 $file 0
	done
}

function build_utags() {
	file=$1
	cmdline="p2a_maserati $2"

	if [ -f ${file} ]; then
		echo "${file} already exists, please remove it first"
		exit 1
	fi

	echo "File: ${file}"
	echo "Generated kernel cmdline:"
	echo "$cmdline"

	append_ascii_utag ${file} $((0xcafe0001)) ""
	append_ascii_utag ${file} $((0xcafe0003)) "$cmdline"
	append_ascii_utag ${file} $((0xcafe0002)) ""
}

if [ "$1" == "" ] || [ "$2" == "" ]; then
	echo "Usage: $0 output_file cmd_line"
	exit 1
fi

target=$1
cmdline=$2
build_utags ${target} "${cmdline}"
