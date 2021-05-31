#!/bin/sh
#
# utagboot.sh - bootloader configuration script for droid 4 xt894
#

options="
baseband
bootmode
carrier
cmdline
display
dtname
filename
fti
logswitch
modelno
msn
serialno
target"

required_options="
dtname
cmdline
filename
"

function print_usage_exit() {
	echo "usage: ${0} --target=xt894 --cmdline=/sbin/init .."
	echo "where the configurable options are:"
	for opt in ${options}; do
		echo "  --${opt}=value"
	done
	echo "where required options are:"
	for opt in ${required_options}; do
		echo "  --${opt}=value"
	done
	echo ""
	echo ""

	exit 1
}

function parse_arg_and_init() {
	arg="${1}"
	opt="${2}"

	found_opt=""
	found_val=""

	case "$arg" in
		"--help")
		print_usage_exit
		;;
	esac

	key=$(echo "${arg}" | cut -d'=' -f1)
	val=$(echo "${arg}" | sed -e "s/${key}=//")

	if [ "${key}" == "" ] || [ "${val}" == "" ]; then
		print_usage_exit
	fi

	case "${key}" in
		"--${opt}")
		found_opt="${opt}"
		found_val="${val}"
		export "${found_opt}=${found_val}"
		found_options="${found_options} ${found_opt}"
		;;
	esac
}

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
	pad=$(($len % 4))
	if [ "$pad" -gt 0 ]; then
		pad=$((4 - $pad))
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

function append_nonempty_utag() {
	file="${1}"
	type="${2}"
	string="${3}"

	if [ "${string}" == "" ]; then
		return
	fi

	append_ascii_utag ${file} $((${type})) "${string}"
}

function build_utags() {
	if [ "${filename}" == "" ]; then
		echo "ERROR: filename missing"
		print_usage_exit
	fi

	if [ -f ${filename} ]; then
		echo "${file} already exists, please remove it first"
		exit 1
	fi

	if [ "${dtname}" == "" ]; then
		echo "ERROR: dtname missing"
		print_usage_exit
	fi

	if [ "${cmdline}" == "" ]; then
		echo "ERROR: cmdline missing"
		print_usage_exit
	fi

	dtname_and_cmdline="${dtname} ${cmdline}"
	echo "Generated product tag with dummy initrd and kernel cmdline:"
	echo "${dtname_and_cmdline}"

	# Note serialno is first at least on mz617 while xy894 does not use it
	append_ascii_utag ${filename} $((0xcafe0001)) ""
	append_nonempty_utag ${filename} $((0xcafe0004)) "${serialno}"
	append_nonempty_utag ${filename} $((0xcafe0003)) "${dtname_and_cmdline}"
	append_nonempty_utag ${filename} $((0xcafe0005)) "${fti}"
	append_nonempty_utag ${filename} $((0xcafe0006)) "${msn}"
	append_nonempty_utag ${filename} $((0xcafe0007)) "${modelno}"
	append_nonempty_utag ${filename} $((0xcafe0008)) "${carrier}"
	append_nonempty_utag ${filename} $((0xcafe0009)) "${logswitch}"
	append_nonempty_utag ${filename} $((0xcafe000a)) "${baseband}"
	append_nonempty_utag ${filename} $((0xcafe000b)) "${display}"
	append_nonempty_utag ${filename} $((0xcafe000c)) "${bootmode}"
	append_ascii_utag ${filename} $((0xcafe0002)) ""
}

for arg in "$@"; do
    shift
    for opt in ${options}; do
	parse_arg_and_init "${arg}" "${opt}"
    done
done

build_utags
