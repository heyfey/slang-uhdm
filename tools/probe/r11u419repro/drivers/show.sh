#!/bin/bash
# r11u419 show.sh <casedir> <binary> [ENV=VAL...]: strict head records (golden A, ours B) of one case
SC=${STRICTCMP:-/tmp/r11u419_bin/strictcmp}
c=$(readlink -f $1); B=$2; shift 2
h=$(cat $c/dut.sv $c/TOP 2>/dev/null | md5sum | cut -c1-16); G=/tmp/r11u419_gold/$h
tag=$(echo "$c $B $*" | md5sum | cut -c1-12); O=/tmp/r11u419_scr/o_$tag.uhdm
[ -f $O ] || bash $(dirname $(readlink -f $0))/case.sh $c $B "$@" >/dev/null
$SC --max ${MAX:-6} $G/golden.uhdm $O 2>&1 | head -${LINES_:-20}
